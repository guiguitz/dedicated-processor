-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do single_cycle_processor

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_data_path IS
    GENERIC (
        -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
        DP_CTRL_BUS_WIDTH : NATURAL := 14; -- tamanho do barramento de controle da via de dados (DP) em bits
        DATA_WIDTH : NATURAL := 32; -- tamanho do dado em bits
        PC_WIDTH : NATURAL := 32; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
        FR_ADDR_WIDTH : NATURAL := 5; -- tamanho da linha de endereços do banco de registradores em bits
        ULA_CTRL_WIDTH : NATURAL := 4; -- tamanho da linha de controle da ULA
        INSTR_WIDTH : NATURAL := 32; -- tamanho da instrução em bits
        MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
    );
    PORT (
        -- declare todas as portas da sua via_dados_ciclo_unico aqui.
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        controle : IN STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0);
        instrucao : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        -- We are the champions:
        zero : OUT STD_LOGIC;
        memd_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- mmed 'Read Data'
        memd_address : OUT STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0); -- address
        memd_write_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) -- The data to be written in memory
    );
END ENTITY single_cycle_data_path;

ARCHITECTURE comportamento OF single_cycle_data_path IS

    -- declare todos os componentes que serão necessários na sua single_cycle_data_path a partir deste comentário
    COMPONENT pc IS
        GENERIC (
            PC_WIDTH : NATURAL := 32
        );
        PORT (
            entrada : IN STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT somador IS
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
            clk : IN STD_LOGIC;
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

    COMPONENT hdl_register IS
        GENERIC (
            largura_dado : NATURAL := 32
        );
        PORT (
            entrada_dados : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            WE, clk, reset : IN STD_LOGIC;
            saida_dados : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
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
            input : IN STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR((data_width - 1) DOWNTO 0)
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
            clk, WE : IN STD_LOGIC
        );
    END COMPONENT;

    -- Declare todos os sinais auxiliares que serão necessários na sua single_cycle_data_path a partir deste comentário.
    -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
    -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
    -- componentes onde serão usados.
    -- Veja os exemplos abaixo:
    SIGNAL aux_read_rs : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_read_rt : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_write_rd : STD_LOGIC_VECTOR(fr_addr_width - 1 DOWNTO 0);
    SIGNAL aux_data_in : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
    SIGNAL aux_data_outrs : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
    SIGNAL aux_data_outrt : STD_LOGIC_VECTOR(data_width - 1 DOWNTO 0);
    SIGNAL aux_reg_write : STD_LOGIC;

    SIGNAL aux_ula_ctrl : STD_LOGIC_VECTOR(ula_ctrl_width - 1 DOWNTO 0);

    SIGNAL aux_pc_out : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_novo_pc : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- We are the champions:
    -- Our Pattern: aux_<src>_<dst>_<dst_port>
    -- ULA signals
    SIGNAL aux_zero : STD_LOGIC;

    -- mux_0 signals:
    SIGNAL aux_epc_m0_dado_ent_0 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m5_m0_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m0_m1_dado_sai : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m0_sele_ent : STD_LOGIC;

    -- mux_1 signals:
    SIGNAL aux_ia_m1_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m1_pc_entrada : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m1_sele_ent : STD_LOGIC;

    -- mux_2 signals:
    SIGNAL aux_m2_reg_ent_Rd_dado : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m2_sele_ent : STD_LOGIC;

    -- mux_3 signals:
    SIGNAL aux_ctrl_m3_sele_ent : STD_LOGIC;
    SIGNAL aux_m3_ula_entrada_b : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_reg_m3_mmed : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- mux_4 signals:
    SIGNAL aux_s0_m4_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_ctrl_m4_sele_ent : STD_LOGIC;

    -- mux_5 signals:
    SIGNAL aux_a1_m5_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- mux_6 signals:
    SIGNAL aux_ctrl_m6_sele_ent : STD_LOGIC;
    SIGNAL aux_mmed_m6_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_m6_m2_dado_ent_1 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_alu_m6_dado_ent_0 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);

    -- adder_0:
    SIGNAL aux_a0_m2_m5_pc4 : STD_LOGIC_VECTOR(PC_WIDTH - 1 DOWNTO 0);
    SIGNAL aux_plus_four : unsigned(PC_WIDTH - 1 DOWNTO 0) := x"00000004";

    -- adder_1:
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

    -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
    -- os sinais que você acabou de definir.
    -- Veja os exemplos abaixo:
    aux_reg_write <= controle(2); -- RegWrite
    aux_ula_ctrl <= controle(8 DOWNTO 5); -- AluOp
    -- aux_we <= controle(4); -- MemWrite
    saida <= aux_data_outrt;
    pc_out <= aux_pc_out;

    -- We are the champions:
    aux_ctrl_m0_sele_ent <= controle(1); -- PcSrc
    aux_ctrl_m1_sele_ent <= controle(0); -- ItController
    aux_branchNEQ <= controle(11); -- BranchNEQ
    aux_branchEQ <= controle(10); -- BranchEQ
    aux_ctrl_m6_sele_ent <= controle(9); -- MemToReg
    aux_mmed_m6_dado_ent_1 <= memd_data;
    aux_mmi_se_entrada_Rs <= instrucao(31 DOWNTO 20);
    aux_ctrl_m2_sele_ent <= controle(13); -- RegDst
    aux_ctrl_m3_sele_ent <= controle(3); -- AluSrc
    memd_write_data <= aux_reg_m3_mmed;
    aux_mmi_reg_ent_Rs_ende <= instrucao(19 DOWNTO 15);
    aux_mmi_reg_ent_Rt_ende <= instrucao(24 DOWNTO 20);
    aux_mmi_reg_ent_Rd_ende <= instrucao(11 DOWNTO 7);

    -- A partir deste comentário instancie todos o componentes que serão usados na sua single_cycle_data_path.
    -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
    -- que você atribuiu ao componente.
    -- Depois segue o port map do referido componente instanciado.
    -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
    -- ou ainda uma das saídas da entidade single_cycle_data_path.
    -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade single_cycle_data_path,
    -- Veja os exemplos de instanciação a seguir:

    instancia_ula1 : ula
    PORT MAP(
        entrada_a => aux_reg_alu_entrada_a,
        entrada_b => aux_m3_ula_entrada_b,
        seletor => aux_ula_ctrl,
        saida => aux_alu_m6_dado_ent_0,
        zero => aux_zero
    );

    instancia_banco_registradores : banco_registradores
    PORT MAP(
        ent_rs_ende => aux_mmi_reg_ent_Rs_ende,
        ent_rt_ende => aux_mmi_reg_ent_Rt_ende,
        ent_rd_ende => aux_mmi_reg_ent_Rd_ende,
        ent_rd_dado => aux_m2_reg_ent_Rd_dado,
        sai_rs_dado => aux_reg_alu_entrada_a,
        sai_rt_dado => aux_reg_m3_mmed,
        clk => clock,
        we => aux_reg_write
    );

    instancia_pc : pc
    PORT MAP(
        entrada => aux_m1_pc_entrada,
        saida => aux_pc_out,
        clk => clock,
        -- we => aux_we,
        reset => reset
    );

    instancia_somador0 : somador
    PORT MAP(
        entrada_a => aux_pc_out,
        entrada_b => STD_LOGIC_VECTOR(aux_plus_four),
        saida => aux_a0_m2_m5_pc4
    );

    instancia_somador1 : somador
    PORT MAP(
        entrada_a => aux_pc_out,
        entrada_b => aux_m4_a1_entrada_b,
        saida => aux_a1_m5_dado_ent_1
    );

    instancia_sign_extend : extensor
    PORT MAP(
        entrada_Rs => aux_mmi_se_entrada_Rs,
        saida => aux_se_m3_m4_shifter
    );

    -- instancia_epc : hdl_register
    --     port map(
    --         entrada_dados => aux_m0_m1_dado_sai,
    --         -- WE => std_logic_vector("0001"),
    --         clk => clock,
    --         -- reset => std_logic_vector("0001"),
    --         saida_dados => aux_epc_m0_dado_ent_0
    --     );

    instancia_mux_0 : mux21
    PORT MAP(
        dado_ent_0 => aux_epc_m0_dado_ent_0,
        dado_ent_1 => aux_m5_m0_dado_ent_1,
        sele_ent => aux_ctrl_m0_sele_ent,
        dado_sai => aux_m0_m1_dado_sai
    );

    instancia_mux_1 : mux21
    PORT MAP(
        dado_ent_0 => aux_m0_m1_dado_sai,
        dado_ent_1 => aux_ia_m1_dado_ent_1,
        sele_ent => aux_ctrl_m1_sele_ent,
        dado_sai => aux_m1_pc_entrada
    );

    instancia_mux_2 : mux21
    PORT MAP(
        dado_ent_0 => aux_a0_m2_m5_pc4,
        dado_ent_1 => aux_m6_m2_dado_ent_1,
        sele_ent => aux_ctrl_m2_sele_ent,
        dado_sai => aux_m2_reg_ent_Rd_dado
    );

    instancia_mux_3 : mux21
    PORT MAP(
        dado_ent_0 => aux_reg_m3_mmed,
        dado_ent_1 => aux_se_m3_m4_shifter,
        sele_ent => aux_ctrl_m3_sele_ent,
        dado_sai => aux_m3_ula_entrada_b
    );

    instancia_mux_4 : mux21
    PORT MAP(
        dado_ent_0 => aux_se_m3_m4_shifter,
        dado_ent_1 => aux_s0_m4_dado_ent_1,
        sele_ent => aux_ctrl_m4_sele_ent,
        dado_sai => aux_m4_a1_entrada_b
    );

    instancia_mux_5 : mux21
    PORT MAP(
        dado_ent_0 => aux_a0_m2_m5_pc4,
        dado_ent_1 => aux_a1_m5_dado_ent_1,
        sele_ent => aux_m5_sele_ent,
        dado_sai => aux_m5_m0_dado_ent_1
    );

    instancia_mux_6 : mux21
    PORT MAP(
        dado_ent_0 => aux_alu_m6_dado_ent_0,
        dado_ent_1 => aux_mmed_m6_dado_ent_1,
        sele_ent => aux_ctrl_m6_sele_ent,
        dado_sai => aux_m6_m2_dado_ent_1
    );

    -- instancia_interrupt_address_registers : interrupt_address_registers
    --     port map(
    --         output => aux_ia_m1_dado_ent_1,
    --         -- ent_rs_ende => aux_read_rs,
    --         -- ent_rt_ende => aux_read_rt,
    --         -- ent_rd_ende => aux_write_rd,
    --         -- ent_rd_dado => aux_data_in,
    --         -- sai_rs_dado => aux_data_outrs,
    --         -- sai_rt_dado => aux_data_outrt,
    --         clk => clock,
    --         -- we => aux_reg_write
    --     );

    instancia_shifter : two_bits_shifter
    PORT MAP(
        input => aux_se_m3_m4_shifter,
        output => aux_s0_m4_dado_ent_1
    );

    PROCESS (aux_zero, aux_branchNEQ, aux_branchEQ) IS
    BEGIN
        aux_m5_sele_ent <= (aux_branchNEQ AND (NOT(aux_zero))) OR (aux_branchNEQ AND aux_zero);
    END PROCESS;
END ARCHITECTURE comportamento;