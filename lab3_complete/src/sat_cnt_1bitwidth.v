module sat_cnt_1bitwidth #(parameter PULSE_CNT_MAX = 200, SATURATING_CNT_WIDTH= 10)(
    input pulse,
    input sync_signal,
    input clk,
    input reg [SAT_CNT_WIDTH-1:0] saturating_counter,
    output debounced_signal
);    
    
    always @(posedge clk) begin
        if (pulse && sync_signal) begin
            if (saturating_counter >= PULSE_CNT_MAX) begin
                saturating_counter <= saturating_counter;
            end else begin
                saturating_counter <= saturating_counter + 1;
            end
        end else begin
            saturating_counter <= 0;
        end
    end

    assign debounced_signal = saturating_counter >= PULSE_CNT_MAX ? 1'b1 : 1'b0;

endmodule