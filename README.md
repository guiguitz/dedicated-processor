# dedicated-processor

## Processor Schematic
![schematic](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/processor-schematic.png)

## DataPath Schematic
![schematic](https://github.com/guiguitz/dedicated-processor/blob/main/Docs/datapath-schematic.png)

## Testbenches
- hdl_register: `Src/Testbenches/tb_hdl_register.vhd`
- ALU: `Src/Testbenches/tb_alu.vhd`
- Instruction Memory (memi): `Src/Testbenches/tb_memi.vhd`
- Data Memory (memd): `Src/Testbenches/tb_memd.vhd`
- Register File: `Src/Testbenches/tb_register_file.vhd`
- DataPath: `Src/Testbenches/tb_single_cycle_data_path.vhd`
- Control Unit: `Src/Testbenches/tb_single_cycle_control_unit.vhd`
- Processor: `Src/Testbenches/tb_single_cycle_processor.vhd`

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

## How to run using Quartus II
### Quartus II
```bash
cd Src/Work
sh run_quartus_single_cycle_processor.sh
```

## Peripherals development
- [X] Design, implementation and synthesis of the interrupt controller
- [X] Simulation and integration of the interrupt controller with the CPU
- [ ] CPU test with interrupt controller in FPGA kit
- [ ] Design, implementation and synthesis of the GPIOs interface
- [ ] Simulation and integration of the GPIOs interface with the CPU and memory
- [ ] CPU Test with the GPIOs Interface in the FPGA Kit
- [X] Design, implementation of programmable TIMERs
- [X] Simulation and integration of programmable TIMERs with the CPU and memory
- [ ] CPU Test of Programmable TIMERs in FPGA Kit
- [ ] UART design, implementation and synthesis
- [ ] UART simulation and integration with CPU and memory
- [ ] CPU Test with UART in FPGA Kit

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
