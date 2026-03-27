# ═══════════════════════════════════════════════════════
#  TB_Realistic.do — Testbench de timing realista
#  Questa/ModelSim
# ═══════════════════════════════════════════════════════
#  COEXISTENCIA con Testbench_CNNver2.do:
#    - Compila en la MISMA library "work"
#    - Modulo top: TB_REALISTIC (distinto de TB_SYSTEM)
#    - Para correr el ideal:    vsim work.TB_SYSTEM
#    - Para correr el realista: vsim work.TB_REALISTIC
#    - Ambos usan el mismo DUT (CNNver2 compilado una vez)
#
#  Uso recomendado:
#    1. Compilar todo una vez (esta .do compila todo)
#    2. Luego: vsim work.TB_SYSTEM    -> testbench ideal
#              vsim work.TB_REALISTIC -> testbench realista
#
#  Alternativamente desde transcript Questa:
#    do Testbench_CNNver2.do    <- compila y simula TB_SYSTEM
#    do TB_Realistic.do         <- compila y simula TB_REALISTIC
# ═══════════════════════════════════════════════════════

# --- LIMPIEZA (solo si se corre stand-alone) ---
# Comentar estas 3 lineas si ya se corrio Testbench_CNNver2.do
# y no se quiere recompilar todo desde cero.
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
vlog ../../rtl/maxpool_shift.v
vlog ../../rtl/result_mux_4to1.v
vlog ../../rtl/accum_maxpool.v

# Nivel 2: state machines (con fix row_latch / weight_latch)
vlog ../../rtl/SC_STATEMACHINE_IMAGE_LOADER.v
vlog ../../rtl/SC_STATEMACHINE_WEIGHT_LOADER.v

# Nivel 3: CNN core
vlog ../../rtl/cnn_v2.v
vlog ../../rtl/cnn_conv_v2.v

# Nivel 4: controlador CNN
vlog ../../rtl/SC_STATEMACHINE_CNN_CTRL.v

# Nivel 5: SPI slave
vlog ../../rtl/spi_cnn_slave_8.v

# Nivel 6: top module
vlog ../../CNNver2.v

# Nivel 7: AMBOS testbenches (coexisten en work)
vlog Testbench_CNNver2.vt   ;# TB_SYSTEM   (ideal)
vlog TB_Realistic.vt            ;# TB_REALISTIC (realista)

# --- SELECCION: simular el realista ---
vsim -voptargs="+acc" work.TB_REALISTIC

# ═══════════════════════════════════════════════════════
#  ONDAS FOCALIZADAS EN TIMING
#  (diferente set de ondas que el testbench ideal:
#   muestra el jitter de MOSI, CS, y los registros
#   clave para verificar comportamiento bajo timing real)
# ═══════════════════════════════════════════════════════

# ── Interfaz externa (timing critico) ─────────────────
add wave -divider "=== INTERFAZ SPI (timing variable) ==="
add wave -color "Yellow" -label "SCK"    /TB_REALISTIC/CLK
add wave -color "Cyan"   -label "SS_N"   /TB_REALISTIC/SS_N
add wave -color "Orange" -label "MOSI"   /TB_REALISTIC/MOSI
add wave -color "Green"  -label "MISO"   /TB_REALISTIC/MISO

# ── Parametros de timing actuales ─────────────────────
add wave -divider "=== TIMING INTERNO TESTBENCH ==="
add wave -radix decimal -label "cur_tck_ns"   /TB_REALISTIC/cur_tck
add wave -radix decimal -label "tsetup_cur_ns" /TB_REALISTIC/tsetup_cur
add wave -radix decimal -label "tsetup_min"    /TB_REALISTIC/tsetup_min_seen
add wave -radix decimal -label "rand_sample"   /TB_REALISTIC/rand_sample_offset

# ── SPI control interno ────────────────────────────────
add wave -divider "=== SPI SLAVE INTERNO ==="
add wave -label "valid_clk" /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/valid_clk
add wave -radix binary  -label "cmd"       /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/cmd
add wave -radix decimal -label "bit_count" /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/bit_count
add wave -label "o_start_cnn"  /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/o_start_cnn
add wave -label "o_save_accum" /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/o_save_accum

# ── Image / Weight loaders (ver el row_latch corregido) ─
add wave -divider "=== LOADERS (row_latch fix) ==="
add wave -label "img_STATE"    /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/STATE_Register
add wave -radix decimal -label "row_latch" /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/loader_image_sm/row_latch
add wave -label "o_load09"     /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/o_load09
add wave -label "wgt_STATE"    /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/loader_weight_sm/STATE_Register
add wave -radix decimal -label "weight_latch" /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/loader_weight_sm/weight_latch
add wave -label "o_wload04"    /TB_REALISTIC/CNNver2_u0/spi_cnn_slave_8_u0/o_wload04

# ── Registros clave (primero y ultimo) ────────────────
add wave -divider "=== REGISTROS IMAGEN [0] y [9] ==="
add wave -radix hex -label "imag[0]" /TB_REALISTIC/CNNver2_u0/register_imag_u0/Register_Imag_DataOutBUS
add wave -radix hex -label "imag[9]" /TB_REALISTIC/CNNver2_u0/register_imag_u9/Register_Imag_DataOutBUS
add wave -divider "=== REGISTROS PESOS [0] y [4] ==="
add wave -radix hex -label "wgt[0]"  /TB_REALISTIC/CNNver2_u0/weight_register_u0/Register_Weight_DataOutBUS
add wave -radix hex -label "wgt[4]"  /TB_REALISTIC/CNNver2_u0/weight_register_u4/Register_Weight_DataOutBUS

# ── CNN y pipeline ─────────────────────────────────────
add wave -divider "=== CNN PIPELINE ==="
add wave -radix unsigned -label "FSM_state"   /TB_REALISTIC/CNNver2_u0/cnn_ctrl_sm/STATE_Register
add wave -label "cnn_rst"                      /TB_REALISTIC/CNNver2_u0/cnn_ctrl_sm/o_cnn_rst
add wave -label "cnn_ready"                    /TB_REALISTIC/CNNver2_u0/CNN_ready_cwire
add wave -radix decimal -label "y_out"         /TB_REALISTIC/CNNver2_u0/CNN_y_out_cwire
add wave -radix decimal -label "main_MR"       /TB_REALISTIC/CNNver2_u0/Master_Result_out_cwire

# ── MaxPool + Acumulador + MR1/MR2 ────────────────────
add wave -divider "=== MAXPOOL + ACCUM ==="
add wave -label "mp_valid"                     /TB_REALISTIC/CNNver2_u0/MaxPool_valid_cwire
add wave -radix decimal -label "mp_max"        /TB_REALISTIC/CNNver2_u0/MaxPool_result_cwire
add wave -radix decimal -label "accum"         /TB_REALISTIC/CNNver2_u0/accum_u0/o_accum
add wave -label "accum_clear"                  /TB_REALISTIC/CNNver2_u0/accum_u0/i_clear
add wave -radix decimal -label "MR1"           /TB_REALISTIC/CNNver2_u0/MR1_out_cwire
add wave -radix decimal -label "MR2"           /TB_REALISTIC/CNNver2_u0/MR2_out_cwire
add wave -label "pass_sel"                     /TB_REALISTIC/CNNver2_u0/cnn_ctrl_sm/pass_sel

# ── Comparador ────────────────────────────────────────
add wave -divider "=== COMPARADOR ==="
add wave -color "Green" -label "comp_wire"     /TB_REALISTIC/CNNver2_u0/comp_result_cwire
add wave -label "comp_captured"                /TB_REALISTIC/comp_captured
add wave -label "MISO_capturado"               /TB_REALISTIC/miso_captured

# --- EJECUCION ---
configure wave -timelineunits ns
# Mostrar picosegundos en cursores (util para ver jitter de ns)
configure wave -signalnamewidth 1
onerror {resume}
run -all
wave zoom full
