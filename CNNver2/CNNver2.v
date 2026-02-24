
module CNNver2 (
//////////// OUTPUTS //////////
	output CNNver2_MISO,
	
//////////// INPUTS ///////////
	input CNNver2_SPICLOCK_50,
	input CNNver2_SS_N,
	input CNNver2_MOSI
);
//////////// PARAMETERS //////////
parameter DATAWIDTH_BUS = 8;

// ═════════════════════════════════════════════════════
//  WIRE — SPI → Imagen (originales, sin cambios)
// ═════════════════════════════════════════════════════
wire SPI_2_CNN_Start_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row00_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row01_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row02_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row03_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row04_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row05_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row06_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_row07_DataOutBUS_routing_cwire;

wire [DATAWIDTH_BUS-1:0]	Register_u0_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u1_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u2_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u3_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u4_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u5_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u6_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	Register_u7_DataOutBUS_routing_cwire;

wire Register_u0_Load_InLow_routing_cwire;
wire Register_u1_Load_InLow_routing_cwire;
wire Register_u2_Load_InLow_routing_cwire;
wire Register_u3_Load_InLow_routing_cwire;
wire Register_u4_Load_InLow_routing_cwire;
wire Register_u5_Load_InLow_routing_cwire;
wire Register_u6_Load_InLow_routing_cwire;
wire Register_u7_Load_InLow_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — SPI → Pesos (NUEVO — misma convención)
// ═════════════════════════════════════════════════════
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow00_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow01_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow02_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow03_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow04_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow05_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow06_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]  SPI_2_wrow07_DataOutBUS_routing_cwire;

wire [DATAWIDTH_BUS-1:0]	WeightReg_u0_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u1_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u2_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u3_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u4_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u5_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u6_DataOutBUS_routing_cwire;
wire [DATAWIDTH_BUS-1:0]	WeightReg_u7_DataOutBUS_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — CNN Controller (NUEVO)
// ═════════════════════════════════════════════════════
wire CNN_CTRL_rst_routing_cwire;
wire CNN_CTRL_weight_load_routing_cwire;
wire CNN_CTRL_result_load_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — CNN Core (NUEVO)
// ═════════════════════════════════════════════════════
wire signed [10:0] CNN_y_out_routing_cwire;
wire               CNN_ready_routing_cwire;
wire signed [14:0] CNN_additional_out_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — CNN Result Register (NUEVO)
// ═════════════════════════════════════════════════════
wire [10:0] CNN_Result_DataOutBUS_routing_cwire;

// ═════════════════════════════════════════════════════
//  WIRE — Empaquetado 8×8-bit → 75-bit flat
// ═════════════════════════════════════════════════════
//  px_flat = {11'b0, reg7, reg6, reg5, reg4, reg3, reg2, reg1, reg0}
//  Esto produce 25 × 3-bit: posiciones [0..20] con datos,
//  posición [21] parcial, posiciones [22..24] = 0 (padding).
wire [74:0] px_flat_packed_routing_cwire;
assign px_flat_packed_routing_cwire = {11'b0,
	Register_u7_DataOutBUS_routing_cwire,
	Register_u6_DataOutBUS_routing_cwire,
	Register_u5_DataOutBUS_routing_cwire,
	Register_u4_DataOutBUS_routing_cwire,
	Register_u3_DataOutBUS_routing_cwire,
	Register_u2_DataOutBUS_routing_cwire,
	Register_u1_DataOutBUS_routing_cwire,
	Register_u0_DataOutBUS_routing_cwire
};

wire signed [74:0] w_flat_packed_routing_cwire;
assign w_flat_packed_routing_cwire = {11'b0,
	WeightReg_u7_DataOutBUS_routing_cwire,
	WeightReg_u6_DataOutBUS_routing_cwire,
	WeightReg_u5_DataOutBUS_routing_cwire,
	WeightReg_u4_DataOutBUS_routing_cwire,
	WeightReg_u3_DataOutBUS_routing_cwire,
	WeightReg_u2_DataOutBUS_routing_cwire,
	WeightReg_u1_DataOutBUS_routing_cwire,
	WeightReg_u0_DataOutBUS_routing_cwire
};

//WIRES PENDIENTES DE CORRECTO USO//
wire CNNver2_Reset_InHigh = 1'b0;


// ═════════════════════════════════════════════════════
// 1. Unidad de Interfaz Serial (SPI + Control)
// ═════════════════════════════════════════════════════
spi_cnn_slave_8 #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) spi_cnn_slave_8_u0 (
	.i_SPI_Clk(CNNver2_SPICLOCK_50),
	.i_SPI_CS_n(CNNver2_SS_N),
	.i_SPI_MOSI(CNNver2_MOSI),
	.o_SPI_MISO(CNNver2_MISO),
	.o_start_cnn(SPI_2_CNN_Start_routing_cwire),
	// Imagen — original
	.o_row00 (SPI_2_row00_DataOutBUS_routing_cwire),
	.o_row01 (SPI_2_row01_DataOutBUS_routing_cwire),
	.o_row02 (SPI_2_row02_DataOutBUS_routing_cwire),
	.o_row03 (SPI_2_row03_DataOutBUS_routing_cwire),
	.o_row04 (SPI_2_row04_DataOutBUS_routing_cwire),
	.o_row05 (SPI_2_row05_DataOutBUS_routing_cwire),
	.o_row06 (SPI_2_row06_DataOutBUS_routing_cwire),
	.o_row07 (SPI_2_row07_DataOutBUS_routing_cwire),
	.o_load00 (Register_u0_Load_InLow_routing_cwire),
	.o_load01 (Register_u1_Load_InLow_routing_cwire),
	.o_load02 (Register_u2_Load_InLow_routing_cwire),
	.o_load03 (Register_u3_Load_InLow_routing_cwire),
	.o_load04 (Register_u4_Load_InLow_routing_cwire),
	.o_load05 (Register_u5_Load_InLow_routing_cwire),
	.o_load06 (Register_u6_Load_InLow_routing_cwire),
	.o_load07 (Register_u7_Load_InLow_routing_cwire),
	// Pesos — NUEVO
	.o_wrow00(SPI_2_wrow00_DataOutBUS_routing_cwire),
	.o_wrow01(SPI_2_wrow01_DataOutBUS_routing_cwire),
	.o_wrow02(SPI_2_wrow02_DataOutBUS_routing_cwire),
	.o_wrow03(SPI_2_wrow03_DataOutBUS_routing_cwire),
	.o_wrow04(SPI_2_wrow04_DataOutBUS_routing_cwire),
	.o_wrow05(SPI_2_wrow05_DataOutBUS_routing_cwire),
	.o_wrow06(SPI_2_wrow06_DataOutBUS_routing_cwire),
	.o_wrow07(SPI_2_wrow07_DataOutBUS_routing_cwire),
	// Resultado CNN — NUEVO
	.i_cnn_result(CNN_Result_DataOutBUS_routing_cwire)
);

// ═════════════════════════════════════════════════════
// 2. Registros de Imagen (8 × Register.v — originales)
// ═════════════════════════════════════════════════════
Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u0 (
	.Register_DataInBUS(SPI_2_row00_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u0_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u0_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u1 (
	.Register_DataInBUS(SPI_2_row01_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u1_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u1_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u2 (
	.Register_DataInBUS(SPI_2_row02_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u2_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u2_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u3 (
	.Register_DataInBUS(SPI_2_row03_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u3_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u3_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u4 (
	.Register_DataInBUS(SPI_2_row04_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u4_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u4_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u5 (
	.Register_DataInBUS(SPI_2_row05_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u5_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u5_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u6 (
	.Register_DataInBUS(SPI_2_row06_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u6_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u6_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) register_u7 (
	.Register_DataInBUS(SPI_2_row07_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (Register_u7_Load_InLow_routing_cwire),
	.Register_DataOutBUS (Register_u7_DataOutBUS_routing_cwire)
);

// ═════════════════════════════════════════════════════
// 3. Registros de Pesos (8 × Register.v — NUEVO)
//    Datos desde SPI weight_mem. Carga controlada por
//    SC_STATEMACHINE_CNN_CTRL (o_weight_load, activo bajo).
//    Se cargan todos simultáneamente en estado LOAD.
// ═════════════════════════════════════════════════════
Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u0 (
	.Register_DataInBUS(SPI_2_wrow00_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u0_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u1 (
	.Register_DataInBUS(SPI_2_wrow01_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u1_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u2 (
	.Register_DataInBUS(SPI_2_wrow02_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u2_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u3 (
	.Register_DataInBUS(SPI_2_wrow03_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u3_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u4 (
	.Register_DataInBUS(SPI_2_wrow04_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u4_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u5 (
	.Register_DataInBUS(SPI_2_wrow05_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u5_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u6 (
	.Register_DataInBUS(SPI_2_wrow06_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u6_DataOutBUS_routing_cwire)
);

Register #(.DATAWIDTH_BUS(DATAWIDTH_BUS)) weight_register_u7 (
	.Register_DataInBUS(SPI_2_wrow07_DataOutBUS_routing_cwire),
	.Register_CLOCK (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow (CNN_CTRL_weight_load_routing_cwire),
	.Register_DataOutBUS (WeightReg_u7_DataOutBUS_routing_cwire)
);

// ═════════════════════════════════════════════════════
// 4. Máquina de Estados — Controlador CNN (NUEVO)
// ═════════════════════════════════════════════════════
SC_STATEMACHINE_CNN_CTRL cnn_ctrl_sm (
	.i_CLOCK      (CNNver2_SPICLOCK_50),
	.i_RESET      (CNNver2_Reset_InHigh),
	.i_START_CNN  (SPI_2_CNN_Start_routing_cwire),
	.o_cnn_rst    (CNN_CTRL_rst_routing_cwire),
	.o_weight_load(CNN_CTRL_weight_load_routing_cwire),
	.o_result_load(CNN_CTRL_result_load_routing_cwire)
);

// ═════════════════════════════════════════════════════
// 5. Núcleo CNN — cnn_conv_v2 (NUEVO, módulo sin cambios)
// ═════════════════════════════════════════════════════
cnn_conv_v2 cnn_conv_v2_u0 (
	.clk            (CNNver2_SPICLOCK_50),
	.rst            (CNN_CTRL_rst_routing_cwire),
	// Datos empaquetados desde registros
	.px_flat_in     (px_flat_packed_routing_cwire),
	.w_flat_in      (w_flat_packed_routing_cwire),
	// Entradas adicionales (sin uso actual — a tierra)
	.additional_in_0(11'sd0),
	.additional_in_1(11'sd0),
	.additional_in_2(11'sd0),
	.additional_in_3(11'sd0),
	// Salidas
	.y_out          (CNN_y_out_routing_cwire),
	.ready          (CNN_ready_routing_cwire),
	.additional_out (CNN_additional_out_routing_cwire)
);

// ═════════════════════════════════════════════════════
// 6. Registro de Resultado CNN (Register.v — 11 bits, NUEVO)
//    Carga controlada por SC_STATEMACHINE_CNN_CTRL
//    (o_result_load, activo bajo). Retiene el resultado
//    entre transacciones SPI para lectura por MISO.
// ═════════════════════════════════════════════════════
Register #(.DATAWIDTH_BUS(11)) result_register_u0 (
	.Register_DataInBUS    (CNN_y_out_routing_cwire),
	.Register_CLOCK        (CNNver2_SPICLOCK_50),
	.Register_Reset_InHigh (CNNver2_Reset_InHigh),
	.Register_Load_InLow   (CNN_CTRL_result_load_routing_cwire),
	.Register_DataOutBUS   (CNN_Result_DataOutBUS_routing_cwire)
);

endmodule
