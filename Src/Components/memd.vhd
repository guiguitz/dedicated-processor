-- # memd size, for MD_WIDTH == 12: 2^12 Bytes = 4,096 kB
--    # interrupt_ctl size: 3 B
--    # peripheral timer size: 100 B
--    # peripheral GPIO size: 100 B
--    # peripheral UART size: 100 B

-- UART range, for MD_WIDTH == 12 -> ram[3995, 4095].
-- GPIO range, for MD_WIDTH == 12 -> ram[3894, 3994].
-- TIMER range, for MD_WIDTH == 12 -> ram[3793, 3893].
-- CPU range, for MD_WIDTH == 12 -> ram[0, 3792].

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
        Int_mask : OUT STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
        Pending : IN STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
        Current : IN STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);

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

    -- GPIO addresses.
    CONSTANT LAST_GPIO_ADDRESS : NATURAL := (FIRST_UART_ADDRESS - 1);
    CONSTANT FIRST_GPIO_ADDRESS : NATURAL := (LAST_GPIO_ADDRESS - 100);

    -- TIMER addresses.
    CONSTANT LAST_TIMER_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS - 1);
    CONSTANT FIRST_TIMER_ADDRESS : NATURAL := (FIRST_GPIO_ADDRESS - 100);

    -- interrupt_ctl registers.
    CONSTANT INT_CTL_INT_MASK_ADDRESS : NATURAL := (LAST_TIMER_ADDRESS - 1);
    CONSTANT INT_CTL_PENDING_ADDRESS : NATURAL := (INT_CTL_INT_MASK_ADDRESS - 1);
    CONSTANT INT_CTL_CURRENT_ADDRESS : NATURAL := (INT_CTL_PENDING_ADDRESS - 1);

    -- CPU addresses.
    CONSTANT LAST_CPU_ADDRESS : NATURAL := (FIRST_TIMER_ADDRESS - 1);
    CONSTANT FIRST_CPU_ADDRESS : NATURAL := 0;

BEGIN
    process_cpu : PROCESS (clock, reset)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (reset = '1') THEN
                ram <= (OTHERS => (OTHERS => '0'));
            ELSIF (write_enable = '1' AND unsigned(address) < LAST_CPU_ADDRESS) THEN
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
                Int_mask <= ram(INT_CTL_INT_MASK_ADDRESS)(3 - 1 DOWNTO 0);
                ram(INT_CTL_PENDING_ADDRESS)(3 - 1 DOWNTO 0) <= Pending;
                ram(INT_CTL_CURRENT_ADDRESS)(3 - 1 DOWNTO 0) <= Current;
            END IF;
        END IF;
    END PROCESS process_interrupt_ctl;

    generate_ifc : FOR i IN 0 TO 6 GENERATE
        interface(i) <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(ram(i))), 32));
    END GENERATE generate_ifc;
END comportamental;
