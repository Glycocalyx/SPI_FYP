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

## Timing Results

| Path | Result | Slack |
|---|---:|---:|
| MOSI input setup | MET | +3760 ps |
| MISO output timing | MET | +5 ps |

The MOSI input path remains comfortably within timing at 110 MHz.

The MISO output path remains the critical external-interface path and is very close to the current pre-layout timing boundary.


## CSB Core Net

The CSB input PAD is physically integrated into the synthesized design.

The mapped `csb_core` net is driven by:

`u_csb_pad/C`

and drives the synthesized SPI transaction-control logic, including the MISO output-enable control path.

The mapped CSB core-net characteristics are:

- Rise capacitance: 41.6 fF
- Fall capacitance: 41.8 fF
- Rise slew: 240.8 ps
- Fall slew: 240.1 ps

This confirms the physical signal path:

    external csb_pad
        |
        v
    CSB input PAD
        |
        v
    u_csb_pad/C
        |
        v
    csb_core
        |
        v
    SPI transaction-control logic

CSB is intentionally not treated as a normal synchronous input in this milestone.

Recovery/removal timing will be analyzed separately in Milestone 5C.


## SCLK Core Net

The mapped SCLK core-net load remains approximately:

- Rise capacitance: 122.5 fF
- Fall capacitance: 120.5 fF

The previously characterized SCLK input PAD delays remain:

- Rising-edge PAD-to-C delay: 0.6738 ns
- Falling-edge PAD-to-C delay: 0.7487 ns


## MOSI Input Timing

The worst reported MOSI setup path has:

- PAD-to-C delay: 0.554 ns
- Setup slack: +3.760 ns
- Result: MET

The physical path is:

    mosi_pad
        |
        v
    u_mosi_pad/PAD
        |
        v
    u_mosi_pad/C
        |
        v
    SPI receive sequential logic

Therefore, MOSI is not the frequency-limiting interface path at 110 MHz.


## MISO Output Timing

The worst reported MISO output path has:

- Data-path delay: 3.791 ns
- MISO PAD I-to-PAD delay: 2.502 ns
- Slack: +5 ps
- Result: MET

The physical path is:

    CORE_SCLK falling edge
        |
        v
    TX sequential logic
        |
        v
    combinational logic
        |
        v
    MISO output PAD
        |
        v
    external miso_pad

The MISO output PAD remains a major contributor to the total interface delay.

Therefore, the TX-to-MISO path remains the frequency-limiting path in the current pre-layout model.


## Area

| Design | Cell Count | Cell Area |
|---|---:|---:|
| Full IO PAD wrapper | 98 | 5660.480 |

The reported Genus area does not represent the physical area of the IO PAD cells themselves.

The actual IO PAD dimensions will be handled later using the physical LEF/layout views during Innovus implementation.


---

# Current Status

Completed:

- [x] SCLK input PAD modeling
- [x] MOSI input PAD modeling
- [x] CSB input PAD integration
- [x] MISO output PAD modeling
- [x] Full IO wrapper synthesis
- [x] SCLK core-net characterization
- [x] MOSI setup timing verification
- [x] MISO output timing verification
- [x] CSB core-net verification

Current verified configuration:

- Technology: TSMC 180nm HV BCD
- Corner: TT / 25°C / 5V
- SPI Mode: Mode 0
- Data width: 16 bits
- SCLK frequency: 110 MHz
- External MISO load: 5 pF


---

# Conclusion

Milestone 5B successfully integrates all four external SPI signals through physical IO PAD cells:

- SCLK
- MOSI
- CSB
- MISO

At 110 MHz:

- MOSI setup timing passes with +3.760 ns slack.
- MISO output timing passes with only +5 ps slack.
- CSB is successfully connected through its physical input PAD into the synthesized transaction-control logic.
- The TX-to-MISO path remains the dominant timing limitation.

This milestone establishes the complete pre-layout SPI IO interface model.


---

# Next Step

## Milestone 5C: CSB Asynchronous Timing Analysis

The next milestone will:

- inspect the exact asynchronous use of `csb_n` inside `spi_slave.sv`
- identify the sequential cells affected by CSB
- determine the appropriate recovery/removal timing methodology
- avoid incorrectly treating CSB as a normal synchronous data input

After Milestone 5C, the design will be prepared for Innovus physical implementation.
