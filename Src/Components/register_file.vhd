LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file IS
    GENERIC (
        DATA_WIDTH : NATURAL;
        ADDRESS_WIDTH : NATURAL
    );

    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        rs1 : IN STD_LOGIC_VECTOR((ADDRESS_WIDTH - 1) DOWNTO 0); -- rs1, Read Register 1, Instruction [19-15]
        rs2 : IN STD_LOGIC_VECTOR((ADDRESS_WIDTH - 1) DOWNTO 0); -- rs2, Read Register 2, Instruction [24-20]
        rd : IN STD_LOGIC_VECTOR((ADDRESS_WIDTH - 1) DOWNTO 0); -- rd, Write Register, Instruction [11-7], Address to access during writing
        write_data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0); -- Write Data, Data to write
        out_rs1 : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0); -- Read Data 1
        out_rs2 : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0); -- Read Data 2
        we : IN STD_LOGIC -- RegWrite
    );
END register_file;

ARCHITECTURE comportamental OF register_file IS
    TYPE register_file_type IS ARRAY(0 TO ((2 ** ADDRESS_WIDTH) - 1)) OF STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
    SIGNAL bank : register_file_type := (OTHERS => (OTHERS => '0'));
BEGIN
    reading : PROCESS (clock, bank, rs1, rs2) IS
    BEGIN
        out_rs1 <= bank(to_integer(unsigned(rs1)));
        out_rs2 <= bank(to_integer(unsigned(rs2)));
    END PROCESS;

    writing : PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '1' THEN
                bank <= (
                    0 => B"00001000000000000000001000000001", -- X"8000201"
                    1 => B"00001100000000000000111100000001", -- X"C000F01"
                    2 => B"00000100000000000000000000000001", -- X"4000001"
                    3 => B"00000000001000000100000010000100", -- X"204084"
                    4 => B"11111100000100001111100010010101", -- X"FC10F895"
                    5 => B"00000000000000000000000000000000", -- X"0"
                    6 => B"00000100000100000000000100000001", -- X"4100101"
                    7 => B"00000000000000000000110010010110", -- X"C96"
                    8 => B"00000000000000000000000000000000", -- X"0"
                    OTHERS => B"00000000000000000000000000000000" -- d"0"
                    );
            ELSIF we = '1' THEN
                bank(to_integer(unsigned(rd))) <= write_data;
            END IF;
        END IF;
    END PROCESS;
END comportamental;
