#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"

ghdl --clean

# Analyzing vhdl files
ghdl -a $COMPONENTS_PATH/memi.vhd
ghdl -a $TESTBENCHES_PATH/tb_memi.vhd

# Elaborating SoC
ghdl -e tb_
ghdl -r tb_memi --vcd=tb_memi.vcd --stop-time=1us

# Wave view
gtkwave -f tb_memi.vcd --script=gtkwave_print.tcl
