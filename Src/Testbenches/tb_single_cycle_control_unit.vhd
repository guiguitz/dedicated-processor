LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.instructions_package.ALL;

ENTITY tb_single_cycle_control_unit IS
END tb_single_cycle_control_unit;

ARCHITECTURE estimulos OF tb_single_cycle_control_unit IS
    COMPONENT single_cycle_control_unit
        GENERIC (
            INSTR_WIDTH : NATURAL := 32;
            OPCODE_WIDTH : NATURAL := 7;
            DP_CTRL_BUS_WIDTH : NATURAL := 14;
            ALU_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
            control : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL instruction : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL control : STD_LOGIC_VECTOR((14 - 1) DOWNTO 0);

    CONSTANT OFFSET : TIME := 5 ns;
BEGIN
    instance_single_cycle_control_unit : single_cycle_control_unit PORT MAP(instruction, control);

    test_ctrl : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP

            -- ADD
            instruction <= ADD_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- SLL
            instruction <= SLL_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- ADDI
            instruction <= ADDI_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- NOP
            instruction <= NOP_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- LW
            instruction <= LW_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- BNE
            instruction <= BNE_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- BEQ
            instruction <= BEQ_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- SW
            instruction <= SW_INSTR_BINARY;
            WAIT FOR OFFSET;

            -- J
            instruction <= J_INSTR_BINARY;
            WAIT FOR OFFSET;

        END LOOP CLOCK_LOOP;
    END PROCESS test_ctrl;
END;
