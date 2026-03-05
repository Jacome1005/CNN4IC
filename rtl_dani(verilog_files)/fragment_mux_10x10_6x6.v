module fragment_mux_10x10_6x6 (
    input  wire [299:0] image_flat,   // 100 píxeles * 3 bits = 300 bits
    input  wire [3:0]   frag_sel,     // 0-8: selección del fragmento 6x6
    output reg  [107:0] fragment_flat // 36 píxeles * 3 bits = 108 bits
);
    wire [2:0] img [0:99];
    genvar i;
    generate
        for (i = 0; i < 100; i = i + 1) begin : unpack
            assign img[i] = image_flat[i*3 +: 3];
        end
    endgenerate

    always @(*) begin
        case (frag_sel)
            // frag 0: origen (row=0, col=0)
            4'd0: begin
                fragment_flat[0*3 +: 3]=img[0];  fragment_flat[1*3 +: 3]=img[1];  fragment_flat[2*3 +: 3]=img[2];  fragment_flat[3*3 +: 3]=img[3];  fragment_flat[4*3 +: 3]=img[4];  fragment_flat[5*3 +: 3]=img[5];
                fragment_flat[6*3 +: 3]=img[10]; fragment_flat[7*3 +: 3]=img[11]; fragment_flat[8*3 +: 3]=img[12]; fragment_flat[9*3 +: 3]=img[13]; fragment_flat[10*3 +: 3]=img[14]; fragment_flat[11*3 +: 3]=img[15];
                fragment_flat[12*3 +: 3]=img[20]; fragment_flat[13*3 +: 3]=img[21]; fragment_flat[14*3 +: 3]=img[22]; fragment_flat[15*3 +: 3]=img[23]; fragment_flat[16*3 +: 3]=img[24]; fragment_flat[17*3 +: 3]=img[25];
                fragment_flat[18*3 +: 3]=img[30]; fragment_flat[19*3 +: 3]=img[31]; fragment_flat[20*3 +: 3]=img[32]; fragment_flat[21*3 +: 3]=img[33]; fragment_flat[22*3 +: 3]=img[34]; fragment_flat[23*3 +: 3]=img[35];
                fragment_flat[24*3 +: 3]=img[40]; fragment_flat[25*3 +: 3]=img[41]; fragment_flat[26*3 +: 3]=img[42]; fragment_flat[27*3 +: 3]=img[43]; fragment_flat[28*3 +: 3]=img[44]; fragment_flat[29*3 +: 3]=img[45];
                fragment_flat[30*3 +: 3]=img[50]; fragment_flat[31*3 +: 3]=img[51]; fragment_flat[32*3 +: 3]=img[52]; fragment_flat[33*3 +: 3]=img[53]; fragment_flat[34*3 +: 3]=img[54]; fragment_flat[35*3 +: 3]=img[55];
            end
            // frag 1: origen (row=0, col=2)
            4'd1: begin
                fragment_flat[0*3 +: 3]=img[2];  fragment_flat[1*3 +: 3]=img[3];  fragment_flat[2*3 +: 3]=img[4];  fragment_flat[3*3 +: 3]=img[5];  fragment_flat[4*3 +: 3]=img[6];  fragment_flat[5*3 +: 3]=img[7];
                fragment_flat[6*3 +: 3]=img[12]; fragment_flat[7*3 +: 3]=img[13]; fragment_flat[8*3 +: 3]=img[14]; fragment_flat[9*3 +: 3]=img[15]; fragment_flat[10*3 +: 3]=img[16]; fragment_flat[11*3 +: 3]=img[17];
                fragment_flat[12*3 +: 3]=img[22]; fragment_flat[13*3 +: 3]=img[23]; fragment_flat[14*3 +: 3]=img[24]; fragment_flat[15*3 +: 3]=img[25]; fragment_flat[16*3 +: 3]=img[26]; fragment_flat[17*3 +: 3]=img[27];
                fragment_flat[18*3 +: 3]=img[32]; fragment_flat[19*3 +: 3]=img[33]; fragment_flat[20*3 +: 3]=img[34]; fragment_flat[21*3 +: 3]=img[35]; fragment_flat[22*3 +: 3]=img[36]; fragment_flat[23*3 +: 3]=img[37];
                fragment_flat[24*3 +: 3]=img[42]; fragment_flat[25*3 +: 3]=img[43]; fragment_flat[26*3 +: 3]=img[44]; fragment_flat[27*3 +: 3]=img[45]; fragment_flat[28*3 +: 3]=img[46]; fragment_flat[29*3 +: 3]=img[47];
                fragment_flat[30*3 +: 3]=img[52]; fragment_flat[31*3 +: 3]=img[53]; fragment_flat[32*3 +: 3]=img[54]; fragment_flat[33*3 +: 3]=img[55]; fragment_flat[34*3 +: 3]=img[56]; fragment_flat[35*3 +: 3]=img[57];
            end
            // frag 2: origen (row=0, col=4)
            4'd2: begin
                fragment_flat[0*3 +: 3]=img[4];  fragment_flat[1*3 +: 3]=img[5];  fragment_flat[2*3 +: 3]=img[6];  fragment_flat[3*3 +: 3]=img[7];  fragment_flat[4*3 +: 3]=img[8];  fragment_flat[5*3 +: 3]=img[9];
                fragment_flat[6*3 +: 3]=img[14]; fragment_flat[7*3 +: 3]=img[15]; fragment_flat[8*3 +: 3]=img[16]; fragment_flat[9*3 +: 3]=img[17]; fragment_flat[10*3 +: 3]=img[18]; fragment_flat[11*3 +: 3]=img[19];
                fragment_flat[12*3 +: 3]=img[24]; fragment_flat[13*3 +: 3]=img[25]; fragment_flat[14*3 +: 3]=img[26]; fragment_flat[15*3 +: 3]=img[27]; fragment_flat[16*3 +: 3]=img[28]; fragment_flat[17*3 +: 3]=img[29];
                fragment_flat[18*3 +: 3]=img[34]; fragment_flat[19*3 +: 3]=img[35]; fragment_flat[20*3 +: 3]=img[36]; fragment_flat[21*3 +: 3]=img[37]; fragment_flat[22*3 +: 3]=img[38]; fragment_flat[23*3 +: 3]=img[39];
                fragment_flat[24*3 +: 3]=img[44]; fragment_flat[25*3 +: 3]=img[45]; fragment_flat[26*3 +: 3]=img[46]; fragment_flat[27*3 +: 3]=img[47]; fragment_flat[28*3 +: 3]=img[48]; fragment_flat[29*3 +: 3]=img[49];
                fragment_flat[30*3 +: 3]=img[54]; fragment_flat[31*3 +: 3]=img[55]; fragment_flat[32*3 +: 3]=img[56]; fragment_flat[33*3 +: 3]=img[57]; fragment_flat[34*3 +: 3]=img[58]; fragment_flat[35*3 +: 3]=img[59];
            end
            // frag 3: origen (row=2, col=0)
            4'd3: begin
                fragment_flat[0*3 +: 3]=img[20]; fragment_flat[1*3 +: 3]=img[21]; fragment_flat[2*3 +: 3]=img[22]; fragment_flat[3*3 +: 3]=img[23]; fragment_flat[4*3 +: 3]=img[24]; fragment_flat[5*3 +: 3]=img[25];
                fragment_flat[6*3 +: 3]=img[30]; fragment_flat[7*3 +: 3]=img[31]; fragment_flat[8*3 +: 3]=img[32]; fragment_flat[9*3 +: 3]=img[33]; fragment_flat[10*3 +: 3]=img[34]; fragment_flat[11*3 +: 3]=img[35];
                fragment_flat[12*3 +: 3]=img[40]; fragment_flat[13*3 +: 3]=img[41]; fragment_flat[14*3 +: 3]=img[42]; fragment_flat[15*3 +: 3]=img[43]; fragment_flat[16*3 +: 3]=img[44]; fragment_flat[17*3 +: 3]=img[45];
                fragment_flat[18*3 +: 3]=img[50]; fragment_flat[19*3 +: 3]=img[51]; fragment_flat[20*3 +: 3]=img[52]; fragment_flat[21*3 +: 3]=img[53]; fragment_flat[22*3 +: 3]=img[54]; fragment_flat[23*3 +: 3]=img[55];
                fragment_flat[24*3 +: 3]=img[60]; fragment_flat[25*3 +: 3]=img[61]; fragment_flat[26*3 +: 3]=img[62]; fragment_flat[27*3 +: 3]=img[63]; fragment_flat[28*3 +: 3]=img[64]; fragment_flat[29*3 +: 3]=img[65];
                fragment_flat[30*3 +: 3]=img[70]; fragment_flat[31*3 +: 3]=img[71]; fragment_flat[32*3 +: 3]=img[72]; fragment_flat[33*3 +: 3]=img[73]; fragment_flat[34*3 +: 3]=img[74]; fragment_flat[35*3 +: 3]=img[75];
            end
            // frag 4: origen (row=2, col=2)
            4'd4: begin
                fragment_flat[0*3 +: 3]=img[22]; fragment_flat[1*3 +: 3]=img[23]; fragment_flat[2*3 +: 3]=img[24]; fragment_flat[3*3 +: 3]=img[25]; fragment_flat[4*3 +: 3]=img[26]; fragment_flat[5*3 +: 3]=img[27];
                fragment_flat[6*3 +: 3]=img[32]; fragment_flat[7*3 +: 3]=img[33]; fragment_flat[8*3 +: 3]=img[34]; fragment_flat[9*3 +: 3]=img[35]; fragment_flat[10*3 +: 3]=img[36]; fragment_flat[11*3 +: 3]=img[37];
                fragment_flat[12*3 +: 3]=img[42]; fragment_flat[13*3 +: 3]=img[43]; fragment_flat[14*3 +: 3]=img[44]; fragment_flat[15*3 +: 3]=img[45]; fragment_flat[16*3 +: 3]=img[46]; fragment_flat[17*3 +: 3]=img[47];
                fragment_flat[18*3 +: 3]=img[52]; fragment_flat[19*3 +: 3]=img[53]; fragment_flat[20*3 +: 3]=img[54]; fragment_flat[21*3 +: 3]=img[55]; fragment_flat[22*3 +: 3]=img[56]; fragment_flat[23*3 +: 3]=img[57];
                fragment_flat[24*3 +: 3]=img[62]; fragment_flat[25*3 +: 3]=img[63]; fragment_flat[26*3 +: 3]=img[64]; fragment_flat[27*3 +: 3]=img[65]; fragment_flat[28*3 +: 3]=img[66]; fragment_flat[29*3 +: 3]=img[67];
                fragment_flat[30*3 +: 3]=img[72]; fragment_flat[31*3 +: 3]=img[73]; fragment_flat[32*3 +: 3]=img[74]; fragment_flat[33*3 +: 3]=img[75]; fragment_flat[34*3 +: 3]=img[76]; fragment_flat[35*3 +: 3]=img[77];
            end
            // frag 5: origen (row=2, col=4)
            4'd5: begin
                fragment_flat[0*3 +: 3]=img[24]; fragment_flat[1*3 +: 3]=img[25]; fragment_flat[2*3 +: 3]=img[26]; fragment_flat[3*3 +: 3]=img[27]; fragment_flat[4*3 +: 3]=img[28]; fragment_flat[5*3 +: 3]=img[29];
                fragment_flat[6*3 +: 3]=img[34]; fragment_flat[7*3 +: 3]=img[35]; fragment_flat[8*3 +: 3]=img[36]; fragment_flat[9*3 +: 3]=img[37]; fragment_flat[10*3 +: 3]=img[38]; fragment_flat[11*3 +: 3]=img[39];
                fragment_flat[12*3 +: 3]=img[44]; fragment_flat[13*3 +: 3]=img[45]; fragment_flat[14*3 +: 3]=img[46]; fragment_flat[15*3 +: 3]=img[47]; fragment_flat[16*3 +: 3]=img[48]; fragment_flat[17*3 +: 3]=img[49];
                fragment_flat[18*3 +: 3]=img[54]; fragment_flat[19*3 +: 3]=img[55]; fragment_flat[20*3 +: 3]=img[56]; fragment_flat[21*3 +: 3]=img[57]; fragment_flat[22*3 +: 3]=img[58]; fragment_flat[23*3 +: 3]=img[59];
                fragment_flat[24*3 +: 3]=img[64]; fragment_flat[25*3 +: 3]=img[65]; fragment_flat[26*3 +: 3]=img[66]; fragment_flat[27*3 +: 3]=img[67]; fragment_flat[28*3 +: 3]=img[68]; fragment_flat[29*3 +: 3]=img[69];
                fragment_flat[30*3 +: 3]=img[74]; fragment_flat[31*3 +: 3]=img[75]; fragment_flat[32*3 +: 3]=img[76]; fragment_flat[33*3 +: 3]=img[77]; fragment_flat[34*3 +: 3]=img[78]; fragment_flat[35*3 +: 3]=img[79];
            end
            // frag 6: origen (row=4, col=0)
            4'd6: begin
                fragment_flat[0*3 +: 3]=img[40]; fragment_flat[1*3 +: 3]=img[41]; fragment_flat[2*3 +: 3]=img[42]; fragment_flat[3*3 +: 3]=img[43]; fragment_flat[4*3 +: 3]=img[44]; fragment_flat[5*3 +: 3]=img[45];
                fragment_flat[6*3 +: 3]=img[50]; fragment_flat[7*3 +: 3]=img[51]; fragment_flat[8*3 +: 3]=img[52]; fragment_flat[9*3 +: 3]=img[53]; fragment_flat[10*3 +: 3]=img[54]; fragment_flat[11*3 +: 3]=img[55];
                fragment_flat[12*3 +: 3]=img[60]; fragment_flat[13*3 +: 3]=img[61]; fragment_flat[14*3 +: 3]=img[62]; fragment_flat[15*3 +: 3]=img[63]; fragment_flat[16*3 +: 3]=img[64]; fragment_flat[17*3 +: 3]=img[65];
                fragment_flat[18*3 +: 3]=img[70]; fragment_flat[19*3 +: 3]=img[71]; fragment_flat[20*3 +: 3]=img[72]; fragment_flat[21*3 +: 3]=img[73]; fragment_flat[22*3 +: 3]=img[74]; fragment_flat[23*3 +: 3]=img[75];
                fragment_flat[24*3 +: 3]=img[80]; fragment_flat[25*3 +: 3]=img[81]; fragment_flat[26*3 +: 3]=img[82]; fragment_flat[27*3 +: 3]=img[83]; fragment_flat[28*3 +: 3]=img[84]; fragment_flat[29*3 +: 3]=img[85];
                fragment_flat[30*3 +: 3]=img[90]; fragment_flat[31*3 +: 3]=img[91]; fragment_flat[32*3 +: 3]=img[92]; fragment_flat[33*3 +: 3]=img[93]; fragment_flat[34*3 +: 3]=img[94]; fragment_flat[35*3 +: 3]=img[95];
            end
            // frag 7: origen (row=4, col=2)
            4'd7: begin
                fragment_flat[0*3 +: 3]=img[42]; fragment_flat[1*3 +: 3]=img[43]; fragment_flat[2*3 +: 3]=img[44]; fragment_flat[3*3 +: 3]=img[45]; fragment_flat[4*3 +: 3]=img[46]; fragment_flat[5*3 +: 3]=img[47];
                fragment_flat[6*3 +: 3]=img[52]; fragment_flat[7*3 +: 3]=img[53]; fragment_flat[8*3 +: 3]=img[54]; fragment_flat[9*3 +: 3]=img[55]; fragment_flat[10*3 +: 3]=img[56]; fragment_flat[11*3 +: 3]=img[57];
                fragment_flat[12*3 +: 3]=img[62]; fragment_flat[13*3 +: 3]=img[63]; fragment_flat[14*3 +: 3]=img[64]; fragment_flat[15*3 +: 3]=img[65]; fragment_flat[16*3 +: 3]=img[66]; fragment_flat[17*3 +: 3]=img[67];
                fragment_flat[18*3 +: 3]=img[72]; fragment_flat[19*3 +: 3]=img[73]; fragment_flat[20*3 +: 3]=img[74]; fragment_flat[21*3 +: 3]=img[75]; fragment_flat[22*3 +: 3]=img[76]; fragment_flat[23*3 +: 3]=img[77];
                fragment_flat[24*3 +: 3]=img[82]; fragment_flat[25*3 +: 3]=img[83]; fragment_flat[26*3 +: 3]=img[84]; fragment_flat[27*3 +: 3]=img[85]; fragment_flat[28*3 +: 3]=img[86]; fragment_flat[29*3 +: 3]=img[87];
                fragment_flat[30*3 +: 3]=img[92]; fragment_flat[31*3 +: 3]=img[93]; fragment_flat[32*3 +: 3]=img[94]; fragment_flat[33*3 +: 3]=img[95]; fragment_flat[34*3 +: 3]=img[96]; fragment_flat[35*3 +: 3]=img[97];
            end
            // frag 8: origen (row=4, col=4)
            4'd8: begin
                fragment_flat[0*3 +: 3]=img[44]; fragment_flat[1*3 +: 3]=img[45]; fragment_flat[2*3 +: 3]=img[46]; fragment_flat[3*3 +: 3]=img[47]; fragment_flat[4*3 +: 3]=img[48]; fragment_flat[5*3 +: 3]=img[49];
                fragment_flat[6*3 +: 3]=img[54]; fragment_flat[7*3 +: 3]=img[55]; fragment_flat[8*3 +: 3]=img[56]; fragment_flat[9*3 +: 3]=img[57]; fragment_flat[10*3 +: 3]=img[58]; fragment_flat[11*3 +: 3]=img[59];
                fragment_flat[12*3 +: 3]=img[64]; fragment_flat[13*3 +: 3]=img[65]; fragment_flat[14*3 +: 3]=img[66]; fragment_flat[15*3 +: 3]=img[67]; fragment_flat[16*3 +: 3]=img[68]; fragment_flat[17*3 +: 3]=img[69];
                fragment_flat[18*3 +: 3]=img[74]; fragment_flat[19*3 +: 3]=img[75]; fragment_flat[20*3 +: 3]=img[76]; fragment_flat[21*3 +: 3]=img[77]; fragment_flat[22*3 +: 3]=img[78]; fragment_flat[23*3 +: 3]=img[79];
                fragment_flat[24*3 +: 3]=img[84]; fragment_flat[25*3 +: 3]=img[85]; fragment_flat[26*3 +: 3]=img[86]; fragment_flat[27*3 +: 3]=img[87]; fragment_flat[28*3 +: 3]=img[88]; fragment_flat[29*3 +: 3]=img[89];
                fragment_flat[30*3 +: 3]=img[94]; fragment_flat[31*3 +: 3]=img[95]; fragment_flat[32*3 +: 3]=img[96]; fragment_flat[33*3 +: 3]=img[97]; fragment_flat[34*3 +: 3]=img[98]; fragment_flat[35*3 +: 3]=img[99];
            end
            default: fragment_flat = 108'd0;
        endcase
    end
endmodule