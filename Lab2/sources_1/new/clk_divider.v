`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/13/2020 04:17:07 PM
// Design Name:
// Module Name: clk_divider
// Project Name: 
// Target Devices:
// Tool Versions:
// Description: Outputs a signal every 1Hz given a 25 MHz clock
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module clk_divider(
    input clk_in,                           // 25 MHz clock
    input reset,                            // Asynchronous reset for counter
    output clk_out                          // 1 Hz clock
    );

    reg[24:0] cnt = 25'd0;                  // 25 bits to store 25e6, as 25MHz/25e6 = 1Hz
    parameter MAX_COUNT = 25000000 - 1;

    always @(posedge clk_in)
    begin
        if (reset)
            cnt <= 25'd0;
        else if (cnt == MAX_COUNT)          // When MAX_COUNT is reached
            cnt <= 25'd0;                   // Reset the counter
        else
            cnt = cnt + 1;                  // Else increment the counter
    end

    assign clk_out = (cnt == MAX_COUNT)

endmodule
