module z1top #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 1_000_000
)(
    input CLK_100MHZ_FPGA,
    input [3:0] BUTTONS,
    input [1:0] SWITCHES,
    output [5:0] LEDS,
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);
    wire rst;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire data_in_valid, data_in_ready, data_out_valid, data_out_ready;

    // This UART is on the FPGA and communicates with your desktop
    // using the FPGA_SERIAL_TX, and FPGA_SERIAL_RX signals. The ready/valid
    // interface for this UART is used on the FPGA design.
    uart # (
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .WIDTH(8)
    ) on_chip_uart (
        .clk(CLK_100MHZ_FPGA),
        .reset(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .serial_in(FPGA_SERIAL_RX),
        .serial_out(FPGA_SERIAL_TX)
    );

    // This is a small state machine that will pull a character from the uart_receiver
    // over the ready/valid interface, modify that character, and send the character
    // to the uart_transmitter, which will send it over the serial line.

    // If a ASCII letter is received, its case will be reversed and sent back. Any other
    // ASCII characters will be echoed back without any modification.
    // a = 97
    reg has_char;
    reg [7:0] char;
    reg [31:0] past_4_bytes;
    reg [1:0] i;

    always @(posedge CLK_100MHZ_FPGA) begin
        if (rst) has_char <= 1'b0;
        else has_char <= has_char ? !data_in_ready : data_out_valid;
    end

    always @(posedge CLK_100MHZ_FPGA) begin
        if (!has_char) char <= data_out;
        if (has_char) past_4_bytes = {past_4_bytes[23:0], char};
    end

    always @ (*) begin
        if (char >= 8'd65 && char <= 8'd90) data_in = char + 8'd32;
        else if (char >= 8'd97 && char <= 8'd122) data_in = char - 8'd32;
        else data_in = char;
    end

    assign data_in_valid = has_char;
    assign data_out_ready = !has_char;
endmodule
