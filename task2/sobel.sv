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
    input  logic        s11,
    input  logic        s21,
    input  logic        s31,
    input  logic        s12,
    input  logic        s22,
    input  logic        s32,
    input  logic        s13,
    input  logic        s23,
    input  logic        s33,
    output logic        out

    
);
    int v1, v2, v3, v4, v5, v6;
  // ---------------------------------------------------
  // Insert your design here
  // ---------------------------------------------------
    always_comb begin
    
        v1 = s13 - s11;
        v2 = s23 - s21;
        v3 = s33 - s31;
        v4 = s11 - s31;
        v5 = s12 - s32;
        v6 = s13 - s33;
        
        
        v2 = v2 << 1;
        v5 = v5 << 1;
        
        v1 = v1 + v2 + v3;
        v4 = v4 + v5 + v6;
        
        v1 = (v1 < 0) ? -v1 : v1;
        v2 = (v2 < 0) ? -v2 : v2;
        
        v1 = v1 + v2;
        
        out = v1;
    
    end 
endmodule
