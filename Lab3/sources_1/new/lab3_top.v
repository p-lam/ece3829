`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
//
// Create Date: 09/29/2020 03:58:33 PM
// Design Name:
// Module Name: lab3_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Top module for lab 3. Includes the SPI interface for the Ambient Light Sensor,
// and outputs the received data, along with the last two digits of my WPI ID, to 
// the four seven segment displays. 
// The seven segment module is derived from previous labs.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module lab3_top(
	input clk_fpga,              //100 MHz clock
	input reset,                 //Global reset
	input SDO,                   //Master-In-Slave-Out
	output SCLK,                 //Series clock
	output CS,                   //Chip select
	output [6:0] disp,           //Output to seven-segment
	output [3:0] an              //Output to anodes
	);
    
	wire [7:0] ls_data;      	 //8 bits for light sensor data
	wire [15:0] seg_data;        //16 bit data bus for seven segment displays
    
    //Last two digits of WPI ID
	parameter nine = 4'b1001;   
	parameter six = 4'b0110;
    
	clk_wiz_0 mmcm               //Create a 10MHz signal from 100MHz
   	(
    	// Clock out ports
    	.clk_out1(clk_10M), 	// output clk_out1
    	// Status and control signals
    	.reset(reset), // input reset
    	.locked(locked),    	// output locked
   	// Clock in ports
    	.clk_in1(clk_fpga));	// input clk_in1
    
	light_sensor ls1
    	(
     	.clk_10M(clk_10M),
     	.SDO(SDO),
     	.reset(reset),
     	.SCLK(SCLK),
     	.CS(CS),
     	.ls_data(ls_data));
    
    //Create a 16-bit bus with all the data to display
	assign seg_data = {nine, six, ls_data};
    
	seven_seg ss1
    	(
    	.in(seg_data),
    	.clk(clk_10M),
    	.reset(reset),
    	.seg(disp),
    	.an(an));

endmodule