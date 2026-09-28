# ============================================================
# Milestone 5D
# Fixed-Netlist TT STA Validation
#
# Purpose:
#   Validate the fixed gate-level netlist at TT.
#
# IMPORTANT:
#   No RTL synthesis.
#   No technology remapping.
#   No optimization.
#
# Expected:
#   Reproduce approximately +5 ps MISO slack at 110 MHz.
# ============================================================


# ============================================================
# Configuration
# ============================================================

set RUN_TAG "wc_fixed_70MHz_5pF"

set SCLK_PERIOD 14.285714
set HALF_PERIOD [expr {$SCLK_PERIOD / 2.0}]

# TT SCLK input PAD delays
set SCLK_PAD_RISE_DELAY 0.9916
set SCLK_PAD_FALL_DELAY 1.0115

set CORE_RISE_EDGE $SCLK_PAD_RISE_DELAY
set CORE_FALL_EDGE \
    [expr {$HALF_PERIOD + $SCLK_PAD_FALL_DELAY}]


# ============================================================
# Libraries
# ============================================================

set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2awc.lib"

set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5wc.lib"

set_db library [list $CORE_LIB $IO_LIB]


# ============================================================
# Output directories
# ============================================================

file mkdir reports


# ============================================================
# Load existing gate-level netlist
#
# DO NOT read RTL.
# DO NOT re-synthesize.
# ============================================================

read_hdl -sv \
    outputs/spi_slave_csb_async_110MHz_5pF.v

elaborate spi_slave_full_io_pad_wrapper

check_design -unresolved


# ============================================================
# External SCLK
# ============================================================

create_clock \
    -name EXT_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list 0.0 $HALF_PERIOD]


# ============================================================
# Internal SCLK
#
# Clock after the input PAD.
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
# MOSI timing constraints
#
# Master changes MOSI on the external falling edge.
# Slave samples MOSI on the internal rising edge.
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
# MISO timing constraints
#
# Slave updates MISO on the internal falling edge.
# Master samples MISO on the next external rising edge.
# ============================================================

set_output_delay \
    -clock EXT_SCLK \
    -max 0.0 \
    [get_ports miso_pad]

set_output_delay \
    -clock EXT_SCLK \
    -min 0.0 \
    [get_ports miso_pad]


# ============================================================
# External MISO load
# ============================================================

set_load 5.0 [get_ports miso_pad]


# ============================================================
# NO SYNTHESIS
#
# The following commands are intentionally NOT executed:
#
# syn_generic
# syn_map
# syn_opt
# ============================================================


# ============================================================
# Timing reports
# ============================================================

report_timing \
    > reports/timing_${RUN_TAG}.rpt

report_timing \
    -to [get_ports miso_pad] \
    > reports/timing_miso_${RUN_TAG}.rpt

report_timing \
    -from [get_ports mosi_pad] \
    > reports/timing_mosi_${RUN_TAG}.rpt


# ============================================================
# Net reports
# ============================================================

report_nets \
    -pin u_sclk_pad/C \
    > reports/sclk_core_net_${RUN_TAG}.rpt

report_nets \
    -pin u_csb_pad/C \
    > reports/csb_core_net_${RUN_TAG}.rpt


# ============================================================
# Area report
# ============================================================

report_area \
    > reports/area_${RUN_TAG}.rpt


# ============================================================
# Completion
# ============================================================

puts "========================================"
puts "Fixed-Netlist TT STA Completed"
puts "========================================"

puts "Netlist:"
puts "  spi_slave_csb_async_110MHz_5pF.v"

puts "Corner:"
puts "  WC / 4.5 V / 125 C"

puts "SCLK:"
puts "  110 MHz"

puts "MISO external load:"
puts "  5 pF"

puts "Reports:"
puts "  reports/timing_miso_${RUN_TAG}.rpt"
puts "  reports/sclk_core_net_${RUN_TAG}.rpt"

puts "========================================"
