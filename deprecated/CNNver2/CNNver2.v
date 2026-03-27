//=======================================================
//  CNNver2 — Top Level final
//=======================================================
//  Puertos externos (solo 6):
//    CNNver2_MISO        — resultado final al exterior
//    CNNver2_SPICLOCK_50 — reloj SPI
//    CNNver2_SS_N        — Chip Select (activo bajo)
//    CNNver2_MOSI        — datos/comandos del master
//    CNNver2_Reset_InHigh — reset global (activo alto)
//    CNNver2_CMD_Reset   — aborta comando SPI en curso
//
//  Flujo de datos:
//
//  LOAD_IMAGE  (cmd 000): MOSI → image_mem → Register_Imag×10 → px_flat
//  LOAD_WEIGHTS(cmd 001): MOSI → weight_mem → Register_Weight×5 → w_flat
//  START_CNN   (cmd 010): FSM IDLE→LOAD→PIPE1→PIPE2→CAPTURE_CNN
//  READ_RESULT (cmd 011): main_MR → MISO (16 bits, resultado CNN sign-ext)
//  LOAD_MAXPOOL(cmd 100): MOSI → maxpool_shift(4 val) → o_max → accum_maxpool
//  SAVE_ACCUM  (cmd 101): FSM→STATE_SAVE_ACCUM:
//                           pass 0 → accum → MR1 (20b) + clear accum
//                           pass 1 → accum → MR2 (20b) + clear accum
//  READ_COMPARE(cmd 110): (MR1>MR2) → MISO (1 bit)
//
//  Modulos nuevos respecto a version anterior:
//    - accum_maxpool (acumula resultados de MaxPool)
//    - master_reg1 / master_reg2 (20 bits, para acumulador)
//    - Comparador combinacional (signed 20b)
//
//  Modulos removidos/simplificados:
//    - CNNver2_result_pos ya no existe como pin externo
//=======================================================

module CNNver2 (
    output  CNNver2_MISO,
    input   CNNver2_SPICLOCK_50,
    input   CNNver2_SS_N,
    input   CNNver2_MOSI,
    input   CNNver2_Reset_InHigh,
    input   CNNver2_CMD_Reset
);

// ═══════════════════════════════════════════
//  PARAMETROS
// ═══════════════════════════════════════════
localparam DATAWIDTH_BUS        = 8;
localparam DATAWIDTH_BUS_IMAGE  = 10;
localparam DATAWIDTH_BUS_WEIGHT = 5;
localparam BITS_PER_POS         = 3;
localparam DATAWIDTH_BUS_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS; // 30
localparam DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS; // 15
localparam ACCUM_WIDTH          = 20; // bits del acumulador (cubre 36 x ±1023)

// ═══════════════════════════════════════════
//  WIRES — SPI → Imagen
// ═══════════════════════════════════════════
wire SPI_2_CNN_Start_cwire;
wire SPI_save_accum_cwire;   // ★ NUEVO: pulso SAVE_ACCUM desde SPI

wire [DATAWIDTH_BUS_FULL-1:0] SPI_2_row00_cwire, SPI_2_row01_cwire;
wire [DATAWIDTH_BUS_FULL-1:0] SPI_2_row02_cwire, SPI_2_row03_cwire;
wire [DATAWIDTH_BUS_FULL-1:0] SPI_2_row04_cwire, SPI_2_row05_cwire;
wire [DATAWIDTH_BUS_FULL-1:0] SPI_2_row06_cwire, SPI_2_row07_cwire;
wire [DATAWIDTH_BUS_FULL-1:0] SPI_2_row08_cwire, SPI_2_row09_cwire;

wire [DATAWIDTH_BUS_FULL-1:0] RegImag_u0_out, RegImag_u1_out;
wire [DATAWIDTH_BUS_FULL-1:0] RegImag_u2_out, RegImag_u3_out;
wire [DATAWIDTH_BUS_FULL-1:0] RegImag_u4_out, RegImag_u5_out;
wire [DATAWIDTH_BUS_FULL-1:0] RegImag_u6_out, RegImag_u7_out;
wire [DATAWIDTH_BUS_FULL-1:0] RegImag_u8_out, RegImag_u9_out;

wire load_img_u0, load_img_u1, load_img_u2, load_img_u3, load_img_u4;
wire load_img_u5, load_img_u6, load_img_u7, load_img_u8, load_img_u9;

// ═══════════════════════════════════════════
//  WIRES — SPI → Pesos
// ═══════════════════════════════════════════
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow00_cwire, SPI_2_wrow01_cwire;
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow02_cwire, SPI_2_wrow03_cwire;
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow04_cwire;

wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u0_out, RegWgt_u1_out;
wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u2_out, RegWgt_u3_out;
wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u4_out;

wire wload_u0, wload_u1, wload_u2, wload_u3, wload_u4;

// ═══════════════════════════════════════════
//  WIRES — CNN Controller
// ═══════════════════════════════════════════
wire        CNN_CTRL_rst_cwire;
wire        CNN_CTRL_weight_load_cwire;
wire        CNN_CTRL_result_load_cwire;
wire [1:0]  CNN_CTRL_result_sel_cwire;
wire        CNN_CTRL_accum_clear_cwire;  // ★ NUEVO
wire        CNN_CTRL_mr1_load_cwire;     // ★ NUEVO (activo bajo)
wire        CNN_CTRL_mr2_load_cwire;     // ★ NUEVO (activo bajo)

// ═══════════════════════════════════════════
//  WIRES — CNN Core
// ═══════════════════════════════════════════
wire signed [10:0] CNN_y_out_cwire;
wire               CNN_ready_cwire;
wire signed [14:0] CNN_additional_out_cwire;

// ═══════════════════════════════════════════
//  WIRES — MaxPool
// ═══════════════════════════════════════════
wire [10:0]        SPI_mp_data_cwire;
wire               SPI_mp_load_cwire;
wire signed [10:0] MaxPool_result_cwire;
wire               MaxPool_valid_cwire;

// ═══════════════════════════════════════════
//  WIRES — Acumulador + MR1 + MR2 + Comparador  ★ NUEVOS
// ═══════════════════════════════════════════
wire signed [ACCUM_WIDTH-1:0] Accum_out_cwire;    // salida del acumulador (20b)
wire signed [ACCUM_WIDTH-1:0] MR1_out_cwire;      // Master Register 1 (20b)
wire signed [ACCUM_WIDTH-1:0] MR2_out_cwire;      // Master Register 2 (20b)
wire                          comp_result_cwire;   // 1 bit: MR1 > MR2

// ═══════════════════════════════════════════
//  WIRES — Main Master Register (CNN result para READ RESULT)
// ═══════════════════════════════════════════
wire [15:0] Master_Result_out_cwire;   // 16 bits → SPI MISO (cmd 011)
wire [15:0] master_data_in_cwire;      // entrada al main MR desde result_mux

// ═══════════════════════════════════════════
//  EMPAQUETADO DE IMAGEN Y KERNEL
// ═══════════════════════════════════════════
wire [299:0] px_flat_cwire;
assign px_flat_cwire = {
    RegImag_u9_out, RegImag_u8_out, RegImag_u7_out, RegImag_u6_out, RegImag_u5_out,
    RegImag_u4_out, RegImag_u3_out, RegImag_u2_out, RegImag_u1_out, RegImag_u0_out
};

wire signed [74:0] w_flat_cwire;
assign w_flat_cwire = {
    RegWgt_u4_out, RegWgt_u3_out, RegWgt_u2_out, RegWgt_u1_out, RegWgt_u0_out
};

// ═══════════════════════════════════════════
//  COMPARADOR (combinacional, signed 20 bits)  ★ NUEVO
//  comp_result = 1 si MR1 > MR2, 0 en caso contrario (incluye igual)
// ═══════════════════════════════════════════
assign comp_result_cwire = ($signed(MR1_out_cwire) > $signed(MR2_out_cwire)) ? 1'b1 : 1'b0;

// ═══════════════════════════════════════════════════════════════
// 1. SPI Slave
// ═══════════════════════════════════════════════════════════════
spi_cnn_slave_8 #(
    .DATAWIDTH_BUS       (DATAWIDTH_BUS),
    .DATAWIDTH_BUS_IMAGE (DATAWIDTH_BUS_IMAGE),
    .DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),
    .BITS_PER_POS        (BITS_PER_POS)
) spi_cnn_slave_8_u0 (
    .i_SPI_Clk   (CNNver2_SPICLOCK_50),
    .i_SPI_CS_n  (CNNver2_SS_N),
    .i_SPI_MOSI  (CNNver2_MOSI),
    .o_SPI_MISO  (CNNver2_MISO),
    .i_RESET     (CNNver2_Reset_InHigh),
    .i_cmd_reset (CNNver2_CMD_Reset),
    .o_start_cnn (SPI_2_CNN_Start_cwire),
    .o_save_accum(SPI_save_accum_cwire),   // ★ NUEVO
    // Imagen
    .o_row00(SPI_2_row00_cwire), .o_row01(SPI_2_row01_cwire),
    .o_row02(SPI_2_row02_cwire), .o_row03(SPI_2_row03_cwire),
    .o_row04(SPI_2_row04_cwire), .o_row05(SPI_2_row05_cwire),
    .o_row06(SPI_2_row06_cwire), .o_row07(SPI_2_row07_cwire),
    .o_row08(SPI_2_row08_cwire), .o_row09(SPI_2_row09_cwire),
    .o_load00(load_img_u0), .o_load01(load_img_u1),
    .o_load02(load_img_u2), .o_load03(load_img_u3),
    .o_load04(load_img_u4), .o_load05(load_img_u5),
    .o_load06(load_img_u6), .o_load07(load_img_u7),
    .o_load08(load_img_u8), .o_load09(load_img_u9),
    // Pesos
    .o_wrow00(SPI_2_wrow00_cwire), .o_wrow01(SPI_2_wrow01_cwire),
    .o_wrow02(SPI_2_wrow02_cwire), .o_wrow03(SPI_2_wrow03_cwire),
    .o_wrow04(SPI_2_wrow04_cwire),
    .o_wload00(wload_u0), .o_wload01(wload_u1),
    .o_wload02(wload_u2), .o_wload03(wload_u3),
    .o_wload04(wload_u4),
    // MISO sources
    .i_cnn_result  (Master_Result_out_cwire),  // 16 bits para cmd 011
    .i_comp_result (comp_result_cwire),         // ★ NUEVO: 1 bit para cmd 110
    // MaxPool
    .o_mp_data(SPI_mp_data_cwire),
    .o_mp_load(SPI_mp_load_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 2. Registros de Imagen (10 x Register_Imag — 30 bits)
// ═══════════════════════════════════════════════════════════════
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u0 (
    .Register_Imag_DataInBUS(SPI_2_row00_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u0),
    .Register_Imag_DataOutBUS(RegImag_u0_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u1 (
    .Register_Imag_DataInBUS(SPI_2_row01_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u1),
    .Register_Imag_DataOutBUS(RegImag_u1_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u2 (
    .Register_Imag_DataInBUS(SPI_2_row02_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u2),
    .Register_Imag_DataOutBUS(RegImag_u2_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u3 (
    .Register_Imag_DataInBUS(SPI_2_row03_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u3),
    .Register_Imag_DataOutBUS(RegImag_u3_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u4 (
    .Register_Imag_DataInBUS(SPI_2_row04_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u4),
    .Register_Imag_DataOutBUS(RegImag_u4_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u5 (
    .Register_Imag_DataInBUS(SPI_2_row05_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u5),
    .Register_Imag_DataOutBUS(RegImag_u5_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u6 (
    .Register_Imag_DataInBUS(SPI_2_row06_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u6),
    .Register_Imag_DataOutBUS(RegImag_u6_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u7 (
    .Register_Imag_DataInBUS(SPI_2_row07_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u7),
    .Register_Imag_DataOutBUS(RegImag_u7_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u8 (
    .Register_Imag_DataInBUS(SPI_2_row08_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u8),
    .Register_Imag_DataOutBUS(RegImag_u8_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u9 (
    .Register_Imag_DataInBUS(SPI_2_row09_cwire), .Register_Imag_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u9),
    .Register_Imag_DataOutBUS(RegImag_u9_out));

// ═══════════════════════════════════════════════════════════════
// 3. Registros de Pesos (5 x Register_Weight — 15 bits)
// ═══════════════════════════════════════════════════════════════
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u0 (
    .Register_Weight_DataInBUS(SPI_2_wrow00_cwire), .Register_Weight_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Weight_Load_InLow(wload_u0),
    .Register_Weight_DataOutBUS(RegWgt_u0_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u1 (
    .Register_Weight_DataInBUS(SPI_2_wrow01_cwire), .Register_Weight_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Weight_Load_InLow(wload_u1),
    .Register_Weight_DataOutBUS(RegWgt_u1_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u2 (
    .Register_Weight_DataInBUS(SPI_2_wrow02_cwire), .Register_Weight_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Weight_Load_InLow(wload_u2),
    .Register_Weight_DataOutBUS(RegWgt_u2_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u3 (
    .Register_Weight_DataInBUS(SPI_2_wrow03_cwire), .Register_Weight_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Weight_Load_InLow(wload_u3),
    .Register_Weight_DataOutBUS(RegWgt_u3_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u4 (
    .Register_Weight_DataInBUS(SPI_2_wrow04_cwire), .Register_Weight_CLOCK(CNNver2_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver2_Reset_InHigh), .Register_Weight_Load_InLow(wload_u4),
    .Register_Weight_DataOutBUS(RegWgt_u4_out));

// ═══════════════════════════════════════════════════════════════
// 4. Controlador CNN
// ═══════════════════════════════════════════════════════════════
SC_STATEMACHINE_CNN_CTRL cnn_ctrl_sm (
    .i_CLOCK        (CNNver2_SPICLOCK_50),
    .i_RESET        (CNNver2_Reset_InHigh),
    .i_START_CNN    (SPI_2_CNN_Start_cwire),
    .i_cnn_ready    (CNN_ready_cwire),
    .i_SAVE_ACCUM   (SPI_save_accum_cwire),        // ★ NUEVO
    .o_cnn_rst      (CNN_CTRL_rst_cwire),
    .o_weight_load  (CNN_CTRL_weight_load_cwire),
    .o_result_load  (CNN_CTRL_result_load_cwire),
    .o_result_sel   (CNN_CTRL_result_sel_cwire),
    .o_accum_clear  (CNN_CTRL_accum_clear_cwire),  // ★ NUEVO
    .o_mr1_load     (CNN_CTRL_mr1_load_cwire),     // ★ NUEVO
    .o_mr2_load     (CNN_CTRL_mr2_load_cwire)      // ★ NUEVO
);

// ═══════════════════════════════════════════════════════════════
// 5. Nucleo CNN
// ═══════════════════════════════════════════════════════════════
cnn_conv_v2 #(.R_OFF(0), .C_OFF(0)) cnn_conv_v2_u0 (
    .clk            (CNNver2_SPICLOCK_50),
    .rst            (CNN_CTRL_rst_cwire),
    .px_flat_in     (px_flat_cwire),
    .w_flat_in      (w_flat_cwire),
    .additional_in_0(11'sd0),
    .additional_in_1(11'sd0),
    .additional_in_2(11'sd0),
    .additional_in_3(11'sd0),
    .y_out          (CNN_y_out_cwire),
    .ready          (CNN_ready_cwire),
    .additional_out (CNN_additional_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 6. MaxPool Shift Register
//    Recibe 4 valores de 11 bits. Calcula el maximo y pulsa o_valid.
// ═══════════════════════════════════════════════════════════════
maxpool_shift maxpool_shift_u0 (
    .i_clk  (CNNver2_SPICLOCK_50),
    .i_rst  (CNNver2_Reset_InHigh),
    .i_data ({5'b0, SPI_mp_data_cwire}),
    .i_load (SPI_mp_load_cwire),
    .o_max  (MaxPool_result_cwire),
    .o_valid(MaxPool_valid_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 7. Acumulador de MaxPool  ★ NUEVO
//    Suma resultados de maxpool_shift.o_max automaticamente.
//    Se limpia cuando CNN_CTRL entra en STATE_SAVE_ACCUM.
// ═══════════════════════════════════════════════════════════════
accum_maxpool #(.ACCUM_WIDTH(ACCUM_WIDTH)) accum_u0 (
    .i_clk  (CNNver2_SPICLOCK_50),
    .i_rst  (CNNver2_Reset_InHigh),
    .i_data (MaxPool_result_cwire),
    .i_valid(MaxPool_valid_cwire),
    .i_clear(CNN_CTRL_accum_clear_cwire),
    .o_accum(Accum_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 8. Master Register 1 (acumulador pass 0)  ★ NUEVO
//    Carga cuando FSM → STATE_SAVE_ACCUM con pass_sel=0
// ═══════════════════════════════════════════════════════════════
Master_register #(.DATAWIDTH_BUS(ACCUM_WIDTH)) master_reg1_u0 (
    .Master_register_DataInBUS   (Accum_out_cwire),
    .Master_register_CLOCK       (CNNver2_SPICLOCK_50),
    .Master_register_Reset_InHigh(CNNver2_Reset_InHigh),
    .Master_register_Load_InLow  (CNN_CTRL_mr1_load_cwire),
    .Master_register_DataOutBUS  (MR1_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 9. Master Register 2 (acumulador pass 1)  ★ NUEVO
//    Carga cuando FSM → STATE_SAVE_ACCUM con pass_sel=1
// ═══════════════════════════════════════════════════════════════
Master_register #(.DATAWIDTH_BUS(ACCUM_WIDTH)) master_reg2_u0 (
    .Master_register_DataInBUS   (Accum_out_cwire),
    .Master_register_CLOCK       (CNNver2_SPICLOCK_50),
    .Master_register_Reset_InHigh(CNNver2_Reset_InHigh),
    .Master_register_Load_InLow  (CNN_CTRL_mr2_load_cwire),
    .Master_register_DataOutBUS  (MR2_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 10. Mux 4:1 de Resultados — para main Master_register (CNN path)
//     sel siempre 2'b00 en operacion normal (CNN sign-ext → MR)
// ═══════════════════════════════════════════════════════════════
result_mux_4to1 result_mux_u0 (
    .i_sel           (CNN_CTRL_result_sel_cwire),
    .i_cnn_result    (CNN_y_out_cwire),
    .i_maxpool_result(MaxPool_result_cwire),
    .i_accum_result  (16'd0),          // no utilizado en esta version
    .i_comp_result   (comp_result_cwire),
    .o_mux_out       (master_data_in_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 11. Main Master Register — Resultado CNN para READ RESULT
//     Retiene el resultado de la convolucion (16 bits signed).
//     Alimenta i_cnn_result del SPI slave → MISO en cmd 011.
// ═══════════════════════════════════════════════════════════════
Master_register #(.DATAWIDTH_BUS(16)) master_reg_u0 (
    .Master_register_DataInBUS   (master_data_in_cwire),
    .Master_register_CLOCK       (CNNver2_SPICLOCK_50),
    .Master_register_Reset_InHigh(CNNver2_Reset_InHigh),
    .Master_register_Load_InLow  (CNN_CTRL_result_load_cwire),
    .Master_register_DataOutBUS  (Master_Result_out_cwire)
);

endmodule