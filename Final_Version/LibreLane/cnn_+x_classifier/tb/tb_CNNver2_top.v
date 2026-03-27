//=======================================================
//  tb_CNNver2_top — Testbench de integración HW
//=======================================================
//  Entradas controladas, golden outputs analíticos.
//
//  Aritmética:
//    MAC    = sum(25 × pixel_i × peso_i)  signed 3-bit
//    Maxpool = max de 4 ventanas 5x5 por fragmento 6x6
//    acc    = suma de 9 maxpools
//
//  Golden outputs:
//    img=1s + ker=1s   → acc = 9 × max(25×1×1)    = 9×25  = 225 (0x00E1)
//    img=1s + ker=ctr  → acc = 9 × max(1×1)       = 9×1   =   9 (0x0009)
//    img=2s + ker=1s   → acc = 9 × max(25×2×1)    = 9×50  = 450 (0x01C2)
//
//  Tests:
//    T01 — comp=1: ker0=1s→acc0=225, ker1=ctr→acc1=9
//    T02 — comp=0: ker0=ctr→acc0=9,  ker1=1s→acc1=225
//    T03 — comp=0: ker0=ker1=1s, img=2s → acc0=acc1=450 (igual no es >)
//    T04 — Reset durante procesamiento y recuperación
//    T05 — Dos clasificaciones consecutivas sin reset
//=======================================================
`timescale 1ns/1ps

module tb_CNNver2_top;

    wire        MISO;
    reg         SPI_CLK;
    reg         SS_N;
    reg         MOSI;
    reg         RESET;
    reg         CMD_RESET;
    wire        MR1_Load;
    wire        MR2_Load;

    CNNver2 dut (
        .CNNver2_MISO         (MISO),
        .CNNver2_SPICLOCK_50  (SPI_CLK),
        .CNNver2_SS_N         (SS_N),
        .CNNver2_MOSI         (MOSI),
        .CNNver2_Reset_InHigh (RESET),
        .CNNver2_CMD_Reset    (CMD_RESET),
        .CNNver2_MR1_Load     (MR1_Load),
        .CNNver2_MR2_Load     (MR2_Load)
    );

    parameter CLK_HALF = 10;

    integer pass_count, fail_count;

    wire [15:0] w_acc0 = dut.acc0;
    wire [15:0] w_acc1 = dut.acc1;
    wire        w_done = dut.proc_u0.o_done;

    // ── Codificación de filas ──────────────────────────
    // pixel valor 1 = 3'b001, valor 2 = 3'b010
    // fila = {pix9,pix8,...,pix0}  → pix0 en bits[2:0]
    localparam [29:0] ROW_ONES  = 30'h09249249; // 10 píxeles = 1
    localparam [29:0] ROW_TWOS  = 30'h12492492; // 10 píxeles = 2
    localparam [29:0] ROW_ZEROS = 30'h00000000;

    // Kernel todo 1s: 5 pesos = 1 → 15'h1249
    localparam [14:0] KW_ONES = 15'h1249;
    // Kernel centro: sólo peso[2][2]=1
    //   fila 2 = 000_000_001_000_000 → bit[8:6]=001 → 15'h0040
    localparam [14:0] KW_CTR  = 15'h0040;
    localparam [14:0] KW_ZERO = 15'h0000;

    // ── check task ────────────────────────────────────
    task check;
        input [255:0] name;
        input [31:0]  got;
        input [31:0]  expected;
        begin
            if (got === expected) begin
                $display("    PASS  %0s = 0x%0h", name, got);
                pass_count = pass_count + 1;
            end else begin
                $display("    FAIL  %0s : got=0x%0h  expected=0x%0h", name, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        SPI_CLK=0; SS_N=1; MOSI=0; RESET=1; CMD_RESET=0;
        pass_count=0; fail_count=0;
        repeat(6) spi_clk_pulse();
        RESET=0; #(CLK_HALF*4);

        $display("=========================================");
        $display(" tb_CNNver2_top — Integracion HW");
        $display("=========================================");
        $display(" Goldens: acc(1s,1s)=225  acc(1s,ctr)=9  acc(2s,1s)=450");

        // ── T01: comp=1, acc0=225 > acc1=9 ────────────
        $display("\n--- T01: ker0=1s acc0=225, ker1=ctr acc1=9, comp=1 ---");
        run_two_kernels(
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES,
            KW_ZERO,KW_ZERO,KW_CTR, KW_ZERO,KW_ZERO
        );
        begin : t01
            reg [15:0] mr1,mr2; reg comp;
            spi_read_16(3'b101,mr1);
            spi_read_16(3'b110,mr2);
            spi_read_1bit(3'b100,comp);
            $display("  acc0=%0d acc1=%0d comp=%0b",$signed(mr1),$signed(mr2),comp);
            check("T01 acc0",mr1,16'h00E1);
            check("T01 acc1",mr2,16'h0009);
            check("T01 comp",comp,1'b1);
        end

        // ── T02: comp=0, acc0=9 < acc1=225 ────────────
        $display("\n--- T02: ker0=ctr acc0=9, ker1=1s acc1=225, comp=0 ---");
        run_two_kernels(
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            KW_ZERO,KW_ZERO,KW_CTR, KW_ZERO,KW_ZERO,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES
        );
        begin : t02
            reg [15:0] mr1,mr2; reg comp;
            spi_read_16(3'b101,mr1);
            spi_read_16(3'b110,mr2);
            spi_read_1bit(3'b100,comp);
            $display("  acc0=%0d acc1=%0d comp=%0b",$signed(mr1),$signed(mr2),comp);
            check("T02 acc0",mr1,16'h0009);
            check("T02 acc1",mr2,16'h00E1);
            check("T02 comp",comp,1'b0);
        end

        // ── T03: acc0==acc1=450, comp=0 ───────────────
        $display("\n--- T03: img=2s, ker0=ker1=1s, acc0=acc1=450, comp=0 ---");
        run_two_kernels(
            ROW_TWOS,ROW_TWOS,ROW_TWOS,ROW_TWOS,ROW_TWOS,
            ROW_TWOS,ROW_TWOS,ROW_TWOS,ROW_TWOS,ROW_TWOS,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES
        );
        begin : t03
            reg [15:0] mr1,mr2; reg comp;
            spi_read_16(3'b101,mr1);
            spi_read_16(3'b110,mr2);
            spi_read_1bit(3'b100,comp);
            $display("  acc0=%0d acc1=%0d comp=%0b",$signed(mr1),$signed(mr2),comp);
            check("T03 acc0",mr1,16'h01C2);
            check("T03 acc1",mr2,16'h01C2);
            check("T03 comp",comp,1'b0);
        end

        // ── T04: reset durante procesamiento ──────────
        $display("\n--- T04: Reset durante procesamiento, recuperacion ---");
        spi_load_image(ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
                       ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES);
        spi_load_weights(KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES);
        spi_start_cnn();
        #(CLK_HALF*20);
        RESET=1; repeat(6) spi_clk_pulse(); RESET=0; #(CLK_HALF*4);
        $display("  Reset aplicado, repitiendo T01...");
        run_two_kernels(
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES,
            KW_ZERO,KW_ZERO,KW_CTR, KW_ZERO,KW_ZERO
        );
        begin : t04
            reg [15:0] mr1,mr2; reg comp;
            spi_read_16(3'b101,mr1);
            spi_read_16(3'b110,mr2);
            spi_read_1bit(3'b100,comp);
            $display("  acc0=%0d acc1=%0d comp=%0b",$signed(mr1),$signed(mr2),comp);
            check("T04 acc0",mr1,16'h00E1);
            check("T04 acc1",mr2,16'h0009);
            check("T04 comp",comp,1'b1);
        end

        // ── T05: dos clasificaciones consecutivas ──────
        $display("\n--- T05: Dos clasificaciones consecutivas sin reset ---");
        run_two_kernels(
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES,
            KW_ZERO,KW_ZERO,KW_CTR, KW_ZERO,KW_ZERO
        );
        begin : t05a
            reg comp;
            spi_read_1bit(3'b100,comp);
            $display("  [1ra] comp=%0b",comp);
            check("T05a comp=1",comp,1'b1);
        end
        run_two_kernels(
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,ROW_ONES,
            KW_ZERO,KW_ZERO,KW_CTR, KW_ZERO,KW_ZERO,
            KW_ONES,KW_ONES,KW_ONES,KW_ONES,KW_ONES
        );
        begin : t05b
            reg comp;
            spi_read_1bit(3'b100,comp);
            $display("  [2da] comp=%0b",comp);
            check("T05b comp=0",comp,1'b0);
        end

        // ── Resumen ───────────────────────────────────
        $display("\n=========================================");
        $display(" RESULTADOS: %0d PASS / %0d FAIL",pass_count,fail_count);
        if (fail_count==0) $display(" *** TODOS LOS TESTS PASARON ***");
        $display("=========================================\n");
        $finish;
    end

    // ── run_two_kernels ───────────────────────────────
    task run_two_kernels;
        input [29:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
        input [14:0] k0w0,k0w1,k0w2,k0w3,k0w4;
        input [14:0] k1w0,k1w1,k1w2,k1w3,k1w4;
        begin
            spi_load_image(r0,r1,r2,r3,r4,r5,r6,r7,r8,r9);
            spi_load_weights(k0w0,k0w1,k0w2,k0w3,k0w4);
            spi_start_cnn();
            wait_done();
            spi_load_weights(k1w0,k1w1,k1w2,k1w3,k1w4);
            spi_start_cnn();
            wait_done();
        end
    endtask

    // ── wait_done ─────────────────────────────────────
    task wait_done;
        integer timeout;
        begin
            timeout=0;
            while (!w_done && timeout<10000) begin
                spi_clk_pulse(); timeout=timeout+1;
            end
            if (timeout>=10000) $display("    TIMEOUT!");
            else repeat(4) spi_clk_pulse();
        end
    endtask

    // ── SPI tasks ─────────────────────────────────────
    task spi_clk_pulse;
        begin #CLK_HALF; SPI_CLK=1; #CLK_HALF; SPI_CLK=0; end
    endtask

    task spi_send_bits;
        input integer n; input [31:0] data; integer k;
        begin
            for (k=n-1; k>=0; k=k-1) begin MOSI=data[k]; spi_clk_pulse(); end
        end
    endtask

    task spi_load_image;
        input [29:0] r0,r1,r2,r3,r4,r5,r6,r7,r8,r9;
        integer f; reg [29:0] rows[0:9];
        begin
            rows[0]=r0;rows[1]=r1;rows[2]=r2;rows[3]=r3;rows[4]=r4;
            rows[5]=r5;rows[6]=r6;rows[7]=r7;rows[8]=r8;rows[9]=r9;
            SS_N=0; MOSI=0; #1;
            spi_send_bits(3,3'b001);
            for (f=0;f<9;f=f+1) spi_send_bits(30,{2'b0,rows[f]});
            spi_send_bits(30,{2'b0,rows[9]});
            MOSI=0; spi_clk_pulse();
            SS_N=1; #(CLK_HALF*4);
        end
    endtask

    task spi_load_weights;
        input [14:0] w0,w1,w2,w3,w4;
        integer f; reg [14:0] wts[0:4];
        begin
            wts[0]=w0;wts[1]=w1;wts[2]=w2;wts[3]=w3;wts[4]=w4;
            SS_N=0; MOSI=0; #1;
            spi_send_bits(3,3'b010);
            for (f=0;f<4;f=f+1) spi_send_bits(15,{17'b0,wts[f]});
            spi_send_bits(15,{17'b0,wts[4]});
            MOSI=0; spi_clk_pulse();
            SS_N=1; #(CLK_HALF*4);
        end
    endtask

    task spi_start_cnn;
        begin SS_N=0; MOSI=0; #1; spi_send_bits(3,3'b011);
              MOSI=0; spi_clk_pulse(); SS_N=1; #(CLK_HALF*2); end
    endtask

    task spi_read_16;
        input [2:0] cmd_bits; output [15:0] rx_data; integer k;
        begin
            rx_data=0; SS_N=0; MOSI=0; #1;
            spi_send_bits(3,{29'b0,cmd_bits});
            for (k=15;k>=0;k=k-1) begin
                rx_data[k]=MISO; #CLK_HALF; SPI_CLK=1; #CLK_HALF; SPI_CLK=0;
            end
            SS_N=1; #(CLK_HALF*2);
        end
    endtask

    task spi_read_1bit;
        input [2:0] cmd_bits; output rx_bit;
        begin
            SS_N=0; MOSI=0; #1; spi_send_bits(3,cmd_bits);
            rx_bit=MISO; #CLK_HALF; SPI_CLK=1; #CLK_HALF; SPI_CLK=0;
            SS_N=1; #(CLK_HALF*2);
        end
    endtask

    initial begin #100_000_000; $display("TIMEOUT GLOBAL"); $finish; end

endmodule
