//=======================================================
//  MODULE Definition
//=======================================================
//  SC_STATEMACHINE_CNN_CTRL
//  ─────────────────────────────────────────────────────
//  Controla el flujo de datos entre los registros SPI
//  y el núcleo CNN (cnn_conv_v2).
//
//  Flujo:
//    IDLE ──(start)──> LOAD ──> PIPE1 ──> PIPE2 ──> CAPTURE ──> IDLE
//
//  IDLE    : Espera señal de inicio desde SPI (cmd 10).
//  LOAD    : Activa carga de weight Registers y result Register reset.
//  PIPE1   : CNN sale de reset — primer ciclo pipeline.
//  PIPE2   : Segundo ciclo pipeline — y_out válido al final.
//  CAPTURE : Carga resultado en register — listo para MISO.
//
//  Timing (lo que la CNN "ve" en cada posedge):
//
//    posedge con STATE=LOAD:    CNN ve rst=1 (LOAD output),
//                               weight registers capturan datos (load=0)
//    posedge con STATE=PIPE1:   CNN ve rst=0 → captura entradas en regs
//    posedge con STATE=PIPE2:   CNN ve rst=0 → y_reg = sum, ready=1
//    posedge con STATE=CAPTURE: y_out estable, result register captura (load=0)
//    posedge con STATE=IDLE:    CNN ve rst=1, resultado almacenado
//=======================================================

module SC_STATEMACHINE_CNN_CTRL (
    //////////// OUTPUTS //////////
    output reg o_cnn_rst,           // Reset activo alto para cnn_conv_v2
    output reg o_weight_load,       // Carga registros de pesos  (activo bajo)
    output reg o_result_load,       // Carga registro resultado  (activo bajo)
    //////////// INPUTS //////////
    input i_CLOCK,
    input i_RESET,
    input i_START_CNN               // Señal desde SPI (puede ser breve)
);

//=======================================================
//  PARAMETER declarations
//=======================================================
localparam STATE_IDLE    = 3'd0;
localparam STATE_LOAD    = 3'd1;
localparam STATE_PIPE1   = 3'd2;
localparam STATE_PIPE2   = 3'd3;
localparam STATE_CAPTURE = 3'd4;

//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [2:0] STATE_Register;
reg [2:0] STATE_Signal;

// Latch de start: captura pulso breve de o_start_cnn del SPI
// Se activa cuando i_START_CNN sube en IDLE, se limpia en LOAD
reg start_latch;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        start_latch <= 1'b0;
    else if (i_START_CNN && STATE_Register == STATE_IDLE)
        start_latch <= 1'b1;
    else if (STATE_Register == STATE_LOAD)
        start_latch <= 1'b0;
end

//=======================================================
//  Structural coding
//=======================================================

// NEXT STATE LOGIC
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if (start_latch) STATE_Signal = STATE_LOAD;
            else             STATE_Signal = STATE_IDLE;

        STATE_LOAD:
            STATE_Signal = STATE_PIPE1;

        STATE_PIPE1:
            STATE_Signal = STATE_PIPE2;

        STATE_PIPE2:
            STATE_Signal = STATE_CAPTURE;

        STATE_CAPTURE:
            STATE_Signal = STATE_IDLE;

        default: STATE_Signal = STATE_IDLE;
    endcase
end

// STATE REGISTER
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET == 1'b1)
        STATE_Register <= STATE_IDLE;
    else
        STATE_Register <= STATE_Signal;
end

//=======================================================
//  Outputs (misma convención: load activo bajo)
//=======================================================
always @(*) begin
    // Valores por defecto: CNN en reset, registros inactivos
    o_cnn_rst     = 1'b1;  // CNN en reset
    o_weight_load = 1'b1;  // Pesos NO cargan (activo bajo)
    o_result_load = 1'b1;  // Resultado NO carga (activo bajo)

    case (STATE_Register)
        STATE_IDLE: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
        end

        STATE_LOAD: begin
            o_cnn_rst     = 1'b1;  // CNN aún en reset
            o_weight_load = 1'b0;  // ¡ACTIVO! Carga registros de pesos
            o_result_load = 1'b1;
        end

        STATE_PIPE1: begin
            o_cnn_rst     = 1'b0;  // CNN operando — pipeline etapa 1
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
        end

        STATE_PIPE2: begin
            o_cnn_rst     = 1'b0;  // CNN operando — pipeline etapa 2
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
        end

        STATE_CAPTURE: begin
            o_cnn_rst     = 1'b0;  // CNN resultado estable
            o_weight_load = 1'b1;
            o_result_load = 1'b0;  // ¡ACTIVO! Captura resultado
        end

        default: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
        end
    endcase
end

endmodule
