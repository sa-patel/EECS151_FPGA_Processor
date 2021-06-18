module icache(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h37050020;
30'h00000001: inst = 32'hb7050010;
30'h00000002: inst = 32'h370a0002;
30'h00000003: inst = 32'h130a3a09;
30'h00000004: inst = 32'hb79a1000;
30'h00000005: inst = 32'h938a3a09;
30'h00000006: inst = 32'h23204501;
30'h00000007: inst = 32'h23225501;
30'h00000008: inst = 32'h83220500;
30'h00000009: inst = 32'h03230500;
30'h0000000a: inst = 32'h33000000;
30'h0000000b: inst = 32'h33000000;
30'h0000000c: inst = 32'h33000000;
30'h0000000d: inst = 32'he7800500;
default:      inst = 32'h00000000;
endcase
end
endmodule
