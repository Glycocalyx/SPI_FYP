# Milestone 5B
#
# SPI Slave with:
#   - real SCLK input PAD
#   - real MOSI input PAD
#   - real CSB input PAD
#   - real MISO output PAD
#
# CSB is physically integrated through an input PAD.
# It remains intentionally unconstrained for synchronous timing;
# asynchronous recovery/removal analysis is deferred to Milestone 5C.
#
# Technology:
#   TSMC 180nm HV BCD
#
# Corner:
#   TT / 25C / 5V
#
# SPI:
#   DATA_WIDTH = 16
#   Mode 0
#   MSB first
#
# Frequency:
#   110 MHz
#
# External assumptions:
#   SCLK slew = 1.0 ns
#   MOSI slew = 1.0 ns
#   MISO load = 5.0 pF
#
# SCLK PAD delay derived from actual mapped SCLK load:
#   rise load = 122.5 fF
#   fall load = 120.5 fF
#
#   PAD->C rise = 0.6738 ns
#   PAD->C fall = 0.7487 ns
# ============================================================


# ============================================================
# Configuration
# ============================================================

set SCLK_PERIOD 9.090909
set HALF_PERIOD [expr {$SCLK_PERIOD / 2.0}]

set RUN_TAG "csb_async_110MHz_5pF"

set SCLK_PAD_RISE_DELAY 0.6738
set SCLK_PAD_FALL_DELAY 0.7487

set CORE_RISE_EDGE $SCLK_PAD_RISE_DELAY
set CORE_FALL_EDGE [expr {$HALF_PERIOD + $SCLK_PAD_FALL_DELAY}]


# ============================================================
# Libraries
# ============================================================

set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"

set_db library [list $CORE_LIB $IO_LIB]


# ============================================================
# Directories
# ============================================================

file mkdir reports
file mkdir outputs


# ============================================================
# RTL
# ============================================================

read_hdl -sv ../rtl/spi_slave.sv
read_hdl -sv ../rtl/spi_slave_full_io_pad_wrapper.sv

elaborate spi_slave_full_io_pad_wrapper

check_design -unresolved


# ============================================================
# External SCLK
#
# Clock at the ASIC external boundary.
# ============================================================

create_clock \
    -name EXT_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list 0.0 $HALF_PERIOD]


# ============================================================
# Internal SCLK
#
# Clock after the SCLK input PAD.
# ============================================================

create_clock \
    -name CORE_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list $CORE_RISE_EDGE $CORE_FALL_EDGE] \
    [get_pins u_sclk_pad/C]


# ============================================================
# External input transition
# ============================================================

set_input_transition 1.0 [get_ports sclk_pad]
set_input_transition 1.0 [get_ports mosi_pad]
set_input_transition 1.0 [get_ports csb_pad]

# ============================================================
# MOSI timing
#
# SPI Mode 0:
#
# FPGA changes MOSI on the external SCLK falling edge.
#
# ASIC samples MOSI on the internal SCLK rising edge.
#
# Therefore MOSI is referenced to the FALLING edge of EXT_SCLK.
#
# The 0 ns input delay is currently an idealized boundary
# assumption:
#
#   FPGA tCO = 0
#   PCB delay/skew = 0
#
# These will be refined later.
# ============================================================

set_input_delay \
    -clock EXT_SCLK \
    -clock_fall \
    -max 0.0 \
    [get_ports mosi_pad]

set_input_delay \
    -clock EXT_SCLK \
    -clock_fall \
    -min 0.0 \
    [get_ports mosi_pad]


# ============================================================
# MISO timing
#
# Same model as Milestone 4.
#
# Core changes MISO after CORE_SCLK falling edge.
# External FPGA samples on EXT_SCLK rising edge.
# ============================================================

set_output_delay \
    -clock EXT_SCLK \
    0.0 \
    [get_ports miso_pad]

set_load 5.0 [get_ports miso_pad]


# ============================================================
# Timing intent
#
# CSB remains intentionally unconstrained in Milestone 5A.
# A warning associated with CSB may therefore appear.
# ============================================================

check_timing_intent


# ============================================================
# Synthesis
# ============================================================

syn_generic
syn_map
syn_opt


# ============================================================
# Net-load diagnostics
# ============================================================

report_nets \
    -pin u_sclk_pad/C \
    > reports/sclk_core_net_${RUN_TAG}.rpt

report_nets \
    -pin u_mosi_pad/C \
    > reports/mosi_core_net_${RUN_TAG}.rpt

report_nets \
    -pin u_csb_pad/C \
    > reports/csb_core_net_${RUN_TAG}.rpt

report_nets \
    -pin g4626/ZN \
    > reports/csb_reset_net_${RUN_TAG}.rpt

report_nets \
    -pin g1768/ZN \
    > reports/tx_clock_net_${RUN_TAG}.rpt

# ============================================================
# Reports
# ============================================================

report_area \
    > reports/area_${RUN_TAG}.rpt

report_timing \
    > reports/timing_${RUN_TAG}.rpt

report_timing \
    -to [get_ports miso_pad] \
    > reports/timing_miso_${RUN_TAG}.rpt

# MOSI input setup path
report_timing \
    -from [get_ports mosi_pad] \
    > reports/timing_mosi_${RUN_TAG}.rpt

report_timing \
    -unconstrained \
    -from [get_ports csb_pad] \
    -to [get_pins u_spi_slave_rx_valid_reg/CDN] \
    > reports/timing_csb_to_cdn_${RUN_TAG}.rpt

# ============================================================
# CSB -> MISO asynchronous paths
#
# CSB intentionally has no normal synchronous input-delay
# constraint, therefore these paths are unconstrained.
# Use -unconstrained explicitly when reporting them.
# ============================================================

# CSB -> MISO output-enable -> external PAD
report_timing \
    -unconstrained \
    -from [get_ports csb_pad] \
    -through [get_pins u_miso_pad/OEN] \
    -to [get_ports miso_pad] \
    > reports/timing_csb_to_miso_oen_${RUN_TAG}.rpt

# CSB -> MISO data input -> external PAD
report_timing \
    -unconstrained \
    -from [get_ports csb_pad] \
    -through [get_pins u_miso_pad/I] \
    -to [get_ports miso_pad] \
    > reports/timing_csb_to_miso_data_${RUN_TAG}.rpt

# CSB assertion -> external MISO rising transition
report_timing \
    -unconstrained \
    -from_fall [get_ports csb_pad] \
    -to_rise [get_ports miso_pad] \
    > reports/timing_csb_to_miso_rise_${RUN_TAG}.rpt

# CSB assertion -> external MISO falling transition
report_timing \
    -unconstrained \
    -from_fall [get_ports csb_pad] \
    -to_fall [get_ports miso_pad] \
    > reports/timing_csb_to_miso_fall_${RUN_TAG}.rpt

# CSB deassertion -> MISO High-Z / output disable
report_timing \
    -unconstrained \
    -from_rise [get_ports csb_pad] \
    -through_rise [get_pins u_miso_pad/OEN] \
    -to [get_ports miso_pad] \
    -max_paths 10 \
    > reports/timing_csb_disable_miso_${RUN_TAG}.rpt

# Overall CSB -> external MISO path
report_timing \
    -unconstrained \
    -from [get_ports csb_pad] \
    -to [get_ports miso_pad] \
    -max_paths 10 \
    > reports/timing_csb_to_miso_pad_${RUN_TAG}.rpt

# ============================================================
# Outputs
# ============================================================

write_hdl \
    > outputs/spi_slave_${RUN_TAG}.v

write_sdc \
    > outputs/spi_slave_${RUN_TAG}.sdc


# ============================================================
# Summary
# ============================================================

puts ""
puts "============================================================"
puts "MILESTONE 5B COMPLETED"
puts ""
puts "Run tag:"
puts "  $RUN_TAG"
puts ""
puts "External SCLK period:"
puts "  $SCLK_PERIOD ns"
puts ""
puts "CORE_SCLK rise:"
puts "  $CORE_RISE_EDGE ns"
puts ""
puts "CORE_SCLK fall:"
puts "  $CORE_FALL_EDGE ns"
puts ""
puts "Reports:"
puts "  reports/timing_miso_${RUN_TAG}.rpt"
puts "  reports/timing_mosi_${RUN_TAG}.rpt"
puts "  reports/sclk_core_net_${RUN_TAG}.rpt"
puts "  reports/mosi_core_net_${RUN_TAG}.rpt"
puts "  reports/csb_core_net_${RUN_TAG}.rpt"
puts "============================================================"
puts ""

