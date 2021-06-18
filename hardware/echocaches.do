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
add wave -noupdate /EchoTestbenchCaches/DUT/clk
add wave -noupdate /EchoTestbenchCaches/DUT/stall
add wave -noupdate /EchoTestbenchCaches/DUT/rst
add wave -noupdate -radix opcodes /EchoTestbenchCaches/DUT/opcode
add wave -noupdate /EchoTestbenchCaches/DUT/funct
add wave -noupdate /EchoTestbenchCaches/DUT/i_read_addr
add wave -noupdate /EchoTestbenchCaches/DUT/PC
add wave -noupdate /EchoTestbenchCaches/mem_arch/i_stall
add wave -noupdate /EchoTestbenchCaches/mem_arch/d_stall
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {73986751 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 319
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
WaveRestoreZoom {73614883 ps} {74454585 ps}
