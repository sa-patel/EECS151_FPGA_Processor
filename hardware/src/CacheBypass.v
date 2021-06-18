
module CacheBypass( 
              input           clk,
              input           rst,
              input [31:0]    addr,
              input [31:0]    din,
              input [3:0]     we,
              input           af_full,
              input           wdf_full,
              
              output          stall,
              output [30:0]   af_addr_din, //x
              output          af_wr_en,
              output [127:0]  wdf_din, //x
              output [15:0]   wdf_mask_din, //x
              output          wdf_wr_en
);


    localparam IDLE     = 2'b00;
    localparam WRITE1   = 2'b01;
    localparam WRITE2   = 2'b10;

    // Register the inputs:
    reg [31:0] din_reg;
    reg [31:0] addr_reg;
    reg [3:0]  we_reg;

    // state registers
    reg [1:0] cs, ns;

    always @(posedge clk) begin
        if(rst) begin
            cs <= IDLE;
            din_reg <= 32'b0;
            addr_reg <= 32'b0;
            we_reg <= 4'b0;
        end
        else
            cs <= ns;

        if(ns == IDLE) begin
            din_reg <= din;
            addr_reg <= addr;
            we_reg <= we;
        end
    end

    // Transition Logic:
    always @(*) begin
        case(cs)
            IDLE: ns = |we_reg ? WRITE1 : IDLE;
            WRITE1: ns = !af_full && !wdf_full ? WRITE2: WRITE1;
            WRITE2: ns = !wdf_full ? IDLE : WRITE2;
           default: ns = IDLE; 
        endcase
    end

    wire [31:0] write_mask_n;
    assign write_mask_n = {we_reg, 28'b0} >> addr_reg[4:0];

    assign stall = ns != IDLE;
    assign af_wr_en = cs == WRITE1;
    assign wdf_wr_en = cs == WRITE1 || cs == WRITE2;
    assign af_addr_din = {6'b0, addr_reg[27:5], 2'b0};
    assign wdf_mask_din = cs == WRITE1 ? ~write_mask_n[31:16] : ~write_mask_n[15:0];
    assign wdf_din = {4{din_reg}}; 

endmodule
