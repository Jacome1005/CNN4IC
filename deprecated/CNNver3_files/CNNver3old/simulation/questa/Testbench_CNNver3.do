# ═══════════════════════════════════════════════════════
#  Testbench_CNNver3.do — Questa/ModelSim
#  Testbench completo para CNNver3
#
#  Cambios respecto a CNNver2:
#    - CMD_Reset eliminado del top (7 pines en lugar de 8)
#    - Nuevo mapa SPI: 001=IMG, 010=WGT, 011=START,
#                      100=READ_CMP, 101=READ_MR1, 110=READ_MR2
#    - Dos kernels secuenciales: MR1=acc kernel0, MR2=acc kernel1
#    - Sin maxpool_shift, accum_maxpool, save_accum
#    - Ondas actualizadas para reflejar nueva jerarquía
#
#  Estructura de archivos:
#    sim/Testbench_CNNver3.do    <- este archivo
#    sim/Testbench_CNNver3.vt   <- testbench
#    rtl/*.v                    <- módulos RTL
#    CNNver3.v                  <- top level
# ═══════════════════════════════════════════════════════

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

# Nivel 5: SPI slave (cmd 001..111, sin cmd_reset externo)
vlog ../../rtl/spi_cnn_slave_8.v

# Nivel 6: top module CNNver3 (7 pines: sin CMD_Reset)
vlog ../../CNNver3.v

# Nivel 7: testbench
vlog Testbench_CNNver3.vt

# --- INICIO DE SIMULACION ---
vsim -voptargs="+acc" work.TB_CNNver3

# ═══════════════════════════════════════════════════════
#  CONFIGURACION DE ONDAS
# ═══════════════════════════════════════════════════════

# ── SPI Interface (7 pines externos — sin CMD_Reset) ──
add wave -divider "=== SPI INTERFACE (7 pines, sin CMD_Reset) ==="
add wave -color "Yellow"  /TB_CNNver3/CNNver3_u0/CNNver3_SPICLOCK_50
add wave -color "Cyan"    /TB_CNNver3/CNNver3_u0/CNNver3_SS_N
add wave -color "Orange"  /TB_CNNver3/CNNver3_u0/CNNver3_MOSI
add wave -color "Green"   /TB_CNNver3/CNNver3_u0/CNNver3_MISO
add wave -color "Red"     /TB_CNNver3/CNNver3_u0/CNNver3_Reset_InHigh
add wave -color "Magenta" /TB_CNNver3/CNNver3_u0/CNNver3_MR1_Load
add wave -color "Magenta" /TB_CNNver3/CNNver3_u0/CNNver3_MR2_Load

# ── SPI Slave: control interno ────────────────────────
add wave -divider "=== SPI CONTROL INTERNO ==="
add wave -radix binary   /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/valid_clk
add wave -radix binary   /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/bit_count
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/data_count
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/row
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/weight_count
add wave -color "Red"    /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/o_start_cnn

# ── SPI Slave: MISO ───────────────────────────────────
add wave -divider "=== MISO READBACK ==="
add wave                 /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/miso_active
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/miso_count
add wave -radix decimal  /TB_CNNver3/miso_mr1
add wave -radix decimal  /TB_CNNver3/miso_mr2
add wave                 /TB_CNNver3/comp_captured

# ── FSM Image Loader ──────────────────────────────────
add wave -divider "=== FSM IMAGE LOADER ==="
add wave -color "Pink"   /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/loader_image_sm/row_latch
add wave                 /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/o_load00
add wave                 /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/o_load09

# ── FSM Weight Loader ─────────────────────────────────
add wave -divider "=== FSM WEIGHT LOADER ==="
add wave -color "Pink"   /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/loader_weight_sm/STATE_Register
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/loader_weight_sm/weight_latch
add wave                 /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/o_wload00
add wave                 /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/o_wload04

# ── Memorias SPI ──────────────────────────────────────
add wave -divider "=== SPI INTERNAL MEMORY ==="
add wave -radix hexadecimal /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/image_mem
add wave -radix hexadecimal /TB_CNNver3/CNNver3_u0/spi_cnn_slave_8_u0/weight_mem

# ── Registros de Imagen ───────────────────────────────
add wave -divider "=== IMAGE REGISTERS (10 x 30b) ==="
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u0/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u1/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u2/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u3/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u4/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u5/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u6/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u7/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u8/Register_Imag_DataOutBUS
add wave -radix hexadecimal -group "IMG_REG" /TB_CNNver3/CNNver3_u0/register_imag_u9/Register_Imag_DataOutBUS

# ── Registros de Pesos ────────────────────────────────
add wave -divider "=== WEIGHT REGISTERS (5 x 15b) ==="
add wave -radix hexadecimal -group "WT_REG" /TB_CNNver3/CNNver3_u0/weight_register_u0/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_CNNver3/CNNver3_u0/weight_register_u1/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_CNNver3/CNNver3_u0/weight_register_u2/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_CNNver3/CNNver3_u0/weight_register_u3/Register_Weight_DataOutBUS
add wave -radix hexadecimal -group "WT_REG" /TB_CNNver3/CNNver3_u0/weight_register_u4/Register_Weight_DataOutBUS

# ── CNN Controller FSM ────────────────────────────────
add wave -divider "=== CNN CONTROLLER FSM ==="
add wave -color "Magenta" -radix unsigned /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/state
add wave -color "Yellow"                  /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_rst
add wave -color "Green"                   /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_start
add wave -color "White"  -radix decimal   /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/kernel_reg
add wave -color "Cyan"                    /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/o_done

# ── CNN Top: cnn_top interno ──────────────────────────
add wave -divider "=== CNN_TOP (interna a cnn_ctrl_u0) ==="
add wave -radix unsigned /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_inst/state
add wave -radix decimal  /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_inst/frag_sel
add wave                 /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_inst/done
add wave -radix decimal -color "White" /TB_CNNver3/CNNver3_u0/cnn_ctrl_u0/cnn_inst/acc

# ── Master Register 1 ─────────────────────────────────
add wave -divider "=== MASTER REGISTER 1 (kernel0 → acc0) ==="
add wave                             /TB_CNNver3/CNNver3_u0/CNN_CTRL_mr1_load_cwire
add wave -radix decimal              /TB_CNNver3/CNNver3_u0/CNN_CTRL_acc0_cwire
add wave -radix decimal -color "Yellow" /TB_CNNver3/CNNver3_u0/MR1_out_cwire

# ── Master Register 2 ─────────────────────────────────
add wave -divider "=== MASTER REGISTER 2 (kernel1 → acc1) ==="
add wave                             /TB_CNNver3/CNNver3_u0/CNN_CTRL_mr2_load_cwire
add wave -radix decimal              /TB_CNNver3/CNNver3_u0/CNN_CTRL_acc1_cwire
add wave -radix decimal -color "Yellow" /TB_CNNver3/CNNver3_u0/MR2_out_cwire

# ── Comparador ────────────────────────────────────────
add wave -divider "=== COMPARADOR (MR1 > MR2) ==="
add wave -color "Green"  /TB_CNNver3/CNNver3_u0/comp_result_cwire
add wave                 /TB_CNNver3/comp_captured

# --- EJECUCION ---
configure wave -timelineunits ns
onerror {resume}
run -all
wave zoom full
