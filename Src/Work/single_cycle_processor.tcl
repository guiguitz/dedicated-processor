# Load Quartus Prime Tcl Project package
package require ::quartus::project

set COMPONENTS_PATH ../components
set TESTBENCHES_PATH ../testbenches

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "single_cycle_processor"]} {
		puts "Project single_cycle_processor is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists single_cycle_processor]} {
		project_open -revision single_cycle_processor single_cycle_processor
	} else {
		project_new -revision single_cycle_processor single_cycle_processor
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "MAX 10"
	set_global_assignment -name DEVICE 10M50DAF484C7G
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 21.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:06:28  DECEMBER 09, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION 21.1.0

	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/register_file.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/two_bits_shifter.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/memd.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/multiplicador.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/mux41.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/hdl_register.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/alu.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/extensor.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/memi.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/mux21.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/pc.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/adder.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/interrupt_address_registers.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/single_cycle_control_unit.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/single_cycle_data_path.vhd
	set_global_assignment -name VHDL_FILE $COMPONENTS_PATH/single_cycle_processor.vhd
	set_global_assignment -name VHDL_FILE $TESTBENCHES_PATH/tb_single_cycle_processor.vhd

	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY .
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# set_location_assignment PIN_B10 -to s[3]
	# set_location_assignment PIN_A10 -to s[2]
	# set_location_assignment PIN_A9 -to s[1]
	# set_location_assignment PIN_A8 -to s[0]

	# set_location_assignment PIN_C12 -to x[3]
	# set_location_assignment PIN_D12 -to x[2]
	# set_location_assignment PIN_C11 -to x[1]
	# set_location_assignment PIN_C10 -to x[0]

	# set_location_assignment PIN_A14 -to y[3]
	# set_location_assignment PIN_A13 -to y[2]
	# set_location_assignment PIN_B12 -to y[1]
	# set_location_assignment PIN_A12 -to y[0]

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
