`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Worcester Polytechnic Institute
// Engineer: Prudence Lam
//
// Create Date: 10/03/2020 12:36:34 PM
// Design Name:
// Module Name: light_sensor
// Project Name:
// Target Devices:
// Tool Versions:
// Description: SPI interface for the Ambient Light Sensor. A reading
// is taken every 10 Hz. Multiple counters were used to keep track of the signals. 
// A Finite State Machine acted as a control for CS and the shift register. 
// At the end of 16 SCLK cycles, the important 8 bits are extracted and outputted to display.
// Two seven segments are used to count the number of samples taken
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module ls_spi(
    input            clk_10M,                 // 10MHz clock from mmcm
    input            SDO,                     // Master-In-Slave-Out
    input            reset,                   // Global reset
    output           SCLK,                    // CLK
    output           CS,                      // Chip select
    output reg [7:0] ls_data,                 // Light sensor data
    output reg [3:0] seg1,                    // Store ones place of sample count
    output reg [3:0] seg2                     // Store tens place of sample count
    );
    
    reg [3:0]  cnt_1M;                        // Counter to divide 10MHz to 1MHz
    reg [16:0] cnt_10;                        // Counter to divide 1MHz to 10Hz
    reg [14:0] q;                             // 15-bit shift register for light sensor data
    reg [1:0]  current_state, next_state;     // Finite state machine states
    reg [4:0]  cnt_16;                        // Counter to count 16 SCLK cycles
    
    wire en_disp;                             // Signal to output light sensor data to display
    wire start_shift;                         // Enable signal for shift register
    
    parameter MAX_COUNT_1M = 10 - 1;
    parameter MAX_COUNT_10 = 100_000 - 1;
    parameter MAX_COUNT_16 = 16;
    parameter [1:0] s0 = 2'b00,               // Read light sensor data
                    s1 = 2'b01,               // Write to display
                    s2 = 2'b11;               // Wait 10Hz
                    
                    
    // SCLK is at 1MHz
    always @(posedge clk_10M, posedge reset)
        if (reset)
            cnt_1M <= 0;
        else
            if (cnt_1M == MAX_COUNT_1M)
                cnt_1M <= 0;
            else
                cnt_1M <= cnt_1M + 1;
    
    assign SCLK = (cnt_1M <= 4);             
    wire SCLK_en = cnt_1M == 0;               
    
    // Counter to wait 10Hz before reading from the sensor
    always @(posedge clk_10M, posedge reset)
        if (reset)
            cnt_10 <= 0;
        else if (cnt_1M == MAX_COUNT_1M)
            if (cnt_10 == MAX_COUNT_10)
                cnt_10 <= 0;
            else
                cnt_10 <= cnt_10 + 1;
    
    // Finite state machine for light sensor reading
    always @(posedge clk_10M, posedge reset)
        if (reset)
            current_state <= s0;
        else
            current_state <= next_state;
    
    always @(current_state, en_disp, cnt_10)
        case (current_state)
            s0: if (en_disp)                        //Wait for control
                    next_state = s1;            
                else
                    next_state = s0;
            s1: next_state = s2;                    //Display data on seven segment
            s2: if (cnt_10 == MAX_COUNT_10)         //Wait for 10 Hz
                    next_state=s0;
                else
                    next_state=s2;
            
        endcase
    
    // Begin shifting into shift register
    assign start_shift = (current_state == s0 && cnt_1M == 5);
    
    // Generate CS signal
    assign CS = (current_state != s0); 
    
    // Counter to count 16 cycles of SCLK
    always @(posedge clk_10M, posedge reset)
        if (reset) begin
            cnt_16 <= 0;
            q <= 15'b0;
            end
        else 
            if(current_state!=s0)
                cnt_16 <=0;
            else if (start_shift) 
                begin
                    q <= {q[13:0], SDO};         //Load data from sensor 
                    cnt_16 <= cnt_16 + 1'b1;        
                end
            
    assign en_disp = (cnt_16 == MAX_COUNT_16);  
    
    // Display logic 
    always @(posedge clk_10M, posedge reset)
        if (reset)
            ls_data <= 8'b0;
        else if (current_state==s1)
            ls_data <= q[11:4];                 //Extract the important eight bits

    // Sample count 
    always @(posedge clk_10M, posedge reset)
        if (reset) begin 
            seg1 <= 4'b0;
            seg2 <= 4'b0;
            end 
        else if (current_state == s1)
            // Number on seg1 depends on seg2
            if (seg1 == 4'd9) 
                begin
                    seg1 <= 4'b0; 
                    if (seg2 == 4'd9) 
                        seg2 <= 0;
                    else 
                        seg2 <= seg2 + 1;
                end 
            else 
                seg1 <= seg1 + 1'b1; 
            
endmodule
