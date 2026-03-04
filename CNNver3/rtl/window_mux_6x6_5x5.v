module window_mux_6x6_5x5 (
    input  wire [107:0] fragment_flat,
    input  wire [1:0]   window_sel,
    output reg  [74:0]  window_flat
);
    wire [2:0] img [0:35];
    genvar i;
    generate
        for (i = 0; i < 36; i = i + 1) begin : unpack
            assign img[i] = fragment_flat[i*3 +: 3];
        end
    endgenerate

    // ventana 00: base (row=0, col=0)
    // ventana 01: base (row=0, col=1)
    // ventana 10: base (row=1, col=0)
    // ventana 11: base (row=1, col=1)

    integer j;
    always @(*) begin
    case (window_sel)
        2'b00: begin
            window_flat[0  +: 3] = img[0];  // (0,0)
            window_flat[3  +: 3] = img[1];  // (0,1)
            window_flat[6  +: 3] = img[2];  // (0,2)
            window_flat[9  +: 3] = img[3];  // (0,3)
            window_flat[12 +: 3] = img[4];  // (0,4)
            window_flat[15 +: 3] = img[6];  // (1,0)
            window_flat[18 +: 3] = img[7];  // (1,1)
            window_flat[21 +: 3] = img[8];  // (1,2)
            window_flat[24 +: 3] = img[9];  // (1,3)
            window_flat[27 +: 3] = img[10]; // (1,4)
            window_flat[30 +: 3] = img[12]; // (2,0)
            window_flat[33 +: 3] = img[13]; // (2,1)
            window_flat[36 +: 3] = img[14]; // (2,2)
            window_flat[39 +: 3] = img[15]; // (2,3)
            window_flat[42 +: 3] = img[16]; // (2,4)
            window_flat[45 +: 3] = img[18]; // (3,0)
            window_flat[48 +: 3] = img[19]; // (3,1)
            window_flat[51 +: 3] = img[20]; // (3,2)
            window_flat[54 +: 3] = img[21]; // (3,3)
            window_flat[57 +: 3] = img[22]; // (3,4)
            window_flat[60 +: 3] = img[24]; // (4,0)
            window_flat[63 +: 3] = img[25]; // (4,1)
            window_flat[66 +: 3] = img[26]; // (4,2)
            window_flat[69 +: 3] = img[27]; // (4,3)
            window_flat[72 +: 3] = img[28]; // (4,4)
        end
        2'b01: begin
            window_flat[0  +: 3] = img[1];  // (0,1)
            window_flat[3  +: 3] = img[2];
            window_flat[6  +: 3] = img[3];
            window_flat[9  +: 3] = img[4];
            window_flat[12 +: 3] = img[5];
            window_flat[15 +: 3] = img[7];  // (1,1)
            window_flat[18 +: 3] = img[8];
            window_flat[21 +: 3] = img[9];
            window_flat[24 +: 3] = img[10];
            window_flat[27 +: 3] = img[11];
            window_flat[30 +: 3] = img[13]; // (2,1)
            window_flat[33 +: 3] = img[14];
            window_flat[36 +: 3] = img[15];
            window_flat[39 +: 3] = img[16];
            window_flat[42 +: 3] = img[17];
            window_flat[45 +: 3] = img[19]; // (3,1)
            window_flat[48 +: 3] = img[20];
            window_flat[51 +: 3] = img[21];
            window_flat[54 +: 3] = img[22];
            window_flat[57 +: 3] = img[23];
            window_flat[60 +: 3] = img[25]; // (4,1)
            window_flat[63 +: 3] = img[26];
            window_flat[66 +: 3] = img[27];
            window_flat[69 +: 3] = img[28];
            window_flat[72 +: 3] = img[29];
        end
        2'b10: begin
            window_flat[0  +: 3] = img[6];  // (1,0)
            window_flat[3  +: 3] = img[7];
            window_flat[6  +: 3] = img[8];
            window_flat[9  +: 3] = img[9];
            window_flat[12 +: 3] = img[10];
            window_flat[15 +: 3] = img[12]; // (2,0)
            window_flat[18 +: 3] = img[13];
            window_flat[21 +: 3] = img[14];
            window_flat[24 +: 3] = img[15];
            window_flat[27 +: 3] = img[16];
            window_flat[30 +: 3] = img[18]; // (3,0)
            window_flat[33 +: 3] = img[19];
            window_flat[36 +: 3] = img[20];
            window_flat[39 +: 3] = img[21];
            window_flat[42 +: 3] = img[22];
            window_flat[45 +: 3] = img[24]; // (4,0)
            window_flat[48 +: 3] = img[25];
            window_flat[51 +: 3] = img[26];
            window_flat[54 +: 3] = img[27];
            window_flat[57 +: 3] = img[28];
            window_flat[60 +: 3] = img[30]; // (5,0)
            window_flat[63 +: 3] = img[31];
            window_flat[66 +: 3] = img[32];
            window_flat[69 +: 3] = img[33];
            window_flat[72 +: 3] = img[34];
        end
        2'b11: begin
            window_flat[0  +: 3] = img[7];  // (1,1)
            window_flat[3  +: 3] = img[8];
            window_flat[6  +: 3] = img[9];
            window_flat[9  +: 3] = img[10];
            window_flat[12 +: 3] = img[11];
            window_flat[15 +: 3] = img[13]; // (2,1)
            window_flat[18 +: 3] = img[14];
            window_flat[21 +: 3] = img[15];
            window_flat[24 +: 3] = img[16];
            window_flat[27 +: 3] = img[17];
            window_flat[30 +: 3] = img[19]; // (3,1)
            window_flat[33 +: 3] = img[20];
            window_flat[36 +: 3] = img[21];
            window_flat[39 +: 3] = img[22];
            window_flat[42 +: 3] = img[23];
            window_flat[45 +: 3] = img[25]; // (4,1)
            window_flat[48 +: 3] = img[26];
            window_flat[51 +: 3] = img[27];
            window_flat[54 +: 3] = img[28];
            window_flat[57 +: 3] = img[29];
            window_flat[60 +: 3] = img[31]; // (5,1)
            window_flat[63 +: 3] = img[32];
            window_flat[66 +: 3] = img[33];
            window_flat[69 +: 3] = img[34];
            window_flat[72 +: 3] = img[35];
        end
        default: window_flat = 75'd0;
    endcase
end
endmodule