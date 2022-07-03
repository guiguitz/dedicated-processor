LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY two_bits_shifter IS
    GENERIC (
        DATA_WIDTH : NATURAL
    );

    PORT (
        operand : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        result : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
    );
END two_bits_shifter;

ARCHITECTURE comportamental OF two_bits_shifter IS
    SIGNAL aux_result : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
BEGIN
    PROCESS (aux_result, operand) IS
    BEGIN
        aux_result <= STD_LOGIC_VECTOR(shift_left(unsigned(operand), 1)); -- Left Shift
    END PROCESS;
    result <= aux_result;
END comportamental;
