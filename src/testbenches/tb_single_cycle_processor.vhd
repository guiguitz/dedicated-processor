LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY tb_single_cycle_processor IS
END tb_single_cycle_processor;

ARCHITECTURE estimulos OF tb_single_cycle_processor IS
    -- Declarar a unidade sob teste
    COMPONENT single_cycle_processor
        PORT (
            reset : IN STD_LOGIC;
            Clock : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC;
    SIGNAL rst : STD_LOGIC;

    -- Definição das configurações de clock
    CONSTANT PERIODO : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
    CONSTANT OFFSET_WRITE : TIME := 12 ns;
    CONSTANT MEIO_OFFSET : TIME := 5 ns;

    -- FILE arquivo_entrada : text OPEN read_mode IS "data_in.txt";
    -- FILE arquivo_saida1 : text OPEN write_mode IS "saida1.txt";
    -- FILE arquivo_saida2 : text OPEN write_mode IS "saida2.txt";
BEGIN
    -- instancia o componente
    inst_single_cycle_processor : single_cycle_processor PORT MAP(rst, clk);

    -- processo para gerar o sinal de clock
    gera_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            clk <= '0';
            WAIT FOR (PERIODO - (PERIODO * DUTY_CYCLE));
            clk <= '1';
            WAIT FOR (PERIODO * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS gera_clock;

    -- processo para gerar o estimulo de reset
    gera_reset : PROCESS
    BEGIN
        rst <= '1';
        WAIT UNTIL falling_edge(clk);
        rst <= '0';
        WAIT;
    END PROCESS gera_reset;

    -- -- processo para ler os dados do arquivo data_in.txt
    -- read_inputs_from_file :
    -- PROCESS
    --     VARIABLE linha : line;
    --     VARIABLE entrada : INTEGER;
    -- BEGIN
    --     WAIT FOR OFFSET;
    --     WHILE NOT endfile(arquivo_entrada) LOOP
    --         IF flag_read_data = '1' THEN
    --             readline(arquivo_entrada, linha);
    --             read(linha, entrada);
    --             xin <= STD_LOGIC_VECTOR(to_unsigned(entrada, 4));
    --         END IF;
    --         WAIT FOR (MEIO_OFFSET);
    --     END LOOP;
    --     WAIT;
    -- END PROCESS read_inputs_from_file;

    -- -- processo para gerar os estimulos da entrada xin
	-- processo_entrada:
	-- process
	-- begin
	-- 	wait for OFFSET;
	-- 	flag_read_data <= '1';
	-- 	for i in 0 to 8 loop
	-- 	    wait for MEIO_OFFSET;
	-- 	end loop;
    --     flag_read_data <= '0';
	-- 	wait;
	-- end process;

    -- -- processo para gerar os sinais simulados para escrita no arquivo_saida1
	-- escreve_outputs1:
	-- process
	-- begin
	-- 	wait for OFFSET_WRITE;
	-- 	flag_write <= '1';
	-- 	for i in 0 to 8 loop
	-- 		wait for MEIO_OFFSET;
	-- 	end loop;
	-- 	flag_write <= '0';			
	-- 	wait;
	-- end process escreve_outputs1;   
END;
