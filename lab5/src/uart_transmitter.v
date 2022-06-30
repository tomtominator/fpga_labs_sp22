module uart_transmitter #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter WIDTH = 8)
(
    input clk,
    input reset,

    input [WIDTH-1:0] data_in,
    input data_in_valid,
    output reg data_in_ready,

    output reg serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
    //State variables
    localparam IDLE = 1'b0;
    localparam TRANSMIT = 1'b1;

    //Internal Wiring
    reg state;
    reg next_state;

    reg [CLOCK_COUNTER_WIDTH-1:0] symbol_edge_cnt;
    reg [$clog2(WIDTH):0] i; // For outputing which bit from the data_in (must count to >WIDTH)

    reg [WIDTH-1:0] data_in_reg;
    //End Internal Wiring

    //State transistion logic
    always @(*) begin
        if (reset) begin
            //Initialize During Reset
            serial_out = 1'b1;    //Outputs
            data_in_ready = 1; 

            next_state = IDLE;    //Internals 
        end else begin
            case (state) //State width 2 so no need for default state
                IDLE: begin
                    data_in_ready = 1'b1;
                    if (data_in_valid) begin
                        next_state = TRANSMIT;
                    end else begin
                        next_state = IDLE;
                    end
                    serial_out = 1'b1; // Hold serial_out high when no data to transfer
                end
                TRANSMIT: begin
                    data_in_ready = 1'b0;
                    if (i == 0) begin 
                        serial_out = 0; //Indicate start of word
                        next_state = TRANSMIT;
                    end else if (i == WIDTH + 1) begin 
                        serial_out = 1'b1; // Indicate completed transfer
                        //Hold for same amount of of time as the other bits, then immediately go to IDLE
                        //next cycle
                        if (symbol_edge_cnt == SYMBOL_EDGE_TIME - 1) begin 
                            next_state = IDLE;
                        end else begin
                            next_state = TRANSMIT;
                        end
                    end else begin
                        serial_out = data_in_reg[i-1]; // bits of word
                        next_state = TRANSMIT;
                    end
                end
            endcase
        end
    end

    //State update
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            i <= 0;
            data_in_reg <= 0;
            symbol_edge_cnt <= 0;
        end else begin 
            state <= next_state;

            //Generate pulse every SYMBOL_EDGE_TIME cycles
            if (state == TRANSMIT) begin
                if (symbol_edge_cnt >= SYMBOL_EDGE_TIME) begin
                    symbol_edge_cnt <= 0;
                    i <= i + 1;
                end else begin
                    symbol_edge_cnt <= symbol_edge_cnt + 1;
                end
            end else begin // Start counter only once we start transmitting
                symbol_edge_cnt <= 0;
                i <= 0;

            end

            //Capture Valid data on clk edge
            if (data_in_valid) begin
                data_in_reg <= data_in;
            end else begin
                data_in_reg <= data_in_reg;
            end
        end
    end


endmodule
