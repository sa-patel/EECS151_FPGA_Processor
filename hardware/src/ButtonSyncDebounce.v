module ButtonSyncDebounce(
  input button,
  input clk,
  input rst,
  output debounced
);

  // Synchronize the button
  reg [2:0] button_sr;

  always@ (posedge clk) begin
    button_sr <= {button_sr[1:0], button};
  end

  // Debounce the button
  localparam DEB_DUR = 1000000;
  reg [20:0] cnt;

  always@ (posedge clk) begin

    if(rst)
      cnt <= 0;

    // If button pressed, increment the count
    else if(button_sr[2]) begin
      if(cnt < 2*DEB_DUR)
        cnt <= cnt + 1;
    end

    // If button not pressed, decrease the count
    else begin
      if(cnt > 0)
        cnt <= cnt - 1;
    end
  end

  assign debounced = (cnt > DEB_DUR);

endmodule
