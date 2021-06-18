start Assembly_TestBench
file copy -force ../../../software/asmtest/asmtest.mif imem_blk_ram.mif
file copy -force ../../../software/asmtest/asmtest.mif dmem_blk_ram.mif
file copy -force ../../../software/asmtest/asmtest.mif bios_mem.mif
add wave Assembly_TestBench/*
add wave Assembly_TestBench/cpu/*
add wave Assembly_TestBench/cpu/regfile/registers
run 5000us
