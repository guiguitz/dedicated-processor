LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_single_cycle_processor IS
END tb_single_cycle_processor;

ARCHITECTURE estimulos OF tb_single_cycle_processor IS
    COMPONENT single_cycle_processor IS
        GENERIC (
            DATA_WIDTH : NATURAL := 32; -- data bus size in bits
            PROC_INSTR_WIDTH : NATURAL := 32; -- processor instruction size in bits
            PROC_ADDR_WIDTH : NATURAL := 12; -- size of processor program memory address in bits
            NUMBER_OF_LEDS : NATURAL := 10; -- number of leds
            DISPLAY_WIDTH : NATURAL := 7; -- displays width
            DP_CTRL_BUS_WIDTH : NATURAL := 14 -- control bus size in bits
        );
        PORT (
            reset : IN STD_LOGIC;
            clock : IN STD_LOGIC;
            leds : OUT STD_LOGIC_VECTOR(NUMBER_OF_LEDS - 1 DOWNTO 0);
            display_1 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
            display_2 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
            display_3 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
            display_4 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
            display_5 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
            display_6 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL aux_clock : STD_LOGIC;
    SIGNAL aux_reset : STD_LOGIC;
    SIGNAL aux_leds : STD_LOGIC_VECTOR(10 - 1 DOWNTO 0);
    SIGNAL aux_display_1 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
    SIGNAL aux_display_2 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
    SIGNAL aux_display_3 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
    SIGNAL aux_display_4 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
    SIGNAL aux_display_5 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
    SIGNAL aux_display_6 : STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;

BEGIN
    instance_single_cycle_processor : single_cycle_processor PORT MAP(aux_reset, aux_clock, aux_leds, aux_display_1, aux_display_2, aux_display_3, aux_display_4, aux_display_5, aux_display_6);

    generate_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            aux_clock <= '0';
            WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
            aux_clock <= '1';
            WAIT FOR (PERIOD * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS generate_clock;

    generate_reset : PROCESS
    BEGIN
        aux_reset <= '1';
        WAIT UNTIL falling_edge(aux_clock);
        aux_reset <= '0';
        WAIT;
    END PROCESS generate_reset;
END;
