-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY two_bits_shifter IS
    GENERIC (
        data_width : NATURAL
    );

    PORT (
        input : IN STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0)
    );
END two_bits_shifter;

ARCHITECTURE comportamental OF two_bits_shifter IS
    SIGNAL r_Shift1 : STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0);
    SIGNAL r_Unsigned_L : unsigned((data_width - 1) DOWNTO 0);
BEGIN
    PROCESS (r_Unsigned_L, r_Shift1) IS
    BEGIN
        -- Left Shift
        r_Unsigned_L <= shift_left(unsigned(r_Shift1), 1);
    END PROCESS;
END comportamental;