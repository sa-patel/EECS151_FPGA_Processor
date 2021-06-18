onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LineEngineTestbench/le/clk
add wave -noupdate /LineEngineTestbench/le/x
add wave -noupdate /LineEngineTestbench/le/y
add wave -noupdate -radix decimal /LineEngineTestbench/le/error
add wave -noupdate -radix unsigned /LineEngineTestbench/le/x0
add wave -noupdate -radix decimal /LineEngineTestbench/le/x1
add wave -noupdate -radix unsigned /LineEngineTestbench/le/y0
add wave -noupdate -radix unsigned /LineEngineTestbench/le/y1
add wave -noupdate /LineEngineTestbench/le/cs
add wave -noupdate /LineEngineTestbench/le/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {191374 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 305
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
WaveRestoreZoom {153600 ps} {262953 ps}
