LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.binary_instructions_package.ALL;
USE work.control_unit_outputs_package.ALL;

ENTITY tb_single_cycle_data_path IS
END tb_single_cycle_data_path;

ARCHITECTURE estimulos OF tb_single_cycle_data_path IS

    COMPONENT single_cycle_data_path IS
        GENERIC (
            DP_CTRL_BUS_WIDTH : NATURAL := 14; -- DataPath (DP) control bus size in bits
            DATA_WIDTH : NATURAL := 32; -- data size in bits
            PC_WIDTH : NATURAL := 32; -- pc size in bits
            INSTR_WIDTH : NATURAL := 32; -- instruction size in bits
            MD_ADDR_WIDTH : NATURAL := 12 -- size of data memory address in bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            control : IN STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
            memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- memd 'Read Data'
            memd_address : OUT STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0); -- memd 'Address'
            memd_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) -- memd 'Write Data'
        );
    END COMPONENT;

    SIGNAL aux_clock : STD_LOGIC;
    SIGNAL aux_reset : STD_LOGIC;
    SIGNAL aux_control : STD_LOGIC_VECTOR((14 - 1) DOWNTO 0);
    SIGNAL aux_instruction : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL aux_pc_out : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL aux_memd_data : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL aux_memd_address : STD_LOGIC_VECTOR((12 - 1) DOWNTO 0);
    SIGNAL aux_memd_write_data : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
    CONSTANT HALF_OFFSET : TIME := 5 ns;
BEGIN
    instance_single_cycle_data_path : single_cycle_data_path PORT MAP(aux_clock, aux_reset, aux_control, aux_instruction, aux_pc_out, aux_memd_data, aux_memd_address, aux_memd_write_data);

    generate_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            clock <= '0';
            WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
            clock <= '1';
            WAIT FOR (PERIOD * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS generate_clock;

    generate_reset : PROCESS
    BEGIN
        reset <= '1';
        WAIT UNTIL falling_edge(clock);
        reset <= '0';
        WAIT;
    END PROCESS generate_reset;

    test_ctrl : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP

            -- ADD
            control <= ADD_CONTROL_UNIT_OUTPUT;
            instruction <= ADD_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- SLL
            control <= SLL_CONTROL_UNIT_OUTPUT;
            instruction <= SLL_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- ADDI
            control <= ADDI_CONTROL_UNIT_OUTPUT;
            instruction <= ADDI_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- NOP
            control <= NOP_CONTROL_UNIT_OUTPUT;
            instruction <= NOP_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- LW
            control <= LW_CONTROL_UNIT_OUTPUT;
            instruction <= LW_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- BNE
            control <= BNE_CONTROL_UNIT_OUTPUT;
            instruction <= BNE_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- BEQ
            control <= BEQ_CONTROL_UNIT_OUTPUT;
            instruction <= BEQ_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- SW
            control <= SW_CONTROL_UNIT_OUTPUT;
            instruction <= SW_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- J
            control <= J_CONTROL_UNIT_OUTPUT;
            instruction <= J_INSTR_BINARY;
            WAIT FOR OFFSET;

        END LOOP CLOCK_LOOP;
    END PROCESS test_ctrl;
END;
