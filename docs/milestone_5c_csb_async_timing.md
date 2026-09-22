# Milestone 5C — CSB Asynchronous Timing Characterization

## 1. Objective

Milestone 5C characterizes the asynchronous timing behavior associated with the SPI chip-select input (`CSB`) after the full input/output PAD integration completed in Milestone 5B.

The main goals are:

1. Understand how external `CSB` propagates to the asynchronous clear pins of the SPI slave state registers.
2. Check the recovery/removal behavior associated with asynchronous reset release.
3. Characterize the delay from `CSB` assertion to the first valid external MISO value.
4. Characterize the delay from `CSB` deassertion to MISO High-Z.
5. Derive practical pre-layout interface timing parameters for the SPI slave.

The two main external interface parameters obtained in this milestone are:

- `tCSS`: CSB assertion to first MISO-valid time.
- `tDIS`: CSB deassertion to MISO High-Z time.

---

## 2. Design Context

The current SPI slave uses:

- SPI Mode 0
- 16-bit word width
- MSB first
- Full duplex
- Active-low `CSB`
- Rising SCLK edge for RX sampling
- Falling SCLK edge for TX update
- Shared MISO with explicit output enable

The slave does not currently use a separate global reset. Instead, `CSB` is also used to asynchronously clear transaction state.

Relevant RTL behavior is conceptually:

```systemverilog
always_ff @(posedge sclk or posedge csb_n)
```

for the RX state, and:

```systemverilog
always_ff @(negedge sclk or posedge csb_n)
```

for the TX state.

Therefore:

```text
CSB high
    -> slave deselected
    -> transaction state asynchronously cleared

CSB falling
    -> slave selected
    -> asynchronous clear released
```

The external `CSB` signal first passes through the input PAD before reaching the SPI core.

---

## 3. Characterization Conditions

The Milestone 5C characterization uses the same baseline as Milestone 5B.

| Parameter | Value |
|---|---|
| Process | TSMC 180-nm BCD |
| Core/IO operating condition | TT / NCCOM |
| Temperature | 25 °C |
| Supply | 5 V |
| SPI word width | 16 bits |
| SCLK frequency | 110 MHz |
| SCLK period | 9.090909 ns |
| Half period | 4.545455 ns |
| External SCLK slew | 1.0 ns |
| External MOSI slew | 1.0 ns |
| External CSB slew | 1.0 ns |
| External MISO load | 5.0 pF |
| Timing stage | Pre-layout synthesis |

The full-IO wrapper is:

```text
spi_slave_full_io_pad_wrapper
```

The PAD cell used for SCLK, MOSI, CSB, and MISO is:

```text
PDDW0208CSG
```

The MISO PAD uses:

```text
DS = 1
IE = 0
PE = 0
OEN = ~miso_oe_core
```

where `OEN` is active low:

```text
OEN = 0 -> output driver enabled
OEN = 1 -> output driver disabled / High-Z
```

---

## 4. CSB Asynchronous Reset Mapping

After synthesis, the asynchronous clear structure is mapped as:

```text
external csb_pad
       |
       v
PDDW0208CSG input PAD
       |
       v
csb_core
       |
       v
INVD1 g4626
       |
       v
n_3
       |
       +----> RX shift-register CDN
       +----> RX counter CDN
       +----> TX counter CDN
       +----> rx_valid CDN
```

The synthesized inverter is:

```text
n_3 = ~csb_core
```

The mapped flip-flops use active-low asynchronous clear pins:

```text
CDN
```

Therefore:

```text
external CSB high
    -> csb_core high
    -> n_3 low
    -> CDN low
    -> asynchronous clear asserted

external CSB falling
    -> csb_core falling
    -> n_3 rising
    -> CDN rising
    -> asynchronous clear released
```

Thus, asynchronous reset release corresponds to the **rising edge of CDN**.

Note that synthesized instance names such as `g4626` are implementation-generated names and may change after remapping. They are useful for characterization but should not be treated as stable RTL-level interface names.

---

## 5. CSB-to-CDN Delay

The direct Genus timing report from external `csb_pad` to a representative asynchronous clear pin produced:

```text
Startpoint: csb_pad
Endpoint:   u_spi_slave_rx_valid_reg/CDN
```

The timing path is:

```text
csb_pad
    |
    | external slew = 1000 ps
    v
u_csb_pad/PAD
    |
    | PAD -> C
    | delay = 621 ps
    | output slew = 240 ps
    v
u_csb_pad/C
    |
    | INVD1
    | delay = 216 ps
    | output slew = 272 ps
    v
g4626/ZN
    |
    v
FF CDN
```

Total delay:

```text
CSB pad -> CDN release
= 621 ps + 216 ps
= 837 ps
```

Therefore:

```text
t(CSB -> CDN release) = 0.837 ns
```

The reset-release slew at the asynchronous clear network is approximately:

```text
CDN rise slew ~= 0.272 ns
```

This agrees with the reset-net report, which showed approximately:

```text
Rise slew ~= 271.5 ps
```

---

## 6. SCLK Slew at the Core

The SCLK input PAD uses the Liberty timing table:

```text
IO_SLEW2CORE_LOAD_5x6
```

For the current configuration:

```text
external SCLK slew = 1.0 ns
SCLK core load ~= 0.1225 pF
```

The relevant `rise_transition` row at a 1.0 ns PAD input transition is:

```text
Load (pF):       0.01    0.03    0.05    0.10    0.30    0.50
Transition(ns):  0.1691  0.2128  0.2610  0.3654  0.8075  1.2670
```

Interpolating between 0.10 pF and 0.30 pF:

```text
fraction
= (0.1225 - 0.10) / (0.30 - 0.10)
= 0.1125
```

Therefore:

```text
SCLK core rise slew
~= 0.3654 + 0.1125 * (0.8075 - 0.3654)
~= 0.415 ns
```

This value is used for the asynchronous recovery/removal characterization.

The SCLK PAD propagation delay previously characterized in Milestone 5B is:

```text
SCLK PAD rise delay = 0.6738 ns
SCLK PAD fall delay = 0.7487 ns
```

---

## 7. Recovery and Removal Characterization

The mapped asynchronous-clear flip-flops include cells such as:

```text
DFCNQD1
DFCND1
DFCNQD4
```

Their Liberty models provide:

```text
recovery_rising
removal_rising
```

constraints between:

```text
related_pin = CP
constrained pin = CDN
```

The constraint table uses:

```text
variable_1 = related_pin_transition
           = CP transition

variable_2 = constrained_pin_transition
           = CDN transition
```

Using approximately:

```text
CP rise slew  = 0.415 ns
CDN rise slew = 0.272 ns
```

the interpolated RX constraints are approximately:

| Cell | Recovery | Removal |
|---|---:|---:|
| DFCNQD1 | -0.344 ns | +0.886 ns |
| DFCND1 | -0.345 ns | +0.886 ns |

A negative recovery number is valid Liberty characterization and must not be clamped to zero.

For the RX path, the recovery relationship can be written conceptually as:

```text
CDN release arrival + recovery <= internal SCLK rising arrival
```

Using the measured values:

```text
CSB -> CDN release     = 0.837 ns
Recovery              ~= -0.344 ns
SCLK PAD rise delay    = 0.6738 ns
```

the external CSB-to-SCLK requirement implied purely by recovery is:

```text
tCSS,recovery
>= 0.837 - 0.344 - 0.6738
~= -0.181 ns
```

Therefore, under the current TT pre-layout conditions:

```text
RX asynchronous-reset recovery does not impose
a positive external tCSS requirement.
```

This does **not** imply that a negative chip-select setup time should be used as an SPI specification. It only means that recovery is not the dominant constraint under this characterization condition.

The approximately 0.886 ns removal constraint is also retained for asynchronous timing analysis, but it should not be directly interpreted as the external SPI `tCSS` requirement.

---

## 8. CSB Assertion to MISO Output Enable

The MISO PAD output-enable path was reported using:

```text
CSB -> u_miso_pad/OEN -> external miso_pad
```

The result was:

```text
CSB falling -> external MISO rising through OEN
Data path = 3139 ps
```

The important components are:

```text
CSB input PAD
    -> 621 ps

MISO PAD OEN -> PAD
    -> 2518 ps

Total
    -> 3139 ps
```

Therefore:

```text
CSB -> MISO output-enable path ~= 3.139 ns
```

However, output enable alone is not sufficient to guarantee that the correct first MISO data bit is present.

---

## 9. CSB Assertion to First MISO Data

The complete CSB-to-MISO data path was:

```text
csb_pad
    |
    v
u_csb_pad/C
    |
    v
g4626/ZN
    |
    v
TX combinational selection logic
    |
    v
u_miso_pad/I
    |
    v
u_miso_pad/PAD
    |
    v
miso_pad
```

The detailed delay was:

```text
CSB PAD->C             621 ps
INVD1                  216 ps
TX combinational logic 660 ps approximately
MISO PAD I->PAD       2502 ps
--------------------------------
Total                 3999 ps
```

Genus reported:

```text
Data Path = 3999 ps
```

Therefore:

```text
CSB assertion -> external MISO data
= 3.999 ns
```

---

## 10. Rising and Falling First-MISO Cases

Separate edge-specific reports were generated.

### 10.1 CSB Falling -> MISO Rising

Genus reported:

```text
Startpoint: (F) csb_pad
Endpoint:   (R) miso_pad
Data Path:  3999 ps
```

The path is dominated by the MISO data path:

```text
CSB input PAD        621 ps
internal logic       876 ps
MISO output PAD     2502 ps
---------------------------
Total               3999 ps
```

Therefore:

```text
CSB↓ -> MISO↑ = 3.999 ns
```

### 10.2 CSB Falling -> MISO Falling

Genus reported:

```text
Startpoint: (F) csb_pad
Endpoint:   (F) miso_pad
Data Path:  2710 ps
```

The critical path is primarily the output-enable path:

```text
CSB input PAD       621 ps
MISO OEN -> PAD    2089 ps
--------------------------
Total              2710 ps
```

Therefore:

```text
CSB↓ -> MISO↓ = 2.710 ns
```

---

## 11. Pre-layout tCSS

For the first MISO bit to be valid, both:

```text
MISO driver enabled
```

and:

```text
correct MISO data present
```

must be satisfied.

Therefore the worst-case first-bit-valid delay is:

```text
tCSS
= max(
    CSB↓ -> MISO↑,
    CSB↓ -> MISO↓
  )

= max(
    3.999 ns,
    2.710 ns
  )

= 3.999 ns
```

The Milestone 5C pre-layout baseline is therefore:

```text
tCSS ~= 4.00 ns
```

Definition used in this milestone:

```text
       CSB falling edge
              |
              |<------ tCSS ------>|
              |                    |
              v                    v
           CSB asserted       first MISO
                              sampling edge
```

Under the current characterization model, the external Master should allow approximately 4.0 ns between asserting CSB and sampling the first MISO bit.

This is a **pre-layout TT characterization result**, not yet a final silicon datasheet guarantee.

---

## 12. 110 MHz tCSS Margin

At 110 MHz:

```text
T = 1 / 110 MHz
  = 9.0909 ns
```

The half-cycle duration is:

```text
T / 2 = 4.5455 ns
```

If the Master asserts CSB one half-cycle before the first active SCLK rising edge:

```text
Available time = 4.5455 ns
Required tCSS  = 3.9990 ns
```

Therefore:

```text
Margin
= 4.5455 - 3.9990
= 0.5465 ns
```

or approximately:

```text
tCSS margin ~= +0.546 ns
```

Thus, under the current TT pre-layout model:

```text
half-cycle CSB setup at 110 MHz passes,
but the margin is relatively limited.
```

---

## 13. MISO PAD Contribution to tCSS

The critical CSB-to-MISO rising path contains:

```text
MISO PAD I->PAD delay = 2.502 ns
Total path            = 3.999 ns
```

Therefore the MISO PAD contributes approximately:

```text
2.502 / 3.999 ~= 62.6%
```

of the total first-bit-valid delay.

This is consistent with the Milestone 5B observation that the external MISO PAD is the dominant timing component of the SPI output interface.

The SPI core logic itself is not the dominant delay source under the current full-IO configuration.

---

## 14. CSB Deassertion and MISO High-Z

Because multiple slaves may share the MISO bus, it is also necessary to characterize how quickly the current slave releases the MISO line after CSB is deasserted.

The relevant sequence is:

```text
external CSB ↑
      |
      v
CSB input PAD
      |
      v
csb_core ↑
      |
      v
u_miso_pad/OEN ↑
      |
      v
three_state_disable
      |
      v
MISO High-Z
```

Because:

```text
OEN = 0 -> drive PAD
OEN = 1 -> High-Z
```

CSB rising causes the MISO PAD output driver to be disabled.

---

## 15. MISO Three-State Disable Liberty Arc

For the actual configuration:

```text
DS = 1
```

the relevant Liberty arc is:

```text
when : "DS";
sdf_cond : "DS == 1'b1";
timing_type : three_state_disable;
related_pin : "OEN";
timing_sense : positive_unate;
```

Therefore the PAD model explicitly provides an `OEN -> High-Z` timing characterization for the configuration used by the design.

This is different from the `DS=0` characterization and the correct `DS=1` table must be used.

---

## 16. Direct Genus tDIS Result

Genus directly reported the CSB deassertion path using:

```text
CSB rising
    -> MISO OEN rising
    -> three-state disable
    -> external MISO
```

The timing report showed:

```text
Startpoint: (R) csb_pad
Endpoint:   (F) miso_pad
Data Path:  2210 ps
```

Detailed path:

```text
csb_pad
    |
    v
u_csb_pad/PAD
    |
    | PAD -> C
    | transition = 241 ps
    | delay = 569 ps
    v
u_csb_pad/C
    |
    | OEN -> PAD
    | three_state_disable
    | transition = 1295 ps
    | delay = 1640 ps
    v
u_miso_pad/PAD
    |
    v
miso_pad
```

Thus:

```text
CSB input PAD delay      = 0.569 ns
MISO three-state disable = 1.640 ns
----------------------------------
Total tDIS               = 2.210 ns
```

Therefore:

```text
tDIS = 2.210 ns
```

The falling-edge notation used for the MISO endpoint in the timing report is the Liberty/STA representation of the three-state-disable arc. Physically, the relevant interpretation is that the MISO output driver is released into the High-Z state.

---

## 17. Milestone 5C Final Interface Parameters

The main pre-layout SPI interface parameters obtained in Milestone 5C are:

| Parameter | Definition | TT Pre-layout Result |
|---|---|---:|
| `tCSS` | CSB↓ to first valid MISO value | **3.999 ns** |
| `tDIS` | CSB↑ to MISO High-Z | **2.210 ns** |
| `tCSB->CDN` | CSB↓ to asynchronous reset release | **0.837 ns** |
| RX recovery | FF recovery requirement at measured slew | approximately **-0.344 ns** |
| RX removal | FF removal requirement at measured slew | approximately **+0.886 ns** |
| 110 MHz half-cycle tCSS margin | 4.545 ns - 3.999 ns | **+0.546 ns** |

For reporting purposes:

```text
tCSS ~= 4.00 ns
tDIS ~= 2.21 ns
```

under the current TT pre-layout characterization conditions.

---

## 18. Interpretation for Multi-Slave SPI

The development architecture contains:

```text
1 Master + 2 Slaves
```

with shared:

```text
SCLK
MOSI
MISO
```

and independent:

```text
CSB[0]
CSB[1]
```

The `tDIS` characterization is particularly relevant to the shared MISO bus.

When switching between slaves:

```text
Slave A CSB ↑
     |
     |  Slave A requires up to ~2.21 ns
     |  to release MISO
     |
MISO High-Z
     |
Slave B may safely become the active driver
```

Therefore system-level bus-turnaround timing should account for MISO release time to avoid temporary output contention.

The exact board-level requirement will later depend on the FPGA timing, package delay, PCB routing, and final post-layout ASIC timing.

---

## 19. Important Limitations

The results in this milestone are **not final silicon guarantees**.

They are based on:

```text
TT / 25 °C / 5 V
pre-layout synthesis
wireload-based timing
1 ns external input slew
5 pF external MISO load
no package parasitics
no PCB routing delay
no FPGA setup/hold requirement
no extracted post-layout interconnect
```

Therefore the following work is still required before defining final interface specifications:

1. Slow/fast PVT characterization.
2. Post-placement/post-route STA.
3. Extracted RC timing analysis.
4. Final PAD-ring and package parasitics.
5. FPGA I/O timing requirements.
6. Board-level signal-integrity and routing delay.
7. Final system-level timing margin.

The values:

```text
tCSS ~= 4.00 ns
tDIS ~= 2.21 ns
```

should therefore be described as:

```text
pre-layout TT baseline characterization
```

rather than guaranteed datasheet limits.

---

## 20. Reports Generated

The Milestone 5C script is:

```text
syn/run_csb_async.tcl
```

The main reports include:

```text
reports/csb_reset_net_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_cdn_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_miso_oen_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_miso_data_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_miso_pad_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_miso_rise_csb_async_110MHz_5pF.rpt

reports/timing_csb_to_miso_fall_csb_async_110MHz_5pF.rpt

reports/timing_csb_disable_miso_csb_async_110MHz_5pF.rpt
```

The frozen result directory is:

```text
syn/results/csb_async_tt_16bit_5pF/
```

---

## 21. Milestone 5C Conclusion

Milestone 5C completed the pre-layout characterization of the SPI slave chip-select asynchronous behavior.

The main findings are:

```text
CSB -> asynchronous reset release:
    0.837 ns

RX asynchronous recovery:
    not the limiting external tCSS constraint
    under the current TT condition

CSB↓ -> first external MISO valid:
    worst case = 3.999 ns

CSB↑ -> MISO High-Z:
    2.210 ns

110 MHz half-cycle CSB setup margin:
    approximately +0.546 ns
```

The dominant `tCSS` path is:

```text
CSB
 -> CSB input PAD
 -> internal first-bit selection logic
 -> MISO output PAD
 -> external MISO
```

while the dominant `tDIS` path is:

```text
CSB
 -> CSB input PAD
 -> MISO OEN
 -> PAD three-state disable
 -> High-Z
```

The MISO PAD remains the dominant contributor to external SPI timing.

Milestone 5C therefore establishes a quantitative pre-layout baseline for CSB timing and shared-MISO bus turnaround behavior before proceeding to physical implementation and post-layout timing analysis.
