onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /FirstTest/cpu/stall
add wave -noupdate -radix decimal /FirstTest/cpu/FPGA_SERIAL_RX
add wave -noupdate -radix decimal /FirstTest/cpu/FPGA_SERIAL_TX
add wave -noupdate -radix decimal /FirstTest/cpu/clk
add wave -noupdate -radix decimal /FirstTest/cpu/rst
add wave -noupdate -radix decimal /FirstTest/cpu/rst_reg
add wave -noupdate -radix decimal /FirstTest/cpu/PC
add wave -noupdate -radix decimal /FirstTest/cpu/PC_s2
add wave -noupdate -radix hexadecimal /FirstTest/cpu/instruction
add wave -noupdate -radix binary /FirstTest/cpu/opcode
add wave -noupdate -radix binary /FirstTest/cpu/funct
add wave -noupdate -radix decimal /FirstTest/cpu/rs1
add wave -noupdate -radix decimal /FirstTest/cpu/rs2
add wave -noupdate -radix decimal /FirstTest/cpu/rd
add wave -noupdate -radix decimal /FirstTest/cpu/rd1
add wave -noupdate -radix decimal /FirstTest/cpu/rd2
add wave -noupdate -radix decimal /FirstTest/cpu/A
add wave -noupdate -radix decimal /FirstTest/cpu/B
add wave -noupdate -radix decimal -childformat {{{/FirstTest/cpu/ALU_out[31]} -radix decimal} {{/FirstTest/cpu/ALU_out[30]} -radix decimal} {{/FirstTest/cpu/ALU_out[29]} -radix decimal} {{/FirstTest/cpu/ALU_out[28]} -radix decimal} {{/FirstTest/cpu/ALU_out[27]} -radix decimal} {{/FirstTest/cpu/ALU_out[26]} -radix decimal} {{/FirstTest/cpu/ALU_out[25]} -radix decimal} {{/FirstTest/cpu/ALU_out[24]} -radix decimal} {{/FirstTest/cpu/ALU_out[23]} -radix decimal} {{/FirstTest/cpu/ALU_out[22]} -radix decimal} {{/FirstTest/cpu/ALU_out[21]} -radix decimal} {{/FirstTest/cpu/ALU_out[20]} -radix decimal} {{/FirstTest/cpu/ALU_out[19]} -radix decimal} {{/FirstTest/cpu/ALU_out[18]} -radix decimal} {{/FirstTest/cpu/ALU_out[17]} -radix decimal} {{/FirstTest/cpu/ALU_out[16]} -radix decimal} {{/FirstTest/cpu/ALU_out[15]} -radix decimal} {{/FirstTest/cpu/ALU_out[14]} -radix decimal} {{/FirstTest/cpu/ALU_out[13]} -radix decimal} {{/FirstTest/cpu/ALU_out[12]} -radix decimal} {{/FirstTest/cpu/ALU_out[11]} -radix decimal} {{/FirstTest/cpu/ALU_out[10]} -radix decimal} {{/FirstTest/cpu/ALU_out[9]} -radix decimal} {{/FirstTest/cpu/ALU_out[8]} -radix decimal} {{/FirstTest/cpu/ALU_out[7]} -radix decimal} {{/FirstTest/cpu/ALU_out[6]} -radix decimal} {{/FirstTest/cpu/ALU_out[5]} -radix decimal} {{/FirstTest/cpu/ALU_out[4]} -radix decimal} {{/FirstTest/cpu/ALU_out[3]} -radix decimal} {{/FirstTest/cpu/ALU_out[2]} -radix decimal} {{/FirstTest/cpu/ALU_out[1]} -radix decimal} {{/FirstTest/cpu/ALU_out[0]} -radix decimal}} -subitemconfig {{/FirstTest/cpu/ALU_out[31]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[30]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[29]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[28]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[27]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[26]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[25]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[24]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[23]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[22]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[21]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[20]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[19]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[18]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[17]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[16]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[15]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[14]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[13]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[12]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[11]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[10]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[9]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[8]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[7]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[6]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[5]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[4]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[3]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[2]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[1]} {-height 17 -radix decimal} {/FirstTest/cpu/ALU_out[0]} {-height 17 -radix decimal}} /FirstTest/cpu/ALU_out
add wave -noupdate -radix decimal /FirstTest/cpu/PC_plus4
add wave -noupdate -radix decimal /FirstTest/cpu/i_read_addr
add wave -noupdate -radix decimal /FirstTest/cpu/PC_sel
add wave -noupdate -radix decimal /FirstTest/cpu/imemWrite_s2
add wave -noupdate -radix decimal /FirstTest/cpu/PC_plus4_s2
add wave -noupdate -radix hexadecimal /FirstTest/cpu/imem_out
add wave -noupdate -radix decimal /FirstTest/cpu/PC_feedback
add wave -noupdate -radix decimal /FirstTest/cpu/j_or_b_feedback
add wave -noupdate -radix decimal /FirstTest/cpu/j_addr_shifted
add wave -noupdate -radix decimal /FirstTest/cpu/upper_imm
add wave -noupdate -radix decimal /FirstTest/cpu/b_offset_shifted
add wave -noupdate -radix decimal /FirstTest/cpu/imm
add wave -noupdate -radix decimal /FirstTest/cpu/s_offset
add wave -noupdate -radix decimal /FirstTest/cpu/add_rshift_type
add wave -noupdate -radix decimal /FirstTest/cpu/ALUop
add wave -noupdate -radix decimal /FirstTest/cpu/imm_store_extended
add wave -noupdate -radix decimal /FirstTest/cpu/j_or_b_extended
add wave -noupdate -radix decimal /FirstTest/cpu/upper_imm_padded
add wave -noupdate -radix decimal /FirstTest/cpu/LUI_AUIPC_PC
add wave -noupdate -radix decimal /FirstTest/cpu/LUI_mux_out
add wave -noupdate -radix decimal /FirstTest/cpu/LUI_AUIPC_mux
add wave -noupdate -radix decimal /FirstTest/cpu/jump_mux
add wave -noupdate -radix decimal /FirstTest/cpu/forward_rd2_mux
add wave -noupdate -radix decimal /FirstTest/cpu/UART_store_s2
add wave -noupdate -radix decimal /FirstTest/cpu/i_type
add wave -noupdate -radix decimal /FirstTest/cpu/LUI
add wave -noupdate -radix decimal /FirstTest/cpu/JAL
add wave -noupdate -radix decimal /FirstTest/cpu/LUI_AUIPC
add wave -noupdate -radix decimal /FirstTest/cpu/Jump
add wave -noupdate -radix decimal /FirstTest/cpu/forward_rd1
add wave -noupdate -radix decimal /FirstTest/cpu/forward_rd2
add wave -noupdate -radix decimal /FirstTest/cpu/store_op
add wave -noupdate -radix decimal /FirstTest/cpu/JALR
add wave -noupdate -radix decimal /FirstTest/cpu/Branch
add wave -noupdate -radix decimal /FirstTest/cpu/RegWrite_s2
add wave -noupdate -radix decimal /FirstTest/cpu/MemWrite_s2
add wave -noupdate -radix decimal /FirstTest/cpu/dmemWrite_s2
add wave -noupdate -radix decimal /FirstTest/cpu/imem_we
add wave -noupdate -radix decimal /FirstTest/cpu/dmem_we
add wave -noupdate -radix decimal /FirstTest/cpu/MemtoReg_s2
add wave -noupdate -radix decimal /FirstTest/cpu/load_UARTcontrol_s2
add wave -noupdate -radix decimal /FirstTest/cpu/load_UARTdata_s2
add wave -noupdate -radix decimal /FirstTest/cpu/ALU_out_s3
add wave -noupdate -radix decimal /FirstTest/cpu/rd_s3
add wave -noupdate -radix decimal /FirstTest/cpu/reg_wr_data
add wave -noupdate -radix decimal /FirstTest/cpu/mem_UARTctrl
add wave -noupdate -radix decimal /FirstTest/cpu/mem_UARTctrl_UARTdata
add wave -noupdate -radix decimal /FirstTest/cpu/execute_result_s3
add wave -noupdate -radix decimal /FirstTest/cpu/read_data_s3
add wave -noupdate -radix decimal /FirstTest/cpu/UART_DataOut
add wave -noupdate -radix decimal /FirstTest/cpu/UART_DataOutValid
add wave -noupdate -radix decimal /FirstTest/cpu/UART_DataInReady
add wave -noupdate -radix decimal /FirstTest/cpu/mem_out
add wave -noupdate -radix decimal /FirstTest/cpu/dmem_enable
add wave -noupdate -radix decimal /FirstTest/cpu/RegWrite_s3
add wave -noupdate -radix decimal /FirstTest/cpu/RegWrite
add wave -noupdate -radix decimal /FirstTest/cpu/MemtoReg_s3
add wave -noupdate -radix decimal /FirstTest/cpu/load_UARTcontrol_s3
add wave -noupdate -radix decimal /FirstTest/cpu/enable
add wave -noupdate -radix decimal /FirstTest/cpu/load_UARTdata_s3
add wave -noupdate -radix decimal /FirstTest/cpu/will_write_rd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 330
configure wave -valuecolwidth 102
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {382070 ps} {485154 ps}
