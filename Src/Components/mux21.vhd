-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- MUX 2 para 1 com entrada de dados genérica
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux21 IS
    GENERIC (
        largura_dado : NATURAL
    );
    PORT (
        dado_ent_0, dado_ent_1 : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        sele_ent : IN STD_LOGIC;
        dado_sai : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
    );
END mux21;

ARCHITECTURE dataflow OF mux21 IS
BEGIN
    WITH sele_ent SELECT
        dado_sai <= dado_ent_0 WHEN '0',
        dado_ent_1 WHEN OTHERS;
END dataflow;
