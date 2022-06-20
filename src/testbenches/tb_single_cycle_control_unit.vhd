-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte

-- Rtype
-- ADD: 00000000000000000 000 00000 0110011
-- SLL: 00000000000000000 010 00000 0110011

-- ADDI, NOP
-- ADDI: 00000000000000000 000 00000 0010011
-- NOP: 00000000000000000 010 00000 0010011

-- LW
-- LW: 00000000000000000 010 00000 0000011

-- SW, BEQ, BNE
-- BNE: 00000000000000000 001 00000 0100011
-- BEQ: 00000000000000000 011 00000 0100011
-- SW: 00000000000000000 010 00000 0100011

-- J
-- LW: 00000000000000000 000 00000 0000010


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_single_cycle_control_unit IS
END tb_single_cycle_control_unit;

ARCHITECTURE estimulos OF tb_single_cycle_control_unit IS
    -- Declarar a unidade sob teste
    COMPONENT single_cycle_control_unit
        GENERIC (
            INSTR_WIDTH : NATURAL := 32;
            OPCODE_WIDTH : NATURAL := 7;
            DP_CTRL_BUS_WIDTH : NATURAL := 14;
            ULA_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0); -- instruction
            control : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0) -- control da via
        );
    END COMPONENT;

    SIGNAL instruction : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL control : STD_LOGIC_VECTOR((14 - 1) DOWNTO 0);

    CONSTANT OFFSET : TIME := 5 ns;
BEGIN
    -- instancia o componente
    instancia : single_cycle_control_unit PORT MAP(instruction, control);
    -- processo para gerar o sinal de clock
    test_ctrl : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP

            -- ADD
            instruction <= B"00000000000000000000000000110011";
            WAIT FOR OFFSET;

            -- SLL
            instruction <= B"00000000000000000010000000110011";
            WAIT FOR OFFSET;

            -- ADDI
            instruction <= B"00000000000000000000000000010011";
            WAIT FOR OFFSET;

            -- NOP
            instruction <= B"00000000000000000010000000010011";
            WAIT FOR OFFSET;

            -- LW
            instruction <= B"00000000000000000010000000000011";
            WAIT FOR OFFSET;

            -- BNE
            instruction <= B"00000000000000000001000000100011";
            WAIT FOR OFFSET;

            -- BEQ
            instruction <= B"00000000000000000011000000100011";
            WAIT FOR OFFSET;

            -- SW
            instruction <= B"00000000000000000010000000100011";
            WAIT FOR OFFSET;

            -- J
            instruction <= B"00000000000000000000000000000010";
            WAIT FOR OFFSET;

        END LOOP CLOCK_LOOP;
    END PROCESS test_ctrl;
END;
