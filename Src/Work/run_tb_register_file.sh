#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"
UTIL_PATH="../util"

ghdl --clean

# Analyzing vhdl files
ghdl -a $UTIL_PATH/testbench_constants.vhd
ghdl -a $COMPONENTS_PATH/register_file.vhd
ghdl -a $TESTBENCHES_PATH/tb_register_file.vhd

# Elaborating SoC
ghdl -e tb_register_file
ghdl -r tb_register_file --vcd=tb_register_file.vcd --stop-time=1us

# Wave view
gtkwave -f tb_register_file.vcd --script=gtkwave_print.tcl
