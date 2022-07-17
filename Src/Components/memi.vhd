LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memi IS
    GENERIC (
        INSTR_WIDTH : NATURAL := 32; -- instruction size in number of bits
        MI_ADDR_WIDTH : NATURAL := 12 -- instruction memory address size in number of bits
    );
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        write_enable : IN STD_LOGIC;
        write_instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamental OF memi IS
    -- memi size: 2^12 bits = 4 kB
    TYPE rom_type IS ARRAY (0 TO 2 ** 12) OF STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL rom : rom_type := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clock, reset) IS
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                rom <= (OTHERS => (OTHERS => '0'));
            ELSIF (write_enable = '1') THEN
                rom(to_integer(unsigned(address))) <= write_instruction;
            ELSE
                instruction <= rom(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS;
END comportamental;
