# ============================================================
# 61 pF Fixed-Netlist Fmax Characterization
#
# Environment variables:
#
#   CORNER    = tt | wc | bc | lt
#   FREQ_MHZ  = test frequency in MHz
#
# Example:
#
#   setenv CORNER tt
#   setenv FREQ_MHZ 67
#   genus -no_gui -f run_61pF_fmax.tcl
#
# IMPORTANT:
#   - Fixed existing gate-level netlist
#   - 61 pF MISO external load
#   - No re-synthesis
#   - No remapping
#   - No optimization
# ============================================================


# ============================================================
# Read environment variables
# ============================================================

if {![info exists ::env(CORNER)]} {
    error "CORNER is not set. Use tt|wc|bc|lt."
}

if {![info exists ::env(FREQ_MHZ)]} {
    error "FREQ_MHZ is not set."
}

set CORNER [string tolower $::env(CORNER)]
set FREQ_MHZ [expr {double($::env(FREQ_MHZ))}]


# ============================================================
# Clock / load
# ============================================================

# MHz -> ns
set SCLK_PERIOD [expr {1000.0 / $FREQ_MHZ}]
set HALF_PERIOD [expr {$SCLK_PERIOD / 2.0}]

set MISO_LOAD 61.0


# ============================================================
# Corner configuration
# ============================================================

switch -exact -- $CORNER {

    tt {
        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"

        set SCLK_PAD_RISE_DELAY 0.6738
        set SCLK_PAD_FALL_DELAY 0.7487
    }

    wc {
        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2awc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5wc.lib"

        set SCLK_PAD_RISE_DELAY 0.9816
        set SCLK_PAD_FALL_DELAY 1.0115
    }

    bc {
        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2abc.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5bc.lib"

        set SCLK_PAD_RISE_DELAY 0.5494
        set SCLK_PAD_FALL_DELAY 0.6391
    }

    lt {
        set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2alt.lib"

        set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5lt.lib"

        set SCLK_PAD_RISE_DELAY 0.5151
        set SCLK_PAD_FALL_DELAY 0.6104
    }

    default {
        error "Unsupported CORNER=$CORNER"
    }
}


# ============================================================
# Run tag
# ============================================================

set FREQ_TAG [string map {. _} $FREQ_MHZ]

set RUN_TAG \
    "${CORNER}_fixed_${FREQ_TAG}MHz_61pF"


# ============================================================
# Libraries
# ============================================================

set_db library [list $CORE_LIB $IO_LIB]


# ============================================================
# Output directory
# ============================================================

set REPORT_DIR "results/multicorner_61pF_fmax"
file mkdir $REPORT_DIR


# ============================================================
# Read existing fixed gate-level netlist
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
# Internal SCLK after SCLK PAD
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
# Input transitions
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
# MISO external load
# ============================================================

set_load $MISO_LOAD [get_ports miso_pad]


# ============================================================
# NO SYNTHESIS
# ============================================================

# No:
# syn_generic
# syn_map
# syn_opt


# ============================================================
# Reports
# ============================================================

report_timing \
    -to [get_ports miso_pad] \
    > ${REPORT_DIR}/timing_miso_${RUN_TAG}.rpt

report_timing \
    > ${REPORT_DIR}/timing_${RUN_TAG}.rpt


# ============================================================
# Completion
# ============================================================

puts ""
puts "============================================================"
puts "61 pF Fmax Test Completed"
puts "============================================================"
puts "Corner:          $CORNER"
puts "Frequency:       $FREQ_MHZ MHz"
puts "Period:          $SCLK_PERIOD ns"
puts "MISO load:       $MISO_LOAD pF"
puts ""
puts "Report:"
puts "  ${REPORT_DIR}/timing_miso_${RUN_TAG}.rpt"
puts "============================================================"
puts ""

exit
