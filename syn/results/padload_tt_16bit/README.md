# 16-bit SPI Slave - PAD Input Load Genus Sweep

## Configuration

- Technology: TSMC 180nm HV BCD
- Standard-cell library: tcb018bcdgp2atc
- Corner: TT / 25C / 5.0V
- DATA_WIDTH: 16 bit
- SPI Mode: Mode 0
- Bit order: MSB first
- Pre-layout synthesis: Cadence Genus 21.14
- MOSI input delay: 0 ns
- MISO output delay: 0 ns
- MISO load: 0.0228543 pF

The MISO load is taken from the input capacitance of pin I of the
PDDW0208CSG IO pad.

## Results

| SCLK | Cell Count | Cell Area | Data Path | Slack | Result |
| --- | ---: | ---: | ---: | ---: | --- |
| 300 MHz | 86 | 5459.776 | 1.663 ns | +0.003 ns | PASS |
| 305 MHz | 88 | 5506.816 | 1.639 ns | 0.000 ns | PASS |
| 310 MHz | 93 | 5538.176 | 1.604 ns | +0.009 ns | PASS |
| 320 MHz | 99 | 5785.920 | 1.559 ns | +0.003 ns | PASS |
| 330 MHz | 102 | 5754.560 | 1.512 ns | +0.003 ns | PASS |
| 340 MHz | 110 | 6058.752 | 1.470 ns | +0.001 ns | PASS |
| 345 MHz | 105 | 6096.384 | 1.448 ns | +0.001 ns | PASS |
| 350 MHz | 122 | 6319.040 | 1.438 ns | -0.010 ns | FAIL |

## Conclusion

The pre-layout synthesis closure boundary with the actual IO-pad input
capacitance applied to MISO is approximately 345-350 MHz at TT / 25C / 5.0V.

The dominant high-frequency critical path remains the TX bit counter to
MISO output path.

This result includes the core-side input capacitance of the IO pad, but
does not yet include the IO pad I-to-PAD propagation delay, package/PCB
loading, worst-case PVT, routing parasitics, or external FPGA timing.
