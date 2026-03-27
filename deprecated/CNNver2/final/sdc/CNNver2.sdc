###############################################################################
# Created by write_sdc
###############################################################################
current_design CNNver2
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk_i -period 20.0000 
set_clock_uncertainty 0.2500 clk_i
set_input_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {CNNver2_MOSI}]
set_input_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {CNNver2_SPICLOCK_50}]
set_input_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {CNNver2_SS_N}]
set_output_delay 4.0000 -clock [get_clocks {clk_i}] -add_delay [get_ports {CNNver2_MISO}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0060 [get_ports {CNNver2_MISO}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {CNNver2_MOSI}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {CNNver2_SPICLOCK_50}]
set_driving_cell -lib_cell sg13g2_buf_4 -pin {X} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {CNNver2_SS_N}]
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 10.0000 [current_design]
