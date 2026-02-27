//=======================================================
//  CNNver2 — Top Level
//=======================================================
//  ★ Cambios en esta versión:
//  1. Añadido DATAWIDTH_BUS_WEIGHT=5, DATAWIDTH_WGT_FULL=15
//  2. Wires de pesos: [14:0] × 5 (antes [7:0] × 8)
//  3. Weight registers: Register_Weight × 5 (antes Register × 8)
//  4. w_flat_packed: 75 bits = {wrow4..wrow0} (antes incorrecto)
//  5. SPI slave: puertos de pesos actualizados ([14:0]×5 + wload×5)
//  6. cnn_conv_v2: px_flat_in = 300 bits ✓, w_flat_in = 75 bits ✓
//=======================================================

module CNNver2 (
    //////////// OUTPUTS //////////
    output 	CNNver2_MISO,
    //////////// INPUTS //////////
    input  	CNNver2_SPICLOCK_50,
    input  	CNNver2_SS_N,
    input  	CNNver2_MOSI,
	input	CNNver2_Reset_InHigh,
    // ── Tipo de dato — pin físico ─────────────────────
    // La PC/controlador externo pone este valor ANTES de
    // bajar CS_n. La SPI lo muestrea al inicio de cada
    // transacción. Todo el payload MOSI es ya datos puros.
    //
    // 000 → LOAD IMAGE    8 bytes de imagen (5×5 ventana)
    // 001 → LOAD WEIGHTS  8 bytes de pesos  (5×5 kernel)
    // 010 → START CNN     sin payload — lanza convolución
    // 011 → READ RESULT   16 bits MISO desde Master_reg
    // 100 → LOAD MAXPOOL  16 bits por vector (×4 vectores)
    input [2:0]  CNNver2_DataType
);
//////////// PARAMETERS ////////////
localparam DATAWIDTH_BUS        = 8;   // ancho bus SPI estándar (no usado directamente)
localparam DATAWIDTH_BUS_IMAGE  = 10;  // columnas de imagen (pixels por fila)
localparam DATAWIDTH_BUS_WEIGHT = 5;   // columnas del kernel (pesos por fila)
localparam BITS_PER_POS         = 3;   // bits por pixel / peso
localparam DATAWIDTH_BUS_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS; // 30: bits/fila imagen
localparam DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS; // 15: bits/fila kernel

// ═══════════════════════════════════════════════
//  WIRES — SPI → Imagen (10 filas × 30 bits)
// ═══════════════════════════════════════════════
wire SPI_2_CNN_Start_routing_cwire;

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

// ═══════════════════════════════════════════════
//  WIRES — SPI → Pesos (★ 5 filas × 15 bits)
// ═══════════════════════════════════════════════
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow00_cwire, SPI_2_wrow01_cwire;
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow02_cwire, SPI_2_wrow03_cwire;
wire [DATAWIDTH_WGT_FULL-1:0] SPI_2_wrow04_cwire;

wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u0_out, RegWgt_u1_out;
wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u2_out, RegWgt_u3_out;
wire [DATAWIDTH_WGT_FULL-1:0] RegWgt_u4_out;

wire wload_u0, wload_u1, wload_u2, wload_u3, wload_u4;

// ═══════════════════════════════════════════════
//  WIRES — CNN Controller
// ═══════════════════════════════════════════════
wire        CNN_CTRL_rst_routing_cwire;
wire        CNN_CTRL_weight_load_routing_cwire;
wire        CNN_CTRL_result_load_routing_cwire;
wire [1:0]  CNN_CTRL_result_sel_routing_cwire;

// ═══════════════════════════════════════════════
//  WIRES — CNN Core
// ═══════════════════════════════════════════════
wire signed [10:0] CNN_y_out_cwire;
wire               CNN_ready_cwire;
wire signed [14:0] CNN_additional_out_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — MaxPool shift register
// ═════════════════════════════════════════════════════
wire [10:0]         SPI_mp_data_routing_cwire;
wire                SPI_mp_load_routing_cwire;
wire signed [10:0]  MaxPool_result_routing_cwire;
wire                MaxPool_valid_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — Master Register resultado (16 bits)
// ═════════════════════════════════════════════════════
wire [15:0] Master_Result_DataOutBUS_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — Mux 4:1 salida → Master_register
// ═════════════════════════════════════════════════════
wire [15:0] master_data_in_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — Entradas futuras al Mux (a tierra hasta crear módulos)
//  ← Reemplazar cuando existan Acumulador y Comparador
// ═════════════════════════════════════════════════════
wire [15:0] Accum_result_routing_cwire;
assign Accum_result_routing_cwire = 16'd0;

wire Comp_result_routing_cwire;
assign Comp_result_routing_cwire  = 1'b0;


// ═══════════════════════════════════════════════
//  EMPAQUETADO DE IMAGEN Y KERNEL
// ═══════════════════════════════════════════════
//  px_flat: 300 bits — fila 0 en bits bajos, fila 9 en bits altos
//  Pixel (fila r, col c) = px_flat[r*30 + c*3 +: 3]
wire [299:0] px_flat_cwire;
assign px_flat_cwire = {
    RegImag_u9_out,   // bits [299:270]
    RegImag_u8_out,   // bits [269:240]
    RegImag_u7_out,   // bits [239:210]
    RegImag_u6_out,   // bits [209:180]
    RegImag_u5_out,   // bits [179:150]
    RegImag_u4_out,   // bits [149:120]
    RegImag_u3_out,   // bits [119:90]
    RegImag_u2_out,   // bits  [89:60]
    RegImag_u1_out,   // bits  [59:30]
    RegImag_u0_out    // bits  [29:0]
};

//  w_flat: 75 bits — fila 0 en bits bajos, fila 4 en bits altos
//  Peso (fila kr, col kc) = w_flat[(kr*5+kc)*3 +: 3]
wire signed [74:0] w_flat_cwire;
assign w_flat_cwire = {
    RegWgt_u4_out,    // bits [74:60] — fila 4 del kernel
    RegWgt_u3_out,    // bits [59:45]
    RegWgt_u2_out,    // bits [44:30]
    RegWgt_u1_out,    // bits [29:15]
    RegWgt_u0_out     // bits [14:0]  — fila 0 del kernel
};

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
    .o_start_cnn (SPI_2_CNN_Start_routing_cwire),
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
    // ★ Pesos (5 filas × 15 bits)
    .o_wrow00(SPI_2_wrow00_cwire), .o_wrow01(SPI_2_wrow01_cwire),
    .o_wrow02(SPI_2_wrow02_cwire), .o_wrow03(SPI_2_wrow03_cwire),
    .o_wrow04(SPI_2_wrow04_cwire),
    .o_wload00(wload_u0), .o_wload01(wload_u1),
    .o_wload02(wload_u2), .o_wload03(wload_u3),
    .o_wload04(wload_u4),
    // Resultado
    .i_cnn_result(CNN_Result_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 2. Registros de Imagen (10 × Register_Imag — 30 bits c/u)
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
// 3. Registros de Pesos (★ 5 × Register_Weight — 15 bits c/u)
//    Carga individual por fila, controlada por SM de pesos del SPI.
//    La señal o_wloadXX del SPI es activa baja y específica por fila.
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
//    (sin cambios — pipeline de 2 ciclos es correcto para cnn_v2)
// ═══════════════════════════════════════════════════════════════
SC_STATEMACHINE_CNN_CTRL cnn_ctrl_sm (
    .i_CLOCK     (CNNver2_SPICLOCK_50),
    .i_RESET     (CNNver2_Reset_InHigh),
    .i_START_CNN (SPI_2_CNN_Start_routing_cwire),
    .o_cnn_rst   (CNN_CTRL_rst_cwire),
    .o_weight_load(),             // No usado: pesos se cargan vía SPI directamente
    .o_result_load(CNN_CTRL_result_load_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 5. Núcleo CNN — convolución 5×5 en posición (R_OFF=0, C_OFF=0)
//    Para otras posiciones, cambiar parámetros R_OFF / C_OFF.
//    Para la convolución completa 6×6 → instanciar 36 copias
//    o añadir un controlador que itere sobre R_OFF y C_OFF.
// ═══════════════════════════════════════════════════════════════
cnn_conv_v2 #(.R_OFF(0), .C_OFF(0)) cnn_conv_v2_u0 (
    .clk            (CNNver2_SPICLOCK_50),
    .rst            (CNN_CTRL_rst_cwire),
    .px_flat_in     (px_flat_cwire),       // 300 bits ★
    .w_flat_in      (w_flat_cwire),        // 75 bits  ★
    .additional_in_0(11'sd0),
    .additional_in_1(11'sd0),
    .additional_in_2(11'sd0),
    .additional_in_3(11'sd0),
    .y_out          (CNN_y_out_cwire),
    .ready          (CNN_ready_cwire),
    .additional_out (CNN_additional_out_cwire)
);

// ═══════════════════════════════════════════════════════════════
// 6. Registro de Resultado CNN (11 bits)
// ═══════════════════════════════════════════════════════════════
Register #(.DATAWIDTH_BUS(11)) result_register_u0 (
    .Register_DataInBUS    (CNN_y_out_cwire),
    .Register_CLOCK        (CNNver2_SPICLOCK_50),
    .Register_Reset_InHigh (CNNver2_Reset_InHigh),
    .Register_Load_InLow   (CNN_CTRL_result_load_cwire),
    .Register_DataOutBUS   (CNN_Result_out_cwire)
);

endmodule