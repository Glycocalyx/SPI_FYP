# 16-bit SPI Slave - Real MISO IO Pad Timing

## Configuration

- Technology: TSMC 180nm HV BCD
- Core library: tcb018bcdgp2atc
- IO library: tps018bcdnv5tc
- Corner: TT / 25C / 5.0V
- DATA_WIDTH: 16 bit
- SPI Mode: Mode 0
- Bit order: MSB first
- MISO IO pad: PDDW0208CSG
- PAD_DS: 1
- External MISO load: 5 pF
- Pre-layout synthesis: Cadence Genus 21.14

Only the MISO output pad is included in this milestone.
SCLK, MOSI, and CSB still connect directly to the SPI core.

## Results

| SCLK | Cell Count | Cell Area | Data Path | Slack | Result |
| --- | ---: | ---: | ---: | ---: | --- |
| 100 MHz | 87 | 5293.568 | 4.424 ns | +0.576 ns | PASS |
| 110 MHz | 88 | 5312.384 | 4.404 ns | +0.142 ns | PASS |
| 120 MHz | 89 | 5444.096 | 4.127 ns | +0.040 ns | PASS |
| 130 MHz | 95 | 5594.624 | 3.845 ns | +0.001 ns | PASS boundary |

## Timing Observation

At 130 MHz, the critical path remains the TX bit counter to external MISO path.

Approximate path breakdown:

- SPI core logic: ~1.38 ns
- PDDW0208CSG I-to-PAD delay: ~2.46 ns
- Total critical path: ~3.85 ns

The IO pad contributes the majority of the critical-path delay.

## Conclusion

Under TT / 25C / 5.0V with a 5 pF external MISO load, 130 MHz is
approximately the pre-layout timing-closure edge for the current
MISO-pad-aware model.

This is not the final guaranteed SPI operating frequency.

The current model does not yet include:

- SCLK input pad delay
- MOSI / CSB input pad delay
- post-route parasitics
- worst-case PVT
- clock uncertainty
- package / PCB delay
- external FPGA timing requirements
