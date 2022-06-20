LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY tb_single_cycle_processor IS
END tb_single_cycle_processor;

ARCHITECTURE estimulos OF tb_single_cycle_processor IS
    COMPONENT single_cycle_processor
        PORT (
            reset : IN STD_LOGIC;
            clock : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clock : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
    CONSTANT HALF_OFFSET : TIME := 5 ns;

BEGIN
    instance : single_cycle_processor PORT MAP(reset, clock);

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
END;
