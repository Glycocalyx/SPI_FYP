# ============================================================
# Milestone 6B
# Innovus Import + Global Power / Constant Connectivity
#
# Purpose:
#   1. Import the same synthesized SPI design used in M6B.
#   2. Establish physical VDD/VSS connectivity for standard cells.
#   3. Map logical constant-high/constant-low connections to
#      VDD/VSS for physical implementation.
#   4. Re-run design checks before floorplanning.
#
# This stage does NOT perform:
#   - floorplanning
#   - placement
#   - CTS
#   - routing
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
# Innovus import configuration
# ============================================================

set init_verilog $NETLIST

set init_top_cell spi_slave_full_io_pad_wrapper

set init_lef_file [list \
    $CORE_LEF \
    $IO_LEF \
]

set init_mmmc_file "mmmc_tt.tcl"

set init_pwr_net VDD
set init_gnd_net VSS


# ============================================================
# Import
# ============================================================

puts ""
puts "============================================================"
puts "Importing SPI design"
puts "============================================================"

init_design


# ============================================================
# Global power / ground connectivity
#
# Standard-cell physical PG pins:
#     VDD -> VDD
#     VSS -> VSS
#
# Logical constants:
#     constant 1 -> VDD
#     constant 0 -> VSS
# ============================================================

puts ""
puts "============================================================"
puts "Applying global VDD / VSS connectivity"
puts "============================================================"

globalNetConnect VDD \
    -type pgpin \
    -pin VDD \
    -all \
    -override \
    -verbose

globalNetConnect VSS \
    -type pgpin \
    -pin VSS \
    -all \
    -override \
    -verbose

globalNetConnect VDD \
    -type tiehi \
    -all \
    -override \
    -verbose

globalNetConnect VSS \
    -type tielo \
    -all \
    -override \
    -verbose

applyGlobalNets


# ============================================================
# Design verification
# ============================================================

puts ""
puts "============================================================"
puts "Checking design after global connectivity"
puts "============================================================"

checkDesign -all \
    > reports/check_design_connectivity_fixed.rpt


# ============================================================
# Save database
# ============================================================

saveDesign db/m6b_connectivity_fixed.enc


# ============================================================
# Completion
# ============================================================

puts ""
puts "============================================================"
puts "Milestone 6B connectivity cleanup completed"
puts ""
puts "Expected result:"
puts "  - Core VDD/VSS connectivity established"
puts "  - Constant high/low connectivity established"
puts ""
puts "Still intentionally pending:"
puts "  - Floorplan"
puts "  - Placement-grid correction"
puts "  - Pad placement"
puts "  - Power grid"
puts "  - Placement / CTS / Routing"
puts ""
puts "Report:"
puts "  reports/check_design_connectivity_fixed.rpt"
puts ""
puts "Database:"
puts "  db/m6b_connectivity_fixed.enc"
puts "============================================================"
puts ""

exit
