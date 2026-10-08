# Milestone 6C — Innovus Floorplan and SPI PAD Placement

**Project:** SPI Interface Design  
**Technology:** TSMC 180-nm BCD  
**Physical stack:** 6LM  
**Innovus:** 21.13-s100_1  
**Status:** Formal floorplan and SPI signal-PAD placement completed.

---

## 1. Objective

Milestone 6C establishes the first formal physical geometry of the
SPI Slave ASIC implementation.

The objectives are:

1. define a legal die and standard-cell core region;
2. align the physical floorplan with the TSMC placement grid;
3. establish standard-cell placement rows;
4. reserve sufficient peripheral area for the IO PADs;
5. place and orient the four SPI signal PADs;
6. preserve the project requirement of using the 6LM technology
   while restricting normal automatic signal routing to METAL1-METAL4;
7. prepare a legal physical database for subsequent power planning,
   standard-cell placement, tie-cell insertion, CTS and routing.

No standard-cell placement, CTS or signal routing is performed in
this milestone.

---

## 2. Input Database

Milestone 6C starts from the validated Innovus import database:

`innovus/db/m6b_import.enc`

Top-level design:

`spi_slave_full_io_pad_wrapper`

The physical libraries are:

- Core: `tcb018bcdgp2a_6lm.lef`
- IO: `tps018bcdnv5_6lm.lef`

The selected IO library is the `mt/6lm` variant.

---

## 3. Standard-Cell Geometry

The TSMC standard-cell placement site is:

`core10T`

with:

- site width: 0.560 um
- row height: 5.600 um

Innovus reports the physical placement grid as:

- origin: `(0,0)`
- X pitch: `0.560 um`
- Y pitch: `0.560 um`

The placement grid and the standard-cell row height therefore
represent two related but distinct physical constraints.

---

## 4. Core Size

The synthesized design contains:

- 94 standard cells
- standard-cell area: 5660.48 um²

The selected core dimensions are:

`123.2 um × 123.2 um`

Core area:

`15178.24 um²`

Therefore the initial standard-cell utilization is approximately:

`37.29%`

This intentionally leaves substantial whitespace for:

- placement optimization;
- clock-tree cells;
- TIEH/TIEL cells;
- routing resources;
- filler cells;
- subsequent implementation adjustments.

The selected core dimensions are compatible with both the placement
grid and the standard-cell row structure.

Horizontal placement sites:

`123.2 / 0.56 = 220`

Standard-cell rows:

`123.2 / 5.6 = 22`

---

## 5. IO PAD Geometry

The selected SPI signal PAD is:

`PDDW0208CSG`

Physical dimensions:

`80 um × 120 um`

The external `PAD` terminal is located along the local bottom edge
of the R0-oriented macro.

The PAD terminal is represented in the LEF using METAL2 through
METAL6 geometries.

The macro supports:

`SYMMETRY X Y R90`

and can therefore be legally rotated for placement on different
sides of the die.

---

## 6. Floorplan Geometry

The final formal floorplan is:

### Die

`403.2 um × 403.2 um`

Die box:

`(0.0,0.0) -> (403.2,403.2)`

### Core

`123.2 um × 123.2 um`

Core box:

`(140.0,140.0) -> (263.2,263.2)`

The final distance between each die edge and the corresponding core
boundary is therefore:

`140.0 um`

Since the PAD depth is 120 um, approximately 20 um remains between
the inner PAD boundary and the core boundary.

---

## 7. Floorplan Grid Investigation

The initial floorplan attempts produced Innovus warnings:

- `IMPFP-7236`
- `IMPFP-7238`

indicating that the die and core corners were not located on the
placement grid.

### 7.1 Initial Observation

Using a requested floorplan margin of 140 um produced an actual
core offset of approximately 220 um.

Further investigation showed that the IO architecture contributes
approximately 80 um of peripheral physical width.

Therefore an input margin of approximately 60 um is appropriate for
achieving a final die-to-core spacing of approximately 140 um.

### 7.2 Placement-Grid Diagnosis

Innovus reported the placement grid as:

- origin: `(0,0)`
- pitch X: `0.56 um`
- pitch Y: `0.56 um`

When a requested margin of 60 um was used with the default
floorplan snapping behavior, Innovus adjusted the requested margin
from:

`60.00 um`

to:

`59.92 um`

because 59.92 um lies directly on the 0.56-um placement grid.

However, after the approximately 80-um IO region was included, the
resulting core boundary became:

`139.92 um`

which is not located on the placement grid.

This produced the remaining grid warnings.

### 7.3 Final Solution

The formal floorplan therefore uses:

`-noSnapToGrid`

when the initial 60-um pre-IO margin is specified.

This prevents Innovus from prematurely changing 60.00 um to
59.92 um.

The resulting geometry becomes:

`60.0 + 80.0 = 140.0 um`

and:

`140.0 / 0.56 = 250`

The core width is:

`123.2 / 0.56 = 220`

and the final die size is:

`403.2 / 0.56 = 720`

Therefore all final die and core boundaries lie exactly on the
0.56-um placement grid.

The final design check reports no:

- `IMPFP-7236`
- `IMPFP-7238`
- `NOT on PlacementGrid`

warnings.

---

## 8. Routing-Layer Policy

The complete physical technology contains:

- METAL1
- METAL2
- METAL3
- METAL4
- METAL5
- METAL6

The project uses the complete 6LM physical library.

However, normal Innovus automatic signal routing is restricted to:

`METAL1 - METAL4`

through the NanoRoute routing-layer configuration.

METAL5 and METAL6 are not intended for ordinary automatic signal
routing in the current SPI digital implementation.

---

## 9. SPI Signal-PAD Placement

The four signal PADs are distributed symmetrically around the die.

### 9.1 SCLK

Instance:

`u_sclk_pad`

Side:

Left

Orientation:

`R90`

Physical box:

`(0.0,161.6) -> (120.0,241.6)`

The external PAD terminal faces toward the left die boundary.

### 9.2 MOSI

Instance:

`u_mosi_pad`

Side:

Bottom

Orientation:

`R0`

Physical box:

`(161.6,0.0) -> (241.6,120.0)`

The external PAD terminal faces toward the bottom die boundary.

### 9.3 MISO

Instance:

`u_miso_pad`

Side:

Top

Orientation:

`R180`

Physical box:

`(161.6,283.2) -> (241.6,403.2)`

The external PAD terminal faces toward the top die boundary.

### 9.4 CSB

Instance:

`u_csb_pad`

Side:

Right

Orientation:

`R270`

Physical box:

`(283.2,161.6) -> (403.2,241.6)`

The external PAD terminal faces toward the right die boundary.

All four PAD instances are fixed after placement.

---

## 10. PAD Arrangement

The physical organization is:

```text
                 MISO
                 R180
                  |
        +----------------------+
        |                      |
        |     +----------+     |
        |     |          |     |
 SCLK --|     |   CORE   |     |-- CSB
 R90    |     |          |     |   R270
        |     +----------+     |
        |                      |
        +----------------------+
                  |
                  R0
                 MOSI
```

This arrangement provides a simple symmetric SPI physical interface.

SCLK is placed on the left side close to the core clock-entry region,
while MOSI, MISO and CSB are distributed across the remaining sides.

---

## 11. Placement Verification

After PAD placement:

- all four PADs are fixed;
- no Innovus fatal errors are reported;
- no standard-cell placement is performed yet;
- all 94 standard cells remain intentionally unplaced.

The placement report shows:

| Parameter | Result |
|---|---:|
| Placed standard cells | 0 |
| Unplaced standard cells | 94 |
| Standard-cell placement density | 37.29% |

The unplaced cells are expected at this milestone because standard-cell
placement belongs to the following physical-design stage.

---

## 12. Remaining Tie-Cell Warnings

The design check continues to report 18 floating IO-instance control
terminals.

These correspond to constant logical values in the synthesized
netlist.

This is expected at this stage.

The TSMC standard-cell library contains dedicated physical tie cells:

### TIEH

- output: `Z`
- logical function: `1`
- size: `2.240 um × 5.600 um`

### TIEL

- output: `ZN`
- logical function: `0`
- size: `2.240 um × 5.600 um`

The final physical implementation will use these foundry-provided
tie cells rather than permanently connecting ordinary logic inputs
directly to VDD or VSS.

Tie-cell insertion is deferred until a valid standard-cell placement
environment exists.

---

## 13. IO-Library PG Warning

Innovus continues to report 17 IO-library macros with missing
conventional PG pins.

The affected cells belong to the foundry IO library, including:

- signal PAD variants;
- IO filler cells;
- corner cells.

This warning was already investigated in Milestone 6B.

The design-level PG checks did not indicate floating standard-cell
power/ground terminals.

The foundry LEF is therefore left unchanged.

A complete tapeout-ready PAD ring will eventually require dedicated
power/ground PADs and corresponding chip-level power architecture.

---

## 14. Output Databases

The formal floorplan database is:

`innovus/db/m6c_floorplan.enc`

The PAD-placed database is:

`innovus/db/m6c_pad_placed.enc`

The Innovus databases are reproducible intermediate implementation
products and are not committed to Git.

The formal TCL scripts and important verification reports are stored
in version control.

---

## 15. Milestone Status

Completed:

- formal die geometry
- formal core geometry
- placement-grid diagnosis
- legal floorplan alignment
- standard-cell row generation
- M1-M4 signal-routing policy
- SPI signal-PAD placement
- PAD orientation
- PAD fixing
- floorplan design checks
- PAD placement checks

Pending:

- chip-level power architecture
- power-ring / rail planning
- standard-cell placement
- TIEH/TIEL insertion
- placement optimization
- clock-tree synthesis
- signal routing
- parasitic extraction
- post-route timing analysis
- multi-corner physical timing verification

---

## 16. Next Stage

The next physical-design stage will establish the implementation
environment required before CTS.

The main tasks include:

1. determine the appropriate core power-delivery structure;
2. establish VDD/VSS rails or rings as appropriate;
3. place the 94 standard cells;
4. insert TIEH/TIEL cells for constant logical values;
5. legalize and optimize the placement;
6. perform pre-CTS timing and congestion checks.

Clock-tree synthesis and detailed signal routing will follow after
the placement stage is verified.
