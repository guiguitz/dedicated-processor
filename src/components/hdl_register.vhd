-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Registrador de carga paralela de tamanho genérico com WE e reset síncrono em nível lógico 1
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hdl_register IS
    GENERIC (
        largura_dado : NATURAL
    );
    PORT (
        entrada_dados : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        WE, clk, reset : IN STD_LOGIC;
        saida_dados : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamental OF hdl_register IS
BEGIN
    PROCESS (clk) IS
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (WE = '1') THEN
                saida_dados <= entrada_dados;
            END IF;
            IF (reset = '1') THEN
                saida_dados <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;
END comportamental;
