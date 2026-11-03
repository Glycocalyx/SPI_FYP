
# Milestone 7C — Core GDS Export and Virtuoso Stream-In Validation

**Date:** 2026-11-03
**Project:** 16-bit SPI Slave ASIC
**Process:** TSMC 180nm HV BCD Gen2_1_7p2a1
**Tools:** Innovus 21.13 / Virtuoso IC6.1.8
**Scope:** Core-only GDS export, merge, import and geometry validation

## 1. Objective

Milestone 7B completed the current Innovus physical-preparation and post-route timing-check session.

Milestone 7C documents the export of the routed SPI Slave core into a merged GDSII file and its import into Virtuoso for preliminary structural and geometry verification.

The target design remains a 16-bit SPI Slave operating above 10 MHz in the final PAD-integrated implementation.

This milestone is NOT foundry DRC, LVS, PEX or final tape-out signoff.

## 2. Source Design

Top cell: `spi_slave`

Innovus restored checkpoint:

`innovus/db/m7b_restore_check/core_final_rc_propagated_clock.enc.dat`

Technology:

`/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1`

Standard-cell library: `tcb018bcdgp2a`

Standard-cell reference GDS:

`$PDKROOT/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/gds/tcb018bcdgp2a_110a/tcb018bcdgp2a.gds`

Innovus StreamOut map:

`innovus/reports/m7b_streamout_probe_20261020/streamOut_bcd_candidate.map`

Target Virtuoso library:

`spi_slave_gds_1000dbu_check`

Target cell/view: `spi_slave/layout`

Virtuoso work directory:

`~/spi-fyp/virtuoso_import_hvbcd_20261029`

## 3. GDS Export

The first merged GDS used 2000 DBU/um and triggered a Virtuoso StreamIn unit-resolution warning (`XSTRM-284`).

A revised GDS was exported using 1000 DBU/um to match the target OA technology database and reference standard-cell GDS.

Output file:

`spi_slave_core_merged_1000dbu_test.gds`

Recorded file size: 481588 bytes.

The recorded export options included:

- `-mode ALL`
- `-units 1000`
- `-dieAreaAsBoundary`
- `-merge` with the reference standard-cell GDS

Innovus reported `IMPOGDS-250`, warning of possible coordinate rounding when converting between the database and stream resolutions.

Innovus DBU: 2000 units/um
GDS DBU: 1000 units/um
Manufacturing grid: 0.005 um

The manufacturing grid is representable in the target GDS resolution, but complete coordinate equivalence has not been formally established.

## 4. Layer Mapping

The tested experimental StreamOut map uses:

| Layer | Routing GDS | Name text GDS |
| --- | --- | --- |
| METAL1 | 16/0 | 40/0 |
| METAL2 | 18/0 | 41/0 |
| METAL3 | 28/0 | 42/0 |
| METAL4 | 31/0 | 43/0 |
| VIA12 | 17/0 | — |
| VIA23 | 27/0 | — |
| VIA34 | 29/0 | — |
| DIEAREA | 62/0 | — |

Metal routing geometry is imported into the corresponding `METALx/drawing` layers.

Text objects on 40/0–43/0 are imported as labels on the corresponding `METALx/pin` layer-purpose pairs.

The current map merges the Innovus NET, SPNET, PIN and LEFPIN geometry categories onto the same metal drawing layers. Their NAME text categories are similarly merged per routing layer.

The map is an experimental working configuration, not a foundry-approved tape-out map.

## 5. Virtuoso Stream-In Results

The 1000-DBU merged GDS was successfully imported into:

`spi_slave_gds_1000dbu_check/spi_slave/layout`

Recorded StreamIn result:

- Errors: 0
- Warnings: 2
- No previous XSTRM-284 DBU mismatch warning

The two recorded warnings were:

- `XSTRM-75`: read-only technology library; undefined LPPs may be dropped
- `XSTRM-107`: existing cells may be overwritten

The on-disk `strmIn.log` was subsequently overwritten by separate standard-cell import experiments. Its latest contents must NOT be treated as the SPI top-level StreamIn log.

## 6. Top-Level Structural Validation

The imported SPI core was opened and inspected using Virtuoso SKILL.

Recorded results:

| Property | Observed |
| --- | ---: |
| Instances | 256 |
| Distinct standard-cell masters | 42 |
| Top-level shapes | 1247 |
| Via instances | 736 |
| Label objects | 171 |
| OA terminals | 0 |

All 256 instances were present.

No missing or empty referenced standard-cell masters were reported in the recorded inspection.

Innovus StreamOut reported 682 regular vias and 54 special vias.

Total: 736 vias.

This agrees with the imported Virtuoso via count.

The count checks establish useful structural consistency but do not prove complete electrical equivalence.

## 7. Standard-Cell Geometry Comparison

A comparison was performed for the 42 used standard-cell masters.

35 masters passed the original-OA versus imported-GDS comparison.

Seven masters initially showed additional METAL1/boundary polygons:

- DFCND4
- ND2D4
- INVD4
- INVD16
- NR2D4
- DFCNQD4
- CKBD16

The seven masters were then imported independently from the original TSMC vendor GDS and compared with their counterparts in the merged core GDS.

| Cell | Vendor GDS shapes | Merged GDS shapes | Mismatches |
| --- | ---: | ---: | ---: |
| DFCND4 | 282 | 282 | 0 |
| ND2D4 | 130 | 130 | 0 |
| INVD4 | 86 | 86 | 0 |
| INVD16 | 204 | 204 | 0 |
| NR2D4 | 130 | 130 | 0 |
| DFCNQD4 | 225 | 225 | 0 |
| CKBD16 | 402 | 402 | 0 |

The extra METAL1/boundary polygons were confirmed to exist in the vendor reference GDS itself.

The seven named masters passed the direct vendor-GDS-versus-merged-GDS shape-signature comparison.

The other 35 masters passed the earlier OA-versus-imported comparison; these are different comparison methods.

These checks do not replace full-chip DRC or LVS.

## 8. Pin Labels and Terminal Investigation

Innovus contained 38 signal terminals, each with one physical pin.

The GDS export recorded 38 signal pin positions on METAL3 and four VDD/VSS power-label occurrences on METAL4.

Virtuoso confirmed that top-level labels were imported.

Examples:

```text
sclk:   METAL3/pin at (0.363 50.4)
csb_n:  METAL3/pin at (0.363 4.48)
mosi:   METAL3/pin at (0.363 8.96)
miso:   METAL3/pin at (99.638 5.04)
VDD:    METAL4/pin, two occurrences
VSS:    METAL4/pin, two occurrences
```

The 171 labels include external port names, duplicate labels and internal net names.

Virtuoso OA terminal count remained zero.

This is not evidence that labels are missing: GDS text labels and OA terminal database objects are different representations.

In the imported layout, labels are found among `cv~>shapes` where `objType == "label"`.

Earlier checks incorrectly used `cv~>labels` or `objType == "text"`, producing misleading zero-label results.

No automatic or manual creation of OA terminals was performed.

Whether the selected LVS deck recognizes the existing labels, including power-net names, is still unverified.

## 9. Reproducible Read-Only SKILL Check

Open the imported SPI layout from Virtuoso CIW:

```lisp
cv1000 = dbOpenCellViewByType(
  "spi_slave_gds_1000dbu_check"
  "spi_slave"
  "layout"
  ""
  "r"
)

when(cv1000
  printf("Instances: %d\n" length(cv1000~>instances))
  printf("Shapes: %d\n" length(cv1000~>shapes))
  printf("Vias: %d\n" length(cv1000~>vias))
  printf("Terminals: %d\n" length(cv1000~>terminals))

  labelCount = 0
  foreach(s cv1000~>shapes
    when(equal(s~>objType "label")
      labelCount = labelCount + 1
    )
  )
  printf("Labels: %d\n" labelCount)
)
```

Recorded output:

```text
Instances: 256
Shapes: 1247
Vias: 736
Terminals: 0
Labels: 171
```

## 10. Known Limitations

The following items are not yet resolved:

1. Foundry-rule DRC has not been run.
2. LVS against a suitable reference netlist has not been run.
3. Foundry PEX/RCC has not been run.
4. Full label-to-metal contact and LVS port recognition are not verified.
5. GDS coordinate rounding warning requires signoff review.
6. The temporary die boundary extension has not been legalized for the final chip.
7. There are no added metal fills in the current exported core.
8. The design does not yet include the final PAD-integrated die.
9. Milestone 7B default-group setup and hold violations remain open.
10. The final die has not been verified above 10 MHz under complete external timing constraints.

The current GDS is a physical-verification candidate, not a tape-out-qualified file.

## 11. Milestone Conclusion

Milestone 7C completed the recorded core-only GDS export and preliminary Virtuoso import validation.

Structural counts, imported labels, and the recorded standard-cell geometry comparisons support using this GDS as the next physical-verification candidate.

No evidence from this milestone establishes foundry DRC/LVS/PEX signoff.

## 12. Next Stage: Milestone 7D

The next milestone is Foundry DRC and LVS:

1. Identify a supported physical-verification tool.
2. Locate the correct TSMC 180nm HV BCD Gen2 rule decks.
3. Run the foundry DRC checks on the core.
4. Prepare the reference netlist and verify power and port recognition.
5. Run LVS and investigate any differences.
6. Proceed to PEX/RCC after DRC/LVS issues are understood.

The final PAD-integrated design will require separate die-level verification.

## 13. Archived Evidence

The Git evidence directory for this milestone is:

`docs/evidence/m7c/`

It records:

- the experimental Innovus StreamOut map;
- source file checksums and paths, where available.

The merged GDS, licensed TSMC GDS/PDK files and OpenAccess databases remain on the server and are not committed to the public repository.
