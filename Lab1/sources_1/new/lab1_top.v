`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 09/02/2020 09:18:45 PM
// Design Name: 
// Module Name: lab1_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top level module for lab 1. Uses the Basys3 board's first four LEDs to display the sum of 
// switch "a" and "b", the next eight to display the product, and the last four to display the last digit of 
// my WPI id number (six)
//   Input: Slider switches a, b, c, d 
//   Input: 2-bit input for two push-button switches
//   Output: 7-bit output to drive seven-segment 
//   Output: Four 1-bit anodes to drive the four anodes
//   Output: 16-bit output for LEDs
//   
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab1_top(
    input [3:0] a, //Input slider switches a, b, c, d
    input [3:0] b,
    input [3:0] c,
    input [3:0] d,
    input [1:0] sel, //2-bit input for pushbuttons
    output [6:0] seg, //Outputs to seven segment display
    output [3:0] an,  //Four 1-bit anodes to drive the four anodes
    output [15:0] led //Outputs to 16 LEDs
    );
    
    //Instantiate the seven segment module 
    seven_seg s1 (.A(a), //
                  .B(b),
                  .C(c), .D(d), .SEL(sel), .seg(seg), .an(an));
    
    //The first four LEDs display the value of input "a" and "b"
    assign led[3:0] = a + b;
    
    //The next eight LEDs display the value of input "a" times input "b"
    assign led[11:4] = a * b;
    
    //The last four LEDs display the last digit of my WPI ID number
    parameter id_last_digit = 4'b0110; //Set as 6
    
    assign led[15:12] = id_last_digit;
    
endmodule
