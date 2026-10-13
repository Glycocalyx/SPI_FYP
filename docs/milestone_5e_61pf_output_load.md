# Milestone 5E — 61 pF External MISO Load Characterization

## 1. Objective

This milestone evaluates the SPI Slave MISO output path under the updated external load requirement of **61 pF**.

The 61 pF load represents the parasitic capacitance of the oscilloscope probe used during off-chip testing.

The goals of this milestone are to:

1. verify that the selected I/O cell timing library supports a 61 pF output load;
2. evaluate the existing fixed gate-level implementation at **10 MHz** across TT, WC, BC, and LT corners;
3. measure MISO output rise/fall slew under the 61 pF load;
4. characterize the fixed-netlist Fmax at each corner;
5. determine whether the results provide evidence that an additional core-side output buffer is required.

This milestone is a **pre-layout fixed-netlist timing characterization**.

It is not final tapeout signoff.

---

# 2. Design Configuration

Top-level module:

```text
spi_slave_full_io_pad_wrapper
```

Existing fixed gate-level netlist:

```text
syn/outputs/spi_slave_csb_async_110MHz_5pF.v
```

The filename still contains `5pF` because this netlist was generated during the previous 5 pF milestone.

For the present characterization:

- the gate-level implementation is intentionally kept fixed;
- no RTL is re-synthesized;
- no technology remapping is performed;
- no optimization is performed;
- only the STA external MISO load is changed from 5 pF to 61 pF.

This controlled setup isolates the effect of the increased external load.

---

# 3. MISO I/O Cell

The current MISO I/O cell is:

```text
PDDW0208CSG
```

The wrapper currently uses:

```text
PAD_DS = 1
```

The relevant Liberty model shows that `PDDW0208CSG` is not modeled as a passive metal-only pad.

It contains a characterized output timing path:

```text
I -> PAD
```

together with:

```text
OEN
DS
```

control behavior.

Therefore, the external MISO capacitance is driven by the I/O cell output stage rather than directly by the core standard-cell logic.

---

# 4. Liberty Characterization Range

The TT, WC, BC, and LT I/O Liberty files were checked individually.

All four corners use the same output timing table structure:

```text
variable_1 : input_net_transition
index_1    : 0.1000, 0.2000, 0.4000, 0.5000, 1.0000 ns

variable_2 : total_output_net_capacitance
index_2    : 5, 10, 25, 40, 70, 100 pF
```

The Liberty unit is:

```text
capacitive_load_unit (1,pf)
```

Therefore:

```text
40 pF < 61 pF < 70 pF
```

and the requested 61 pF load lies inside the characterized output-load range for all four corners.

The 61 pF condition therefore uses Liberty interpolation rather than output-load extrapolation.

---

# 5. 10 MHz Baseline STA

A fixed-netlist STA was performed at:

```text
SPI frequency = 10 MHz
Clock period  = 100 ns
MISO load     = 61 pF
```

The scripts use the previously established external/internal SCLK timing model.

The external master samples MISO on the external rising SCLK edge, while the slave MISO data path is launched from the internal falling-edge domain after the SCLK input pad.

The baseline script is:

```text
syn/run_61pF_10MHz_baseline.tcl
```

---

# 6. MISO Timing Results at 10 MHz

| Corner | Total Data Path | MISO PAD Delay | Timing Slack |
|---|---:|---:|---:|
| TT | 6.635 ns | 5.154 ns | +42.616 ns |
| WC | 9.977 ns | 7.740 ns | +39.012 ns |
| BC | 5.337 ns | 4.151 ns | +44.024 ns |
| LT | 4.966 ns | 3.865 ns | +44.424 ns |

All four corners meet the 10 MHz timing requirement with large positive slack.

The worst corner is WC:

```text
WC slack = +39.012 ns
```

Therefore, under the current pre-layout timing model, the existing I/O architecture has substantial timing margin relative to the 10 MHz requirement.

---

# 7. MISO Output Slew at 61 pF

The MISO external output net reports give the following rise/fall slew values:

| Corner | Rise Slew | Fall Slew |
|---|---:|---:|
| TT | 6.430 ns | 6.103 ns |
| WC | 9.791 ns | 9.654 ns |
| BC | 5.105 ns | 4.855 ns |
| LT | 4.642 ns | 4.437 ns |

WC gives the slowest output transition:

```text
Rise slew ≈ 9.79 ns
Fall slew ≈ 9.65 ns
```

Even at this corner, the 10 MHz timing requirement is still met with approximately 39 ns positive slack.

---

# 8. Effective MISO Output Load Seen by Genus

The output-net reports show:

| Corner | Reported Total Capacitance |
|---|---:|
| TT | 63.1244 pF |
| WC | 63.3136 pF |
| BC | 62.9780 pF |
| LT | 62.9500 pF |

The explicit external load constraint is:

```text
61 pF
```

Genus is operating in:

```text
Wireload mode: segmented
```

and reports a slightly larger total effective capacitance at the MISO output node.

The difference between 61 pF and the reported approximately 63 pF value should not be interpreted directly as a measured intrinsic PAD capacitance.

The important result is that the intended heavy external load is being included in the timing analysis.

---

# 9. MISO PAD Input Slew

The core-side MISO net driving the I/O cell input gives:

| Corner | Rise Slew | Fall Slew |
|---|---:|---:|
| TT | 0.311 ns | 0.349 ns |
| WC | 0.432 ns | 0.564 ns |
| BC | 0.257 ns | 0.280 ns |
| LT | 0.241 ns | 0.248 ns |

The Liberty input-transition characterization range is:

```text
0.1 ns to 1.0 ns
```

Therefore all observed MISO PAD input slew values are also inside the characterized range.

For the critical I/O timing calculation, both important Liberty dimensions are within the table range:

```text
PAD input slew:
0.24–0.56 ns
→ inside 0.1–1.0 ns

PAD output load:
approximately 63 pF
→ inside 40–70 pF interval
```

Thus the timing results are based on table interpolation in both dimensions rather than extrapolation.

---

# 10. Delay Distribution

The MISO output pad dominates the total MISO timing path.

For example:

```text
TT:
Total data path = 6.635 ns
PAD delay       = 5.154 ns

WC:
Total data path = 9.977 ns
PAD delay       = 7.740 ns
```

Across the four corners, the output PAD contributes approximately the same dominant fraction of the complete MISO path.

The core-side driver itself sees only approximately:

```text
22–24 fF
```

and produces sub-1-ns slew at the `PDDW0208CSG` input.

Therefore, the 61 pF external capacitance is not directly driven by the core standard-cell logic.

The heavy load is primarily driven by the output stage inside the I/O cell.

---

# 11. 61 pF Fixed-Netlist Fmax Characterization

A second script was created to characterize the maximum frequency of the same fixed netlist under the 61 pF MISO load:

```text
syn/run_61pF_fmax.tcl
```

The script accepts:

```text
CORNER
FREQ_MHZ
```

from the shell environment.

No synthesis or optimization is performed during the frequency sweep.

The Fmax boundary is defined by the MISO external timing path:

```text
Slack >= 0  -> MET
Slack < 0   -> VIOLATED
```

---

# 12. TT Fmax

Measured boundary:

```text
67.6 MHz : +12 ps
67.7 MHz :  +1 ps
67.8 MHz :  -9 ps
```

Therefore:

```text
TT Fmax ≈ 67.7 MHz
```

---

# 13. WC Fmax

Measured boundary:

```text
45.5 MHz :  +1 ps
45.6 MHz : -23 ps
```

Therefore:

```text
WC Fmax ≈ 45.5 MHz
```

One 45.4 MHz timing report initially showed an anomalous large positive slack.

Inspection showed that Genus selected the internal rising SCLK edge rather than the intended internal falling launch edge for that reported path.

The anomalous point was therefore excluded from the Fmax boundary determination.

The surrounding valid results and the expected falling-edge timing relationship both support the approximately 45.5 MHz result.

---

# 14. BC Fmax

Measured boundary:

```text
83.6 MHz : +4 ps
83.7 MHz : -3 ps
```

The reported launch edge was checked and correctly corresponded to:

```text
half-period + BC SCLK input PAD falling delay
```

Therefore:

```text
BC Fmax ≈ 83.7 MHz
```

---

# 15. LT Fmax

Measured boundary:

```text
89.6 MHz : +4 ps
89.7 MHz : -2 ps
```

The reported launch edge was also verified to correspond to the intended internal falling SCLK edge.

Therefore:

```text
LT Fmax ≈ 89.7 MHz
```

---

# 16. Final 61 pF Fmax Summary

| Corner | 61 pF Fixed-Netlist Fmax |
|---|---:|
| TT | ~67.7 MHz |
| WC | ~45.5 MHz |
| BC | ~83.7 MHz |
| LT | ~89.7 MHz |

The worst-case frequency limit is therefore:

```text
WC ≈ 45.5 MHz
```

The actual SPI target is:

```text
10 MHz
```

Therefore the pre-layout fixed-netlist WC Fmax remains substantially above the required operating frequency.

---

# 17. Comparison with Previous 5 pF Results

Previous fixed-netlist characterization at 5 pF gave approximately:

| Corner | 5 pF Fmax | 61 pF Fmax |
|---|---:|---:|
| TT | ~110 MHz | ~67.7 MHz |
| WC | ~72.6 MHz | ~45.5 MHz |
| BC | ~137 MHz | ~83.7 MHz |
| LT | ~147 MHz | ~89.7 MHz |

Increasing the external MISO load from 5 pF to 61 pF therefore causes a substantial reduction in high-frequency capability.

Across the corners, the reduction is consistently on the order of roughly 37–39%.

However, the new worst-case Fmax remains well above the required 10 MHz operating point.

---

# 18. Interpretation of the Output Buffer Question

The current evidence does not support the assumption that the core standard-cell logic is directly required to drive the full 61 pF load.

The observed structure is effectively:

```text
core logic
    |
    | approximately 22–24 fF
    v
PDDW0208CSG input
    |
    | internal output-driver path
    v
PDDW0208CSG PAD
    |
    | approximately 61 pF external probe load
    v
off-chip measurement
```

The core-side signal already reaches the I/O cell with a characterized and relatively fast input slew.

The large output delay and slew are generated primarily by the I/O output stage driving the heavy external capacitance.

Therefore, based on the current pre-layout STA results, there is no evidence that an additional ordinary core-side standard-cell buffer is required solely to satisfy the 10 MHz timing specification.

However, this does not prove that an additional buffer or stronger output-driver architecture is unnecessary for the final chip.

The supervisor's previous recommendation may refer to:

- an additional core-side pre-driver;
- a dedicated high-drive output stage;
- a different definition of "PAD";
- extra robustness for real measurement conditions;
- or prior silicon/test-board experience not captured by the present STA model.

The distinction should therefore be clarified before finalizing the chip-level I/O architecture.

---

# 19. Current Engineering Conclusion

The current results support the following conclusion:

> The 61 pF oscilloscope-probe load is a significant heavy-load condition and reduces the pre-layout fixed-netlist Fmax substantially. However, the currently selected `PDDW0208CSG` I/O cell includes a characterized output-driver path and, with `DS=1`, meets the 10 MHz MISO timing requirement at TT, WC, BC, and LT with substantial margin. The present data therefore do not establish that an additional core-side standard-cell buffer is necessary for the 10 MHz specification.

This conclusion is limited to the current Liberty-based pre-layout timing model.

---

# 20. Limitations

The present results do not include:

- final placement;
- clock-tree synthesis;
- routed interconnect parasitics;
- post-route extraction;
- package parasitics;
- PCB parasitics;
- probe behavior beyond the modeled 61 pF capacitance;
- power integrity effects;
- IR drop;
- simultaneous switching noise;
- final tapeout I/O ring implementation;
- silicon process variation beyond the available Liberty corners;
- laboratory measurement uncertainty.

Therefore:

```text
pre-layout STA pass
!=
final silicon guarantee
```

The 61 pF analysis should be repeated or revalidated after the final I/O architecture and post-layout implementation are available.

---

# 21. Impact on Physical-Design Flow

Milestones 6B and 6C were completed using the earlier prototype chip-level wrapper and 5 pF timing assumptions.

The new 61 pF characterization does not invalidate those milestones as flow-development exercises.

However, the final tapeout implementation must eventually be rebuilt using the finalized chip-level I/O architecture.

In particular, the final implementation still requires resolution of:

- complete chip-top interface definition;
- MISO output-driver architecture;
- power and ground pads;
- pad-ring completion;
- corner cells;
- pad fillers;
- core power planning;
- final placement and routing;
- extracted post-layout timing;
- physical verification;
- foundry tapeout requirements.

Therefore the existing Innovus databases remain useful development milestones but should not yet be treated as the final tapeout implementation.

---

# 22. Files Added for This Milestone

Primary scripts:

```text
syn/run_61pF_10MHz_baseline.tcl
syn/run_61pF_fmax.tcl
```

Primary result directory:

```text
syn/results/multicorner_61pF_10MHz_baseline/
```

Fmax result directory:

```text
syn/results/multicorner_61pF_fmax/
```

Milestone documentation:

```text
docs/milestone_5e_61pf_output_load.md
```

---

# 23. Next Step

Before changing the RTL or inserting a new output buffer, clarify with the supervisor whether the previously requested "buffer" refers to:

```text
1. a standard-cell buffer between the core and PDDW0208CSG;
2. a dedicated high-drive output driver;
3. or a previous assumption that the PAD itself was passive.
```

After the intended architecture is confirmed:

1. compare the current no-extra-buffer implementation against the requested buffered implementation if necessary;
2. finalize the chip-level I/O structure;
3. re-synthesize the final design;
4. rebuild the final Innovus implementation from the completed chip top;
5. perform post-layout timing and tapeout-level verification.
