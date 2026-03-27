transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3 {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/CNNver3.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/window_mux_6x6_5x5.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/spi_cnn_slave_8.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/SC_STATEMACHINE_WEIGHT_LOADER.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/SC_STATEMACHINE_IMAGE_LOADER.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/SC_STATEMACHINE_CNN_CTRL.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/Register_Weight.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/Register_Imag.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/progressive_maxpool.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/mux_cnn.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/Master_register.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/mac_parallel.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/fragment_mux_10x10_6x6.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/comm_mem_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/cnn_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl {C:/Users/jacob/Desktop/UNIC_CASS/CNN4IC/CNNver3/rtl/cnn_proc_top.v}

