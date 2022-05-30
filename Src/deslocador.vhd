-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_bits_shifter is
    generic (
        data_width : natural
    );

    port (
        input           : in std_logic_vector((data_width - 1) downto 0);
        output          : out std_logic_vector((data_width - 1) downto 0)
    );
end two_bits_shifter;

architecture comportamental of two_bits_shifter is
    signal r_Shift1     : std_logic_vector((data_width - 1) downto 0);
    signal r_Unsigned_L : unsigned((data_width - 1) downto 0);
begin
    process (r_Unsigned_L, r_Shift1) is
    begin
        -- Left Shift
        r_Unsigned_L <= shift_left(unsigned(r_Shift1), 1);
    end process;
end comportamental;
