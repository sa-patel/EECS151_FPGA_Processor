module FrameFiller(
    //system:
    input             clk,
    input             rst,
    // fill control:
    input             valid,
    input [23:0]      color,
    // ddr2 fifo control:
    input             af_full,
    input             wdf_full,
    // ddr2 fifo outputs:
    output [127:0]    wdf_din,
    output            wdf_wr_en,
    output [30:0]     af_addr_din,
    output            af_wr_en,
    output [15:0]     wdf_mask_din,
    // handshaking:
    output            ready);
    
    wire [31:0] addr;
    

    localparam IDLE     = 2'b00;
    localparam WRITE1   = 2'b01;
    localparam WRITE2   = 2'b10;

    // Register the inputs:
	reg [127:0] color_reg;
    reg curr_writing;
    // state registers
    reg [1:0] cs, ns;
    

	reg [9:0] x, y;

	
	// assign addr = {10’b0001000001, y, x, 2’b00};
    assign addr[31:22] = 10'b0001000001;
    assign addr[1:0] = 2'b00;
    assign addr[21:2] = {y,x};
	
	always @(posedge clk) begin
        color_reg <= color_reg;
		if (valid && ready) begin
			color_reg <= {8'b0, color, 8'b0, color, 8'b0, color, 8'b0, color};
        end
    end
			
			
    always @(posedge clk) begin
        if (rst) begin
            cs <= IDLE;
			x <= 10'b0;
			y <= 10'b0;
            curr_writing <= 1'b0;
        end else begin
            cs <= ns;
            y <= y;
            x <= x;
            curr_writing <= curr_writing;

    		if(cs == WRITE2 && ns == IDLE) begin
    			if (x < 792) begin //x can go up to 800	
                    x <= x + 8;
                    y <= y;
    			end else if (y < 599) begin
    				y <= y + 1;
    				x <= 0;
    			end else begin
                    curr_writing <= 1'b0;
                    x <= 0;
                    y <= 0;
                end
            end else if(valid && ready) begin
                curr_writing <= 1'b1;
            end
		end
    end

    // Transition Logic:
    always @(*) begin
        case(cs)
            IDLE: ns = (valid && ready) || curr_writing ? WRITE1 : IDLE;
            WRITE1: ns = !af_full && !wdf_full ? WRITE2: WRITE1;
            WRITE2: ns = !wdf_full ? IDLE : WRITE2;
           default: ns = IDLE; 
        endcase
    end

    assign af_wr_en = cs == WRITE1;
    assign wdf_wr_en = cs == WRITE1 || cs == WRITE2;
    assign af_addr_din = {6'b0, addr[27:5], 2'b0};
    assign wdf_mask_din = 16'd0;
    assign wdf_din = color_reg;
    assign ready = !curr_writing;

    // Remove these when you implement the frame filler
    // assign wdf_wr_en = 1'b0;
    // assign af_wr_en  = 1'b0;
    // assign ready     = 1'b1;


endmodule
