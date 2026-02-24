module cnn_conv_v2 (
    input  wire        clk,
    input  wire        rst,
    // Entradas convolución
    input  wire        [74:0] px_flat_in,
    input  wire signed [74:0] w_flat_in,
    // Entradas adicionales (4 × 11 bits) — para bloque futuro
    input  wire signed [10:0] additional_in_0,
    input  wire signed [10:0] additional_in_1,
    input  wire signed [10:0] additional_in_2,
    input  wire signed [10:0] additional_in_3,
    // Salidas convolución
    output wire signed [10:0] y_out,
    output wire               ready,
    // Salida adicional (15 bits) — para bloque futuro
    output wire signed [14:0] additional_out
);
    // ── Registros adicionales (viven aquí hasta que exista el bloque) ──
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
				 // Suma real de los 4 registros — ocupa los bits necesarios
				 additional_out_reg <= additional_reg_0 + additional_reg_1
 											 + additional_reg_2 + additional_reg_3;
		 end
	 end
    assign additional_out = additional_out_reg;

    // ── Instancia CNN (sin cambios) ────────────────────────
    wire signed [10:0] y;
    wire               rdy;

    cnn_v2 uut (
        .clk       (clk),
        .rst       (rst),
        .w_flat_in (w_flat_in),
        .px_flat_in(px_flat_in),
        .y         (y),
        .ready     (rdy)
    );

    assign y_out = y;
    assign ready = rdy;

endmodule