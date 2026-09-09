# ============================================================
# SPI Slave - Genus Synthesis Script
#
# Current configuration:
#   DATA_WIDTH  = 16
#   SCLK        = 100 MHz
#   Period      = 10 ns
#   Corner      = TT / 25C / 5.0V
#
# Run from:
#   ~/spi-fyp/syn
#
# Command:
#   genus -no_gui -f run.tcl
# ============================================================


# ============================================================
# 0. Run configuration
# ============================================================

set SCLK_PERIOD 2.667
set RUN_TAG "375MHz"


# ============================================================
# 1. Create output directories
# ============================================================

file mkdir reports
file mkdir outputs


# ============================================================
# 2. Technology library
#
# TSMC 180nm HV BCD
# Typical corner:
#   Process     = TT
#   Temperature = 25 C
#   Voltage     = 5.0 V
# ============================================================

set_db library \
/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib


# ============================================================
# 3. Read RTL
#
# Only synthesize the final SPI Slave.
# spi_master.sv and testbenches are verification-only.
# ============================================================

read_hdl -sv ../rtl/spi_slave.sv


# ============================================================
# 4. Elaborate design
#
# spi_slave default DATA_WIDTH = 16
# ============================================================

elaborate spi_slave


# ============================================================
# 5. Basic design check
# ============================================================

check_design -unresolved


# ============================================================
# 6. Clock constraint
#
# 100 MHz:
#   Period = 10 ns
#
# SPI Mode 0:
#   Rising edge  = sample
#   Falling edge = data update
#
# Default waveform is 50% duty cycle.
# Therefore:
#
#   posedge = 0 ns
#   negedge = 5 ns
#   posedge = 10 ns
# ============================================================

create_clock \
    -name SCLK \
    -period $SCLK_PERIOD \
    [get_ports sclk]


# ============================================================
# 7. Core-level I/O timing baseline
#
# These are currently IDEAL assumptions.
#
# They are NOT final FPGA / PCB / IO-pad specifications.
#
# MOSI:
#   sampled by the Slave on SCLK rising edge.
#
# MISO:
#   produced by the Slave and sampled by the external Master.
# ============================================================

set_input_delay \
    -clock SCLK \
    0.0 \
    [get_ports mosi]

set_output_delay \
    -clock SCLK \
    0.0 \
    [get_ports miso]


# ============================================================
# 8. Timing-intent check
#
# Warnings are currently expected for:
#
#   csb_n
#   tx_data[15:0]
#   miso_oe
#   rx_data[15:0]
#   rx_valid
#
# because their final external timing environment has not yet
# been defined.
# ============================================================

check_timing_intent


# ============================================================
# 9. Synthesis
# ============================================================

syn_generic
syn_map
syn_opt


# ============================================================
# 10. Reports
# ============================================================

report_area \
    > reports/area_${RUN_TAG}.rpt

report_timing \
    > reports/timing_${RUN_TAG}.rpt


# ============================================================
# 11. Write synthesized gate-level netlist
# ============================================================

write_hdl \
    > outputs/spi_slave_${RUN_TAG}.v


# ============================================================
# 12. Write SDC constraints
# ============================================================

write_sdc \
    > outputs/spi_slave_${RUN_TAG}.sdc


# ============================================================
# 13. Completion message
# ============================================================

puts ""
puts "============================================================"
puts " SPI Slave Genus synthesis completed"
puts " RUN_TAG     = ${RUN_TAG}"
puts " SCLK_PERIOD = ${SCLK_PERIOD} ns"
puts "============================================================"
puts ""
puts "Reports:"
puts "  reports/area_${RUN_TAG}.rpt"
puts "  reports/timing_${RUN_TAG}.rpt"
puts ""
puts "Outputs:"
puts "  outputs/spi_slave_${RUN_TAG}.v"
puts "  outputs/spi_slave_${RUN_TAG}.sdc"
puts "============================================================"
puts ""
