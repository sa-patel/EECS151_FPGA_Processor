// UC Berkeley CS150
// Lab 3, Fall 2014
// Module: ALUdecoder
// Desc:   Sets the ALU operation
// Inputs: opcode: the top 6 bits of the instruction
//         funct: the funct, in the case of r-type instructions
//         add_rshift_type: selects whether an ADD vs SUB, or an SRA vs SRL
// Outputs: ALUop: Selects the ALU`s operation
//

`include "Opcode.vh"
`include "ALUop.vh"

module ALUdec(
  input [6:0]       opcode,
  input [2:0]       funct,
  input             add_rshift_type,
  output reg [3:0]  ALUop
);
  always@(*) begin
  	ALUop = `ALU_COPY_B;
	case(opcode)
		`OPC_LUI: ALUop = `ALU_COPY_B;
		`OPC_AUIPC, `OPC_STORE, `OPC_LOAD, `OPC_JAL, `OPC_JALR: ALUop = `ALU_ADD;
		`OPC_BRANCH:
			begin
				case(funct)
					`FNC_BEQ: ALUop = `ALU_EQ; // can be moved to branch ALU		
					`FNC_BNE: ALUop = `ALU_NE; // can be moved to branch ALU	
					`FNC_BLT: ALUop = `ALU_SLT;
					`FNC_BGE: ALUop = `ALU_GE; // can be moved to branch ALU
					`FNC_BLTU: ALUop = `ALU_SLTU; 
					`FNC_BGEU: ALUop = `ALU_GEU; // can be moved to branch ALU
				endcase
			end
		`OPC_ARI_ITYPE:
			begin
				case(funct)
					`FNC_ADD_SUB: ALUop = `ALU_ADD;
					`FNC_SLL: ALUop = `ALU_SLL;
					`FNC_SLT: ALUop = `ALU_SLT;
					`FNC_SLTU: ALUop = `ALU_SLTU;
					`FNC_XOR: ALUop = `ALU_XOR;
					`FNC_OR: ALUop = `ALU_OR;
					`FNC_AND: ALUop = `ALU_AND;
					`FNC_SRL_SRA:
						begin
							case(add_rshift_type)
								`FNC2_SRL: ALUop = `ALU_SRL;
								`FNC2_SRA: ALUop = `ALU_SRA; 
							endcase
						end
				endcase
			end
		`OPC_ARI_RTYPE:
			begin
				case(funct)  
					`FNC_ADD_SUB:
						begin
							case(add_rshift_type)
								`FNC2_ADD: ALUop = `ALU_ADD;
								`FNC2_SUB: ALUop = `ALU_SUB;
							endcase
						end
					`FNC_SLL: ALUop = `ALU_SLL;
					`FNC_SLT: ALUop = `ALU_SLT;
					`FNC_SLTU: ALUop = `ALU_SLTU;
					`FNC_XOR: ALUop = `ALU_XOR;
					`FNC_OR: ALUop = `ALU_OR;
					`FNC_AND: ALUop = `ALU_AND;
					`FNC_SRL_SRA:
						begin
							case(add_rshift_type)
								`FNC2_SRL: ALUop = `ALU_SRL;
								`FNC2_SRA: ALUop = `ALU_SRA; 
							endcase
						end
				endcase
			end
	endcase
   end		

endmodule
