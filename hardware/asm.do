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
add wave -noupdate /Assembly_TestBench/cpu/clk
add wave -noupdate /Assembly_TestBench/cpu/rst_reg
add wave -noupdate /Assembly_TestBench/cpu/stall
add wave -noupdate /Assembly_TestBench/cpu/PC_s2
add wave -noupdate -radix opcodes /Assembly_TestBench/cpu/opcode
add wave -noupdate /Assembly_TestBench/cpu/instruction_s2
add wave -noupdate /Assembly_TestBench/cpu/rd1_s1
add wave -noupdate /Assembly_TestBench/cpu/rd1_s2
add wave -noupdate -radix unsigned /Assembly_TestBench/cpu/rs1
add wave -noupdate /Assembly_TestBench/cpu/A
add wave -noupdate /Assembly_TestBench/cpu/B
add wave -noupdate /Assembly_TestBench/cpu/ALU_out
add wave -noupdate /Assembly_TestBench/cpu/write_data
add wave -noupdate /Assembly_TestBench/cpu/PC_sel_reg
add wave -noupdate /Assembly_TestBench/cpu/jump_or_branch_addr
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[7]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {132669143 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 406
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
WaveRestoreZoom {132642946 ps} {132696162 ps}
