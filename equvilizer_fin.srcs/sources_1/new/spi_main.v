`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2025 14:19:28
// Design Name: 
// Module Name: spi_main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_main (
    input wire clk,            // System clock (e.g., 125 MHz)
    input wire miso,           // Master In Slave Out
    output reg sck = 0,        // SPI Clock
    output reg ss = 1,         // Slave Select (active low)
    output reg [15:0] out = 0  // Received data
);

    parameter DIVIDER = 50;    // Divider for ~2 MHz from 125 MHz
    reg [5:0] clk_div = 0;     // Clock divider counter
    reg [4:0] bit_cnt = 0;     // Bit counter
    reg [15:0] shift_reg = 0;  // Shift register for input data
    reg sck_enable = 0;

    always @(posedge clk) begin
        // Clock Divider
        if (clk_div == DIVIDER - 1) begin
            clk_div <= 0;
            sck <= ~sck;  // Toggle SPI clock
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // SPI Shift and Control
    always @(posedge sck) begin
        if (sck_enable) begin
            shift_reg <= {shift_reg[14:0], miso}; // Shift in MISO
            bit_cnt <= bit_cnt + 1;

            if (bit_cnt == 15) begin
                out <= {shift_reg[14:0], miso}; // Final shift in
                sck_enable <= 0;
                ss <= 1; // Deselect slave
            end
        end else begin
            bit_cnt <= 0;
            sck_enable <= 1;
            ss <= 0; // Select slave
        end
    end

endmodule

