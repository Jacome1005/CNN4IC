//=======================================================
//  SC_STATEMACHINE_CNN_CTRL — version combinada
//=======================================================
//  Flujo CNN:
//    IDLE --(start_cnn_latch)--> LOAD --> PIPE1 --> PIPE2
//         --(i_cnn_ready)-----> CAPTURE_CNN --> IDLE
//
//  Flujo MaxPool:
//    IDLE --(start_maxpool_latch)--> CAPTURE_MAXPOOL --> IDLE
//
//  Prioridad en IDLE: CNN > MaxPool
//
//  CAMBIOS respecto a version base:
//  ★1  Nuevo estado CAPTURE_MAXPOOL (fue CAPTURE en base,
//      renombrado a CAPTURE_CNN para claridad)
//  ★2  Nuevo puerto i_cnn_ready: PIPE2 espera confirmacion
//      de CNN antes de avanzar a CAPTURE_CNN
//  ★3  Nuevo puerto i_START_MAXPOOL
//  ★4  Nuevo puerto o_result_sel[1:0] para result_mux_4to1
//  ★5  start_cnn_latch se limpia en PIPE1 (no en LOAD)
//      para mayor robustez ante pulsos cortos
//  ★6  start_maxpool_latch se limpia en CAPTURE_MAXPOOL
//
//  Codificacion o_result_sel:
//    2'b00 = CNN conv    (sign-extend 11 -> 16 bits)
//    2'b01 = Max Pooling (sign-extend 11 -> 16 bits)
//    2'b10 = Acumulador  [futuro]
//    2'b11 = Comparador  [futuro]
//=======================================================

module SC_STATEMACHINE_CNN_CTRL (
    output reg       o_cnn_rst,
    output reg       o_weight_load,
    output reg       o_result_load,
    output reg [1:0] o_result_sel,   // ★4
    input wire       i_CLOCK,
    input wire       i_RESET,
    input wire       i_START_CNN,
    input wire       i_cnn_ready,    // ★2 — ready desde cnn_conv_v2
    input wire       i_START_MAXPOOL // ★3 — valid desde maxpool_shift
);

//=======================================================
//  Estados
//=======================================================
localparam STATE_IDLE            = 3'd0;
localparam STATE_LOAD            = 3'd1;
localparam STATE_PIPE1           = 3'd2;
localparam STATE_PIPE2           = 3'd3;
localparam STATE_CAPTURE_CNN     = 3'd4;  // ★1 (antes CAPTURE)
localparam STATE_CAPTURE_MAXPOOL = 3'd5;  // ★1 nuevo

reg [2:0] STATE_Register;
reg [2:0] STATE_Signal;

//=======================================================
//  ★5 Latch CNN start — se limpia en PIPE1
//  (en LOAD podria haber re-disparo si START_CNN dura >1 ciclo)
//=======================================================
reg start_cnn_latch;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        start_cnn_latch <= 1'b0;
    else if (i_START_CNN)
        start_cnn_latch <= 1'b1;
    else if (STATE_Register == STATE_PIPE1)   // ★5
        start_cnn_latch <= 1'b0;
end

//=======================================================
//  ★6 Latch MaxPool — se limpia en CAPTURE_MAXPOOL
//=======================================================
reg start_maxpool_latch;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        start_maxpool_latch <= 1'b0;
    else if (i_START_MAXPOOL)
        start_maxpool_latch <= 1'b1;
    else if (STATE_Register == STATE_CAPTURE_MAXPOOL)  // ★6
        start_maxpool_latch <= 1'b0;
end

//=======================================================
//  Logica de siguiente estado
//=======================================================
always @(*) begin
    case (STATE_Register)

        STATE_IDLE:
            if      (start_cnn_latch)     STATE_Signal = STATE_LOAD;
            else if (start_maxpool_latch)  STATE_Signal = STATE_CAPTURE_MAXPOOL;
            else                           STATE_Signal = STATE_IDLE;

        STATE_LOAD:
            STATE_Signal = STATE_PIPE1;

        STATE_PIPE1:
            STATE_Signal = STATE_PIPE2;

        STATE_PIPE2:
            // ★2 Espera confirmacion del nucleo CNN antes de capturar
            if (i_cnn_ready) STATE_Signal = STATE_CAPTURE_CNN;
            else             STATE_Signal = STATE_PIPE2;

        STATE_CAPTURE_CNN:
            STATE_Signal = STATE_IDLE;

        STATE_CAPTURE_MAXPOOL:
            STATE_Signal = STATE_IDLE;

        default: STATE_Signal = STATE_IDLE;
    endcase
end

//=======================================================
//  Registro de estado
//=======================================================
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        STATE_Register <= STATE_IDLE;
    else
        STATE_Register <= STATE_Signal;
end

//=======================================================
//  Salidas combinacionales
//  Convencion: load activo bajo, rst activo alto
//=======================================================
always @(*) begin
    // Valores por defecto: CNN en reset, registros inactivos
    o_cnn_rst     = 1'b1;
    o_weight_load = 1'b1;
    o_result_load = 1'b1;
    o_result_sel  = 2'b00;

    case (STATE_Register)

        STATE_IDLE: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
        end

        STATE_LOAD: begin
            o_cnn_rst     = 1'b1;   // CNN aun en reset
            o_weight_load = 1'b0;   // ACTIVO: carga registros de pesos
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
        end

        STATE_PIPE1: begin
            o_cnn_rst     = 1'b0;   // CNN operando — etapa 1
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
        end

        STATE_PIPE2: begin
            o_cnn_rst     = 1'b0;   // CNN operando — etapa 2
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
        end

        STATE_CAPTURE_CNN: begin
            o_cnn_rst     = 1'b0;   // CNN resultado estable
            o_weight_load = 1'b1;
            o_result_load = 1'b0;   // ACTIVO: captura resultado CNN en Master
            o_result_sel  = 2'b00;  // selecciona CNN -> Master
        end

        STATE_CAPTURE_MAXPOOL: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b0;   // ACTIVO: captura resultado MaxPool en Master
            o_result_sel  = 2'b01;  // selecciona MaxPool -> Master
        end

        default: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
        end
    endcase
end

endmodule
