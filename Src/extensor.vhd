-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Extensor de sinais. Replica o bit de sinal da entrada Rs (largura_saida-largura_dado) vezes.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY extensor IS
    GENERIC (
        largura_dado : NATURAL;
        largura_saida : NATURAL
    );

    PORT (
        entrada_Rs : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR((largura_saida - 1) DOWNTO 0)
    );
END extensor;

ARCHITECTURE dataflow OF extensor IS
    SIGNAL extensao : STD_LOGIC_VECTOR((largura_saida - largura_dado - 1) DOWNTO 0);
BEGIN
    extensao <= (OTHERS => entrada_Rs(largura_dado - 1)); -- todos os bits da extensão correspondem ao bit mais significativo da entrada Rs
    saida <= extensao & entrada_Rs; -- saida com o sinal estendido de Rs, concatenado com Rs.
END dataflow;