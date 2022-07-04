LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

package leds_package is
    TYPE memd_interface_t IS ARRAY (0 TO 7 - 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE display_t IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR(7 - 1 DOWNTO 0);
end package leds_package;
