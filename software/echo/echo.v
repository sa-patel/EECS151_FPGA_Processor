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
30'h00000004: inst = 32'h232e2700;
30'h00000005: inst = 32'h13010702;
30'h00000006: inst = 32'h13000000;
30'h00000007: inst = 32'h37080080;
30'h00000008: inst = 32'h03280800;
30'h00000009: inst = 32'h13782800;
30'h0000000a: inst = 32'he30a08fe;
30'h0000000b: inst = 32'h37080080;
30'h0000000c: inst = 32'h13084800;
30'h0000000d: inst = 32'h03280800;
30'h0000000e: inst = 32'ha30701ff;
30'h0000000f: inst = 32'h13000000;
30'h00000010: inst = 32'h37080080;
30'h00000011: inst = 32'h03280800;
30'h00000012: inst = 32'h13781800;
30'h00000013: inst = 32'he30a08fe;
30'h00000014: inst = 32'h37080080;
30'h00000015: inst = 32'h13088800;
30'h00000016: inst = 32'h8348f1fe;
30'h00000017: inst = 32'h23201801;
30'h00000018: inst = 32'h13000000;
30'h00000019: inst = 32'h6ff05ffb;
default:      inst = 32'h00000000;
endcase
end
endmodule
