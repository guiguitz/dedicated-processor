LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.instructions_package.ALL;

ENTITY tb_memd IS
END tb_memd;

ARCHITECTURE estimulos OF tb_memd IS

    COMPONENT memd IS
        GENERIC (
            MD_DATA_WIDTH : NATURAL := 32; -- word size in bits
            MD_ADDR_WIDTH : NATURAL := 12 -- size of data memory address in bits
        );
        PORT (
            clock : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            address : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            write_enable : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clock : STD_LOGIC;
    SIGNAL aux_write_data : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_memd_address : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_read_data : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_write_enable : STD_LOGIC;

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;

BEGIN
    instance_memd : memd PORT MAP(clock, aux_write_data, aux_memd_address, aux_read_data, aux_write_enable);

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

    test_memd : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP

            -- Writing data on memd
            aux_write_enable <= '1';

            aux_memd_address <= X"00000000";
            aux_write_data <= ADD_INSTR_BINARY; -- ADD
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000001";
            aux_write_data <= SLL_INSTR_BINARY; -- SLL
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000002";
            aux_write_data <= ADDI_INSTR_BINARY; -- ADDI
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000003";
            aux_write_data <= NOP_INSTR_BINARY; -- NOP
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000004";
            aux_write_data <= LW_INSTR_BINARY; -- LW
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000005";
            aux_write_data <= BNE_INSTR_BINARY; -- BNE
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000006";
            aux_write_data <= BEQ_INSTR_BINARY; -- BEQ
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000007";
            aux_write_data <= SW_INSTR_BINARY; -- SW
            WAIT FOR PERIOD;
            aux_memd_address <= X"00000008";
            aux_write_data <= J_INSTR_BINARY; -- J
            WAIT FOR PERIOD;

            aux_write_enable <= '0';

            aux_memd_address <= X"00000000";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000001";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000002";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000003";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000004";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000005";
            WAIT FOR PERIOD;

            aux_memd_address <= X"00000006";
            WAIT FOR PERIOD;
        END LOOP CLOCK_LOOP;
    END PROCESS test_memd;
END;
