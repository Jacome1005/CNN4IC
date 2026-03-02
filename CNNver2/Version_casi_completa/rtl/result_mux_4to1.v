//=======================================================
//  MODULE: result_mux_4to1
//=======================================================
//  Mux 4:1 de 16 bits que selecciona cual modulo de
//  procesamiento escribe en el Master_register.
//
//  Tabla de seleccion:
//  +--------------+-----+----------------------------------+
//  | Fuente       | sel | Conversion a 16 bits            |
//  +--------------+-----+----------------------------------+
//  | CNN conv     | 00  | sign-extend  11 -> 16 bits      |
//  | Max Pooling  | 01  | sign-extend  11 -> 16 bits      |
//  | Acumulador   | 10  | directo      16 bits   [futuro] |
//  | Comparador   | 11  | zero-extend   1 -> 16 bits [f.] |
//  +--------------+-----+----------------------------------+
//
//  Las extensiones de signo/cero se hacen dentro de este
//  modulo para mantener CNNver2.v limpio.
//=======================================================

module result_mux_4to1 (
    input  wire [1:0]  i_sel,

    input  wire signed [10:0] i_cnn_result,       // CNN conv    — activo
    input  wire signed [10:0] i_maxpool_result,   // Max Pooling — activo
    input  wire        [15:0] i_accum_result,     // Acumulador  — futuro
    input  wire               i_comp_result,      // Comparador  — futuro

    output wire [15:0] o_mux_out
);

    wire [15:0] cnn_extended;
    wire [15:0] maxpool_extended;
    wire [15:0] accum_direct;
    wire [15:0] comp_extended;

    // Sign-extend 11 -> 16
    assign cnn_extended     = {{5{i_cnn_result[10]}},    i_cnn_result};
    assign maxpool_extended = {{5{i_maxpool_result[10]}}, i_maxpool_result};

    // Directo / zero-extend
    assign accum_direct     = i_accum_result;
    assign comp_extended    = {15'b0, i_comp_result};

    // Mux 4:1
    assign o_mux_out =
        (i_sel == 2'b00) ? cnn_extended     :
        (i_sel == 2'b01) ? maxpool_extended :
        (i_sel == 2'b10) ? accum_direct     :
                           comp_extended;

endmodule
