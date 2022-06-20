-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Program Counter tamanho genérico
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pc IS
    GENERIC (
        PC_WIDTH : NATURAL -- tamanho de PC em bits (complete)
    );
    PORT (
        entrada : IN STD_LOGIC_VECTOR (PC_WIDTH - 1 DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE comportamental OF pc IS
BEGIN
    PROCESS (clock, reset) IS
    BEGIN
        IF (reset = '1') THEN
            saida <= (OTHERS => '0');
        ELSIF (rising_edge(clock)) THEN
            saida <= entrada;
        END IF;
    END PROCESS;
END comportamental;
