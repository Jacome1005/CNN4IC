//=======================================================
//  cnn_conv_v2 — Wrapper de cnn_v2
//  ─────────────────────────────────────────────────────
//  ★ px_flat_in actualizado a 300 bits (10×10×3)
//  ★ w_flat_in  sigue en 75 bits (5×5×3)
//
//  El bloque "additional" permanece para uso futuro.
//=======================================================

module cnn_conv_v2 #(
    parameter R_OFF = 0,   // Posición de la convolución — fila
    parameter C_OFF = 0    // Posición de la convolución — columna
)(
    input  wire        clk,
    input  wire        rst,
    // Imagen completa 10×10×3 = 300 bits
    input  wire [299:0] px_flat_in,
    // Kernel 5×5×3 = 75 bits
    input  wire signed [74:0] w_flat_in,
    // Entradas adicionales (reservadas para uso futuro)
    input  wire signed [10:0] additional_in_0,
    input  wire signed [10:0] additional_in_1,
    input  wire signed [10:0] additional_in_2,
    input  wire signed [10:0] additional_in_3,
    // Salidas convolución
    output wire signed [10:0] y_out,
    output wire               ready,
    // Salida adicional (reservada)
    output wire signed [14:0] additional_out
);

    // ── Registros adicionales (uso futuro) ───────────────
    reg signed [10:0] additional_reg_0;
    reg signed [10:0] additional_reg_1;
    reg signed [10:0] additional_reg_2;
    reg signed [10:0] additional_reg_3;
    reg signed [14:0] additional_out_reg;

    always @(posedge clk) begin
        if (rst) begin
            additional_reg_0   <= 11'd0;
            additional_reg_1   <= 11'd0;
            additional_reg_2   <= 11'd0;
            additional_reg_3   <= 11'd0;
            additional_out_reg <= 15'd0;
        end else begin
            additional_reg_0   <= additional_in_0;
            additional_reg_1   <= additional_in_1;
            additional_reg_2   <= additional_in_2;
            additional_reg_3   <= additional_in_3;
            additional_out_reg <= additional_reg_0 + additional_reg_1
                                + additional_reg_2 + additional_reg_3;
        end
    end
    assign additional_out = additional_out_reg;

    // ── Instancia cnn_v2 ─────────────────────────────────
    wire signed [10:0] y;
    wire               rdy;

    cnn_v2 #(.R_OFF(R_OFF), .C_OFF(C_OFF)) uut (
        .clk        (clk),
        .rst        (rst),
        .px_flat_in (px_flat_in),
        .w_flat_in  (w_flat_in),
        .y          (y),
        .ready      (rdy)
    );

    assign y_out = y;
    assign ready = rdy;

endmodule