module LineEngine(
  input                 clk,
  input                 rst,
  output                LE_ready,
  // 8-bit each for RGB, and 8 bits zeros at the top
  input [31:0]          LE_color,
  // 800 x 600 => 10 bits x 10 bits
  input [9:0]           LE_point,
  // Valid signals for the inputs
  input                 LE_color_valid,
  input                 LE_x0_valid,
  input                 LE_y0_valid,
  input                 LE_x1_valid,
  input                 LE_y1_valid,
  // Trigger signal - line engine should start drawing the line
  input                 LE_trigger,
  // FIFO connections
  input                 af_full,
  input                 wdf_full,
  
  output [30:0]         af_addr_din,
  output                af_wr_en,
  output [127:0]        wdf_din,
  output [15:0]         wdf_mask_din,
  output                wdf_wr_en
);
    reg [9:0] x0, y0, x1, y1, next_x0, next_y0, next_x1, next_y1;
    reg [31:0] color, next_color;

    wire [31:0] addr, regular_addr, flipped_addr;
    wire[31:0] write_mask_n;
    

    localparam IDLE     = 2'b00;
    localparam SETUP    = 2'b11;
    localparam WRITE1   = 2'b01;
    localparam WRITE2   = 2'b10;

    // Register the inputs:
    reg [127:0] color_reg;
    // state registers
    reg [1:0] cs, ns;
    reg steep;

    reg [15:0] write2_mask, write1_mask;

    reg [9:0] x, y;
    wire [9:0] delta_x, delta_y;
    reg [10:0] error;
    reg [10:0] next_error;
    wire [1:0] ystep;

    assign regular_addr[31:22] = 10'b0001000001;
    assign regular_addr[1:0] = 2'b00;
    assign regular_addr[21:2] = {y,x};

    assign flipped_addr[31:22] = 10'b0001000001;
    assign flipped_addr[1:0] = 2'b00;
    assign flipped_addr[21:2] = {x,y};

    assign addr = steep ? flipped_addr : regular_addr;

    assign write_mask_n = {4'hf, 28'b0} >> addr[4:0];
    assign delta_x = (x1 > x0)?(x1-x0):(x0-x1);
    assign delta_y = (y1 > y0)?(y1-y0):(y0-y1);
    assign ystep = (y0 < y1) ? 1 : -1; 

    always @(*) begin
        next_x0 = x0;
        next_y0 = y0;
        next_x1 = x1;
        next_y1 = y1;
        next_color = color;
        if (rst) begin
            next_x0 = 10'd0;
            next_y0 = 10'd0;
            next_x1 = 10'd0;
            next_y1 = 10'd0;
        end else if (LE_ready) begin
            if (LE_color_valid) begin
                next_color = LE_color;
            end

            if (LE_x0_valid) begin
                next_x0 = LE_point;
            end 

            if (LE_x1_valid) begin
                next_x1 = LE_point;
            end 

            if (LE_y0_valid) begin
                next_y0 = LE_point;
            end 

            if (LE_y1_valid) begin
                next_y1 = LE_point;
            end
        end else if (cs == SETUP) begin
            if ((delta_y > delta_x) && (y0 < y1)) begin
                next_x0 = y0;
                next_y0 = x0;
                next_x1 = y1;
                next_y1 = x1;
            end else if (delta_x >= delta_y && x0 > x1 ) begin
                next_x0 = x1;
                next_x1 = x0;
                next_y0 = y1;
                next_y1 = y0;
            end else if ((delta_y > delta_x) && y0 > y1) begin
                next_x0 = y1;
                next_x1 = y0;
                next_y0 = x1;
                next_y1 = x0;
            end
        end
    end

    always @(posedge clk) begin
        cs <= ns;
        y <= y;
        x <= x;
        x0 <= next_x0;
        y0 <= next_y0;
        y1 <= next_y1;
        x1 <= next_x1;
        color <= next_color;
        steep <= steep;
        if (rst) begin
            cs <= IDLE;
        end else begin
            if (cs == SETUP) begin
                steep <= (delta_y > delta_x);
                x <= next_x0;
                y <= next_y0;
                error <= ((next_x1 > next_x0)?(next_x1-next_x0):(next_x0-next_x1))/2;
            end else if (cs == WRITE2 && ns == WRITE1) begin
                x <= x + 1;
                error <= error - delta_y;
                if (next_error[10] == 1) begin
                    y <= y + {{8{ystep[1]}},ystep};
                    error <= (error - delta_y) + delta_x;
                end
            end
        end
    end

    // Transition Logic:
    always @(*) begin
        next_error = error - delta_y;
        case(cs)
            IDLE: ns = LE_trigger ? SETUP : IDLE;
            SETUP: ns = WRITE1;
            WRITE1: ns = !af_full && !wdf_full ? WRITE2: WRITE1;
            WRITE2: ns = !wdf_full ? ( (x == x1) ? IDLE: WRITE1 ) : WRITE2;
            default: ns = IDLE; 
        endcase
    end

    assign af_wr_en = cs == WRITE1;
    assign wdf_wr_en = cs == WRITE1 || cs == WRITE2;
    assign af_addr_din = {6'b0, addr[27:5], 2'b0};
    assign wdf_mask_din = cs == WRITE1 ? ~write_mask_n[31:16] : ~write_mask_n[15:0];
    assign wdf_din = {color,color,color,color};
    assign LE_ready = cs == IDLE;  

endmodule
