# dedicated-processor

## Introduction

This project was developed as a work in the discipline of Computer Architecture and Organization Lab at UFMG - Prof. Ricardo de Oliveira Duarte - Department of Electronic Engineering.

The project aims to implemented a 32-bit processor, inspired in the RISC-V. Implemented in VHDL using GHDL for synthesis and gtkwave for wave view and simulations. Tested in the Altera DE10 FPGA development kit.

## General Flow of the Project
1. Definition of initial project requirements: [project requirements](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/template_mapa_de_memoria%20-%20Guilherme%2C%20Matheus%20e%20Thiago.pdf)

2. Detailing the project requirements: [instruction set](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/template_discriminacao_instrucao%20-%20Guilherme%2C%20Matheus%20e%20Thiago.pdf)

3. Single cycle CPU modeling (DataPath).

4. Main Control Unit modeling: [Control signals](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/template_discriminacao_sinais_ctrl.pdf)

5. CPU implementation in VHDL.

6. CPU verification and validation (Testbench and FPGA).

7. Interrupt controller modeling.

8. Implementation and validation of peripherals, Timer, Uart and Gpio.


## Processor Schematic
![schematic](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/processor-schematic.png)

## DataPath Schematic
![schematic](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/datapath-schematic.png)

## Peripherals
- GPIO
- TIMER
- UART

## Testbenches
- [hdl_register](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_hdl_register.vhd)
- [ALU](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_alu.vhd)
- [Instruction Memory (memi)](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_memi.vhd)
- [Data Memory (memd)](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_memd.vhd)
- [Register File](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_register_file.vhd)
- [DataPath](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_single_cycle_data_path.vhd)
- [Control Unit](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_single_cycle_control_unit.vhd)
- [Processor](https://github.com/guiguitz/dedicated-processor/blob/main/Src/Testbenches/tb_single_cycle_processor.vhd)

## How to run using ghdl + gtkwave
### DataPath testbench
```bash
cd Src/Work
sh run_tb_single_cycle_data_path.sh
```
### Control Unit testbench
```bash
cd Src/Work
sh run_tb_single_cycle_control_unit.sh
```
### Processor testbench
```bash
cd Src/Work
sh run_tb_single_cycle_processor.sh
```

## Simulation example

In the following image we can see the wave view for the alu component, on its testbench.

![schematic](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/alu_debug.png)

## How to run using Quartus II
### Quartus II
```bash
cd Src/Work
sh run_quartus_single_cycle_processor.sh
```

## Dependencies

- [msys2-x86_64-20220603](https://www.msys2.org)
  - gcc (Rev8, Built by MSYS2 project) 11.2.0
  - GNU gdb (GDB) 11.2
  - [Python 3.9.12](https://packages.msys2.org/package/mingw-w64-x86_64-python)
- [GHDL v0.37](https://github.com/ghdl/ghdl/releases/download/v0.37/ghdl-0.37-mingw32-mcode.zip)
- [gtkwave-3.3.100](https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.100-bin-win32)
- [Quartus-lite-21.1.0.842](https://www.intel.com/content/www/us/en/software-kit/684216/intel-quartus-prime-lite-edition-design-software-version-21-1-for-windows.html)
  - Quartus Lite
  - MAX 10 FPGA

## Additional Softwares
- [Git](https://git-scm.com/downloads)
- [GNU make v3.81](http://gnuwin32.sourceforge.net/packages/make.htm)
- [VSCode](https://code.visualstudio.com/download)
  - [VHDL Formatter](https://marketplace.visualstudio.com/items?itemName=Vinrobot.vhdl-formatter)
  - [VHDL](https://marketplace.visualstudio.com/items?itemName=puorc.awesome-vhdl)
  - [GHDL Interface](https://marketplace.visualstudio.com/items?itemName=johannesbonk.ghdl-interface)

## Contact the Authors
Guilherme Amorim: `guilherme.vini65@gmail.com`

Matheus Silva: `mateusilva73@gmail.com`

Thiago Santos: `thiagoSantos.on@gmail.com`
