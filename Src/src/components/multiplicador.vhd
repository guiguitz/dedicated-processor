-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Multiplicador puramente combinacional
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY multiplicador IS
    GENERIC (
        largura_dado : NATURAL
    );

    PORT (
        entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR((2 * largura_dado - 1) DOWNTO 0)
    );
END multiplicador;

ARCHITECTURE comportamental OF multiplicador IS
BEGIN
    saida <= STD_LOGIC_VECTOR(signed(entrada_a) * signed(entrada_b));
END comportamental;
