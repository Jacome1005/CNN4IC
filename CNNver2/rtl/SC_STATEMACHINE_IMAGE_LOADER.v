//=======================================================
//  SC_STATEMACHINE_IMAGE_LOADER
//=======================================================
//  Genera senales de carga (activo bajo) para los 10
//  registros de filas de imagen.
//
//  Cambios respecto a version anterior:
//  ★ i_CMD ampliado a 3 bits (protocolo nuevo)
//  ★ Condicion: i_CMD == 3'b000 (LOAD IMAGE)
//  (resto sin cambios: ROW_BITS param, fix off-by-one,
//   fix STATE_WAIT_NEXT eliminado, 10 filas)
//=======================================================

module SC_STATEMACHINE_IMAGE_LOADER #(
    parameter ROW_BITS = 30   // bits por fila (DATAWIDTH_BUS_IMAGE x BITS_PER_POS)
)(
    output reg o_load00, output reg o_load01,
    output reg o_load02, output reg o_load03,
    output reg o_load04, output reg o_load05,
    output reg o_load06, output reg o_load07,
    output reg o_load08, output reg o_load09,

    input       i_CLOCK,
    input       i_RESET,
    input [2:0] i_CMD,         // ★ 3 bits
    input [6:0] i_DATA_COUNT,
    input [3:0] i_ROW
);

localparam STATE_IDLE     = 0;
localparam STATE_LOAD_ROW = 1;

localparam [6:0] LAST_BIT = ROW_BITS - 1;  // 29

reg [1:0] STATE_Register;
reg [1:0] STATE_Signal;

// NEXT STATE — LOAD_ROW dura 1 ciclo, vuelve directo a IDLE
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if (i_CMD == 3'b000 && i_DATA_COUNT == LAST_BIT)  // ★ 3'b000
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
// Fix off-by-one: cuando LOAD_ROW dispara, el SPI ya incremento `row`
// en el mismo posedge → la fila recien escrita es i_ROW-1.
always @(*) begin
    o_load00 = 1'b1; o_load01 = 1'b1; o_load02 = 1'b1; o_load03 = 1'b1;
    o_load04 = 1'b1; o_load05 = 1'b1; o_load06 = 1'b1; o_load07 = 1'b1;
    o_load08 = 1'b1; o_load09 = 1'b1;

    if (STATE_Register == STATE_LOAD_ROW) begin
        case (i_ROW - 4'd1)
            4'd0: o_load00 = 1'b0;
            4'd1: o_load01 = 1'b0;
            4'd2: o_load02 = 1'b0;
            4'd3: o_load03 = 1'b0;
            4'd4: o_load04 = 1'b0;
            4'd5: o_load05 = 1'b0;
            4'd6: o_load06 = 1'b0;
            4'd7: o_load07 = 1'b0;
            4'd8: o_load08 = 1'b0;
            4'd9: o_load09 = 1'b0;
            default: ;
        endcase
    end
end

endmodule
