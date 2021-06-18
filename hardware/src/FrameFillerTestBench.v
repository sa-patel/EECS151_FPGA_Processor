`timescale 1ns/1ps

module FrameFillerTestBench();

    reg Clock, Reset;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;
    reg fill_valid,af_full, wdf_full;
    wire wdf_wr_en, af_wr_en;
    reg [23:0] fill_color;
    wire [127:0] wdf_din;
    wire [30:0] af_addr_din;
    wire wdf_mask_din;
    wire fill_ready;
    reg [20:0] i;


    `ifdef RISCV_CLK_50
        parameter HalfCycle = 10;
    `endif `ifdef RISCV_CLK_100
       parameter HalfCycle = 5;
    `endif
    parameter Cycle = 2*HalfCycle;

    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;


    FrameFiller framefiller(
            .clk(Clock),
            .rst(Reset),
            .valid(fill_valid),
            .color(fill_color),
            .af_full(af_full),
            .wdf_full(wdf_full),
            .wdf_din(wdf_din),
            .wdf_wr_en(wdf_wr_en),
            .af_addr_din(af_addr_din),
            .af_wr_en(af_wr_en),
            .wdf_mask_din(wdf_mask_din),
            .ready(fill_ready));



    initial begin
        // Reset. Has to be long enough to not be eaten by the debouncer.
        Reset = 1;
        #(10*Cycle)
        Reset = 0;
        #(5*Cycle);


        // Wait until transmit is ready
        fill_color = 24'hff0000;
        fill_valid = 1'b1;
        af_full = 1'b0;
        wdf_full = 1'b0;
        #(Cycle);
        fill_valid = 1'b0;


        for (i = 0; i< 200000; i = i + 1) begin
            #(Cycle)
            if(framefiller.x == 792) begin
                $display("reached end of line %d", framefiller.y);
            end else if (framefiller.x == 800) begin
                $display("bad");
            end
            // if (i %500 == 0) begin
            //     $display("ready: %d" , fill_ready);
            //     $display("curr_writing: %d", framefiller.curr_writing);
            //     $display("cs: %d", framefiller.cs);
            //     $display("%d, %d", framefiller.x, framefiller.y);
            // end
        end
        $display("ready: %d", framefiller.ready);

        $finish();
    end

endmodule