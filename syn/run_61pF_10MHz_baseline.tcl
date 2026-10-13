# ============================================================
# 61 pF / 10 MHz Fixed-Netlist Baseline STA
#
# Purpose:
#   Evaluate the existing synthesized SPI Slave implementation
#   under the newly specified 61 pF external MISO load.
#
# Corners:
#   TT / WC / BC / LT
#
# IMPORTANT:
#   - No RTL synthesis
#   - No technology remapping
#   - No optimization
#   - No output buffer insertion
#
# This is a controlled baseline experiment.
# ============================================================


# ============================================================
# Select corner from shell environment
#
# Example:
#   setenv CORNER tt
#   genus -no_gui -f run_61pF_10MHz_baseline.tcl
# ============================================================

if {![info exists ::env(CORNER)]} {
    error "CORNER is not set. Use: setenv CORNER tt|wc|bc|lt"
}

set CORNER [string tolower $::env(CORNER)]


# ============================================================
# Common timing configuration
# ============================================================

# 10 MHz SPI clock
set SCLK_PERIOD 100.0
set HALF_PERIOD [expr {$SCLK_PERIOD / 2.0}]

# Final external oscilloscope/probe load on MISO
set MISO_LOAD 61.0


# ============================================================
# Corner-specific libraries and SCLK input-PAD delays
# ============================================================

switch -exact -- $CORNER {

    tt {
        set RUN_TAG "tt_fixed_10MHz_61pF"

        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"

        set SCLK_PAD_RISE_DELAY 0.6738
        set SCLK_PAD_FALL_DELAY 0.7487
    }

    wc {
        set RUN_TAG "wc_fixed_10MHz_61pF"

        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2awc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5wc.lib"

        set SCLK_PAD_RISE_DELAY 0.9816
        set SCLK_PAD_FALL_DELAY 1.0115
    }

    bc {
        set RUN_TAG "bc_fixed_10MHz_61pF"

        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2abc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5bc.lib"

        set SCLK_PAD_RISE_DELAY 0.5494
        set SCLK_PAD_FALL_DELAY 0.6391
    }

    lt {
        set RUN_TAG "lt_fixed_10MHz_61pF"

        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2alt.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5lt.lib"

        set SCLK_PAD_RISE_DELAY 0.5151
        set SCLK_PAD_FALL_DELAY 0.6104
    }

    default {
        error "Unsupported CORNER=$CORNER. Use tt, wc, bc, or lt."
    }
}


# ============================================================
# Library setup
# ============================================================

set_db library [list $CORE_LIB $IO_LIB]


# ============================================================
# Report directory
# ============================================================

set REPORT_DIR "results/multicorner_61pF_10MHz_baseline"
file mkdir $REPORT_DIR


# ============================================================
# Load existing gate-level netlist
#
# Keep the original synthesized netlist fixed.
# Only the external MISO load is changed to 61 pF.
# ============================================================

read_hdl -sv outputs/spi_slave_csb_async_110MHz_5pF.v

elaborate spi_slave_full_io_pad_wrapper

check_design -unresolved


# ============================================================
# External SPI clock
# ============================================================

create_clock \
    -name EXT_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list 0.0 $HALF_PERIOD]


# ============================================================
# Internal clock after SCLK input PAD
# ============================================================

set CORE_RISE_EDGE $SCLK_PAD_RISE_DELAY

set CORE_FALL_EDGE \
    [expr {$HALF_PERIOD + $SCLK_PAD_FALL_DELAY}]

create_clock \
    -name CORE_SCLK \
    -period $SCLK_PERIOD \
    -waveform [list $CORE_RISE_EDGE $CORE_FALL_EDGE] \
    [get_pins u_sclk_pad/C]


# ============================================================
# External input transitions
# ============================================================

set_input_transition 1.0 [get_ports sclk_pad]
set_input_transition 1.0 [get_ports mosi_pad]
set_input_transition 1.0 [get_ports csb_pad]


# ============================================================
# MOSI timing
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
# Final external MISO load
#
# Liberty output-load table:
#   5, 10, 25, 40, 70, 100 pF
#
# 61 pF is therefore interpolated between 40 and 70 pF.
# ============================================================

set_load $MISO_LOAD [get_ports miso_pad]


# ============================================================
# NO SYNTHESIS
# ============================================================

# Intentionally NOT executed:
#
# syn_generic
# syn_map
# syn_opt


# ============================================================
# Timing reports
# ============================================================

report_timing \
    > ${REPORT_DIR}/timing_${RUN_TAG}.rpt

report_timing \
    -to [get_ports miso_pad] \
    > ${REPORT_DIR}/timing_miso_${RUN_TAG}.rpt

report_timing \
    -from [get_ports mosi_pad] \
    > ${REPORT_DIR}/timing_mosi_${RUN_TAG}.rpt


# ============================================================
# Net reports
# ============================================================

report_nets \
    -pin u_sclk_pad/C \
    > ${REPORT_DIR}/sclk_core_net_${RUN_TAG}.rpt

report_nets \
    -pin u_miso_pad/I \
    > ${REPORT_DIR}/miso_pad_input_net_${RUN_TAG}.rpt

report_nets \
    -pin u_miso_pad/PAD \
    > ${REPORT_DIR}/miso_pad_output_net_${RUN_TAG}.rpt


# ============================================================
# Area report
# ============================================================

report_area \
    > ${REPORT_DIR}/area_${RUN_TAG}.rpt


# ============================================================
# Completion
# ============================================================

puts ""
puts "============================================================"
puts "61 pF / 10 MHz Fixed-Netlist Baseline Completed"
puts "============================================================"
puts "Corner:             $CORNER"
puts "Clock period:       $SCLK_PERIOD ns"
puts "SPI frequency:      10 MHz"
puts "MISO load:          $MISO_LOAD pF"
puts "SCLK PAD rise:      $SCLK_PAD_RISE_DELAY ns"
puts "SCLK PAD fall:      $SCLK_PAD_FALL_DELAY ns"
puts ""
puts "Netlist:"
puts "  outputs/spi_slave_csb_async_110MHz_5pF.v"
puts ""
puts "Key report:"
puts "  ${REPORT_DIR}/timing_miso_${RUN_TAG}.rpt"
puts "============================================================"
puts ""

exit
