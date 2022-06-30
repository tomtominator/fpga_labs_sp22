`timescale 1ns/1ns

`define CYCLES_PER_SECOND 125_000_000
`define CLK_PERIOD 8

// This testbench checks that your debouncer smooths-out the input signals properly. Refer to the spec for details.

module counter_tb();
    // Generate 125 MHz clock
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // I/O of counter
    wire ce;
    reg [3:0] buttons;
    wire [3:0] leds;

    counter #(
        .CYCLES_PER_SECOND(`CYCLES_PER_SECOND)
    ) DUT (
        .clk(clk),
        .ce(ce),
        .buttons(buttons),
        .leds(leds)
    );

    initial begin
        integer i = 0;
        buttons = 4'b0000;
        repeat (5) @(posedge clk);
        #1;

        repeat(12) begin
            buttons = 4'b0001;
            i <= i + 1;
            #1;
            assert(leds == i) else $display("Not counting properly");
        end

        $display("Done!");
        $finish();
    end
endmodule
