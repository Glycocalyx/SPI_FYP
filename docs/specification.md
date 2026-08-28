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