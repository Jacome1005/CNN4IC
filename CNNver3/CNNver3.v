//=======================================================
//  CNNver3 — Top Level
//=======================================================
//  Puertos externos (8):
//    CNNver3_MISO         — resultado final al exterior (SPI)
//    CNNver3_SPICLOCK_50  — reloj SPI
//    CNNver3_SS_N         — Chip Select (activo bajo)
//    CNNver3_MOSI         — datos/comandos del master
//    CNNver3_Reset_InHigh — reset global (activo alto)
//    CNNver3_CMD_Reset    — aborta comando SPI en curso
//    CNNver3_MR1_Load     — DEBUG: pulso activo bajo al cargar acc0 en MR1
//    CNNver3_MR2_Load     — DEBUG: pulso activo bajo al cargar acc1 en MR2
//
//  Flujo de uso desde MCU:
//    cmd 000 → carga imagen 10x10
//    cmd 001 → carga kernel0
//    cmd 010 → START → chip procesa 9 frags con kernel0 → acc0 → MR1
//               ↑ CNNver3_MR1_Load baja un ciclo al terminar
//    cmd 001 → carga kernel1
//    cmd 010 → START → chip procesa 9 frags con kernel1 → acc1 → MR2
//               ↑ CNNver3_MR2_Load baja un ciclo al terminar
//    cmd 110 → lee 1 bit comparador (MR1 > MR2) → clasificación
//
//  Jerarquía:
//    CNNver3
//     ├── spi_cnn_slave_8
//     ├── Register_Imag  ×10
//     ├── Register_Weight ×5
//     ├── SC_STATEMACHINE_CNN_CTRL
//     │     └── cnn_top
//     │           ├── fragment_mux_10x10_6x6
//     │           └── mux_cnn
//     │                 ├── window_mux_6x6_5x5
//     │                 ├── mac_parallel
//     │                 └── progressive_maxpool
//     ├── Master_register (MR1)
//     └── Master_register (MR2)
//=======================================================

module CNNver3 (
    output       CNNver3_MISO,
    input        CNNver3_SPICLOCK_50,
    input        CNNver3_SS_N,
    input        CNNver3_MOSI,
    input        CNNver3_Reset_InHigh,
    input        CNNver3_CMD_Reset,
    output       CNNver3_MR1_Load,     // DEBUG: activo bajo, pulso al cargar MR1
    output       CNNver3_MR2_Load      // DEBUG: activo bajo, pulso al cargar MR2
);

// ═══════════════════════════════════════════
//  PARÁMETROS
// ═══════════════════════════════════════════
localparam DATAWIDTH_BUS        = 8;
localparam DATAWIDTH_BUS_IMAGE  = 10;
localparam DATAWIDTH_BUS_WEIGHT = 5;
localparam BITS_PER_POS         = 3;
localparam DATAWIDTH_BUS_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS; // 30
localparam DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS; // 15

// ═══════════════════════════════════════════
//  WIRES — SPI → Imagen
// ═══════════════════════════════════════════
wire SPI_2_CNN_Start_cwire;

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
//  WIRES — CNN Controller → Master Registers
// ═══════════════════════════════════════════
wire        CNN_CTRL_mr1_load_cwire;   // activo bajo
wire        CNN_CTRL_mr2_load_cwire;   // activo bajo
wire [15:0] CNN_CTRL_acc0_cwire;
wire [15:0] CNN_CTRL_acc1_cwire;

// ═══════════════════════════════════════════
//  WIRES — Master Registers → Comparador
// ═══════════════════════════════════════════
wire [15:0] MR1_out_cwire;
wire [15:0] MR2_out_cwire;
wire        comp_result_cwire;

// ═══════════════════════════════════════════
//  PINES DE DEBUG
//  Los loads se exponen directamente como pines
//  de salida para observación con osciloscopio
// ═══════════════════════════════════════════
assign CNNver3_MR1_Load = CNN_CTRL_mr1_load_cwire;
assign CNNver3_MR2_Load = CNN_CTRL_mr2_load_cwire;

// ═══════════════════════════════════════════
//  COMPARADOR (combinacional, signed 16 bits)
//  comp_result = 1 si MR1 > MR2 (kernel0 gana)
//              = 0 si MR1 <= MR2 (kernel1 gana)
// ═══════════════════════════════════════════
assign comp_result_cwire = ($signed(MR1_out_cwire) > $signed(MR2_out_cwire)) ? 1'b1 : 1'b0;

// ═══════════════════════x════════════════════════════════════════
// 1. SPI Slave
// ═══════════════════════════════════════════════════════════════
spi_cnn_slave_8 #(
    .DATAWIDTH_BUS       (DATAWIDTH_BUS),
    .DATAWIDTH_BUS_IMAGE (DATAWIDTH_BUS_IMAGE),
    .DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),
    .BITS_PER_POS        (BITS_PER_POS)
) spi_cnn_slave_8_u0 (
    .i_SPI_Clk   (CNNver3_SPICLOCK_50),
    .i_SPI_CS_n  (CNNver3_SS_N),
    .i_SPI_MOSI  (CNNver3_MOSI),
    .o_SPI_MISO  (CNNver3_MISO),
    .i_RESET     (CNNver3_Reset_InHigh),
    .i_cmd_reset (CNNver3_CMD_Reset),
    .o_start_cnn (SPI_2_CNN_Start_cwire),
    .o_save_accum(),        // no utilizado en esta versión
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
    .i_cnn_result (MR1_out_cwire),     // cmd 011 → MR1 (acc0)
    .i_comp_result(comp_result_cwire),  // cmd 110 → clasificación
    // MaxPool (no utilizado en esta versión)
    .o_mp_data(),
    .o_mp_load()
);

// ═══════════════════════════════════════════════════════════════
// 2. Registros de Imagen (10 × Register_Imag — 30 bits)
// ═══════════════════════════════════════════════════════════════
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u0 (
    .Register_Imag_DataInBUS(SPI_2_row00_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u0),
    .Register_Imag_DataOutBUS(RegImag_u0_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u1 (
    .Register_Imag_DataInBUS(SPI_2_row01_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u1),
    .Register_Imag_DataOutBUS(RegImag_u1_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u2 (
    .Register_Imag_DataInBUS(SPI_2_row02_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u2),
    .Register_Imag_DataOutBUS(RegImag_u2_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u3 (
    .Register_Imag_DataInBUS(SPI_2_row03_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u3),
    .Register_Imag_DataOutBUS(RegImag_u3_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u4 (
    .Register_Imag_DataInBUS(SPI_2_row04_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u4),
    .Register_Imag_DataOutBUS(RegImag_u4_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u5 (
    .Register_Imag_DataInBUS(SPI_2_row05_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u5),
    .Register_Imag_DataOutBUS(RegImag_u5_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u6 (
    .Register_Imag_DataInBUS(SPI_2_row06_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u6),
    .Register_Imag_DataOutBUS(RegImag_u6_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u7 (
    .Register_Imag_DataInBUS(SPI_2_row07_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u7),
    .Register_Imag_DataOutBUS(RegImag_u7_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u8 (
    .Register_Imag_DataInBUS(SPI_2_row08_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u8),
    .Register_Imag_DataOutBUS(RegImag_u8_out));
Register_Imag #(.DATAWIDTH_BUS_IMAGE(DATAWIDTH_BUS_IMAGE),.BITS_PER_POS(BITS_PER_POS)) register_imag_u9 (
    .Register_Imag_DataInBUS(SPI_2_row09_cwire), .Register_Imag_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Imag_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Imag_Load_InLow(load_img_u9),
    .Register_Imag_DataOutBUS(RegImag_u9_out));

// ═══════════════════════════════════════════════════════════════
// 3. Registros de Pesos (5 × Register_Weight — 15 bits)
// ═══════════════════════════════════════════════════════════════
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u0 (
    .Register_Weight_DataInBUS(SPI_2_wrow00_cwire), .Register_Weight_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Weight_Load_InLow(wload_u0),
    .Register_Weight_DataOutBUS(RegWgt_u0_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u1 (
    .Register_Weight_DataInBUS(SPI_2_wrow01_cwire), .Register_Weight_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Weight_Load_InLow(wload_u1),
    .Register_Weight_DataOutBUS(RegWgt_u1_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u2 (
    .Register_Weight_DataInBUS(SPI_2_wrow02_cwire), .Register_Weight_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Weight_Load_InLow(wload_u2),
    .Register_Weight_DataOutBUS(RegWgt_u2_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u3 (
    .Register_Weight_DataInBUS(SPI_2_wrow03_cwire), .Register_Weight_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Weight_Load_InLow(wload_u3),
    .Register_Weight_DataOutBUS(RegWgt_u3_out));
Register_Weight #(.DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),.BITS_PER_POS(BITS_PER_POS)) weight_register_u4 (
    .Register_Weight_DataInBUS(SPI_2_wrow04_cwire), .Register_Weight_CLOCK(CNNver3_SPICLOCK_50),
    .Register_Weight_Reset_InHigh(CNNver3_Reset_InHigh), .Register_Weight_Load_InLow(wload_u4),
    .Register_Weight_DataOutBUS(RegWgt_u4_out));

// ═══════════════════════════════════════════════════════════════
// 4. Controlador CNN
// ═══════════════════════════════════════════════════════════════
SC_STATEMACHINE_CNN_CTRL cnn_ctrl_u0 (
    .i_CLOCK    (CNNver3_SPICLOCK_50),
    .i_RESET    (CNNver3_Reset_InHigh),
    .i_START_CNN(SPI_2_CNN_Start_cwire),
    // Imagen
    .i_row00(RegImag_u0_out), .i_row01(RegImag_u1_out),
    .i_row02(RegImag_u2_out), .i_row03(RegImag_u3_out),
    .i_row04(RegImag_u4_out), .i_row05(RegImag_u5_out),
    .i_row06(RegImag_u6_out), .i_row07(RegImag_u7_out),
    .i_row08(RegImag_u8_out), .i_row09(RegImag_u9_out),
    // Pesos
    .i_wrow00(RegWgt_u0_out), .i_wrow01(RegWgt_u1_out),
    .i_wrow02(RegWgt_u2_out), .i_wrow03(RegWgt_u3_out),
    .i_wrow04(RegWgt_u4_out),
    // Salidas
    .o_acc0    (CNN_CTRL_acc0_cwire),
    .o_acc1    (CNN_CTRL_acc1_cwire),
    .o_mr1_load(CNN_CTRL_mr1_load_cwire),
    .o_mr2_load(CNN_CTRL_mr2_load_cwire),
    .o_done    ()
);

// ═══════════════════════════════════════════════════════════════
// 5. Master Register 1 — acumulador kernel0
// ═══════════════════════════════════════════════════════════════
Master_register #(.DATAWIDTH_BUS(16)) master_reg1_u0 (
    .Master_register_DataInBUS   (CNN_CTRL_acc0_cwire),
    .Master_register_CLOCK       (CNNver3_SPICLOCK_50),
    .Master_register_Reset_InHigh(CNNver3_Reset_InHigh),
    .Master_register_Load_InLow  (CNN_CTRL_mr1_load_cwire),
    .Master_register_DataOutBUS  (MR1_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 6. Master Register 2 — acumulador kernel1
// ═══════════════════════════════════════════════════════════════
Master_register #(.DATAWIDTH_BUS(16)) master_reg2_u0 (
    .Master_register_DataInBUS   (CNN_CTRL_acc1_cwire),
    .Master_register_CLOCK       (CNNver3_SPICLOCK_50),
    .Master_register_Reset_InHigh(CNNver3_Reset_InHigh),
    .Master_register_Load_InLow  (CNN_CTRL_mr2_load_cwire),
    .Master_register_DataOutBUS  (MR2_out_cwire)
);

endmodule