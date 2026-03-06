//=======================================================
//  tb_comm_mem_top_v4 — Cobertura completa SPI
//=======================================================
//  Tests:
//    T01 — LOAD IMAGE: las 10 filas, verificar cada registro
//    T02 — LOAD IMAGE dos veces (sobreescritura)
//    T03 — LOAD WEIGHTS: los 5 pesos, verificar cada registro
//    T04 — LOAD WEIGHTS dos veces (sobreescritura)
//    T05 — START CNN: pulso correcto
//    T06 — START CNN doble (dos transacciones)
//    T07 — READ MR1: valor correcto por MISO
//    T08 — READ MR2: valor correcto por MISO
//    T09 — READ RESULT: comp=1
//    T10 — READ RESULT: comp=0
//    T11 — READ MR1 tras cambio de acc0
//    T12 — RESET global: todos los registros vuelven a 0
//    T13 — Secuencia completa: imagen + pesos + start + read
//=======================================================
`timescale 1ns/1ps

module tb_comm_mem_top_v4;

    // ── Ports ─────────────────────────────────────────
    reg         clk_spi;
    reg         cs_n;
    reg         mosi;
    wire        miso;
    reg         rst;
    reg         cmd_reset;

    wire        o_MR1_Load_dbg;
    wire        o_MR2_Load_dbg;

    wire [29:0] img_row00, img_row01, img_row02, img_row03, img_row04;
    wire [29:0] img_row05, img_row06, img_row07, img_row08, img_row09;
    wire [14:0] wgt_row00, wgt_row01, wgt_row02, wgt_row03, wgt_row04;
    wire        start_cnn;

    reg  [15:0] acc0, acc1;
    reg         mr1_load, mr2_load;
    reg         comp_result;

    // ── DUT ───────────────────────────────────────────
    comm_mem_top dut (
        .i_SPI_Clk    (clk_spi),
        .i_SPI_CS_n   (cs_n),
        .i_SPI_MOSI   (mosi),
        .o_SPI_MISO   (miso),
        .i_RESET      (rst),
        .i_CMD_Reset  (cmd_reset),
        .o_MR1_Load_dbg(o_MR1_Load_dbg),
        .o_MR2_Load_dbg(o_MR2_Load_dbg),
        .o_img_row00(img_row00), .o_img_row01(img_row01),
        .o_img_row02(img_row02), .o_img_row03(img_row03),
        .o_img_row04(img_row04), .o_img_row05(img_row05),
        .o_img_row06(img_row06), .o_img_row07(img_row07),
        .o_img_row08(img_row08), .o_img_row09(img_row09),
        .o_wgt_row00(wgt_row00), .o_wgt_row01(wgt_row01),
        .o_wgt_row02(wgt_row02), .o_wgt_row03(wgt_row03),
        .o_wgt_row04(wgt_row04),
        .o_start_cnn  (start_cnn),
        .i_acc0       (acc0),
        .i_mr1_load   (mr1_load),
        .i_acc1       (acc1),
        .i_mr2_load   (mr2_load),
        .i_comp_result(comp_result)
    );

    // ── Parámetros ────────────────────────────────────
    parameter CLK_HALF = 10;

    // ── Contadores globales ───────────────────────────
    integer pass_count, fail_count;

    // ── Macro de verificación ─────────────────────────
    // CHECK(nombre, got, expected)
    task check;
        input [255:0] name;
        input [31:0]  got;
        input [31:0]  expected;
        begin
            if (got === expected) begin
                $display("    PASS  %0s = %0h", name, got);
                pass_count = pass_count + 1;
            end else begin
                $display("    FAIL  %0s : got=%0h  expected=%0h", name, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Datos de prueba ───────────────────────────────
    // Imagen A: 10 filas con valores únicos y reconocibles
    localparam [29:0]
        IA0 = 30'h15A0_001, IA1 = 30'h15A0_002, IA2 = 30'h15A0_003,
        IA3 = 30'h15A0_004, IA4 = 30'h15A0_005, IA5 = 30'h15A0_006,
        IA6 = 30'h15A0_007, IA7 = 30'h15A0_008, IA8 = 30'h15A0_009,
        IA9 = 30'h15A0_00A;

    // Imagen B: sobreescritura
    localparam [29:0]
        IB0 = 30'h2BC0_001, IB1 = 30'h2BC0_002, IB2 = 30'h2BC0_003,
        IB3 = 30'h2BC0_004, IB4 = 30'h2BC0_005, IB5 = 30'h2BC0_006,
        IB6 = 30'h2BC0_007, IB7 = 30'h2BC0_008, IB8 = 30'h2BC0_009,
        IB9 = 30'h2BC0_00A;

    // Pesos A y B
    localparam [14:0]
        WA0=15'h1A1, WA1=15'h1B2, WA2=15'h1C3, WA3=15'h1D4, WA4=15'h1E5,
        WB0=15'h2F0, WB1=15'h2E1, WB2=15'h2D2, WB3=15'h2C3, WB4=15'h2B4;

    // ── Main ──────────────────────────────────────────
    initial begin
        clk_spi     = 0; cs_n = 1; mosi = 0;
        rst = 1; cmd_reset = 0;
        acc0 = 16'hABCD; acc1 = 16'h1234;
        mr1_load = 1; mr2_load = 1;
        comp_result = 1;
        pass_count = 0; fail_count = 0;

        #(CLK_HALF*4) rst = 0;
        #(CLK_HALF*2);

        $display("=========================================");
        $display(" tb_comm_mem_top_v4 — Cobertura completa");
        $display("=========================================");

        // ══════════════════════════════════════════════
        // T01 — LOAD IMAGE: las 10 filas
        // ══════════════════════════════════════════════
        $display("\n--- T01: LOAD IMAGE (10 filas) ---");
        spi_load_image_all(IA0,IA1,IA2,IA3,IA4,IA5,IA6,IA7,IA8,IA9);
        check("img_row00", img_row00, IA0);
        check("img_row01", img_row01, IA1);
        check("img_row02", img_row02, IA2);
        check("img_row03", img_row03, IA3);
        check("img_row04", img_row04, IA4);
        check("img_row05", img_row05, IA5);
        check("img_row06", img_row06, IA6);
        check("img_row07", img_row07, IA7);
        check("img_row08", img_row08, IA8);
        check("img_row09", img_row09, IA9);

        // ══════════════════════════════════════════════
        // T02 — LOAD IMAGE sobreescritura
        // ══════════════════════════════════════════════
        $display("\n--- T02: LOAD IMAGE sobreescritura ---");
        spi_load_image_all(IB0,IB1,IB2,IB3,IB4,IB5,IB6,IB7,IB8,IB9);
        check("img_row00", img_row00, IB0);
        check("img_row01", img_row01, IB1);
        check("img_row02", img_row02, IB2);
        check("img_row03", img_row03, IB3);
        check("img_row04", img_row04, IB4);
        check("img_row05", img_row05, IB5);
        check("img_row06", img_row06, IB6);
        check("img_row07", img_row07, IB7);
        check("img_row08", img_row08, IB8);
        check("img_row09", img_row09, IB9);

        // ══════════════════════════════════════════════
        // T03 — LOAD WEIGHTS: los 5 pesos
        // ══════════════════════════════════════════════
        $display("\n--- T03: LOAD WEIGHTS (5 pesos) ---");
        spi_load_weights_all(WA0,WA1,WA2,WA3,WA4);
        check("wgt_row00", wgt_row00, WA0);
        check("wgt_row01", wgt_row01, WA1);
        check("wgt_row02", wgt_row02, WA2);
        check("wgt_row03", wgt_row03, WA3);
        check("wgt_row04", wgt_row04, WA4);

        // ══════════════════════════════════════════════
        // T04 — LOAD WEIGHTS sobreescritura
        // ══════════════════════════════════════════════
        $display("\n--- T04: LOAD WEIGHTS sobreescritura ---");
        spi_load_weights_all(WB0,WB1,WB2,WB3,WB4);
        check("wgt_row00", wgt_row00, WB0);
        check("wgt_row01", wgt_row01, WB1);
        check("wgt_row02", wgt_row02, WB2);
        check("wgt_row03", wgt_row03, WB3);
        check("wgt_row04", wgt_row04, WB4);

        // ══════════════════════════════════════════════
        // T05 — START CNN: pulso activo 1 ciclo
        // ══════════════════════════════════════════════
        $display("\n--- T05: START CNN ---");
        begin : t05
            reg saw_pulse;
            saw_pulse = 0;
            fork
                begin
                    @(posedge start_cnn);
                    saw_pulse = 1;
                end
                begin
                    spi_start_cnn();
                    #(CLK_HALF*4);
                end
            join
            check("start_cnn pulse", saw_pulse, 1);
            // 1 pulso extra para que el default limpie start_cnn
            spi_clk_pulse();
            check("start_cnn low after", start_cnn, 0);
        end

        // ══════════════════════════════════════════════
        // T06 — START CNN doble (dos transacciones)
        // ══════════════════════════════════════════════
        $display("\n--- T06: START CNN doble ---");
        begin : t06
            integer pulse_count;
            pulse_count = 0;
            fork
                begin
                    repeat(2) begin
                        @(posedge start_cnn);
                        pulse_count = pulse_count + 1;
                    end
                end
                begin
                    spi_start_cnn(); #(CLK_HALF*2);
                    spi_start_cnn(); #(CLK_HALF*4);
                end
            join
            check("start_cnn 2 pulses", pulse_count, 2);
        end

        // ══════════════════════════════════════════════
        // T07 — READ MR1
        // ══════════════════════════════════════════════
        $display("\n--- T07: READ MR1 ---");
        begin : t07
            reg [15:0] rx;
            acc0 = 16'hABCD;
            mr1_load = 0; spi_clk_pulse(); mr1_load = 1;
            #(CLK_HALF*2);
            spi_read_16(3'b101, rx);
            check("MR1 via MISO", rx, 16'hABCD);
        end

        // ══════════════════════════════════════════════
        // T08 — READ MR2
        // ══════════════════════════════════════════════
        $display("\n--- T08: READ MR2 ---");
        begin : t08
            reg [15:0] rx;
            acc1 = 16'h1234;
            mr2_load = 0; spi_clk_pulse(); mr2_load = 1;
            #(CLK_HALF*2);
            spi_read_16(3'b110, rx);
            check("MR2 via MISO", rx, 16'h1234);
        end

        // ══════════════════════════════════════════════
        // T09 — READ RESULT comp=1
        // ══════════════════════════════════════════════
        $display("\n--- T09: READ RESULT comp=1 ---");
        begin : t09
            reg rx_bit;
            comp_result = 1;
            spi_read_1bit(rx_bit);
            check("comp=1 via MISO", rx_bit, 1);
        end

        // ══════════════════════════════════════════════
        // T10 — READ RESULT comp=0
        // ══════════════════════════════════════════════
        $display("\n--- T10: READ RESULT comp=0 ---");
        begin : t10
            reg rx_bit;
            comp_result = 0;
            spi_read_1bit(rx_bit);
            check("comp=0 via MISO", rx_bit, 0);
        end

        // ══════════════════════════════════════════════
        // T11 — READ MR1 tras cambio de acc0
        // ══════════════════════════════════════════════
        $display("\n--- T11: READ MR1 tras cambio de acc0 ---");
        begin : t11
            reg [15:0] rx;
            acc0 = 16'hDEAD;
            mr1_load = 0; spi_clk_pulse(); mr1_load = 1;
            #(CLK_HALF*2);
            spi_read_16(3'b101, rx);
            check("MR1 updated DEAD", rx, 16'hDEAD);
        end

        // ══════════════════════════════════════════════
        // T12 — RESET global
        // Register_Imag/Weight/Master tienen reset SÍNCRONO:
        // necesitan posedge de SPI_Clk con rst=1 para limpiar.
        // ══════════════════════════════════════════════
        $display("\n--- T12: RESET global ---");
        rst = 1;
        repeat(4) spi_clk_pulse();   // pulsos con rst=1 → registros se limpian
        rst = 0; #(CLK_HALF*2);
        check("img_row00 after reset", img_row00, 30'd0);
        check("img_row09 after reset", img_row09, 30'd0);
        check("wgt_row00 after reset", wgt_row00, 15'd0);
        check("wgt_row04 after reset", wgt_row04, 15'd0);
        begin : t12mr
            reg [15:0] rx;
            // MR1 debe leer 0 tras reset
            spi_read_16(3'b101, rx);
            check("MR1 after reset", rx, 16'h0000);
        end

        // ══════════════════════════════════════════════
        // T13 — Secuencia completa end-to-end
        // ══════════════════════════════════════════════
        $display("\n--- T13: Secuencia completa ---");
        // Cargar imagen
        spi_load_image_all(IA0,IA1,IA2,IA3,IA4,IA5,IA6,IA7,IA8,IA9);
        // Cargar pesos
        spi_load_weights_all(WA0,WA1,WA2,WA3,WA4);
        // Verificar que imagen y pesos no se pisaron mutuamente
        check("e2e img_row00", img_row00, IA0);
        check("e2e img_row09", img_row09, IA9);
        check("e2e wgt_row00", wgt_row00, WA0);
        check("e2e wgt_row04", wgt_row04, WA4);
        // Start CNN
        begin : t13s
            reg saw;
            saw = 0;
            fork
                begin @(posedge start_cnn); saw = 1; end
                begin spi_start_cnn(); #(CLK_HALF*4); end
            join
            check("e2e start_cnn", saw, 1);
        end
        // Simular resultado de CNN: cargar MR1 y MR2
        acc0 = 16'hCAFE; acc1 = 16'hBEEF;
        mr1_load = 0; spi_clk_pulse(); mr1_load = 1;
        mr2_load = 0; spi_clk_pulse(); mr2_load = 1;
        #(CLK_HALF*2);
        // Leer resultados
        begin : t13r
            reg [15:0] rx1, rx2;
            reg rx_comp;
            comp_result = 1;
            spi_read_16(3'b101, rx1);
            spi_read_16(3'b110, rx2);
            spi_read_1bit(rx_comp);
            check("e2e MR1", rx1, 16'hCAFE);
            check("e2e MR2", rx2, 16'hBEEF);
            check("e2e comp", rx_comp, 1'b1);
        end

        // ── Resumen ────────────────────────────────────
        $display("\n=========================================");
        $display(" RESULTADOS: %0d PASS / %0d FAIL", pass_count, fail_count);
        if (fail_count == 0)
            $display(" *** TODOS LOS TESTS PASARON *** ");
        $display("=========================================\n");
        $finish;
    end

    // ═════════════════════════════════════════════════
    // Tasks SPI
    // ═════════════════════════════════════════════════

    task spi_clk_pulse;
        begin
            #CLK_HALF; clk_spi = 1;
            #CLK_HALF; clk_spi = 0;
        end
    endtask

    task spi_send_bits;
        input integer n;
        input [31:0] data;
        integer k;
        begin
            for (k = n-1; k >= 0; k = k - 1) begin
                mosi = data[k];
                spi_clk_pulse();
            end
        end
    endtask

    // ── LOAD IMAGE: 10 filas en una sola transacción ──
    // Filas 0-8: sin clock extra (el MSB de la fila N+1 actúa como T34)
    // Fila 9: clock extra explícito al final
    task spi_load_image_all;
        input [29:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
        integer f;
        reg [29:0] rows [0:9];
        begin
            rows[0]=r0; rows[1]=r1; rows[2]=r2; rows[3]=r3; rows[4]=r4;
            rows[5]=r5; rows[6]=r6; rows[7]=r7; rows[8]=r8; rows[9]=r9;
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b001);
            for (f = 0; f < 9; f = f + 1)
                spi_send_bits(30, {2'b0, rows[f]});
            spi_send_bits(30, {2'b0, rows[9]});
            mosi = 0; spi_clk_pulse();   // clock extra fila 9
            cs_n = 1; #(CLK_HALF*4);
        end
    endtask

    // ── LOAD WEIGHTS: 5 pesos en una sola transacción ─
    task spi_load_weights_all;
        input [14:0] w0,w1,w2,w3,w4;
        integer f;
        reg [14:0] wts [0:4];
        begin
            wts[0]=w0; wts[1]=w1; wts[2]=w2; wts[3]=w3; wts[4]=w4;
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b010);
            for (f = 0; f < 4; f = f + 1)
                spi_send_bits(15, {17'b0, wts[f]});
            spi_send_bits(15, {17'b0, wts[4]});
            mosi = 0; spi_clk_pulse();   // clock extra peso 4
            cs_n = 1; #(CLK_HALF*4);
        end
    endtask

    // ── START CNN ─────────────────────────────────────
    task spi_start_cnn;
        begin
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b011);
            mosi = 0; spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask

    // ── READ 16 bits por MISO ─────────────────────────
    // Leer MISO antes del posedge (miso_count estable)
    task spi_read_16;
        input  [2:0]  cmd_bits;
        output [15:0] rx_data;
        integer k;
        begin
            rx_data = 0;
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, {29'b0, cmd_bits});
            for (k = 15; k >= 0; k = k - 1) begin
                rx_data[k] = miso;
                #CLK_HALF; clk_spi = 1;
                #CLK_HALF; clk_spi = 0;
            end
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask

    // ── READ RESULT (1 bit) ───────────────────────────
    task spi_read_1bit;
        output rx_bit;
        begin
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b100);
            rx_bit = miso;
            #CLK_HALF; clk_spi = 1;
            #CLK_HALF; clk_spi = 0;
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask

    // ── Timeout ───────────────────────────────────────
    initial begin
        #2000000;
        $display("TIMEOUT — simulacion abortada");
        $finish;
    end

endmodule
