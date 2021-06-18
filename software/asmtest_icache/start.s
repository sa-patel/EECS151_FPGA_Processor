.section    .start
.global     _start

_start:


##TODO
##branch not taken does PC + 4 like normal
## check that AUIPC actually adds a shifted offset
## Noop doesn't write to mem
## forward from two instructions before and one instruction before prioritizes one instruction before


# don't mess with reg 30 or reg 31 or 7 in the tests. 

# this keeps track of whether we are done
addi x30, x0, 0x0
# Counter to keep track of how many tests pass
addi x7, x0, 0x0


# Load values to registers to test (use as rs, not rd)
addi x3, x0, 0x3
addi x4, x0, 0x4
addi x5, x0, 0x5
addi x6, x0, 0x6

# Load some test values into registers
lui x1, 0x10000
addi x1, x1, 0x020
lui x2, 0x1eadb
addi x2, x2, 0x0ef

# Set up the base address for loads/stores
# Base address will be 0x10000000
lui x10, 0x10000

# Store the values, and then load them back
sw x1, 0(x10)
sw x2, 4(x10)
lw x11, 0(x10)
lw x12, 4(x10)

# Test 1
addi x31, x0, '1'
addi x7, x7, 0x1
bne x1, x11, Error

# Test 2
addi x31, x0, '2'
addi x7, x7, 0x1
bne x2, x12, Error

# Test 3 - LUI
# x20 is loaded to 
addi x31, x0, '3'
addi x7, x7, 0x1

lui x20, 0x00001
addi x21, x0, 0x400
addi x21, x21, 0x400
addi x21, x21, 0x400
addi x21, x21, 0x400

bne x21, x20, Error

# Test 4 - ORI 
# also checks that forwarding 2 instructions ahead works
addi x31, x0, '4'
addi x7, x7, 0x1 

addi x21, x0, 0x4ff
ori  x20, x0, 0x4ff
bne x21, x20, Error



# Test 5 - AUIPC/ JALR 
# Checks whether offset is computed correctly
addi x31, x0, '5'
addi x7, x7, 0x1 

# put current PC in AUIPC
auipc x20, 0x0 

# adds x20 + 12 to bypass flag jump
jalr x21, x20, 0x00c
#branches to Error
j Flag

# corresponds to x20 + 12, should add 8 so both x20 and x21 are equal 
addi x20, x20, 0x8

bne x20,x21, Error

# Test 6 - Check that PC is in icache
addi x31, x0, '6'
addi x7, x7, 0x1 

auipc x20, 0x0
srli x20, x20, 0x1c # shift by 29 
add x5, x0, 0x1
bne x5, x20, Error


# Test 7 - BEQ
addi x31, x0, '7'
addi x7, x7, 0x1 

addi x20, x0, 0x1
addi x21, x0, 0x2
addi x22, x0, 0x2

# Not supposed to jump
beq x20,x21, Flag

# Supposed to Jump
beq x21, x22, Beqtest
j Error
Beqtest:

# Test 8 - BLT
addi x31, x0, '8'
addi x7, x7, 0x1 

addi x20, x0, 0x1
addi x21, x0, 0x2
LUI x23, 0xfffff

# Not supposed to jump
blt x21, x20, Flag
blt x21, x23, Flag

# Supposed to Jump
blt x23, x20, Blttest
j Error
Blttest:

# Test 9 - BLTU 
addi x31, x0, '9'
addi x7, x7, 0x1 

addi x20, x0, 0x1
addi x21, x0, 0x2
LUI x23, 0xfffff

# Not supposed to jump
bltu x21, x20, Flag
bltu x23, x20, Flag

# Supposed to Jump
bltu x20, x21, Bltutest
j Error
Bltutest:

# Test 10 - BGE 
addi x31, x0, 'a'
addi x7, x7, 0x1 

addi x20, x0, 0x1
addi x21, x0, 0x2
LUI x23, 0xfffff

# Not supposed to jump
bge x20, x21, Flag
bge x23, x21, Flag

# Supposed to Jump
bge x20, x23, Bgetest
j Error
Bgetest:

# Test 11 - BGEU 
addi x31, x0, 'b'
addi x7, x7, 0x1 

addi x20, x0, 0x1
addi x21, x0, 0x2
LUI x23, 0xfffff

# Not supposed to jump
bgeu x20, x23, Flag
bgeu x20, x21, Flag
bgeu x0, x21, Flag

# Supposed to Jump
bgeu x23, x21, Bgeutest
j Error
Bgeutest:


# Test 12 - SLLI (op used in future tests)
addi x31, x0, 'c'
addi x7, x7, 0x1

addi x20, x0, 0x0ff

slli x21, x20, 0x14

lui x23, 0x0ff00

bne x23, x21, Error

# Test 13 - SRA 
addi x31, x0, 'd'
addi x7, x7, 0x1

lui x24, 0xfffff
ori x24, x24, -1

lui x23, 0x80000
sra x23, x23, 0x1f

bne x24, x23, Error

# Test 14 - LB (contingent on STORE WORD)
addi x31, x0, 'e'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# li instruction
lui x21, 0x87654
ori x21, x21, 0x321

sw x21, 0(x10)

# bottom byte
lb x22, 0(x10)
addi x24, x0, 0x21
bne x22,x24, Error

lb x22, 1(x10)
addi x24, x0, 0x43
bne x22,x24, Error

lb x22, 2(x10)
addi x24, x0, 0x65
bne x22,x24, Error

#top byte
lb x22, 3(x10)
lui x24, 0x87000
sra x24, x24, 24
bne x22,x24, Error



# Test 15 - LB (contingent on STORE WORD) with sign extension
addi x31, x0, 'f'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# li instruction
# lui x21, 0x89abc
# # x21 = 0x89abcdef
# ori x21, x21, -529
lui x26, 0xcdef0
srl x26, x26, 16
lui x20, 0x89ab0
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom byte
lb x22, 0(x10)
lui x24, 0xef000
sra x24, x24, 24
bne x22, x24, Error

# 2nd from right byte
lb x22, 1(x10)
lui x24, 0xcd000
sra x24, x24, 24
bne x22, x24, Error

# 3rd from right byte
lb x22, 2(x10)
lui x24, 0xab000
sra x24, x24, 24
bne x22, x24, Error

lw x25, 0(x10)

# top byte
lb x22, 3(x10)
lui x24, 0x89000
sra x24, x24, 24
bne x22, x24, Error

# Test 16 - LH (contingent on STORE WORD) with sign extension
addi x31, x0, 'g'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x89abcdef
lui x26, 0xcdef0
srl x26, x26, 16
lui x20, 0x89ab0
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom half
lh x22, 0(x10)
lui x24, 0xcdef0
sra x24, x24, 16
bne x22, x24, Error

# top half
lh x22, 2(x10)
lui x24, 0x89ab0
sra x24, x24, 16
bne x22, x24, Error

# Test 17 - LH (contingent on STORE WORD) with sign extension
addi x31, x0, 'h'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x89abcdef
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom half
lh x22, 0(x10)
lui x24, 0x43210
sra x24, x24, 16
bne x22, x24, Error

# top half
lh x22, 2(x10)
lui x24, 0x87650
sra x24, x24, 16
bne x22, x24, Error


# Test 18 - LW (contingent on STORE WORD) with sign extension
addi x31, x0, 'i'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x89abcdef
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 

sw x19, 0(x10)
lw x15, 0(x10)

bne x15, x19, Error




# Test 19 - LBU (contingent on STORE WORD)
addi x31, x0, 'j'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# li instruction
lui x21, 0x87654
ori x21, x21, 0x321

sw x21, 0(x10)

# bottom byte
lbu x22, 0(x10)
addi x24, x0, 0x21
bne x22,x24, Error

lbu x22, 1(x10)
addi x24, x0, 0x43
bne x22,x24, Error

lbu x22, 2(x10)
addi x24, x0, 0x65
bne x22,x24, Error

#top byte
lbu x22, 3(x10)
lui x24, 0x87000
srl x24, x24, 24
bne x22,x24, Error



# Test 20 - LBU (contingent on STORE WORD) with sign extension
addi x31, x0, 'k'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x89abcdef
lui x26, 0xcdef0
srl x26, x26, 16
lui x20, 0x89ab0
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom byte
lbu x22, 0(x10)
lui x24, 0xef000
srl x24, x24, 24
bne x22, x24, Error

# 2nd from right byte
lbu x22, 1(x10)
lui x24, 0xcd000
srl x24, x24, 24
bne x22, x24, Error

# 3rd from right byte
lbu x22, 2(x10)
lui x24, 0xab000
srl x24, x24, 24
bne x22, x24, Error

# top byte
lbu x22, 3(x10)
lui x24, 0x89000
srl x24, x24, 24
bne x22, x24, Error


# Test 21 - LHU (contingent on STORE WORD) with sign extension
addi x31, x0, 'l'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x89abcdef
lui x26, 0xcdef0
srl x26, x26, 16
lui x20, 0x89ab0
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom half
lhu x22, 0(x10)
lui x24, 0xcdef0
srl x24, x24, 16
bne x22, x24, Error

# top half
lhu x22, 2(x10)
lui x24, 0x89ab0
srl x24, x24, 16
bne x22, x24, Error

# Test 22 - LHU (contingent on STORE WORD) with sign extension
addi x31, x0, 'm'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 


sw x19, 0(x10)
lw x15, 0(x10)

# bottom half
lhu x22, 0(x10)
lui x24, 0x43210
srl x24, x24, 16
bne x22, x24, Error

# top half
lhu x22, 2(x10)
lui x24, 0x87650
srl x24, x24, 16
bne x22, x24, Error



# Test 23 - SB 
addi x31, x0, 'n'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x87654321
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 

sw x0, 0(x10) # zero out the bits 

# rightmost byte
sb x19, 0(x10)
lui x24, 0x21000
srl x24, x24, 24
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sb x19, 1(x10)
lui x24, 0x21210
srl x24, x24, 16
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sw x0, 0(x10)
sb x19, 2(x10)
lui x24, 0x00210
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sb x19, 3(x10)
lui x24, 0x21210
lw x22, 0(x10)

bne x22, x24, Error


# Test 23 - SB 
addi x31, x0, 'n'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x87654321
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 

sw x0, 0(x10) # zero out the bits 

# rightmost byte
sb x19, 0(x10)
lui x24, 0x21000
srl x24, x24, 24
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sb x19, 1(x10)
lui x24, 0x21210
srl x24, x24, 16
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sw x0, 0(x10)
sb x19, 2(x10)
lui x24, 0x00210
lw x22, 0(x10)

bne x22, x24, Error

# next byte
sb x19, 3(x10)
lui x24, 0x21210
lw x22, 0(x10)

bne x22, x24, Error


# Test 24 - SW
addi x31, x0, 'l'
addi x7, x7, 0x1

# x19 = 0x87654321
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 

sw x19, 4(x10)
lw x22, 4(x10)

bne x19, x22, Error

# Test 25 - SH

addi x31, x0, 'o'
addi x7, x7, 0x1

#Store and load address
lui x10, 0x10000

# x19 = 0x87654321
lui x26, 0x43210
srl x26, x26, 16
lui x20, 0x87650
add x19, x26, x20 

sw x19, 0(x10) # zero out the bits 

# rightmost 2 bytes

# store 0x1234
lui x26, 0x12340
srl x26, x26, 16
sh x26, 0(x10)
lw x22, 0(x10)

# Should be 0x87651234
lui x26, 0x12340
srl x26, x26, 16
lui x20, 0x87650
add x24, x26, x20 

bne x22, x24, Error


# leftmost 2 bytes

# store 0x4321
lui x26, 0x43210
srl x26, x26, 16
sh x26, 2(x10)
lw x22, 0(x10)

# Should be 0x43211234
lui x25, 0x12340
srl x25, x25, 16
lui x20, 0x43210
add x24, x25, x20 

bne x22, x24, Error

# Test 25 - SH

addi x31, x0, 'p'
addi x7, x7, 0x1

lui x10, 0x10000
addi x11, x10, 0x4
addi x26, x0, 0x5
sw x26, -4(x11)
lw x5, 0(x10)
bne x5, x26, Error

# # Test 26 - Stalls with JALR
addi x31, x0, 'q'
addi x7, x7, 0x1
jal x1, jalr_stall
lw x8, 0(x11)
bne x8, x6, Error


jalr_stall:
addi x6, x0, 0x6
lui x11, 0x10000 # create address
addi x10, x0, 0x400
sll x10, x10, 0x8
add x11, x10, x11
sw x6, 0(x11)
jalr x1, x1, 0x0  

# # 27 Instructions after branch don't execute
addi x31, x0, 'r'
addi x7, x7, 0x1
addi x2, x0, 0x2
add x20, x0, x0
beq x0, x0, skip
addi x20, x20, 0xa
skip:
add x0, x0, x0 #two noops because data might not be forwarded
add x0, x0, x0
addi x20, x20, 0x2
bne x2, x20, Error





# NEED TO CHECK operation when WRITING TO ICACHE AND DCACHE TOGETHER
# CHECK LOADS followed by STORES and STORES followed by LOADS
# test that r0 is not forwarded
# addi x0 x1 0x5
# addi x1 x0 0x5 (result should 0x5, but if r0 is forwarded result will be 10)

j Pass

Error:
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'I'
jal x1, WriteUART
addi x4, x0, 'L'
jal x1, WriteUART
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'I'
jal x1, WriteUART
addi x4, x0, 'L'
jal x1, WriteUART
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'I'
jal x1, WriteUART
addi x4, x0, 'L'
jal x1, WriteUART
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'I'
jal x1, WriteUART
addi x4, x0, 'L'
jal x1, WriteUART
addi x4, x0, ':'
jal x1, WriteUART
addi x4, x0, ' '
jal x1, WriteUART
add x4, x0, x31
jal x1, WriteUART
addi x4, x0, '\n'
jal x1, WriteUART
j Done

Flag:
# Used for debugssing purposes
addi x4, x0, 'F'
jal x1, WriteUART
addi x4, x0, 'L'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'G'
jal x1, WriteUART
addi x4, x0, ':'
jal x1, WriteUART
addi x4, x0, ' '
jal x1, WriteUART
add x4, x0, x31
jal x1, WriteUART
addi x4, x0, '\n'
jal x1, WriteUART
j Done

Pass:
# Write success over serial
addi x4, x0, 'P'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'P'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'P'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'P'
jal x1, WriteUART
addi x4, x0, 'A'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, 'S'
jal x1, WriteUART
addi x4, x0, '\n'
jal x1, WriteUART
j Done

Done:
addi x30, x0, 0x1
j Done

WriteUART:
# Return address is in x1
# Byte to write is in x4
# UART addressing:
# 0x80000000: bit1=dout_valid, bit0=din_ready
# 0x80000004: read data from UART
# 0x80000008: write data to UART

lui x2, 0x80000    # actually loads 0x80000000 into x2
lw x3, 0(x2)
andi x3, x3, 0x1
beq x3, x0, WriteUART
sw x4, 8(x2)
jalr x0, x1, 0
