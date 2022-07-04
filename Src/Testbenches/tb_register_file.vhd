LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.instructions_package.ALL;

ENTITY tb_register_file IS
END tb_register_file;

ARCHITECTURE estimulos OF tb_register_file IS

    COMPONENT register_file IS
        GENERIC (
            DATA_WIDTH : NATURAL := 32;
            ADDRESS_WIDTH : NATURAL := 5 -- address size in bits -> 2^5 = 32 bits
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
    END COMPONENT;

    SIGNAL aux_clock : STD_LOGIC;
    SIGNAL aux_reset : STD_LOGIC;
    SIGNAL aux_rs1 : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    SIGNAL aux_rs2 : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    SIGNAL aux_rd : STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    SIGNAL aux_write_data : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_out_rs1 : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_out_rs2 : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    SIGNAL aux_we : STD_LOGIC;

    CONSTANT PERIOD : TIME := 20 ns;
    CONSTANT DUTY_CYCLE : real := 0.5;
    CONSTANT OFFSET : TIME := 5 ns;
    CONSTANT MEIO_OFFSET : TIME := 5 ns;

BEGIN
    instance_register_file : register_file PORT MAP(aux_clock, aux_reset, aux_rs1, aux_rs2, aux_rd, aux_write_data, aux_out_rs1, aux_out_rs2, aux_we);

    generate_clock : PROCESS
    BEGIN
        WAIT FOR OFFSET;
        CLOCK_LOOP : LOOP
            aux_clock <= '0';
            WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
            aux_clock <= '1';
            WAIT FOR (PERIOD * DUTY_CYCLE);
        END LOOP CLOCK_LOOP;
    END PROCESS generate_clock;

    generate_reset : PROCESS
    BEGIN
        aux_reset <= '1';
        WAIT UNTIL falling_edge(aux_clock);
        aux_reset <= '0';
        WAIT;
    END PROCESS generate_reset;

    test_register_file : PROCESS
    BEGIN
        CLOCK_LOOP : LOOP

        -- ADD: R[rd] = R[rs1] + R[rs2] -> R[4] = R[3] + R[10]
        aux_rd <= ADD_INSTR_RD;
        aux_rs1 <= ADD_INSTR_RS1;
        aux_rs2 <= ADD_INSTR_RS2;
        aux_write_data <= X"00000013";
        aux_we <= '1';
        WAIT FOR PERIOD;

        END LOOP CLOCK_LOOP;
    END PROCESS test_register_file;
END;
