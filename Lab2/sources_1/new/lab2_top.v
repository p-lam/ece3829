`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 09/09/2020 06:42:28 PM
// Design Name: 
// Module Name: lab2_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top module for lab 2. 16 slide switches are used to control the seven segment display.
// The first three switches control what is outputted to the VGA
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab2_top(
    input clk_fpga,        // 100MHz Clock
    input reset,       
    input [15:0] sw,       // 16-bit input for switches
    output hSync,      
    output vSync,
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,
    output [6:0] seg,      // Outputs to seven segment display
    output [3:0] an);      // Four 1-bit anodes to drive the four anodes
    
    wire[2:0] sel;         
    assign sel = sw[2:0];  // Group the first three switches for the VGA
    wire blank;            // Blank signal
    wire [10:0] h_count;   // Horizontal count of the displayed pixel
    wire [10:0] v_count;   // Vertical count of the displayed pixel
    
    // Create a 25MHz clock using the MMCM
    clk_wiz_0 mmcm
   (
    // Clock out ports
    .clk_out1(clk_25MHz),     // output clk_out1
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk_fpga));      // input clk_in1
    
    vga_controller_640_60 u1(.rst(reset), 
                             .pixel_clk(clk_25MHz), 
                             .HS(hSync), 
                             .VS(vSync), 
                             .hcount(h_count), 
                             .vcount(v_count), 
                             .blank(blank));
    
    // Instantiate module to create a signal every 1Hz
    clk_divider slow_clock(.clk_in(clk_25MHz), 
                           .reset(reset),
                           .clk_out(clk_1Hz));
    
    // Instantiate logic for VGA display   
    color_log(  .h_count(h_count), 
                .v_count(v_count), 
                .blank(blank), 
                .SEL(sel),
                .clk(clk_1Hz),
                .vga_red(vga_red),
                .vga_green(vga_green),
                .vga_blue(vga_blue));
    
    // Instantiate seven segment module
    seven_seg seg1( .in(sw),
                    .clk(clk_25MHz),
                    .reset(reset),
                    .seg(seg),
                    .an(an));
                    
endmodule
