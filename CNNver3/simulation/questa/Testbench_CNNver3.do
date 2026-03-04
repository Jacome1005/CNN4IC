# ═══════════════════════════════════════════════════════
#  Testbench_CNNver3.do — Questa/ModelSim  (version final)
#  Incluye: accum_maxpool, MR1, MR2, comparador
# ═══════════════════════════════════════════════════════
#  Estructura de archivos:
#    sim/Testbench_CNNver3.do    <- este archivo
#    sim/Testbench_CNNver3.vt   <- testbench
#    rtl/*.v                    <- modulos RTL
#    CNNver3.v                  <- top level
# ═══════════════════════════════════════════════════════

# --- LIMPIEZA ---
quit -sim
if [file exists work] { vdel -all -lib work }
vlib work

# --- COMPILACION (orden de dependencias bottom-up) ---

# Nivel 0: registros base
vlog ../../rtl/Register.v
vlog ../../rtl/Register_Imag.v
vlog ../../rtl/Register_Weight.v
vlog ../../rtl/Master_register.v

# Nivel 1: modulos de resultado
vlog ../../rtl/window_mux_6x6_5x5.v
vlog ../../rtl/progressive_maxpool.v
vlog ../../rtl/mux_cnn.v
vlog ../../rtl/mac_parallel.v
vlog ../../rtl/fragment_mux_10x10_6x6.v

# Nivel 2: state machines
vlog ../../rtl/SC_STATEMACHINE_IMAGE_LOADER.v
vlog ../../rtl/SC_STATEMACHINE_WEIGHT_LOADER.v

# Nivel 3: CNN core
vlog ../../rtl/cnn_top.v

# Nivel 4: controlador CNN (actualizado: SAVE_ACCUM, pass_sel)
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# Nivel 5: SPI slave (actualizado: cmd 101, 110)
vlog ../../rtl/spi_cnn_slave_8.v

# Nivel 6: top module (6 pines externos)
vlog ../../CNNver3.v

# Nivel 7: testbench
vlog Testbench_CNNver3.vt

# --- INICIO DE SIMULACION ---
vsim -voptargs="+acc" work.TB_SYSTEM

# ═══════════════════════════════════════════════════════
#  CONFIGURACION DE ONDAS
# ═══════════════════════════════════════════════════════

# ── SPI Interface (6 pines externos) ──────────────────
add wave -divider "=== SPI INTERFACE (6 pines externos) ==="
add wave -color "Yellow"  /TB_SYSTEM/CNNver3_u0/CNNver3_SPICLOCK_50
add wave -color "Cyan"    /TB_SYSTEM/CNNver3_u0/CNNver3_SS_N
add wave -color "Orange"  /TB_SYSTEM/CNNver3_u0/CNNver3_MOSI
add wave -color "Green"   /TB_SYSTEM/CNNver3_u0/CNNver3_MISO
add wave -color "Red"     /TB_SYSTEM/CNNver3_u0/CNNver3_Reset_InHigh
add wave -color "Red"     /TB_SYSTEM/CNNver3_u0/CNNver3_CMD_Reset

# ── SPI Slave: control interno ─────────────────────────
add wave -divider "=== SPI CONTROL INTERNO ==="
add wave -radix binary    /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/valid_clk
add wave -radix binary    /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/bit_count
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/data_count
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/row
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/weight_count
add wave -color "Red"     /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_start_cnn
add wave -color "Magenta" /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_save_accum

# ── SPI Slave: MISO ────────────────────────────────────
add wave -divider "=== MISO READBACK ==="
add wave                  /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/miso_active
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/miso_count
add wave -radix decimal   /TB_SYSTEM/miso_captured
add wave                  /TB_SYSTEM/comp_captured

# ── FSM Image Loader ───────────────────────────────────
add wave -divider "=== FSM IMAGE LOADER ==="
add wave -color "Pink"    /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
add wave                  /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_load00
add wave                  /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_load09

# ── FSM Weight Loader ──────────────────────────────────
add wave -divider "=== FSM WEIGHT LOADER ==="
add wave -color "Pink"    /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/loader_weight_sm/STATE_Register
add wave                  /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_wload00
add wave                  /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/o_wload04

# ── Memorias SPI ───────────────────────────────────────
add wave -divider "=== SPI INTERNAL MEMORY ==="
add wave -radix hexadecimal /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/image_mem
add wave -radix hexadecimal /TB_SYSTEM/CNNver3_u0/spi_cnn_slave_8_u0/weight_mem

# ── Registros de Imagen ────────────────────────────────
add wave -divider "=== IMAGE REGISTERS (10 x 30b) ==="
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u0/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u1/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u2/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u3/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u4/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u5/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u6/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u7/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u8/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_SYSTEM/CNNver3_u0/register_imag_u9/Register_Imag_DataOutBUS

# ── Registros de Pesos ─────────────────────────────────
add wave -divider "=== WEIGHT REGISTERS (5 x 15b) ==="
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver3_u0/weight_register_u0/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver3_u0/weight_register_u1/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver3_u0/weight_register_u2/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver3_u0/weight_register_u3/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_SYSTEM/CNNver3_u0/weight_register_u4/Register_Weight_DataOutBUS

# ── CNN Controller FSM ─────────────────────────────────
add wave -divider "=== CNN CONTROLLER FSM ==="
add wave -color "Magenta" -radix unsigned /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/STATE_Register
add wave -color "Magenta"                 /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/start_cnn_latch
add wave -color "Yellow"                  /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/save_accum_latch
add wave -color "Cyan"                    /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/pass_sel
add wave -color "Yellow"                  /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/o_cnn_rst
add wave -color "Green"                   /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/o_result_load
add wave -color "Cyan"                    /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/o_accum_clear
add wave                                  /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/o_mr1_load
add wave                                  /TB_SYSTEM/CNNver3_u0/cnn_ctrl_sm/o_mr2_load

# ── CNN Core ───────────────────────────────────────────
add wave -divider "=== CNN CORE ==="
add wave -radix hexadecimal /TB_SYSTEM/CNNver3_u0/px_flat_cwire
add wave -radix hexadecimal /TB_SYSTEM/CNNver3_u0/w_flat_cwire
add wave -color "Green"     /TB_SYSTEM/CNNver3_u0/CNN_ready_cwire
add wave -radix decimal -color "White" /TB_SYSTEM/CNNver3_u0/CNN_y_out_cwire

# ── Main Master Register (CNN result para READ RESULT) ─
add wave -divider "=== MAIN MASTER REGISTER (CNN → MISO) ==="
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver3_u0/Master_Result_out_cwire

# ── MaxPool ────────────────────────────────────────────
add wave -divider "=== MAXPOOL ==="
add wave                  /TB_SYSTEM/CNNver3_u0/SPI_mp_load_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/SPI_mp_data_cwire
add wave                  /TB_SYSTEM/CNNver3_u0/MaxPool_valid_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/MaxPool_result_cwire
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/maxpool_shift_u0/reg0
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/maxpool_shift_u0/reg1
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/maxpool_shift_u0/reg2
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/maxpool_shift_u0/reg3
add wave -radix decimal   /TB_SYSTEM/CNNver3_u0/maxpool_shift_u0/count

# ── Acumulador MaxPool (NUEVO) ─────────────────────────
add wave -divider "=== ACUMULADOR MAXPOOL (accum_u0) ==="
add wave                  /TB_SYSTEM/CNNver3_u0/accum_u0/i_valid
add wave                  /TB_SYSTEM/CNNver3_u0/accum_u0/i_clear
add wave -radix decimal -color "Cyan" /TB_SYSTEM/CNNver3_u0/accum_u0/o_accum

# ── Master Register 1 (NUEVO) ─────────────────────────
add wave -divider "=== MASTER REGISTER 1 (pass 0) ==="
add wave                  /TB_SYSTEM/CNNver3_u0/CNN_CTRL_mr1_load_cwire
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver3_u0/MR1_out_cwire

# ── Master Register 2 (NUEVO) ─────────────────────────
add wave -divider "=== MASTER REGISTER 2 (pass 1) ==="
add wave                  /TB_SYSTEM/CNNver3_u0/CNN_CTRL_mr2_load_cwire
add wave -radix decimal -color "Yellow" /TB_SYSTEM/CNNver3_u0/MR2_out_cwire

# ── Comparador (NUEVO) ────────────────────────────────
add wave -divider "=== COMPARADOR MR1 > MR2 ==="
add wave -color "Green"   /TB_SYSTEM/CNNver3_u0/comp_result_cwire
add wave                  /TB_SYSTEM/comp_captured

# --- EJECUCION ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
