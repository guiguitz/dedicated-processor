# dedicated-processor

## General TODO
- [X] hdl_register testbench
- [X] ULA testbench
- [X] Instruction Memory (memi) testbench
- [X] Data Memory (memd) testbench
- [ ] Add seven-segment LEDs to improve the debuggability
- [ ] Translate all RTL code to English
## Single Cycle TODO
- [X] Draw DataPath
- [X] Implement the RTL for Single Cycle DataPath (`single_cycle_data_path.vhd`)
- [X] Implement the RTL for Single Cycle Control Unit (`single_cycle_control_unit.vhd`)
- [X] Implement the RTL for Single Cycle processor (`single_cycle_processor.vhd`)
- [ ] Implement the DataPath testbench (`tb_single_cycle_data_path.vhd`)
- [X] Implement the Control Unit testbench (`tb_single_cycle_control_unit.vhd`)
- [X] Implement the Processor testbench (`tb_single_cycle_processor.vhd`)
- [X] Simulations with dummy instructions
- [ ] Simulations with R-type instructions
- [ ] Simulations with I-type instructions
- [ ] Simulations with Branch-type instructions
- [ ] Test on FPGA
- [ ] Update the DataPath adding the correct signal/component names

## Pipeline TODO
- [ ] Draw DataPath

## How to run
### DataPath testbenches
```bash
cd src/work
sh run_tb_single_cycle_data_path.sh; # Single Cycle
sh run_tb_pipeline_data_path.sh; # Pipeline
```
### Control Unit testbenches
```bash
cd src/work
sh run_tb_single_cycle_control_unit.sh; # Single Cycle
sh run_tb_pipeline_control_unit.sh; # Pipeline
```
### Processor testbenches
```bash
cd src/work
sh run_tb_single_cycle_processor.sh; # Single Cycle
sh run_tb_pipeline_processor.sh; # Pipeline
```

## Dependencies

- [MSYS2 64 bit](https://www.msys2.org/)
  - gcc (Rev8, Built by MSYS2 project) 11.2.0
  - GNU gdb (GDB) 11.2
  - [Python 3.9.12](https://packages.msys2.org/package/mingw-w64-x86_64-python)
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
