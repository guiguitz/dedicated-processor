#!/bin/bash

COMPONENTS_PATH="../components"
TESTBENCHES_PATH="../testbenches"

ghdl --clean

# Analyzing vhdl files
ghdl -a $COMPONENTS_PATH/banco_registradores.vhd
ghdl -a $COMPONENTS_PATH/deslocador.vhd
ghdl -a $COMPONENTS_PATH/memd.vhd
ghdl -a $COMPONENTS_PATH/multiplicador.vhd
ghdl -a $COMPONENTS_PATH/mux41.vhd
ghdl -a $COMPONENTS_PATH/hdl_register.vhd
ghdl -a $COMPONENTS_PATH/ula.vhd
ghdl -a $COMPONENTS_PATH/extensor.vhd
ghdl -a $COMPONENTS_PATH/memi.vhd
ghdl -a $COMPONENTS_PATH/mux21.vhd
ghdl -a $COMPONENTS_PATH/pc.vhd
ghdl -a $COMPONENTS_PATH/adder.vhd
ghdl -a $COMPONENTS_PATH/interrupt_address_registers.vhd
ghdl -a $COMPONENTS_PATH/single_cycle_control_unit.vhd
ghdl -a $COMPONENTS_PATH/single_cycle_data_path.vhd
ghdl -a $COMPONENTS_PATH/single_cycle_processor.vhd
ghdl -a $TESTBENCHES_PATH/tb_single_cycle_processor.vhd
ghdl -a $TESTBENCHES_PATH/tb_single_cycle_processor.vhd

# Elaborating SoC
ghdl -e tb_single_cycle_processor
ghdl -r tb_single_cycle_processor --vcd=tb_single_cycle_processor.vcd --stop-time=1us

# # Wave view
gtkwave -f tb_single_cycle_processor.vcd --script=gtkwave_print.tcl
