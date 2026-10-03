# ============================================================
# Milestone 6B
# TT MMMC Setup
#
# Technology:
#   TSMC 180 nm BCD
#   6LM
#
# Timing:
#   TT / 5.0 V / 25 C
# ============================================================


# ============================================================
# Timing libraries
# ============================================================

set CORE_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb018bcdgp2a_110a/tcb018bcdgp2atc.lib"

set IO_LIB "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/IO/tps018bcdnv5_113a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tps018bcdnv5_160b/tps018bcdnv5tc.lib"


# ============================================================
# RC model
# ============================================================

set CAP_TABLE "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/lef/tcb018bcdgp2a_110a/techfiles/captable/t018lo_1p6m_typical.captable"


# ============================================================
# Library set
# ============================================================

create_library_set \
    -name LIB_TT \
    -timing [list $CORE_LIB $IO_LIB]


# ============================================================
# RC corner
# ============================================================

create_rc_corner \
    -name RC_TT \
    -cap_table $CAP_TABLE


# ============================================================
# Delay corner
# ============================================================

create_delay_corner \
    -name DELAY_TT \
    -library_set LIB_TT \
    -rc_corner RC_TT


# ============================================================
# Constraint mode
# ============================================================

create_constraint_mode \
    -name CONSTRAINT_SPI \
    -sdc_files [list constraints/spi_tt_110MHz_phys.sdc]


# ============================================================
# Analysis view
# ============================================================

create_analysis_view \
    -name VIEW_TT \
    -constraint_mode CONSTRAINT_SPI \
    -delay_corner DELAY_TT


set_analysis_view \
    -setup [list VIEW_TT] \
    -hold  [list VIEW_TT]
