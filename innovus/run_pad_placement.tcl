# ============================================================
# Milestone 6C-2
# SPI PAD Placement
#
# Starting point:
#   Validated M6C floorplan
#
# Die:
#   403.2 um x 403.2 um
#
# Core:
#   (140.0,140.0) -> (263.2,263.2)
#
# PAD:
#   PDDW0208CSG
#   80 um x 120 um
#
# Default R0 external PAD terminal:
#   located on local bottom edge
#
# Placement concept:
#
#       MISO / R180
#
# SCLK             CSB
# R90     CORE     R270
#
#       MOSI / R0
#
# ============================================================


# ============================================================
# Restore validated formal floorplan
# ============================================================

restoreDesign \
    db/m6c_floorplan.enc.dat \
    spi_slave_full_io_pad_wrapper


# ============================================================
# Place SPI signal PADs
#
# Bottom:
#   PAD terminal faces downward/outward.
#
# Top:
#   PAD terminal faces upward/outward.
#
# Left:
#   PAD terminal faces left/outward.
#
# Right:
#   PAD terminal faces right/outward.
# ============================================================

placeInstance u_mosi_pad \
    161.6 0.0 R0 \
    -fixed

placeInstance u_miso_pad \
    161.6 283.2 R180 \
    -fixed

placeInstance u_sclk_pad \
    0.0 161.6 R90 \
    -fixed

placeInstance u_csb_pad \
    283.2 161.6 R270 \
    -fixed


# ============================================================
# Report actual PAD placement
# ============================================================

puts ""
puts "============================================================"
puts "PAD PLACEMENT"
puts "============================================================"

foreach inst_name {
    u_sclk_pad
    u_mosi_pad
    u_miso_pad
    u_csb_pad
} {

    set inst [dbGet -p top.insts.name $inst_name]

    puts ""
    puts "Instance: $inst_name"
    puts "Orientation:"
    puts [dbGet $inst.orient]
    puts "Box:"
    puts [dbGet $inst.box]
    puts "Placement status:"
    puts [dbGet $inst.pStatus]
}


# ============================================================
# Placement / design validation
# ============================================================

checkPlace \
    > reports/check_place_pads.rpt

checkDesign -all \
    > reports/check_design_pad_placement.rpt


# ============================================================
# Save PAD-placed database
# ============================================================

saveDesign db/m6c_pad_placed.enc


puts ""
puts "============================================================"
puts "Milestone 6C PAD placement generated"
puts ""
puts "PAD arrangement:"
puts "  Left   : SCLK"
puts "  Right  : CSB"
puts "  Bottom : MOSI"
puts "  Top    : MISO"
puts ""
puts "All four PADs are fixed."
puts ""
puts "Pending:"
puts "  Standard-cell placement"
puts "  TIEH/TIEL insertion"
puts "  Power planning"
puts "  CTS"
puts "  Routing"
puts "============================================================"
puts ""

exit
