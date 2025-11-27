`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06.11.2025 11:46:14
// Design Name:
// Module Name: sobel
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

module sobel(
    input  logic[7:0]        s11,
    input  logic[7:0]        s21,
    input  logic[7:0]        s31,
    input  logic[7:0]        s12,
    input  logic[7:0]        s22,
    input  logic[7:0]        s32,
    input  logic[7:0]        s13,
    input  logic[7:0]        s23,
    input  logic[7:0]        s33,
    output logic[7:0]        out

);
    logic signed [11:0] gx_s, gy_s;
    logic signed [11:0] gx_abs, gy_abs;
    logic [11:0] mag;
  // ---------------------------------------------------
  // Insert your design here
  // ---------------------------------------------------
    localparam int MAX_MAG = 2040;
    logic [15:0] normalized;

    always_comb begin
        gx_s = $signed({4'd0, s13}) - $signed({4'd0, s11}) + (($signed({4'd0, s23}) - $signed({4'd0, s21})) << 1) + $signed({4'd0, s33}) - $signed({4'd0, s31});
        gy_s = $signed({4'd0, s11}) - $signed({4'd0, s31}) + (($signed({4'd0, s12}) - $signed({4'd0, s32})) << 1) + $signed({4'd0, s13}) - $signed({4'd0, s33});

        gx_abs = gx_s[11] ? (~gx_s + 12'b1) : gx_s;
        gy_abs = gy_s[11] ? (~gy_s + 12'b1) : gy_s;

        mag = gx_abs + gy_abs;

        // Normalize to 0-255
        normalized = (mag * 255) / MAX_MAG;

        out = (normalized > 20) ? (normalized > 255 ? 8'd255 : normalized[7:0]) : 8'd0;
    end
endmodule
