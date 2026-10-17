# Milestone 7B — Core Physical-Verification Preparation and Final Innovus Timing Check

**Date:** 2026-10-17
**Project:** 16-bit SPI Slave ASIC
**Process:** TSMC 180-nm HV BCD Gen2
**Tool:** Cadence Innovus 21.13-s100_1
**Scope:** Core layout preparation, RC extraction, and post-route timing checks before foundry physical verification

## 1. Objective

This milestone records the preparation of the routed SPI Slave core for subsequent GDS export and foundry DRC/LVS/PEX.

It follows Milestone 7A, which demonstrated a 100 MHz core-only post-route SDF simulation using the earlier routed implementation.

The final product requirement is an SPI SCLK frequency greater than 10 MHz after PAD integration and external loading. The 375 MHz constraint used here is a core timing stress-test baseline, rather than the final die operating requirement.

This milestone does not establish foundry physical signoff or complete timing closure.

## 2. Physical Preparation Recorded During the Session

The Innovus preparation session recorded the following work:

- insertion of 151 filler instances;
- manual routing repair associated with `rx_shift_reg[8]`;
- temporary extension of the die bottom boundary to -2 um;
- preparation of the M1–M4 power/ground network;
- M4 VDD/VSS stripes and 54 PG vias;
- creation and routing of 38 M3 signal physical pins;
- regular and special connectivity checks reporting zero violations;
- creation of VDD/VSS PG pins using `createPGPin`;
- preparation of a PG-connected, no-filler netlist candidate for LVS reference.

These are session records of Innovus preparation work. They do not substitute for foundry DRC, LVS, or extracted-layout verification.

The temporary boundary change, filler treatment, PG pin representation, and reference-netlist suitability must be checked during the export and physical-verification flow.

A successful Innovus connectivity check does not establish LVS equivalence.

## 3. Process and RC Configuration

The Innovus process setting was corrected from 90 nm to 180 nm before the final RC extraction.

The configuration recorded for this check was:

| Item | Setting |
| --- | --- |
| Process mode | 180 nm |
| Routing layer limit | METAL1–METAL4 |
| Analysis view | VIEW_TT |
| Constraint mode | CONSTRAINT_SPI |
| Delay corner | DELAY_TT |
| RC corner | RC_TT |
| Capacitance table | t018lo_1p6m_typical.captable |
| Extraction engine | postRoute |
| Extraction effort | low |
| Post-route resistance scale | 1 |
| Post-route capacitance scale | 1 |
| Post-route coupling capacitance scale | 1 |

Correcting the process setting and completing extraction do not independently validate the full technology setup. Foundry-rule physical verification remains pending.

## 4. Timing Constraints and Clock Propagation

The source core SDC is:

```text
syn/results/ideal_core_tt_16bit/spi_slave_375MHz.sdc
```

Its relevant constraints include:

```tcl
create_clock -name "SCLK" -period 2.667 \
    -waveform {0.0 1.3335} [get_ports sclk]

set_input_delay -clock [get_clocks SCLK] \
    -add_delay 0.0 [get_ports mosi]

set_output_delay -clock [get_clocks SCLK] \
    -add_delay 0.0 [get_ports miso]
```

`report_clocks` confirmed an SCLK period of 2.667 ns in VIEW_TT.

Although the analysis-view report displayed `/dev/null` as the SDC file path, the clock object existed in the restored database. The displayed file path alone therefore did not demonstrate that the clock constraint was missing.

Initially, SCLK was reported as ideal:

```text
Propagated = n
```

The first attempt to set clock propagation failed with:

```text
TCLCMD-1048:
constraints are specified but no constraint mode is enabled interactively
```

The constraint mode was then enabled and SCLK propagation applied:

```tcl
set_interactive_constraint_modes [list CONSTRAINT_SPI]
set_propagated_clock [get_clocks SCLK]
report_clocks
```

The resulting clock report confirmed:

```text
Clock       SCLK
Source      sclk
View        VIEW_TT
Period      2.667 ns
Propagated  y
```

The subsequent timing checks used the propagated clock.

## 5. Final RC Extraction

The current core layout was extracted using:

```tcl
extractRC
```

The extraction log reported:

```text
RC corner:                      RC_TT
RC mode:                        PostRoute
Effort level:                   low
Extracted resistors:            1695
Extracted ground capacitors:    1727
Extracted coupling capacitors:  2420
Status:                         RC Extraction DONE
```

Extraction completed before clock propagation was enabled. Enabling clock propagation changes the timing analysis treatment of the clock network; it does not itself require physical RC extraction to be repeated.

This Innovus extraction is distinct from the subsequent foundry PEX/RCC flow.

## 6. Post-Route Setup Analysis

The setup analysis was run using:

```tcl
file mkdir reports/final_sta

timeDesign -postRoute \
    -pathreports \
    -slackReports \
    -numPaths 20 \
    -outDir reports/final_sta \
    -prefix core_375mhz_final
```

Setup view:

```text
VIEW_TT
```

Results:

| Setup metric | All | reg2reg | default |
| --- | ---: | ---: | ---: |
| WNS (ns) | -0.444 | +0.534 | -0.444 |
| TNS (ns) | -0.444 | 0.000 | -0.444 |
| Violating paths | 1 | 0 | 1 |

The setup summary also reported zero violations for:

- maximum capacitance;
- maximum transition;
- maximum fanout;
- maximum length.

All reported reg2reg setup checks passed under this view and constraint set. Overall setup did not pass because one violation remained in the default group.

The default-group classification alone does not identify the failing path or its cause. Detailed path inspection remains necessary.

## 7. Post-Route Hold Analysis

The hold analysis was run using:

```tcl
timeDesign -postRoute \
    -hold \
    -pathreports \
    -slackReports \
    -numPaths 20 \
    -outDir reports/final_sta \
    -prefix core_final_hold
```

Hold view:

```text
VIEW_TT
```

Results:

| Hold metric | All | reg2reg | default |
| --- | ---: | ---: | ---: |
| WNS (ns) | -0.726 | +0.668 | -0.726 |
| TNS (ns) | -14.568 | 0.000 | -14.568 |
| Violating paths | 22 | 0 | 22 |

All reported reg2reg hold checks passed under this view and constraint set. Overall hold did not pass because 22 violations remained in the default group.

Their startpoints, endpoints, clock relationships, and applied constraints have not yet been established from detailed path reports in this milestone.

Reducing the target operating frequency does not generally resolve same-edge hold violations. These violations must be investigated rather than dismissed on the basis of the final >10 MHz requirement.

## 8. Reports and Evidence

The reports were generated under:

```text
innovus/reports/final_sta/
```

Setup report filenames observed during the session include:

```text
core_375mhz_final_all.tarpt.gz
core_375mhz_final_default.tarpt.gz
core_375mhz_final_reg2reg.tarpt.gz
core_375mhz_final.SI_Glitches.rpt.gz
core_375mhz_final.slk
core_375mhz_final.summary.gz
```

The hold reports use the prefix:

```text
core_final_hold
```

Compressed reports must be opened with tools such as `zcat` or `zgrep`. Ordinary recursive `grep` does not decompress their contents.

This document records the terminal summaries and session observations. Its presence in Git does not imply that the Innovus database, extracted parasitics, or all raw reports have also been archived in Git.

## 9. Interpretation and Limitations

The supported timing conclusion is:

> In VIEW_TT, with a 2.667 ns propagated SCLK and the current extracted core layout, reported reg2reg setup and hold checks passed. Overall setup and hold still contained default-group violations.

The current core SDC explicitly supplies IO delays for MOSI and MISO, but does not provide a complete external timing model for all core interfaces.

Consequently:

- the results do not establish complete core IO timing closure;
- default-group violations cannot yet be classified as harmless constraint artifacts;
- the results do not establish final PAD-level timing;
- the results do not establish timing closure across all required PVT/RC corners;
- the current core STA does not independently demonstrate the final loaded die's maximum operating frequency;
- the Milestone 7A simulation applies to its recorded implementation and timing data; it is not automatically a simulation of the modified Milestone 7B layout.

PAD delay, external load, clock duty cycle, board timing, input arrival assumptions, output requirements, and asynchronous control behavior must be considered in the final interface verification.

## 10. Milestone Status and Next Steps

Milestone 7B records completion of the current Innovus preparation and timing-check session, with open timing and physical-verification items explicitly retained.

| Item | Status |
| --- | --- |
| Core physical preparation | Recorded in the session |
| Final Innovus RC extraction | Completed |
| SCLK propagated-clock setting | Confirmed |
| TT reg2reg setup | No reported violations |
| TT reg2reg hold | No reported violations |
| Overall setup | 1 default-group violation |
| Overall hold | 22 default-group violations |
| Foundry DRC | Pending |
| LVS | Pending |
| Foundry PEX/RCC | Pending |
| Verification of the modified extracted layout | Pending |
| Final PAD/load verification above 10 MHz | Pending |

Next steps:

1. Preserve the current core database and associated reports.
2. Inspect the remaining default-group setup and hold paths.
3. Prepare GDS export and validate the export configuration.
4. Run foundry-rule DRC and LVS with a suitable reference netlist.
5. Perform PEX/RCC and verify the extracted implementation.
6. Integrate the PAD/top-level implementation.
7. Verify operation above 10 MHz with defined external loading and complete interface constraints.
## 11. Archived Milestone 7B Evidence

After the setup and hold analyses, Innovus checks were repeated in the same active design session on 2026-10-17 at 19:25:

| Check | Archived report | Result |
| --- | --- | --- |
| Innovus DRC | `innovus/reports/m7b_sta_state_drc.rpt` | 0 violations |
| Regular connectivity | `innovus/reports/m7b_sta_state_regular_connectivity.rpt` | No problems or warnings |
| Special connectivity, including PG pins | `innovus/reports/m7b_sta_state_special_connectivity.rpt` | No problems or warnings |

The setup and hold path reports, slack files, and summaries are archived under `innovus/reports/final_sta/`. The `innovus/mmmc_tt_375mhz_m7b.tcl` file preserves the MMMC configuration used for this 375 MHz analysis. These checks do not replace foundry DRC/LVS or resolve the default-group timing violations.

The final Innovus checkpoint and two selected intermediate checkpoints were backed up separately from Git. Each `.enc` entry must be retained together with its matching `.enc.dat` directory for restoration. The backup archives contain links to the site PDK and tool installation, so restoration requires access to the corresponding environment.
