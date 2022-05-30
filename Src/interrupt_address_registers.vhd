-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Banco de registradores com entradas e saída de dados de tamanho genérico
-- entradas de endereço de tamanho genérico
-- clock e sinal de WE
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interrupt_address_registers IS
    GENERIC (
        largura_dado : NATURAL;
        largura_ende : NATURAL
    );

    PORT (
        address : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
        input : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        clk, WE : IN STD_LOGIC
    );
END interrupt_address_registers;

ARCHITECTURE comportamental OF interrupt_address_registers IS
    TYPE registerfile IS ARRAY(0 TO ((2 ** largura_ende) - 1)) OF STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
    SIGNAL banco : registerfile;
BEGIN
    leitura : PROCESS (clk) IS
    BEGIN
        output <= banco(to_integer(unsigned(address)));
    END PROCESS;

    escrita : PROCESS (clk) IS
    BEGIN
        IF rising_edge(clk) THEN
            IF WE = '1' THEN
                banco(to_integer(unsigned(address))) <= input;
            END IF;
        END IF;
    END PROCESS;
END comportamental;