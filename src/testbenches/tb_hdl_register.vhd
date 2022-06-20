-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Testbench para o mini_risc
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Este arquivo irá gerar um sinal de clock e reset de modo a possibilitar a simulação do DUT mini_risc

ENTITY tb_hdl_register IS
END tb_hdl_register;

ARCHITECTURE estimulos OF tb_hdl_register IS
    -- Declarar a unidade sob teste
    COMPONENT hdl_register
        GENERIC (
            largura_dado : NATURAL
        );
        PORT (
            entrada_dados : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            WE, clock, reset : IN STD_LOGIC;
            saida_dados : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL entrada_dados : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);
    SIGNAL WE, clock, reset : STD_LOGIC;
    SIGNAL saida_dados : STD_LOGIC_VECTOR((32 - 1) DOWNTO 0);

    -- Definição das configurações de clock
    CONSTANT PERIODO : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
BEGIN
    -- instancia o componente
    WE <= '1';
    instancia : hdl_register GENERIC MAP(largura_dado => 32) PORT MAP(entrada_dados, WE, clock, reset, saida_dados);
    -- processo para gerar o sinal de clock
    gera_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            clock <= '0';
            entrada_dados <= X"0000000A";
            -- WE <= '1';
            WAIT FOR (PERIODO - (PERIODO * DUTY_CYCLE));
            clock <= '1';
            WAIT FOR (PERIODO * DUTY_CYCLE);

            clock <= '0';
            entrada_dados <= X"FFFFFFFF";
            -- WE <= '1';
            WAIT FOR (PERIODO - (PERIODO * DUTY_CYCLE));
            clock <= '1';
            WAIT FOR (PERIODO * DUTY_CYCLE);

            clock <= '0';
            entrada_dados <= X"0C0C0C0C";
            -- WE <= '0';
            WAIT FOR (PERIODO - (PERIODO * DUTY_CYCLE));
            clock <= '1';
            WAIT FOR (PERIODO * DUTY_CYCLE);

        END LOOP CLOCK_LOOP;
    END PROCESS gera_clock;
    -- processo para gerar o estimulo de reset
    gera_reset : PROCESS
    BEGIN
        reset <= '1';
        FOR i IN 1 TO 2 LOOP
            WAIT UNTIL rising_edge(clock);
        END LOOP;
        reset <= '0';
        WAIT;
    END PROCESS gera_reset;
END;
