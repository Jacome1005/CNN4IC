//=======================================================
//  spi_cnn_slave_8
//=======================================================
//  Protocolo MOSI:
//    cmd 00 = LOAD IMAGE   : 10 filas x 30 bits = 300 bits
//    cmd 01 = LOAD WEIGHTS : 5 filas  x 15 bits = 75 bits
//    cmd 10 = START CNN    : dummy bits
//    cmd 11 = READ RESULT  : 11 clocks -> MISO
//
//  FIX de sincronizacion (posedge espurio post-CS):
//  ────────────────────────────────────────────────
//  El testbench aserta SS_N en un negedge del CLK y luego espera
//  OTRO negedge para poner MOSI = cmd[1].
//  Entre esos dos negedges hay un posedge que antes se contaba
//  como bit_count=0, desalineando cmd y datos en 1 bit.
//  Efecto observado:
//    - image_mem: datos shifteados 1 bit a la derecha
//    - weight_mem: cmd=01 leido como cmd=00 => memoria queda en xxx
//
//  Solucion: flag valid_clk, activo en el primer negedge de CLK
//  con CS_n=0. El bloque posedge solo procesa cuando valid_clk=1.
//  El posedge espurio (valid_clk=0 todavia) queda ignorado.
//
//  Otros cambios previos mantenidos:
//    - weight_mem: [14:0] x 5 (kernel 5x5 x 3 bits = 75 bits)
//    - weight_shift: [14:0]
//    - Condicion de carga de peso: data_count == WGT_LAST_BIT (14)
//    - Puertos o_wrow: [14:0] x 5
//    - SM de pesos (SC_STATEMACHINE_WEIGHT_LOADER)
//=======================================================

module spi_cnn_slave_8 #(
    parameter DATAWIDTH_BUS        = 8,
    parameter DATAWIDTH_BUS_IMAGE  = 10,
    parameter DATAWIDTH_BUS_WEIGHT = 5,
    parameter BITS_PER_POS         = 3,
    parameter DATAWIDTH_IMG_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS, // 30
    parameter DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS  // 15
)(
    input  wire i_SPI_Clk,
    input  wire i_SPI_CS_n,
    input  wire i_SPI_MOSI,
    output wire o_SPI_MISO,
    output reg  o_start_cnn,

    // Salidas de imagen - 30 bits por fila (10 filas)
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

    // Senales de carga de imagen - activa baja
    output wire o_load00, output wire o_load01,
    output wire o_load02, output wire o_load03,
    output wire o_load04, output wire o_load05,
    output wire o_load06, output wire o_load07,
    output wire o_load08, output wire o_load09,

    // Salidas de pesos del kernel - 15 bits por fila (5 filas)
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow00,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow01,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow02,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow03,
    output wire [DATAWIDTH_WGT_FULL-1:0] o_wrow04,

    // Senales de carga de pesos - activa baja (una por fila)
    output wire o_wload00, output wire o_wload01,
    output wire o_wload02, output wire o_wload03,
    output wire o_wload04,

    // Resultado CNN para lectura MISO
    input  wire [10:0] i_cnn_result
);

    // ── Memorias internas ────────────────────────────────────────────────
    reg [DATAWIDTH_IMG_FULL-1:0] image_mem  [0:DATAWIDTH_BUS_IMAGE-1];   // 10 x 30
    reg [DATAWIDTH_WGT_FULL-1:0] weight_mem [0:DATAWIDTH_BUS_WEIGHT-1];  //  5 x 15

    // ── Asignacion continua - imagen ─────────────────────────────────────
    assign o_row00 = image_mem[0];  assign o_row01 = image_mem[1];
    assign o_row02 = image_mem[2];  assign o_row03 = image_mem[3];
    assign o_row04 = image_mem[4];  assign o_row05 = image_mem[5];
    assign o_row06 = image_mem[6];  assign o_row07 = image_mem[7];
    assign o_row08 = image_mem[8];  assign o_row09 = image_mem[9];

    // ── Asignacion continua - pesos ──────────────────────────────────────
    assign o_wrow00 = weight_mem[0];  assign o_wrow01 = weight_mem[1];
    assign o_wrow02 = weight_mem[2];  assign o_wrow03 = weight_mem[3];
    assign o_wrow04 = weight_mem[4];

    // ── Registros internos de control ────────────────────────────────────
    reg [1:0] cmd;
    reg [8:0] bit_count;
    reg [6:0] data_count;
    reg [3:0] row;
    reg [DATAWIDTH_IMG_FULL-1:0] image_shift;
    reg [DATAWIDTH_WGT_FULL-1:0] weight_shift;
    reg [2:0] weight_count;
    reg [3:0] miso_count;
    reg       miso_active;

    // ★ Flag de sincronizacion anti-posedge-espurio
    reg valid_clk;

    localparam [6:0] IMG_LAST_BIT = DATAWIDTH_IMG_FULL  - 1; // 29
    localparam [6:0] WGT_LAST_BIT = DATAWIDTH_WGT_FULL  - 1; // 14

    // ── SM: carga de filas de imagen ─────────────────────────────────────
    SC_STATEMACHINE_IMAGE_LOADER #(.ROW_BITS(DATAWIDTH_IMG_FULL))
    loader_image_sm (
        .i_CLOCK     (i_SPI_Clk),
        .i_RESET     (i_SPI_CS_n),
        .i_CMD       (cmd),
        .i_DATA_COUNT(data_count),
        .i_ROW       (row),
        .o_load00(o_load00), .o_load01(o_load01),
        .o_load02(o_load02), .o_load03(o_load03),
        .o_load04(o_load04), .o_load05(o_load05),
        .o_load06(o_load06), .o_load07(o_load07),
        .o_load08(o_load08), .o_load09(o_load09)
    );

    // ── SM: carga de filas de pesos ──────────────────────────────────────
    SC_STATEMACHINE_WEIGHT_LOADER #(.ROW_BITS(DATAWIDTH_WGT_FULL))
    loader_weight_sm (
        .i_CLOCK     (i_SPI_Clk),
        .i_RESET     (i_SPI_CS_n),
        .i_CMD       (cmd),
        .i_DATA_COUNT(data_count),
        .i_WROW      (weight_count),
        .o_wload00(o_wload00), .o_wload01(o_wload01),
        .o_wload02(o_wload02), .o_wload03(o_wload03),
        .o_wload04(o_wload04)
    );

    // ── MISO: resultado CNN MSB primero ──────────────────────────────────
    assign o_SPI_MISO = (miso_active) ? i_cnn_result[10 - miso_count] : 1'bZ;

    // ═══════════════════════════════════════════════════════════════════
    // ★ BLOQUE NEGEDGE: activa valid_clk en el primer negedge post-CS
    //
    //   Cronologia exacta del testbench (TCK=20ns):
    //
    //   t=0    negedge_A  → spi_load_image aserta SS_N 2ns despues
    //   t=2ns             → SS_N = 0 (CS activo)
    //   t=10ns posedge_A  → ESPURIO: valid_clk=0 aun → slave ignora
    //   t=20ns negedge_B  → este always: valid_clk <= 1
    //                        TB pone MOSI = cmd[1] 2ns despues
    //   t=22ns            → MOSI = cmd[1] valido
    //   t=30ns posedge_B  → VALIDO: valid_clk=1, bit_count=0 → cmd[1]
    //   t=40ns negedge_C  → TB pone MOSI = cmd[0]
    //   t=50ns posedge_C  → bit_count=1 → cmd[0]
    //   t=60ns negedge_D  → TB pone MOSI = data[0] (primer bit de fila)
    //   t=70ns posedge_D  → bit_count=2 → data_count=1, shift bit
    //   ...
    //
    //   Al subir CS_n (fin de transaccion): valid_clk <= 0 para la
    //   siguiente transaccion.
    // ═══════════════════════════════════════════════════════════════════
    always @(negedge i_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n)
            valid_clk <= 1'b0;   // fin de transaccion: resetear para la siguiente
        else
            valid_clk <= 1'b1;   // primer negedge con CS=0 activo: habilitar captura
    end

    // ── Logica principal SPI ─────────────────────────────────────────────
    always @(posedge i_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n) begin
            // Reset asincrono: limpia todo al final de la transaccion
            bit_count    <= 9'd0;
            data_count   <= 7'd0;
            row          <= 4'd0;
            weight_count <= 3'd0;
            miso_count   <= 4'd0;
            miso_active  <= 1'b0;
            o_start_cnn  <= 1'b0;
            cmd          <= 2'b00;
        end
        // ★ Solo procesar posedges validos (saltarse el espurio post-CS)
        else if (valid_clk) begin
            bit_count <= bit_count + 9'd1;

            // ── Primeros 2 posedges: captura de comando ───────────────────
            if (bit_count < 9'd2) begin
                cmd[1 - bit_count[0]] <= i_SPI_MOSI;
                data_count <= 7'd0;
            end
            else begin
                // ── Posedges 2 en adelante: datos ────────────────────────
                data_count <= data_count + 7'd1;

                // ── CMD 00: LOAD IMAGE ────────────────────────────────────
                if (cmd == 2'b00) begin
                    image_shift <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                    if (data_count == IMG_LAST_BIT) begin
                        image_mem[row] <= {image_shift[DATAWIDTH_IMG_FULL-2:0], i_SPI_MOSI};
                        row        <= row + 4'd1;
                        data_count <= 7'd0;
                    end
                end

                // ── CMD 01: LOAD WEIGHTS ──────────────────────────────────
                else if (cmd == 2'b01) begin
                    weight_shift <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                    if (data_count == WGT_LAST_BIT) begin
                        weight_mem[weight_count] <= {weight_shift[DATAWIDTH_WGT_FULL-2:0], i_SPI_MOSI};
                        weight_count <= weight_count + 3'd1;
                        data_count   <= 7'd0;
                    end
                end

                // ── CMD 10: START CNN ─────────────────────────────────────
                else if (cmd == 2'b10) begin
                    o_start_cnn <= 1'b1;
                end

                // ── CMD 11: READ RESULT ───────────────────────────────────
                else if (cmd == 2'b11) begin
                    miso_active <= 1'b1;
                    if (miso_count < 4'd10)
                        miso_count <= miso_count + 4'd1;
                end
            end
        end
        // valid_clk=0: posedge espurio post-CS ignorado completamente
    end

endmodule