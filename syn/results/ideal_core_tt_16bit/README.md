# 16-bit SPI Slave - Ideal Core Genus Sweep

## Configuration

- Technology: TSMC 180nm HV BCD
- Standard-cell library: tcb018bcdgp2atc
- Corner: TT / 25C / 5.0V
- DATA_WIDTH: 16 bit
- SPI Mode: Mode 0
- Bit order: MSB first
- I/O assumption: ideal core-level timing
- MOSI input delay: 0 ns
- MISO output delay: 0 ns
- MISO output load: 0 pF
- Pre-layout synthesis: Cadence Genus 21.14

## Results

| SCLK | Cell Count | Cell Area | Worst Path | Slack | Result |
| --- | ---: | ---: | --- | ---: | --- |
| 50 MHz | 80 | 5190.080 | TX counter -> MISO | +8.054 ns | PASS |
| 100 MHz | 80 | 5186.944 | TX counter -> MISO | +3.185 ns | PASS |
| 150 MHz | 80 | 5190.080 | TX counter -> MISO | +1.580 ns | PASS |
| 200 MHz | 80 | 5202.624 | TX counter -> MISO | +0.752 ns | PASS |
| 250 MHz | 81 | 5205.760 | RX control | +0.166 ns | PASS |
| 260 MHz | 81 | 5205.760 | RX control | +0.012 ns | PASS |
| 262 MHz | 84 | 5262.208 | TX counter -> MISO | +0.191 ns | PASS |
| 280 MHz | 81 | 5221.440 | TX counter -> MISO | +0.098 ns | PASS |
| 300 MHz | 83 | 5255.936 | TX counter -> MISO | +0.015 ns | PASS |
| 350 MHz | 90 | 5569.536 | TX counter -> MISO | +0.002 ns | PASS |
| 360 MHz | 93 | 5644.800 | TX counter -> MISO | +0.002 ns | PASS |
| 375 MHz | 99 | 5732.608 | TX counter -> MISO | 0 ns | PASS boundary |
| 380 MHz | 101 | 5880.000 | TX counter -> MISO | -0.011 ns | FAIL |

## Conclusion

The ideal core-level pre-layout synthesis limit is approximately 375 MHz.

The dominant high-frequency critical path is the falling-edge TX bit counter to MISO output path.

This is an optimistic core-only result and does not include realistic pad load, IO pad delay, routing parasitics, worst-case PVT, or external FPGA/PCB timing.
