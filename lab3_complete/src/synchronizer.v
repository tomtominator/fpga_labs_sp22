`timescale 1ns/1ns


module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
); 
    
    reg [WIDTH-1:0] ff1;
    reg [WIDTH-1:0] ff2;

    always @(posedge clk) begin
        ff1 <= async_signal;
        ff2 <= ff1;
    end

    assign sync_signal = ff2;

    
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk
endmodule
