//=======================================================
//  tb_comm_mem_top_v3 — Testbench con monitores internos
//=======================================================
//  Accede directamente a señales internas del SPI slave
//  para diagnosticar la cadena de carga completa.
//
//  Protocolo: 3 bits CMD + payload
//    001 = LOAD IMAGE  (10 filas × 30 bits)
//    010 = LOAD WEIGHTS (5 filas × 15 bits)
//    011 = START CNN
//    101 = READ MR1 (16 bits por MISO)
//    110 = READ MR2 (16 bits por MISO)
//    100 = READ RESULT (1 bit por MISO)
//
//  Cada transacción SPI:
//    1. CS_n baja
//    2. 3 clocks CMD (MSB primero)
//    3. N clocks de payload
//    4. 1 clock extra (necesario para que SM ejecute LOAD_ROW)
//    5. CS_n sube
//=======================================================
`timescale 1ns/1ps
module tb_comm_mem_top_v3;
    // ── DUT ports ─────────────────────────────────────
    reg        clk_spi;
    reg        cs_n;
    reg        mosi;
    wire       miso;
    reg        rst;
    reg        cmd_reset;
    wire       o_MR1_Load_dbg;
    wire       o_MR2_Load_dbg;
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
        .o_MR1_Load_dbg (o_MR1_Load_dbg),
        .o_MR2_Load_dbg (o_MR2_Load_dbg),
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
    // ── Acceso interno al SPI slave ───────────────────
    // Señales internas del slave (jerarquía directa)
    wire [2:0]  w_cmd        = dut.spi_u0.cmd;
    wire [8:0]  w_bit_count  = dut.spi_u0.bit_count;
    wire [6:0]  w_data_count = dut.spi_u0.data_count;
    wire [3:0]  w_row        = dut.spi_u0.row;
    wire        w_miso_active= dut.spi_u0.miso_active;
    wire [29:0] w_imem0      = dut.spi_u0.image_mem[0];
    wire [29:0] w_imem1      = dut.spi_u0.image_mem[1];
    wire        w_load00     = dut.load_img_u0;
    wire        w_load01     = dut.load_img_u1;
    // ── Clock generation ──────────────────────────────
    parameter CLK_HALF = 10;  // 50 MHz SPI
    initial clk_spi = 0;
    // No free-running clock — toggled manually in SPI task
    // ── Inicialización ────────────────────────────────
    integer i;
    integer pass_count, fail_count;
    initial begin
        clk_spi    = 0;
        cs_n       = 1;
        mosi       = 0;
        rst        = 1;
        cmd_reset  = 0;
        acc0       = 16'hABCD;
        acc1       = 16'h1234;
        mr1_load   = 1;   // inactivo (activo bajo)
        mr2_load   = 1;
        comp_result= 1;
        pass_count = 0;
        fail_count = 0;
        #(CLK_HALF*4) rst = 0;
        #(CLK_HALF*2);
        $display("=========================================");
        $display(" tb_comm_mem_top_v3 — Inicio");
        $display("=========================================");
        // ── TEST 1: LOAD IMAGE ─────────────────────────
        $display("\n--- TEST 1: LOAD IMAGE ---");
        spi_load_image_all(
            30'h1A2B3C, 30'h2B3C4D, 30'h000001, 30'h000002, 30'h000003,
            30'h000004, 30'h000005, 30'h000006, 30'h000007, 30'h000008
        );
        $display("  img_row00 (Register) : %0h  (esperado: 1A2B3C)", img_row00);
        if (img_row00 === 30'h1A2B3C) begin
            $display("  TEST 1 PASS: fila 0 OK");
            pass_count = pass_count + 1;
        end else begin
            $display("  TEST 1 FAIL: img_row00=%0h", img_row00);
            fail_count = fail_count + 1;
        end
        $display("  img_row01 (Register) : %0h  (esperado: 2B3C4D)", img_row01);
        if (img_row01 === 30'h2B3C4D) begin
            $display("  TEST 1b PASS: fila 1 OK");
            pass_count = pass_count + 1;
        end else begin
            $display("  TEST 1b FAIL: img_row01=%0h", img_row01);
            fail_count = fail_count + 1;
        end
        // ── TEST 2: LOAD WEIGHTS ───────────────────────
        $display("\n--- TEST 2: LOAD WEIGHTS ---");
        spi_load_weights_all(15'h5A5, 15'h111, 15'h222, 15'h333, 15'h444);
        $display("  wgt_row00 (Register) : %0h  (esperado: 5A5)", wgt_row00);
        if (wgt_row00 === 15'h5A5) begin
            $display("  TEST 2 PASS: peso 0 OK");
            pass_count = pass_count + 1;
        end else begin
            $display("  TEST 2 FAIL: wgt_row00=%0h", wgt_row00);
            fail_count = fail_count + 1;
        end
        // ── TEST 3: START CNN ──────────────────────────
        $display("\n--- TEST 3: START CNN ---");
        spi_start_cnn();
        #(CLK_HALF*2);
        if (start_cnn === 1'b1) begin
            $display("  TEST 3 PASS: start_cnn pulsó");
            pass_count = pass_count + 1;
        end else begin
            $display("  TEST 3 FAIL: start_cnn=%0b", start_cnn);
            fail_count = fail_count + 1;
        end
        // ── TEST 4: READ MR1 (cmd 101) ─────────────────
        $display("\n--- TEST 4: READ MR1 ---");
        // Master_register captura en posedge de i_SPI_Clk.
        // Hay que pulsar mr1_load mientras damos un pulso de SPI_Clk.
        mr1_load = 0;
        spi_clk_pulse();   // posedge SPI_Clk con mr1_load=0 → Master_register captura
        mr1_load = 1;
        #(CLK_HALF*2);
        begin : test4
            reg [15:0] rx;
            spi_read_16(3'b101, rx);
            $display("  MR1 leído por MISO: %0h  (esperado: ABCD)", rx);
            if (rx === 16'hABCD) begin
                $display("  TEST 4 PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  TEST 4 FAIL");
                fail_count = fail_count + 1;
            end
        end
        // ── TEST 5: READ MR2 (cmd 110) ─────────────────
        $display("\n--- TEST 5: READ MR2 ---");
        mr2_load = 0;
        spi_clk_pulse();
        mr2_load = 1;
        #(CLK_HALF*2);
        begin : test5
            reg [15:0] rx;
            spi_read_16(3'b110, rx);
            $display("  MR2 leído por MISO: %0h  (esperado: 1234)", rx);
            if (rx === 16'h1234) begin
                $display("  TEST 5 PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  TEST 5 FAIL");
                fail_count = fail_count + 1;
            end
        end
        // ── TEST 6: READ RESULT (cmd 100) ──────────────
        $display("\n--- TEST 6: READ RESULT ---");
        begin : test6
            reg rx_bit;
            spi_read_1bit(rx_bit);
            $display("  comp_result leído: %0b  (esperado: 1)", rx_bit);
            if (rx_bit === 1'b1) begin
                $display("  TEST 6 PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  TEST 6 FAIL: got %0b", rx_bit);
                fail_count = fail_count + 1;
            end
        end
        // ── RESUMEN ────────────────────────────────────
        $display("\n=========================================");
        $display(" RESULTADOS: %0d PASS / %0d FAIL", pass_count, fail_count);
        $display("=========================================\n");
        $finish;
    end
    // ─────────────────────────────────────────────────
    // Task: un pulso de SPI_Clk (posedge)
    // ─────────────────────────────────────────────────
    task spi_clk_pulse;
        begin
            #CLK_HALF; clk_spi = 1;
            #CLK_HALF; clk_spi = 0;
        end
    endtask
    // ─────────────────────────────────────────────────
    // Task: enviar N bits MSB primero por MOSI
    // ─────────────────────────────────────────────────
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
    // ─────────────────────────────────────────────────
    // Task: LOAD IMAGE ROW — CMD 001 + 30 bits
    // Incluye 1 clock extra antes de subir CS
    // ─────────────────────────────────────────────────
    // ─────────────────────────────────────────────────
    // Task: LOAD IMAGE — CMD 001 + 10 filas x 30 bits
    // UNA SOLA TRANSACCION SPI (CS bajo durante toda la imagen)
    // El contador 'row' dentro del slave se incrementa con cada fila
    // y NO se resetea hasta que CS suba al final.
    // ─────────────────────────────────────────────────
    task spi_load_image_all;
        input [29:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9;
        integer f;
        reg [29:0] rows [0:9];
        begin
            rows[0]=r0; rows[1]=r1; rows[2]=r2; rows[3]=r3; rows[4]=r4;
            rows[5]=r5; rows[6]=r6; rows[7]=r7; rows[8]=r8; rows[9]=r9;
            $display("  [SPI] LOAD IMAGE — 10 filas en una transaccion");
            cs_n = 0; mosi = 0; #1;
            // CMD = 001
            spi_send_bits(3, 3'b001);
            // Filas 0-8: sin clock extra — el primer bit de la fila N+1
            // actúa como T34 para la fila N (captura Register_Imag)
            for (f = 0; f < 9; f = f + 1) begin
                spi_send_bits(30, {2'b0, rows[f]});
            end
            // Fila 9: sí necesita clock extra (no hay fila 10)
            spi_send_bits(30, {2'b0, rows[9]});
            mosi = 0; spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*4);
        end
    endtask

    // Mantener la version por fila para compatibilidad (ya no se usa en tests)
    task spi_load_image_row;
        input [29:0] row_data;
        input [3:0]  row_idx;
        integer k;
        begin
            $display("  [SPI] LOAD IMAGE fila %0d = %0h", row_idx, row_data);
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b001);
            spi_send_bits(30, {2'b0, row_data});
            $display("    image_mem[%0d]=%0h (post-ultimo-bit)", row_idx, dut.spi_u0.image_mem[row_idx]);
            mosi = 0;
            spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*4);
        end
    endtask
    // ─────────────────────────────────────────────────
    // Task: LOAD WEIGHTS — CMD 010 + 5 filas x 15 bits
    // UNA SOLA TRANSACCION SPI
    // ─────────────────────────────────────────────────
    task spi_load_weights_all;
        input [14:0] w0, w1, w2, w3, w4;
        integer f;
        reg [14:0] wts [0:4];
        begin
            wts[0]=w0; wts[1]=w1; wts[2]=w2; wts[3]=w3; wts[4]=w4;
            $display("  [SPI] LOAD WEIGHTS — 5 filas en una transaccion");
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b010);
            // Pesos 0-3: sin clock extra
            for (f = 0; f < 4; f = f + 1) begin
                spi_send_bits(15, {17'b0, wts[f]});
            end
            // Peso 4: clock extra al final
            spi_send_bits(15, {17'b0, wts[4]});
            mosi = 0; spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*4);
        end
    endtask

    task spi_load_weight_row;
        input [14:0] wdata;
        input [2:0]  widx;
        begin
            $display("  [SPI] LOAD WEIGHT fila %0d = %0h", widx, wdata);
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b010);
            spi_send_bits(15, {17'b0, wdata});
            mosi = 0; spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask
    // ─────────────────────────────────────────────────
    // Task: START CNN — CMD 011 (sin payload)
    // ─────────────────────────────────────────────────
    task spi_start_cnn;
        begin
            $display("  [SPI] START CNN");
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b011);
            // 1 clock extra para que el pulso se genere
            mosi = 0; spi_clk_pulse();
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask
    // ─────────────────────────────────────────────────
    // Task: READ 16 bits por MISO
    // MISO se muestrea ANTES del posedge: en ese momento miso_count
    // ya tiene el valor correcto para ese bit (estable desde el posedge anterior).
    // Secuencia por bit: leer MISO → posedge (miso_count++) → negedge
    // ─────────────────────────────────────────────────
    task spi_read_16;
        input  [2:0]  cmd_bits;
        output [15:0] rx_data;
        integer k;
        begin
            rx_data = 0;
            $display("  [SPI] READ cmd=%0b (16 bits MISO)", cmd_bits);
            cs_n = 0; mosi = 0; #1;
            // 3 bits CMD — termina con clk=0, miso_count=0, MISO=bit[15]
            spi_send_bits(3, {29'b0, cmd_bits});
            $display("    miso_active=%0b (esperado 1)", w_miso_active);
            // 16 bits: leer MISO antes del posedge (miso_count estable)
            // luego dar el pulso de clock para avanzar miso_count
            for (k = 15; k >= 0; k = k - 1) begin
                rx_data[k] = miso;               // leer primero (miso_count=15-k)
                $display("    bit[%0d] MISO=%0b", k, miso);
                #CLK_HALF; clk_spi = 1;          // posedge → miso_count++
                #CLK_HALF; clk_spi = 0;          // negedge
            end
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask
    // ─────────────────────────────────────────────────
    // Task: READ 1 bit por MISO (READ RESULT, cmd 100)
    // ─────────────────────────────────────────────────
    task spi_read_1bit;
        output rx_bit;
        begin
            $display("  [SPI] READ RESULT (1 bit MISO)");
            cs_n = 0; mosi = 0; #1;
            spi_send_bits(3, 3'b100);
            $display("    miso_active=%0b (esperado 1)", w_miso_active);
            // 1 clock de lectura
            #CLK_HALF; clk_spi = 1;
            #1; rx_bit = miso;
            $display("    MISO=%0b (esperado 1)", miso);
            #(CLK_HALF-1); clk_spi = 0;
            cs_n = 1; #(CLK_HALF*2);
        end
    endtask
    // ── Monitor de carga de imagen ─────────────────────
    always @(negedge w_load00) $display("  [MON] load00 ACTIVO @ %0t", $time);
    always @(posedge w_load00) $display("  [MON] load00 inactivo @ %0t", $time);
    // ── Timeout ───────────────────────────────────────
    initial begin
        #500000;
        $display("TIMEOUT");
        $finish;
    end
endmodule
