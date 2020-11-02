`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2020 02:39:36 PM
// Design Name: 
// Module Name: vga_scope
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VGA display (640x480)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_scope(
    input clk,                      // 25MHz clock
    input reset,                    // Reset signal
    input blank,                    // Blank signal
    input [10:0] h_count,           // Horizontal count of the displayed pixel
    input [10:0] v_count,           // Vertical count of the displayed pixel
    output reg [3:0] vga_red,       // Red VGA signal
    output reg [3:0] vga_green,     // Green VGA signal
    output reg [3:0] vga_blue       // Blue VGA signal
    );
    
    // Counter to keep track of seconds 
    reg[24:0] cnt_1; 
    parameter MAX_COUNT_1 = 48828 - 1;
    wire en_1Hz; 
    
    always @(posedge clk) 
        if (reset) 
            cnt_1 <= 25'd0; 
        else if (cnt_1 == MAX_COUNT_1) 
            cnt_1 <= 25'd0;
        else 
            cnt_1 <= cnt_1 + 1;
    
    assign en_1Hz = cnt_1 == MAX_COUNT_1; 
    
    // Counter to move a white pixel 
    reg [4:0] x_counter;
    
    always @(posedge clk) 
        if (reset)
            x_counter <= 0; 
        else if (en_1Hz) 
            if (x_counter == 511) 
                x_counter <= 0;
            else 
                x_counter <= x_counter + 1'b1;
            
    // Draw the VGA display
    parameter BLACK = 12'b000000000000;     // Displays a black screen on the VGA
    parameter BLUE = 12'b000000001111;      // Displays a blue screen on the VGA
    parameter WHITE = 12'b111111111111;
    
    reg[11:0] disp;                         // Display on VGA
    
    // Draw the border, 512x256
    always @(blank, h_count, v_count) 
        if (blank) 
            disp <= BLACK; 
        else 
            if (h_count >= 0 && h_count <= 511 && v_count >= 0 && v_count <= 255)
                disp <= BLUE;               
            else 
                disp <= BLACK;
     
     // Moving block
     always @(blank, h_count, x_counter) 
        if (blank) 
            disp <= BLACK; 
        else 
            if (h_count == x_counter) 
                disp <= WHITE;               
            else 
                disp <= BLACK;
    
    always @ (disp)
        begin
            vga_red <= disp[11:8];      // Set signal for the red VGA signal
            vga_green <= disp[7:4];     // Set signal for the green VGA signal
            vga_blue <= disp[3:0];      // Set signal for the blue VGA signal
        end
endmodule
