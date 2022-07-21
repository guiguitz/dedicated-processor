-- This code was obtained from: 
-- https://github.com/zylin/zpu/blob/master/zpu/hdl/zealot/devices/gpio.vhdl
--
-- this module describes a simple GPIO interface
--
-- data on port_in is synhronized to clk_i and can be read at
-- address 0
--
-- any write to address 0 is mapped to port_out
--
-- at address 1 is a direction register (port_dir)
-- initialized with '1's, what mean direction = in
-- this register is useful for bidirectional pins, e.g. headers
--
--
-- some examples:
--
-- to connect 4 buttons:
-- port_in( 3 downto  0) <= gpio_button;
--
--
-- to connect 8 LEDs:
-- gpio_led <= port_out(7 downto 0); 
--
--
-- to connect 2 bidirectional header pins:
-- port_in(8)  <= gpio_pin(0);
-- gpio_pin(0) <= port_out(8) when port_dir(8) = '0' else 'Z';
--
-- port_in(9)  <= gpio_pin(1);
-- gpio_pin(1) <= port_out(9) when port_dir(9) = '0' else 'Z';
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY gpio IS
    PORT (
        clk_i : IN STD_LOGIC;
        reset_i : IN STD_LOGIC;
        --
        we_i : IN STD_LOGIC;
        data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        addr_i : IN STD_LOGIC;
        data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        --
        port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        port_dir : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        --
        interrupt_flag : OUT STD_LOGIC
    );
END ENTITY gpio;

ARCHITECTURE rtl OF gpio IS

    SIGNAL port_in_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL port_in_sync : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --
    SIGNAL direction : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '1');

BEGIN

    PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk_i);

        -- synchronize all inputs with two registers
        -- to avoid metastability
        port_in_reg <= port_in;
        port_in_sync <= port_in_reg;

        -- write access to gpio
        IF we_i = '1' THEN
            -- data
            IF addr_i = '0' THEN
                port_out <= STD_LOGIC_VECTOR(data_i);
                interrupt_flag <= '0';
            END IF;
            -- direction
            IF addr_i = '1' THEN
                interrupt_flag <= '1';
                direction <= STD_LOGIC_VECTOR(data_i);
            END IF;
        END IF;

        -- read access to gpio
        -- data
        IF addr_i = '0' THEN
            data_o <= STD_LOGIC_VECTOR(port_in_sync);
            interrupt_flag <= '0';
        END IF;
        -- direction
        IF addr_i = '1' THEN
            interrupt_flag <= '1';
            data_o <= STD_LOGIC_VECTOR(direction);
        END IF;

        -- outputs
        port_dir <= direction;

        -- sync reset
        IF reset_i = '1' THEN
            direction <= (OTHERS => '1');
            port_in_reg <= (OTHERS => '0');
            port_in_sync <= (OTHERS => '0');
        END IF;

    END PROCESS;
END rtl;
