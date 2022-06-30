`timescale 1ns/1ns

module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output reg [WIDTH-1:0] edge_detect_pulse
);  

    reg [WIDTH-1:0] past_signal_in;

    always @(posedge clk) begin
        past_signal_in <= signal_in;

        if (past_signal_in != signal_in && signal_in) begin
            edge_detect_pulse <= past_signal_in ^ signal_in;
        end else begin
            edge_detect_pulse <= 0;
        end
    end 


    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like

endmodule
