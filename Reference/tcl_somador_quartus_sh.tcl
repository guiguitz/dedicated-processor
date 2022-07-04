# Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus Prime License Agreement,
# the Altera MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Altera and sold by Altera or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: tcl_somador_quartus_sh.tcl
# Generated on: Thu Dec 09 15:38:20 2021

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "somador"]} {
		puts "Project somador is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists somador]} {
		project_open -revision somador somador
	} else {
		project_new -revision somador somador
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "MAX 10"
	set_global_assignment -name DEVICE 10M50DAF484C7G
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 15.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:06:28  DECEMBER 09, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION 15.1.0
    # local onde se encontra o seu arquivo fonte do design em VHDL.
    set_global_assignment -name VHDL_FILE ../somador.vhd
    # local onde vai ser gerado os seus arquivos de saída.
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
    set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
    set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

  set_location_assignment PIN_B10 -to s[3]
  set_location_assignment PIN_A10 -to s[2]
  set_location_assignment PIN_A9 -to s[1]
  set_location_assignment PIN_A8 -to s[0]
  
  set_location_assignment PIN_C12 -to x[3]
  set_location_assignment PIN_D12 -to x[2]
  set_location_assignment PIN_C11 -to x[1]
  set_location_assignment PIN_C10 -to x[0]
  
  set_location_assignment PIN_A14 -to y[3]
  set_location_assignment PIN_A13 -to y[2]
  set_location_assignment PIN_B12 -to y[1]
  set_location_assignment PIN_A12 -to y[0]

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
