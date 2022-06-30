module counter (
  input clk,
  input ce,
  output [3:0] LEDS
);
  localparam cycles_in_second = 125000000;
  
    // Some initial code has been provided for you
    // You can change this code if needed
    reg [3:0] led_cnt_value;
    assign LEDS = led_cnt_value;

    reg [$clog2(cycles_in_second):0] cycle_cnt;
    // TODO: Instantiate a reg net to count the number of cycles
    // required to reach one second. Note that our clock period is 8ns.
    // Think about how many bits are needed for your reg.

    always @(posedge clk) begin
        // TODO: update the reg if clock is enabled (ce is 1).
        // Once the requisite number of cycles is reached, increment the count.
        if (ce) begin
          if (cycle_cnt > cycles_in_second) begin
            cycle_cnt <= 0;
            led_cnt_value = led_cnt_value + 1;
          end else begin
            cycle_cnt <= cycle_cnt + 1;
          end
        end else begin
          cycle_cnt <= cycle_cnt;
        end

    end
endmodule
