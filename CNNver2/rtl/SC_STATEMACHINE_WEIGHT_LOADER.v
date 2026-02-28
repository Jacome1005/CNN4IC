//=======================================================
//  SC_STATEMACHINE_WEIGHT_LOADER
//=======================================================
//  Genera senales de carga (activo bajo) para los 5
//  registros de filas del kernel de pesos.
//
//  Cambios respecto a version anterior:
//  ★ i_CMD ampliado a 3 bits (protocolo nuevo)
//  ★ Condicion: i_CMD == 3'b001 (LOAD WEIGHTS)
//  (resto sin cambios: ROW_BITS param, LOAD_ROW 1 ciclo,
//   fix off-by-one, 5 filas)
//=======================================================

module SC_STATEMACHINE_WEIGHT_LOADER #(
    parameter ROW_BITS = 15   // bits por fila (DATAWIDTH_BUS_WEIGHT x BITS_PER_POS)
)(
    output reg o_wload00, output reg o_wload01,
    output reg o_wload02, output reg o_wload03,
    output reg o_wload04,

    input       i_CLOCK,
    input       i_RESET,
    input [2:0] i_CMD,         // ★ 3 bits
    input [6:0] i_DATA_COUNT,
    input [2:0] i_WROW         // fila de peso actual (0-4)
);

localparam STATE_IDLE     = 0;
localparam STATE_LOAD_ROW = 1;

localparam [6:0] LAST_BIT = ROW_BITS - 1;  // 14

reg [1:0] STATE_Register;
reg [1:0] STATE_Signal;

// NEXT STATE — LOAD_ROW dura 1 ciclo
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if (i_CMD == 3'b001 && i_DATA_COUNT == LAST_BIT)  // ★ 3'b001
                STATE_Signal = STATE_LOAD_ROW;
            else
                STATE_Signal = STATE_IDLE;

        STATE_LOAD_ROW:
            STATE_Signal = STATE_IDLE;

        default: STATE_Signal = STATE_IDLE;
    endcase
end

// STATE REGISTER
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        STATE_Register <= STATE_IDLE;
    else
        STATE_Register <= STATE_Signal;
end

// OUTPUTS — activo bajo
// Fix off-by-one: mismo razonamiento que IMAGE_LOADER —
// cuando LOAD_ROW dispara, weight_count ya fue incrementado.
always @(*) begin
    o_wload00 = 1'b1; o_wload01 = 1'b1; o_wload02 = 1'b1;
    o_wload03 = 1'b1; o_wload04 = 1'b1;

    if (STATE_Register == STATE_LOAD_ROW) begin
        case (i_WROW - 3'd1)
            3'd0: o_wload00 = 1'b0;
            3'd1: o_wload01 = 1'b0;
            3'd2: o_wload02 = 1'b0;
            3'd3: o_wload03 = 1'b0;
            3'd4: o_wload04 = 1'b0;
            default: ;
        endcase
    end
end

endmodule
