# ===================================================================
#  tb_CNNver3_robust.do — Questa/ModelSim
#  Testbench de robustez HW para CNNver3
#
#  Tests:
#    T01 — Baseline: img=1s, ker0=1s→225, ker1=ctr→9, comp=1
#    T02 — Baseline inverso: ker0=ctr→9, ker1=1s→225, comp=0
#    T03 — img=2s, kernels iguales → comp=0 (450==450)
#    T04 — Checkerboard: acc0=117 vs acc1=9, comp=1
#    T05 — Solo fila 0 activa: acc0=15 vs acc1=0, comp=1
#    T06 — img=-1, ker0=+1→-225, ker1=-1→+225, comp=0
#    T07 — Cuadrantes TL=2 BR=1: acc0=213 vs acc1=11, comp=1
#    T08 — Pixel único (0,0)=3: acc0=3 vs acc1=0, comp=1
#    T09 — CMD Reset a mitad de transacción SPI
#    T10 — Reset global durante CNN → recuperación
#    T11 — Tres clasificaciones consecutivas: comp=1,0,1
# ===================================================================

# --- LIMPIEZA ---
quit -sim
if [file exists work] { vdel -all -lib work }
vlib work

# --- COMPILACION (orden bottom-up) ---

# Nivel 0: registros base
vlog ../../rtl/Register.v
vlog ../../rtl/Register_Imag.v
vlog ../../rtl/Register_Weight.v
vlog ../../rtl/Master_register.v

# Nivel 1: bloques aritméticos (combinacionales)
vlog ../../rtl/mac_parallel.v
vlog ../../rtl/progressive_maxpool.v
vlog ../../rtl/window_mux_6x6_5x5.v
vlog ../../rtl/fragment_mux_10x10_6x6.v

# Nivel 2: máquinas de estado de carga SPI
vlog ../../rtl/SC_STATEMACHINE_IMAGE_LOADER.v
vlog ../../rtl/SC_STATEMACHINE_WEIGHT_LOADER.v

# Nivel 3: CNN core
vlog ../../rtl/mux_cnn.v
vlog ../../rtl/cnn_top.v

# Nivel 4: controlador CNN (doble kernel, MR1/MR2)
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# Nivel 5: SPI slave
vlog ../../rtl/spi_cnn_slave_8.v

# Nivel 6: bloques top intermedios
vlog ../../rtl/comm_mem_top.v
vlog ../../rtl/cnn_proc_top.v

# Nivel 7: top level CNNver3
vlog ../../CNNver3.v

# Nivel 8: testbench
vlog tb_CNNver3_robust.v

# --- INICIO DE SIMULACION ---
vsim -voptargs="+acc" work.tb_CNNver3_robust

# ===================================================================
#  CONFIGURACION DE ONDAS
# ===================================================================

# -- SPI Interface (8 pines externos) --
add wave -divider "=== SPI INTERFACE ==="
add wave -color "Yellow"  /tb_CNNver3_robust/SPI_CLK
add wave -color "Cyan"    /tb_CNNver3_robust/SS_N
add wave -color "Orange"  /tb_CNNver3_robust/MOSI
add wave -color "Green"   /tb_CNNver3_robust/MISO
add wave -color "Red"     /tb_CNNver3_robust/RESET
add wave -color "Pink"    /tb_CNNver3_robust/CMD_RESET
add wave -color "Magenta" /tb_CNNver3_robust/MR1_Load
add wave -color "Magenta" /tb_CNNver3_robust/MR2_Load

# -- Señales internas de observación --
add wave -divider "=== OBSERVACION INTERNA ==="
add wave -radix decimal  /tb_CNNver3_robust/w_acc0
add wave -radix decimal  /tb_CNNver3_robust/w_acc1
add wave                 /tb_CNNver3_robust/w_done
add wave -radix unsigned /tb_CNNver3_robust/w_state

# -- SPI Slave: control interno --
add wave -divider "=== SPI SLAVE INTERNO ==="
add wave -radix binary   /tb_CNNver3_robust/dut/spi_u0/cmd
add wave -radix decimal  /tb_CNNver3_robust/dut/spi_u0/bit_count
add wave -radix decimal  /tb_CNNver3_robust/dut/spi_u0/row
add wave -radix decimal  /tb_CNNver3_robust/dut/spi_u0/weight_count
add wave -color "Red"    /tb_CNNver3_robust/dut/spi_u0/o_start_cnn

# -- Memorias SPI --
add wave -divider "=== SPI MEMORY ==="
add wave -radix hexadecimal /tb_CNNver3_robust/dut/spi_u0/image_mem
add wave -radix hexadecimal /tb_CNNver3_robust/dut/spi_u0/weight_mem

# -- Registros de Imagen --
add wave -divider "=== IMAGE REGISTERS (10 x 30b) ==="
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u0/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u1/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u2/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u3/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u4/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u5/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u6/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u7/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u8/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_img_u9/Register_Imag_DataOutBUS

# -- Registros de Pesos --
add wave -divider "=== WEIGHT REGISTERS (5 x 15b) ==="
add wave -radix hexadecimal -group "WT_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_wgt_u0/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_wgt_u1/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_wgt_u2/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_wgt_u3/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /tb_CNNver3_robust/dut/comm_mem_u0/reg_wgt_u4/Register_Weight_DataOutBUS

# -- CNN Controller FSM --
add wave -divider "=== CNN CONTROLLER FSM ==="
add wave -color "Magenta" -radix unsigned /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/state
add wave -color "Yellow"                  /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_rst
add wave -color "Green"                   /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_start
add wave -color "Cyan"                    /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/o_done

# -- CNN Top --
add wave -divider "=== CNN_TOP ==="
add wave -radix unsigned /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_inst/state
add wave -radix decimal  /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_inst/frag_sel
add wave                 /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_inst/done
add wave -radix decimal -color "White" /tb_CNNver3_robust/dut/proc_u0/cnn_ctrl_u0/cnn_inst/acc

# -- Acumuladores y comparador --
add wave -divider "=== ACUMULADORES Y COMPARADOR ==="
add wave -radix decimal  /tb_CNNver3_robust/dut/acc0
add wave -radix decimal  /tb_CNNver3_robust/dut/acc1
add wave -radix decimal -color "Yellow" /tb_CNNver3_robust/dut/comm_mem_u0/mr1_u0/Register_DataOutBUS
add wave -radix decimal -color "Yellow" /tb_CNNver3_robust/dut/comm_mem_u0/mr2_u0/Register_DataOutBUS
add wave -color "Green"  /tb_CNNver3_robust/dut/comp_result

# --- EJECUCION ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
