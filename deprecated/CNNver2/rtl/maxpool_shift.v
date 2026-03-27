//=======================================================
//  MODULE: maxpool_shift
//=======================================================
//  Shift register de 4 etapas de 11 bits con comparador
//  encadenado. Calcula el maximo de 4 vectores recibidos
//  uno por uno desde la SPI (con padding a 16 bits).
//
//  Flujo:
//    La SPI recibe 4 palabras de 16 bits (5 bits padding + 11 utiles).
//    Cada vez que llega una palabra valida activa i_load por 1 ciclo.
//    El dato entra a reg0, los anteriores se desplazan:
//      reg3 <- reg2 <- reg1 <- reg0 <- i_data[10:0]
//
//    Cuando llegan los 4 (count llega a 3):
//      valid_reg se activa 1 ciclo -> o_valid pulsa
//      o_max = max(reg0, reg1, reg2, reg3)
//
//  Senales:
//    i_clk       — reloj (SPI clock)
//    i_rst       — reset activo alto
//    i_data[15:0]— dato desde SPI (16 bits, solo [10:0] se usa)
//    i_load      — pulso activo alto: nuevo dato valido
//    o_max[10:0] — maximo de los 4 vectores (signed)
//    o_valid     — pulso 1 ciclo: o_max es valido, cargar Master
//
//  Comparador encadenado (signed):
//    max01 = max(reg0, reg1)
//    max23 = max(reg2, reg3)
//    o_max = max(max01, max23)
//=======================================================

module maxpool_shift (
    input  wire        i_clk,
    input  wire        i_rst,

    input  wire [15:0] i_data,   // [15:11] padding, [10:0] dato util
    input  wire        i_load,   // pulso: nuevo dato valido

    output wire signed [10:0] o_max,
    output wire               o_valid   // pulso 1 ciclo cuando o_max listo
);

    // ── Shift register 4 x 11 bits (signed) ──────────────────────────
    reg signed [10:0] reg0, reg1, reg2, reg3;

    // ── Contador de datos recibidos (0..3) ───────────────────────────
    reg [1:0] count;
    reg       valid_reg;

    always @(posedge i_clk) begin
        if (i_rst) begin
            reg0      <= 11'sd0;
            reg1      <= 11'sd0;
            reg2      <= 11'sd0;
            reg3      <= 11'sd0;
            count     <= 2'd0;
            valid_reg <= 1'b0;
        end
        else begin
            valid_reg <= 1'b0;   // pulso de 1 ciclo por defecto

            if (i_load) begin
                // Desplazamiento: reg3 <- reg2 <- reg1 <- reg0 <- nuevo
                reg3 <= reg2;
                reg2 <= reg1;
                reg1 <= reg0;
                reg0 <= $signed(i_data[10:0]);

                if (count == 2'd3) begin
                    // Llego el 4o dato — o_max valido este ciclo
                    count     <= 2'd0;
                    valid_reg <= 1'b1;
                end
                else begin
                    count <= count + 2'd1;
                end
            end
        end
    end

    // ── Comparador encadenado (combinacional) ─────────────────────────
    wire signed [10:0] max01;
    wire signed [10:0] max23;

    assign max01 = ($signed(reg0) > $signed(reg1)) ? reg0 : reg1;
    assign max23 = ($signed(reg2) > $signed(reg3)) ? reg2 : reg3;
    assign o_max = ($signed(max01) > $signed(max23)) ? max01 : max23;

    assign o_valid = valid_reg;

endmodule
