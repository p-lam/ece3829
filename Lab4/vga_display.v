`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
// 
// Create Date: 10/10/2020 09:50:14 AM
// Design Name: 
// Module Name: vga_display
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Logic for the VGA display. An oscilloscope and some text are 
// written to the display. The oscilloscope is composed of a moving pixel 
// inside a blue border with an amplitude based on the light sensor value.
// The text is of my name and changes gradient according to the sensor.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_display (
    input             clk,           // 25MHz clock
    input             reset,         // Reset signal
    input             blank,         // Blank signal
    input     [10:0]  h_count,       // Horizontal count of the displayed pixel
    input     [10:0]  v_count,       // Vertical count of the displayed pixel
    input      [7:0]  data,          // Light sensor data
    output reg [3:0]  vga_r,         // Red VGA signal
    output reg [3:0]  vga_g,         // Green VGA signal
    output reg [3:0]  vga_b          // Blue VGA signal     
    );
    
    // Slow clock for the moving pixel
    reg[15:0] s_cnt;
    parameter MAX_COUNT_S = 48828 - 1; 
    wire move; 
    
    always @(posedge clk, posedge reset)
        if (reset)
            s_cnt <= 16'd0;
        else if (s_cnt == MAX_COUNT_S)
            s_cnt <= 16'd0;
        else 
            s_cnt <= s_cnt + 1'b1; 
    
    assign move = s_cnt == MAX_COUNT_S; 
    
    // Count pixels on x-axis until border is reached
    reg[9:0] hpos; 
    parameter MAX_COUNT_H = 512 - 1;
    
    always @(posedge clk, posedge reset)
        if (reset)
            hpos <= 0;
        else if (move) 
            if (hpos == MAX_COUNT_H)
                hpos <= 0; 
            else 
                hpos <= hpos + 1;
    
    // Maximum pixel count for the y-axis
    parameter MAX_COUNT_V = 256 - 1;
    
    // Text Display
    wire [3:0] text_addr;
    wire [2:0] font_col;
    wire p_bit, r_bit, u_bit, d_bit, e_bit, n_bit, c_bit;
    wire [7:0] pos_x;
    wire [5:0] pos_y;
    wire p_pos, r_pos, u_pos, d_pos, e_pos, n_pos, c_pos, e2_pos;
    wire p_char, r_char, u_char, d_char, e_char, n_char, c_char;
    
    reg [7:0] p, r, u, d, e, n, c;
    
    // Character fonts 8x16 pixels
    always @(text_addr)
        case (text_addr)
            4'h0: begin 
                p = 8'hFC;
                r = 8'hFC;
                u = 8'h82; 
                d = 8'hF8;
                e = 8'hFE;
                n = 8'hC2;
                c = 8'hFC;
                end
            4'h1: begin
                p = 8'h82;
                r = 8'h82;
                u = 8'h82;
                d = 8'h84;
                e = 8'h80;
                n = 8'hA2;
                c = 8'h80;
                end
            4'h2: begin 
                p = 8'h82;
                r = 8'h82;
                u = 8'h82;
                d = 8'h82;
                e = 8'h80;
                n = 8'hA2;
                c = 8'h80;
                end
            4'h3: begin 
                p = 8'h82;
                r = 8'h82;
                u = 8'h82;
                d = 8'h82;
                e = 8'h80;
                n = 8'h92;
                c = 8'h80;
                end
            4'h4: begin
                p = 8'hFC;
                r = 8'hFC;
                u = 8'h82;
                d = 8'h82;
                e = 8'hFC;
                n = 8'h92;
                c = 8'h80;
                end
            4'h5: begin
                p = 8'h80;
                r = 8'h90;
                u = 8'h82;
                d = 8'h82;
                e = 8'h80;
                n = 8'h8A;
                c = 8'h80;
                end
            4'h6: begin
                p = 8'h80;
                r = 8'h88;
                u = 8'h82;
                d = 8'h82;
                e = 8'h80;
                n = 8'h8A;
                c = 8'h80;
                end
            4'h7: begin
                p = 8'h80;
                r = 8'h84;
                u = 8'h82;
                d = 8'h84;
                e = 8'h80;
                n = 8'h86;
                c = 8'h80;
                end
            4'h8: begin 
                p = 8'h80;
                r = 8'h86;
                u = 8'hFE;
                d = 8'hF8;
                e = 8'hFE;
                n = 8'h82;
                c = 8'hFC;
                end
            default: begin 
                p = 8'h00; 
                r = 8'h00; 
                u = 8'h00; 
                d = 8'h00;
                e = 8'h00;
                n = 8'h00;
                c = 8'h00;
                end
        endcase 
        
    // Create an 80x30 array of characters
    assign pos_x = h_count[10:3];       // Character X position
    assign pos_y = v_count[9:4];        // Character Y position
    
    // Character positions
    assign p_pos = (pos_x == 70) && (pos_y == 8);
    assign r_pos = (pos_x == 71) && (pos_y == 8);
    assign u_pos = (pos_x == 72) && (pos_y == 8);
    assign d_pos = (pos_x == 73) && (pos_y == 8);
    assign e_pos = (pos_x == 74) && (pos_y == 8);
    assign n_pos = (pos_x == 75) && (pos_y == 8);
    assign c_pos = (pos_x == 76) && (pos_y == 8);
    assign e2_pos = (pos_x == 77) && (pos_y == 8);
    
    assign font_col = h_count[2:0];
    assign text_addr = v_count[3:0];
    
    assign p_bit = p[~font_col];
    assign r_bit = r[~font_col];
    assign u_bit = u[~font_col];
    assign d_bit = d[~font_col];
    assign e_bit = e[~font_col];
    assign n_bit = n[~font_col];
    assign c_bit = c[~font_col];
    
    assign p_char = p_pos & p_bit; 
    assign r_char = r_pos & r_bit;
    assign u_char = u_pos & u_bit; 
    assign d_char = d_pos & d_bit; 
    assign e_char = (e_pos | e2_pos) & e_bit; 
    assign n_char = n_pos & n_bit; 
    assign c_char = c_pos & c_bit; 
    
    // For the VGA display
    parameter BLACK = 12'b000000000000;
    parameter WHITE = 12'b111111111111;
    parameter BLUE = 12'b000000001111; 
    
    reg[11:0] disp;
    reg[11:0] color_change;
    
    // Changing text color according to light sensor data
    always @(posedge clk, posedge reset)
        if (reset) 
            color_change <= 12'b0;
        else
            // Extrapolate first 4 data bits over 12 bits to create gradient
            color_change <= {data[3:0],data[3:0],data[3:0]};
    
    // Draw the oscilloscope
    always @(blank, h_count, v_count, hpos, data, p_char, r_char, u_char, d_char, e_char, n_char, c_char, color_change)
        // Check if signal has been received
        if (blank)          
            disp <= BLACK;  
        // Parameters for the moving pixel
        else if (h_count == hpos && v_count == (MAX_COUNT_V - data))
            disp <= WHITE;
        // Draw the blue scope border
        else if ((h_count == MAX_COUNT_H && v_count >= 0 && v_count <= MAX_COUNT_V)|
                 (v_count == MAX_COUNT_V && h_count >= 0 && h_count <= MAX_COUNT_H))
            disp <= BLUE;
        // Draw text
        else if (p_char|r_char|u_char|d_char|e_char|n_char|c_char)
            disp <= color_change;
        else 
            disp <= BLACK;
            
    always @(disp)
        begin
            vga_r <= disp[11:8];      // Set signal for the red VGA signal
            vga_g <= disp[7:4];       // Set signal for the green VGA signal
            vga_b <= disp[3:0];       // Set signal for the blue VGA signal
        end 
    
    
endmodule
