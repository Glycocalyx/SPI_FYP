# SPI Slave ASIC — Active Checkpoint Registry

**Last Updated:** 2026-11-11  
**Project:** SPI Slave ASIC  
**Technology:** TSMC 180nm HV BCD Gen2  
**Tool:** Cadence Innovus 21.13

## 1. Purpose

This document is the authoritative index of Innovus design checkpoints.

Its purpose is to identify:

- The latest verified physical-design checkpoint.
- The most complete known checkpoint.
- The checkpoint used to generate the current GDS.
- Older and unverified candidate checkpoints.
- The associated verification reports and artifacts.

Do not select a checkpoint based only on its filename.

Every new checkpoint must be recorded here, together with its verification evidence.

## 2. Current Authoritative Baseline

### Status: LATEST DOCUMENTED AND VERIFIED GDS SOURCE

**Checkpoint:**

`innovus/db/m7b_restore_check/core_final_rc_propagated_clock.enc.dat`

Companion file:

`innovus/db/m7b_restore_check/core_final_rc_propagated_clock.enc`

Top cell:

`spi_slave`

Recorded instance count:

`256`

This checkpoint was explicitly used as the source design in Milestone 7C.

It is the current reference baseline for the ongoing core-only DRC investigation.

**Restoration confirmed on 2026-11-11.**

Restore command (execute inside Innovus Tcl Console):

```tcl
restoreDesign /staff/ee/yliumb/spi-fyp/innovus/db/m7b_restore_check/core_final_rc_propagated_clock.enc.dat spi_slave
```

### 2.1 Verified Physical-Design History

Milestone 7B (2026-10-17) records:

- 151 filler instances.
- Manual routing repair around `rx_shift_reg[8]`.
- Temporary die-bottom boundary extension to -2 um.
- M1-M4 power/ground network preparation.
- M4 VDD/VSS stripes.
- 54 PG vias.
- 38 M3 signal physical pins.
- VDD/VSS PG pins created using `createPGPin`.
- Regular connectivity check: zero violations.
- Special connectivity check: zero violations.
- Innovus DRC check: zero violations.

These are recorded Innovus checks, not foundry signoff results.

### 2.2 Milestone 7C Downstream Validation

The same checkpoint was used to generate:

`innovus/reports/m7b_streamout_probe_20261020/spi_slave_core_merged_1000dbu_test.gds`

Recorded properties:

| Item | Result |
|---|---:|
| Top cell | spi_slave |
| Instances | 256 |
| Distinct standard-cell masters | 42 |
| Regular vias | 682 |
| Special vias | 54 |
| Total vias | 736 |
| Signal pin positions | 38 |
| VDD label occurrences | 2 |
| VSS label occurrences | 2 |
| GDS resolution | 1000 DBU/um |

The GDS was successfully imported into Virtuoso.

Important: VDD/VSS labels establish exported power-net labels, not independent proof of substrate electrical connectivity.

The GDS is an experimental core-only verification candidate, not a frozen tape-out GDS.

## 3. Other Existing Checkpoint Candidates

These files exist on the server but have not yet been compared sufficiently to establish their relationship with the authoritative baseline.

### Candidate A

`innovus/db/core_postroute_filler_manualfix_clean.enc`

Companion:

`innovus/db/core_postroute_filler_manualfix_clean.enc.dat`

Status: EXISTS, VERSION RELATIONSHIP UNVERIFIED.

Do not assume this is newer or more complete than the M7B checkpoint solely from its filename.

### Candidate B

`innovus/db/core_final_rc_propagated_clock.enc`

Status: EXISTS, but its matching session directory and relationship to the M7B restore copy have not been established.

### Historical Backup

`/staff/ee/yliumb/spi-fyp-backups/core_final_rc_propagated_clock_20261017_1835.tar.gz`

Status: ARCHIVED BACKUP.

Do not overwrite or delete any of these candidates until their contents and provenance have been compared.

## 4. Current GDS and DRC Baseline

### GDS

`innovus/reports/m7b_streamout_probe_20261020/spi_slave_core_merged_1000dbu_test.gds`

Properties:

- Core-only SPI Slave.
- 1000 DBU/um.
- Merged with the TSMC standard-cell GDS.
- Source checkpoint: M7B restore checkpoint.

### Calibre DRC

Working directory:

`virtuoso_import_hvbcd_20261029/drc_run_core_20261108`

Local deck:

`virtuoso_import_hvbcd_20261029/calibre_spi_slave_core.drc`

The initial DRC run completed, but the design has not passed final foundry DRC.

LVS and PEX remain pending.

Do not freeze the GDS until DRC issues have been resolved.

## 5. Version Selection Rules

For future checkpoint updates:

1. Never overwrite the previous verified checkpoint.
2. Save each new checkpoint under a distinct versioned directory.
3. Preserve both `.enc` and its matching `.enc.dat` directory.
4. Record the date, time, tool version and source design.
5. Record instance count and standard-cell master count.
6. Record PG network status, VDD/VSS connectivity and PG via counts.
7. Record regular and special connectivity results.
8. Record whether fillers, routing, RC extraction and clock propagation are included.
9. Record the corresponding GDS and verification reports.
10. Only promote a checkpoint to the authoritative baseline after comparing it with the previous baseline and confirming its required functionality.

### Status Definitions

- **LATEST VERIFIED:** Most recent checkpoint with sufficient verification evidence.
- **MOST COMPLETE:** Checkpoint containing the most complete required physical-design work.
- **ACTIVE BASELINE:** Checkpoint currently used for ongoing DRC/LVS work.
- **CANDIDATE:** Existing checkpoint awaiting comparison.
- **SUPERSEDED:** Previously authoritative checkpoint replaced by a newer verified version.

These statuses must not be treated as interchangeable.

## 6. Current Status — 2026-11-11

| Item | Status |
|---|---|
| M7B restore checkpoint | Restored successfully |
| M7B PG preparation | Previously verified |
| M7C GDS export | Completed |
| Virtuoso Stream-In | Completed |
| Core-only Calibre DRC | In progress |
| BND provenance | Identified |
| Final GDS freeze | Pending |
| Schematic generation | Deferred |
| LVS | Pending |
| PEX | Pending |
| Substrate-to-ground electrical proof | Pending |

**Current working decision:**

Use `m7b_restore_check/core_final_rc_propagated_clock.enc.dat` as the reference baseline for the ongoing DRC investigation.

Do not declare it the absolute newest server checkpoint until the other existing candidates have been compared.

## 7. Documentation Policy

Whenever a significant physical-design task is completed:

- Update the relevant milestone document.
- Update this checkpoint registry if the active design state changes.
- Preserve the previous checkpoint.
- Record the exact commands and resulting evidence.
- Clearly distinguish confirmed results from hypotheses and pending checks.

GitHub is the persistent project history.

The checkpoint registry is the single reference for identifying which Innovus database should be restored for continued work.
