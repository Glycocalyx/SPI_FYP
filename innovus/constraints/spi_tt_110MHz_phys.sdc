# ============================================================
# Milestone 6B
# Innovus Physical Timing Constraints
#
# Design:
#   spi_slave_full_io_pad_wrapper
#
# Corner:
#   TT / 5.0 V / 25 C
#
# Reference target:
#   110 MHz
#
# IMPORTANT:
#   Unlike the Genus pre-layout characterization,
#   only the external SCLK clock is created here.
#
#   No manually shifted CORE_SCLK is created.
#   The SCLK input PAD and physical clock network will be
#   handled by the physical implementation flow.
# ============================================================

set_units -time ns
set_units -capacitance pF


# ============================================================
# External SPI clock
# ============================================================

create_clock \
    -name SCLK \
    -period 9.090909 \
    -waveform {0.0 4.545455} \
    [get_ports sclk_pad]


# ============================================================
# External input slew
# ============================================================

set_input_transition 1.0 [get_ports sclk_pad]
set_input_transition 1.0 [get_ports mosi_pad]
set_input_transition 1.0 [get_ports csb_pad]


# ============================================================
# MOSI
#
# Mode 0:
#   Master changes MOSI on falling edge.
#   Slave captures MOSI on rising edge.
#
# External FPGA/PCB delay is still idealized as zero.
# ============================================================

set_input_delay \
    -clock SCLK \
    -clock_fall \
    -max 0.0 \
    [get_ports mosi_pad]

set_input_delay \
    -clock SCLK \
    -clock_fall \
    -min 0.0 \
    [get_ports mosi_pad]


# ============================================================
# MISO
#
# Master samples MISO on external rising SCLK.
#
# External FPGA setup/hold and PCB delay are not yet modeled.
# ============================================================

set_output_delay \
    -clock SCLK \
    -max 0.0 \
    [get_ports miso_pad]

set_output_delay \
    -clock SCLK \
    -min 0.0 \
    [get_ports miso_pad]


# ============================================================
# External MISO capacitive load
# ============================================================

set_load 5.0 [get_ports miso_pad]


# ============================================================
# CSB
#
# CSB asynchronous recovery/removal timing will be checked
# separately after the physical clock/reset networks exist.
# ============================================================
