# ═══════════════════════════════════════════════════
#  Testbench_CNNver2.do — Questa/ModelSim
#  Simulacion completa: SPI + CNN + MaxPool + Master_reg
#  Estructura de archivos esperada:
#    sim/Testbench_CNNver2.do   <- este archivo
#    sim/Testbench_CNNver2.vt   <- testbench
#    rtl/*.v                    <- modulos RTL
#    CNNver2.v                  <- top level
# ═══════════════════════════════════════════════════

# --- LIMPIEZA ---
quit -sim
if [file exists work] { vdel -all -lib work }
vlib work

# --- COMPILACION (orden de dependencias bottom-up) ---

# Nivel 0: registros y modulos sin dependencias
vlog ../../rtl/Register.v
vlog ../../rtl/Register_Imag.v
vlog ../../rtl/Register_Weight.v
vlog ../../rtl/Master_register.v

# Nivel 1: modulos de resultado (sin dependencias de SM)
vlog ../../rtl/maxpool_shift.v
vlog ../../rtl/result_mux_4to1.v

# Nivel 2: state machines de carga (dependen de nada)
vlog ../../rtl/SC_STATEMACHINE_IMAGE_LOADER.v
vlog ../../rtl/SC_STATEMACHINE_WEIGHT_LOADER.v

# Nivel 3: CNN core
vlog ../../rtl/cnn_v2.v
vlog ../../rtl/cnn_conv_v2.v

# Nivel 4: controlador CNN (depende de maxpool_shift.v para i_cnn_ready)
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# Nivel 5: SPI slave (depende de SM loaders)
vlog ../../rtl/spi_cnn_slave_8.v

# Nivel 6: top module (depende de todo)
vlog ../../CNNver2.v

# Nivel 7: testbench
vlog Testbench_CNNver2.vt

# --- INICIO DE SIMULACION ---
vsim -voptargs="+acc" work.TB_SYSTEM

# ═══════════════════════════════════════════════════
#  CONFIGURACION DE ONDAS
# ═══════════════════════════════════════════════════

# ── SPI Interface (pines del top) ──────────────────
add wave -divider "=== SPI INTERFACE ==="
add wave -color "Yellow"  /TB_SYSTEM/CNNver2_u0/CNNver2_SPICLOCK_50
add wave -color "Cyan"    /TB_SYSTEM/CNNver2_u0/CNNver2_SS_N
add wave -color "Orange"  /TB_SYSTEM/CNNver2_u0/CNNver2_MOSI
add wave -color "Green"   /TB_SYSTEM/CNNver2_u0/CNNver2_MISO
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/CNNver2_Reset_InHigh
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/CNNver2_CMD_Reset
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/CNNver2_result_pos

# ── SPI Slave: control interno ─────────────────────
add wave -divider "=== SPI CONTROL INTERNO ==="
add wave -radix binary    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/valid_clk
add wave -radix binary    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/bit_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/data_count
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/row
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/weight_count
add wave -color "Red"     /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_start_cnn
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/cmd_latch_for_pos

# ── SPI Slave: MISO readback ───────────────────────
add wave -divider "=== MISO READBACK ==="
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_active
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/miso_count
add wave -radix decimal   /TB_SYSTEM/miso_captured

# ── FSM Image Loader ───────────────────────────────
add wave -divider "=== FSM IMAGE LOADER ==="
add wave -color "Pink"    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
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

# ── FSM Weight Loader ──────────────────────────────
add wave -divider "=== FSM WEIGHT LOADER ==="
add wave -color "Pink"    /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/loader_weight_sm/STATE_Register
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload00
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload01
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload02
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload03
add wave                  /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/o_wload04

# ── SPI Memorias Internas ──────────────────────────
add wave -divider "=== SPI INTERNAL MEMORY ==="
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/image_mem
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/spi_cnn_slave_8_u0/weight_mem

# ── Registros de Imagen (10 x 30 bits) ────────────
add wave -divider "=== IMAGE REGISTERS (10 x 30 bits) ==="
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

# ── Registros de Pesos (5 x 15 bits) ──────────────
add wave -divider "=== WEIGHT REGISTERS (5 x 15 bits) ==="
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u0/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u1/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u2/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u3/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver2_u0/weight_register_u4/Register_Weight_DataOutBUS

# ── CNN Controller FSM ────────────────────────────
add wave -divider "=== CNN CONTROLLER FSM ==="
add wave -color "Magenta" -radix unsigned /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/STATE_Register
add wave -color "Magenta"                 /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/start_cnn_latch
add wave -color "Cyan"                    /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/start_maxpool_latch
add wave -color "Yellow"                  /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_cnn_rst
add wave -color "Cyan"                    /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_weight_load
add wave -color "Green"                   /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_result_load
add wave -radix binary                    /TB_SYSTEM/CNNver2_u0/cnn_ctrl_sm/o_result_sel

# ── CNN Core ─────────────────────────────────────
add wave -divider "=== CNN CORE ==="
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/px_flat_cwire
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/w_flat_cwire
add wave -color "Green"     /TB_SYSTEM/CNNver2_u0/CNN_ready_cwire
add wave -radix decimal -color "White" /TB_SYSTEM/CNNver2_u0/CNN_y_out_cwire

# ── MaxPool ─────────────────────────────────────
add wave -divider "=== MAXPOOL ==="
add wave                  /TB_SYSTEM/CNNver2_u0/SPI_mp_load_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/SPI_mp_data_cwire
add wave                  /TB_SYSTEM/CNNver2_u0/MaxPool_valid_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/MaxPool_result_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/maxpool_shift_u0/reg0
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/maxpool_shift_u0/reg1
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/maxpool_shift_u0/reg2
add wave -radix decimal   /TB_SYSTEM/CNNver2_u0/maxpool_shift_u0/reg3

# ── result_mux y Master_register ─────────────────
add wave -divider "=== RESULT MUX + MASTER REGISTER ==="
add wave -radix binary    /TB_SYSTEM/CNNver2_u0/CNN_CTRL_result_sel_cwire
add wave -radix hexadecimal /TB_SYSTEM/CNNver2_u0/master_data_in_cwire
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver2_u0/Master_Result_out_cwire

# --- EJECUCION ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
