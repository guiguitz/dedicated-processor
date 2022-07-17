LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_data_path IS
    GENERIC (
        DP_CTRL_BUS_WIDTH : NATURAL; -- DataPath (DP) control bus size in bits
        DATA_WIDTH : NATURAL; -- data size in bits
        PC_WIDTH : NATURAL; -- pc size in bits
        INSTR_WIDTH : NATURAL; -- instruction size in bits
        MD_WIDTH : NATURAL -- size of data memory address in bits
    );
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        control : IN STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
        instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
        memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- memd 'Read Data'
        memd_address : OUT STD_LOGIC_VECTOR(MD_WIDTH - 1 DOWNTO 0); -- memd 'Address'
        memd_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) -- memd 'Write Data'
    );
END ENTITY single_cycle_data_path;

ARCHITECTURE comportamento OF single_cycle_data_path IS

    COMPONENT pc IS
        GENERIC (
            PC_WIDTH : NATURAL := 32
        );
        PORT (
            entrada : IN STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT adder IS
        GENERIC (
            largura_dado : NATURAL := 32
        );
        PORT (
            entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT register_file IS
        GENERIC (
            DATA_WIDTH : NATURAL := 32;
            ADDRESS_WIDTH : NATURAL := 5
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

    COMPONENT alu IS
        GENERIC (
            largura_dado : NATURAL := 32
        );
        PORT (
            entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            seletor : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            zero : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mux21 IS
        GENERIC (
            largura_dado : NATURAL := 32
        );
        PORT (
            dado_ent_0, dado_ent_1 : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sele_ent : IN STD_LOGIC;
            dado_sai : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT extensor IS
        GENERIC (
            largura_dado : NATURAL := 12;
            largura_saida : NATURAL := 32
        );

        PORT (
            entrada_Rs : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_saida - 1) DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT two_bits_shifter IS
        GENERIC (
            data_width : NATURAL := 32
        );

        PORT (
            operand : IN STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0)
        );
    END COMPONENT;

    -- SIGNAL_NAME_PATTERN: aux_<src>_<dst>_<dst_port>
    -- ALU signals
    SIGNAL aux_alu_op : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL aux_zero : STD_LOGIC;

    -- mux0 signals:
    SIGNAL aux_m5_m0_dado_ent_1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m0_m1_dado_sai : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control_m0_sele_ent : STD_LOGIC;
    SIGNAL aux_epc_m0_dado_ent_0 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- 'X

    -- mux1 signals:
    SIGNAL aux_ia_m1_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0); -- 'X
    SIGNAL aux_m1_pc_entrada : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control_m1_sele_ent : STD_LOGIC;

    -- mux2 signals:
    SIGNAL aux_m2_register_write_data : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control_m2_sele_ent : STD_LOGIC;

    -- mux3 signals:
    SIGNAL aux_control_m3_sele_ent : STD_LOGIC;
    SIGNAL aux_m3_ula_entrada_b : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_register_m3_memd : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- mux4 signals:
    SIGNAL aux_s0_m4_dado_ent_1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_control_m4_sele_ent : STD_LOGIC;

    -- mux5 signals:
    SIGNAL aux_a1_m5_dado_ent_1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- mux6 signals:
    SIGNAL aux_control_m6_sele_ent : STD_LOGIC;
    SIGNAL aux_memd_m6_dado_ent_1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m6_m2_dado_ent_1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_alu_memd_m6_dado_ent_0 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- adder0:
    SIGNAL aux_pc_adder0_adder1 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_adder0_m2_m5 : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- adder1:
    SIGNAL aux_m4_a1_entrada_b : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- process branch (BEQ, BNE)
    SIGNAL aux_bne : STD_LOGIC;
    SIGNAL aux_beq : STD_LOGIC;
    SIGNAL aux_m5_sele_ent : STD_LOGIC;

    -- Sign Extend
    SIGNAL aux_memi_se_entrada_Rs : STD_LOGIC_VECTOR(12 - 1 DOWNTO 0);
    SIGNAL aux_se_m3_m4_shifter : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- Alu
    SIGNAL aux_register_alu_entrada_a : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

    -- Register File
    SIGNAL aux_register_write : STD_LOGIC;
    SIGNAL aux_memi_register_rs1 : STD_LOGIC_VECTOR(19 DOWNTO 15);
    SIGNAL aux_memi_register_rs2 : STD_LOGIC_VECTOR(24 DOWNTO 20);
    SIGNAL aux_memi_register_rd : STD_LOGIC_VECTOR(11 DOWNTO 7);

BEGIN

    aux_register_write <= control(2); -- RegWrite
    aux_alu_op <= control(8 DOWNTO 5); -- AluOp
    aux_control_m4_sele_ent <= control(12); -- Jump
    pc_out <= aux_pc_adder0_adder1;

    aux_control_m0_sele_ent <= control(1); -- PcSrc
    aux_control_m1_sele_ent <= control(0); -- ItController
    aux_bne <= control(11); -- BranchNEQ
    aux_beq <= control(10); -- BranchEQ
    aux_control_m6_sele_ent <= control(9); -- MemToReg
    aux_memd_m6_dado_ent_1 <= memd_data;
    aux_memi_se_entrada_Rs <= instruction(31 DOWNTO 20);
    aux_control_m2_sele_ent <= control(13); -- RegDst
    aux_control_m3_sele_ent <= control(3); -- AluSrc
    memd_write_data <= aux_register_m3_memd;
    memd_address <= aux_alu_memd_m6_dado_ent_0;
    aux_memi_register_rs1 <= instruction(19 DOWNTO 15);
    aux_memi_register_rs2 <= instruction(24 DOWNTO 20);
    aux_memi_register_rd <= instruction(11 DOWNTO 7);

    instance_alu0 : alu
    PORT MAP(
        entrada_a => aux_register_alu_entrada_a,
        entrada_b => aux_m3_ula_entrada_b,
        seletor => aux_alu_op,
        saida => aux_alu_memd_m6_dado_ent_0,
        zero => aux_zero
    );

    instance_register_file : register_file
    PORT MAP(
        clock => clock,
        reset => reset,
        rs1 => aux_memi_register_rs1,
        rs2 => aux_memi_register_rs2,
        rd => aux_memi_register_rd,
        write_data => aux_m2_register_write_data,
        out_rs1 => aux_register_alu_entrada_a,
        out_rs2 => aux_register_m3_memd,
        we => aux_register_write
    );

    instance_pc : pc
    PORT MAP(
        entrada => aux_m1_pc_entrada,
        saida => aux_pc_adder0_adder1,
        clock => clock,
        -- we => aux_we,
        reset => reset
    );

    instance_adder0 : adder
    PORT MAP(
        entrada_a => aux_pc_adder0_adder1,
        entrada_b => x"00000004",
        saida => aux_adder0_m2_m5
    );

    instance_adder1 : adder
    PORT MAP(
        entrada_a => aux_pc_adder0_adder1,
        entrada_b => aux_m4_a1_entrada_b,
        saida => aux_a1_m5_dado_ent_1
    );

    instance_sign_extend : extensor
    PORT MAP(
        entrada_Rs => aux_memi_se_entrada_Rs,
        saida => aux_se_m3_m4_shifter
    );

    instance_mux0 : mux21
    PORT MAP(
        dado_ent_0 => aux_epc_m0_dado_ent_0,
        dado_ent_1 => aux_m5_m0_dado_ent_1,
        sele_ent => aux_control_m0_sele_ent,
        dado_sai => aux_m0_m1_dado_sai
    );

    instance_mux1 : mux21
    PORT MAP(
        dado_ent_0 => aux_m0_m1_dado_sai,
        dado_ent_1 => aux_ia_m1_dado_ent_1,
        sele_ent => aux_control_m1_sele_ent,
        dado_sai => aux_m1_pc_entrada
    );

    instance_mux2 : mux21
    PORT MAP(
        dado_ent_0 => aux_adder0_m2_m5,
        dado_ent_1 => aux_m6_m2_dado_ent_1,
        sele_ent => aux_control_m2_sele_ent,
        dado_sai => aux_m2_register_write_data
    );

    instance_mux3 : mux21
    PORT MAP(
        dado_ent_0 => aux_register_m3_memd,
        dado_ent_1 => aux_se_m3_m4_shifter,
        sele_ent => aux_control_m3_sele_ent,
        dado_sai => aux_m3_ula_entrada_b
    );

    instance_mux4 : mux21
    PORT MAP(
        dado_ent_0 => aux_se_m3_m4_shifter,
        dado_ent_1 => aux_s0_m4_dado_ent_1,
        sele_ent => aux_control_m4_sele_ent,
        dado_sai => aux_m4_a1_entrada_b
    );

    instance_mux5 : mux21
    PORT MAP(
        dado_ent_0 => aux_adder0_m2_m5,
        dado_ent_1 => aux_a1_m5_dado_ent_1,
        sele_ent => aux_m5_sele_ent,
        dado_sai => aux_m5_m0_dado_ent_1
    );

    instance_mux6 : mux21
    PORT MAP(
        dado_ent_0 => aux_alu_memd_m6_dado_ent_0,
        dado_ent_1 => aux_memd_m6_dado_ent_1,
        sele_ent => aux_control_m6_sele_ent,
        dado_sai => aux_m6_m2_dado_ent_1
    );

    instance_shifter : two_bits_shifter
    PORT MAP(
        operand => aux_se_m3_m4_shifter,
        result => aux_s0_m4_dado_ent_1
    );

    PROCESS (aux_zero, aux_bne, aux_beq) IS
    BEGIN
        aux_m5_sele_ent <= (aux_bne AND (NOT(aux_zero))) OR (aux_beq AND aux_zero);
    END PROCESS;
END ARCHITECTURE comportamento;
