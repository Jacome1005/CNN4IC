//`timescale 1ns/1ps
//=======================================================
//  spi_cnn_slave_8 — MODIFICADO para integración CNN
//=======================================================
//  CAMBIOS respecto al original (marcados con ★):
//  ★1  Puertos de salida para weight_mem (o_wrow00..07)
//  ★2  Puerto de entrada i_cnn_result[10:0] para MISO
//  ★3  result eliminado; MISO lee de i_cnn_result
//  ★4  miso_count ampliado a [3:0] para 11 bits
//  ★5  Límite de miso_count: < 11 (era < 4)
//
//  TODA la lógica SPI original es IDÉNTICA.
//=======================================================

module spi_cnn_slave_8 #(parameter DATAWIDTH_BUS = 8)(
    input  wire i_SPI_Clk,
    input  wire i_SPI_CS_n,
    input  wire i_SPI_MOSI,
    output wire o_SPI_MISO,
    output reg  o_start_cnn,

    // Salidas físicas de las 8 filas — original
    output wire [7:0] o_row00, output wire [7:0] o_row01,
    output wire [7:0] o_row02, output wire [7:0] o_row03,
    output wire [7:0] o_row04, output wire [7:0] o_row05,
    output wire [7:0] o_row06, output wire [7:0] o_row07,
    output wire o_load00, output wire o_load01,
    output wire o_load02, output wire o_load03,
    output wire o_load04, output wire o_load05,
    output wire o_load06, output wire o_load07,

    // ★1 Salidas de weight_mem (NUEVO)
    output wire [7:0] o_wrow00, output wire [7:0] o_wrow01,
    output wire [7:0] o_wrow02, output wire [7:0] o_wrow03,
    output wire [7:0] o_wrow04, output wire [7:0] o_wrow05,
    output wire [7:0] o_wrow06, output wire [7:0] o_wrow07,

    // ★2 Resultado CNN para lectura MISO (NUEVO)
    input  wire [10:0] i_cnn_result
);

    // Memorias internas — original
    reg [7:0] image_mem [0:7];
    reg [7:0] weight_mem [0:7]; 
    
    // Asignación continua imagen — original
    assign o_row00 = image_mem[0];  assign o_row01 = image_mem[1];
    assign o_row02 = image_mem[2];  assign o_row03 = image_mem[3];
    assign o_row04 = image_mem[4];  assign o_row05 = image_mem[5];
    assign o_row06 = image_mem[6];  assign o_row07 = image_mem[7];

    // ★1 Asignación continua pesos (NUEVO)
    assign o_wrow00 = weight_mem[0];  assign o_wrow01 = weight_mem[1];
    assign o_wrow02 = weight_mem[2];  assign o_wrow03 = weight_mem[3];
    assign o_wrow04 = weight_mem[4];  assign o_wrow05 = weight_mem[5];
    assign o_wrow06 = weight_mem[6];  assign o_wrow07 = weight_mem[7];

    // Registros internos de control — original (excepto ★3 ★4)
    reg [1:0] cmd;
    reg [6:0] bit_count;  
    reg [6:0] data_count; 
    reg [3:0] row;        
    reg [7:0] image_shift;
    reg [7:0] weight_shift;
    reg [6:0] weight_count;
    // ★3  result eliminado — ya no se necesita registro interno
    reg [3:0] miso_count;    // ★4  Ampliado de [2:0] a [3:0]
    reg       miso_active;

    // Instancia de la Máquina de Estados — original sin cambios
    SC_STATEMACHINE_IMAGE_LOADER loader_image_sm (
        .i_CLOCK(i_SPI_Clk),
        .i_RESET(i_SPI_CS_n), // Reset cuando el CS es alto
        .i_CMD(cmd),
        .i_DATA_COUNT(data_count),
        .i_ROW(row),
        .o_load00(o_load00), .o_load01(o_load01),
        .o_load02(o_load02), .o_load03(o_load03),
        .o_load04(o_load04), .o_load05(o_load05),
        .o_load06(o_load06), .o_load07(o_load07)
    );

    // ★3 MISO ahora lee de i_cnn_result (11 bits, MSB primero)
    assign o_SPI_MISO = (miso_active) ? i_cnn_result[10 - miso_count] : 1'bZ;

    // Lógica principal SPI — IDÉNTICA a la original (excepto ★5 en READ RESULT)
    always @(posedge i_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n) begin
            bit_count    <= 0;
            data_count   <= 0;
            row          <= 0;
            weight_count <= 0;
            miso_count   <= 0;
            miso_active  <= 0;
            o_start_cnn  <= 0;
            cmd          <= 2'b00;
        end
        else begin
            bit_count <= bit_count + 7'd1;

            if (bit_count < 2) begin
                cmd[1 - bit_count] <= i_SPI_MOSI;
                data_count <= 0;
            end
            else begin
                data_count <= data_count + 7'd1;
                // LOAD IMAGE (00) — original
                if (cmd == 2'b00) begin
                    image_shift <= {image_shift[6:0], i_SPI_MOSI};
                    if (data_count == 7) begin
                        image_mem[row] <= {image_shift[6:0], i_SPI_MOSI};
                        row <= row + 4'd1;
                        data_count <= 0; 
                    end
                end
                // LOAD WEIGHTS (01) — original
                else if (cmd == 2'b01) begin
                    weight_shift <= {weight_shift[6:0], i_SPI_MOSI};
                    if (data_count == 7) begin
                        weight_mem[weight_count] <= {weight_shift[6:0], i_SPI_MOSI};
                        weight_count <= weight_count + 7'd1;
                        data_count <= 0;
                    end
                end
                // START CNN (10) — original
                else if (cmd == 2'b10) begin
                    o_start_cnn <= 1;
                end
                // READ RESULT (11) — ★5 ampliado a 11 bits
                else if (cmd == 2'b11) begin
                    miso_active <= 1;
                    if (miso_count < 4'd10)
                        miso_count <= miso_count + 4'd1;
                end
            end
        end
    end
endmodule
