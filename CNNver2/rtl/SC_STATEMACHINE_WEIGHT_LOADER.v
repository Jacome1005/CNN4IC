//=======================================================
//  SC_STATEMACHINE_WEIGHT_LOADER
//  ─────────────────────────────────────────────────────
//  Genera señales de carga (activo bajo) para los 5
//  registros de filas del kernel de pesos.
//
//  Análogo a SC_STATEMACHINE_IMAGE_LOADER, pero para
//  cmd == 2'b01 (LOAD WEIGHTS) y solo 5 filas.
//
//  ROW_BITS  : bits por fila de pesos = 5×3 = 15
//
//  Flujo: IDLE → LOAD_ROW (1 ciclo) → IDLE
//  (igual que la SM de imagen: sin STATE_WAIT_NEXT)
//=======================================================

module SC_STATEMACHINE_WEIGHT_LOADER #(
    parameter ROW_BITS = 15
)(
    //////////// OUTPUTS //////////
    output reg o_wload00, output reg o_wload01,
    output reg o_wload02, output reg o_wload03,
    output reg o_wload04,
    //////////// INPUTS //////////
    input       i_CLOCK,
    input       i_RESET,
    input [1:0] i_CMD,
    input [6:0] i_DATA_COUNT,
    input [2:0] i_WROW          // fila de peso actual (0-4)
);

localparam STATE_IDLE     = 0;
localparam STATE_LOAD_ROW = 1;

localparam [6:0] LAST_BIT = ROW_BITS - 1;  // 14

reg [1:0] STATE_Register;
reg [1:0] STATE_Signal;

// NEXT STATE LOGIC — igual que SM de imagen: LOAD_ROW → IDLE directo
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if (i_CMD == 2'b01 && i_DATA_COUNT == LAST_BIT)
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

// OUTPUTS — activo bajo, decodifica fila con i_WROW-1 (igual offset que SM imagen)
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
