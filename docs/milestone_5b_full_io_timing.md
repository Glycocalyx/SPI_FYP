# Milestone 5B: Full IO PAD Timing Characterization

## Overview

This milestone extends the SPI slave synthesis flow from partial IO PAD modeling to a complete ASIC IO interface model.

The design includes:

- SCLK input PAD
- MOSI input PAD
- CSB input PAD
- MISO output PAD

Technology:

- TSMC 180nm HV BCD CMOS
- Core library: tcb018bcdgp2atc
- IO library: tps018bcdnv5tc

Corner:

- TT
- 25°C
- 5V


## Design Configuration

SPI configuration:

- Data width: 16-bit
- SPI Mode: Mode 0
- Bit order: MSB first

Target frequency:

- SCLK frequency: 110 MHz
- Clock period: 9.0909 ns


External assumptions:

- SCLK input slew: 1 ns
- MOSI input slew: 1 ns
- MISO output load: 5 pF


---

# IO PAD Architecture


## SCLK Input PAD

External direction:

```
FPGA
 |
 v
SCLK PAD
 |
 v
PAD receiver
 |
 v
CORE_SCLK
 |
 v
SPI slave core
```

SCLK is treated as a clock input.

Because synthesis tools idealize clock networks, the internal clock waveform is explicitly modeled after the SCLK input PAD delay.

Measured SCLK PAD delay:

- Rising edge delay: 0.6738 ns
- Falling edge delay: 0.7487 ns


The internal clock relationship:

```
CORE_SCLK = EXT_SCLK + SCLK PAD delay
```


---

# MOSI Input PAD

External direction:

```
FPGA
 |
 v
MOSI PAD
 |
 v
PAD receiver
 |
 v
mosi_core
 |
 v
SPI slave core
```


MOSI is a normal synchronous input data path.

The PAD input delay is automatically characterized by the Liberty PAD model:

```
PAD -> C
```

No manual PAD delay estimation is required.

SPI Mode 0 relationship:

- FPGA changes MOSI on EXT_SCLK falling edge
- ASIC samples MOSI on CORE_SCLK rising edge


Current assumption:

```
input_delay = 0
```

This represents an idealized external boundary without FPGA tCO delay and PCB delay.


---

# CSB Input PAD

External direction:

```
FPGA
 |
 v
CSB PAD
 |
 v
PAD receiver
 |
 v
csb_core
 |
 v
SPI slave core
```


CSB is different from MOSI because it is not only a slave-select signal.

In the current RTL implementation:

- CSB controls transaction state
- CSB participates in asynchronous control behavior

Therefore:

- Physical CSB PAD is instantiated
- Normal synchronous input timing constraint is not applied yet
- Recovery/removal timing will be analyzed separately


---

# MISO Output PAD

External direction:

```
SPI core
 |
 v
miso_core
 |
 v
Output PAD driver
 |
 v
MISO PAD
 |
 v
External load
```


The output timing path includes:

```
TX register
 |
 v
Combinational logic
 |
 v
MISO PAD driver
 |
 v
External pin
```


The dominant delay contribution comes from:

- TX register clock-to-Q delay
- Combinational logic delay
- IO PAD output delay


---

# Timing Constraint Methodology


## External Clock

The external SPI clock is modeled as:

```
EXT_SCLK
```

with:

```
period = 9.0909 ns
```


The internal clock is:

```
CORE_SCLK
```

after the SCLK input PAD.


---

## MOSI Timing

SPI Mode 0:

- External master changes MOSI at falling edge
- Slave samples MOSI at rising edge


Therefore MOSI timing is referenced to:

```
EXT_SCLK falling edge
```

and captured by:

```
CORE_SCLK rising edge
```


Current assumption:

```
input_delay = 0
```


Future improvement:

- FPGA tCO delay
- PCB trace delay
- clock skew


---

## MISO Timing

MISO output timing path:

```
CORE_SCLK
 |
 v
TX register
 |
 v
Logic path
 |
 v
MISO output PAD
 |
 v
External load
```


Main timing contributors:

- Register clock-to-Q delay
- Combinational logic delay
- PAD output delay


---

# Generated Reports

Timing reports:

```
timing_full_io_pad_110MHz_5pF.rpt

timing_mosi_full_io_pad_110MHz_5pF.rpt

timing_miso_full_io_pad_110MHz_5pF.rpt
```


Net capacitance reports:

```
sclk_core_net_full_io_pad_110MHz_5pF.rpt

mosi_core_net_full_io_pad_110MHz_5pF.rpt
```


Area report:

```
area_full_io_pad_110MHz_5pF.rpt
```


---

# Result Summary


## Timing

| Path | Slack |
|---|---|
| MOSI input setup | TBD |
| MISO output delay | TBD |


## Area

| Design | Area |
|---|---|
| Full IO PAD wrapper | TBD |


---

# Current Status

Completed:

- [x] SCLK input PAD modeling
- [x] MOSI input PAD modeling
- [x] MISO output PAD modeling
- [x] CSB input PAD instantiation
- [x] Complete IO wrapper synthesis using Genus


---

# Next Step

## Milestone 5C

Tasks:

- Analyze CSB asynchronous behavior
- Perform recovery/removal timing analysis
- Prepare design for Innovus physical implementation
