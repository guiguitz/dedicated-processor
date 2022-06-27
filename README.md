# dedicated-processor

## General TODO
- [ ] Add seven-segment LEDs to improve the debuggability
- [ ] Translate all RTL code to English
## Single Cycle Processor development
- [X] Draw DataPath
- [X] Implement the RTL for Single Cycle DataPath (`Src/Components/single_cycle_data_path.vhd`)
- [X] Implement the RTL for Single Cycle Control Unit (`Src/Components/single_cycle_control_unit.vhd`)
- [X] Implement the RTL for Single Cycle processor (`Src/Components/single_cycle_processor.vhd`)
- [X] hdl_register testbench (`Src/Testbenches/tb_hdl_register.vhd`)
- [X] ULA testbench (`Src/Testbenches/tb_ula.vhd`)
- [X] Instruction Memory (memi) testbench (`Src/Testbenches/tb_memi.vhd`)
- [X] Data Memory (memd) testbench (`Src/Testbenches/tb_memd.vhd`)
- [ ] Implement the DataPath testbench (`Src/Testbenches/tb_single_cycle_data_path.vhd`)
- [X] Implement the Control Unit testbench (`Src/Testbenches/tb_single_cycle_control_unit.vhd`)
- [X] Implement the Processor testbench (`Src/Testbenches/tb_single_cycle_processor.vhd`)
- [X] Simulations with dummy instructions
- [ ] Simulations with R-type instructions
- [ ] Simulations with I-type instructions
- [ ] Simulations with Branch-type instructions
- [ ] Test on FPGA
- [ ] Update the DataPath adding the correct signal/component names

## Peripherals development
- [ ] Design, implementation and synthesis of the interrupt controller
- [ ] Simulation and integration of the interrupt controller with the CPU
- [ ] CPU test with interrupt controller in FPGA kit
- [ ] Design, implementation and synthesis of the GPIOs interface
- [ ] Simulation and integration of the GPIOs interface with the CPU and memory
- [ ] CPU Test with the GPIOs Interface in the FPGA Kit
- [ ] Design, implementation of programmable TIMERs
- [ ] Simulation and integration of programmable TIMERs with the CPU and memory
- [ ] CPU Test of Programmable TIMERs in FPGA Kit
- [ ] UART design, implementation and synthesis
- [ ] UART simulation and integration with CPU and memory
- [ ] CPU Test with UART in FPGA Kit

## How to run
### DataPath testbenches
```bash
cd Src/Work
sh run_tb_single_cycle_data_path.sh; # Single Cycle
```
### Control Unit testbenches
```bash
cd Src/Work
sh run_tb_single_cycle_control_unit.sh; # Single Cycle
```
### Processor testbenches
```bash
cd Src/Work
sh run_tb_single_cycle_processor.sh; # Single Cycle
```

## Dependencies

- [msys2-x86_64-20220603](https://www.msys2.org)
  - gcc (Rev8, Built by MSYS2 project) 11.2.0
  - GNU gdb (GDB) 11.2
  - [Python 3.9.12](https://packages.msys2.org/package/mingw-w64-x86_64-python)
- [GHDL v0.37](https://github.com/ghdl/ghdl/releases/download/v0.37/ghdl-0.37-mingw32-mcode.zip)
- [gtkwave-3.3.100](https://sourceforge.net/projects/gtkwave/files/gtkwave-3.3.100-bin-win32)
- [Yosys nightly-20211006](https://github.com/YosysHQ/fpga-toolchain/releases)

## Additional Softwares
- [Quartus-lite-21.1.0.842](https://www.intel.com/content/www/us/en/software-kit/684216/intel-quartus-prime-lite-edition-design-software-version-21-1-for-windows.html)
  - Quartus Lite
  - Questa
  - MAX 10 FPGA
- [Git](https://git-scm.com/downloads)
- [VSCode](https://code.visualstudio.com/download)
  - [TerosHDL v2.0.7](https://terostechnology.github.io/terosHDLdoc/about/installing.html)
  - [VHDL Formatter](https://marketplace.visualstudio.com/items?itemName=Vinrobot.vhdl-formatter)
  - [istyle-verilog-formatter v1.23](https://github.com/thomasrussellmurphy/istyle-verilog-formatter/releases/tag/v1.23)
  - [VHDL](https://marketplace.visualstudio.com/items?itemName=puorc.awesome-vhdl)
  - [GHDL Interface](https://marketplace.visualstudio.com/items?itemName=johannesbonk.ghdl-interface)
