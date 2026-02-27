//=======================================================
//  SC_STATEMACHINE_IMAGE_LOADER
//=======================================================
//  CAMBIOS respecto al original (marcados con ★):
//  ★A  Parámetro ROW_BITS (por defecto 30) para umbral de carga
//  ★B  Añadidos o_load08 y o_load09 (imagen 10×10)
//  ★C  i_DATA_COUNT comparado contra ROW_BITS-1 (=29)
//=======================================================

module SC_STATEMACHINE_IMAGE_LOADER #(
    parameter ROW_BITS = 30   // ★A número de bits por fila (DATAWIDTH_BUS_IMAGE × BITS_PER_POS)
)(
    //////////// OUTPUTS //////////
    output reg o_load00, output reg o_load01,
    output reg o_load02, output reg o_load03,
    output reg o_load04, output reg o_load05,
    output reg o_load06, output reg o_load07,
    output reg o_load08, output reg o_load09,  // ★B

    //////////// INPUTS //////////
    input       i_CLOCK,
    input       i_RESET,
    input [1:0] i_CMD,
    input [6:0] i_DATA_COUNT,
    input [3:0] i_ROW
);

//=======================================================
//  PARAMETER declarations
//=======================================================
localparam STATE_IDLE      = 0;
localparam STATE_LOAD_ROW  = 1;
// STATE_WAIT_NEXT eliminado — ver corrección en NEXT STATE LOGIC

localparam [6:0] LAST_BIT = ROW_BITS - 1;  // ★C = 29

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [2:0] STATE_Register;
reg [2:0] STATE_Signal;

//=======================================================
//=======================================================
//  NEXT STATE LOGIC
//  ★ Fix: STATE_WAIT_NEXT eliminado.
//  Problema original: WAIT_NEXT esperaba data_count==0, que solo ocurre en la
//  SIGUIENTE frontera de fila (30 ciclos). El SM tardaba 31 ciclos en volver
//  a IDLE, pero las filas llegan cada 30 ciclos → se saltaba una fila de cada dos.
//  Solución: LOAD_ROW → IDLE directo (pulso de 1 ciclo).
//  data_count se resetea a 0 en cada frontera, garantizando 29 ciclos antes
//  de que pueda volver a dispararse la condición.
//=======================================================
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if (i_CMD == 2'b00 && i_DATA_COUNT == LAST_BIT)
                STATE_Signal = STATE_LOAD_ROW;
            else
                STATE_Signal = STATE_IDLE;

        STATE_LOAD_ROW:
            STATE_Signal = STATE_IDLE;   // ★ Fix: vuelve directo a IDLE

        default: STATE_Signal = STATE_IDLE;
    endcase
end

//=======================================================
//  STATE REGISTER
//=======================================================
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET == 1'b1)
        STATE_Register <= STATE_IDLE;
    else
        STATE_Register <= STATE_Signal;
end

//=======================================================
//  OUTPUTS — lógica activa baja
//=======================================================
always @(*) begin
    // Valores por defecto: inactivo (1)
    o_load00 = 1'b1; o_load01 = 1'b1; o_load02 = 1'b1; o_load03 = 1'b1;
    o_load04 = 1'b1; o_load05 = 1'b1; o_load06 = 1'b1; o_load07 = 1'b1;
    o_load08 = 1'b1; o_load09 = 1'b1;  // ★B

    case (STATE_Register)
        STATE_LOAD_ROW: begin
            // ★ Fix off-by-one: at the clock STATE_LOAD_ROW fires, the SPI
            //   already incremented `row` at the previous posedge (same clock
            //   that triggered the transition). So the row that was just written
            //   to image_mem is i_ROW-1, not i_ROW.
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
        default: ;
    endcase
end

endmodule