-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY processador_ciclo_unico IS
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
END processador_ciclo_unico;

ARCHITECTURE comportamento OF processador_ciclo_unico IS
    -- declare todos os componentes que serão necessários no seu processador_ciclo_unico a partir deste comentário
    COMPONENT via_de_dados_ciclo_unico IS
        GENERIC (
            -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
            DP_CTRL_BUS_WIDTH : NATURAL := 14; -- tamanho do barramento de controle da via de dados (DP) em bits
            DATA_WIDTH : NATURAL := 32; -- tamanho do dado em bits
            PC_WIDTH : NATURAL := 32; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
            FR_ADDR_WIDTH : NATURAL := 5; -- tamanho da linha de endereços do banco de registradores em bits
            ULA_CTRL_WIDTH : NATURAL := 4; -- tamanho da linha de controle da ULA
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instrução em bits
            MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
        );
        PORT (
            -- declare todas as portas da sua via_dados_ciclo_unico aqui.
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            controle : IN STD_LOGIC_VECTOR (DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
            instrucao : IN STD_LOGIC_VECTOR (INSTR_WIDTH - 1 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR (PC_WIDTH - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            -- We are the champions:
            zero : OUT STD_LOGIC;
            memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            memd_address : OUT STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
            memd_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT unidade_de_controle_ciclo_unico IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32;
            OPCODE_WIDTH : NATURAL := 7;
            DP_CTRL_BUS_WIDTH : NATURAL := 14;
            ULA_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instrucao : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0); -- instrução
            controle : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0) -- controle da via
            -- RegDst | Jump | Branch NEQ | Branch EQ | MemToReg | AluOp (4) | MemWrite | AluSrc | RegWrite | PcSrc | ITController
        );
    END COMPONENT;

    COMPONENT memi IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instrução em número de bits
            MI_ADDR_WIDTH : NATURAL := 32 -- tamanho do endereço da memória de instruções em número de bits
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            Endereco : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
            Instrucao : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memd IS
        GENERIC (
            number_of_words : NATURAL := 4096; -- número de words que a sua memória é capaz de armazenar
            MD_DATA_WIDTH : NATURAL := 32; -- tamanho da palavra em bits
            MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
        );
        PORT (
            clk : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            memd_address : IN STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- Declare todos os sinais auxiliares que serão necessários no seu processador_ciclo_unico a partir deste comentário.
    -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
    -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
    -- componentes onde serão usados.
    -- Veja os exemplos abaixo:

    -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade do seu processador_ciclo_unico com
    -- os sinais que você acabou de definir.
    -- Veja os exemplos abaixo:
    SIGNAL aux_instrucao : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_controle : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_endereco : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- We are the champions:
    -- Signals for memd
    SIGNAL aux_mmed_dp_memd_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_dp_mmed_memd_address : STD_LOGIC_VECTOR(PROC_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_dp_mmed_write_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
BEGIN
    -- A partir deste comentário instancie todos o componentes que serão usados no seu processador_ciclo_unico.
    -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
    -- que você atribuiu ao componente.
    -- Depois segue o port map do referido componente instanciado.
    -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
    -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade processador_ciclo_unico,
    -- ou ainda uma das saídas da entidade processador_ciclo_unico.
    -- Veja os exemplos de instanciação a seguir:

    instancia_memi : memi
    PORT MAP(
        clk => Clock,
        reset => reset,
        Endereco => aux_endereco,
        Instrucao => aux_instrucao
    );

    instancia_memd : memd
    PORT MAP(
        clk => Clock,
        write_data => aux_dp_mmed_write_data,
        memd_address => aux_dp_mmed_memd_address,
        read_data => aux_mmed_dp_memd_data
    );

    instancia_unidade_de_controle_ciclo_unico : unidade_de_controle_ciclo_unico
    PORT MAP(
        instrucao => aux_instrucao, -- instrução
        controle => aux_controle -- controle da via
    );

    instancia_via_de_dados_ciclo_unico : via_de_dados_ciclo_unico
    PORT MAP(
        -- declare todas as portas da sua via_dados_ciclo_unico aqui.
        clock => Clock,
        reset => reset,
        controle => aux_controle,
        instrucao => aux_instrucao,
        memd_data => aux_mmed_dp_memd_data,
        memd_address => aux_dp_mmed_memd_address,
        memd_write_data => aux_dp_mmed_write_data,
        pc_out => aux_endereco
    );
END comportamento;