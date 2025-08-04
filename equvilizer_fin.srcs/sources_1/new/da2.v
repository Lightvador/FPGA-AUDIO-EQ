`timescale 1ns / 1ps
//module da2(
//  input clk,
//  input reset,
//  output cs,
//  output reg SCLK = 0,                  // Serial clock
//  output SDATA,                // Serial data out
//  output reg SYNC,             // Sync signal
//  output reg working,          // Enable clock
 
//  input [11:0] value_12bit           // Now 16-bit input
//);
//assign cs =0;
//  reg [1:0] chmode_reg;
//  reg [11:0] value_reg;
//  wire update;
//   wire [1:0] chmode=2'b00;          // Channel mode: 00 Enabled, 01 1kOhm, 10 100kOhm, 11 High-Z

//  reg count;
//  reg contCount;
//  reg [3:0] counter;              // Counter for SCLK edges
//  wire [15:0] SDATAbuff_cont;
//  reg [15:0] SDATAbuff;

 
//  assign SDATAbuff_cont = {2'd0, chmode, value_12bit};          // Compose 16-bit data
//  assign SDATA = SDATAbuff[15];

//  // Generate update signal on value or mode change
//  assign update = (chmode != chmode_reg) || (value_12bit != value_reg);

//  // Store values when SYNC is triggered
//  always @(posedge SYNC or posedge reset) begin
//    if (reset) begin
//      chmode_reg <= 2'd0;
//      value_reg  <= 12'd0;
//    end else begin
//      chmode_reg <= chmode;
//      value_reg  <= value_12bit;
//    end
//  end

//  // Shift data on each SCLK rising edge or reload buffer on SYNC
//  always @(posedge SCLK or posedge SYNC) begin
//    if (SYNC) begin
//      SDATAbuff <= SDATAbuff_cont;
//    end else begin
//      SDATAbuff <= (count) ? {SDATAbuff[14:0], 1'b0} : SDATAbuff;
//    end
//  end

//  // Control SYNC and working flags
//  always @(posedge clk or posedge reset) begin
//    if (reset) begin
//      working <= 0;
//      SYNC <= 0;
//      counter <= 0;
//      count <= 0;
//      contCount <= 0;
//    end else if (update) begin
//      SYNC <= 1;
//      counter <= 0;
//      working <= 1;
//      count <= 1;
//    end else if (count) begin
//      SYNC <= 0;
//      counter <= counter + 1;
//      if (counter == 15) begin
//        count <= 0;
//        working <= 0;
//      end
//    end else begin
//      SYNC <= 0;
//    end
// end 

module da2(
  input clk,
  input reset,
  //Serial data line
  output reg SCLK,
  output SDATA,
  output reg SYNC,
  //Enable clock
  output reg working,
  //Output value and mode
  input [1:0] chmode,
  //Channel modes: 00 Enabled, Power off modes: 01 1kOhm, 10 100kOhm, 11 High-Z 
  input [11:0] value,
  //Control signals
  input update);
  reg count;
  reg contCount;
  reg [3:0] counter; //Count edges
  wire [15:0] SDATAbuff_cont;
  reg [15:0] SDATAbuff;

  //Handle SDATA buffer
  assign SDATAbuff_cont = {2'd0, chmode, value};
  assign SDATA = SDATAbuff[15];
  always@(posedge SCLK or posedge SYNC) begin
    if(SYNC) begin
      SDATAbuff <= SDATAbuff_cont;
    end else begin
      SDATAbuff <= (count) ? {SDATAbuff[14:0], 1'b0} : SDATAbuff;
    end
  end

  //count
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      count <= 1'b0;
    end else case(count)
      1'b0: count <= SCLK & contCount;
      1'b1: count <= (counter != 4'd0) | contCount;
    endcase
  end
  
  //contCount
  always@(posedge clk or posedge SYNC) begin
    if(SYNC) begin
      contCount <= 1'b1;
    end else begin
      contCount <= working & contCount & (counter != 4'd15);
    end
  end
  
  //working
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      working <= 1'b0;
    end else case(working)
      1'b0: working <= SYNC;
      1'b1: working <= (counter != 4'd0) | contCount;
    endcase
  end
  
  //SYNC
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      SYNC <= 1'b0;
    end else case(SYNC)
      1'b0: SYNC <= update & ~(contCount | count);
      1'b1: SYNC <= 1'b0;
    endcase
  end
  
  //Count SCLK
  always@(negedge SCLK or posedge SYNC) begin
    if(SYNC) begin
      counter <= 4'd0;
    end else begin
      counter <= counter + {3'd0, count};
    end
  end 

 parameter DIVIDER = 50;    // Divider for ~2 MHz from 125 MHz
    reg [5:0] clkdiv = 0;     // Clock divider counter
  

    always @(posedge clk) begin
        // Clock Divider
        if (clkdiv == DIVIDER - 1) begin
            clkdiv <= 0;
            SCLK <= ~SCLK;  // Toggle SPI clock
        end else begin
            clkdiv <= clkdiv + 1;
        end
        end
 endmodule