//=======================================================
//  SC_STATEMACHINE_CNN_CTRL
//=======================================================
//  Flujo CNN (sin cambios):
//    IDLE → LOAD → PIPE1 → PIPE2 → (i_cnn_ready) → CAPTURE_CNN → IDLE
//
//  Flujo Acumulador (nuevo):
//    IDLE → (save_accum_latch) → STATE_SAVE_ACCUM → IDLE
//
//  En STATE_SAVE_ACCUM (1 ciclo):
//    - o_accum_clear = 1  → limpia acumulador DESPUES de capturar
//    - o_mr1_load = 0     → si pass_sel == 0: carga MR1 con acumulador
//    - o_mr2_load = 0     → si pass_sel == 1: carga MR2 con acumulador
//    - pass_sel toglea en el posedge siguiente (IDLE)
//
//  Timing de o_accum_clear vs Master_register load:
//    Ambos ocurren en el MISMO posedge (el de STATE_SAVE_ACCUM):
//    - Master_register lee Accum_out_cwire (valor VIEJO, pre-NBA) → carga OK
//    - accum_maxpool ve i_clear=1 → limpia o_accum (NBA post-posedge)
//    Por lo tanto MR recibe el valor correcto y luego el accum se limpia.
//
//  CAMBIOS respecto a version anterior:
//    - Removido: i_START_MAXPOOL, STATE_CAPTURE_MAXPOOL
//      (la acumulacion ahora es automatica via maxpool_shift.o_valid)
//    - Agregado: i_SAVE_ACCUM, STATE_SAVE_ACCUM
//    - Agregado: o_accum_clear, o_mr1_load, o_mr2_load
//    - Agregado: registro interno pass_sel (0→MR1, 1→MR2)
//    - Mantenido: o_result_sel (siempre 2'b00 en operacion normal)
//=======================================================

module SC_STATEMACHINE_CNN_CTRL (
    output reg       o_cnn_rst,
    output reg       o_weight_load,
    output reg       o_result_load,    // carga main Master_register (CNN result)
    output reg [1:0] o_result_sel,     // sel para result_mux (siempre 00 en op. normal)
    output reg       o_accum_clear,    // ★ NUEVO: limpia acumulador
    output reg       o_mr1_load,       // ★ NUEVO: carga MR1 (activo bajo)
    output reg       o_mr2_load,       // ★ NUEVO: carga MR2 (activo bajo)
    input  wire      i_CLOCK,
    input  wire      i_RESET,
    input  wire      i_START_CNN,
    input  wire      i_cnn_ready,
    input  wire      i_SAVE_ACCUM      // ★ NUEVO: trigger desde SPI cmd 101
);

//=======================================================
//  Estados
//=======================================================
localparam STATE_IDLE         = 3'd0;
localparam STATE_LOAD         = 3'd1;
localparam STATE_PIPE1        = 3'd2;
localparam STATE_PIPE2        = 3'd3;
localparam STATE_CAPTURE_CNN  = 3'd4;
localparam STATE_SAVE_ACCUM   = 3'd5;  // ★ NUEVO

reg [2:0] STATE_Register;
reg [2:0] STATE_Signal;

//=======================================================
//  Latch CNN start — se limpia en PIPE1
//=======================================================
reg start_cnn_latch;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        start_cnn_latch <= 1'b0;
    else if (i_START_CNN)
        start_cnn_latch <= 1'b1;
    else if (STATE_Register == STATE_PIPE1)
        start_cnn_latch <= 1'b0;
end

//=======================================================
//  ★ Latch SAVE_ACCUM — se limpia en STATE_SAVE_ACCUM
//=======================================================
reg save_accum_latch;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        save_accum_latch <= 1'b0;
    else if (i_SAVE_ACCUM)
        save_accum_latch <= 1'b1;
    else if (STATE_Register == STATE_SAVE_ACCUM)
        save_accum_latch <= 1'b0;
end

//=======================================================
//  ★ pass_sel: selecciona MR1 (0) o MR2 (1)
//  Toglea CUANDO FSM entra en STATE_SAVE_ACCUM
//  (en ese posedge, STATE_Register == STATE_SAVE_ACCUM)
//  → Primera vez: pass_sel=0 → guarda en MR1 → toglea a 1
//  → Segunda vez: pass_sel=1 → guarda en MR2 → toglea a 0
//=======================================================
reg pass_sel;
always @(posedge i_CLOCK or posedge i_RESET) begin
    if (i_RESET)
        pass_sel <= 1'b0;
    else if (STATE_Register == STATE_SAVE_ACCUM)
        pass_sel <= ~pass_sel;
end

//=======================================================
//  Logica de siguiente estado
//  Prioridad: CNN > SAVE_ACCUM
//=======================================================
always @(*) begin
    case (STATE_Register)
        STATE_IDLE:
            if      (start_cnn_latch)   STATE_Signal = STATE_LOAD;
            else if (save_accum_latch)  STATE_Signal = STATE_SAVE_ACCUM;
            else                        STATE_Signal = STATE_IDLE;

        STATE_LOAD:       STATE_Signal = STATE_PIPE1;
        STATE_PIPE1:      STATE_Signal = STATE_PIPE2;

        STATE_PIPE2:
            if (i_cnn_ready) STATE_Signal = STATE_CAPTURE_CNN;
            else             STATE_Signal = STATE_PIPE2;

        STATE_CAPTURE_CNN:  STATE_Signal = STATE_IDLE;
        STATE_SAVE_ACCUM:   STATE_Signal = STATE_IDLE;

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
//  Convenciones:
//    - o_cnn_rst:    1 = CNN en reset  (activo alto)
//    - o_weight_load:1 = inactivo      (activo bajo)
//    - o_result_load:1 = inactivo      (activo bajo)
//    - o_mr1_load:   1 = inactivo      (activo bajo)
//    - o_mr2_load:   1 = inactivo      (activo bajo)
//    - o_accum_clear:1 = limpiar       (activo alto)
//=======================================================
always @(*) begin
    // Valores por defecto: todo inactivo
    o_cnn_rst     = 1'b1;
    o_weight_load = 1'b1;
    o_result_load = 1'b1;
    o_result_sel  = 2'b00;
    o_accum_clear = 1'b0;
    o_mr1_load    = 1'b1;
    o_mr2_load    = 1'b1;

    case (STATE_Register)

        STATE_IDLE: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end

        STATE_LOAD: begin
            o_cnn_rst     = 1'b1;   // CNN aun en reset
            o_weight_load = 1'b0;   // ACTIVO: carga registros de pesos
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end

        STATE_PIPE1: begin
            o_cnn_rst     = 1'b0;   // CNN operando — etapa 1
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end

        STATE_PIPE2: begin
            o_cnn_rst     = 1'b0;   // CNN operando — etapa 2
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end

        STATE_CAPTURE_CNN: begin
            o_cnn_rst     = 1'b0;   // CNN resultado estable
            o_weight_load = 1'b1;
            o_result_load = 1'b0;   // ACTIVO: captura CNN en main Master_register
            o_result_sel  = 2'b00;  // selecciona CNN → Master
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end

        STATE_SAVE_ACCUM: begin
            // ★ Guarda acumulador en MR1 o MR2 segun pass_sel
            // ★ Limpia acumulador en el mismo ciclo
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;   // NO toca main Master_register
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b1;   // ★ ACTIVO: limpia accum en este ciclo
            // Activo bajo: solo uno de los dos se activa segun pass_sel
            o_mr1_load    = pass_sel ? 1'b1 : 1'b0;  // 0=activo cuando pass_sel=0
            o_mr2_load    = pass_sel ? 1'b0 : 1'b1;  // 0=activo cuando pass_sel=1
        end

        default: begin
            o_cnn_rst     = 1'b1;
            o_weight_load = 1'b1;
            o_result_load = 1'b1;
            o_result_sel  = 2'b00;
            o_accum_clear = 1'b0;
            o_mr1_load    = 1'b1;
            o_mr2_load    = 1'b1;
        end
    endcase
end

endmodule