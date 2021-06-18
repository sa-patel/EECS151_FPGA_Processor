onerror {resume}
quietly set dataset_list [list sim echo]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/EchoTestbench/riscv151/clk
add wave -noupdate sim:/EchoTestbench/riscv151/PC_s2
add wave -noupdate sim:/EchoTestbench/riscv151/instruction
add wave -noupdate sim:/EchoTestbench/riscv151/rd1
add wave -noupdate sim:/EchoTestbench/riscv151/rd2
add wave -noupdate sim:/EchoTestbench/riscv151/A
add wave -noupdate sim:/EchoTestbench/riscv151/B
add wave -noupdate sim:/EchoTestbench/riscv151/ALU_out
add wave -noupdate -radix binary sim:/EchoTestbench/riscv151/opcode
add wave -noupdate -radix binary sim:/EchoTestbench/riscv151/funct
add wave -noupdate sim:/EchoTestbench/riscv151/UART_store_s2
add wave -noupdate sim:/EchoTestbench/riscv151/write_data
add wave -noupdate sim:/EchoTestbench/riscv151/write_data_shift8
add wave -noupdate sim:/EchoTestbench/riscv151/write_data_shift16
add wave -noupdate sim:/EchoTestbench/riscv151/write_data_shift24
add wave -noupdate sim:/EchoTestbench/riscv151/store_type
add wave -noupdate sim:/EchoTestbench/riscv151/load_UARTcontrol_s2
add wave -noupdate sim:/EchoTestbench/riscv151/load_UARTdata_s2
add wave -noupdate sim:/EchoTestbench/riscv151/load_UARTcontrol_s3
add wave -noupdate sim:/EchoTestbench/riscv151/load_UARTdata_s3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {89617436 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 365
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
WaveRestoreZoom {89560680 ps} {89659320 ps}
