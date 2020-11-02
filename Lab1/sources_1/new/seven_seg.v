`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 09/02/2020 05:36:03 PM
// Design Name: 
// Module Name: seven_seg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Module to display 0000 to FFFF on four seven-segment displays. 
// The value on the display is controlled by sixteen slider switches, four for each digit
// A clock is used to cycle through the digits for all four can seemingly appear
// An asynchronous reset signal depends on a pushbutton
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg(
    input     [15:0] in,              // 16-bit input 
    input            clk,             // 25 MHz Clock
    input            reset,
    output reg [6:0] seg,             // Output to seven-segment
    output reg [3:0] an               // Output to anodes
    );
    
    // For lab 4 seven segment displays
    parameter  MAX_COUNT = 2500 - 1;  // 25MHz to 10kHz
    reg [3:0]  sw;
    reg [1:0]  SEL = 2'b00;           // Initialize select 
    reg [20:0] cnt;                   // 21 bit register to store counter
    
    // Group the input into 4 bits for each digit
    wire [3:0] A, B, C, D;           
    assign A = in[3:0];
    assign B = in[7:4];
    assign C = in[11:8];
    assign D = in[15:12];
   
    always @(posedge clk, posedge reset)
        begin
            if (reset) begin                    // Asynchronous reset for counter
                cnt <= 0;
                SEL <= 0;
                end
            else if (cnt == MAX_COUNT) begin    
                cnt <= 0;                   
                SEL <= SEL + 1;                 // Increment SEL to assign state of switches to display
                end
            else                            
                cnt <= cnt + 1;                 
        end
    
    always @(SEL, A, B, C, D)
        begin
            case(SEL) 
                2'b00: begin  
                sw = A;       // Display value of switch A
                an = 4'b1110; // Since the anodes are at low logic level, shows value on first display
                end 
                2'b01: begin  
                sw = B;       // Display the value of switch B
                an = 4'b1101; //Use the second display
                end
                2'b10: begin  
                sw = C;       //Display value of switch C
                an = 4'b1011; //Use third display
                end
                2'b11: begin  
                sw = D;       //Display value of switch D
                an = 4'b0111; //Use fourth display
                end
            endcase 
        end
        
    //Define constants for seven segment display
    parameter zero = 7'b1000000;   //Display shows zero
    parameter one = 7'b1111001;    //Display shows one
    parameter two = 7'b0100100;    //Display shows two
    parameter three = 7'b0110000;  //Display shows three
    parameter four = 7'b0011001;   //Display shows four
    parameter five = 7'b0010010;   //Display shows five
    parameter six = 7'b0000010;    //Display shows six
    parameter seven = 7'b1111000;  //Display shows seven
    parameter eight = 7'b0000000;  //Display shows eight
    parameter nine = 7'b0010000;   //Display shows nine
    parameter disp_A = 7'b0001000; //Display shows A
    parameter disp_B = 7'b0000011; //Display shows B
    parameter disp_C = 7'b1000110; //Display shows C
    parameter disp_D = 7'b0100001; //Display shows D
    parameter disp_E = 7'b0000110; //Display shows E
    parameter disp_F = 7'b0001110; //Display shows F
    
    always @(sw)
        begin
            case(sw) //Depending on slider switches, display corresponding number
                4'b0000: seg = zero; 
                4'b0001: seg = one; 
                4'b0010: seg = two; 
                4'b0011: seg = three; 
                4'b0100: seg = four; 
                4'b0101: seg = five; 
                4'b0110: seg = six;
                4'b0111: seg = seven; 
                4'b1000: seg = eight;  
                4'b1001: seg = nine; 
                4'b1010: seg = disp_A;
                4'b1011: seg = disp_B; 
                4'b1100: seg = disp_C; 
                4'b1101: seg = disp_D; 
                4'b1110: seg = disp_E; 
                4'b1111: seg = disp_F;
                default: seg = zero;
            endcase
        end
        
endmodule
