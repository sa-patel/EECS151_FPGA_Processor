.section    .start
.global     _start

_start:

lui x10, 0x20000 #store addr
lui x11, 0x10000 #load addr

li x20, 0x02000093 # stores binary for addi x1, x0, 32
li x21, 0x00109093 # stores binary for slli x1, 0x1
sw x20, 0(x10)
sw x21, 4(x10)
lw x5, 0(x10)
lw x6, 4(x10)
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0c

jalr x11