# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Wed Sep 09 18:43:19 HKT 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design spi_slave

create_clock -name "SCLK" -period 2.667 -waveform {0.0 1.3335} [get_ports sclk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks SCLK] -add_delay 0.0 [get_ports mosi]
set_output_delay -clock [get_clocks SCLK] -add_delay 0.0 [get_ports miso]
set_wire_load_mode "segmented"
