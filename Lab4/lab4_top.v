`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 10/10/2020 10:11:16 AM
// Design Name: 
// Module Name: lab4_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Top module for lab 4. Uses the Digilent VGA controller and an
// SPI interface for an Ambient Light Sensor to create an oscilloscope 
// and some text on the VGA display
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab4_top(
    input        clk_fpga,      // 100MHz clock
    input        reset,         // Global reset 
    input        SDO,           // Master-In-Slave-Out
    output       hSync,         // Horizontal sync
    output       vSync,         // Vertical sync
    output [3:0] vga_r,         // VGA red signal
    output [3:0] vga_g,         // VGA green signal
    output [3:0] vga_b,         // VGA blue signal
    output       SCLK,          // Series clock
    output       CS,            // Chip select
    output [6:0] seg,        	// Output to seven-segment
    output [3:0] an          	// Output to anodes
    );
    
    wire         blank;         // Blank signal
    wire  [10:0] h_count;       // Horizontal count of the displayed pixel
    wire  [10:0] v_count;       // Vertical count of the displayed pixel
    
    // Create the 25 MHz and 10 MHz clocks
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
    
    // Instantiate PmodALS module 
    wire [7:0] ls_data;          // 8 bits for light sensor data
    wire [3:0] s_cnt1;           // Sample count ones place
    wire [3:0] s_cnt2;           // Sample count tens place
    
    ls_spi l1
    (
    .clk_10M(clk_10),
    .SDO(SDO),
    .reset(reset),
    .SCLK(SCLK),
    .CS(CS),
    .ls_data(ls_data),
    .seg1(s_cnt1),
    .seg2(s_cnt2));
    
    // Draw the VGA display
    vga_display v1
    (
    .clk(clk_25),
    .reset(reset),
    .blank(blank),
    .h_count(h_count),
    .v_count(v_count),
    .data(ls_data),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b));
    
    // Instantiate seven segment module 
    seven_seg s1
    (
    .in({s_cnt2,s_cnt1,ls_data}),
    .clk(clk_10),
    .reset(reset),
    .seg(seg),
    .an(an));
    
endmodule