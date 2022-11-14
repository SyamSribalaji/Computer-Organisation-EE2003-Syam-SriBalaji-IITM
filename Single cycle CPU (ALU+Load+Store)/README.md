# Assignment - ALU + Load/Store 

Implement ALU and Load/Store instructions from RISC-V RV32I set

## Note

- This is a part of course work - EE2003: Computer Organisation (Jul-Nov, 2022) from IIT-M. For this Single cycle CPU (ALU+Load_Store), I designed hardware description on Verilog (cpu.v) and synthesis in Vivado. And I have Implemented it in PYNQ-1 board. And this testbench is not a part of my work (done by course Instructors).

## Goals

- Implement all the instructions in the RISC-V RV32I ISA that correspond to Load/Store (memory) operations, as well as all the ALU operations.

## Given

The eventual goal of the single cycle CPU is to implement all instructions (except `FENCE`, `ECALL` and `EBREAK`) in the RV32I instruction set (pg. 130 of riscv-spec.pdf - attached).  For this, we will assume a simplified memory model, where data and instruction memory can be read in a single cycle (provide the address, and the memory responds with data in the same cycle), while allowing write at the next edge of the clock.  You are already provided with memory modules that behave as required, along with the following:

- Test bench with test cases having Load/Store along with ALU operations
    - Test bench will feed one input instruction per clock cycle
    - All registers are assumed initialized to 0 - this should be done in your code
- IMEM and DMEM are given as modules in the test bench.  You should not change them, but have to follow the read/write timing patterns from them.
- `cpu_tb.v` is the top test bench - the interface for your CPU code must match this.

## Details on the assignment

You need to implement code for the `cpu` module, that will read in the instructions and execute them.  For this assignment, you can assume that the program counter (PC) always increments by 4 on each clock cycle.  For the assignment involving branching, this cannot be assumed and you will have to implement the proper changes in PC.

You can run all the test cases by typing in the following command at the command line:

```sh
$ ./run.sh
```

This will compile the code using the `iverilog` compiler and run it against some test cases.  In case you add more files for your modules, you need to update the list of files in `program_file.txt`.

### Test cases

Test cases are given under the `test/` folder, with appropriate imem and dmem files.  Each imem file contains a set of instructions at the end that will dump all the register values into the first several locations in dmem.  The test bench will then read out these values from dmem and compare with expected results.

The file `dump.s` in the top folder also shows an example of assembly code that you can write to create your own test cases.  You can compile and disassemble as follows to generate the instruction codes.  Note that function calls need to be handled with care: the addresses for functions are not resolved till the Link step completes, so disassembled code will not look or work as expected.

```bash
$ riscv32-unknown-elf-gcc -c dump.s
$ riscv32-unknown-elf-objdump -d -Mnumeric,no-aliases dump.o
```
