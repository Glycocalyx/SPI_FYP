# ============================================================
# 16-bit SPI Slave + Real MISO IO Pad
# Milestone 3
#
# Core library:
#   TSMC 180nm HV BCD standard cells
#
# IO library:
#   tps018bcdnv5
#
# MISO pad:
#   PDDW0208CSG
#
# Current experiment:
#   TT / 25C / 5V
#   PAD_DS = 1
#   External MISO PAD load = 5 pF
# ============================================================

# ------------------------------------------------------------
# Experiment configuration
# ------------------------------------------------------------

set SCLK_PERIOD 7.692308
set RUN_TAG "miso_pad_130MHz_5pF"

set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"

# ------------------------------------------------------------
# Output directories
# ------------------------------------------------------------

file mkdir reports
file mkdir outputs

# ------------------------------------------------------------
# Libraries
# ------------------------------------------------------------

set_db library [list $CORE_LIB $IO_LIB]

# ------------------------------------------------------------
# RTL
# ------------------------------------------------------------

read_hdl -sv ../rtl/spi_slave.sv
read_hdl -sv ../rtl/spi_slave_miso_pad_wrapper.sv

elaborate spi_slave_miso_pad_wrapper

check_design -unresolved

# ------------------------------------------------------------
# Timing constraints
# ------------------------------------------------------------

create_clock \
    -name SCLK \
    -period $SCLK_PERIOD \
    [get_ports sclk]

# For now MOSI still enters directly at core level.
# Input-pad timing will be added in a later milestone.
set_input_delay \
    -clock SCLK \
    0.0 \
    [get_ports mosi]

# External timing requirement is currently ideal.
set_output_delay \
    -clock SCLK \
    0.0 \
    [get_ports miso_pad]

# Real external load on the physical MISO PAD.
#
# IO Liberty characterization range starts at 5 pF,
# so 5 pF is used as the first PDK-characterized baseline.
set_load 5.0 [get_ports miso_pad]

check_timing_intent

# ------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------

syn_generic
syn_map
syn_opt

# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------

report_area \
    > reports/area_${RUN_TAG}.rpt

report_timing \
    > reports/timing_${RUN_TAG}.rpt

# ------------------------------------------------------------
# Outputs
# ------------------------------------------------------------

write_hdl \
    > outputs/spi_slave_${RUN_TAG}.v

write_sdc \
    > outputs/spi_slave_${RUN_TAG}.sdc

puts "============================================================"
puts "Completed: $RUN_TAG"
puts "SCLK period: $SCLK_PERIOD ns"
puts "External MISO PAD load: 5 pF"
puts "============================================================"
