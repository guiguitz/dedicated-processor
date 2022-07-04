# Copyright (C) 2021  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: single_cycle_processor.tcl
# Generated on: Mon Jul  4 13:08:05 2022

# Load Quartus Prime Tcl Project package
package require ::quartus::project

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
	set_global_assignment -name LAST_QUARTUS_VERSION "21.1.0 Lite Edition"
	set_global_assignment -name VHDL_FILE ../Components/single_cycle_processor.vhd
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY .
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VHDL_FILE ../components/register_file.vhd
	set_global_assignment -name VHDL_FILE ../components/two_bits_shifter.vhd
	set_global_assignment -name VHDL_FILE ../components/memd.vhd
	set_global_assignment -name VHDL_FILE ../components/multiplicador.vhd
	set_global_assignment -name VHDL_FILE ../components/mux41.vhd
	set_global_assignment -name VHDL_FILE ../components/hdl_register.vhd
	set_global_assignment -name VHDL_FILE ../components/alu.vhd
	set_global_assignment -name VHDL_FILE ../components/extensor.vhd
	set_global_assignment -name VHDL_FILE ../components/memi.vhd
	set_global_assignment -name VHDL_FILE ../components/mux21.vhd
	set_global_assignment -name VHDL_FILE ../components/pc.vhd
	set_global_assignment -name VHDL_FILE ../components/adder.vhd
	set_global_assignment -name VHDL_FILE ../components/interrupt_address_registers.vhd
	set_global_assignment -name VHDL_FILE ../components/single_cycle_control_unit.vhd
	set_global_assignment -name VHDL_FILE ../components/single_cycle_data_path.vhd
	set_global_assignment -name VHDL_FILE ../components/single_cycle_processor.vhd
	set_global_assignment -name VHDL_FILE ../testbenches/tb_single_cycle_processor.vhd
	set_global_assignment -name EDA_RUN_TOOL_AUTOMATICALLY OFF -section_id eda_simulation
	set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
	set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH tb_single_cycle_processor -section_id eda_simulation
	set_global_assignment -name EDA_TEST_BENCH_NAME tb_single_cycle_processor -section_id eda_simulation
	set_global_assignment -name EDA_DESIGN_INSTANCE_NAME NA -section_id tb_single_cycle_processor
	set_global_assignment -name EDA_TEST_BENCH_RUN_SIM_FOR "200 ns" -section_id tb_single_cycle_processor
	set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME tb_single_cycle_processor -section_id tb_single_cycle_processor
	set_global_assignment -name EDA_TEST_BENCH_FILE source/tb_single_cycle_processor.vhd -section_id tb_single_cycle_processor
	set_global_assignment -name VHDL_FILE ../Util/custom_types.vhd
	set_global_assignment -name VHDL_FILE ../Util/testbench_constants.vhd
	set_global_assignment -name VHDL_FILE ../Components/register_file.vhd
	set_global_assignment -name VHDL_FILE ../Components/two_bits_shifter.vhd
	set_global_assignment -name VHDL_FILE ../Components/memd.vhd
	set_global_assignment -name VHDL_FILE ../Components/multiplicador.vhd
	set_global_assignment -name VHDL_FILE ../Components/mux41.vhd
	set_global_assignment -name VHDL_FILE ../Components/hdl_register.vhd
	set_global_assignment -name VHDL_FILE ../Components/alu.vhd
	set_global_assignment -name VHDL_FILE ../Components/extensor.vhd
	set_global_assignment -name VHDL_FILE ../Components/memi.vhd
	set_global_assignment -name VHDL_FILE ../Components/mux21.vhd
	set_global_assignment -name VHDL_FILE ../Components/pc.vhd
	set_global_assignment -name VHDL_FILE ../Components/adder.vhd
	set_global_assignment -name VHDL_FILE ../Components/seven_seg_decoder.vhd
	set_global_assignment -name VHDL_FILE ../Components/interrupt_address_registers.vhd
	set_global_assignment -name VHDL_FILE ../Components/single_cycle_control_unit.vhd
	set_global_assignment -name VHDL_FILE ../Components/single_cycle_data_path.vhd
	set_global_assignment -name VHDL_FILE ../Testbenches/tb_single_cycle_processor.vhd
	set_global_assignment -name EDA_TEST_BENCH_FILE ../Testbenches/tb_single_cycle_processor.vhd -section_id tb_single_cycle_processor
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
	set_location_assignment PIN_C10 -to clock
	set_location_assignment PIN_C11 -to reset
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clock
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset
	set_location_assignment PIN_C17 -to display_1[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[6]
	set_location_assignment PIN_D17 -to display_1[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[5]
	set_location_assignment PIN_E16 -to display_1[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[4]
	set_location_assignment PIN_C16 -to display_1[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[3]
	set_location_assignment PIN_C15 -to display_1[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[2]
	set_location_assignment PIN_E15 -to display_1[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[1]
	set_location_assignment PIN_C14 -to display_1[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_1[0]
	set_location_assignment PIN_B17 -to display_2[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[6]
	set_location_assignment PIN_A18 -to display_2[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[5]
	set_location_assignment PIN_A17 -to display_2[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[4]
	set_location_assignment PIN_B16 -to display_2[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[3]
	set_location_assignment PIN_E18 -to display_2[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[2]
	set_location_assignment PIN_D18 -to display_2[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[1]
	set_location_assignment PIN_C18 -to display_2[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_2[0]
	set_location_assignment PIN_B22 -to display_3[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[6]
	set_location_assignment PIN_C22 -to display_3[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[5]
	set_location_assignment PIN_B21 -to display_3[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[4]
	set_location_assignment PIN_A21 -to display_3[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[3]
	set_location_assignment PIN_B19 -to display_3[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[2]
	set_location_assignment PIN_A20 -to display_3[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[1]
	set_location_assignment PIN_B20 -to display_3[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_3[0]
	set_location_assignment PIN_E17 -to display_4[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[6]
	set_location_assignment PIN_D19 -to display_4[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[5]
	set_location_assignment PIN_C20 -to display_4[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[4]
	set_location_assignment PIN_C19 -to display_4[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[3]
	set_location_assignment PIN_E21 -to display_4[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[2]
	set_location_assignment PIN_E22 -to display_4[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[1]
	set_location_assignment PIN_F21 -to display_4[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_4[0]
	set_location_assignment PIN_F20 -to display_5[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[6]
	set_location_assignment PIN_F19 -to display_5[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[5]
	set_location_assignment PIN_H19 -to display_5[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[4]
	set_location_assignment PIN_J18 -to display_5[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[3]
	set_location_assignment PIN_E19 -to display_5[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[2]
	set_location_assignment PIN_E20 -to display_5[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[1]
	set_location_assignment PIN_F18 -to display_5[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_5[0]
	set_location_assignment PIN_N20 -to display_6[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[6]
	set_location_assignment PIN_N19 -to display_6[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[5]
	set_location_assignment PIN_M20 -to display_6[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[4]
	set_location_assignment PIN_N18 -to display_6[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[3]
	set_location_assignment PIN_L18 -to display_6[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[2]
	set_location_assignment PIN_K20 -to display_6[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[1]
	set_location_assignment PIN_J20 -to display_6[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_6[0]
	set_location_assignment PIN_B11 -to leds[9]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[9]
	set_location_assignment PIN_A11 -to leds[8]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[8]
	set_location_assignment PIN_D14 -to leds[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[7]
	set_location_assignment PIN_E14 -to leds[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[6]
	set_location_assignment PIN_C13 -to leds[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[5]
	set_location_assignment PIN_D13 -to leds[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[4]
	set_location_assignment PIN_B10 -to leds[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[3]
	set_location_assignment PIN_A10 -to leds[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[2]
	set_location_assignment PIN_A9 -to leds[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[1]
	set_location_assignment PIN_A8 -to leds[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to leds[0]

	# Including default assignments
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON -family "MAX 10"
	set_global_assignment -name TIMING_ANALYZER_REPORT_WORST_CASE_TIMING_PATHS OFF -family "MAX 10"
	set_global_assignment -name TIMING_ANALYZER_CCPP_TRADEOFF_TOLERANCE 0 -family "MAX 10"
	set_global_assignment -name TDC_CCPP_TRADEOFF_TOLERANCE 0 -family "MAX 10"
	set_global_assignment -name TIMING_ANALYZER_DO_CCPP_REMOVAL ON -family "MAX 10"
	set_global_assignment -name DISABLE_LEGACY_TIMING_ANALYZER OFF -family "MAX 10"
	set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON -family "MAX 10"
	set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 2 -family "MAX 10"
	set_global_assignment -name SYNTH_RESOURCE_AWARE_INFERENCE_FOR_BLOCK_RAM ON -family "MAX 10"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS" -family "MAX 10"
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON -family "MAX 10"
	set_global_assignment -name AUTO_DELAY_CHAINS ON -family "MAX 10"
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF -family "MAX 10"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON -family "MAX 10"
	set_global_assignment -name ENABLE_OCT_DONE ON -family "MAX 10"

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
