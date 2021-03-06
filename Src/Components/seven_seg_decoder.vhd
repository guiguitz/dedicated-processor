-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Guilherme Serra Camargo Gomes
-- Decodificador para display de 7 seguimentos

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY seven_seg_decoder IS
    PORT (
        input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END seven_seg_decoder;

ARCHITECTURE arch OF seven_seg_decoder IS
BEGIN
    PROCESS (input)
    BEGIN
        CASE input IS
            WHEN "0000" => output <= "1000000";
            WHEN "0001" => output <= "1111001";
            WHEN "0010" => output <= "0100100";
            WHEN "0011" => output <= "0110000";
            WHEN "0100" => output <= "0011001";
            WHEN "0101" => output <= "0010010";
            WHEN "0110" => output <= "0000010";
            WHEN "0111" => output <= "1111000";
            WHEN "1000" => output <= "0000000";
            WHEN "1001" => output <= "0010000";
            WHEN "1010" => output <= "0001000";
            WHEN "1011" => output <= "0000011";
            WHEN "1100" => output <= "1000110";
            WHEN "1101" => output <= "0100001";
            WHEN "1110" => output <= "0000110";
            WHEN "1111" => output <= "0001110";
            WHEN OTHERS => output <= "0110110";
        END CASE;
    END PROCESS;

END arch;
