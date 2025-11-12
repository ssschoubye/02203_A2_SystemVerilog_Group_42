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
    input  logic[8:0]        s11,
    input  logic[8:0]        s21,
    input  logic[8:0]        s31,
    input  logic[8:0]        s12,
    input  logic[8:0]        s22,
    input  logic[8:0]        s32,
    input  logic[8:0]        s13,
    input  logic[8:0]        s23,
    input  logic[8:0]        s33,
    output logic[12:0]        out

    
);
    logic signed [10:0] v1, v2, v3, v4, v5, v6;
    logic signed [11:0] gx_s, gy_s;
    logic signed [11:0] gx_abs, gy_abs;
  // ---------------------------------------------------
  // Insert your design here
  // ---------------------------------------------------
    always_comb begin
        
        gx_s = s13 - s11 + ((s23 - s21) << 1) + s33 - s31;
        gy_s = s11 - s31 + ((s12 - s32) << 1) + s13 - s33;
        
        gx_abs = gx_s[11] ? (~gx_s + 12'b1) : gx_s;
        gy_abs = gy_s[11] ? (~gy_s + 12'b1) : gx_s;
        
        out = gx_abs + gy_abs;
    
    end 
endmodule
