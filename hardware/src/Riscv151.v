/**
 * Top-level module for the RISCV processor.
 * This should contain instantiations of your datapath and control unit.
 * For CP1, the imem and dmem should be instantiated in this top-level module.
 * For CP2 and CP3, the memories are moved to a different module (Memory151),
 * and connected to the datapath via memory ports in the RISC I/O interface.
 *
 * EECS151 Fall 15. Template written by Simon Scott.
 */

`include "Opcode.vh"
`include "ALUop.vh"

module Riscv151(
    input clk,
    input rst,
    input stall,

    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX

    // Memory system ports
    // Only used for checkpoint 2 and 3
`ifdef EECS151_CHKPNT_2_OR_3
    ,
    output [31:0]  dcache_addr,
    output [31:0]  icache_addr,
    output [3:0]   dcache_we,
    output [3:0]   icache_we,
    output         dcache_re,
    output         icache_re,
    output [31:0]  dcache_din,
    output [31:0]  icache_din,
    input  [31:0]  dcache_dout,
    input  [31:0]  instruction
`endif

    // Graphics ports
    // Only used for checkpoint 3
`ifdef EECS151_CHKPNT_3
    ,
    output  reg [31:0] bypass_addr,
    output  reg [31:0] bypass_din,
    output  reg [3:0]  bypass_we,

    input              filler_ready,
    input              line_ready,
    output  reg [23:0] filler_color,
    output  reg        filler_valid,
    output  reg [31:0] line_color,
    output  reg [9:0]  line_point,
    output  reg        line_color_valid,
    output  reg        line_x0_valid,
    output  reg        line_y0_valid,
    output  reg        line_x1_valid,
    output  reg        line_y1_valid,
    output  reg        line_trigger
`endif
);

    // --------------- Instruction Fetch--------------------- 
    reg  [31:0] PC, next_PC;

    // --------------- Stage 1 REGS and WIRES--------------------- 
    reg rst_reg;

    // --------------- Stage 2 REGS and WIRES--------------------- 
    wire [31:0] instruction_s1, bios_instruction, rd1_s1, rd2_s1, A,B, ALU_out, PC_feedback, j_or_b_feedback;
    reg  [31:0] rd1_s2, rd2_s2;
    reg  [31:0] PC_s2;
    reg  [31:0] instruction_s2_reg;
    wire [31:0] instruction_s2;
    wire [4:0]  rs1, rs2, rd, rs1_s2, rs2_s2;
    wire [6:0]  opcode;
    wire [2:0]  funct;
    wire [20:0] j_addr_shifted;
    wire [19:0] upper_imm;
    wire [12:0] b_offset_shifted; 
    wire [11:0] imm, s_offset;
    wire [3:0]  ALUop_s1;
    reg  [3:0]  ALUop_s2;
    wire [31:0] imm_store_extended;
    wire [31:0] j_or_b_extended;
    wire [31:0] upper_imm_padded;
    wire [31:0] LUI_AUIPC_PC;
    wire [31:0] LUI_mux_out;
    wire [31:0] LUI_AUIPC_mux;
    wire [31:0] jump_mux;
    wire [31:0] forward_rd2_mux;
    reg         UART_store_s2;
    reg  [31:0] write_data;
    wire [31:0] write_data_shift8;
    wire [31:0] write_data_shift16;
    wire [31:0] write_data_shift24;
    reg  [31:0] mem_data;
    wire [31:0] mem_addr;
    wire PC_sel;


    //--------------- Stage 2 Control Signals--------------------- 
    wire i_type, LUI, JAL, LUI_AUIPC, Jump, forward_rd1, forward_rd2, store_op, JALR, Branch, RegWrite_s2;
    reg  [3:0] MemWrite_s2;
    reg        imem_we;
    reg        dmem_we;
    wire       MemtoReg_s2;
    reg        load_UARTcontrol_s2;
    reg        load_UARTdata_s2;
    wire       PC_bios_s2;
    wire       bios_data_s2;
    reg        filler_control_s2;
    reg        line_control_s2;
    reg        take_branch;

    //--------------- Stage 3 REGS and WIRES--------------------- 
    reg  [1:0]  mem_addr_s3;
    reg  [3:0]  MemWrite_s3;
    reg  [4:0]  rd_s3; 
    reg  [31:0] reg_wr_data;
    reg  [31:0] write_data_s3;
    wire [31:0] mem_UARTctrl, mem_UARTctrl_UARTdata;
    reg  [31:0] execute_result_s3;
    reg  [31:0] read_data_s3;
    wire [7:0]  UART_DataOut; 
    wire        UART_DataOutValid;
    wire        UART_DataInReady;
    wire [31:0] mem_out, bios_mem_data;
    reg  [31:0] dcache_addr_s3;
    reg  [31:0] jump_or_branch_addr;
    reg         reset_counters_s3;
    reg         PC_sel_reg, kill;

    //--------------- Stage 3 Control Signals--------------------- 
    reg         RegWrite_s3; 
    reg         MemtoReg_s3;
    reg         load_UARTcontrol_s3;
    reg         load_UARTdata_s3; 
    reg         will_write_rd;
    reg  [2:0]  funct_s3;
    reg         bios_data_s3;
    reg         dcache_re_s3;
    reg         filler_control_s3;
    reg         line_control_s3;
    reg         imem_we_s3;

    //--------------- Benchmarking ------------------------------
    reg  [31:0] cycle_counter;
    reg  [31:0] instruction_counter;
    reg         reset_counters;
    reg         load_cycle_counter_s2;
    reg         load_instruction_counter_s2;
    reg         load_cycle_counter_s3;
    reg         load_instruction_counter_s3;

    always @ (posedge clk) begin
        if (rst_reg || reset_counters_s3) begin
            instruction_counter <= 0;
        end else if (!stall && !PC_sel_reg && !kill) begin
            instruction_counter <= instruction_counter + 1;
        end

        if (rst_reg || reset_counters_s3) begin
            cycle_counter <= 0;
        end else begin
            cycle_counter <= cycle_counter + 1;
        end
    end 

    //--------------- Bypass ------------------------------    
    wire  [31:0] bypass_addr_s2;
    wire  [31:0] bypass_din_s2;
    reg   [3:0]  bypass_we_s2;
    wire  [23:0] filler_color_s2;
    reg          filler_valid_s2;
    wire  [31:0] line_color_s2;
    wire  [9:0]  line_point_s2;
    reg          line_color_valid_s2;
    reg          line_x0_valid_s2;
    reg          line_y0_valid_s2;
    reg          line_x1_valid_s2;
    reg          line_y1_valid_s2;
    reg          line_trigger_s2;


    always @(posedge clk) begin
        if (!stall) begin
            bypass_addr <= bypass_addr_s2;
            bypass_din <= bypass_din_s2;
            bypass_we <= bypass_we_s2;
            filler_color <= filler_color_s2;
            filler_valid <= filler_valid_s2;
            line_color <= line_color_s2;
            line_point <= line_point_s2;
            line_color_valid <= line_color_valid_s2;
            line_x0_valid <= line_x0_valid_s2;
            line_y0_valid <= line_y0_valid_s2;
            line_x1_valid <= line_x1_valid_s2;
            line_y1_valid <= line_y1_valid_s2;
            line_trigger <= line_trigger_s2;
        end
    end

    //--------------- Stage 1 DATAPATH ---------------------

    bios_mem bios_mem(
        .clka(clk),
        .ena(1'b1),
        .addra(next_PC[13:2]),
        .douta(bios_instruction),
        .clkb(clk),
        .enb(1'b1),
        .addrb(dcache_addr[13:2]),
        .doutb(bios_mem_data));


    //--------------- Stage 2 DATAPATH ---------------------'

    // ChipScope components:
    // wire [35:0] chipscope_control;
    // chipscope_icon icon(        
    // .CONTROL0(chipscope_control)
    // ) /* synthesis syn_noprune=1 */;  
    // chipscope_ila ila(
    //     .CONTROL(chipscope_control),
    //     .CLK(clk),
    //     .DATA({JALR, PC_sel, will_write_rd, forward_rd1, forward_rd2, instruction_s2, jump_or_branch_addr, next_PC, PC}),
    //     .TRIG0(UART_store_s2)
    // ) /* synthesis syn_noprune=1 */;

    ALUdec aludec(
        .opcode(instruction_s1[6:0]),
        .funct(instruction_s1[14:12]),
        .add_rshift_type(instruction_s1[30]),
        .ALUop(ALUop_s1));

    RegFile regfile(
        .clk(clk),
        .we(RegWrite_s3 && !rst_reg && !stall),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rd_s3),
        .wd(reg_wr_data),
        .rd1(rd1_s1),
        .rd2(rd2_s1)); 

    ALU alu(
        .A(A),
        .B(B),
        .ALUop(ALUop_s2),
        .Out(ALU_out)
    );

    UART uart(
        .Clock(clk),
        .Reset(rst_reg),
        .DataIn(forward_rd2_mux[7:0]),
        .DataInValid(UART_store_s2 && !stall),
        .DataInReady(UART_DataInReady),
        .DataOut(UART_DataOut),
        .DataOutValid(UART_DataOutValid),
        .DataOutReady(load_UARTdata_s3 && !stall),
        .SIn(FPGA_SERIAL_RX),
        .SOut(FPGA_SERIAL_TX)
    );

    //---------------------------  Control ---------------------------

    assign PC_bios_s2 = PC[31:28] == 4'b0100;
    assign instruction_s1 = (rst_reg) ? 32'h00000033 : (PC_bios_s2 ? bios_instruction : instruction); 
    assign instruction_s2 = PC_sel_reg ? 32'h00000033: instruction_s2_reg;
    assign rs1 = instruction_s1[19:15];
    assign rs2 = instruction_s1[24:20];
    assign rs1_s2 = instruction_s2[19:15];
    assign rs2_s2 = instruction_s2[24:20];
    assign opcode = instruction_s2[6:0];
    assign rd = instruction_s2[11:7]; 
    assign funct = instruction_s2[14:12];
    assign j_addr_shifted = {instruction_s2[31], instruction_s2[19:12], instruction_s2[20], instruction_s2[30:21], 1'b0}; 
    assign upper_imm = instruction_s2[31:12];
    assign b_offset_shifted = {instruction_s2[31], instruction_s2[7], instruction_s2[30:25], instruction_s2[11:8], 1'b0}; 
    assign imm = instruction_s2[31:20]; //used for both i type instruction_s2s and load instruction_s2s and 
    assign s_offset = {instruction_s2[31:25], instruction_s2[11:7]};


    assign i_type = (opcode == `OPC_ARI_ITYPE || opcode == `OPC_LOAD || opcode == `OPC_STORE || opcode == `OPC_JALR );
    assign LUI = (opcode == `OPC_LUI);
    assign JAL = (opcode == `OPC_JAL); 
    assign LUI_AUIPC = (opcode == `OPC_LUI || opcode == `OPC_AUIPC); 
    assign Jump = (opcode == `OPC_JALR || opcode == `OPC_JAL); // could write this as JAL | JALR
    assign store_op = (opcode == `OPC_STORE);
    assign JALR = (opcode == `OPC_JALR);
    assign Branch = (opcode == `OPC_BRANCH);
    assign RegWrite_s2 = !(opcode == `OPC_BRANCH || opcode == `OPC_STORE); //&& !PC_sel_reg;
    assign MemtoReg_s2 = opcode == `OPC_LOAD; 

    //forwarding
    assign forward_rd1 = (rs1_s2 == rd_s3) && (will_write_rd); 
    assign forward_rd2 = (rs2_s2 == rd_s3) && (will_write_rd);

    //---------------------------  Branch Prediction ---------------------------'

    // reg [1:0] cs;
    // reg [1:0] ns;
    // wire branch_taken; // set high when branch is taken for that branch instruction

    // always @(posedge clk) begin
    //     if (!stall && Branch) begin // CHECK LOGIC HERE!!!!!! <- ONLY CHANGE STATE after BRANCH STAGE
    //         cs <= ns;
    //     end
    // end

    // always @(*) begin 
    //     case(cs)
    //         2'b00: begin
    //             if (branch_taken) begin
    //                 ns = 2'b01;
    //             end else begin
    //                 ns = 2'b00;
    //             end
    //         2'b01: begin
    //             if (branch_taken) begin
    //                 ns = 2'b11;
    //             end else begin
    //                 ns = 2'b00;
    //             end
    //         2'b10: begin
    //             if (branch_taken) begin
    //                 ns = 2'b01;
    //             end else begin
    //                 ns = 2'b00;
    //             end
    //         2'b11: begin
    //             if (branch_taken) begin
    //                 ns = 2'b11;
    //             end else begin
    //                 ns = 2'b10;
    //             end
    //      endcase
    // end

    //---------------------------  DATAPATH ---------------------------'
    //BRANCH ALU
    always@(*) begin
        case(ALUop_s2)   
            `ALU_SLT:  take_branch = ($signed(A) < $signed(B));  
            `ALU_SLTU: take_branch = (A < B);
            `ALU_EQ: take_branch = (A == B);    
            `ALU_NE: take_branch = (A != B);     
            `ALU_GE:  take_branch = ($signed(A) >= $signed(B));   
            //`ALU_GEU: take_branch = (A >= B);    
            default: take_branch = (A >= B); 
        endcase
    end

    always @(posedge clk) begin
        if (!stall) begin
            instruction_s2_reg <=  PC_sel_reg ? 32'h00000033 : instruction_s1;
            ALUop_s2 <= ALUop_s1;
            rd1_s2 <= ((rs1 == rd_s3) && (will_write_rd)) ? reg_wr_data : rd1_s1;
            rd2_s2 <= ((rs2 == rd_s3) && (will_write_rd)) ? reg_wr_data : rd2_s1;
        end
    end

    assign A = (forward_rd1) ? reg_wr_data : rd1_s2;
    assign imm_store_extended = (store_op) ? {{20{s_offset[11]}}, s_offset} : {{20{imm[11]}}, imm}; 
    assign forward_rd2_mux = (forward_rd2) ? reg_wr_data : rd2_s2;
    assign B = (i_type) ? imm_store_extended : forward_rd2_mux;
    
    assign write_data_shift8 = forward_rd2_mux << 8; 
    assign write_data_shift16 = forward_rd2_mux << 16; 
    assign write_data_shift24 = forward_rd2_mux << 24;

    assign j_or_b_extended = (JAL) ? { {11{j_addr_shifted[20]}}, j_addr_shifted} : {{19{b_offset_shifted[12]}}, b_offset_shifted};  
    assign j_or_b_feedback = j_or_b_extended + PC_s2;
    assign PC_feedback = (JALR) ? {mem_addr[31:1], 1'b0} : j_or_b_feedback;

    assign upper_imm_padded = {upper_imm, 12'h000};

    assign LUI_mux_out = (LUI) ? 32'd0 : {PC_s2};
    assign LUI_AUIPC_PC = LUI_mux_out + upper_imm_padded;

    assign LUI_AUIPC_mux = (LUI_AUIPC) ? LUI_AUIPC_PC : ALU_out; 

    assign jump_mux = (Jump) ? PC_s2 + 4 : LUI_AUIPC_mux;

    //whether or not to branch/jump
    assign PC_sel = (Jump || (take_branch && Branch));

    assign bios_data_s2 = dcache_addr[31:28] == 4'b0100; 
    
    always @(posedge clk) begin 
        rst_reg <= rst;
        if (!stall) begin
            PC_sel_reg <= PC_sel;
            kill <= PC_sel_reg;
            rd_s3 <= rd;
            funct_s3 <= funct;
            mem_addr_s3 <= mem_addr [1:0];
            execute_result_s3 <= jump_mux;
            dcache_addr_s3 <= dcache_addr;
            write_data_s3 <= write_data;
            imem_we_s3 <= imem_we;
            MemWrite_s3 <= MemWrite_s2;
        end
    end

    always @(*) begin 
        if (MemtoReg_s3) begin 
            if (load_cycle_counter_s3) begin
                reg_wr_data = cycle_counter;
            end else if (load_instruction_counter_s3) begin 
                reg_wr_data = instruction_counter;
            end else if (filler_control_s3) begin
                reg_wr_data = {31'b0, filler_ready};
            end else if (line_control_s3) begin
                reg_wr_data = {31'b0, line_ready};
            end else if (load_UARTcontrol_s3) begin 
                reg_wr_data = {30'd0, UART_DataOutValid, UART_DataInReady};
            end else if (load_UARTdata_s3) begin
                reg_wr_data = {24'd0, UART_DataOut};
            end else begin
                reg_wr_data = read_data_s3; 
            end
        end else begin
            reg_wr_data = execute_result_s3;
        end
    end
   

    always @(*) begin
        if (rst_reg) begin
            next_PC = 32'h40000000;
        end else if (stall) begin
            next_PC = PC;
        end else if (PC_sel_reg) begin
            next_PC = jump_or_branch_addr;
        end else begin
            next_PC = PC + 4;
        end
    end

    always @(posedge clk) begin
        if (!stall) begin
            PC <= next_PC;
            PC_s2 <= PC;
            jump_or_branch_addr <= PC_feedback;
        end
    end

    always @(posedge clk) begin 
        if (!stall) begin 
            MemtoReg_s3 <= MemtoReg_s2;
            RegWrite_s3 <= RegWrite_s2;
            bios_data_s3 <= bios_data_s2;
            dcache_re_s3 <= dcache_re;
        end
    end

    // ---------------------------MEMORY and MEM I/O---------------------------
    assign filler_color_s2 = write_data[23:0];
    assign line_color_s2 = write_data;
    assign line_point_s2 = write_data[9:0];
    assign bypass_din_s2 = dcache_din;
    assign bypass_addr_s2 = dcache_addr;
    assign dcache_addr = !stall ? mem_addr : dcache_addr_s3; 
    assign dcache_din = write_data;
    assign dcache_re = !stall ? opcode == `OPC_LOAD && dcache_addr[28] : dcache_re_s3;
    assign dcache_we = (dmem_we && !rst_reg && !stall) ? MemWrite_s2 : 4'b0000; 
    assign icache_we = (imem_we_s3 && !rst_reg && !stall) ? MemWrite_s3 : 4'b0000; 
    assign mem_out = bios_data_s3 ? bios_mem_data : dcache_dout;
    assign icache_addr = (imem_we_s3 && !rst_reg && !stall) ? dcache_addr_s3 : next_PC;
    assign icache_re = next_PC[31:28] == 4'b0001;
    assign icache_din = write_data_s3;

    assign mem_addr = imm_store_extended + A;

    always @(posedge clk) begin
        if (!stall) begin
            will_write_rd <= (opcode != `OPC_STORE) && (opcode != `OPC_BRANCH) && (rd != 0) && (!rst_reg);
            load_UARTdata_s3 <= load_UARTdata_s2;
            load_UARTcontrol_s3 <= load_UARTcontrol_s2;
            load_cycle_counter_s3 <= load_cycle_counter_s2;
            load_instruction_counter_s3 <= load_instruction_counter_s2;
            filler_control_s3 <= filler_control_s2;
            line_control_s3 <= line_control_s2; 
            reset_counters_s3 <= reset_counters;
        end
    end

    // Setting Write enables 
    always @(*) begin
        dmem_we = 1'b0;
        imem_we = 1'b0;
        bypass_we_s2 = 4'b0000;
        UART_store_s2 = 1'b0;
        reset_counters = 1'b0;
        filler_valid_s2 = 1'b0;

        line_color_valid_s2 = 1'b0;
        line_x0_valid_s2 = 1'b0;
        line_y0_valid_s2 = 1'b0;
        line_x1_valid_s2 = 1'b0;
        line_y1_valid_s2 = 1'b0;
        line_trigger_s2 = 1'b0;

        if (opcode == `OPC_STORE) begin 
            if (mem_addr[31:30] == 2'b00) begin
                if (mem_addr[28] == 1'b1) begin  
                    dmem_we = 1'b1;
                end
                if (mem_addr[29] == 1'b1 && next_PC[30] == 1'b1) begin 
                    imem_we = 1'b1;
                end
            end else if (mem_addr == 32'h80000008) begin  // 'UART transmitter data (write) 
                UART_store_s2 = 1'b1;
            end else if (mem_addr == 32'h80000018) begin
                reset_counters = 1'b1;
            end else if (mem_addr[31:28] == 4'b0100) begin 
                bypass_we_s2 = 4'b1111; //
            end else if (mem_addr == 32'h80000020) begin
                filler_valid_s2 = 1'b1;
            end else if (mem_addr == 32'h80000028) begin
                line_color_valid_s2 = 1'b1;
            end else if (mem_addr == 32'h80000030) begin
                line_x0_valid_s2 = 1'b1;
            end else if (mem_addr== 32'h80000034) begin
                line_y0_valid_s2 = 1'b1;
            end else if (mem_addr == 32'h80000038) begin
                line_x1_valid_s2 = 1'b1;
            end else if (mem_addr == 32'h8000003c) begin
                line_y1_valid_s2 = 1'b1;
            end else if (mem_addr == 32'h80000040) begin
                line_x0_valid_s2 = 1'b1;
                line_trigger_s2 = 1'b1;
            end else if (mem_addr == 32'h80000044) begin
                line_y0_valid_s2 = 1'b1;
                line_trigger_s2 = 1'b1;
            end else if (mem_addr == 32'h80000048) begin
                line_x1_valid_s2 = 1'b1;
                line_trigger_s2 = 1'b1;
            end else if (mem_addr == 32'h8000004c) begin
                line_y1_valid_s2 = 1'b1;
                line_trigger_s2 = 1'b1;
            end
        end

        load_UARTcontrol_s2 = 1'b0; //'defaults to normal dmem load
        load_UARTdata_s2 = 1'b0; //'defaults to normal dmem load
        load_cycle_counter_s2 = 1'b0;
        load_instruction_counter_s2 = 1'b0;
        filler_control_s2 <= 0;
        line_control_s2 <= 0;
        if (opcode == `OPC_LOAD) begin
            if (mem_addr[31:28] == 4'b1000) begin  //' Memory mapped I/O 
                if (mem_addr == 32'h80000000) begin //' UART control (read)
                    load_UARTcontrol_s2 = 1'b1;
                end else if (mem_addr == 32'h80000004) begin //' UART Reciever data (read) 
                    load_UARTdata_s2 = 1'b1; 
                end else if (mem_addr == 32'h80000010) begin 
                    load_cycle_counter_s2 = 1'b1;
                end else if (mem_addr == 32'h80000014) begin
                    load_instruction_counter_s2 = 1'b1;
                end else if (mem_addr == 32'h8000001c) begin
                    filler_control_s2 <= 1;
                end else if (mem_addr == 32'h80000024) begin
                    line_control_s2 <= 1;
                end

            end
        end
    end

    // Writing to Mem (STORE)
    always @(*) begin
        MemWrite_s2 = 4'b0000; 
        write_data = forward_rd2_mux;
        if (opcode == `OPC_STORE) begin 
            case(funct)
            `FNC_SB: case(mem_addr [1:0])
                     0: begin 
                        MemWrite_s2 = 4'b0001;
                        write_data = forward_rd2_mux;
                        end
                     1: begin
                        MemWrite_s2 = 4'b0010;
                        write_data = write_data_shift8;
                        end
                     2: begin
                        MemWrite_s2 = 4'b0100;
                        write_data = write_data_shift16;
                        end
                     3: begin
                        MemWrite_s2 = 4'b1000;
                        write_data = write_data_shift24;
                        end
                     endcase
            `FNC_SH: case(mem_addr [1:0])
                     0: begin
                        MemWrite_s2 = 4'b0011;
                        write_data = forward_rd2_mux;
                        end
                     1: begin
                        MemWrite_s2 = 4'b0011; // Unaligned
                        write_data = forward_rd2_mux;
                        end
                     2: begin
                        MemWrite_s2 = 4'b1100;
                        write_data = write_data_shift16;
                        end
                     3: begin
                        MemWrite_s2 = 4'b1100; // Unaligned
                        write_data = write_data_shift16;
                        end
                     endcase
            `FNC_SW: begin
                write_data = forward_rd2_mux;
                MemWrite_s2 = 4'b1111;  
            end
            endcase
        end
    end
    
    // Reading from Mem (LOAD)
    always @(*) begin
        read_data_s3 = mem_out;
        case(funct_s3)
        `FNC_LB: case(mem_addr_s3)
                 0: read_data_s3 = {{24{mem_out[7]}}, mem_out[7:0]};
                 1: read_data_s3 = {{24{mem_out[15]}}, mem_out[15:8]};
                 2: read_data_s3 = {{24{mem_out[23]}}, mem_out[23:16]};
                 3: read_data_s3 = {{24{mem_out[31]}}, mem_out[31:24]};
                 endcase
        `FNC_LH: case(mem_addr_s3)
                 0: read_data_s3 = {{16{mem_out[15]}}, mem_out[15:0]};
                 1: read_data_s3 = {{16{mem_out[15]}}, mem_out[15:0]}; // unaligned
                 2: read_data_s3 = {{16{mem_out[31]}}, mem_out[31:16]};
                 3: read_data_s3 = {{16{mem_out[31]}}, mem_out[31:16]}; // unaligned
                 endcase
        `FNC_LW: read_data_s3 = mem_out;    
        `FNC_LBU:case(mem_addr_s3)
                 0: read_data_s3 = {24'b0, mem_out[7:0]};
                 1: read_data_s3 = {24'b0, mem_out[15:8]};
                 2: read_data_s3 = {24'b0, mem_out[23:16]};
                 3: read_data_s3 = {24'b0, mem_out[31:24]};
                 endcase
        `FNC_LHU:case(mem_addr_s3)
                 0: read_data_s3 = {16'b0, mem_out[15:0]};
                 1: read_data_s3 = {16'b0, mem_out[15:0]}; // unaligned
                 2: read_data_s3 = {16'b0, mem_out[31:16]};
                 3: read_data_s3 = {16'b0, mem_out[31:16]}; //' unaligned
                 endcase
        endcase
    end

 //         .| _                         |\
 //         ||/ )                     .--' '--.
 //        //|-'          _   |   o .  `; . .' |_| _ | |   _   _
 //       /|||\)   .     ( (| | \|| |\| |/and  | |(_)|)|) (- _)
 //      /.'||     |`.'/  `      '    `
 //     ' | ||    <.  _\                  .--.          _
 //    '  ' 'L_     \'       .   ,       | .-.\.-'``;-'`.)           /.
 //   /  |  ||/              |'.'/       \ \ ,'  ;'`,--. \       __ / |
 //  ' / ;  |||           .--'   `.       '/;;-._ ,'    ';      \      '-.
 //  |'` \ _/ _/)          '-. .'''`     >\|,    /       |       >     .'
 //  | "  `' /|),            |/         >`. ``-.|     D D|      / _.  ;
 // |  '| ,-'||\_)                     /_              .-.'.   /.'  \ |
 // |    /    .                          >     .  ) (     )<         \'
 //  \ .'    ||         _.,---.c        '-/._  `-'\  `'-'`/
 // | `,     ||     __,','/    \`.         >    -. `'--'
 // ;   \    ||    (._`'-._     | \       /  _\ '\`--'`
 // '    ;           /``'-.`-._ |  ;    .'`'-\     > .-.          /\
 //  \  /    '|     _O     `-. -.  |   /'--./     _` )  \,      ,'  \
 //  '|/    _||    (   O      )-.`-.  / _  <   .-; `".-. )     /     `.
 // ,'|    (_( `\   |,__      `._/`'.).' |  >  |  \_/  /)    .' X-''-. \
 // | ;     (_)-.`'-\ \ `'--.   _)   |  _| ( .-\       /  _.' / __..---/
 //  \ ;      || `||||.`._./ _.'     |/` \  \ .'`..--"``-/ \ :/\     ,'
 //   '|      |;   `\|=`--'=`-.      |   /;.-'\ .'|_| /.'`-' /_X`'. /
 //           |      /======///`>    \  / | \  /  |  `/___7\/(_    `>
 //           |.    '=======__//,-""``.|  \ _;'    ;     /' \  `') /
 //           ||    ;======'-, )\`-..__\_,-' |      '.__/ |  '.-' /
 //           |:    |=======(_/ ;   ;  /    __\        /  ;    \ /
 //           L|    |________\  |   |  |  .'   '      .' _|   _ \
 //  .             _'--_-----'  |   |  | /   .-''._ _/ .'  './ `'.
 //  |`.'/        ( ` (  '--'`) `-..|__/\   /   /  /  :   o  | o |  _ /\__
 // <.  _\       /,`'--`'---""`-,-'\  /-/\ /   |  /.-'| o  o;   o:  \    /
 //   \'       .';;;,,-::_           |-;_ `-..._\_ _|_\  o  / o ,'   | ;.\
 //           /   \  ``''-`'-.    ,- './ '-.._     '" ''._.''._,'    |/
 //          ,'    |          ` -'      `-.|_ /.             \
 //         /      '.                  ;     `.-\      `;;    '
 //        .'  ,    `-.             _,-'       \_) ,;;;;;;;.__ \
 //        |    ;.     \       ,;;;'                `'''~~;;;;;;.
 //       ' .,__,;'    _..;;;;;';      ,;;;-'               ~~;;;
 //       |;.;;;;'    ;;;;'`  ,'     _;;;'     _                 '
 //       |;'       ;;'  '.  ;      .;;~      ';;.               |
 //       |               `', \     '.;;._      `;\      .-      |
 //       '.                 ` |      `';;`;;;;_';;       `;'.   ;
 //        | /     ____       |`~'._   _  `''-;;;'           `;\
 //        \'.__,-';;;;,,.   /      `~~ `._       '      '''_;; '
 //         \;;;;;;-''';;/  |              \'    |.__      ..,::'
 //          \::;;;';,      ;              /      `-.;...,, ;;:'
 //           \;;;;-'.       \           .'           '~~~~;:'/
 //            `.---'         \         /                   ;/
 //             `.              ;    ,:;;;;,-'`-.           /
 //               `.   _...~ ;;;;`,-'    `-.`';;;,_.'---. .'
 //                  ..';;;;. `-.'.     ::;;   `-.;;;;:. '
 //                    `-. :::;;;-    ~~         `-..'mx/LGB
 //                        ''.__.---'       ;;;;,-'
 //                             `''--=====--'' 

endmodule
