LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_data_path IS
    GENERIC (
        DP_CTRL_BUS_WIDTH : NATURAL; -- DataPath (DP) control bus size in bits
        DATA_WIDTH : NATURAL; -- data size in bits
        PC_WIDTH : NATURAL; -- pc size in bits
        INSTR_WIDTH : NATURAL; -- instruction size in bits
        MD_ADDR_WIDTH : NATURAL -- size of data memory address in bits
    );
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        control : IN STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
        instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
        memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- memd 'Read Data'
        memd_address : OUT STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0); -- memd 'Address'
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

    COMPONENT banco_registradores IS
        GENERIC (
            largura_dado : NATURAL := 32;
            largura_ende : NATURAL := 5
        );
        PORT (
            ent_rs_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_rt_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_rd_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_rd_dado : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sai_rs_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sai_rt_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            clock : IN STD_LOGIC;
            we : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ula IS
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

    -- COMPONENT hdl_register IS
    --     GENERIC (
    --         largura_dado : NATURAL := 32
    --     );
    --     PORT (
    --         entrada_dados : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
    --         WE, clock, reset : IN STD_LOGIC;
    --         saida_dados : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
    --     );
    -- END COMPONENT;

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

    COMPONENT interrupt_address_registers IS
        GENERIC (
            largura_dado : NATURAL := 32;
            largura_ende : NATURAL := 5
        );

        PORT (
            address : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            input : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            clock, WE : IN STD_LOGIC
        );
    END COMPONENT;

    -- SIGNAL_NAME_PATTERN: aux_<src>_<dst>_<dst_port>

    SIGNAL aux_read_rs : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_read_rt : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_write_rd : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_data_in : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
    SIGNAL aux_data_outrs : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
    SIGNAL aux_reg_write : STD_LOGIC;

    SIGNAL aux_ula_ctrl : STD_LOGIC_VECTOR(ula_ctrl_width - 1 DOWNTO 0);

    SIGNAL aux_pc_adder0_mmi : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_novo_pc : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- ULA signals
    SIGNAL aux_zero : STD_LOGIC;

    -- mux0 signals:
    SIGNAL aux_epc_m0_dado_ent_0 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m5_m0_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m0_m1_dado_sai : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m0_sele_ent : STD_LOGIC;

    -- mux1 signals:
    SIGNAL aux_ia_m1_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m1_pc_entrada : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m1_sele_ent : STD_LOGIC;

    -- mux2 signals:
    SIGNAL aux_m2_reg_ent_Rd_dado : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m2_sele_ent : STD_LOGIC;

    -- mux3 signals:
    SIGNAL aux_ctrl_m3_sele_ent : STD_LOGIC;
    SIGNAL aux_m3_ula_entrada_b : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_reg_m3_mmed : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- mux4 signals:
    SIGNAL aux_s0_m4_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m4_sele_ent : STD_LOGIC;

    -- mux5 signals:
    SIGNAL aux_a1_m5_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- mux6 signals:
    SIGNAL aux_ctrl_m6_sele_ent : STD_LOGIC;
    SIGNAL aux_mmed_m6_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m6_m2_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_alu_m6_dado_ent_0 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- adder0:
    SIGNAL aux_a0_m2_m5_pc4 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_plus_four : unsigned(PC_WIDTH - 1 DOWNTO 0) := x"00000004";

    -- adder1:
    SIGNAL aux_m4_a1_entrada_b : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- process branch (BEQ, BNE)
    SIGNAL aux_branchNEQ : STD_LOGIC;
    SIGNAL aux_branchEQ : STD_LOGIC;
    SIGNAL aux_m5_sele_ent : STD_LOGIC;

    -- Sign Extend
    SIGNAL aux_mmi_se_entrada_Rs : STD_LOGIC_VECTOR(12 - 1 DOWNTO 0);
    SIGNAL aux_se_m3_m4_shifter : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- Alu
    SIGNAL aux_reg_alu_entrada_a : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- Reg
    SIGNAL aux_mmi_reg_ent_Rs_ende : STD_LOGIC_VECTOR(19 DOWNTO 15);
    SIGNAL aux_mmi_reg_ent_Rt_ende : STD_LOGIC_VECTOR(24 DOWNTO 20);
    SIGNAL aux_mmi_reg_ent_Rd_ende : STD_LOGIC_VECTOR(11 DOWNTO 7);

BEGIN

    aux_reg_write <= control(2); -- RegWrite
    aux_ula_ctrl <= control(8 DOWNTO 5); -- AluOp
    aux_ctrl_m4_sele_ent <= control(12); -- Jump
    pc_out <= aux_pc_adder0_mmi;

    aux_ctrl_m0_sele_ent <= control(1); -- PcSrc
    aux_ctrl_m1_sele_ent <= control(0); -- ItController
    aux_branchNEQ <= control(11); -- BranchNEQ
    aux_branchEQ <= control(10); -- BranchEQ
    aux_ctrl_m6_sele_ent <= control(9); -- MemToReg
    aux_mmed_m6_dado_ent_1 <= memd_data;
    aux_mmi_se_entrada_Rs <= instruction(31 DOWNTO 20);
    aux_ctrl_m2_sele_ent <= control(13); -- RegDst
    aux_ctrl_m3_sele_ent <= control(3); -- AluSrc
    memd_write_data <= aux_reg_m3_mmed;
    memd_address <= aux_alu_m6_dado_ent_0;
    aux_mmi_reg_ent_Rs_ende <= instruction(19 DOWNTO 15);
    aux_mmi_reg_ent_Rt_ende <= instruction(24 DOWNTO 20);
    aux_mmi_reg_ent_Rd_ende <= instruction(11 DOWNTO 7);

    instance_ula1 : ula
    PORT MAP(
        entrada_a => aux_reg_alu_entrada_a,
        entrada_b => aux_m3_ula_entrada_b,
        seletor => aux_ula_ctrl,
        saida => aux_alu_m6_dado_ent_0,
        zero => aux_zero
    );

    instance_banco_registradores : banco_registradores
    PORT MAP(
        ent_rs_ende => aux_mmi_reg_ent_Rs_ende,
        ent_rt_ende => aux_mmi_reg_ent_Rt_ende,
        ent_rd_ende => aux_mmi_reg_ent_Rd_ende,
        ent_rd_dado => aux_m2_reg_ent_Rd_dado,
        sai_rs_dado => aux_reg_alu_entrada_a,
        sai_rt_dado => aux_reg_m3_mmed,
        clock => clock,
        we => aux_reg_write
    );

    instance_pc : pc
    PORT MAP(
        entrada => aux_m1_pc_entrada,
        saida => aux_pc_adder0_mmi,
        clock => clock,
        -- we => aux_we,
        reset => reset
    );

    instance_adder0 : adder
    PORT MAP(
        entrada_a => aux_pc_adder0_mmi,
        entrada_b => STD_LOGIC_VECTOR(aux_plus_four),
        saida => aux_a0_m2_m5_pc4
    );

    instance_adder1 : adder
    PORT MAP(
        entrada_a => aux_pc_adder0_mmi,
        entrada_b => aux_m4_a1_entrada_b,
        saida => aux_a1_m5_dado_ent_1
    );

    instance_sign_extend : extensor
    PORT MAP(
        entrada_Rs => aux_mmi_se_entrada_Rs,
        saida => aux_se_m3_m4_shifter
    );

    -- instance_epc : hdl_register
    --     port map(
    --         entrada_dados => aux_m0_m1_dado_sai,
    --         -- WE => std_logic_vector("0001"),
    --         clock => clock,
    --         -- reset => std_logic_vector("0001"),
    --         saida_dados => aux_epc_m0_dado_ent_0
    --     );

    instance_mux0 : mux21
    PORT MAP(
        dado_ent_0 => aux_epc_m0_dado_ent_0,
        dado_ent_1 => aux_m5_m0_dado_ent_1,
        sele_ent => aux_ctrl_m0_sele_ent,
        dado_sai => aux_m0_m1_dado_sai
    );

    instance_mux1 : mux21
    PORT MAP(
        dado_ent_0 => aux_m0_m1_dado_sai,
        dado_ent_1 => aux_ia_m1_dado_ent_1,
        sele_ent => aux_ctrl_m1_sele_ent,
        dado_sai => aux_m1_pc_entrada
    );

    instance_mux2 : mux21
    PORT MAP(
        dado_ent_0 => aux_a0_m2_m5_pc4,
        dado_ent_1 => aux_m6_m2_dado_ent_1,
        sele_ent => aux_ctrl_m2_sele_ent,
        dado_sai => aux_m2_reg_ent_Rd_dado
    );

    instance_mux3 : mux21
    PORT MAP(
        dado_ent_0 => aux_reg_m3_mmed,
        dado_ent_1 => aux_se_m3_m4_shifter,
        sele_ent => aux_ctrl_m3_sele_ent,
        dado_sai => aux_m3_ula_entrada_b
    );

    instance_mux4 : mux21
    PORT MAP(
        dado_ent_0 => aux_se_m3_m4_shifter,
        dado_ent_1 => aux_s0_m4_dado_ent_1,
        sele_ent => aux_ctrl_m4_sele_ent,
        dado_sai => aux_m4_a1_entrada_b
    );

    instance_mux5 : mux21
    PORT MAP(
        dado_ent_0 => aux_a0_m2_m5_pc4,
        dado_ent_1 => aux_a1_m5_dado_ent_1,
        sele_ent => aux_m5_sele_ent,
        dado_sai => aux_m5_m0_dado_ent_1
    );

    instance_mux6 : mux21
    PORT MAP(
        dado_ent_0 => aux_alu_m6_dado_ent_0,
        dado_ent_1 => aux_mmed_m6_dado_ent_1,
        sele_ent => aux_ctrl_m6_sele_ent,
        dado_sai => aux_m6_m2_dado_ent_1
    );

    -- instance_interrupt_address_registers : interrupt_address_registers
    --     port map(
    --         output => aux_ia_m1_dado_ent_1,
    --         -- ent_rs_ende => aux_read_rs,
    --         -- ent_rt_ende => aux_read_rt,
    --         -- ent_rd_ende => aux_write_rd,
    --         -- ent_rd_dado => aux_data_in,
    --         -- sai_rs_dado => aux_data_outrs,
    --         -- sai_rt_dado => aux_data_outrt,
    --         clock => clock,
    --         -- we => aux_reg_write
    --     );

    instance_shifter : two_bits_shifter
    PORT MAP(
        operand => aux_se_m3_m4_shifter,
        result => aux_s0_m4_dado_ent_1
    );

    PROCESS (aux_zero, aux_branchNEQ, aux_branchEQ) IS
    BEGIN
        aux_m5_sele_ent <= (aux_branchNEQ AND (NOT(aux_zero))) OR (aux_branchNEQ AND aux_zero);
    END PROCESS;
END ARCHITECTURE comportamento;
