onerror {resume}
radix define opcodes {
    "7'b0110111" "LUI",
    "7'b0010111" "AUIPC",
    "7'b1101111" "JAL",
    "7'b1100111" "JALR",
    "7'b1100011" "BRANCH",
    "7'b0000011" "LOAD",
    "7'b0100011" "STORE",
    "7'b0010011" "Itype",
    "7'b0110011" "Rtype",
    -default hexadecimal
}
quietly WaveActivateNextPane {} 0
add wave -noupdate /icache_testbench/DUT/clk
add wave -noupdate /icache_testbench/DUT/rst
add wave -noupdate -radix opcodes /icache_testbench/DUT/opcode
add wave -noupdate /icache_testbench/DUT/rst_reg
add wave -noupdate /icache_testbench/DUT/i_read_addr
add wave -noupdate /icache_testbench/DUT/stall
add wave -noupdate /icache_testbench/DUT/instruction
add wave -noupdate /icache_testbench/mem_arch/stall
add wave -noupdate /icache_testbench/mem_arch/i_stall
add wave -noupdate /icache_testbench/mem_arch/d_stall
add wave -noupdate /icache_testbench/mem_arch/bypass_stall
add wave -noupdate /icache_testbench/mem_arch/bypass_addr
add wave -noupdate /icache_testbench/mem_arch/bypass_addr_din
add wave -noupdate /icache_testbench/mem_arch/bypass_af_full
add wave -noupdate /icache_testbench/mem_arch/bypass_af_wr_en
add wave -noupdate /icache_testbench/mem_arch/bypass_din
add wave -noupdate /icache_testbench/mem_arch/bypass_stall
add wave -noupdate /icache_testbench/mem_arch/bypass_wdf_din
add wave -noupdate /icache_testbench/mem_arch/bypass_wdf_full
add wave -noupdate /icache_testbench/mem_arch/bypass_wdf_mask_din
add wave -noupdate /icache_testbench/mem_arch/bypass_wdf_wr_en
add wave -noupdate /icache_testbench/mem_arch/bypass_we
add wave -noupdate /icache_testbench/bypass_addr
add wave -noupdate /icache_testbench/DUT/bypass_addr
add wave -noupdate /icache_testbench/DUT/PC
add wave -noupdate /icache_testbench/DUT/PC_rst_mux
add wave -noupdate /icache_testbench/DUT/bios_instruction
add wave -noupdate /icache_testbench/DUT/instruction_chkpnt_1
add wave -noupdate /icache_testbench/DUT/i_read_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {73908626 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 355
configure wave -valuecolwidth 100
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
WaveRestoreZoom {73872877 ps} {73973430 ps}
