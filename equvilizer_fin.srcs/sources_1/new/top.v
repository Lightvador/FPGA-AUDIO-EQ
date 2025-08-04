`timescale 1ns / 1ps
module top(
    input wire clk,       // 100 MHz system clock
    input wire reset,
    input wire miso,      // SPI MISO from MIC
    output wire sclk,     // SPI clock to MIC
    output wire ss,        // SPI chip select (active low)
   // output wire cs,
    //output wire [11:0] value_12bit,
    output wire SCLK,
    output SDATA,
    output  SYNC
);

    wire signed [15:0] mic_data;
    wire signed [15:0] audio_out;
    wire [7:0] gain_low, gain_mid, gain_high;
  
    // SPI interface
    spi_main spi_inst (
        .clk(clk),
        .miso(miso),
        .sck(sclk),
        .ss(ss),
        .out(mic_data)
    );

    // FIR Filter
    FIR_FILTER fir_inst (
        .clk(clk),
        .reset(reset),
        .audio_in(mic_data),
        .gain_low(gain_low),
        .gain_mid(gain_mid),
        .gain_high(gain_high),
        .audio_out(audio_out)
    );
//    da2 da2_inst(
//    .clk(clk), 
//    .reset(reset), 
//    .SCLK(SCLK), 
    
//    .SDATA(SDATA), 
//    .SYNC(SYNC), 
//    .cs(cs),
//    .working(working), 
//    .value_12bit(audio_out[11:0]));
   
 da2_run1 da2(.clk(clk),
 .reset(reset),
 .SCLK(SCLK),
 .SDATA(SDATA),
 .SYNC(SYNC), 

   .working(working), 
    .value(audio_out[11:0]));

//vio_0 your_instance_name0 (
//  .clk(clk),                // input wire clk
//  .probe_in0(sclk),    // input wire [0 : 0] probe_in0
//  .probe_in1(ss),    // input wire [0 : 0] probe_in1
//  .probe_in2(miso),    // input wire [0 : 0] probe_in2
//  .probe_in3(audio_out),    // input wire [15 : 0] probe_in3
//  .probe_in4(mic_data),    // input wire [15 : 0] probe_in4
//  .probe_out0(gain_low),  // output wire [7 : 0] probe_out0
//  .probe_out1(gain_mid),  // output wire [7 : 0] probe_out1
//  .probe_out2(gain_high),  // output wire [7 : 0] probe_out2
   
//);
vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_in0(SCLK),    // input wire [0 : 0] probe_in0
  .probe_in1(ss),    // input wire [0 : 0] probe_in1
  .probe_in2(miso),    // input wire [0 : 0] probe_in2
  .probe_in3(SDATA),    // input wire [15 : 0] probe_in3
  .probe_in4(mic_data),    // input wire [15 : 0] probe_in4
  .probe_out0(gain_low),  // output wire [7 : 0] probe_out0
  .probe_out1(gain_mid),  // output wire [7 : 0] probe_out1
  .probe_out2(gain_high)  // output wire [7 : 0] probe_out2
);


endmodule
