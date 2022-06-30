`timescale 1ns/1ns


module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    //Synchronize Signal (glitchy signal has been synchronized when entering debouncer)
    //wire [WIDTH-1:0] sync_signal;
    //synchronizer #(.WIDTH(WIDTH)) syncr(.async_signal(glitchy_signal), .clk(clk), .sync_signal(sync_signal));

    localparam WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX);
    localparam SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1;

    //Pulse Generator
    reg [WRAPPING_CNT_WIDTH:0] pulse_cnt = 0;
    reg pulse;
    always @(posedge clk) begin
        pulse_cnt <= pulse_cnt + 10;
        if (pulse_cnt > SAMPLE_CNT_MAX) begin
            pulse <= 1'b1;
            pulse_cnt <= 0;
        end else begin
            pulse <= 1'b0;
        end
    end


    //Saturating counter
    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
    //give saturating_counter an initial state
    integer k;
    initial begin
        for (k = 0; k < WIDTH; k = k + 1) begin
            saturating_counter[k] = 0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i +1) begin : add_sat_cnter
            always @(posedge pulse) begin
                if (glitchy_signal[i]) begin //changed from sync_signal after removal of synchronizer within debouncer
                    if (saturating_counter[i] >= PULSE_CNT_MAX) begin
                        saturating_counter[i] <= saturating_counter[i];
                    end else begin
                        saturating_counter[i] <= saturating_counter[i] + 1;
                    end
                end else begin
                    saturating_counter[i] <= 0;
                end
            end
        end
    endgenerate
    

    //Assign debounced signal from saturating_counter
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sig_assigning
            assign debounced_signal[i] = saturating_counter[i] >= PULSE_CNT_MAX ? 1'b1 : 1'b0;
        end
    endgenerate

    /*
    no work
    //Saturating counter
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_sat_counters
            sat_cnt_1bitwidth #(.PULSE_CNT_MAX(PULSE_CNT_MAX), 
                                .SATURATING_CNT_WIDTH(SATURATING_CNT_WIDTH)) 
            sat_cnter(.clk(clk), 
                    .pulse(pulse), 
                    .sync_signal(sync_signal[i]),
                    .saturating_counter(saturating_counter[i]),
                    .debounced_signal(debounced_signal[i]));
        end
    endgenerate
    */

    
endmodule
