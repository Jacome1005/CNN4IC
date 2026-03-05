//=======================================================
//  spi_cnn_slave_8 — version final
//=======================================================
//  Protocolo MOSI (3 bits de comando al inicio):
//    3'b000 = LOAD IMAGE   : 10 filas x 30 bits
//    3'b001 = LOAD WEIGHTS : 5 filas  x 15 bits
//    3'b010 = START CNN    : sin payload, pulso o_start_cnn
//    3'b011 = READ RESULT  : 16 clocks → MISO (16 bits CNN)
//    3'b100 = LOAD MAXPOOL : 16 bits por vector x 4 vectores
//    3'b101 = SAVE ACCUM   : sin payload, pulso o_save_accum
//    3'b110 = READ COMPARE : 1 clock → MISO (1 bit comparador)
//
//  Fixes de timing aplicados (ver notas en bloques):
//    FIX-1: o_start_cnn, o_save_accum, o_mp_load en bloques
//           separados con solo i_RESET (no internal_reset)
//           → sobreviven hasta el posedge donde la FSM los lee
//    FIX-2: SM loaders usan i_RESET (no internal_reset)
//           → ultimo registro siempre se carga correctamente
//
//  Puertos removidos respecto a version anterior:
//    - o_result_pos (antes pin externo, ahora no necesario)
//=======================================================

module spi_cnn_slave_8 #(
    parameter DATAWIDTH_BUS        = 8,
    parameter DATAWIDTH_BUS_IMAGE  = 10,
    parameter DATAWIDTH_BUS_WEIGHT = 5,
    parameter BITS_PER_POS         = 3,
    parameter DATAWIDTH_IMG_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS,  // 30
    parameter DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS   // 15
)(
    input  wire i_SPI_Clk,
    input  wire i_SPI_CS_n,
    input  wire i_SPI_MOSI,
    output wire o_SPI_MISO,

    input  wire i_RESET,      // Reset global — SM loaders y pulsos de salida
    input  wire i_cmd_reset,  // Aborta comando en curso (no afecta pulsos)

    // Pulsos de 1 ciclo (bloques separados, no borrados por CS)
    output reg  o_start_cnn,
    output reg  o_save_accum,  // ★ NUEVO: dispara SAVE_ACCUM en FSM

    // Imagen: 30 bits por fila, 10 filas
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row00, o_row01, o_row02, o_row03, o_row04,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row05, o_row06, o_row07, o_row08, o_row09,
    output wire o_load00, o_load01, o_load02, o_load03, o_load04,
    output wire o_load05, o_load06, o_load07, o_load08, o_load09,

    // Pesos: 15 bits por fila, 5 filas
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow00, o_wrow01, o_wrow02, o_wrow03, o_wrow04,
    output wire o_wload00, o_wload01, o_wload02, o_wload03, o_wload04,

    // Resultado 16 bits desde main Master_register (cmd 011 READ RESULT)
    input  wire [15:0] i_cnn_result,

    // ★ Resultado 1 bit del comparador (cmd 110 READ COMPARE)
    input  wire        i_comp_result,

    // MaxPool: datos hacia maxpool_shift (bloque separado)
    output reg  [10:0] o_mp_data,
    output reg         o_mp_load
);

    // ── Memorias internas ──────────────────────────────────────────────
    reg [DATAWIDTH_IMG_FULL-1:0] image_mem  [0:DATAWIDTH_BUS_IMAGE-1];
    reg [DATAWIDTH_WGT_FULL-1:0] weight_mem [0:DATAWIDTH_BUS_WEIGHT-1];

    assign o_row00 = image_mem[0]; assign o_row01 = image_mem[1];
    assign o_row02 = image_mem[2]; assign o_row03 = image_mem[3];
    assign o_row04 = image_mem[4]; assign o_row05 = image_mem[5];
    assign o_row06 = image_mem[6]; assign o_row07 = image_mem[7];
    assign o_row08 = image_mem[8]; assign o_row09 = image_mem[9];

    assign o_wrow00 = weight_mem[0]; assign o_wrow01 = weight_mem[1];
    assign o_wrow02 = weight_mem[2]; assign o_wrow03 = weight_mem[3];
    assign o_wrow04 = weight_mem[4];

    // ── Registros de control ──────────────────────────────────────────
    reg [2:0] cmd;
    reg [8:0] bit_count;
    reg [6:0] data_count;
    reg [3:0] row;
    reg [2:0] weight_count;
    reg [DATAWIDTH_IMG_FULL-1:0]  image_shift;
    reg [DATAWIDTH_WGT_FULL-1:0]  weight_shift;
    reg [4:0]  miso_count;
    reg        miso_active;
    reg [15:0] mp_shift;
    reg        valid_clk;

    // internal_reset: SOLO para contadores/shifts internos del SPI.
    // NO para o_start_cnn, o_save_accum, o_mp_load ni SM loaders.
    wire internal_reset = i_SPI_CS_n | i_cmd_reset;

    localparam IMG_LAST_BIT = DATAWIDTH_IMG_FULL - 1;  // 29
    localparam WGT_LAST_BIT = DATAWIDTH_WGT_FULL - 1;  // 14

    // ── SM imagen: reset GLOBAL (FIX-2) ──────────────────────────────
    SC_STATEMACHINE_IMAGE_LOADER #(.ROW_BITS(DATAWIDTH_IMG_FULL))
    loader_image_sm (
        .i_CLOCK      (i_SPI_Clk),
        .i_RESET      (i_RESET),
        .i_CMD        (cmd),
        .i_DATA_COUNT (data_count),
        .i_ROW        (row),
        .o_load00(o_load00), .o_load01(o_load01), .o_load02(o_load02),
        .o_load03(o_load03), .o_load04(o_load04), .o_load05(o_load05),
        .o_load06(o_load06), .o_load07(o_load07), .o_load08(o_load08),
        .o_load09(o_load09)
    );

    // ── SM pesos: reset GLOBAL (FIX-2) ───────────────────────────────
    SC_STATEMACHINE_WEIGHT_LOADER #(.ROW_BITS(DATAWIDTH_WGT_FULL))
    loader_weight_sm (
        .i_CLOCK      (i_SPI_Clk),
        .i_RESET      (i_RESET),
        .i_CMD        (cmd),
        .i_DATA_COUNT (data_count),
        .i_WROW       (weight_count),
        .o_wload00(o_wload00), .o_wload01(o_wload01), .o_wload02(o_wload02),
        .o_wload03(o_wload03), .o_wload04(o_wload04)
    );

    // ── MISO: mux entre READ_RESULT (16b) y READ_COMPARE (1b) ────────
    // cmd 011: MISO = i_cnn_result bit [15-miso_count] (16 clocks)
    // cmd 110: MISO = i_comp_result (1 clock, miso_count no avanza)
    assign o_SPI_MISO = miso_active ?
        ((cmd == 3'b110) ? i_comp_result : i_cnn_result[15 - miso_count[3:0]])
        : 1'bZ;

    // ── NEGEDGE: activa valid_clk (anti-posedge-espurio) ─────────────
    always @(negedge i_SPI_Clk or posedge internal_reset) begin
        if (internal_reset) valid_clk <= 1'b0;
        else                valid_clk <= 1'b1;
    end

    // ─────────────────────────────────────────────────────────────────
    // FIX-1a: o_start_cnn — bloque solo con reset GLOBAL
    // El pulso sobrevive hasta el posedge donde la FSM lo muestrea.
    // ─────────────────────────────────────────────────────────────────
    always @(posedge i_SPI_Clk or posedge i_RESET) begin
        if (i_RESET)
            o_start_cnn <= 1'b0;
        else begin
            o_start_cnn <= 1'b0;  // default: limpiar
            if (valid_clk && (bit_count == 9'd3) && (cmd == 3'b010))
                o_start_cnn <= 1'b1;
        end
    end

    // ─────────────────────────────────────────────────────────────────
    // FIX-1b: o_save_accum — bloque solo con reset GLOBAL (★ NUEVO)
    // Mismo patron que o_start_cnn.
    // Disparo: bit_count==3 con cmd==101 (primer dato-posedge de la transaccion)
    // ─────────────────────────────────────────────────────────────────
    always @(posedge i_SPI_Clk or posedge i_RESET) begin
        if (i_RESET)
            o_save_accum <= 1'b0;
        else begin
            o_save_accum <= 1'b0;
            if (valid_clk && (bit_count == 9'd3) && (cmd == 3'b101))
                o_save_accum <= 1'b1;
        end
    end

    // ─────────────────────────────────────────────────────────────────
    // FIX-1c: o_mp_load + o_mp_data — bloque solo con reset GLOBAL
    // mp_shift[9:0] al muestrear = data[10:1], MOSI = data[0]
    // → o_mp_data = {mp_shift[9:0], MOSI} = data[10:0] ✓
    // ─────────────────────────────────────────────────────────────────
    always @(posedge i_SPI_Clk or posedge i_RESET) begin
        if (i_RESET) begin
            o_mp_load <= 1'b0;
            o_mp_data <= 11'd0;
        end else begin
            o_mp_load <= 1'b0;
            if (valid_clk && (cmd == 3'b100) && (data_count == 7'd15)) begin
                o_mp_data <= {mp_shift[9:0], i_SPI_MOSI};
                o_mp_load <= 1'b1;
            end
        end
    end

    // ─────────────────────────────────────────────────────────────────
    // Logica principal SPI: contadores, shifts, memorias
    // Reset con internal_reset (CS o i_cmd_reset)
    // ─────────────────────────────────────────────────────────────────
    always @(posedge i_SPI_Clk or posedge internal_reset) begin
        if (internal_reset) begin
            bit_count    <= 9'd0;
            data_count   <= 7'd0;
            row          <= 4'd0;
            weight_count <= 3'd0;
            miso_count   <= 5'd0;
            miso_active  <= 1'b0;
            cmd          <= 3'b000;
            image_shift  <= {DATAWIDTH_IMG_FULL{1'b0}};
            weight_shift <= {DATAWIDTH_WGT_FULL{1'b0}};
            mp_shift     <= 16'd0;
        end
        else if (valid_clk) begin
            bit_count <= bit_count + 9'd1;

            // ── Primeros 3 posedges: captura cmd (3 bits, MSB primero) ──
            if (bit_count < 9'd3) begin
                cmd[2 - bit_count[1:0]] <= i_SPI_MOSI;
                data_count <= 7'd0;
            end
            else begin
                data_count <= data_count + 7'd1;

                case (cmd)

                    // CMD 000: LOAD IMAGE — 10 filas x 30 bits
                    3'b000: begin
                        image_shift <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                        if (data_count == IMG_LAST_BIT) begin
                            image_mem[row] <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                            row        <= row + 4'd1;
                            data_count <= 7'd0;
                        end
                    end

                    // CMD 001: LOAD WEIGHTS — 5 filas x 15 bits
                    3'b001: begin
                        weight_shift <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                        if (data_count == WGT_LAST_BIT) begin
                            weight_mem[weight_count] <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                            weight_count <= weight_count + 3'd1;
                            data_count   <= 7'd0;
                        end
                    end

                    // CMD 010: START CNN — pulso generado en bloque separado
                    3'b010: ;

                    // CMD 011: READ RESULT — 16 bits MSB primero por MISO
                    // Primer clock: activa miso_active (miso_count=0 → MISO=bit[15])
                    // Clocks 2-16: incrementa miso_count → MISO=bit[14..0]
                    3'b011: begin
                        if (!miso_active) begin
                            miso_active <= 1'b1;
                        end else begin
                            if (miso_count < 5'd15)
                                miso_count <= miso_count + 5'd1;
                        end
                    end

                    // CMD 100: LOAD MAXPOOL — 16 bits, shift; pulso generado en bloque separado
                    3'b100: begin
                        mp_shift <= {mp_shift[14:0], i_SPI_MOSI};
                        if (data_count == 7'd15)
                            data_count <= 7'd0;
                    end

                    // CMD 101: SAVE ACCUM — pulso generado en bloque separado
                    3'b101: ;

                    // CMD 110: READ COMPARE — 1 bit MISO
                    // Solo se necesita 1 clock: miso_active=1, MISO=i_comp_result
                    // miso_count NO avanza (no hay multiplex de bits)
                    3'b110: begin
                        if (!miso_active)
                            miso_active <= 1'b1;
                        // miso_count queda en 0: siempre muestra i_comp_result
                    end

                    default: ;
                endcase
            end
        end
    end

endmodule