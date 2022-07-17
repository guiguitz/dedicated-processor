LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.custom_types_package.ALL;

ENTITY single_cycle_processor IS
    GENERIC (
        DATA_WIDTH : NATURAL := 32; -- data bus size in bits
        PROC_INSTR_WIDTH : NATURAL := 32; -- processor instruction size in bits
        PROC_ADDR_WIDTH : NATURAL := 12; -- size of processor program memory address in bits
        NUMBER_OF_LEDS : NATURAL := 10; -- number of leds
        DISPLAY_WIDTH : NATURAL := 7; -- displays width
        DP_CTRL_BUS_WIDTH : NATURAL := 14 -- control bus size in bits
    );
    PORT (
        reset : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        leds : OUT STD_LOGIC_VECTOR(NUMBER_OF_LEDS - 1 DOWNTO 0);
        display_1 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
        display_2 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
        display_3 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
        display_4 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
        display_5 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0);
        display_6 : OUT STD_LOGIC_VECTOR(DISPLAY_WIDTH - 1 DOWNTO 0)
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
            ALU_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
            control : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0)
            -- RegDst & Jump & Branch NEQ & Branch EQ & MemToReg & AluOp(3) & AluOp(2) & AluOp(1) & AluOp(0) & MemWrite & AluSrc & RegWrite & PcSrc & ITController
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
            reset : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            address : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            write_enable : IN STD_LOGIC;
            interface : OUT memd_interface_t
        );
    END COMPONENT;

    COMPONENT seven_seg_decoder IS
        PORT (
            input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL aux_instruction : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memi_pc_out : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- Signals for memd
    SIGNAL aux_memd_write_enable : STD_LOGIC;
    SIGNAL aux_memd_data_path_memd_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_address : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_write_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- Signals for outputs (LEDs and 7-Seg LEDS)
    SIGNAL aux_memd_interface : memd_interface_t;
    SIGNAL aux_display : display_t;

BEGIN

    aux_memd_write_enable <= aux_control(4); -- MemWrite
    display_1 <= aux_display(0);
    display_2 <= aux_display(1);
    display_3 <= aux_display(2);
    display_4 <= aux_display(3);
    display_5 <= aux_display(4);
    display_6 <= aux_display(5);
    leds <= aux_memd_interface(0)(NUMBER_OF_LEDS - 1 DOWNTO 0);

    gen_display :
    FOR i IN 0 TO 5 GENERATE
        instance_seven_seg_decoder : seven_seg_decoder
        PORT MAP(
            input => aux_memd_interface(i + 1)(3 DOWNTO 0),
            output => aux_display(i)
        );
    END GENERATE gen_display;

    instance_memi : memi
    PORT MAP(
        clock => clock,
        reset => reset,
        address => aux_data_path_memi_pc_out,
        instruction => aux_instruction,
        write_enable => '0',
        write_instruction => X"00000000"
    );

    instance_memd : memd
    PORT MAP(
        clock => clock,
        reset => reset,
        write_data => aux_data_path_memd_write_data,
        address => aux_data_path_memd_address,
        read_data => aux_memd_data_path_memd_data,
        write_enable => aux_memd_write_enable,
        interface => aux_memd_interface
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
