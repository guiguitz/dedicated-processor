-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY tb_ula IS
END tb_ula;

ARCHITECTURE estimulos OF tb_ula IS
    -- Declarar a unidade sob teste
    COMPONENT ula
        GENERIC (
            largura_dado : NATURAL := 32
        );

        PORT (
            entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            seletor : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            zero : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL entrada_a : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL entrada_b : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL seletor : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL saida : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL zero : STD_LOGIC;

    CONSTANT OFFSET : TIME := 5 ns;
BEGIN
    -- instancia o componente
    instancia : ula GENERIC MAP(largura_dado => 32) PORT MAP(entrada_a, entrada_b, seletor, saida, zero);
    -- processo para gerar o sinal de clock
    test_ula : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            entrada_a <= X"00000004";
            entrada_b <= X"00000005";
            seletor <= "0001"; -- SUM
            WAIT FOR OFFSET;

            entrada_a <= X"0000000A";
            entrada_b <= X"00000003";
            seletor <= "0010"; -- SUB
            WAIT FOR OFFSET;

            entrada_a <= X"0000000F";
            entrada_b <= X"00000001";
            seletor <= "0100"; -- SLL
            WAIT FOR OFFSET;

            entrada_a <= X"FFFF0000";
            entrada_b <= X"00000007";
            seletor <= "0011"; -- ADDI
            WAIT FOR OFFSET;

        END LOOP CLOCK_LOOP;
    END PROCESS test_ula;
END;
