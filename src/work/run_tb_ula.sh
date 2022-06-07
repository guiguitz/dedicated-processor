#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"

ghdl --clean

# Analyzing vhdl files
ghdl -a $COMPONENTS_PATH/ula.vhd
ghdl -a $TESTBENCHES_PATH/tb_ula.vhd

# Elaborating SoC
ghdl -e tb_ula
ghdl -r tb_ula --vcd=tb_ula.vcd --stop-time=1us

# Wave view
gtkwave -f tb_ula.vcd --script=gtkwave_print.tcl
