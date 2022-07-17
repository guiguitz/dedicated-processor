LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.custom_types_package.ALL;

ENTITY memd IS
    GENERIC (
        MD_DATA_WIDTH : NATURAL := 32; -- word size in bits
        MD_ADDR_WIDTH : NATURAL := 12 -- size of data memory address in bits
    );
    PORT (
        clock : IN STD_LOGIC;
        write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        address : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        write_enable : IN STD_LOGIC;
        interface : OUT memd_interface_t
    );
END ENTITY;

ARCHITECTURE comportamental OF memd IS
    -- memd size: 2^12 Bytes = 4 kB
    TYPE ram_type IS ARRAY (0 TO 2 ** MD_ADDR_WIDTH) OF STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clock)
    BEGIN
        IF (rising_edge(clock)) THEN
            IF (write_enable = '1') THEN
                ram(to_integer(unsigned(address))) <= write_data;
            ELSE
                read_data <= ram(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS;

    gen_ifc :
    FOR i IN 0 TO 6 GENERATE
        interface(i) <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(ram(i))), 32));
    END GENERATE gen_ifc;
END comportamental;
