create_clock -name clk_50 -period 20.000 [get_ports {CNNver3_SPICLOCK_50}]
derive_clock_uncertainty

# CNNver3_Reset_InHigh es una señal asíncrona de reset, no un clock.
# Elimina Warning (16406/16407): Quartus la promueve a red global no dedicada.
set_false_path -from [get_ports {CNNver3_Reset_InHigh}]
