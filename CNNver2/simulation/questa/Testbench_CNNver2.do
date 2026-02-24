# ═══════════════════════════════════════════════════
#  Testbench_CNNver2.do — Questa/ModelSim
#  Simulación completa: SPI + CNN Integration
# ═══════════════════════════════════════════════════

# --- LIMPIEZA ---
quit -sim
if [file exists work] { vdel -all -lib work }
vlib work

# --- COMPILACIÓN (orden de dependencias) ---
# Módulos base sin dependencias
vlog ../../rtl/Register.v
vlog ../../rtl/STATEMACHINE_IMAGE_LOADER.v

# CNN core (sin dependencias externas)
vlog ../../rtl/cnn_v2.v
vlog ../../rtl/cnn_conv_v2.v

# Controlador CNN (nuevo, sin dependencias)
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# SPI slave (depende de STATEMACHINE_IMAGE_LOADER)
vlog ../../rtl/spi_cnn_slave_8.v

# Top module (depende de todo lo anterior)
vlog ../../CNNver2.v

# Testbench
vlog Testbench_CNNver2.vt

# --- INICIO DE SIMULACIÓN ---
vsim -voptargs="+acc" work.TB_SYSTEM

# ═══════════════════════════════════════════════════
#  CONFIGURACIÓN DE ONDAS
# ═══════════════════════════════════════════════════

# ── SPI Interface ──
add wave -divider "SPI INTERFACE"
add wave -color "Yellow"  /TB_SYSTEM/CNNver2_u0/CNNver2_SPICLOCK_50
add wave -color "Cyan"    /TB_SYSTEM/CNNver2_u0/CNNver2_SS_N
add wave -color "Orange"  /TB_SYSTEM/CNNver2_u0/CNNver2_MOSI
add wave -color "Green"   /TB_SYSTEM/CNNver2_u0/CNNver2_MISO

# ── SPI Control ──
add wave -divider "SPI CONTROL"
add wave -radix binary    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/bit_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/data_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/row
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_start_cnn

# ── Image Loader FSM (original) ──
add wave -divider "FSM IMAGE LOADER"
add wave -color "Pink"    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_load*

# ── SPI Internal Memory ──
add wave -divider "SPI INTERNAL MEMORY"
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/image_mem
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/weight_mem

# ── Image Registers (original) ──
add wave -divider "IMAGE REGISTERS"
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u0/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u1/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u2/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u3/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u4/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u5/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u6/Register_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver2_u0/register_u7/Register_DataOutBUS

# ── Weight Registers (nuevo) ──
add wave -divider "WEIGHT REGISTERS"
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u0/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u1/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u2/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u3/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u4/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u5/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u6/Register_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u7/Register_DataOutBUS

# ── CNN Controller FSM (nuevo) ──
add wave -divider "CNN CONTROLLER FSM"
add wave -color "Magenta" -radix unsigned /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/STATE_Register
add wave -color "Magenta"                 /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/start_latch
add wave -color "Yellow"                  /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_cnn_rst
add wave -color "Cyan"                    /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_weight_load
add wave -color "Green"                   /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_result_load

# ── CNN Core ──
add wave -divider "CNN CORE"
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/px_flat_packed_routing_cwire
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/w_flat_packed_routing_cwire
add wave -color "Green"     /TB_SYSTEM/CNNver2_u0/CNN_ready_routing_cwire
add wave -radix decimal -color "White" /TB_SYSTEM/CNNver2_u0/CNN_y_out_routing_cwire

# ── CNN Result Register ──
add wave -divider "CNN RESULT"
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver2_u0/CNN_Result_DataOutBUS_routing_cwire

# ── MISO Readback ──
add wave -divider "MISO READBACK"
add wave /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_active
add wave -radix decimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_count
add wave -radix decimal /TB_SYSTEM/miso_captured

# --- EJECUCIÓN ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
