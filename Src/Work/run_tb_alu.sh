#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"

ghdl --clean

# Analyzing vhdl files
ghdl -a $COMPONENTS_PATH/alu.vhd
ghdl -a $TESTBENCHES_PATH/tb_alu.vhd

# Elaborating SoC
ghdl -e tb_alu
ghdl -r tb_alu --vcd=tb_alu.vcd --stop-time=1us

# Wave view
gtkwave -f tb_alu.vcd --script=gtkwave_print.tcl
