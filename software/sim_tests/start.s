.section    .start
.global     _start

_start:

addi x7, x0, 0x7
addi x1, x0, 0x1
addi x2, x0, 0x2
add  x8, x7, x1  #PC 12
add x9, x8, x1
add x10, x1, x9
lui x31, 0x80000 #PC 24
addi x31, x31, 0x1 
auipc x31, 0x80000
add x31, x31, x0 #PC 36

beq x7, x7, Pass #PC 40
lui x31, 0x80000 
addi x0, x0, 0x0
addi x0, x0, 0x0
addi x0, x0, 0x0
addi x0, x0, 0x0

Pass:
addi x11, x10, 0x1 #PC 64


jal x1, Done

add x0, x0, x0 #PC 72

Done:
addi x1, x1,0x0 
addi x1, x0, 0x1

# memory base address for data memory
lui x10, 0x10000 
# Store the values, and then load them back
sw x1, 0(x10)
sw x2, 4(x10)
lw x11, 0(x10)
lw x12, 4(x10)

addi x2, x12, 0x0
addi x1, x11, 0x0
