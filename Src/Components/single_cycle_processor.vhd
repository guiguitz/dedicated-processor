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
            DP_CTRL_BUS_WIDTH : NATURAL := 14; -- DataPath (DP) control bus size in bits
            DATA_WIDTH : NATURAL := 32; -- data size in bits
            PC_WIDTH : NATURAL := 32; -- pc size in bits
            INSTR_WIDTH : NATURAL := 32; -- instruction size in bits
            MD_ADDR_WIDTH : NATURAL := 32 -- size of data memory address in bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            control : IN STD_LOGIC_VECTOR (DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR (INSTR_WIDTH - 1 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR (PC_WIDTH - 1 DOWNTO 0);
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
            INSTR_WIDTH : NATURAL := 32; -- instruction size in number of bits
            MI_ADDR_WIDTH : NATURAL := 12 -- instruction memory address size in number of bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
            write_enable : IN STD_LOGIC;
            write_instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memd IS
        GENERIC (
            MD_DATA_WIDTH : NATURAL := 32; -- word size in bits
            MD_ADDR_WIDTH : NATURAL := 12 -- size of data memory address in bits
        );
        PORT (
            clock : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            address : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            write_enable : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL aux_instruction : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memi_pc_out : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- Signals for memi
    SIGNAL aux_write_enable : STD_LOGIC := '0';
    SIGNAL aux_write_instruction : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0) := X"00000000";

    -- Signals for memd
    SIGNAL aux_memd_write_enable : STD_LOGIC;
    SIGNAL aux_memd_data_path_memd_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_address : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_write_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

BEGIN

    aux_memd_write_enable <= aux_control(4); -- MemWrite

    instance_memi : memi
    PORT MAP(
        clock => clock,
        reset => reset,
        address => aux_data_path_memi_pc_out,
        instruction => aux_instruction,
        write_enable => aux_write_enable,
        write_instruction => aux_write_instruction
    );

    instance_memd : memd
    PORT MAP(
        clock => clock,
        write_data => aux_data_path_memd_write_data,
        address => aux_data_path_memd_address,
        read_data => aux_memd_data_path_memd_data,
        write_enable => aux_memd_write_enable
    );

    instance_single_cycle_control_unit : single_cycle_control_unit
    PORT MAP(
        instruction => aux_instruction,
        control => aux_control
    );

    instance_single_cycle_data_path : single_cycle_data_path
    PORT MAP(
        clock => clock,
        reset => reset,
        control => aux_control,
        instruction => aux_instruction,
        pc_out => aux_data_path_memi_pc_out,
        memd_data => aux_memd_data_path_memd_data,
        memd_address => aux_data_path_memd_address,
        memd_write_data => aux_data_path_memd_write_data
    );
END comportamento;
