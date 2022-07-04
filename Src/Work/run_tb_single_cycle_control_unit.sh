#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"
UTIL_PATH="../util"

ghdl --clean

# Analyzing vhdl files
ghdl -a $UTIL_PATH/testbench_constants.vhd
ghdl -a $COMPONENTS_PATH/single_cycle_control_unit.vhd
ghdl -a $TESTBENCHES_PATH/tb_single_cycle_control_unit.vhd

# Elaborating SoC
ghdl -e tb_single_cycle_control_unit
ghdl -r tb_single_cycle_control_unit --vcd=tb_single_cycle_control_unit.vcd --stop-time=1us

# Wave view
gtkwave -f tb_single_cycle_control_unit.vcd --script=gtkwave_print.tcl
