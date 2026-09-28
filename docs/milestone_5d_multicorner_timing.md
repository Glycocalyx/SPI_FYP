# Milestone 5D — Pre-layout Multi-Corner Timing Characterization

**Project:** SPI Interface Design (16-bit SPI Slave, TSMC 180-nm BCD)  
**Date:** September 28, 2026  
**Status:** Pre-layout timing characterization completed for TT, WC, BC, and LT corners.

> This milestone characterizes a fixed TT-optimized synthesized netlist
> across four PVT corners. The results do not constitute complete timing
> sign-off. Physical timing, complete asynchronous timing verification,
> and post-CTS hold analysis remain pending.

---

## 1. Objectives

Milestone 5D evaluates the timing performance of the existing
TT-optimized SPI Slave netlist across four PVT corners before
proceeding to Innovus.

The main objectives are:

1. Characterize the operating-frequency boundary of the periodic
   MISO timing path at each corner.
2. Measure CSB-to-MISO propagation delays and MISO output-disable
   delays.
3. Characterize asynchronous reset-release propagation delays.
4. Estimate RX and TX recovery/removal constraints using the
   corresponding Liberty timing tables.
5. Identify the main performance bottlenecks and remaining
   verification requirements.

All experiments use the same fixed synthesized netlist.

No corner-specific resynthesis or optimization is performed.

---

## 2. Design Configuration

### 2.1 SPI Architecture

The design implements a 16-bit full-duplex SPI Slave with:

- SPI Mode 0
- CPOL = 0
- CPHA = 0
- MSB-first transmission
- Independent active-low chip select
- Shared SCLK, MOSI, and MISO interface
- MISO output-enable control
- CSB-controlled asynchronous transaction reset

The development environment contains one verification Master and
two identical SPI Slaves.

The final ASIC implementation contains the SPI Slave, while an
external FPGA acts as the SPI Master.

### 2.2 Fixed Netlist

Top-level module:

`spi_slave_full_io_pad_wrapper`

Fixed synthesized netlist:

`syn/outputs/spi_slave_csb_async_110MHz_5pF.v`

The netlist was originally optimized under the TT corner.

All four corners use this same cell-level netlist.

The following synthesis operations are not repeated during
multi-corner characterization:

- `syn_generic`
- `syn_map`
- `syn_opt`

This approach isolates the effect of the PVT-dependent timing models
on an unchanged circuit implementation.

### 2.3 IO Configuration

The design uses the `PDDW0208CSG` IO PAD cell.

The complete interface includes:

- SCLK input PAD
- MOSI input PAD
- CSB input PAD
- MISO output PAD

External timing assumptions:

| Parameter | Value |
|---|---:|
| MISO external load | 5 pF |
| SCLK input transition | 1 ns |
| MOSI input transition | 1 ns |
| CSB input transition | 1 ns |
| External MOSI input delay | 0 ns |
| External MISO output delay | 0 ns |

The zero external delays are idealized characterization assumptions.

Actual FPGA timing requirements, package delays, PCB propagation
delays, and clock uncertainty have not yet been incorporated.

### 2.4 Tool

Cadence Genus:

`21.14-s082_1`

The analysis uses the available pre-layout wireload model.

Physical placement, clock-tree synthesis, routing, and extracted
parasitics are not included.

---

## 3. PVT Corners

Four corners with matching Core and IO Liberty models are evaluated.

| Corner | Voltage | Temperature | Core Liberty | IO Liberty |
|---|---:|---:|---|---|
| TT | 5.0 V | 25 °C | tcb018bcdgp2atc.lib | tps018bcdnv5tc.lib |
| WC | 4.5 V | 125 °C | tcb018bcdgp2awc.lib | tps018bcdnv5wc.lib |
| BC | 5.5 V | 0 °C | tcb018bcdgp2abc.lib | tps018bcdnv5bc.lib |
| LT | 5.5 V | -40 °C | tcb018bcdgp2alt.lib | tps018bcdnv5lt.lib |

Additional Core Liberty models exist for certain 150 °C conditions.

These conditions are not included in this milestone because
corresponding matched IO Liberty models were not identified.

---

## 4. Pre-layout Clock Model

The timing environment uses two clocks:

1. Virtual external clock `EXT_SCLK`.
2. Ideal internal clock `CORE_SCLK`.

The internal clock is defined at:

`u_sclk_pad/C`

Its waveform incorporates the corresponding SCLK input PAD
propagation delays for each corner.

This compensates for the fact that the current Genus version
does not support the required propagated-clock modeling in
the existing synthesis flow.

### 4.1 SCLK PAD Delays

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| Rising delay (ns) | 0.6738 | 0.9816 | 0.5494 | 0.5151 |
| Falling delay (ns) | 0.7487 | 1.0115 | 0.6391 | 0.6104 |

These delays were characterized using the respective Liberty
models and corner-dependent output loads.

Because the internal clock is ideal, Genus may display
zero transition time for the clock network.

The actual signal slew must therefore be estimated separately
from the corresponding Liberty transition tables.

---

## 5. Multi-Corner Frequency Characterization

The same fixed TT-optimized netlist is analyzed using the
timing libraries of each corner.

The reported frequencies represent near-boundary characterization
of the periodic MISO timing path under the current assumptions.

### 5.1 Results

| Corner | Characterized Frequency Boundary | Evidence |
|---|---:|---|
| TT | Approximately 110 MHz | MISO slack approximately +5 ps at 110 MHz |
| WC | Approximately 72.7 MHz | Slack approximately +6 ps at 72.6 MHz |
| BC | Approximately 137 MHz | Slack approximately +3 ps near 137 MHz |
| LT | Approximately 146.9 MHz | Slack approximately -2 ps at 147 MHz |

These frequencies should not be interpreted as guaranteed
maximum operating frequencies.

The measurements do not establish complete setup, hold,
recovery, or removal closure.

### 5.2 Observations

The WC corner exhibits a substantial reduction in the
characterized frequency boundary.

The fixed TT-optimized netlist reaches approximately:

- TT: 110 MHz
- WC: 72.7 MHz
- BC: 137 MHz
- LT: 146.9 MHz

The dominant periodic timing limitation involves the
MISO output path.

In the TT analysis, the complete MISO path delay is
approximately 3.79 ns.

The MISO output PAD contributes approximately 2.50 ns.

Consequently, the output PAD represents a major portion
of the critical-path delay.

Optimizing the Core logic alone may therefore provide
limited improvement to the complete output timing path.

---

## 6. CSB Propagation Characterization

CSB timing is characterized separately from the periodic
MISO timing path.

The following measurements are performed:

1. CSB falling to MISO rising.
2. CSB falling to MISO falling.
3. CSB rising to MISO High-Z.
4. CSB falling to asynchronous reset release.

### 6.1 Propagation Results

All values are in nanoseconds.

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| CSB falling to MISO rising | 3.999 | 6.050 | 3.202 | 2.977 |
| CSB falling to MISO falling | 2.710 | 4.051 | 2.169 | 2.034 |
| Maximum measured CSB-to-MISO path | 3.999 | 6.050 | 3.202 | 2.977 |
| CSB rising to MISO High-Z | 2.210 | 3.253 | 1.828 | 1.695 |
| CSB falling to CDN rising | 0.837 | 1.137 | 0.715 | 0.682 |

The maximum measured CSB-to-MISO path provides an estimate
of the propagation time required for the initial MISO data
to become valid after CSB assertion.

However, the actual minimum CSB setup time depends on the
external Master's sampling schedule and setup requirements.

These values should not be treated as complete interface
timing specifications.

### 6.2 Conditional First-Bit Timing Example

Consider an illustrative assumption in which the external
Master asserts CSB half an SCLK period before the first
sampling edge.

Ignoring external setup requirements, board delays,
package delays, and clock uncertainty produces the
following arithmetic margins:

| Corner | Assumed Frequency | Half-Period (ns) | Illustrative Margin (ns) |
|---|---:|---:|---:|
| TT | 110 MHz | 4.545 | +0.546 |
| WC | 72.6 MHz | 6.887 | +0.837 |
| BC | 137 MHz | 3.650 | +0.448 |
| LT | 146.9 MHz | 3.404 | +0.427 |

These margins are conditional examples only.

They do not establish a guaranteed CSB setup-time
specification.

### 6.3 Asynchronous Reset Release

The CSB reset-release path is:

`csb_pad -> u_csb_pad/C -> g4626/ZN -> FF/CDN`

The input PAD first propagates the CSB signal.

The inverter `g4626` then generates the active-low
asynchronous reset signal required by the internal FFs.

Measured results:

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| CSB-to-CDN delay (ns) | 0.837 | 1.137 | 0.715 | 0.682 |
| CDN rising slew (ns) | 0.272 | 0.376 | 0.225 | 0.211 |

The TT reports independently confirm that the examined
TX and RX FFs share the same reset-release network.

Both paths pass through `g4626` and have a measured
TT delay of 0.837 ns.

The reported reset-network fanout is 27.

Because all four corners use the same fixed netlist,
the corresponding reset-network topology is unchanged.

However, complete reset-path endpoint coverage has
not yet been independently verified at every corner.

---

## 7. RX Recovery and Removal

The RX logic uses the rising edge of SCLK.

The clock path is:

`External SCLK -> SCLK Input PAD -> RX FF CP`

The asynchronous reset-release path is:

`External CSB -> CSB Input PAD -> g4626 -> RX FF CDN`

Recovery and removal constraints are estimated
using the corresponding Liberty timing tables.

Both CP rising slew and CDN rising slew are considered.

### 7.1 RX Slew and Constraint Estimates

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| RX CP rising slew (ns) | 0.415 | 0.607 | 0.348 | 0.324 |
| CDN rising slew (ns) | 0.272 | 0.376 | 0.225 | 0.211 |
| DFCNQD1 Recovery (ns) | -0.344 | -0.525 | -0.271 | -0.253 |
| DFCNQD1 Removal (ns) | 0.886 | 1.403 | 0.671 | 0.620 |

Additional estimates for `DFCND1`:

| Parameter | WC | BC | LT |
|---|---:|---:|---:|
| Recovery (ns) | -0.524 | -0.268 | -0.253 |
| Removal (ns) | 1.406 | 0.672 | 0.622 |

The TT `DFCND1` data has not been separately archived
at the same level of detail.

Negative recovery constraints are valid Liberty
table values.

They do not imply that asynchronous reset timing
checks can be ignored.

The calculations above represent individual
cell-level constraint estimates, not complete
asynchronous timing verification.

---

## 8. TX Recovery and Removal

### 8.1 TX Clock Architecture

The TX bit counter uses an inverted version
of SCLK.

The clock path is:

`External SCLK falling`
`-> SCLK Input PAD`
`-> sclk_core falling`
`-> g1768/ZN rising`
`-> TX FF CP rising`

Because the TX clock passes through an additional
inverter, its clock slew and propagation delay
must be estimated separately from those of RX.

### 8.2 Measured Clock Loads

The output capacitance of the TX clock inverter
was extracted from the fixed netlist at each corner.

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| SCLK PAD falling capacitance (fF) | 120.5 | 113.0 | 126.3 | 126.3 |
| TX inverter rising capacitance (fF) | 13.2 | 12.4 | 14.0 | 14.0 |

The clock-inverter output drives four
TX bit-counter FF clock pins.

### 8.3 TX Clock Characterization

The SCLK PAD falling transition is estimated
using the corresponding IO Liberty table.

The inverter propagation delay and output
transition are then estimated using the
`INVD1` Liberty tables.

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| SCLK PAD falling slew (ns) | 0.434 | 0.658 | 0.363 | 0.334 |
| INVD1 rising delay (ns) | 0.222 | 0.317 | 0.188 | 0.177 |
| TX CP rising slew (ns) | 0.215 | 0.311 | 0.179 | 0.165 |
| External SCLK falling to TX CP rising (ns) | 0.971 | 1.329 | 0.827 | 0.787 |

The total estimated TX clock propagation delay is:

`t_TX_clock = t_SCLK_PAD_fall + t_INVD1_rise`

For example, TT gives:

`t_TX_clock = 0.7487 + 0.2223`

Therefore:

`t_TX_clock = approximately 0.971 ns`

These estimates use Liberty transition and
delay tables rather than the zero-slew values
displayed by the ideal-clock timing model.

### 8.4 TX Recovery/Removal Results

The `DFCNQD4` recovery and removal tables are
evaluated using TX CP rising slew and CDN
rising slew.

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| TX CP rising slew (ns) | 0.215 | 0.311 | 0.179 | 0.165 |
| CDN rising slew (ns) | 0.272 | 0.376 | 0.225 | 0.211 |
| DFCNQD4 Recovery (ns) | -0.383 | -0.573 | -0.304 | -0.284 |
| DFCNQD4 Removal (ns) | 0.861 | 1.366 | 0.651 | 0.603 |

TT, BC, and LT were calculated using the
corresponding extracted Liberty tables.

WC values are retained as approximate
pre-layout estimates.

The results currently apply to the four
characterized TX bit-counter FFs.

Other TX sequential elements and complete
asynchronous endpoint coverage still
require verification.

---

## 9. Summary of Timing Results

### 9.1 Frequency

| Corner | Frequency Boundary |
|---|---:|
| TT | Approximately 110 MHz |
| WC | Approximately 72.7 MHz |
| BC | Approximately 137 MHz |
| LT | Approximately 146.9 MHz |

### 9.2 CSB Paths

| Parameter | TT | WC | BC | LT |
|---|---:|---:|---:|---:|
| Maximum measured CSB-to-MISO path (ns) | 3.999 | 6.050 | 3.202 | 2.977 |
| MISO disable delay (ns) | 2.210 | 3.253 | 1.828 | 1.695 |
| Reset-release delay (ns) | 0.837 | 1.137 | 0.715 | 0.682 |

### 9.3 Main Observations

**Observation 1: Significant PVT sensitivity**

The fixed TT-optimized netlist shows a considerable
frequency reduction under the WC timing models.

**Observation 2: MISO PAD timing dominates**

The MISO output PAD contributes a substantial
portion of the complete output-path delay.

**Observation 3: Initial MISO timing requires
separate consideration**

CSB-to-MISO propagation and periodic MISO timing
are distinct constraints.

Both must be considered when specifying the
external Master interface.

**Observation 4: Asynchronous timing is not
fully verified**

The recovery/removal values are calculated from
Liberty tables.

Complete timing checks must account for the
actual CSB/SCLK edge relationships and cover
all applicable sequential elements.

---

## 10. Verification Status

| Task | Status |
|---|---|
| Fixed-netlist TT frequency characterization | Completed |
| Fixed-netlist WC frequency characterization | Completed |
| Fixed-netlist BC frequency characterization | Completed |
| Fixed-netlist LT frequency characterization | Completed |
| Multi-corner CSB-to-MISO propagation | Completed |
| Multi-corner MISO disable characterization | Completed |
| Multi-corner reset-release propagation | Completed |
| RX recovery/removal Liberty estimation | Completed for characterized cells |
| TX recovery/removal Liberty estimation | Completed for characterized cells |
| TT TX/RX reset-path comparison | Completed |
| Complete asynchronous endpoint coverage | Pending |
| Complete recovery/removal STA | Pending |
| External FPGA and PCB timing model | Pending |
| Physical clock-tree timing | Pending |
| Post-CTS hold verification | Pending |
| Post-route timing sign-off | Pending |

An attempt was made to perform an early timing
report in the current Genus version.

The attempted `report_timing -early` command
was rejected by the tool.

Therefore, no valid pre-layout hold result
was obtained from that experiment.

Full hold verification is deferred to
the physical implementation stage.

---

## 11. Scripts and Experimental Evidence

### 11.1 Fixed Netlist

`syn/outputs/spi_slave_csb_async_110MHz_5pF.v`

### 11.2 Main Scripts

- `syn/run_tt_fixed_sta.tcl`
- `syn/run_wc_csb_sta.tcl`
- `syn/run_bc_csb_sta.tcl`
- `syn/run_lt_csb_sta.tcl`
- `syn/run_tt_tx_clock_sta.tcl`
- `syn/run_wc_tx_clock_sta.tcl`
- `syn/run_bc_tx_clock_sta.tcl`
- `syn/run_lt_tx_clock_sta.tcl`

### 11.3 Main Reports

CSB propagation:

- `csb_miso_rise_<RUN_TAG>.rpt`
- `csb_miso_fall_<RUN_TAG>.rpt`
- `csb_disable_rise_<RUN_TAG>.rpt`
- `csb_disable_fall_<RUN_TAG>.rpt`
- `csb_reset_release_<RUN_TAG>.rpt`

TX clock characterization:

- `tx_clock_net_tt.rpt`
- `tx_clock_net_wc.rpt`
- `tx_clock_net_bc.rpt`
- `tx_clock_net_lt.rpt`

TT additional characterization:

- `sclk_pad_net_tt.rpt`
- `tx_reset_release_tt.rpt`
- `rx_reset_release_tt.rpt`

The actual CSB run tags include:

- `wc_csb_70MHz_5pF`
- `bc_csb_130MHz_5pF`
- `lt_csb_140MHz_5pF`

These tags identify the reference clock used
during the respective CSB measurements.

They are not the maximum-frequency
characterization results.

---

## 12. Next Steps

Before physical implementation, the following
items should be discussed with the supervisor:

1. Required operating frequency across all
   supported PVT corners.
2. Actual FPGA-to-ASIC timing budget.
3. Whether the current TT-optimized implementation
   should proceed directly to preliminary placement.
4. Whether additional WC-oriented optimization
   is necessary before physical design.

During Innovus implementation:

1. Import the required Core and IO physical views.
2. Establish the physical design and timing constraints.
3. Perform placement and clock-tree synthesis.
4. Analyze post-CTS setup and hold timing.
5. Complete routing and parasitic extraction.
6. Perform multi-corner physical timing analysis.
7. Verify asynchronous recovery/removal constraints
   with actual clock and reset propagation.
8. Check all applicable timing endpoints.

---

## 13. Conclusion

Milestone 5D completed pre-layout timing
characterization of a fixed TT-optimized
SPI Slave netlist across four PVT corners.

The periodic MISO path was characterized
near 110 MHz, 72.7 MHz, 137 MHz, and
146.9 MHz for TT, WC, BC, and LT,
respectively.

The results identify the MISO output PAD
as a major timing contributor and show
substantial performance sensitivity to
the WC timing models.

CSB propagation, MISO output-disable
behavior, and asynchronous reset-release
delays were also characterized.

RX and TX recovery/removal constraints
were estimated using the corresponding
Liberty timing tables.

These results establish a documented
pre-layout characterization baseline.

Complete asynchronous STA, realistic
external timing constraints, and
physical timing sign-off remain
necessary before final implementation.
