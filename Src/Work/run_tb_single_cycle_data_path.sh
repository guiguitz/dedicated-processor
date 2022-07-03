#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"
UTIL_PATH="../util"

ghdl --clean

# Analyzing vhdl files
ghdl -a $UTIL_PATH/binary_instructions.vhd
ghdl -a $UTIL_PATH/control_unit_outputs.vhd

ghdl -a $COMPONENTS_PATH/pc.vhd
ghdl -a $COMPONENTS_PATH/adder.vhd
ghdl -a $COMPONENTS_PATH/banco_registradores.vhd
ghdl -a $COMPONENTS_PATH/ula.vhd
ghdl -a $COMPONENTS_PATH/mux21.vhd
ghdl -a $COMPONENTS_PATH/extensor.vhd
ghdl -a $COMPONENTS_PATH/two_bits_shifter.vhd
ghdl -a $COMPONENTS_PATH/single_cycle_data_path.vhd

ghdl -a $TESTBENCHES_PATH/tb_single_cycle_data_path.vhd

# Elaborating SoC
ghdl -e tb_single_cycle_data_path
ghdl -r tb_single_cycle_data_path --vcd=tb_single_cycle_data_path.vcd --stop-time=1us

# Wave view
gtkwave -f tb_single_cycle_data_path.vcd --script=gtkwave_print.tcl
