-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY single_cycle_processor IS
    GENERIC (
        DATA_WIDTH : NATURAL := 32; -- tamanho do barramento de dados em bits
        PROC_INSTR_WIDTH : NATURAL := 32; -- tamanho da instruction do processador em bits
        PROC_ADDR_WIDTH : NATURAL := 12; -- tamanho do endereço da memória de programa do processador em bits
        DP_CTRL_BUS_WIDTH : NATURAL := 14 -- tamanho do barramento de control em bits
    );
    PORT (
        reset : IN STD_LOGIC;
        Clock : IN STD_LOGIC
    );
END single_cycle_processor;

ARCHITECTURE comportamento OF single_cycle_processor IS
    COMPONENT single_cycle_data_path IS
        GENERIC (
            DP_CTRL_BUS_WIDTH : NATURAL := 14; -- tamanho do barramento de control da via de dados (DP) em bits
            DATA_WIDTH : NATURAL := 32; -- tamanho do dado em bits
            PC_WIDTH : NATURAL := 32; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
            FR_ADDR_WIDTH : NATURAL := 5; -- tamanho da linha de endereços do banco de registradores em bits
            ULA_CTRL_WIDTH : NATURAL := 4; -- tamanho da linha de control da ULA
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instruction em bits
            MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            control : IN STD_LOGIC_VECTOR (DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR (INSTR_WIDTH - 1 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR (PC_WIDTH - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
            zero : OUT STD_LOGIC;
            memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            memd_address : OUT STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
            memd_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT single_cycle_control_unit IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32;
            OPCODE_WIDTH : NATURAL := 7;
            DP_CTRL_BUS_WIDTH : NATURAL := 14;
            ULA_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0); -- instruction
            control : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0) -- control da via
            -- RegDst | Jump | Branch NEQ | Branch EQ | MemToReg | AluOp (4) | MemWrite | AluSrc | RegWrite | PcSrc | ITController
        );
    END COMPONENT;

    COMPONENT memi IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instruction em número de bits
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

    -- Declare todos os sinais auxiliares que serão necessários no seu single_cycle_processor a partir deste comentário.
    -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
    -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
    -- componentes onde serão usados.
    -- Veja os exemplos abaixo:

    -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade do seu single_cycle_processor com
    -- os sinais que você acabou de definir.
    -- Veja os exemplos abaixo:
    SIGNAL aux_instrucao : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_controle : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memi : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- We are the champions:
    -- Signals for memd
    SIGNAL aux_mmed_dp_memd_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_mmed_memd_address : STD_LOGIC_VECTOR(PROC_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_mmed_write_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
BEGIN
    -- A partir deste comentário instancie todos o componentes que serão usados no seu single_cycle_processor.
    -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
    -- que você atribuiu ao componente.
    -- Depois segue o port map do referido componente instanciado.
    -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da 
    -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade single_cycle_processor,
    -- ou ainda uma das saídas da entidade single_cycle_processor.
    -- Veja os exemplos de instanciação a seguir:

    instance_memi : memi
    PORT MAP(
        clk => Clock,
        reset => reset,
        Endereco => aux_data_path_memi,
        Instrucao => aux_instrucao
    );

    instance_memd : memd
    PORT MAP(
        clk => Clock,
        write_data => aux_data_path_mmed_write_data,
        memd_address => aux_data_path_mmed_memd_address,
        read_data => aux_mmed_dp_memd_data
    );

    instance_single_cycle_control_unit : single_cycle_control_unit
    PORT MAP(
        instruction => aux_instrucao, -- instruction
        control => aux_controle -- control da via
    );

    instance_via_de_dados_ciclo_unico : single_cycle_data_path
    PORT MAP(
        clock => Clock,
        reset => reset,
        control => aux_controle,
        instruction => aux_instrucao,
        memd_data => aux_mmed_dp_memd_data,
        memd_address => aux_data_path_mmed_memd_address,
        memd_write_data => aux_data_path_mmed_write_data,
        pc_out => aux_data_path_memi
    );
END comportamento;