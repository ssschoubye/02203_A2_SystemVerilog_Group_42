# 02203 Assignment 2 – Edge Detection (SystemVerilog)

__The repository is not yet complete see the TODO section__

This repository contains a **SystemVerilog implementation** of **Assignment 2** in *02203 Design of Digital Systems (Fall 2025)* at DTU.

The goal of this assignment is to design, simulate, and implement a digital system for **edge detection** in images using a custom accelerator and memory interface.

The design flow follows a **top-down, simulation-based methodology** and targets the **Xilinx Nexys 4 DDR / Nexys A7 FPGA board**.

Otto Westy Rasmussen, S203838, S203838@dtu.dk

## Repository Structure

```bash
├── README.md                 # This file
├── other_images/             # Example PGM images for testing
│   ├── cross.pgm
│   ├── illusion.pgm
│   ├── kaleidoscope.pgm
│   └── pattern.pgm
├── serial_interface/         # Serial interface utility
│   ├── serial_interface.py
│   └── Serial interface.exe
├── task2/                    # Accelerator, memory, and testbench
│   ├── acc2.sv
│   ├── clock.sv
│   ├── memory2.sv
│   ├── pic1.pgm
│   ├── test2.sv
└── task3/                    # Extended system and UART
    ├── clock_divider.sv
    ├── debouncer.sv
    ├── memory3.sv
    ├── Nexys4DDR_edge.xdc
    ├── top.sv
    └── uart.vhd
```

## Simulation and Tools

- **FPGA Synthesis and Testing:**  
  - Tool: [Xilinx Vivado](https://www.xilinx.com/products/design-tools/vivado.html)  
  - Target board: Nexys 4 DDR or Nexys A7  
  - Use `Nexys4DDR_edge.xdc` for FPGA pin constraints   

## TODO
- [ ] Task 3
- [ ] Update serial interface

## Notes
- This repo provides a **SystemVerilog** version of the assignment (original was in VHDL).  
- Use at your own risk if substituting for the official VHDL files.
