# SPI Slave ASIC — Active Specification

## Active scope

The ASIC implements a 16-bit SPI Slave on TSMC 180 nm HV BCD Gen2 (6LM / 1P6M). An external FPGA drives the bus as Master. The repository's Master serves as a verification reference.

- SPI Mode 0 (CPOL=0, CPHA=0), MSB first, with SCLK idle low.
- The Slave samples MOSI on the rising SCLK edge and advances MISO on the falling edge.
- Active-low CSB selects the Slave. Separate CSB lines allow multiple Slaves on the bus. The Slave releases MISO via output enable when deselected.
- CSB asynchronously clears transaction state. The Slave updates `rx_data` and `rx_valid` after receiving a full word.
- The die-level SPI target is at least 10 MHz. The 61 pF external MISO load models the oscilloscope probe for pre-layout assessment. The 375 MHz constraint belongs to a separate core-only stress test.
- The die architecture includes core, IO PADs and VDD/VSS. Ordinary signal routing is constrained to M1–M4.

See [project overview](PROJECT_OVERVIEW.md) and [current status](PROJECT_STATE.md).

## Original 8-bit Master specification (historical)

The following snapshot describes the initial architecture and planned work.

# SPI System Specification

## Technology and Flow
- Process: TSMC 180 nm BCD
- RTL language: SystemVerilog
- RTL simulation: Cadence Xcelium 23.05
- Logic synthesis: Cadence Genus 21.1
- Physical design: Cadence Innovus 21.1
- Final target: tapeout-oriented ASIC implementation

## System Architecture
- One SPI Master
- Two SPI Slaves
- Conventional multi-slave configuration
- Shared SCLK
- Shared MOSI
- Shared MISO
- Independent CSB1 and CSB2
- Active-low chip select

## Tentative Protocol Parameters
- SPI Mode: Mode 0
- CPOL: 0
- CPHA: 0
- Data width: 8 bits
- Bit order: MSB first
- Communication: Full duplex
- Transaction length: One 8-bit word per chip-select transaction

## Current Design Stage
The project is currently at the RTL architecture and implementation stage.

The next work is to:
- define Master, Slave, and Top-level interfaces;
- define one complete 8-bit SPI transaction timing;
- design the Master and Slave control logic;
- implement synthesizable RTL;
- build SystemVerilog testbenches and verify functionality.