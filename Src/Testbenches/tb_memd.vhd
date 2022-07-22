LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.instructions_package.ALL;
USE work.custom_types_package.ALL;

ENTITY tb_memd IS
END tb_memd;

ARCHITECTURE estimulos OF tb_memd IS

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
    END COMPONENT;

    -- clock and reset signals.
    SIGNAL clock : STD_LOGIC;
    SIGNAL reset : STD_LOGIC;

    -- CPU signals.
    SIGNAL aux_write_enable : STD_LOGIC;
    SIGNAL aux_write_data : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_address : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_read_data : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);

    -- interrupt_ctl signals.
    SIGNAL aux_interrupt_ctl_Int_mask : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Pending : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Current : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL aux_interrupt_ctl_Interrupt : STD_LOGIC;
    SIGNAL aux_interrupt_ctl_Acknowledge : STD_LOGIC;
    SIGNAL aux_interrupt_ctl_Clear_pending : STD_LOGIC;

    -- timer peripheral signals.
    SIGNAL aux_timer_enable_counter_burst : STD_LOGIC;
    SIGNAL aux_timer_counter_burst_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_timer_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Signals for gpio.
    SIGNAL aux_gpio_we : STD_LOGIC;
    SIGNAL aux_gpio_data_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_addr : STD_LOGIC;
    SIGNAL aux_gpio_data_o : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL aux_gpio_port_dir : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Signals for uart.
    SIGNAL aux_uart_addr_i : STD_LOGIC_VECTOR(31 DOWNTO 0); -- address
    SIGNAL aux_uart_rden_i : STD_LOGIC; -- read enable
    SIGNAL aux_uart_wren_i : STD_LOGIC; -- write enable
    SIGNAL aux_uart_data_i : STD_LOGIC_VECTOR(31 DOWNTO 0); -- data in
    SIGNAL aux_uart_data_o : STD_LOGIC_VECTOR(31 DOWNTO 0); -- data out
    SIGNAL aux_uart_ack_o : STD_LOGIC; -- transfer acknowledge
    SIGNAL aux_uart_clkgen_en_o : STD_LOGIC; -- enable clock generator
    SIGNAL aux_uart_clkgen_i : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL aux_uart_txd_o : STD_LOGIC;
    SIGNAL aux_uart_rxd_i : STD_LOGIC;
    SIGNAL aux_uart_rts_o : STD_LOGIC; -- UART.RX ready to receive ("RTR"), low-active, optional
    SIGNAL aux_uart_cts_i : STD_LOGIC; -- UART.TX allowed to transmit, low-active, optional
    SIGNAL aux_uart_irq_rxd_o : STD_LOGIC; -- uart data received interrupt
    SIGNAL aux_uart_irq_txd_o : STD_LOGIC; -- uart transmission done interrupt

    -- Output interface ports.
    SIGNAL aux_interface : memd_interface_t;

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;

BEGIN
    instance_memd : memd
    PORT MAP(
        -- clock and reset ports.
        clock => clock,
        reset => reset,

        -- CPU ports.
        write_enable => aux_write_enable,
        write_data => aux_write_data,
        address => aux_address,
        read_data => aux_read_data,

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

        -- uart ports.
        uart_addr_o => aux_uart_addr_o,
        uart_rden_o => aux_uart_rden_o,
        uart_wren_o => aux_uart_wren_o,
        uart_ack_o => aux_uart_ack_o,
        uart_clkgen_en_o => aux_uart_clkgen_en_o,
        uart_clkgen_o => uart_clkgen_o,
        uart_rxd_i => aux_uart_rxd_i,
        uart_txd_o => aux_uart_txd_o,
        uart_cts_i => aux_uart_cts_i,
        uart_rts_o => aux_uart_rts_o,

        -- gpio peripheral ports.
        gpio_we_o => aux_gpio_we,
        gpio_data_o => aux_gpio_data_o,
        gpio_addr_o => aux_gpio_addr,
        gpio_data_i => aux_gpio_data_i,
        gpio_port_dir => aux_gpio_port_dir
    );

    generate_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            clock <= '0';
            WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
            clock <= '1';
            WAIT FOR (PERIOD * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS generate_clock;

    generate_reset : PROCESS
    BEGIN
        reset <= '1';
        WAIT UNTIL falling_edge(clock);
        reset <= '0';
        WAIT;
    END PROCESS generate_reset;

    test_memd : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP

            -- Writing data on memd
            aux_write_enable <= '1';

            aux_address <= X"00000000";
            aux_write_data <= ADD_INSTR_BINARY; -- ADD
            WAIT FOR PERIOD;
            aux_address <= X"00000001";
            aux_write_data <= SLL_INSTR_BINARY; -- SLL
            WAIT FOR PERIOD;
            aux_address <= X"00000002";
            aux_write_data <= ADDI_INSTR_BINARY; -- ADDI
            WAIT FOR PERIOD;
            aux_address <= X"00000003";
            aux_write_data <= NOP_INSTR_BINARY; -- NOP
            WAIT FOR PERIOD;
            aux_address <= X"00000004";
            aux_write_data <= LW_INSTR_BINARY; -- LW
            WAIT FOR PERIOD;
            aux_address <= X"00000005";
            aux_write_data <= BNE_INSTR_BINARY; -- BNE
            WAIT FOR PERIOD;
            aux_address <= X"00000006";
            aux_write_data <= BEQ_INSTR_BINARY; -- BEQ
            WAIT FOR PERIOD;
            aux_address <= X"00000007";
            aux_write_data <= SW_INSTR_BINARY; -- SW
            WAIT FOR PERIOD;
            aux_address <= X"00000008";
            aux_write_data <= J_INSTR_BINARY; -- J
            WAIT FOR PERIOD;

            aux_write_enable <= '0';

            aux_address <= X"00000000";
            WAIT FOR PERIOD;

            aux_address <= X"00000001";
            WAIT FOR PERIOD;

            aux_address <= X"00000002";
            WAIT FOR PERIOD;

            aux_address <= X"00000003";
            WAIT FOR PERIOD;

            aux_address <= X"00000004";
            WAIT FOR PERIOD;

            aux_address <= X"00000005";
            WAIT FOR PERIOD;

            aux_address <= X"00000006";
            WAIT FOR PERIOD;
        END LOOP CLOCK_LOOP;
    END PROCESS test_memd;
END;
