
# Milestone 7D — Foundry DRC and LVS Preparation

**Date:** 2026-11-08
**Project:** 16-bit SPI Slave ASIC
**Process:** TSMC 180nm HV BCD Gen2_1_7p2a1
**Process Metal Option:** 1P6M / 6LM
**Tools:** Cadence Innovus 21.13 / Virtuoso IC6.1.8 / Calibre v2022.1_36.16
**Status:** IN PROGRESS — Initial core DRC completed; investigation ongoing.

---

## 1. Objective and Scope

Milestone 7D follows the core GDS export and Virtuoso import validation
documented in Milestone 7C.

The objectives are:

1. Run TSMC foundry DRC on the exported SPI Slave core GDS.
2. Investigate runtime warnings and reported DRC results.
3. Verify GDS layer mapping against the TSMC PDK.
4. Investigate standard-cell obstruction geometry and boundary purposes.
5. Confirm substrate connectivity and appropriate DRC configuration.
6. Prepare for LVS using a suitable reference netlist.

The current design uses a 6LM process option, but signal routing is
intentionally restricted to METAL1–METAL4, as required by the professor.

This does NOT mean the process itself is a 4LM process.

The current verification scope is core-only. It is not final die-level
DRC, LVS, PEX or tape-out signoff.

## 2. Input Design and Environment

### 2.1 Main GDS

Top cell:

`spi_slave`

Current GDS:

`~/spi-fyp/innovus/reports/m7b_streamout_probe_20261020/spi_slave_core_merged_1000dbu_test.gds`

GDS database resolution: 1000 DBU/um.

The GDS contains the SPI Slave core merged with the TSMC standard-cell
reference GDS.

### 2.2 PDK

PDK root:

`/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1`

Standard-cell library:

`tcb018bcdgp2a`

6LM LEF:

`$PDKROOT/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/lef/tcb018bcdgp2a_110a/lef/tcb018bcdgp2a_6lm.lef`

Virtuoso layer map:

`$PDKROOT/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/lef/tcb018bcdgp2a_110a/techfiles/Virtuoso/virtuoso_018um_v28a.map`

### 2.3 Calibre Rule Deck

Calibre directory:

`/usr/eelocal/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/PDK/Cadence_OA/HRIRES3K_1V8_5V_GAGB_1fF_1P6M_4KMiM30K_20260222/Calibre`

DRC deck:

`$CALDIR/drc/calibre.drc`

README:

`$CALDIR/drc/README_DRC`

The inspected rule deck identifies itself as:

`CHV18S_AL_..._6M.114_1a_pre082925`

Its header describes the TSMC 0.18um CMOS HV mixed-signal
Generation II BCD 1P6M process.

## 3. Core DRC Setup

### 3.1 Working Directory

`~/spi-fyp/virtuoso_import_hvbcd_20261029`

DRC run directory:

`~/spi-fyp/virtuoso_import_hvbcd_20261029/drc_run_core_20261108`

Local rule deck copy:

`~/spi-fyp/virtuoso_import_hvbcd_20261029/calibre_spi_slave_core.drc`

The original PDK rule deck was copied locally before modification.
The original PDK file was not modified.

### 3.2 Local Rule Deck Configuration

The local deck was configured for the core-only GDS:

- GDS input points to `spi_slave_core_merged_1000dbu_test.gds`.
- Layout primary cell is `spi_slave`.
- `FULL_CHIP` was disabled for the core-only run.
- The active process configuration includes 5V, 1.8V, MIX_MODE
  and THICK_30K.
- GUIDELINE_LUP and GUIDELINE_ESD were enabled.
- PARASITIC_ESD was enabled.
- WARNING_HVLUP was enabled.
- SubToGround remained disabled/commented.

Important: The SubToGround setting has NOT been validated against
the actual physical substrate connection.

The local configuration is provisional and must not be treated as
a confirmed foundry signoff configuration.

### 3.3 Important Configuration Decision

The process option is 6LM, but the design uses only METAL1–METAL4
for signal routing.

The Innovus StreamOut map contains:

- METAL1: 16/0
- METAL2: 18/0
- METAL3: 28/0
- METAL4: 31/0
- VIA12: 17/0
- VIA23: 27/0
- VIA34: 29/0

METAL5 and METAL6 are not used for the current signal routing.

Do not change the process option to 4LM merely because the design
is restricted to four routing layers.

## 4. Initial DRC Run

### 4.1 Execution Information

Calibre version:

`v2022.1_36.16`

Layout system: GDS

Primary cell: `spi_slave`

Input GDS:

`spi_slave_core_merged_1000dbu_test.gds`

The initial DRC run completed and generated:

- `spi_slave.drc.summary`
- `spi_slave.drc.results`

The run produced a summary report and runtime warnings.

This establishes that the deck executed, not that the design passed DRC.

### 4.2 Selected Rule Result Counts

The initial summary contained:

| Rule | Reported Result Count |
|---|---:|
| NBL.R.1 | 219 (1279) |
| M2.R.1 | 1 |
| M3.R.1 | 1 |
| M4.R.1 | 1 |
| M5.R.1 | 1 |
| UTM30K.R.1 | 1 |
| DRM.R.1 | 1 |

These results have not yet been individually classified or resolved.

The NBL.R.1 result requires particular attention because its
interpretation depends on the substrate isolation configuration.

The counts above are observations from the initial run, not
confirmed final violation counts or signoff conclusions.

### 4.3 Runtime Warnings

The initial DRC summary reported:

**Connectivity configuration warning**

`DISCONNECT operations are present without DRC INCREMENTAL CONNECT YES specified.`

**Unmapped GDS layer/datatype warnings**

- 3/1
- 4/1
- 13/1
- 13/4
- 16/1
- 16/2
- 18/1
- 18/2
- 28/1
- 28/2
- 31/1
- 31/2
- 56/1

**Other warnings**

- PROJECTING constraint only supported with PARALLEL ONLY.
- Calibre automatically set PARALLEL ONLY.
- Missing connections STAMPing layer LV_SD by PSD_mf.
- Missing connections STAMPing layer LV_SD by NSD_mf.

These are runtime warnings and must be distinguished from
the actual DRC rule result counts.

No 151/0 unmapped-layer warning appeared in the supplied warning list.

## 5. Investigation: GDS Layer Mapping

### 5.1 TSMC Virtuoso Layer Map

Inspected file:

`virtuoso_018um_v28a.map`

The following mappings were found:

| GDS Layer/Datatype | Virtuoso Layer/Purpose |
|---|---|
| 3/1 | DIFF/dummy |
| 13/1 | POLY1/dummy |
| 16/1 | METAL1/dummy |
| 18/1 | METAL2/dummy |
| 28/1 | METAL3/dummy |
| 31/1 | METAL4/dummy |
| 16/2 | METAL1/slot |
| 18/2 | METAL2/slot |
| 28/2 | METAL3/slot |
| 31/2 | METAL4/slot |
| 3/2 | DIFF/boundary |
| 3/4 | DIFF/net |
| 13/2 | POLY1/boundary |

The following pairs were not found in the inspected mapping:

- 4/1
- 13/4
- 56/1

Their origins remain unidentified.

### 5.2 Preliminary Interpretation

Most of the identified unmapped objects correspond to auxiliary
PDK purposes, particularly dummy and slot geometries.

However, the existence of a Virtuoso mapping does not guarantee
that Calibre recognizes the same GDS layer/datatype.

Virtuoso Stream-In/Out mapping and Calibre DRC layer definitions
are separate configurations.

The actual Calibre treatment of dummy and slot geometry must
be investigated independently.

### 5.3 Pending Investigation

1. Identify the source of 4/1, 13/4 and 56/1.
2. Inspect Calibre internal layer definitions.
3. Determine whether dummy and slot datatypes are intentionally
   excluded or require explicit mapping.
4. Compare GDS geometry counts against Calibre internal layers.
5. Verify that all manufacturing-relevant geometry is checked.

No GDS layers have been deleted or remapped as part of this investigation.

## 6. Investigation: METAL1 Boundary / BND

### 6.1 Initial Problem

During Virtuoso inspection of the imported GDS, additional
`METAL1 bnd` geometry was observed.

Initially, this appeared to be invalid Metal1 geometry overlapping
normal Metal1 shapes.

The concern was whether the Innovus StreamOut map had incorrectly
converted normal Metal1 into an invalid boundary layer.

### 6.2 TSMC Layer Map Evidence

The original TSMC Virtuoso map contains:

`METAL1 boundary 151 0`

It also defines:

- METAL2/boundary: 152/0
- METAL3/boundary: 153/0
- METAL4/boundary: 154/0
- METAL5/boundary: 155/0
- METAL6/boundary: 156/0

These are explicitly defined boundary purposes.

### 6.3 LEF OBS Evidence

The inspected CKBD16 macro in the 4LM LEF contains:

`OBS`

`LAYER METAL1 ;`

followed by multiple RECT definitions.

These represent Metal1 routing obstruction regions.

The LEF rectangles were compared against the GDS 151/0 polygons.

The bounding boxes correspond after converting LEF coordinates
from micrometers to GDS coordinates using 1000 DBU/um.

Examples:

| GDS 151/0 Bounding Box | Corresponding LEF Coordinate Range |
|---|---|
| 16050,1240,23285,2140 | 16.050,1.240,23.285,2.140 |
| 6985,2900,14190,4620 | 6.985,2.900,14.190,4.620 |
| 6985,1240,14190,2140 | 6.985,1.240,14.190,2.140 |
| 16050,2900,23340,4620 | 16.050,2.900,23.340,4.620 |

The comparison confirms that the inspected CKBD16 boundary
geometry corresponds to its LEF Metal1 OBS geometry.

The 6LM LEF should also be cross-checked before treating this
particular comparison as complete for the selected process option.

### 6.4 Source GDS vs Merged GDS Comparison

The Python script:

`check_metal1_boundary.py`

compared GDS 151/0 polygon XY records between the vendor
standard-cell GDS and the merged core GDS.

Recorded result:

| Cell | Source | Merged | Result |
|---|---:|---:|---|
| CKBD16 | 4 | 4 | MATCH |
| DFCND4 | 8 | 8 | MATCH |
| DFCNQD4 | 4 | 4 | MATCH |
| INVD16 | 4 | 4 | MATCH |
| INVD4 | 4 | 4 | MATCH |
| ND2D4 | 3 | 3 | MATCH |
| NR2D4 | 3 | 3 | MATCH |

Merged total: 30 polygons.

### 6.5 Conclusion

The observed METAL1/boundary geometry is not evidence of
ordinary conductive Metal1 being incorrectly mapped.

For the inspected CKBD16 geometry, it corresponds to standard-cell
routing obstruction information.

It is not an additional conductive Metal1 layer.

Do not delete the BND geometry or alter the original TSMC layer map
merely to remove its appearance in Virtuoso.

Whether boundary geometry should be retained or filtered in the
final manufacturing GDS must be checked against the applicable
foundry StreamOut requirements.

## 7. Investigation: Substrate Grounding

### 7.1 DRC Deck Dependency

The local DRC deck contains:

`//#DEFINE SubToGround`

The NBL.R.1 rule is located under:

`#IFNDEF SubToGround`

Its description states that when the substrate is not tied to ground,
LV devices must satisfy the specified NBL/HVNW/N+ isolation requirements.

Therefore, the current deck configuration evaluates the
not-tied-to-ground branch.

This is a configuration assumption, not proof of the actual
physical substrate connection.

### 7.2 Previous Investigation

The following checks were attempted:

1. Search the 6LM standard-cell LEF for tap/well/substrate macros.
2. Search Innovus Tcl and log files for addWellTap/tapcell commands.
3. Inspect available Innovus database checkpoints.
4. Inspect the layout in Virtuoso to identify substrate contacts.

The inspected LEF search returned FILL and TIE cells but no
obvious TAP/WELL/PTAP/NTAP macro names.

No conclusive evidence of the top-level P-substrate connection
has been obtained.

Virtuoso GUI connectivity inspection remains unresolved.

### 7.3 Pending Actions

1. Determine whether the P-substrate is physically tied to VSS.
2. Identify the relevant substrate contacts and their connectivity.
3. Confirm the appropriate SubToGround configuration with
   the actual physical design and applicable PDK documentation.
4. Rerun DRC after the configuration is verified.

Do not enable SubToGround solely to reduce NBL.R.1 results.

## 8. Important Decisions

1. Keep the selected 6LM process option.
2. Keep signal routing restricted to METAL1–METAL4, following
   the professor's requirement.
3. Do not delete METAL1/boundary geometry.
4. Do not modify the original TSMC PDK mapping.
5. Do not treat runtime warnings as confirmed DRC violations.
6. Do not disable DRC checks merely to obtain a clean report.
7. Do not generate the final reference schematic yet.
8. Defer LVS until the physical GDS and DRC configuration
   are sufficiently stable.

## 9. Current Status and Pending Work

| Item | Status |
|---|---|
| Core GDS export | COMPLETED in Milestone 7C |
| Virtuoso Stream-In | COMPLETED in Milestone 7C |
| Initial Calibre DRC execution | COMPLETED |
| Initial DRC result investigation | IN PROGRESS |
| METAL1 boundary investigation | PARTIALLY CONFIRMED |
| Dummy/slot layer mapping | IN PROGRESS |
| 4/1, 13/4, 56/1 identification | PENDING |
| Calibre internal layer mapping | PENDING |
| P-substrate grounding confirmation | PENDING |
| NBL.R.1 result investigation | PENDING |
| M2/M3/M4/M5/UTM30K/DRM result investigation | PENDING |
| Final core DRC | PENDING |
| Reference netlist preparation | PENDING |
| LVS | NOT STARTED |
| PEX/RCC | NOT STARTED |
| Final PAD-integrated die verification | NOT STARTED |

## 10. Next Steps

Priority order:

1. Inspect Calibre layer definitions for dummy and slot layers.
2. Investigate the M1DMY/M2DMY/etc. internal geometry counts.
3. Identify GDS 4/1, 13/4 and 56/1.
4. Inspect individual DRC results, especially NBL.R.1.
5. Confirm physical P-substrate grounding.
6. Verify the correct process and rule-deck switches.
7. Resolve genuine DRC violations and rerun the core DRC.
8. Freeze the verified GDS.
9. Prepare the matching reference netlist and schematic strategy.
10. Run LVS.
11. Proceed to PEX/RCC.
12. Perform separate PAD-integrated die-level verification.

## 11. Project Documentation Convention

Every completed subtask or significant debugging investigation
should be recorded in the appropriate milestone document.

Each record should distinguish:

- CONFIRMED: supported by actual command output or other evidence.
- HYPOTHESIS: a possible explanation that remains unverified.
- PENDING: an unresolved task.

Record important commands, file paths, tool versions, outputs,
decisions and reasons for decisions.

Do not wait until an entire milestone is completed to preserve
important debugging information.

The GitHub repository is the persistent project history and
the reference for resuming work across sessions.

## 12. Milestone Conclusion

The initial core DRC execution has been completed.

The investigation has identified several auxiliary GDS datatypes
reported as unmapped and established that the observed CKBD16
METAL1/boundary geometry corresponds to LEF OBS geometry.

However, the Calibre layer mapping, substrate configuration,
and initial DRC results still require investigation.

Milestone 7D remains IN PROGRESS.

No final DRC, LVS, PEX or tape-out signoff is claimed.

EOF




## 2026-11-09: METAL1 Boundary / Blockage Mapping Investigation

### 1. METAL1 Boundary Mapping

Confirmed the following PDK layer mapping in `virtuoso_018um_v28a.map`:

- METAL1 drawing: GDS Layer 16 / Datatype 0.
- METAL1 boundary: GDS Layer 151 / Datatype 0.
- The mapping file explicitly categorizes this section as Blockage layers.

The `boundary` purpose is therefore distinct from normal conductive METAL1 drawing geometry.

### 2. LEF OBS Verification

Inspected the `CKBD16` macro in `tcb018bcdgp2a_4lm.lef`.

Confirmed:
- The macro contains an `OBS` section.
- `OBS` includes multiple `LAYER METAL1` obstruction rectangles.
- These rectangles represent routing obstructions, rather than additional conductive METAL1 nets.

### 3. GDS Boundary Preservation Check

Created and ran `check_metal1_boundary.py` to compare GDS Layer 151/Datatype 0 between the original standard-cell GDS and the merged core GDS.

Results:

| Standard Cell | Boundary Records | Result |
|---|---:|---|
| CKBD16 | 4 | MATCH |
| DFCND4 | 8 | MATCH |
| DFCNQD4 | 4 | MATCH |
| INVD16 | 4 | MATCH |
| INVD4 | 4 | MATCH |
| ND2D4 | 3 | MATCH |
| NR2D4 | 3 | MATCH |
| **Total** | **30** | **MATCH** |

The comparison checks element types and XY coordinate records.

Conclusion: All seven examined standard cells preserve their Layer 151/0 boundary records in the merged GDS.

This confirms geometry preservation for the examined cells, but does not independently establish complete layer correctness or DRC correctness.

### 4. Virtuoso Stream-In Findings

Used the following layer map:

`$PDKROOT/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/lef/tcb018bcdgp2a_110a/techfiles/Virtuoso/virtuoso_018um_v28a.map`

The Stream-In log reports:
- 0 errors.
- 2 warnings.
- XSTRM-75: Target library is attached to a technology library, so the technology file is read-only. Undefined layer-purpose pairs will be dropped.
- XSTRM-163: No `viaMap` option was supplied.

Important: Zero Stream-In errors does not guarantee that every GDS layer-purpose pair was successfully imported.

### 5. Calibre Layer-Mapping Warnings

The Calibre output contains warnings about unmapped GDS layers/datatype pairs, including:

- 3/1, 4/1
- 13/1, 13/4
- 16/1, 16/2
- 18/1, 18/2
- 28/1, 28/2
- 31/1, 31/2
- 56/1, 56/2

A separate inspection of the Cadence Stream-In map confirmed the following entries:

| Layer Purpose | GDS Layer/Datatype |
|---|---|
| DIFF dummy | 3/1 |
| POLY1 dummy | 13/1 |
| METAL1 dummy | 16/1 |
| METAL1 slot | 16/2 |
| METAL2 dummy | 18/1 |
| METAL2 slot | 18/2 |
| METAL3 dummy | 28/1 |
| METAL3 slot | 28/2 |
| METAL4 dummy | 31/1 |
| METAL4 slot | 31/2 |

Important distinction: The Cadence Stream-In map is not necessarily the layer map used by Calibre. These findings do not yet establish the cause of Calibre's unmapped-layer warnings.

Other Calibre messages requiring further investigation:

- DISCONNECT operations without `DRC INCREMENTAL CONNECT YES`.
- PROJECTING constraints automatically changed to PARALLEL ONLY.
- Missing connections when stamping LV_SD by PSD_mf and NSD_mf.

These messages have not yet been classified as harmless warnings or actual verification problems.

### 6. Current Status and Next Steps

**Confirmed:**
- METAL1 boundary is mapped to GDS 151/0 in the inspected PDK map.
- Standard-cell LEF contains METAL1 OBS obstruction geometry.
- All seven examined standard cells preserve their 151/0 geometry in the merged GDS.

**Pending:**
1. Identify the actual layer mapping configuration used by the Calibre DRC run.
2. Investigate all unmapped layer/datatype warnings.
3. Determine whether the remaining Calibre warnings affect DRC results.
4. Analyze and resolve actual DRC violations.
5. Freeze the final GDS only after DRC is resolved.
6. Generate the corresponding schematic and proceed with LVS afterward.

**Current priority: Calibre DRC correctness. LVS and schematic generation are deferred until the physical layout is finalized.**

