module cnn_v2 (
    input  wire              clk,
    input  wire              rst,
    input  wire signed [74:0] w_flat_in,
    input  wire        [74:0] px_flat_in,
    output wire signed [10:0] y,
    output wire               ready
);

    // ── Registros de entrada ──────────────────────────────
    reg signed [74:0] w_flat_reg;
    reg        [74:0] px_flat_reg;

    always @(posedge clk) begin
        if (rst) begin
            w_flat_reg  <= 75'd0;
            px_flat_reg <= 75'd0;
        end else begin
            w_flat_reg  <= w_flat_in;
            px_flat_reg <= px_flat_in;
        end
    end

    // ── Unpack ────────────────────────────────────────────
    wire signed [2:0] w  [0:24];
    wire        [2:0] px [0:24];

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : UNPACK
            assign w[i]  = w_flat_reg[i*3 +: 3];
            assign px[i] = px_flat_reg[i*3 +: 3];
        end
    endgenerate

    // ── Multiplicación ────────────────────────────────────
	wire signed [5:0] p [0:24];
	generate
		 for (i = 0; i < 25; i = i + 1) begin : MULT
			  (* multstyle = "logic" *) wire signed [5:0] prod;
			  assign prod = $signed(px[i]) * w[i];
			  assign p[i] = prod;
		 end
	endgenerate
    // ── Suma ──────────────────────────────────────────────
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