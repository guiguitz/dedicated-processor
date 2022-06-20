LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_memi IS
END tb_memi;

ARCHITECTURE estimulos OF tb_memi IS

    COMPONENT memi IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instruction em número de bits
            MI_ADDR_WIDTH : NATURAL := 32 -- tamanho do endereço da memória de instruções em número de bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clock : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;
    SIGNAL aux_address : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_instruction : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

    -- Definição das configurações de clock
    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
    CONSTANT MEIO_OFFSET : TIME := 5 ns;

BEGIN
    instance : memi PORT MAP(clock, reset, aux_address, aux_instruction);

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

    test_memi : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            aux_address <= X"00000000";
            WAIT FOR PERIOD;

            aux_address <= X"00000001";
            WAIT FOR PERIOD;

            aux_address <= X"00000002";
            WAIT FOR PERIOD;

            aux_address <= X"00000003";
            WAIT FOR PERIOD;

            aux_address <= X"00000004";
            WAIT FOR PERIOD;

            aux_address <= X"00000005";
            WAIT FOR PERIOD;

            aux_address <= X"00000006";
            WAIT FOR PERIOD;
        END LOOP CLOCK_LOOP;
    END PROCESS test_memi;
END;
