# ============================================================
# Milestone 6C
# Formal SPI Physical Floorplan
#
# Technology:
#   TSMC 180 nm BCD
#   6LM physical technology
#
# Signal-routing policy:
#   METAL1 - METAL4
#
# Formal geometry:
#
#   Die:
#       403.2 um x 403.2 um
#
#   Core:
#       123.2 um x 123.2 um
#
#   Final die-to-core offset:
#       140.0 um
#
# Placement grid:
#       0.56 um x 0.56 um
#
# Standard-cell site:
#       core10T
#       0.56 um x 5.60 um
# ============================================================


# ============================================================
# Restore validated M6B import database
# ============================================================

restoreDesign \
    db/m6b_import.enc.dat \
    spi_slave_full_io_pad_wrapper


# ============================================================
# Standard-cell power / ground connectivity
#
# Only PG pins are connected here.
#
# Constant logic inputs are NOT directly connected to
# VDD/VSS. Dedicated TIEH/TIEL cells will be used later.
# ============================================================

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

applyGlobalNets


# ============================================================
# Formal floorplan
#
# The loaded IO PAD architecture contributes an 80-um
# physical IO region.
#
# Therefore:
#
#     requested pre-IO margin = 60 um
#     IO region               = 80 um
#     final core offset       = 140 um
#
# -noSnapToGrid is intentionally used here.
#
# Without this option Innovus pre-snaps 60.0 um to
# 59.92 um before adding the 80-um IO region,
# producing an off-grid final core boundary of 139.92 um.
#
# Preserving 60.0 um gives:
#
#     Core:
#       (140.0,140.0) -> (263.2,263.2)
#
#     Die:
#       (0,0) -> (403.2,403.2)
#
# All final boundaries align with the 0.56-um
# placement grid.
# ============================================================

floorPlan \
    -site core10T \
    -s 123.2 123.2 \
    60.0 60.0 60.0 60.0 \
    -noSnapToGrid


# ============================================================
# Signal-routing layer policy
#
# Physical process:
#   6LM
#
# Automatic normal signal routing:
#   METAL1 - METAL4
# ============================================================

setNanoRouteMode \
    -routeBottomRoutingLayer 1

setNanoRouteMode \
    -routeTopRoutingLayer 4


# ============================================================
# Report actual physical geometry
# ============================================================

puts ""
puts "============================================================"
puts "FORMAL FLOORPLAN GEOMETRY"
puts "============================================================"

puts "Placement-grid origin:"
puts [get_snap_grid_info -type placement -origin]

puts "Placement-grid pitch X:"
puts [get_snap_grid_info -type placement -pitch_x]

puts "Placement-grid pitch Y:"
puts [get_snap_grid_info -type placement -pitch_y]

puts "Die box:"
puts [dbGet top.fPlan.box]

puts "Core box:"
puts [dbGet top.fPlan.coreBox]


# ============================================================
# Physical-design validation
# ============================================================

checkDesign -all \
    > reports/check_design_floorplan.rpt


# ============================================================
# Save formal M6C database
# ============================================================

saveDesign db/m6c_floorplan.enc


puts ""
puts "============================================================"
puts "Milestone 6C formal floorplan generated"
puts ""
puts "Die:"
puts "  403.2 um x 403.2 um"
puts ""
puts "Core:"
puts "  123.2 um x 123.2 um"
puts ""
puts "Core boundary:"
puts "  (140.0,140.0) -> (263.2,263.2)"
puts ""
puts "Signal-routing policy:"
puts "  METAL1 - METAL4"
puts ""
puts "Pending:"
puts "  PAD placement"
puts "  TIEH/TIEL insertion"
puts "  standard-cell placement"
puts "  power planning"
puts "  CTS"
puts "  signal routing"
puts "============================================================"
puts ""

exit
