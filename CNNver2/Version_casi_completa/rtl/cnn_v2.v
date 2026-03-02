//=======================================================
//  cnn_v2 — Convolución 5×5 sobre imagen 10×10 (3 bits/px)
//=======================================================
//  Computa UN resultado de convolución: el producto punto
//  de un parche 5×5 de la imagen con el kernel 5×5.
//
//  Parámetros de posición:
//    R_OFF : fila superior izquierda del parche (0 a 5)
//    C_OFF : columna superior izquierda del parche (0 a 5)
//
//  Para valid convolution completa (sin padding):
//    - Resultado válido en posiciones (r,c) con
//      r ∈ [0,5], c ∈ [0,5] → 6×6 = 36 valores
//    - Instanciar 36 copias de este módulo con distintos
//      R_OFF/C_OFF, o usar la SC_STATEMACHINE_CNN_CTRL
//      para computar una posición a la vez.
//
//  Layout de px_flat_in[299:0]:
//    Fila r, columna c → bits [r*30 + c*3 +: 3]
//    Pixel (r,c) [2:0] = pixel 3-bit signed
//
//  Layout de w_flat_in[74:0]:
//    Peso (kr,kc) → bits [(kr*5+kc)*3 +: 3]
//    (kr=0 es la fila superior del kernel)
//
//  Pipeline: 2 ciclos de latencia
//    Ciclo 1 (posedge clk, rst=0): captura px_flat / w_flat en registros
//    Ciclo 2 (posedge clk, rst=0): computa suma → y_reg, ready=1
//=======================================================

module cnn_v2 #(
    parameter IMG_ROWS    = 10,          // filas de la imagen
    parameter IMG_COLS    = 10,          // columnas de la imagen
    parameter KERN_SIZE   = 5,           // lado del kernel (5×5)
    parameter BITS_PX     = 3,           // bits por píxel
    parameter BITS_W      = 3,           // bits por peso
    parameter R_OFF       = 0,           // offset de fila del parche (0..IMG_ROWS-KERN_SIZE)
    parameter C_OFF       = 0            // offset de columna del parche (0..IMG_COLS-KERN_SIZE)
)(
    input  wire              clk,
    input  wire              rst,
    // Imagen completa 10×10 = 300 bits
    input  wire [IMG_ROWS*IMG_COLS*BITS_PX-1:0] px_flat_in,
    // Kernel 5×5 = 75 bits
    input  wire signed [KERN_SIZE*KERN_SIZE*BITS_W-1:0] w_flat_in,
    output wire signed [10:0] y,
    output wire               ready
);

    localparam N_PX = KERN_SIZE * KERN_SIZE;  // 25
    localparam IMG_ROW_BITS = IMG_COLS * BITS_PX; // 30 bits por fila de imagen

    // ── Registros de entrada ──────────────────────────────
    reg [IMG_ROWS*IMG_COLS*BITS_PX-1:0] px_flat_reg;
    reg signed [KERN_SIZE*KERN_SIZE*BITS_W-1:0] w_flat_reg;

    always @(posedge clk) begin
        if (rst) begin
            px_flat_reg <= 0;
            w_flat_reg  <= 0;
        end else begin
            px_flat_reg <= px_flat_in;
            w_flat_reg  <= w_flat_in;
        end
    end

    // ── Extracción del parche 5×5 en (R_OFF, C_OFF) ──────
    //
    //  Para el parche en la posición (R_OFF, C_OFF):
    //    pixel k (raster scan, k=0..24):
    //      fila imagen  = R_OFF + k/KERN_SIZE
    //      col  imagen  = C_OFF + k%KERN_SIZE
    //      bit offset   = (R_OFF + k/KERN_SIZE)*IMG_ROW_BITS
    //                   + (C_OFF + k%KERN_SIZE)*BITS_PX
    //
    //  Todos los offsets son constantes de elaboración (genvar).

    wire signed [BITS_PX-1:0] px [0:N_PX-1];
    wire signed [BITS_W-1:0]  w  [0:N_PX-1];

    genvar i;
    generate
        for (i = 0; i < N_PX; i = i + 1) begin : UNPACK
            // Offsets de pixel en el parche (constantes de compilación)
            localparam integer KR  = i / KERN_SIZE;           // fila dentro del kernel
            localparam integer KC  = i % KERN_SIZE;           // columna dentro del kernel
            localparam integer IR  = R_OFF + KR;              // fila en la imagen
            localparam integer IC  = C_OFF + KC;              // columna en la imagen
            localparam integer PX_BIT = IR * IMG_ROW_BITS + IC * BITS_PX; // offset en px_flat

            assign px[i] = $signed(px_flat_reg[PX_BIT +: BITS_PX]);
            assign w[i]  = w_flat_reg[i * BITS_W +: BITS_W];
        end
    endgenerate

    // ── Multiplicación (3-bit signed × 3-bit signed → 6-bit signed) ──────
    wire signed [5:0] p [0:N_PX-1];
    generate
        for (i = 0; i < N_PX; i = i + 1) begin : MULT
            (* multstyle = "logic" *) wire signed [5:0] prod;
            assign prod = px[i] * w[i];
            assign p[i] = prod;
        end
    endgenerate

    // ── Suma de los 25 productos ──────────────────────────
    //  Máx: 25 × 16 = 400 → cabe en 10 bits (±512 → 11 bits signed ✓)
    wire signed [10:0] sum;
    assign sum =
        p[0]+p[1]+p[2]+p[3]+p[4]+
        p[5]+p[6]+p[7]+p[8]+p[9]+
        p[10]+p[11]+p[12]+p[13]+p[14]+
        p[15]+p[16]+p[17]+p[18]+p[19]+
        p[20]+p[21]+p[22]+p[23]+p[24];

    // ── Registro de salida + flag ready ───────────────────
    reg signed [10:0] y_reg;
    reg               ready_reg;

    always @(posedge clk) begin
        if (rst) begin
            y_reg     <= 11'd0;
            ready_reg <= 1'b0;
        end else begin
            y_reg     <= sum;
            ready_reg <= 1'b1;
        end
    end

    assign y     = y_reg;
    assign ready = ready_reg;

endmodule