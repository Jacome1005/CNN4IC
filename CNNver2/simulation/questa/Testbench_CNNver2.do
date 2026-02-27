# ═══════════════════════════════════════════════════
#  Testbench_CNNver2.do — Questa/ModelSim
#  Simulacion completa: SPI + CNN Integration
# ═══════════════════════════════════════════════════

# --- LIMPIEZA ---
quit -sim
if [file exists work] { vdel -all -lib work }
vlib work

# --- COMPILACION (orden de dependencias) ---
# Modulos base sin dependencias
vlog ../../rtl/Register.v
vlog ../../rtl/Register_Imag.v
vlog ../../rtl/Register_Weight.v

# State machines de carga (★ nombre actualizado)
vlog ../../rtl/STATEMACHINE_IMAGE_LOADER.v
vlog ../../rtl/SC_STATEMACHINE_WEIGHT_LOADER.v

# CNN core
vlog ../../rtl/cnn_v2.v
vlog ../../rtl/cnn_conv_v2.v

# Controlador CNN
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# SPI slave (depende de SM loaders)
vlog ../../rtl/spi_cnn_slave_8.v

# Top module
vlog ../../CNNver2.v

# Testbench
vlog Testbench_CNNver2.vt

# --- INICIO DE SIMULACION ---
vsim -voptargs="+acc" work.TB_SYSTEM

# ═══════════════════════════════════════════════════
#  CONFIGURACION DE ONDAS
# ═══════════════════════════════════════════════════

# ── SPI Interface ──
add wave -divider "SPI INTERFACE"
add wave -color "Yellow"  /TB_SYSTEM/CNNver2_u0/CNNver2_SPICLOCK_50
add wave -color "Cyan"    /TB_SYSTEM/CNNver2_u0/CNNver2_SS_N
add wave -color "Orange"  /TB_SYSTEM/CNNver2_u0/CNNver2_MOSI
add wave -color "Green"   /TB_SYSTEM/CNNver2_u0/CNNver2_MISO
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/CNNver2_Reset_InHigh

# ── SPI Control internals ──
add wave -divider "SPI CONTROL"
add wave -radix binary    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/bit_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/data_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/row
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/weight_count
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_start_cnn

# ── Image Loader FSM ──
add wave -divider "FSM IMAGE LOADER"
add wave -color "Pink"    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Signal
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load00
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load01
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load02
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load03
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load04
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load05
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load06
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load07
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load08
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load09

# ── Weight Loader FSM (nuevo) ──
add wave -divider "FSM WEIGHT LOADER"
add wave -color "Pink"    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_weight_sm/STATE_Register
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload00
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload01
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload02
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload03
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload04

# ── SPI Internal Memory ──
add wave -divider "SPI INTERNAL MEMORY"
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/image_mem
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/weight_mem

# ── Image Registers ──
add wave -divider "IMAGE REGISTERS (30 bits x 10)"
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u0/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u1/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u2/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u3/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u4/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u5/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u6/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u7/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u8/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_imag_u9/Register_Imag_DataOutBUS

# ── Weight Registers (★ 5 filas x 15 bits, puerto correcto) ──
add wave -divider "WEIGHT REGISTERS (15 bits x 5)"
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u0/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u1/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u2/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u3/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u4/Register_Weight_DataOutBUS

# ── CNN Controller FSM ──
add wave -divider "CNN CONTROLLER FSM"
add wave -color "Magenta" -radix unsigned /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/STATE_Register
add wave -color "Magenta"                 /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/start_latch
add wave -color "Yellow"                  /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_cnn_rst
add wave -color "Cyan"                    /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_weight_load
add wave -color "Green"                   /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_result_load

# ── CNN Core (★ wire names actualizados) ──
add wave -divider "CNN CORE"
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/px_flat_cwire
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/w_flat_cwire
add wave -color "Green"     /TB_SYSTEM/CNNver2_u0/CNN_ready_cwire
add wave -radix decimal -color "White" /TB_SYSTEM/CNNver2_u0/CNN_y_out_cwire

# ── CNN Result Register (★ wire name actualizado) ──
add wave -divider "CNN RESULT"
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver2_u0/CNN_Result_out_cwire

# ── MISO Readback ──
add wave -divider "MISO READBACK"
add wave /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_active
add wave -radix decimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_count
add wave -radix decimal /TB_SYSTEM/miso_captured

# --- EJECUCION ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
