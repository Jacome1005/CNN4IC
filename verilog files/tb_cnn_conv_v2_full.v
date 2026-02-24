`timescale 1ns/1ps

module tb_cnn_conv_v2_full;

    // =========================================================
    // DUT signals
    // =========================================================
    reg         clk;
    reg         rst;
    reg  [74:0]        px_flat_in;
    reg  signed [74:0] w_flat_in;
    reg  signed [10:0] additional_in_0;
    reg  signed [10:0] additional_in_1;
    reg  signed [10:0] additional_in_2;
    reg  signed [10:0] additional_in_3;

    wire signed [10:0] y_out;
    wire               ready;
    wire signed [14:0] additional_out;

    // =========================================================
    // DUT instantiation
    // =========================================================
    cnn_conv_v2 dut (
        .clk            (clk),
        .rst            (rst),
        .px_flat_in     (px_flat_in),
        .w_flat_in      (w_flat_in),
        .additional_in_0(additional_in_0),
        .additional_in_1(additional_in_1),
        .additional_in_2(additional_in_2),
        .additional_in_3(additional_in_3),
        .y_out          (y_out),
        .ready          (ready),
        .additional_out (additional_out)
    );

    // =========================================================
    // Clock 50 MHz -> periodo 20 ns
    // =========================================================
    initial clk = 0;
    always #10 clk = ~clk;

    // =========================================================
    // Task: cargar pixeles y pesos uniformes
    // =========================================================
    task set_pixels_weights;
        input [2:0]        px_val;
        input signed [2:0] w_val;
        integer k;
        begin
            for (k = 0; k < 25; k = k + 1) begin
                px_flat_in[k*3 +: 3] = px_val;
                w_flat_in [k*3 +: 3] = w_val;
            end
        end
    endtask

    // =========================================================
    // Task: aplicar entradas y esperar 2 ciclos de pipeline
    // Ciclo 1: registros de entrada capturan px, w y additional
    // Ciclo 2: registros de salida capturan suma y additional_out
    // =========================================================
    task apply_and_wait;
        input [2:0]        px_val;
        input signed [2:0] w_val;
        input signed [10:0] a0, a1, a2, a3;
        begin
            @(negedge clk);
            set_pixels_weights(px_val, w_val);
            additional_in_0 = a0;
            additional_in_1 = a1;
            additional_in_2 = a2;
            additional_in_3 = a3;
            @(posedge clk); #1;
            @(posedge clk); #1;
        end
    endtask

    // =========================================================
    // Contadores de resultado
    // =========================================================
    integer pass_count;
    integer fail_count;

    task check_y;
        input integer test_id;
        input integer exp_y;
        begin
            $display("---------------------------------------------");
            $display("TEST %0d  y_out=%0d (expected:%0d)  ready=%b",
                     test_id, $signed(y_out), exp_y, ready);
            if ($signed(y_out) === exp_y && ready === 1'b1) begin
                $display("  CNN PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  CNN FAIL (got y=%0d ready=%b)", $signed(y_out), ready);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_add;
        input integer exp_add;
        begin
            $display("  additional_out=%0d (expected:%0d)",
                     $signed(additional_out), exp_add);
            if ($signed(additional_out) === exp_add) begin
                $display("  ADDITIONAL PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("  ADDITIONAL FAIL (got %0d)", $signed(additional_out));
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================
    // Estimulos
    // =========================================================
    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("=================================================");
        $display("  TB cnn_conv_v2 + additional registers");
        $display("=================================================");
        $display("  NOTA: px es unsigned 3-bit en el puerto pero");
        $display("  se interpreta signed en la multiplicacion.");
        $display("  Rango signed 3-bit: -4 a +3");
        $display("  3b111=-1  3b110=-2  3b101=-3  3b100=-4");
        $display("  3b000=0   3b001=1   3b010=2   3b011=3");
        $display("=================================================");

        // ── Reset inicial ─────────────────────────────────────
        rst             = 1;
        px_flat_in      = 75'd0;
        w_flat_in       = 75'd0;
        additional_in_0 = 11'sd0;
        additional_in_1 = 11'sd0;
        additional_in_2 = 11'sd0;
        additional_in_3 = 11'sd0;
        repeat(4) @(posedge clk);
        rst = 0;
        @(posedge clk); #1;

        // =========================================================
        // TEST 1: todo ceros
        // px=0, w=0 -> prod=0, CNN=0
        // ADD: 0+0+0+0=0
        // =========================================================
        apply_and_wait(3'd0, 3'sd0, 11'sd0, 11'sd0, 11'sd0, 11'sd0);
        check_y(1, 0);
        check_add(0);

        // =========================================================
        // TEST 2: positivos simples
        // px=1 (3b001=+1), w=1 (3sb001=+1) -> prod=1, CNN=25*1=25
        // ADD: 1+2+3+4=10
        // =========================================================
        apply_and_wait(3'b001, 3'sb001, 11'sd1, 11'sd2, 11'sd3, 11'sd4);
        check_y(2, 25);
        check_add(10);

        // =========================================================
        // TEST 3: positivos mayores
        // px=3 (3b011=+3), w=2 (3sb010=+2) -> prod=6, CNN=25*6=150
        // ADD: 10+20+30+40=100
        // =========================================================
        apply_and_wait(3'b011, 3'sb010, 11'sd10, 11'sd20, 11'sd30, 11'sd40);
        check_y(3, 150);
        check_add(100);

        // =========================================================
        // TEST 4: peso negativo
        // px=1 (3b001=+1), w=-1 (3sb111=-1) -> prod=-1, CNN=25*(-1)=-25
        // ADD: -100+(-50)+75+25=-50
        // =========================================================
        apply_and_wait(3'b001, 3'sb111, -11'sd100, -11'sd50, 11'sd75, 11'sd25);
        check_y(4, -25);
        check_add(-50);

        // =========================================================
        // TEST 5: maximos positivos validos en signed 3-bit
        // px=3 (3b011=+3 max positivo), w=3 (3sb011=+3 max positivo)
        // prod=9, CNN=25*9=225
        // ADD: 50+50+50+50=200
        // =========================================================
        apply_and_wait(3'b011, 3'sb011, 11'sd50, 11'sd50, 11'sd50, 11'sd50);
        check_y(5, 225);
        check_add(200);

        // =========================================================
        // TEST 6: px negativo, w negativo -> resultado positivo
        // px=3b111=-1, w=3sb111=-1 -> prod=(-1)*(-1)=1, CNN=25*1=25
        // ADD: -10+(-10)+(-10)+(-10)=-40
        // =========================================================
        apply_and_wait(3'b111, 3'sb111, -11'sd10, -11'sd10, -11'sd10, -11'sd10);
        check_y(6, 25);
        check_add(-40);

        // =========================================================
        // TEST 7: maximo negativo en px
        // px=3b100=-4 (min signed 3-bit), w=3sb011=+3
        // prod=(-4)*3=-12, CNN=25*(-12)=-300
        // ADD: 100+100+100+100=400
        // =========================================================
        apply_and_wait(3'b100, 3'sb011, 11'sd100, 11'sd100, 11'sd100, 11'sd100);
        check_y(7, -300);
        check_add(400);

        // =========================================================
        // TEST 8: maximo negativo absoluto
        // px=3b100=-4, w=3sb100=-4 -> prod=(-4)*(-4)=16, CNN=25*16=400
        // ADD: -200+(-200)+200+200=0
        // =========================================================
        apply_and_wait(3'b100, 3'sb100, -11'sd200, -11'sd200, 11'sd200, 11'sd200);
        check_y(8, 400);
        check_add(0);

        // =========================================================
        // TEST 9: patron alternado
        // px pares=0, impares=1 (3b001=+1), w=1
        // posiciones impares: 1,3,5,...,23 -> 12 pixeles activos
        // CNN=12*1*1=12
        // ADD: 5+5+5+5=20
        // =========================================================
        @(negedge clk);
        begin : ALTERNADO
            integer k;
            for (k = 0; k < 25; k = k + 1) begin
                px_flat_in[k*3 +: 3] = (k % 2 == 0) ? 3'b000 : 3'b001;
                w_flat_in [k*3 +: 3] = 3'sb001;
            end
        end
        additional_in_0 = 11'sd5;
        additional_in_1 = 11'sd5;
        additional_in_2 = 11'sd5;
        additional_in_3 = 11'sd5;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_y(9, 12);
        check_add(20);

        // =========================================================
        // TEST 10: reset en medio de operacion
        // Cargar datos validos, aplicar reset, verificar que
        // y_out y additional_out queden en 0
        // =========================================================
        $display("---------------------------------------------");
        $display("TEST 10 - Reset mid-operation");

        @(negedge clk);
        set_pixels_weights(3'b011, 3'sb011);
        additional_in_0 = 11'sd500;
        additional_in_1 = 11'sd500;
        additional_in_2 = 11'sd500;
        additional_in_3 = 11'sd500;
        @(posedge clk); #1;

        // Aplicar reset con entradas en cero
        @(negedge clk);
        rst             = 1;
        px_flat_in      = 75'd0;
        w_flat_in       = 75'd0;
        additional_in_0 = 11'sd0;
        additional_in_1 = 11'sd0;
        additional_in_2 = 11'sd0;
        additional_in_3 = 11'sd0;
        repeat(3) @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;

        $display("  y_out=%0d (expected:0)  additional_out=%0d (expected:0)",
                 $signed(y_out), $signed(additional_out));
        if ($signed(y_out) === 0 && $signed(additional_out) === 0) begin
            $display("  RESET PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("  RESET FAIL (y=%0d add=%0d)", $signed(y_out), $signed(additional_out));
            fail_count = fail_count + 1;
        end

        // =========================================================
        // TEST 11: pipeline - ciclos consecutivos sin mezcla de datos
        // Ciclo A: px=2 w=2 -> prod=4, CNN=25*4=100, ADD=4*4=16
        // Ciclo B: px=1 w=1 -> prod=1, CNN=25*1=25,  ADD=4*1=4
        // =========================================================
        $display("---------------------------------------------");
        $display("TEST 11 - Pipeline: ciclos consecutivos");

        @(negedge clk);
        set_pixels_weights(3'b010, 3'sb010);
        additional_in_0 = 11'sd4;
        additional_in_1 = 11'sd4;
        additional_in_2 = 11'sd4;
        additional_in_3 = 11'sd4;
        @(posedge clk); #1;

        @(negedge clk);
        set_pixels_weights(3'b001, 3'sb001);
        additional_in_0 = 11'sd1;
        additional_in_1 = 11'sd1;
        additional_in_2 = 11'sd1;
        additional_in_3 = 11'sd1;
        @(posedge clk); #1;

        $display("  Ciclo A -> y_out=%0d (expected:100)  additional_out=%0d (expected:16)",
                 $signed(y_out), $signed(additional_out));
        if ($signed(y_out) === 100 && $signed(additional_out) === 16) begin
            $display("  PIPELINE A PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("  PIPELINE A FAIL (y=%0d add=%0d)", $signed(y_out), $signed(additional_out));
            fail_count = fail_count + 1;
        end

        @(posedge clk); #1;

        $display("  Ciclo B -> y_out=%0d (expected:25)  additional_out=%0d (expected:4)",
                 $signed(y_out), $signed(additional_out));
        if ($signed(y_out) === 25 && $signed(additional_out) === 4) begin
            $display("  PIPELINE B PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("  PIPELINE B FAIL (y=%0d add=%0d)", $signed(y_out), $signed(additional_out));
            fail_count = fail_count + 1;
        end

        // =========================================================
        // Resumen
        // =========================================================
        $display("=================================================");
        $display("  RESULTS: %0d PASS  |  %0d FAIL", pass_count, fail_count);
        if (fail_count === 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED - review waveforms");
        $display("=================================================");
        $finish;
    end

    // =========================================================
    // Dump de ondas
    // =========================================================
    initial begin
        $dumpfile("tb_cnn_conv_v2_full.vcd");
        $dumpvars(0, tb_cnn_conv_v2_full);
    end

endmodule