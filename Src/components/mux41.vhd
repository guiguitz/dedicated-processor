-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- MUX 4 para 1 com entrada de dados genérica
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux41 IS
    GENERIC (
        largura_dado : NATURAL
    );
    PORT (
        dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        sele_ent : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        dado_sai : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
    );
END mux41;

ARCHITECTURE dataflow OF mux41 IS
BEGIN
    WITH sele_ent SELECT
        dado_sai <= dado_ent_0 WHEN "00",
        dado_ent_1 WHEN "01",
        dado_ent_2 WHEN "10",
        dado_ent_3 WHEN OTHERS;
END dataflow;
