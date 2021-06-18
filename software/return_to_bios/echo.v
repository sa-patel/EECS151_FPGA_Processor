module echo(input clk, input rst, input [29:0] addr, output reg [31:0] inst);
reg [29:0] addr_r;
always @(posedge clk)
begin
addr_r <= (rst) ? (30'b0) : (addr);
end
always @(*)
begin
case(addr_r)
30'h00000000: inst = 32'h37070010;
30'h00000001: inst = 32'h13070704;
30'h00000002: inst = 32'hef004000;
30'h00000003: inst = 32'h130707fe;
30'h00000004: inst = 32'h232e1700;
30'h00000005: inst = 32'h232c2700;
30'h00000006: inst = 32'h13010702;
30'h00000007: inst = 32'h37080040;
30'h00000008: inst = 32'h232601ff;
30'h00000009: inst = 32'h0328c1fe;
30'h0000000a: inst = 32'h232401ff;
30'h0000000b: inst = 32'h032881fe;
30'h0000000c: inst = 32'he7000800;
30'h0000000d: inst = 32'h13080000;
30'h0000000e: inst = 32'h8320c701;
30'h0000000f: inst = 32'h03218701;
30'h00000010: inst = 32'h13070702;
30'h00000011: inst = 32'h67800000;
default:      inst = 32'h00000000;
endcase
end
endmodule
