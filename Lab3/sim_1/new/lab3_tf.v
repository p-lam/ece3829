`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lm
//
// Create Date: 09/30/2020 01:10:07 PM
// Design Name:
// Module Name: lab3_tf
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Text fixture for lab 3
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module lab3_tf(
	);
  	//Clock
	reg clk;
    
	//Inputs
	reg SDO;
	reg reset;
    
	//Outputs
	wire SCLK;
	wire CS;
	wire [7:0] data;
    
    reg i;
    
	//Instantiate the UUT
	light_sensor ls_test (
    	.clk_10M(clk),
    	.SDO(SDO),
    	.reset(reset),
    	.SCLK(SCLK),
    	.CS(CS),
    	.ls_data(data));
    
	always
    	begin
    	clk = 0;
    	#50;
    	clk = 1;
    	#50;
    	end
   	        
	initial begin
	   //Initialize inputs
    	SDO = 1;
    	reset = 1;
    	#10;
    	
    	//Print header statement in console
    	$display("Testing Light Sensor Logic");
    	
    	//Begin testing
    	reset = 0;
 
    end
endmodule