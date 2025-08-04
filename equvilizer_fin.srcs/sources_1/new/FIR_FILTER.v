`timescale 1ns / 1ps
module FIR_FILTER #(
    parameter TAPS = 25,
    parameter DATA_WIDTH = 16,
    parameter COEFF_WIDTH = 16,
    parameter GAIN_WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire signed [DATA_WIDTH-1:0] audio_in,
    input wire [GAIN_WIDTH-1:0] gain_low,
    input wire [GAIN_WIDTH-1:0] gain_mid,
    input wire [GAIN_WIDTH-1:0] gain_high,
    output reg signed [DATA_WIDTH-1:0] audio_out
);

localparam ACCUM_WIDTH = DATA_WIDTH + COEFF_WIDTH + 5; // Ceiling of log2(25) is 5
localparam GAIN_PROD_WIDTH = ACCUM_WIDTH + GAIN_WIDTH;
localparam PIPELINE_STAGES = 5; // Example number of pipeline stages

reg signed [COEFF_WIDTH-1:0] coeff_low [0:TAPS-1];
reg signed [COEFF_WIDTH-1:0] coeff_mid [0:TAPS-1];
reg signed [COEFF_WIDTH-1:0] coeff_high [0:TAPS-1];

reg signed [DATA_WIDTH-1:0] delay_line [0:TAPS-1];
reg signed [DATA_WIDTH-1:0] audio_in_r;

// Pipelined multiply-accumulate registers
reg signed [COEFF_WIDTH + DATA_WIDTH - 1:0] mult_low [0:TAPS-1];
reg signed [COEFF_WIDTH + DATA_WIDTH - 1:0] mult_mid [0:TAPS-1];
reg signed [COEFF_WIDTH + DATA_WIDTH - 1:0] mult_high [0:TAPS-1];

reg signed [ACCUM_WIDTH-1:0] accum_low [0:PIPELINE_STAGES];
reg signed [ACCUM_WIDTH-1:0] accum_mid [0:PIPELINE_STAGES];
reg signed [ACCUM_WIDTH-1:0] accum_high [0:PIPELINE_STAGES];

reg signed [GAIN_PROD_WIDTH-1:0] scaled_low_r, scaled_mid_r, scaled_high_r;
reg signed [ACCUM_WIDTH-1:0] sum_low_r, sum_mid_r, sum_high_r;
reg signed [DATA_WIDTH + 2 + GAIN_WIDTH - 1:0] final_sum_wide; // log2(3) ceiling is 2

integer i, j;

initial begin
    $readmemh("low_coeffs.mem", coeff_low);
    $readmemh("mid_coeffs.mem", coeff_mid);
    $readmemh("high_coeffs.mem", coeff_high);
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < TAPS; i = i + 1) begin
            delay_line[i] <= 0;
        end
        audio_in_r <= 0;
        for (j = 0; j <= PIPELINE_STAGES; j = j + 1) begin
            accum_low[j] <= 0;
            accum_mid[j] <= 0;
            accum_high[j] <= 0;
        end
        scaled_low_r <= 0;
        scaled_mid_r <= 0;
        scaled_high_r <= 0;
        sum_low_r <= 0;
        sum_mid_r <= 0;
        sum_high_r <= 0;
        final_sum_wide <= 0;
        audio_out <= 0;
    end else begin
        // Input and Delay Line (Pipeline Stage 1)
        audio_in_r <= audio_in;
        for (i = TAPS - 1; i > 0; i = i - 1) begin
            delay_line[i] <= delay_line[i - 1];
        end
        delay_line[0] <= audio_in_r;

        // Multiply (Pipeline Stage 2)
        for (i = 0; i < TAPS; i = i + 1) begin
            mult_low[i] <= delay_line[i] * coeff_low[i];
            mult_mid[i] <= delay_line[i] * coeff_mid[i];
            mult_high[i] <= delay_line[i] * coeff_high[i];
        end

        // Pipelined Accumulation (Pipeline Stages 3 to 3 + PIPELINE_STAGES - 1)
        for (j = 0; j < PIPELINE_STAGES; j = j + 1) begin
            accum_low[j+1] <= (j == 0) ? mult_low[0] : accum_low[j] + mult_low[j*(TAPS/PIPELINE_STAGES)]; // Simplified example
            accum_mid[j+1] <= (j == 0) ? mult_mid[0] : accum_mid[j] + mult_mid[j*(TAPS/PIPELINE_STAGES)];
            accum_high[j+1] <= (j == 0) ? mult_high[0] : accum_high[j] + mult_high[j*(TAPS/PIPELINE_STAGES)];
            // A more complete pipelined adder tree would be needed here
        end
        sum_low_r <= accum_low[PIPELINE_STAGES];
        sum_mid_r <= accum_mid[PIPELINE_STAGES];
        sum_high_r <= accum_high[PIPELINE_STAGES];

        // Apply Gains (Pipeline Stage 3 + PIPELINE_STAGES)
        scaled_low_r <= sum_low_r * {{(ACCUM_WIDTH - GAIN_WIDTH){1'b0}}, gain_low};
        scaled_mid_r <= sum_mid_r * {{(ACCUM_WIDTH - GAIN_WIDTH){1'b0}}, gain_mid};
        scaled_high_r <= sum_high_r * {{(ACCUM_WIDTH - GAIN_WIDTH){1'b0}}, gain_high};

        // Combine Bands (Pipeline Stage 4 + PIPELINE_STAGES)
        final_sum_wide <= (scaled_low_r >>> (COEFF_WIDTH - 1)) + // Adjust shift based on coefficient scaling
                          (scaled_mid_r >>> (COEFF_WIDTH - 1)) +
                          (scaled_high_r >>> (COEFF_WIDTH - 1));

        // Output Saturation (Pipeline Stage 5 + PIPELINE_STAGES)
        if (final_sum_wide > ((1 << (DATA_WIDTH - 1)) - 1)) begin
            audio_out <= ((1 << (DATA_WIDTH - 1)) - 1);
        end else if (final_sum_wide < -(1 << (DATA_WIDTH - 1))) begin
            audio_out <= -(1 << (DATA_WIDTH - 1));
        end else begin
            audio_out <= final_sum_wide[DATA_WIDTH - 1:0];
        end
    end
end

endmodule

