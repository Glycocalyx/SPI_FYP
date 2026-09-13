# Milestone 5A - SCLK, MOSI, and MISO IO PAD Timing

## Objective

This milestone extends the SPI Slave external-interface timing model by
adding a real MOSI input PAD in addition to the SCLK input PAD and MISO
output PAD.

The purpose is to verify that the MOSI input path can meet the SPI Mode 0
sampling requirement at the current 110 MHz operating point.

CSB is intentionally kept as a core-level signal in this milestone and
will be handled separately.

---

## Configuration

- Technology: TSMC 180 nm HV BCD
- Core library: `tcb018bcdgp2atc`
- IO library: `tps018bcdnv5tc`
- IO cell: `PDDW0208CSG`
- Tool: Cadence Genus 21.14
- Corner: TT / 25 C / 5.0 V
- SPI mode: Mode 0
- Data width: 16 bit
- Bit order: MSB first
- SCLK frequency: 110 MHz
- SCLK period: 9.090909 ns
- External SCLK slew assumption: 1.0 ns
- External MOSI slew assumption: 1.0 ns
- External MISO load: 5.0 pF

---

## Interface Structure

The current wrapper contains:

```text
External SCLK
    |
    v
SCLK input PAD
    |
    v
sclk_core
    |
    +----------------------+
                           |
External MOSI              |
    |                      |
    v                      v
MOSI input PAD -------> SPI Slave
    |                      |
    v                      |
mosi_core                  |
                           |
                           v
                       miso_core
                           |
                           v
                     MISO output PAD
                           |
                           v
                     External MISO
```

CSB remains directly connected to the SPI core in this milestone.

---

## SCLK Timing Model

Genus treats the pre-layout clock network as ideal, so the SCLK input PAD
delay is represented using two clocks:

- `EXT_SCLK`: SCLK at the external ASIC boundary
- `CORE_SCLK`: SCLK seen by the SPI core after the input PAD

The mapped SCLK core load from synthesis is approximately:

- Rise capacitance: 122.5 fF
- Fall capacitance: 120.5 fF

Using the 1.0 ns external SCLK slew and interpolation of the
`PDDW0208CSG` PAD-to-C Liberty timing table gives:

- SCLK PAD rise delay: approximately 0.6738 ns
- SCLK PAD fall delay: approximately 0.7487 ns

---

## MOSI Input Timing

MOSI is a normal data path, so the real input PAD is instantiated directly
and Genus automatically uses the `PDDW0208CSG PAD->C` Liberty timing arc.

The mapped MOSI core net load is:

- Rise capacitance: 7.9 fF
- Fall capacitance: 7.6 fF

At 110 MHz, the worst reported MOSI setup path is:

```text
EXT_SCLK falling edge
        |
        v
external mosi_pad
        |
        v
PDDW0208CSG PAD -> C
        |
        v
mosi_core
        |
        v
RX sequential element
        |
        v
CORE_SCLK rising edge
```

Measured timing:

- External launch edge: 4.546 ns
- MOSI PAD-to-C delay: 0.554 ns
- CORE_SCLK capture edge: 9.765 ns
- Setup requirement: 0.906 ns
- MOSI setup slack: +3.760 ns
- Result: MET

Therefore, the MOSI input path is not frequency-limiting at 110 MHz.

---

## MISO Output Timing

Adding the MOSI input PAD does not change the previously identified MISO
critical path.

At 110 MHz:

- CORE_SCLK falling launch edge: 5.294 ns
- EXT_SCLK rising deadline: 9.091 ns
- Data path delay: 3.796 ns
- MISO timing slack: 0 ps
- Result: MET at the timing-closure boundary

The critical external-interface path remains:

```text
CORE_SCLK falling edge
        |
        v
TX logic
        |
        v
MISO output PAD
        |
        v
external miso_pad
```

The MISO output PAD remains a major contributor to the total path delay.

---

## Area

Genus reports:

- Cell count: 103
- Cell area: 5647.936

The IO timing library reports zero cell area for the PAD cell, so this
number should not be interpreted as the physical silicon area including
the IO PADs.

Actual PAD physical area will be determined later from the physical
library / LEF during the Innovus flow.

---

## Conclusion

At the current pre-layout TT baseline:

- SCLK input PAD is included
- MOSI input PAD is included
- MISO output PAD is included
- MOSI setup timing has approximately +3.760 ns margin
- MISO output timing remains at approximately 0 ps slack at 110 MHz

Therefore, the current frequency limit is still dominated by the
TX-to-MISO external output path rather than the MOSI input path.

---

## Current Limitations

This milestone is not a final silicon timing signoff.

The current analysis does not yet include:

- CSB input PAD timing
- FPGA clock-to-output delay
- FPGA input setup/hold requirements
- PCB/package delay and skew
- clock jitter or uncertainty
- post-route parasitic RC
- worst-case PVT corners
- formal min-delay / hold analysis

The MOSI input delay is currently set to 0 ns at the ASIC boundary.

Formal hold/min-delay analysis will be performed later using appropriate
fast/min timing corners and physical implementation timing in the
MMMC / Innovus flow.
