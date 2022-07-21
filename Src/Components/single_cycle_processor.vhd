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
            MD_WIDTH : NATURAL := 32 -- size of data memory address in bits
        );
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            control : IN STD_LOGIC_VECTOR (DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
            instruction : IN STD_LOGIC_VECTOR (INSTR_WIDTH - 1 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR (PC_WIDTH - 1 DOWNTO 0);
            memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            memd_address : OUT STD_LOGIC_VECTOR(MD_WIDTH - 1 DOWNTO 0);
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
            MD_ADDRESS_WIDTH : NATURAL := 32; -- address size in bits
            MD_WIDTH : NATURAL := 12; -- size of data memory address in bits
            MD_SIZE : NATURAL := 4096 -- size of data memory address (2^12)
        );
        PORT (
            -- clock and reset ports.
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;

            -- CPU ports.
            write_enable : IN STD_LOGIC;
            write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            address : IN STD_LOGIC_VECTOR(MD_ADDRESS_WIDTH - 1 DOWNTO 0);
            read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);

            -- interrupt_ctl ports.
            interrupt_ctl_Int_mask : OUT STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Set bits correspond to active interrupts
            interrupt_ctl_Pending : IN STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Set bits indicate which interrupts are pending
            interrupt_ctl_Current : IN STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Single set bit for the active interrupt
            interrupt_ctl_Interrupt : IN STD_LOGIC; --# Flag indicating when an interrupt is pending
            interrupt_ctl_Acknowledge : OUT STD_LOGIC; --# Clear the active interrupt
            interrupt_ctl_Clear_pending : OUT STD_LOGIC; --# Clear all pending interrupts

            -- gpio ports.
            gpio_we_o : OUT STD_LOGIC;
            gpio_data_o : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            gpio_addr_o : OUT STD_LOGIC;
            gpio_data_i : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            gpio_port_dir : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);

            -- timer peripheral ports.
            timer_enable_counter_burst_o : OUT STD_LOGIC;
            timer_counter_burst_value_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            timer_data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

            -- Output interface ports.
            interface : OUT memd_interface_t
        );
    END COMPONENT;

    COMPONENT seven_seg_decoder IS
        PORT (
            input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT interrupt_ctl IS
        GENERIC (
            RESET_ACTIVE_LEVEL : STD_LOGIC := '1' --# Asynch. reset control level
        );
        PORT (
            --# {{clocks|}}
            Clock : IN STD_LOGIC; --# System clock
            Reset : IN STD_LOGIC; --# Asynchronous reset

            --# {{control|}}
            Int_mask : IN STD_LOGIC_VECTOR (3 - 1 DOWNTO 0); --# Set bits correspond to active interrupts
            Int_request : IN STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Controls used to activate new interrupts
            Pending : OUT STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Set bits indicate which interrupts are pending
            Current : OUT STD_LOGIC_VECTOR(3 - 1 DOWNTO 0); --# Single set bit for the active interrupt

            Interrupt : OUT STD_LOGIC; --# Flag indicating when an interrupt is pending
            Acknowledge : IN STD_LOGIC; --# Clear the active interrupt
            Clear_pending : IN STD_LOGIC --# Clear all pending interrupts
        );
    END COMPONENT;

    COMPONENT timer IS
        PORT (
            clk_i : IN STD_LOGIC;
            reset_i : IN STD_LOGIC;
            enable_counter_burst_i : IN STD_LOGIC;
            counter_burst_value_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            counter_burst_flag_o : OUT STD_LOGIC;
            data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT gpio IS
        PORT (
            clk_i : IN STD_LOGIC;
            reset_i : IN STD_LOGIC;
            --
            we_i : IN STD_LOGIC;
            data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            addr_i : IN STD_LOGIC;
            data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --
            port_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            port_dir : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            --
            interrupt_flag : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL aux_instruction : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control : STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memi_pc_out : STD_LOGIC_VECTOR(PROC_INSTR_WIDTH - 1 DOWNTO 0);

    -- Signals for memd
    SIGNAL aux_write_enable : STD_LOGIC;
    SIGNAL aux_memd_data_path_memd_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_address : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_data_path_memd_write_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- Signals for interrupt_ctl.
    SIGNAL aux_interrupt_ctl_Int_mask : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Pending : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Current : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Int_request : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Interrupt : STD_LOGIC;
    SIGNAL aux_interrupt_ctl_Acknowledge : STD_LOGIC;
    SIGNAL aux_interrupt_ctl_Clear_pending : STD_LOGIC;

    -- Signals for timer.
    SIGNAL aux_timer_enable_counter_burst : STD_LOGIC;
    SIGNAL aux_timer_counter_burst_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_timer_counter_burst_flag : STD_LOGIC;
    SIGNAL aux_timer_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Signals for gpio.
    SIGNAL aux_gpio_we : STD_LOGIC;
    SIGNAL aux_gpio_data_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_addr : STD_LOGIC;
    SIGNAL aux_gpio_data_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_dir : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_interrupt_flag : STD_LOGIC;

    -- Signals for outputs (LEDs and 7-Seg LEDS)
    SIGNAL aux_interface : memd_interface_t;
    SIGNAL aux_display : display_t;

BEGIN

    aux_write_enable <= aux_control(4); -- MemWrite
    display_1 <= aux_display(0);
    display_2 <= aux_display(1);
    display_3 <= aux_display(2);
    display_4 <= aux_display(3);
    display_5 <= aux_display(4);
    display_6 <= aux_display(5);
    leds <= aux_interface(0)(NUMBER_OF_LEDS - 1 DOWNTO 0);
    aux_interrupt_ctl_Int_request(0) <= aux_timer_counter_burst_flag; -- timer interrupt
    aux_interrupt_ctl_Int_request(1) <= aux_gpio_interrupt_flag; -- gpio interrupt

    generate_display : FOR i IN 0 TO 5 GENERATE
        instance_seven_seg_decoder : seven_seg_decoder
        PORT MAP(
            input => aux_interface(i + 1)(3 DOWNTO 0),
            output => aux_display(i)
        );
    END GENERATE generate_display;

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
        -- clock and reset ports.
        clock => clock,
        reset => reset,

        -- CPU ports.
        write_enable => aux_write_enable,
        write_data => aux_data_path_memd_write_data,
        address => aux_data_path_memd_address,
        read_data => aux_memd_data_path_memd_data,

        -- interrupt_ctl ports.
        interrupt_ctl_Int_mask => aux_interrupt_ctl_Int_mask,
        interrupt_ctl_Pending => aux_interrupt_ctl_Pending,
        interrupt_ctl_Current => aux_interrupt_ctl_Current,
        interrupt_ctl_Interrupt => aux_interrupt_ctl_Interrupt,
        interrupt_ctl_Acknowledge => aux_interrupt_ctl_Acknowledge,
        interrupt_ctl_Clear_pending => aux_interrupt_ctl_Clear_pending,

        -- timer peripheral ports.
        timer_enable_counter_burst_o => aux_timer_enable_counter_burst,
        timer_counter_burst_value_o => aux_timer_counter_burst_value,
        timer_data_i => aux_timer_data,

        -- gpio peripheral ports.
        gpio_we_o => aux_gpio_we,
        gpio_data_o => aux_gpio_data_o,
        gpio_addr_o => aux_gpio_addr,
        gpio_data_i => aux_gpio_data_i,
        gpio_port_dir => aux_gpio_port_dir,

        -- Output interface ports.
        interface => aux_interface
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

    instance_interrupt_ctl : interrupt_ctl
    PORT MAP(
        --# {{clocks|}}
        Clock => clock,
        Reset => reset,

        --# {{control|}}
        Int_mask => aux_interrupt_ctl_Int_mask,
        Int_request => aux_interrupt_ctl_Int_request,
        Pending => aux_interrupt_ctl_Pending,
        Current => aux_interrupt_ctl_Current,

        Interrupt => aux_interrupt_ctl_Interrupt,
        Acknowledge => aux_interrupt_ctl_Acknowledge,
        Clear_pending => aux_interrupt_ctl_Clear_pending
    );

    instance_timer : timer
    PORT MAP(
        clk_i => clock,
        reset_i => reset,
        enable_counter_burst_i => aux_timer_enable_counter_burst,
        counter_burst_value_i => aux_timer_counter_burst_value,
        counter_burst_flag_o => aux_timer_counter_burst_flag,
        data_o => aux_timer_data
    );

    instance_gpio : gpio
    PORT MAP(
        clk_i => clock,
        reset_i => reset,
        --
        we_i => aux_gpio_we,
        data_i => aux_gpio_data_i,
        addr_i => aux_gpio_addr,
        data_o => aux_gpio_data_o,
        --
        port_in => aux_gpio_port_in,
        port_out => aux_gpio_port_out,
        port_dir => aux_gpio_port_dir,
        --
        interrupt_flag => aux_gpio_interrupt_flag
    );
END comportamento;
