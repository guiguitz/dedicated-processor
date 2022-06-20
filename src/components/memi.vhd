LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memi IS
    GENERIC (
        INSTR_WIDTH : NATURAL := 32; -- instruction size in number of bits
        MI_ADDR_WIDTH : NATURAL := 32 -- instruction memory address size in number of bits
    );
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        write_enable : IN STD_LOGIC;
        write_instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamental OF memi IS
    TYPE rom_type IS ARRAY (0 TO 2 ** (MI_ADDR_WIDTH - 20)) OF STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL rom : rom_type;
BEGIN
    PROCESS (clock, reset) IS
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (write_enable = '1') THEN
                rom(to_integer(unsigned(address))) <= write_instruction;
            ELSIF (reset = '1') THEN
                rom <= (OTHERS => (OTHERS => '0'));
            ELSE
                instruction <= rom(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS;
END comportamental;
