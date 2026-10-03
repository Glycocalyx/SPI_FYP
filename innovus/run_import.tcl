# ============================================================
# Milestone 6B
# Innovus Initial Design Import
#
# Technology:
#   TSMC 180 nm BCD
#   6LM
#
# Routing policy:
#   Physical library = 6LM
#   Signal routing later restricted to METAL1-METAL4
#
# This script ONLY imports and validates the design.
# No floorplan / placement / CTS / routing yet.
# ============================================================


# ============================================================
# Paths
# ============================================================

set PDK_ROOT "/dfs/app/tsmc_icdc/tsmc180/tsmc180_HV_BCD_Gen2_1_7p2a1"

set CORE_LEF \
"$PDK_ROOT/SC/tcb018bcdgp2a_110c/TSMCHOME/digital/Back_End/lef/tcb018bcdgp2a_110a/lef/tcb018bcdgp2a_6lm.lef"

set IO_LEF \
"$PDK_ROOT/IO/tps018bcdnv5_113a/TSMCHOME/digital/Back_End/lef/tps018bcdnv5_113a/mt/6lm/lef/tps018bcdnv5_6lm.lef"

set NETLIST \
"../syn/outputs/spi_slave_csb_async_110MHz_5pF.v"


# ============================================================
# Innovus Init Variables
# ============================================================

set init_verilog $NETLIST

set init_top_cell spi_slave_full_io_pad_wrapper

set init_lef_file [list \
    $CORE_LEF \
    $IO_LEF \
]

set init_mmmc_file "mmmc_tt.tcl"


# Core standard-cell supplies
set init_pwr_net VDD
set init_gnd_net VSS


# ============================================================
# Import design
# ============================================================

puts ""
puts "============================================================"
puts "Starting Innovus design import"
puts "============================================================"

init_design


# ============================================================
# Routing policy
#
# Professor requirement:
#   Use 6LM process,
#   but Innovus signal routing is restricted to M1-M4.
#
# We record the intended routing range here.
# Actual routing configuration will be applied before routing.
# ============================================================

puts ""
puts "Physical technology: 6LM"
puts "Future signal routing range: METAL1 - METAL4"


# ============================================================
# Basic checks
# ============================================================

checkDesign -all \
    > reports/check_design_import.rpt

reportGateCount \
    > reports/gate_count_import.rpt


# ============================================================
# Save imported database
# ============================================================

saveDesign db/m6b_import.enc


# ============================================================
# Completion
# ============================================================

puts ""
puts "============================================================"
puts "Milestone 6B initial import completed"
puts ""
puts "Top:"
puts "  spi_slave_full_io_pad_wrapper"
puts ""
puts "Core LEF:"
puts "  $CORE_LEF"
puts ""
puts "IO LEF:"
puts "  $IO_LEF"
puts ""
puts "Netlist:"
puts "  $NETLIST"
puts ""
puts "Reports:"
puts "  reports/check_design_import.rpt"
puts "  reports/gate_count_import.rpt"
puts ""
puts "Database:"
puts "  db/m6b_import.enc"
puts "============================================================"
puts ""

exit

