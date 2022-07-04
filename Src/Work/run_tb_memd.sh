#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"
UTIL_PATH="../util"

ghdl --clean

# Analyzing vhdl files
ghdl -a $UTIL_PATH/custom_types.vhd
ghdl -a $UTIL_PATH/testbench_constants.vhd
ghdl -a $COMPONENTS_PATH/memd.vhd
ghdl -a $TESTBENCHES_PATH/tb_memd.vhd

# Elaborating SoC
ghdl -e tb_memd
ghdl -r tb_memd --vcd=tb_memd.vcd --stop-time=1us

# Wave view
gtkwave -f tb_memd.vcd --script=gtkwave_print.tcl
