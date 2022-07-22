-- # memd size, for MD_WIDTH == 12: 2^12 Bytes = 4,096 kB
--    # interrupt_ctl size: 3 B
--    # peripheral timer size: 100 B
--    # peripheral GPIO size: 100 B
--    # peripheral UART size: 100 B
--    # interrupt_ctl flags size: 1 B

-- 5) UART range, for MD_WIDTH == 12 -> ram[3995, 4095];
--    1) uart_flags = ram[3995];
--           addr_i = ram[3995][0];
--           rden_i = ram[3995][1];
--           wren_i = ram[3995][2];
--           ack_o = ram[3995][3];
--           clkgen_en_o = ram[3995][4];
--           txd_o = ram[3995][5];
--           rxd_i = ram[3995][6];
--    2) uart_data_i = ram[3996];
--    3) uart_data_o = ram[3997];
--    4) uart_clkgen_en_o = ram[3998];
--    5) uart_clkgen_i = ram[3999](7 - 1 DOWNTO 0);

-- 4) GPIO range, for MD_WIDTH == 12 -> ram[3894, 3994];
--    1) gpio_flags = ram[3894];
--        1) gpio_we = ram[3894][0];
--        2) gpio_addr = ram[3894][1];
--    2) gpio_data_i = ram[3895];
--    3) gpio_data_o = ram[3896];
--    4) gpio_port_dir = ram[3897];

-- 3) timer range, for MD_WIDTH == 12 -> ram[3793, 3893];
--    1) timer_flags = ram[3793];
--        1) timer_enable_counter_burst = ram[3793][0];
--    2) timer_counter_burst_value = ram[3794];
--    3) timer_data = ram[3795];

-- 2) interrupt_ctl byte, for MD_WIDTH == 12 -> ram[3792];
--     1) interrupt_ctl_Interrupt = ram[3792][0];
--     2) interrupt_ctl_Acknowledge = ram[3792][1];
--     3) interrupt_ctl_Clear_pending = ram[3792][2];

-- 1) CPU range, for MD_WIDTH == 12 -> ram[0, 3791].

--------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.custom_types_package.ALL;

ENTITY memd IS
    GENERIC (
        MD_DATA_WIDTH : NATURAL; -- word size in bits
        MD_ADDRESS_WIDTH : NATURAL; -- address size in bits
        MD_WIDTH : NATURAL; -- size of data memory address in bits
        MD_SIZE : NATURAL -- size of data memory address
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

        -- timer peripheral ports.
        timer_enable_counter_burst_o : OUT STD_LOGIC;
        timer_counter_burst_value_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        timer_data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        -- gpio ports.
        gpio_we_o : OUT STD_LOGIC;
        gpio_data_o : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        gpio_addr_o : OUT STD_LOGIC;
        gpio_data_i : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        gpio_port_dir : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);

        -- uart ports.
        uart_addr_o : OUT STD_LOGIC; -- global clock line
        uart_rden_o : OUT STD_LOGIC; -- read enable
        uart_wren_o : OUT STD_LOGIC; -- write enable
        uart_ack_o : OUT STD_LOGIC; -- transfer acknowledge
        uart_clkgen_en_o : OUT STD_LOGIC; -- enable clock generator
        uart_clkgen_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        uart_rxd_i : IN STD_LOGIC;
        uart_txd_o : OUT STD_LOGIC;
        uart_cts_i : IN STD_LOGIC;
        uart_rts_o : OUT STD_LOGIC;

        -- Output interface ports.
        interface : OUT memd_interface_t
    );
END ENTITY;

ARCHITECTURE comportamental OF memd IS

    TYPE ram_type IS ARRAY (0 TO 2 ** MD_WIDTH) OF STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));

    -- UART addresses.
    CONSTANT LAST_UART_ADDRESS : NATURAL := (MD_SIZE - 1);
    CONSTANT FIRST_UART_ADDRESS : NATURAL := (LAST_UART_ADDRESS - 100);
    CONSTANT UART_FLAGS_ADDRESS : NATURAL := (FIRST_UART_ADDRESS);
    CONSTANT UART_CLKGEN_O_ADDRESS : NATURAL := (FIRST_UART_ADDRESS + 1);

    -- GPIO addresses.
    CONSTANT LAST_GPIO_ADDRESS : NATURAL := (FIRST_UART_ADDRESS - 1);
    CONSTANT FIRST_GPIO_ADDRESS : NATURAL := (LAST_GPIO_ADDRESS - 100);
    CONSTANT GPIO_FLAGS_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS);
    CONSTANT GPIO_DATA_I_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS + 1);
    CONSTANT GPIO_DATA_O_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS + 2);
    CONSTANT GPIO_PORT_DIR_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS + 3);

    -- TIMER addresses.
    CONSTANT LAST_TIMER_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS - 1);
    CONSTANT FIRST_TIMER_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS - 100);
    CONSTANT TIMER_FLAGS_ADDRESS : NATURAL := (FIRST_TIMER_ADDRESS);
    CONSTANT TIMER_COUNTER_BURST_VALUE_ADDRESS : NATURAL := (FIRST_TIMER_ADDRESS + 1);
    CONSTANT TIMER_DATA_ADDRESS : NATURAL := (FIRST_TIMER_ADDRESS + 2);

    -- interrupt_ctl registers.
    CONSTANT INT_CTL_INT_MASK_ADDRESS : NATURAL := (LAST_TIMER_ADDRESS - 1);
    CONSTANT INT_CTL_PENDING_ADDRESS : NATURAL := (INT_CTL_INT_MASK_ADDRESS - 1);
    CONSTANT INT_CTL_CURRENT_ADDRESS : NATURAL := (INT_CTL_PENDING_ADDRESS - 1);
    CONSTANT INT_CTL_FLAGS_ADDRESS : NATURAL := (INT_CTL_CURRENT_ADDRESS - 1);

    -- CPU addresses.
    CONSTANT LAST_CPU_ADDRESS : NATURAL := (INT_CTL_FLAGS_ADDRESS - 1);
    CONSTANT FIRST_CPU_ADDRESS : NATURAL := 0;

BEGIN
    process_cpu : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSIF (write_enable = '1' AND unsigned(address) < MD_SIZE) THEN
                ram(to_integer(unsigned(address))) <= write_data;
            ELSE
                read_data <= ram(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS process_cpu;

    process_interrupt_ctl : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSE
                interrupt_ctl_Int_mask <= ram(INT_CTL_INT_MASK_ADDRESS)(3 - 1 DOWNTO 0);
                ram(INT_CTL_PENDING_ADDRESS)(3 - 1 DOWNTO 0) <= interrupt_ctl_Pending;
                ram(INT_CTL_CURRENT_ADDRESS)(3 - 1 DOWNTO 0) <= interrupt_ctl_Current;
                ram(INT_CTL_FLAGS_ADDRESS)(0) <= interrupt_ctl_Interrupt;
                interrupt_ctl_Acknowledge <= ram(INT_CTL_FLAGS_ADDRESS)(1);
                interrupt_ctl_Clear_pending <= ram(INT_CTL_FLAGS_ADDRESS)(2);
            END IF;
        END IF;
    END PROCESS process_interrupt_ctl;

    process_timer : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSE
                timer_enable_counter_burst_o <= ram(TIMER_FLAGS_ADDRESS)(0);
                timer_counter_burst_value_o <= ram(TIMER_COUNTER_BURST_VALUE_ADDRESS);
                ram(TIMER_DATA_ADDRESS) <= timer_data_i;
            END IF;
        END IF;
    END PROCESS process_timer;

    process_gpio : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSE
                gpio_we_o <= ram(GPIO_FLAGS_ADDRESS)(0);
                gpio_data_o <= ram(GPIO_DATA_O_ADDRESS);
                gpio_addr_o <= ram(GPIO_FLAGS_ADDRESS)(1);
                ram(GPIO_DATA_I_ADDRESS) <= gpio_data_i;
                ram(GPIO_PORT_DIR_ADDRESS) <= gpio_port_dir;
            END IF;
        END IF;
    END PROCESS process_gpio;

    process_uart : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSE
                uart_addr_o <= ram(UART_FLAGS_ADDRESS)(0);
                uart_rden_o <= ram(UART_FLAGS_ADDRESS)(1);
                uart_wren_o <= ram(UART_FLAGS_ADDRESS)(2);
                uart_ack_o <= ram(UART_FLAGS_ADDRESS)(3);
                uart_clkgen_en_o <= ram(UART_FLAGS_ADDRESS)(4);
                uart_clkgen_o <= ram(UART_CLKGEN_O_ADDRESS)(7 DOWNTO 0);
                ram(UART_FLAGS_ADDRESS)(5) <= uart_rxd_i;
                uart_txd_o <= ram(UART_FLAGS_ADDRESS)(6);
                ram(UART_FLAGS_ADDRESS)(7) <= uart_cts_i;
                uart_rts_o <= ram(UART_FLAGS_ADDRESS)(8);
            END IF;
        END IF;
    END PROCESS process_uart;

    generate_ifc : FOR i IN 0 TO 6 GENERATE
        interface(i) <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(ram(i))), 32));
    END GENERATE generate_ifc;
END comportamental;
