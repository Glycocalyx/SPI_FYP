# SPI FYP Development Instructions

## Project
This is a digital ASIC SPI interface design project targeting TSMC 180 nm BCD.

Target tool flow:
- SystemVerilog RTL
- Cadence Xcelium 23.05 for RTL simulation
- Cadence Genus 21.1 for logic synthesis
- Cadence Innovus 21.1 for physical design
- Virtuoso may be used later for top-level integration if required

## System Architecture
- One SPI Master
- Two SPI Slaves
- Conventional multi-slave topology
- SCLK shared by both slaves
- MOSI shared by both slaves
- MISO shared by both slaves
- Independent active-low CSB1 and CSB2
- Only one slave may be selected at a time
- The two slaves should reuse the same slave module when possible

## Tentative SPI Specification
These parameters are tentative and may be changed later:
- SPI Mode 0
- CPOL = 0
- CPHA = 0
- 8-bit data width
- MSB first
- Full-duplex communication
- One 8-bit word per transaction

## RTL Design Rules
- Use synthesizable SystemVerilog
- Target ASIC implementation, not FPGA implementation
- Do not instantiate Xilinx/Intel FPGA-specific primitives
- Do not use `#` delays in synthesizable RTL
- Keep RTL and testbench code separate
- Prefer simple, readable RTL over unnecessary complexity
- Master, slave, and top-level logic should remain modular
- Use self-checking SystemVerilog testbenches
- Do not add FIFO, CRC, DMA, APB/AHB, or other extra features unless explicitly requested
- Do not change the agreed SPI specification without explicit confirmation

## Development Approach
Develop incrementally:
1. Define interfaces and timing behavior
2. Implement and verify a single SPI slave
3. Implement and verify the SPI master
4. Integrate one master with one slave
5. Extend to one master with two slaves
6. Perform system-level RTL verification
7. Prepare the design for Genus synthesis
8. Perform Innovus physical implementation