# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Thu Sep 10 16:06:12 HKT 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design spi_slave

create_clock -name "SCLK" -period 2.89855 -waveform {0.0 1.449275} [get_ports sclk]
set_load -pin_load 0.0229 [get_ports miso]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks SCLK] -add_delay 0.0 [get_ports mosi]
set_output_delay -clock [get_clocks SCLK] -add_delay 0.0 [get_ports miso]
set_wire_load_mode "segmented"
