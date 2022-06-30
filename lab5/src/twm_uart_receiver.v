module uart_receiver_twm #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter WIDTH = 8)
(
    input clk,
    input reset,

    output [WIDTH-1:0] data_out,
    output data_out_valid,
    input data_out_ready,

    input serial_in
);
    // See diagram in the lab guide
    localparam SYMBOL_EDGE_TIME = CLOCK_FREQ / BAUD_RATE;
    localparam SAMPLE_TIME = SYMBOL_EDGE_TIME / 2;
    localparam CLOCK_COUNTER_WIDTH= $clog2(SYMBOL_EDGE_TIME);

    wire symbol_edge;
    wire sample;
    wire start;
    wire rx_running;

    reg [WIDTH + 1:0] bits_recieved; // TODO: make 1 bit shorter to avoid waste (never use the last bit when serial line goes back high)
    reg [$clog2(WIDTH + 1):0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;
    reg received_word;

    //--|Signal Assignments|------------------------------------------------------

    // Goes high at every symbol edge
    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);

    // Goes high halfway through each symbol
    assign sample = clock_counter == SAMPLE_TIME;

    // Goes high when it is time to start receiving a new character
    assign start = !serial_in && !rx_running;

    // Goes high while we are receiving a character
    assign rx_running = bit_counter != 0;

    // Outputs
    assign data_out = bits_recieved[WIDTH:1];
    assign data_out_valid = received_word && !rx_running;

    
    always @ (posedge clk) begin
        // Sample Serial_in
        if (sample && rx_running) bits_recieved <= {serial_in, bits_recieved[WIDTH + 1:1]};


        // Counts cycles until a single symbol is done
        clock_counter <= (start || reset || symbol_edge) ? 0 : clock_counter + 1;
    
        // Counts down from WIDTH + 2 bits for every word recieved
        if (reset) begin
            bit_counter <= 0;
        end else if (start) begin
            bit_counter <= WIDTH + 2;
        end else if (symbol_edge && rx_running) begin
            bit_counter <= bit_counter - 1;
        end
    
    
        // Ready/Valid Interface
        if (reset) received_word <= 1'b0;
        else if (bit_counter == 1 && symbol_edge) received_word <= 1'b1;
        else if (data_out_ready) received_word <= 1'b0;
    end
endmodule
