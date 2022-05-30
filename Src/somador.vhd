-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Somador de n bits unsigned
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY somador IS
    GENERIC (
        largura_dado : NATURAL
    );

    PORT (
        entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
    );
END somador;

ARCHITECTURE dataflow OF somador IS
BEGIN
    saida <= STD_LOGIC_VECTOR(unsigned(entrada_a) + unsigned(entrada_b));
END dataflow;