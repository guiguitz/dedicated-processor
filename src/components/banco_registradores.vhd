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

ENTITY banco_registradores IS
    GENERIC (
        largura_dado : NATURAL;
        largura_ende : NATURAL
    );

    PORT (
        ent_Rs_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0); -- rs1, Read Register 1, Instruction [19-15]
        ent_Rt_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0); -- rs2, Read Register 2, Instruction [24-20]
        ent_Rd_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0); -- rd, Write Register, Instruction [11-7], Address to access during writing
        ent_Rd_dado : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0); -- Write Data, Data to write
        sai_Rs_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0); -- Read Data 1
        sai_Rt_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0); -- Read Data 2
        clk, WE : IN STD_LOGIC -- RegWrite
    );
END banco_registradores;

ARCHITECTURE comportamental OF banco_registradores IS
    TYPE registerfile IS ARRAY(0 TO ((2 ** largura_ende) - 1)) OF STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
    SIGNAL banco : registerfile;
BEGIN
    leitura : PROCESS (clk) IS
    BEGIN
        -- lê o hdl_register de endereço Rs da instruction apontada por PC no ciclo anterior,
        -- lê o hdl_register de endereço Rt da instruction apontada por PC no ciclo anterior.
        sai_Rs_dado <= banco(to_integer(unsigned(ent_Rs_ende)));
        sai_Rt_dado <= banco(to_integer(unsigned(ent_Rt_ende)));
    END PROCESS;

    escrita : PROCESS (clk) IS
    BEGIN
        IF rising_edge(clk) THEN
            IF WE = '1' THEN
                banco(to_integer(unsigned(ent_Rd_ende))) <= ent_Rd_dado;
            END IF;
        END IF;
    END PROCESS;
END comportamental;