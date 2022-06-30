`timescale 1ns/1ns
`define CLK_PERIOD 10


module z1top_tb();
    // Generate 100 MHz clock
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    localparam integer B_SAMPLE_CNT_MAX = $rtoi(0.0005 * 100_000_000);
    localparam integer B_PULSE_CNT_MAX = $rtoi(0.100 / 0.0005);

    // I/O of bp + counter
    reg [3:0] buttons;
    wire [1:0] switches;
    wire [5:0] leds;

    z1top DUT (
        .CLK_125MHZ_FPGA(clk),
        .BUTTONS(buttons),
        .SWITCHES(switches),
        .LEDS(leds)
    );

    initial begin
        buttons = 4'd0;
        #(`CLK_PERIOD * 5);
        buttons = 4'd1;
        #(`CLK_PERIOD * B_SAMPLE_CNT_MAX * B_PULSE_CNT_MAX * 2);
        buttons = 4'd4;
        #(`CLK_PERIOD * B_SAMPLE_CNT_MAX * B_PULSE_CNT_MAX * 2);
        buttons = 4'd0;
        #(`CLK_PERIOD * 5);

        $display("Done!");
        $finish();
    end


endmodule
