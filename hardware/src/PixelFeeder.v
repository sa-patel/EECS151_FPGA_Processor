/* This module keeps a FIFO filled that then outputs to the DVI module. */

module PixelFeeder( //System:
                    input          cpu_clk_g,
                    input          clk50_g,
                    input          rst,
                    //DDR2 FIFOS:
                    input          rdf_valid,
                    input          af_full,
                    input  [127:0] rdf_dout,
                    output         rdf_rd_en,
                    output         af_wr_en,
                    output [30:0]  af_addr_din,
                    // DVI module:
                    output [23:0]  video,
                    output         video_valid,
                    input          video_ready,
                    output         dvi_rst);

    // states:
    localparam IDLE = 1'b0;
    localparam FETCH = 1'b1;

    // wires for the FIFO signals
    wire [31:0] feeder_dout;
    wire        feeder_full;
    wire        feeder_empty;
    
    // counter for the fifo (not using built in because we need to increment 
    // based on requests sent. The FIFO can hold 8188 pixels (count has extra
    // bit for overflow)
    reg  [13:0] buffered_count;
    reg  [13:0] actual_count;
    reg  [31:0] ignore_count;

    // fsm register:
    reg    current_state;
    reg    next_state;
    wire [30:0] current_address;
    reg [9:0] y;
    reg [6:0] x; //Chop off bottom 3 bits of y because there are 8 pixels in a request (log_2(8) = 3)

    // Use x as lower bits because screen draws top down starting from the top
    // right corner
    assign current_address = {6'b0, 6'b1, y, x, 2'b0};
    //wire in_fifo_max;
    wire request_max;
    assign request_max = buffered_count > 14'd8000;
    reg has_been_rst;
    reg video_ready_cpu_clk;
    reg video_ready_reg;

    // State transition logic:
    always @(*) begin
        `ifdef DEBUG
          $display("(%d, %d)", x, y);
        `endif
        case(current_state)
            IDLE: next_state = request_max ? IDLE : FETCH;
            FETCH: next_state = !request_max ? FETCH : IDLE;
        endcase
    end


    // synchronous logic:
    always @(posedge cpu_clk_g) begin
        if(rst)
            current_state <= IDLE;
        else
            current_state <= next_state;

        // x and y logic: if in the FETCH state, and address FIFO has space,
        // increment x and y (with wrapping)
        if(rst) begin
            x <= 7'd0;
            y <= 10'd0;
        end
        else if(current_state == FETCH && !af_full) begin
          // - 1 because we are 0 indexing
            if(y == 10'd599 && x == 7'd99) begin
                x <= 7'b0;
                y <= 10'b0;
            end 
            else begin
                if(x == 7'd99) begin
                    x <= 7'b0;
                    y <= y + 10'b1;
                end
                else begin
                    x <= x + 7'b1;
                    y <= y;
                end
            end
        end else begin
            x <= x;
            y <= y;
        end

        // video_ready is clocked at 50MHz, while the CPU clock can run at either
        // 50 or 100 MHz. If the CPU runs at 100MHz, cpu_clk will be twice the rate       
        // at which video_ready is clocked. In this case, we need to generate a
        // video_ready_cpu_clk signal, which only goes high every second cycle
        video_ready_reg <= video_ready;
        if(rst)
            video_ready_cpu_clk <= 0;
        else
        `ifdef RISCV_CLK_50
            video_ready_cpu_clk <= video_ready;
        `endif `ifdef RISCV_CLK_100
            video_ready_cpu_clk <= video_ready_cpu_clk + video_ready_reg;
        `endif

        // Actual count logic: keeps track of the actual number of 32-bit words in the FIFO.
        // Each time rdf_valid goes high, 4 words (128 bits) are loaded into the FIFO.
        // Each time that video_ready goes high, one word is removed from the FIFO.
        if(rst)
            actual_count <= 14'b0;
        else if(rdf_valid && (video_ready_cpu_clk && has_been_rst))
            actual_count <= actual_count + 14'd4 - 14'd1;
        else if(rdf_valid)
            actual_count <= actual_count + 14'd4;
        else if(video_ready_cpu_clk && has_been_rst)
            actual_count <= actual_count - 14'd1;
        else 
            actual_count <= actual_count;

        // Buffered count logic: keeps track of requested addresses
        // Buffered count is number of 32-bit words that are already in the FIFO, or
        // that have been requested from DRAM and will soon be loaded into FIFO.
        // Each address requests 256 bytes (8 words) at a time.
        if(rst) 
            buffered_count <= 14'b0;
        else if(!af_full && af_wr_en && (video_ready_cpu_clk && ignore_count == 32'b0))
            buffered_count <= buffered_count + 14'd8 - 14'd1;
        else if(!af_full && af_wr_en)
            buffered_count <= buffered_count + 14'd8;
        else if(video_ready_cpu_clk && ignore_count == 32'b0)
            buffered_count <= buffered_count - 14'd1;
        else
            buffered_count <= buffered_count;
    end

    // synchronous logic for ignore count
    // This writes 800x600 black pixels to the DVI driver
    // before it starts fetching pixels from the DRAM
    always @(posedge clk50_g) begin
        if(dvi_rst)
            ignore_count <= 32'd480000;
        else if(video_ready && ignore_count != 32'b0)
            ignore_count <= ignore_count - 32'b1;
        else
            ignore_count <= ignore_count;
    end

    // assignments:
    assign rdf_rd_en = 1'b1;
    assign af_wr_en = current_state == FETCH;
    assign af_addr_din = current_address;

    /* we want to assert rst for the DVI module once we've buffered a certain 
       amount of pixels in order to sync the output. */
    always @(posedge cpu_clk_g) begin
       if(rst)
            has_been_rst <= 1'b0;
       else if(has_been_rst || actual_count > 14'd256)
            has_been_rst <= 1'b1;
       else
            has_been_rst <= has_been_rst;
    end

    // FIFO to buffer the reads with a write width of 128 and read width of 32. We try to fetch blocks
    // until the FIFO is full.
    pixel_fifo feeder_fifo(
    	.rst(rst),
    	.wr_clk(cpu_clk_g),
    	.rd_clk(clk50_g),
    	.din(rdf_dout),
    	.wr_en(rdf_valid),
    	.rd_en(video_ready && ignore_count == 32'b0),
    	.dout(feeder_dout),
    	.full(feeder_full),
    	.empty(feeder_empty));

    assign video = feeder_dout[23:0];
    assign video_valid = 1;
    assign dvi_rst = !has_been_rst;

endmodule
