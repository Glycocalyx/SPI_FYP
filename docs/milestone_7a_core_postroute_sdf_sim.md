# Milestone 7A — Core Post-Route SDF Simulation

**Date:** 2026-10-15  
**Project:** 16-bit SPI Slave ASIC  
**Process:** TSMC 180-nm HV BCD Gen2  
**Scope:** Core-only post-route gate-level timing simulation

---

## 1. Objective

This milestone validates the routed SPI Slave core using a post-route gate-level netlist and Innovus-generated SDF delay back-annotation.

The purpose is to verify that:

1. the routed gate-level implementation remains functionally correct;
2. the Innovus SDF can be successfully back-annotated in Xcelium;
3. the core operates correctly at a 100 MHz SPI SCLK under the current post-route timing model;
4. timing-model mismatches between the Innovus SDF and the TSMC standard-cell Verilog model are identified and understood.

This milestone covers the digital core only.

IO PAD integration, foundry signoff DRC, LVS, PEX, package effects, PCB loading, and final silicon timing are outside the scope of this milestone.

---

## 2. Tools

### Cadence Innovus

Version:

```text
Innovus 21.13-s100_1
```

Used to generate:

- post-route gate-level Verilog netlist;
- post-route SDF timing data.

### Cadence Xcelium

Version:

```text
xrun 23.03-s004
```

Executable environment:

```text
/dfs/app/cadence/xcelium2303hf/tools.lnx86/inca/bin/xrun
```

### TSMC standard-cell simulation model

```text
/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/verilog/tcb018bcdgp2a_110a/tcb018bcdgp2a.v
```

---

## 3. Post-Route Simulation Inputs

### Routed gate-level netlist

```text
syn/outputs/spi_slave_core_postroute.v
```

Top module:

```text
spi_slave
```

### Innovus SDF

```text
syn/outputs/spi_slave_core_postroute.sdf
```

The SDF was regenerated using:

```tcl
write_sdf -recompute_delay_calc /staff/ee/yliumb/spi-fyp/syn/outputs/spi_slave_core_postroute.sdf
```

The SDF header reports:

```text
DESIGN      spi_slave
VOLTAGE     5.000000::5.000000
TEMPERATURE 25.000000::25.000000
TIMESCALE   1.0 ns
```

Therefore this simulation should be interpreted as the current TT-like 5 V / 25 °C post-route timing model.

The `$sdf_annotate` option `MAXIMUM` selects the maximum value available in each SDF timing tuple. It does **not** convert this SDF into a WC process corner.

---

## 4. Dedicated Post-Route Testbench

Testbench:

```text
post_sim/spi_slave_16bit_postroute_tb.sv
```

The verification Master uses:

```systemverilog
.CLK_DIV(1)
```

with a 200 MHz reference clock:

```systemverilog
#2.5 clk = ~clk;
```

The Master generates SCLK according to:

```text
f_SCLK = f_clk / (2 × CLK_DIV)
```

Therefore:

```text
f_SCLK = 200 MHz / (2 × 1)
       = 100 MHz
```

and:

```text
SCLK period = 10 ns
```

The directed full-duplex transaction is:

```text
Master -> Slave : 16'hA5A5
Slave  -> Master: 16'h3C3C
```

The testbench checks:

- correct CSB selection;
- MISO output-enable assertion;
- correct Master-to-Slave receive data;
- correct Slave-to-Master receive data;
- `rx_valid`;
- exactly 16 rising SCLK edges;
- CSB release;
- Mode-0 SCLK idle-low behavior;
- MISO release after deselection.

---

## 5. SDF Back-Annotation

The SDF is applied directly to the routed DUT instance:

```systemverilog
initial begin
    $sdf_annotate(
        "../syn/outputs/spi_slave_core_postroute.sdf",
        u_slave,
        ,
        "sdf_annotate.log",
        "MAXIMUM"
    );
end
```

Xcelium reports:

```text
Backannotation scope: spi_slave_16bit_postroute_tb.u_slave
MTM control:          MAXIMUM
Time units:           1ns
```

This confirms that the SDF was loaded and targeted at the post-route SPI Slave instance.

---

## 6. 100 MHz Gate-Level Baseline Without SDF

Before enabling SDF back-annotation, the same routed gate-level netlist was simulated at a true 100 MHz SPI SCLK.

The simulation passed all directed functional checks.

Representative output:

```text
PASS: Slave selected correctly
PASS: MISO OE enabled
PASS: Slave received a5a5
PASS: Master received 3c3c
PASS: rx_valid asserted after 16 bits
PASS: CSB released
PASS: SCLK idle low
PASS: MISO released
```

Result:

```text
100 MHz post-route gate-level functional simulation without SDF: PASS
```

This separates basic gate-level functional correctness from delay back-annotation effects.

---

## 7. Initial SDF Simulation

The first SDF simulation successfully completed all functional checks at 100 MHz.

However, the annotation log initially reported:

```text
SDF annotation errors   : 0
SDF annotation warnings : 28
```

Warning classification:

```text
24 × SDFNET
 4 × SDFNEP
```

The 24 `SDFNET` warnings were all associated with asynchronous recovery/removal timing checks on TSMC flip-flops.

The four `SDFNEP` warnings were associated with one `XOR2D1` instance.

---

## 8. Recovery / Removal Timing Model Investigation

The Innovus SDF contains combined recovery/removal checks in the form:

```text
RECREM (posedge CDN) (posedge CP)
```

Inspection of the TSMC flip-flop Verilog timing model showed conditional compilation:

```verilog
`ifdef NTC
    `ifdef RECREM
        $setuphold (...);
        $setuphold (...);
        $recrem (posedge CDN, posedge CP, ...);
    `else
        $setuphold (...);
        $setuphold (...);
        $recovery (posedge CDN, posedge CP, ...);
        $hold (posedge CP, posedge CDN, ...);
    `endif
`else
    $setuphold (...);
    $setuphold (...);
    $recovery (posedge CDN, posedge CP, ...);
    $hold (posedge CP, posedge CDN, ...);
`endif
```

Without the appropriate compile definitions, Xcelium therefore instantiated a timing-check representation that did not match the `RECREM` entries produced by Innovus.

The Xcelium command was updated to enable:

```text
+define+NTC+RECREM
```

After enabling these model definitions:

```text
SDF annotation errors   : 0
SDF annotation warnings : 4
```

All 24 asynchronous `RECREM` mismatch warnings disappeared.

This confirms that the TSMC timing model must be compiled with `NTC` and `RECREM` enabled for this Innovus SDF representation.

---

## 9. Residual XOR2D1 SDF Warnings

Four warnings remain:

```text
4 × SDFNEP
```

All four refer to the same routed cell:

```text
spi_slave_16bit_postroute_tb.u_slave.g1298__5122
```

Cell type:

```text
XOR2D1
```

The Innovus SDF contains both edge-specific and conditional timing paths.

Example:

```text
IOPATH (posedge A1) Z
IOPATH (negedge A1) Z

COND A2==1'b1 (IOPATH A1 Z ...)
COND A2==1'b0 (IOPATH A1 Z ...)

IOPATH (posedge A2) Z
IOPATH (negedge A2) Z

COND A1==1'b1 (IOPATH A2 Z ...)
COND A1==1'b0 (IOPATH A2 Z ...)
```

Representative delays are approximately:

```text
0.23 ns to 0.37 ns
```

The TSMC Verilog model defines the XOR timing paths conditionally:

```verilog
if (A2 == 1'b0)
    (A1 => Z) = (0, 0);

if (A2 == 1'b1)
    (A1 => Z) = (0, 0);

if (A1 == 1'b0)
    (A2 => Z) = (0, 0);

if (A1 == 1'b1)
    (A2 => Z) = (0, 0);
```

It does not define separate:

```text
posedge A1 -> Z
negedge A1 -> Z
posedge A2 -> Z
negedge A2 -> Z
```

paths.

Therefore Xcelium cannot match the four additional edge-specific SDF entries and reports `SDFNEP`.

The corresponding conditional timing paths are present in both the SDF and the TSMC Verilog model.

No modification was made to the TSMC PDK, the standard-cell model, or the Innovus SDF to suppress these warnings.

---

## 10. Final Xcelium Command

The validated SDF simulation command is:

```tcsh
xrun -64bit -sv -access +rwc \
+define+NTC+RECREM \
-v /dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/verilog/tcb018bcdgp2a_110a/tcb018bcdgp2a.v \
../rtl/spi_master.sv \
../syn/outputs/spi_slave_core_postroute.v \
spi_slave_16bit_postroute_tb.sv \
-top spi_slave_16bit_postroute_tb
```

The important timing-model options are:

```text
+define+NTC+RECREM
```

These options must be retained when repeating this SDF simulation with the same TSMC standard-cell model.

---

## 11. Final Functional Result

The final SDF-annotated 100 MHz run reports:

```text
PASS: Slave selected correctly
PASS: MISO OE enabled
PASS: Slave received a5a5
PASS: Master received 3c3c
PASS: rx_valid asserted after 16 bits
PASS: CSB released
PASS: SCLK idle low
PASS: MISO released
==================================================
16-bit SPI Slave verification completed.
==================================================
```

Final simulation time:

```text
268500 ps
```

Final annotation status:

```text
Errors   : 0
Warnings : 4 × SDFNEP
```

The four residual warnings are limited to redundant edge-specific `XOR2D1` IOPATH entries whose corresponding conditional timing paths are represented by the TSMC cell model.

---

## 12. Milestone Conclusion

The routed SPI Slave core has successfully completed a 100 MHz SCLK post-route gate-level simulation with Innovus SDF delay back-annotation.

Confirmed results:

```text
Post-route gate-level simulation without SDF @ 100 MHz : PASS
Post-route SDF simulation @ 100 MHz                     : PASS
SDF loaded onto routed DUT                              : CONFIRMED
SDF annotation errors                                   : 0
RECREM timing-model mismatch                            : RESOLVED
Residual warnings                                       : 4 × XOR2D1 SDFNEP
TSMC PDK / cell model modified                          : NO
```

This milestone establishes the routed digital core as functionally valid under the current post-route SDF timing model.

It does **not** establish final silicon timing closure or foundry physical signoff.

---

## 13. Next Stage

The next stage is core-only physical verification and extraction:

```text
Routed core
   ↓
GDS export
   ↓
Virtuoso / foundry-rule DRC
   ↓
LVS
   ↓
PEX / RCC extraction
   ↓
extracted post-layout verification
```

The core will be verified through this flow before IO PAD integration, allowing later failures to be localized between the digital core and the outer PAD/top-level implementation.
