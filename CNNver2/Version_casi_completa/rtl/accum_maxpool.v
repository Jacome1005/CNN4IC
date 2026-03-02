//=======================================================
//  MODULE: accum_maxpool
//=======================================================
//  Acumulador de resultados de MaxPool.
//  Suma los valores de o_max de maxpool_shift en cada
//  ciclo donde i_valid esta activo.
//
//  Ancho default: 20 bits signed.
//    Rango: -524288 a +524287
//    Suficiente para 36 resultados x ±1023 = ±36828 (~17b)
//
//  Prioridad de control (en posedge):
//    1. i_rst   → o_accum = 0  (reset global)
//    2. i_clear → o_accum = 0  (limpieza post SAVE_ACCUM)
//    3. i_valid → o_accum += sign_extend(i_data)  (acumula)
//    4. (nada)  → o_accum sin cambio
//
//  Timing de i_clear:
//    - Generado por SC_STATEMACHINE_CNN_CTRL en STATE_SAVE_ACCUM
//      (combinacional, activo durante ese estado).
//    - Se activa 1 ciclo ANTES de que el FSM avance a IDLE.
//    - En ese mismo ciclo Master_register captura o_accum (old).
//    - En el siguiente posedge accum_maxpool limpia o_accum. ✓
//=======================================================

module accum_maxpool #(
    parameter ACCUM_WIDTH = 20
)(
    input  wire                          i_clk,
    input  wire                          i_rst,    // reset global activo alto
    input  wire signed [10:0]            i_data,   // maxpool_shift.o_max
    input  wire                          i_valid,  // maxpool_shift.o_valid
    input  wire                          i_clear,  // limpia despues de SAVE_ACCUM
    output reg  signed [ACCUM_WIDTH-1:0] o_accum
);
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst)
            o_accum <= {ACCUM_WIDTH{1'b0}};
        else if (i_clear)
            o_accum <= {ACCUM_WIDTH{1'b0}};
        else if (i_valid)
            // Sign-extend i_data de 11 a ACCUM_WIDTH bits antes de sumar
            o_accum <= o_accum + {{(ACCUM_WIDTH-11){i_data[10]}}, i_data};
    end
endmodule
