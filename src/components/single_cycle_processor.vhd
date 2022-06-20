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
        clock : IN STD_LOGIC
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
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memd IS
        GENERIC (
            number_of_words : NATURAL := 4096; -- número de words que a sua memória é capaz de armazenar
            MD_DATA_WIDTH : NATURAL := 32; -- tamanho da palavra em bits
            MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
        );
        PORT (
            clock : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            memd_address : IN STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL aux_instrucao : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_controle : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memi : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- Signals for memd
    SIGNAL aux_mmed_dp_memd_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_mmed_memd_address : STD_LOGIC_VECTOR(PROC_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_mmed_write_data : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

BEGIN
    instance_memi : memi
    PORT MAP(
        clock => clock,
        reset => reset,
        address => aux_data_path_memi,
        instruction => aux_instrucao
    );

    instance_memd : memd
    PORT MAP(
        clock => clock,
        write_data => aux_data_path_mmed_write_data,
        memd_address => aux_data_path_mmed_memd_address,
        read_data => aux_mmed_dp_memd_data
    );

    instance_single_cycle_control_unit : single_cycle_control_unit
    PORT MAP(
        instruction => aux_instrucao, -- instruction
        control => aux_controle -- control da via
    );

    instance_single_cycle_data_path : single_cycle_data_path
    PORT MAP(
        clock => clock,
        reset => reset,
        control => aux_controle,
        instruction => aux_instrucao,
        memd_data => aux_mmed_dp_memd_data,
        memd_address => aux_data_path_mmed_memd_address,
        memd_write_data => aux_data_path_mmed_write_data,
        pc_out => aux_data_path_memi
    );
END comportamento;
