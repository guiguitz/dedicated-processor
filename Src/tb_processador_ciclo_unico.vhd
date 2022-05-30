-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Testbench para o processador_ciclo_unico
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- Este arquivo irá gerar um sinal de clock e reset de modo a possibilitar a simulação do DUT processador_ciclo_unico

ENTITY tb_processador_ciclo_unico IS
END tb_processador_ciclo_unico;

ARCHITECTURE estimulos OF tb_processador_ciclo_unico IS
    -- Declarar a unidade sob teste
    COMPONENT processador_ciclo_unico
        GENERIC (
            DATA_WIDTH : NATURAL := 32; -- tamanho do barramento de dados em bits
            PROC_INSTR_WIDTH : NATURAL := 32; -- tamanho da instrução do processador em bits
            PROC_ADDR_WIDTH : NATURAL := 12; -- tamanho do endereço da memória de programa do processador em bits
            DP_CTRL_BUS_WIDTH : NATURAL := 14 -- tamanho do barramento de controle em bits
        );
        PORT (
            reset : IN STD_LOGIC;
            Clock : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL Clock : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;

    -- Definição das configurações de clock
    CONSTANT PERIODO : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
BEGIN
    -- instancia o componente
    instancia : processador_ciclo_unico PORT MAP(Clock => Clock, reset => rst);
    -- processo para gerar o sinal de clock
    gera_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            Clock <= '0';
            WAIT FOR (PERIODO - (PERIODO * DUTY_CYCLE));
            Clock <= '1';
            WAIT FOR (PERIODO * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS gera_clock;
    -- processo para gerar o estimulo de reset
    gera_reset : PROCESS
    BEGIN
        rst <= '0';
        FOR i IN 1 TO 2 LOOP
            WAIT UNTIL rising_edge(Clock);
        END LOOP;
        rst <= '0';
        WAIT;
    END PROCESS gera_reset;
END;