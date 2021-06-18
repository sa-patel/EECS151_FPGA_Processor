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
add wave -noupdate /Assembly_TestBench/cpu/UART_store_s2
add wave -noupdate -radix decimal /Assembly_TestBench/cpu/write_data
add wave -noupdate -radix opcodes /Assembly_TestBench/cpu/opcode
add wave -noupdate -radix binary /Assembly_TestBench/cpu/funct
add wave -noupdate -radix decimal /Assembly_TestBench/cpu/reg_wr_data
add wave -noupdate -radix unsigned /Assembly_TestBench/cpu/rd
add wave -noupdate -radix unsigned /Assembly_TestBench/cpu/rs1
add wave -noupdate -radix unsigned /Assembly_TestBench/cpu/rs2
add wave -noupdate /Assembly_TestBench/cpu/forward_rd1
add wave -noupdate -radix hexadecimal /Assembly_TestBench/cpu/A
add wave -noupdate -radix hexadecimal /Assembly_TestBench/cpu/B
add wave -noupdate -radix hexadecimal /Assembly_TestBench/cpu/ALU_out
add wave -noupdate -radix decimal /Assembly_TestBench/cpu/imm
add wave -noupdate -label {register 31} {/Assembly_TestBench/cpu/regfile/registers[31]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[30]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[29]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[28]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[27]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[26]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[25]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[24]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[23]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[22]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[21]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[20]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[19]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[18]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[17]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[16]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[15]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[14]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[13]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[12]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[11]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[10]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[9]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[8]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[7]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[6]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[5]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[4]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[3]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[2]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[1]}
add wave -noupdate {/Assembly_TestBench/cpu/regfile/registers[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1320459 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 386
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
WaveRestoreZoom {1303947 ps} {1399879 ps}
