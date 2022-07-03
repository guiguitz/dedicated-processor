#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"
UTIL_PATH="../util"

ghdl --clean

# Analyzing vhdl files
ghdl -a $UTIL_PATH/binary_instructions.vhd
ghdl -a $COMPONENTS_PATH/memi.vhd
ghdl -a $TESTBENCHES_PATH/tb_memi.vhd

# Elaborating SoC
ghdl -e tb_memi
ghdl -r tb_memi --vcd=tb_memi.vcd --stop-time=1us

# Wave view
gtkwave -f tb_memi.vcd --script=gtkwave_print.tcl
