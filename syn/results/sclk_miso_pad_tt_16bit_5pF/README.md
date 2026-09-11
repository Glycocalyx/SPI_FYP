# Milestone 4 - SCLK Input PAD + MISO Output PAD Timing

## Configuration

- Technology: TSMC 180nm HV BCD
- Core library: `tcb018bcdgp2atc`
- IO library: `tps018bcdnv5tc`
- Corner: TT / 25C / 5.0V
- DATA_WIDTH: 16 bit
- SPI mode: Mode 0
- Bit order: MSB first
- IO cell: `PDDW0208CSG`
- External SCLK slew assumption: 1.0 ns
- External MISO load: 5.0 pF
- Tool: Cadence Genus 21.14

## Timing Model

The external SPI clock and the internal SPI clock are modeled separately:

- `EXT_SCLK`: clock at the external ASIC interface
- `CORE_SCLK`: clock observed by the SPI core after the SCLK input PAD

This is required because Genus treats the clock network as ideal during
pre-layout synthesis, while the real SCLK input PAD has a non-zero
PAD-to-C propagation delay.

The MISO output PAD is instantiated directly, so its I-to-PAD delay is
taken automatically from the IO Liberty timing model.

## SCLK Core Load

The mapped SCLK core net has:

- Rise capacitance: 122.5 fF = 0.1225 pF
- Fall capacitance: 120.5 fF = 0.1205 pF

Using a 1.0 ns external SCLK input slew and linear interpolation of the
PDDW0208CSG PAD-to-C Liberty table gives approximately:

- SCLK PAD rise delay: 0.6738 ns
- SCLK PAD fall delay: 0.7487 ns

## 110 MHz Result

At 110 MHz:

- EXT_SCLK rising deadline: 9.091 ns
- CORE_SCLK falling launch: 5.294 ns
- Available timing budget: ~3.797 ns
- Data path: 3.796 ns
- Slack: 0 ps
- Result: MET at the timing-closure boundary

The critical path is:

`CORE_SCLK falling edge -> TX logic -> MISO IO PAD -> external miso_pad`

The MISO IO PAD I-to-PAD delay is approximately 2.464 ns under the
current 5 pF external-load condition.

## Conclusion

Under the current pre-layout baseline:

- TT / 25C / 5.0V
- 1.0 ns external SCLK slew
- actual mapped SCLK core load of approximately 0.12 pF
- 5.0 pF external MISO load

the external-interface timing-closure edge is approximately 110 MHz.

This is not the final guaranteed silicon SPI frequency. Post-route
parasitics, worst-case PVT, package/PCB delay, FPGA setup/hold timing,
clock uncertainty, and jitter are not yet included.
