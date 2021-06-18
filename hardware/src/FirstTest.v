//  Module: ALUTestVectorTestbench
//  Desc:   Alternative 32-bit ALU testbench for the MIPS150 Processor
//  Feel free to edit this testbench to add additional functionality
//  
//  Note that this testbench only tests correct operation of the ALU,
//  it doesn't check that you're mux-ing the correct values into the inputs
//  of the ALU. 

`timescale 1ns / 1ps

module FirstTest();


   


    reg Clock, Reset, Stall;
	reg [31:0] REFout;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    parameter Halfcycle = 10; //half period is 10ns

    localparam Cycle = 2*Halfcycle;

    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;

 	// Task for checking output
    task checkOutput;
        if ( REFout == cpu.ALU_out ) begin
        	$display("PASS");
        end
        else begin
        	$display("Fail: Incorrect result");
            $display("\tA: 0x%h, B: 0x%h, ALUout: 0x%h, REFout: 0x%h", cpu.A, cpu.B, cpu.ALU_out, REFout);
            $finish();
        end
    endtask

	task checkValues;
		input [31:0] value1;
		input [31:0] value2;
		if ( value1 != value2 ) begin
            $display("Fail: Incorrect result");
            $display("\tValue1: 0x%h, Value2: 0x%h", value1, value2);
            $finish();
        end
        else begin
            $display("PASS");
        end
    endtask
		 

 	Riscv151  cpu( .clk(Clock),
			.rst(Reset),
			.stall(Stall),
		    .FPGA_SERIAL_RX(  FPGA_SERIAL_RX),
			.FPGA_SERIAL_TX(  FPGA_SERIAL_TX));

	initial begin
	 	Stall = 0;
		Reset = 1;
		#(10*Cycle);
		Reset = 0;
		#(Cycle);// now rst_reg is 0
		REFout = 32'd7;
		checkOutput();
		#(Cycle);
		REFout = 32'd1;
		checkOutput();		
		#(Cycle);
		REFout = 32'd2;
		checkOutput();
		#(Cycle);
		REFout = 32'd8;
		checkOutput();
		#(Cycle);
		REFout = 32'd9;
		checkOutput();
		#(Cycle);
		REFout = 32'd10;
		checkOutput();
		#(2*Cycle);
		REFout = 32'h80000001;
		checkOutput();
		#(2*Cycle);
		REFout = 32'h80000020;
		checkOutput();
		#(2*Cycle);
		REFout = 32'd11;
		checkOutput();
		#(2*Cycle);
		REFout = 32'd72;
		checkOutput();
		#(7*Cycle);
		REFout = 32'd2;
		$display("Mem tests");
		checkOutput();
		#(Cycle);
		REFout = 32'd1;
		checkOutput();
	
		
		
	end



endmodule
