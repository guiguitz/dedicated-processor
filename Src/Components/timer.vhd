-- 64 bits counter.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY timer IS
    PORT (
        clk_i : IN STD_LOGIC;
        reset_i : IN STD_LOGIC;
        enable_counter_burst_i : IN STD_LOGIC;
        counter_burst_value_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        counter_burst_flag_o : OUT STD_LOGIC;
        data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY timer;

ARCHITECTURE Behave OF timer IS
    SIGNAL reset : STD_LOGIC;
    SIGNAL cnt : unsigned(31 DOWNTO 0);
    SIGNAL aux_timer_counter_burst_value : unsigned(31 DOWNTO 0);
BEGIN
    -- Carry generation
    do_timer : PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF reset_i = '1' OR reset = '1' THEN
                cnt <= (OTHERS => '0');
            ELSE
                cnt <= cnt + 1;
                IF enable_counter_burst_i = '1' AND cnt = aux_timer_counter_burst_value THEN
                    counter_burst_flag_o <= '1';
                    reset <= '1';
                else
                    counter_burst_flag_o <= '0';
                END IF;
            END IF; -- else reset_i='1'
        END IF; -- rising_edge(clk_i)
    END PROCESS do_timer;

    aux_timer_counter_burst_value <= unsigned(counter_burst_value_i);
    data_o <= STD_LOGIC_VECTOR(cnt);
END ARCHITECTURE Behave; -- Entity: timer
