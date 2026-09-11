# ============================================================
# Milestone 4
# 16-bit SPI Slave
# + SCLK Input PAD
# + MISO Output PAD
#
# Technology:
#   TSMC 180nm HV BCD
#
# Core library:
#   tcb018bcdgp2atc
#
# IO library:
#   tps018bcdnv5tc
#
# IO cell:
#   PDDW0208CSG
#
# Current baseline:
#   TT / 25C / 5V
#   SCLK = 100 MHz
#   MISO external load = 5 pF
#   SCLK external input slew assumption = 1.0 ns
#
# SCLK PAD timing assumption derived from TT Liberty:
#   PAD -> C rising delay  = 0.6472 ns
#   PAD -> C falling delay = 0.7183 ns
#
# These values correspond to:
#   input slew = 1.0 ns
#   core-side load = 0.12 pF
#
# Timing model:
#
#   EXT_SCLK
#      |
#      | external SCLK timing reference
#      |
#      +------------------------------+
#                                     |
#                                     | next external rising edge
#                                     | used as MISO deadline
#                                     |
#   CORE_SCLK                         |
#      |                              |
#      | delayed by SCLK input PAD    |
#      v                              |
#   SPI core                          |
#      |                              |
#      v                              |
#   MISO output PAD ------------------+
#
# NOTE:
# This is a pre-layout timing abstraction.
# The SCLK PAD delay is represented by shifting the waveform of
# CORE_SCLK relative to EXT_SCLK.
# ============================================================


# ============================================================
# 1. Experiment configuration
# ============================================================

set SCLK_PERIOD 9.090909
set RUN_TAG "sclk_miso_pad_110MHz_5pF_actual_load"

set HALF_PERIOD [expr {$SCLK_PERIOD / 2.0}]

# SCLK input PAD delays from PDDW0208CSG TT Liberty.
set SCLK_PAD_RISE_DELAY 0.6738
set SCLK_PAD_FALL_DELAY 0.7487

# Internal clock waveform after the SCLK input PAD.
set CORE_RISE_EDGE $SCLK_PAD_RISE_DELAY
set CORE_FALL_EDGE [expr {$HALF_PERIOD + $SCLK_PAD_FALL_DELAY}]


# ============================================================
# 2. Library paths
# ============================================================

set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"


# ============================================================
# 3. Output directories
# ============================================================

file mkdir reports
file mkdir outputs


# ============================================================
# 4. Load libraries
# ============================================================

set_db library [list $CORE_LIB $IO_LIB]


# ============================================================
# 5. Read RTL
# ============================================================

read_hdl -sv ../rtl/spi_slave.sv
read_hdl -sv ../rtl/spi_slave_sclk_miso_pad_wrapper.sv


# ============================================================
# 6. Elaborate top
# ============================================================

elaborate spi_slave_sclk_miso_pad_wrapper

check_design -unresolved


# ============================================================
# 7. Clock constraints
# ============================================================

# ------------------------------------------------------------
# EXT_SCLK
#
# Virtual external reference clock.
#
# At 100 MHz:
#   rising edge  = 0.000 ns
#   falling edge = 5.000 ns
#
# This represents the clock timing seen at the external
# FPGA / ASIC interface.
# ------------------------------------------------------------

create_clock \
    -name EXT_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list 0.0 $HALF_PERIOD]


# ------------------------------------------------------------
# CORE_SCLK
#
# Internal SPI clock after the SCLK input PAD.
#
# At 100 MHz:
#   external rising edge  = 0.000 ns
#   internal rising edge  = 0.6472 ns
#
#   external falling edge = 5.000 ns
#   internal falling edge = 5.7183 ns
#
# CORE_SCLK is attached directly to the C pin of the
# SCLK input PAD.
# ------------------------------------------------------------

create_clock \
    -name CORE_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list $CORE_RISE_EDGE $CORE_FALL_EDGE] \
    [get_pins u_sclk_pad/C]


# ============================================================
# 8. External SCLK electrical assumption
# ============================================================

# Representative external SCLK input slew.
#
# The PAD->C delay values above were selected from the IO
# Liberty table using 1.0 ns input slew and 0.1 pF core load.
#
# This is a PDK-characterized baseline, not yet a specific
# FPGA/PCB timing specification.

set_input_transition 1.0 [get_ports sclk_pad]


# ============================================================
# 9. Input timing constraints
# ============================================================

# MOSI does NOT yet have its own input PAD in this milestone.
# Therefore it still enters the SPI core directly.
#
# Use CORE_SCLK because MOSI is sampled internally by the SPI
# slave after the SCLK input PAD.

set_input_delay \
    -clock CORE_SCLK \
    0.0 \
    [get_ports mosi]


# tx_data, csb_n, rx_data, rx_valid, etc. are intentionally
# not fully constrained yet because their final system-level
# interface timing has not been defined.


# ============================================================
# 10. MISO external timing constraint
# ============================================================

# MISO is evaluated relative to the EXTERNAL clock.
#
# This is the key reason for having EXT_SCLK and CORE_SCLK
# separately:
#
#   launch:
#       delayed CORE_SCLK falling edge
#
#   deadline:
#       next EXT_SCLK rising edge
#
# For now FPGA setup time is assumed to be 0 ns.
# A real FPGA setup requirement will be added later.

set_output_delay \
    -clock EXT_SCLK \
    0.0 \
    [get_ports miso_pad]


# ============================================================
# 11. MISO external load
# ============================================================

# 5 pF is the first characterized output-load point in the
# PDDW0208CSG IO timing table.
#
# Genus will additionally account for the PAD pin's intrinsic
# capacitance from the IO Liberty library.

set_load 5.0 [get_ports miso_pad]


# ============================================================
# 12. Timing checks before synthesis
# ============================================================

check_timing_intent


# ============================================================
# 13. Synthesis
# ============================================================

syn_generic
syn_map
syn_opt

# ============================================================
# SCLK core-net load report
# ============================================================

report_nets \
    -pin u_sclk_pad/C \
    > reports/sclk_core_net_${RUN_TAG}.rpt

# ============================================================
# 14. Reports
# ============================================================

report_area \
    > reports/area_${RUN_TAG}.rpt

# Overall worst timing path.
report_timing \
    > reports/timing_${RUN_TAG}.rpt

# Additional MISO-specific timing report.
report_timing \
    -to [get_ports miso_pad] \
    > reports/timing_miso_${RUN_TAG}.rpt


# ============================================================
# 15. Synthesized outputs
# ============================================================

write_hdl \
    > outputs/spi_slave_${RUN_TAG}.v

write_sdc \
    > outputs/spi_slave_${RUN_TAG}.sdc


# ============================================================
# 16. Completion summary
# ============================================================

puts ""
puts "============================================================"
puts "SYNTHESIS COMPLETED"
puts ""
puts "Run tag:"
puts "  $RUN_TAG"
puts ""
puts "SCLK period:"
puts "  $SCLK_PERIOD ns"
puts ""
puts "External clock waveform:"
puts "  EXT rise = 0.0000 ns"
puts "  EXT fall = $HALF_PERIOD ns"
puts ""
puts "Internal clock waveform:"
puts "  CORE rise = $CORE_RISE_EDGE ns"
puts "  CORE fall = $CORE_FALL_EDGE ns"
puts ""
puts "SCLK PAD model:"
puts "  PAD->C rise delay = $SCLK_PAD_RISE_DELAY ns"
puts "  PAD->C fall delay = $SCLK_PAD_FALL_DELAY ns"
puts ""
puts "MISO external load:"
puts "  5.0 pF"
puts ""
puts "Reports:"
puts "  reports/area_${RUN_TAG}.rpt"
puts "  reports/timing_${RUN_TAG}.rpt"
puts "  reports/timing_miso_${RUN_TAG}.rpt"
puts ""
puts "Outputs:"
puts "  outputs/spi_slave_${RUN_TAG}.v"
puts "  outputs/spi_slave_${RUN_TAG}.sdc"
puts "============================================================"
puts ""

