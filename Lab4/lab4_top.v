`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2020 02:26:19 PM
// Design Name: 
// Module Name: lab4_top
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


module lab4_top(
    input clk_fpga,             // 100MHz clock
    input reset,                // Global reset 
    output hSync,
    output vSync,
    output [3:0] vga_r,         // VGA red signal
    output [3:0] vga_g,         // VGA green signal
    output [3:0] vga_b,         // VGA blue signal
    output [6:0] seg,        	// Output to seven-segment
	output [3:0] an          	// Output to anodes
    );
    
    wire blank;                 // Blank signal
    wire [10:0] h_count;        // Horizontal count of the displayed pixel
    wire [10:0] v_count;        // Vertical count of the displayed pixel

    clk_wiz_0 MMCM
    (
    // Clock out ports
    .clk_out1(clk_25),          // output clk_out1
    .clk_out2(clk_10),          // output clk_out2
    // Status and control signals
    .reset(reset),              // input reset
    .locked(locked),            // output locked
   // Clock in ports
    .clk_in1(clk_fpga));        // input clk_in1
    
    // For the VGA Display
    vga_controller_640_60 u1
    (
    .rst(reset),
    .pixel_clk(clk_25),
    .HS(hSync),
    .VS(vSync),
    .hcount(h_count),
    .vcount(v_count),
    .blank(blank));
    
    // Draw the display
    vga_scope 
    (
    .clk(clk_25),
    .reset(reset),
    .blank(blank),
    .h_count(h_count),
    .v_count(v_count),
    .vga_red(vga_r),
    .vga_green(vga_g),
    .vga_blue(vga_b));
    
    // Instantiate seven segment module 
    seven_seg s1
    (
    .in(),
    .clk(clk_10),
    .reset(reset),
    .seg(seg),
    .an(an));
    
    
endmodule
