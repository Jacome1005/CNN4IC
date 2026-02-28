//=======================================================
//  spi_cnn_slave_8 — version combinada
//=======================================================
//  Protocolo MOSI (3 bits de comando al inicio):
//    3'b000 = LOAD IMAGE   : 10 filas x 30 bits = 300 bits
//    3'b001 = LOAD WEIGHTS : 5 filas  x 15 bits = 75 bits
//    3'b010 = START CNN    : sin payload (pulso o_start_cnn)
//    3'b011 = READ RESULT  : 16 clocks -> MISO (16 bits)
//    3'b100 = LOAD MAXPOOL : 16 bits por vector x 4
//
//  Cambios y funcionalidades:
//  ★A  Comando de 3 bits capturado en MOSI (primeros 3 posedges)
//  ★B  Fix valid_clk: ignora posedge espurio post-CS
//  ★C  i_cmd_reset: pin fisico para abortar/reiniciar comando en curso
//  ★D  o_start_cnn como pulso de 1 ciclo (no nivel)
//  ★E  Imagen: 10 filas x 30 bits (DATAWIDTH_BUS_IMAGE x BITS_PER_POS)
//  ★F  Pesos: 5 filas x 15 bits (DATAWIDTH_BUS_WEIGHT x BITS_PER_POS)
//  ★G  Resultado MISO: 16 bits (desde Master_register)
//  ★H  MaxPool: o_mp_data[10:0], o_mp_load (pulso 1 ciclo)
//  ★I  o_result_pos[5:0]: contador de resultado (0-35) para
//      almacenamiento externo de los 36 resultados del mapa
//      de caracteristicas 6x6. Incrementa al completar cada
//      READ RESULT. Se reinicia con i_cmd_reset.
//
//  Timing de cmd (con valid_clk):
//    CS baja  → negedge A: valid_clk = 0 todavia
//    posedge espurio → valid_clk=0, ignorado por slave
//    negedge B → valid_clk <= 1
//    TB pone MOSI = cmd[2]
//    posedge B → bit_count=0, captura cmd[2]
//    ...posedge D → bit_count=2, captura cmd[0]
//    posedge E → bit_count=3, primer dato
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

    // ★C Pin fisico para reiniciar comando en curso
    input  wire i_cmd_reset,

    output reg  o_start_cnn,    // ★D pulso 1 ciclo

    // Salidas imagen — 30 bits por fila (10 filas)
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row00,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row01,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row02,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row03,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row04,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row05,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row06,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row07,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row08,
    output wire [DATAWIDTH_IMG_FULL-1:0] o_row09,

    // Senales de carga de imagen — activa baja
    output wire o_load00, output wire o_load01,
    output wire o_load02, output wire o_load03,
    output wire o_load04, output wire o_load05,
    output wire o_load06, output wire o_load07,
    output wire o_load08, output wire o_load09,

    // Salidas pesos — 15 bits por fila (5 filas)
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow00,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow01,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow02,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow03,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow04,

    // Senales de carga de pesos — activa baja
    output wire o_wload00, output wire o_wload01,
    output wire o_wload02, output wire o_wload03,
    output wire o_wload04,

    // ★G Resultado 16 bits desde Master_register (MISO)
    input  wire [15:0] i_cnn_result,

    // ★H MaxPool
    output reg  [10:0] o_mp_data,
    output reg         o_mp_load,

    // ★I Posicion del resultado actual (0-35) para almacenamiento externo
    output reg  [5:0]  o_result_pos
);

    // ── Memorias internas ────────────────────────────────────────────────
    reg [DATAWIDTH_IMG_FULL-1:0] image_mem  [0:DATAWIDTH_BUS_IMAGE-1];   // 10 x 30
    reg [DATAWIDTH_WGT_FULL-1:0] weight_mem [0:DATAWIDTH_BUS_WEIGHT-1];  //  5 x 15

    // ── Asignacion continua — imagen ─────────────────────────────────────
    assign o_row00 = image_mem[0];  assign o_row01 = image_mem[1];
    assign o_row02 = image_mem[2];  assign o_row03 = image_mem[3];
    assign o_row04 = image_mem[4];  assign o_row05 = image_mem[5];
    assign o_row06 = image_mem[6];  assign o_row07 = image_mem[7];
    assign o_row08 = image_mem[8];  assign o_row09 = image_mem[9];

    // ── Asignacion continua — pesos ──────────────────────────────────────
    assign o_wrow00 = weight_mem[0];  assign o_wrow01 = weight_mem[1];
    assign o_wrow02 = weight_mem[2];  assign o_wrow03 = weight_mem[3];
    assign o_wrow04 = weight_mem[4];

    // ── Registros de control ─────────────────────────────────────────────
    reg [2:0] cmd;               // ★A 3 bits de comando
    reg [8:0] bit_count;         // cuenta posedges validos en la transaccion
    reg [6:0] data_count;        // cuenta bits dentro del dato actual
    reg [3:0] row;               // fila de imagen (0-9)
    reg [2:0] weight_count;      // fila de peso (0-4)
    reg [DATAWIDTH_IMG_FULL-1:0]  image_shift;   // shift 30 bits
    reg [DATAWIDTH_WGT_FULL-1:0]  weight_shift;  // shift 15 bits
    reg [4:0]  miso_count;       // cuenta bits MISO enviados (0-15)
    reg        miso_active;
    reg [15:0] mp_shift;         // shift 16 bits para MaxPool

    // ★B Flag anti-posedge-espurio
    reg valid_clk;

    // ★C Reset combinado: CS sube O pin i_cmd_reset asertado
    wire internal_reset = i_SPI_CS_n | i_cmd_reset;

    localparam IMG_LAST_BIT = DATAWIDTH_IMG_FULL  - 1;  // 29
    localparam WGT_LAST_BIT = DATAWIDTH_WGT_FULL  - 1;  // 14

    // ── SM: carga de filas de imagen (ahora recibe cmd 3 bits) ───────────
    SC_STATEMACHINE_IMAGE_LOADER #(.ROW_BITS(DATAWIDTH_IMG_FULL))
    loader_image_sm (
        .i_CLOCK     (i_SPI_Clk),
        .i_RESET     (internal_reset),   // ★C
        .i_CMD       (cmd),              // ★A 3 bits
        .i_DATA_COUNT(data_count),
        .i_ROW       (row),
        .o_load00(o_load00), .o_load01(o_load01),
        .o_load02(o_load02), .o_load03(o_load03),
        .o_load04(o_load04), .o_load05(o_load05),
        .o_load06(o_load06), .o_load07(o_load07),
        .o_load08(o_load08), .o_load09(o_load09)
    );

    // ── SM: carga de filas de pesos (ahora recibe cmd 3 bits) ────────────
    SC_STATEMACHINE_WEIGHT_LOADER #(.ROW_BITS(DATAWIDTH_WGT_FULL))
    loader_weight_sm (
        .i_CLOCK     (i_SPI_Clk),
        .i_RESET     (internal_reset),   // ★C
        .i_CMD       (cmd),              // ★A 3 bits
        .i_DATA_COUNT(data_count),
        .i_WROW      (weight_count),
        .o_wload00(o_wload00), .o_wload01(o_wload01),
        .o_wload02(o_wload02), .o_wload03(o_wload03),
        .o_wload04(o_wload04)
    );

    // ── MISO: resultado 16 bits MSB primero ──────────────────────────────
    assign o_SPI_MISO = (miso_active) ? i_cnn_result[15 - miso_count[3:0]] : 1'bZ;

    // ═══════════════════════════════════════════════════════════════════
    // ★B BLOQUE NEGEDGE: activa valid_clk en primer negedge post-CS
    //
    //   Cronologia (TCK=20ns):
    //   t=0    negedge_A  → TB aserta SS_N 2ns despues
    //   t=2ns             → SS_N=0 (CS activo)
    //   t=10ns posedge_A  → ESPURIO: valid_clk=0 → slave ignora
    //   t=20ns negedge_B  → valid_clk <= 1
    //                        TB pone MOSI = cmd[2] 2ns despues
    //   t=30ns posedge_B  → VALIDO: bit_count=0, captura cmd[2]
    //   t=50ns posedge_C  → bit_count=1, captura cmd[1]
    //   t=70ns posedge_D  → bit_count=2, captura cmd[0]
    //   t=90ns posedge_E  → bit_count=3, primer dato (data_count=1)
    //   ...
    //   Al subir CS_n o asertar i_cmd_reset: valid_clk <= 0
    // ═══════════════════════════════════════════════════════════════════
    always @(negedge i_SPI_Clk or posedge internal_reset) begin
        if (internal_reset)
            valid_clk <= 1'b0;
        else
            valid_clk <= 1'b1;
    end

    // ═══════════════════════════════════════════════════════════════════
    // Logica principal SPI
    // ═══════════════════════════════════════════════════════════════════
    always @(posedge i_SPI_Clk or posedge internal_reset) begin
        if (internal_reset) begin
            // Reset: CS sube o i_cmd_reset asertado
            bit_count    <= 9'd0;
            data_count   <= 7'd0;
            row          <= 4'd0;
            weight_count <= 3'd0;
            miso_count   <= 5'd0;
            miso_active  <= 1'b0;
            o_start_cnn  <= 1'b0;
            o_mp_load    <= 1'b0;
            o_mp_data    <= 11'd0;
            cmd          <= 3'b000;
            image_shift  <= {DATAWIDTH_IMG_FULL{1'b0}};
            weight_shift <= {DATAWIDTH_WGT_FULL{1'b0}};
            mp_shift     <= 16'd0;
            // NOTA: result_pos NO se resetea aqui para preservar
            // la cuenta entre transacciones. Se resetea solo con
            // i_cmd_reset (ver bloque separado abajo).
        end
        else if (valid_clk) begin
            // ★D Limpiar pulsos de 1 ciclo por defecto
            o_start_cnn <= 1'b0;
            o_mp_load   <= 1'b0;

            bit_count <= bit_count + 9'd1;

            // ── Primeros 3 posedges: captura de comando (3 bits) ────────
            // bit_count=0 → cmd[2] (MSB del cmd)
            // bit_count=1 → cmd[1]
            // bit_count=2 → cmd[0] (LSB del cmd)
            if (bit_count < 9'd3) begin
                cmd[2 - bit_count[1:0]] <= i_SPI_MOSI;  // ★A
                data_count <= 7'd0;
            end
            else begin
                // ── Posedge 3 en adelante: datos ────────────────────────
                data_count <= data_count + 7'd1;

                case (cmd)

                    // ── CMD 000: LOAD IMAGE ───────────────────────────────
                    3'b000: begin
                        image_shift <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                        if (data_count == IMG_LAST_BIT) begin
                            image_mem[row] <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                            row        <= row + 4'd1;
                            data_count <= 7'd0;
                        end
                    end

                    // ── CMD 001: LOAD WEIGHTS ────────────────────────────
                    3'b001: begin
                        weight_shift <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                        if (data_count == WGT_LAST_BIT) begin
                            weight_mem[weight_count] <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                            weight_count <= weight_count + 3'd1;
                            data_count   <= 7'd0;
                        end
                    end

                    // ── CMD 010: START CNN ───────────────────────────────
                    // ★D Pulso de 1 ciclo en el primer bit de datos
                    3'b010: begin
                        if (bit_count == 9'd3)
                            o_start_cnn <= 1'b1;
                    end

                    // ── CMD 011: READ RESULT ─────────────────────────────
                    // ★G 16 bits MSB primero por MISO
                    // ── CMD 011: READ RESULT ─────────────────────────────
                    // Primer clock: activa miso_active, miso_count=0 → MISO=bit[15]
                    // Siguientes clocks: incrementa miso_count → MISO=bit[14..0]
                    // Total: 16 clocks para leer los 16 bits completos
                    3'b011: begin
                        if (!miso_active) begin
                            miso_active <= 1'b1;
                            // miso_count queda en 0: MISO ya muestra bit[15]
                        end else begin
                            if (miso_count < 5'd15)
                                miso_count <= miso_count + 5'd1;
                        end
                    end

                    // ── CMD 100: LOAD MAXPOOL ────────────────────────────
                    // ★H 16 bits por vector: [15:11]=padding, [10:0]=dato
                    // Al llegar el bit 15 extrae [10:0] y pulsa o_mp_load
                    3'b100: begin
                        mp_shift <= {mp_shift[14:0], i_SPI_MOSI};
                        if (data_count == 7'd15) begin
                            o_mp_data  <= {mp_shift[9:0], i_SPI_MOSI};
                            o_mp_load  <= 1'b1;
                            data_count <= 7'd0;
                        end
                    end

                    default: ; // comando desconocido: ignorar

                endcase
            end
        end
        // valid_clk=0: posedge espurio ignorado
    end

    // ═══════════════════════════════════════════════════════════════════
    // ★I Contador de posicion de resultado (0-35)
    //    - Incrementa al completar cada transaccion READ RESULT
    //      (deteccion en flanco de subida de CS_n con cmd=011)
    //    - Se reinicia a 0 cuando i_cmd_reset es asertado
    //    - Permite al controlador externo saber cual de los 36
    //      resultados de la convolucion 6x6 esta recibiendo
    //
    //  Uso tipico:
    //    Para cada posicion (R_OFF, C_OFF) de 0 a 35:
    //      1. Configurar R_OFF/C_OFF en el hardware (o instanciar 36 copias)
    //      2. START CNN → esperar ready
    //      3. READ RESULT → leer 16 bits MISO
    //      4. Guardar externamente en buffer[result_pos]
    //      5. result_pos se incrementa automaticamente
    //    Despues de 36 lecturas, result_pos wraps a 0.
    // ═══════════════════════════════════════════════════════════════════
    // ── cmd_latch_for_pos: retiene el cmd de la transaccion en curso ─────
    // Unico driver: bloque posedge CLK.
    //   - internal_reset (CS sube o i_cmd_reset): -> 3'b111 (invalido)
    //     Esto garantiza que si la siguiente CS sube sin haber capturado
    //     cmd completo, result_pos no se incrementa.
    //   - bit_count==2 (ultimo bit del cmd capturado): guarda {cmd[2],cmd[1],MOSI}
    //     Es decir, el cmd completo justo cuando llega cmd[0].
    reg [2:0] cmd_latch_for_pos;
    always @(posedge i_SPI_Clk or posedge internal_reset) begin
        if (internal_reset) begin
            cmd_latch_for_pos <= 3'b111;   // invalido: no incrementar result_pos
        end else if (valid_clk && bit_count == 9'd2) begin
            // bit_count=2: capturamos cmd[0] (MOSI), cmd[2:1] ya estan en cmd[]
            cmd_latch_for_pos <= {cmd[2], cmd[1], i_SPI_MOSI};
        end
    end

    // Incremento de result_pos en flanco de subida de CS_n
    // (fin de transaccion) si la transaccion fue READ RESULT
    always @(posedge i_SPI_CS_n or posedge i_cmd_reset) begin
        if (i_cmd_reset) begin
            o_result_pos <= 6'd0;
        end
        else begin
            // CS subio: si la transaccion completada fue READ RESULT
            if (cmd_latch_for_pos == 3'b011) begin
                if (o_result_pos == 6'd35)
                    o_result_pos <= 6'd0;    // wrap despues de 36 resultados
                else
                    o_result_pos <= o_result_pos + 6'd1;
            end
        end
    end

endmodule