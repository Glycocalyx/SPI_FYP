# Milestone 6B — Innovus Physical Design Import

**Project:** SPI Interface Design  
**Technology:** TSMC 180-nm BCD  
**Physical stack:** 6LM  
**Innovus:** 21.13-s100_1  
**Status:** Initial physical-design import completed and validated.

---

## 1. Objective

Milestone 6B establishes the initial Cadence Innovus physical-design
environment for the synthesized SPI Slave.

The objectives are:

1. Import the fixed Genus synthesized gate-level netlist into Innovus.
2. Load the corresponding 6LM standard-cell and IO physical libraries.
3. Establish the TT timing-analysis environment.
4. Replace the pre-layout artificial internal-clock model with a
   physical-design timing constraint suitable for Innovus.
5. Verify library, netlist, timing and physical-database consistency.
6. Identify power, constant-net and floorplan issues before placement.

No placement, clock-tree synthesis or signal routing is performed in
this milestone.

---

## 2. Design Input

### 2.1 Top-Level Design

The imported top-level module is:

`spi_slave_full_io_pad_wrapper`

The imported gate-level netlist is:

`syn/outputs/spi_slave_csb_async_110MHz_5pF.v`

This is the same fixed TT-optimized netlist used for the previous
pre-layout timing characterization.

The design contains the SPI Slave core together with four
`PDDW0208CSG` signal PADs:

- SCLK
- MOSI
- CSB
- MISO

---

## 3. Innovus Environment

Cadence Innovus version:

`21.13-s100_1`

Executable:

`/usr/eelocal/cadence/innovus211/tools/bin/innovus`

The physical implementation uses the TSMC 180-nm BCD PDK.

---

## 4. Physical Technology Configuration

The selected physical stack is the 6-layer-metal configuration.

### 4.1 Standard-Cell LEF

`tcb018bcdgp2a_6lm.lef`

The technology LEF defines the following routing stack:

- METAL1
- METAL2
- METAL3
- METAL4
- METAL5
- METAL6

The physical library therefore corresponds to the complete 6LM
process option.

### 4.2 IO LEF

The initial IO physical library is:

`tps018bcdnv5_6lm.lef`

from the `mt/6lm` library branch.

The supervisor confirmed that the exact PAD variant is not critical
at this stage because the small number of PADs allows manual
replacement if required later.

### 4.3 Routing-Layer Policy

Although the 6LM physical technology is loaded, the implementation
flow will restrict normal Innovus signal routing to:

`METAL1` through `METAL4`

METAL5 and METAL6 are therefore not intended for ordinary automatic
signal routing in this project.

The routing-layer restriction will be explicitly applied in the
subsequent physical implementation stages.

---

## 5. Timing Environment

### 5.1 Timing Libraries

The TT timing environment uses:

Core:

`tcb018bcdgp2atc.lib`

IO:

`tps018bcdnv5tc.lib`

The analysis condition is:

- TT corner
- 5.0 V
- 25 °C

### 5.2 RC Model

The 6LM typical capacitance table is:

`t018lo_1p6m_typical.captable`

This provides the initial interconnect RC model used by Innovus.

### 5.3 Physical-Design SDC

A dedicated physical-design SDC is used:

`innovus/constraints/spi_tt_110MHz_phys.sdc`

The reference SCLK frequency remains 110 MHz in this stage so that
future post-layout results can be directly compared with the previous
Genus pre-layout characterization.

Unlike the previous Genus timing model, the Innovus SDC creates the
clock at the external `sclk_pad` port.

The manually shifted ideal `CORE_SCLK` used during pre-layout timing
characterization is intentionally removed.

This allows the physical SCLK PAD and the subsequently implemented
clock network to contribute their actual physical timing.

The current external interface assumptions remain:

- SCLK input transition: 1 ns
- MOSI input transition: 1 ns
- CSB input transition: 1 ns
- MISO load: 5 pF
- external MOSI delay: 0 ns
- external MISO delay: 0 ns

The external zero-delay assumptions remain idealized and do not yet
include FPGA, package or PCB timing.

---

## 6. MMMC Configuration

The initial Innovus MMMC environment contains one analysis view:

`VIEW_TT`

It combines:

- TT Core Liberty
- TT IO Liberty
- 6LM typical RC model
- physical SPI SDC

This is sufficient for the initial physical implementation flow.

Additional WC, BC and LT analysis views will be introduced after the
basic placement and routing flow is established.

---

## 7. Import Result

The Innovus design import completed without fatal errors.

The imported physical database contains:

| Item | Result |
|---|---:|
| Standard cells | 94 |
| IO PAD cells | 4 |
| Total instances | 98 |
| Nets | 123 |
| Standard-cell area | 5660.48 um² |
| IO PAD area | 38400.00 um² |

All standard cells and PAD cells referenced by the synthesized
netlist were successfully resolved in the loaded LEF libraries.

There are no missing LEF macros and no missing timing models for the
instantiated cells.

The imported database was saved as:

`innovus/db/m6b_import.enc`

---

## 8. Standard-Cell Placement Site

The standard-cell site is:

`core10T`

with physical dimensions:

`0.560 um × 5.600 um`

The standard cells therefore occupy rows with a height of 5.600 um,
while the horizontal placement grid is based on a 0.560-um site.

The formal floorplan created in Milestone 6C will be aligned to this
placement grid.

---

## 9. IO PAD Geometry

The currently selected signal PAD is:

`PDDW0208CSG`

Its physical dimensions are:

`80 um × 120 um`

and its LEF class is:

`PAD`

The four signal PADs therefore have a combined abstract LEF area of:

`38400 um²`

This is significantly larger than the total standard-cell area.

The present SPI implementation is therefore strongly PAD-dominated
in physical area.

---

## 10. Power/Ground Connectivity

The standard-cell library defines:

- `VDD` as the power pin
- `VSS` as the ground pin

Global VDD/VSS connectivity was examined during the import
diagnostics.

The design-level physical checks report:

- zero floating power/ground terminals
- zero power/ground pins connected to signal nets
- zero power pins connected to ground
- zero ground pins connected to power

The reported VDD and VSS nets remain unrouted because power planning
and physical power routing have not yet been performed.

This is expected at the import stage.

---

## 11. IO Library PG-Pin Warning

Innovus reports 17 library cells with missing PG pins.

The affected cells are:

- PXOE2CSG
- PFILLER5
- PFILLER20
- PFILLER10
- PFILLER1
- PFILLER05
- PFILLER0005
- PDUW0412SOPD
- PDUW0412SCSG
- PDUW0412CSG
- PDUW0208SCSG
- PDUW0208CSG
- PDDW0412SCSG
- PDDW0412CSG
- PDDW0208SCSG
- PDDW0208CSG
- PCORNER

All affected macros belong to the IO PAD library rather than the
standard-cell core library.

For example, the `PDDW0208CSG` LEF abstraction contains the functional
PAD pins but does not expose conventional `VDD` and `VSS` PG pins.

The warning is therefore classified as a physical-library integrity
warning associated with the IO LEF abstraction rather than evidence
of floating standard-cell power connections.

The foundry-provided LEF is not modified.

Dedicated IO power PADs and the final PAD-ring power architecture
remain future chip-level implementation tasks.

---

## 12. Constant-Net Handling

The synthesized gate-level netlist contains constant control values
on several IO PAD terminals.

Examples include control inputs such as:

- IE
- PE
- OEN
- DS
- I

An initial diagnostic experiment connected logical constant-high and
constant-low signals directly to VDD and VSS through Innovus global
net connectivity.

This removed the original floating constant-input warnings and
confirmed their cause.

However, direct VDD/VSS tie-off is not adopted as the final physical
implementation strategy.

### 12.1 Foundry Tie Cells

The standard-cell library contains dedicated physical tie cells.

#### TIEH

Physical cell:

`TIEH`

Size:

`2.240 um × 5.600 um`

Placement site:

`core10T`

Output:

`Z`

Liberty logical function:

`1`

#### TIEL

Physical cell:

`TIEL`

Size:

`2.240 um × 5.600 um`

Placement site:

`core10T`

Output:

`ZN`

Liberty logical function:

`0`

Therefore, the final implementation will use foundry-provided TIEH
and TIEL cells for logical constants rather than directly connecting
ordinary logic inputs to the power rails.

Physical tie-cell insertion will be performed after a valid
floorplan and placement environment exists.

The direct global TieHi/TieLo experiment is retained only as a
diagnostic step and is not used as the final implementation database.

---

## 13. Temporary Floorplan Warnings

During the initial import, Innovus automatically creates a temporary
core and die geometry.

The initial design check reports that the automatically created core
and die boundaries are not completely aligned with the placement
grid.

This is expected because a formal project floorplan has not yet been
created.

The warning will be resolved in Milestone 6C by explicitly creating
a floorplan aligned with the `core10T` placement site.

No manual modification of the temporary import geometry is required.

---

## 14. Milestone Status

Milestone 6B successfully establishes the Innovus physical-design
environment.

Completed:

- Innovus environment setup
- 6LM Core LEF selection
- 6LM IO LEF selection
- gate-level netlist import
- TT Liberty configuration
- 6LM typical RC configuration
- physical-design SDC
- MMMC TT analysis view
- standard-cell and PAD resolution
- VDD/VSS connectivity diagnosis
- IO PG warning classification
- TieHi/TieLo root-cause diagnosis
- foundry TIEH/TIEL identification

Pending for subsequent milestones:

- formal floorplan
- PAD placement
- placement rows and utilization
- TIEH/TIEL physical insertion
- power-ring / power-grid planning
- standard-cell placement
- clock-tree synthesis
- signal routing
- post-route parasitic extraction
- post-layout setup/hold analysis
- multi-corner physical timing analysis

---

## 15. Next Milestone

Milestone 6C will establish the formal physical floorplan.

The main objectives are:

1. determine a suitable die/core size;
2. align the core with the `core10T` placement grid;
3. place or reserve the four signal PAD regions;
4. establish standard-cell placement rows;
5. enforce the project requirement of using the 6LM process while
   restricting ordinary signal routing to METAL1-METAL4;
6. prepare the physical database for standard-cell placement and
   tie-cell insertion.
