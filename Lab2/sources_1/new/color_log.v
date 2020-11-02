`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 09/10/2020 01:38:19 PM
// Design Name: 
// Module Name: color_log
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Uses three selection switches (3 bits) to determine the pattern on the VGA display (640x480)

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module color_log(
    input [10:0] h_count,        // Horizontal count of the displayed pixel
    input [10:0] v_count,        // Vertical count of the displayed pixel
    input blank,                 // Blank signal
    input [2:0] SEL,             // Selection switches
    input clk,                   // 1 Hz clock
    output reg [3:0] vga_red,    // Red VGA signal
    output reg [3:0] vga_green,  // Green VGA signal
    output reg [3:0] vga_blue    // Blue VGA signal
    );
    
    reg [11:0] disp_color;       // Current pattern on the VGA display
    reg [4:0] x_counter;         // Store the x parameter of the moving block
    reg [3:0] y_counter;         // Store the y parameter of the moving block
    wire      counter_en;        // Enable signal after x counter reaches max count
    
    parameter RED = 12'b111100000000;    // Displays a red screen on the VGA
    parameter GREEN = 12'b000011110000;  // Displays a green screen on the VGA
    parameter BLUE = 12'b000000001111;   // Displays a blue screen on the VGA
    parameter YELLOW = 12'b111111110000; // Displays a yellow screen on the VGA
    parameter BLACK = 12'b000000000000;  // Displays a black screen on the VGA
    parameter WHITE = 12'b111111111111;  // Displays a white screen on the VGA
    
    always @ (posedge clk)
        x_counter <= (x_counter == 19) ? 0 : x_counter + 1'b1; // x counter counts to 19
    
    assign counter_en = x_counter == 19; // Set enable to high when x_counter reaches max count
    
    always @ (posedge clk) 
        if (counter_en) 
            y_counter <= (y_counter == 14) ? 0 : y_counter + 1'b1; // y counter counts to 14
    
    always @ (SEL or blank or h_count or v_count or y_counter or x_counter)
        begin
            if (blank)
                disp_color <= BLACK; 
            else
                if (SEL == 3'b000)          // If no switches are on
                    disp_color <= GREEN;    // Displays a green screen
                else if (SEL == 3'b001)     // First switch is on
                    disp_color <= (h_count[4] == 1) ? RED : YELLOW;  //Displays red and yellow stripes, 16 pixels wide
                else if (SEL == 3'b010)     // Second switch is on
                    if (h_count <= 639 && h_count >= (639-64) && v_count <= 63 && v_count >= 0) 
                        //Displays a 64x64 blue box on the top right
                        disp_color <= BLUE;
                    else
                        disp_color <= BLACK;
                else if (SEL == 3'b011)     // Third switch is on
                     if (h_count >= 0 && h_count <= 31 && v_count <= 31 && v_count >= 0) 
                        //Displays a 32x32 white box on the top left
                        disp_color <= WHITE;
                    else
                        disp_color <= BLACK;
                else if (SEL == 3'b100)     // Fourth switch is on
                    // Counters are multiplied by 32 for 32x32 block to move across the entire screen
                    // Once the block reaches the end of the screen horizontally, it wraps around but starts one down vertically
                     disp_color <= (h_count < (32*x_counter) + 32) && h_count >= (32*x_counter) && 
                                    v_count < ((32*y_counter) + 32) && v_count >= (32*y_counter) ? WHITE : BLACK;             
        end      
        
   always @ (disp_color)
        begin 
            vga_red <= disp_color[11:8];    // Set signal for the red VGA signal
            vga_green <= disp_color[7:4];   // Set signal for the green VGA signal
            vga_blue <= disp_color[3:0];    // Set signal for the blue VGA signal
        end 
        
endmodule
