-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Via de dados do processador_ciclo_unico

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity via_de_dados_ciclo_unico is
    generic (
        -- declare todos os tamanhos dos barramentos (sinais) das portas da sua via_dados_ciclo_unico aqui.
        dp_ctrl_bus_width : natural; -- tamanho do barramento de controle da via de dados (DP) em bits
        data_width        : natural; -- tamanho do dado em bits
        pc_width          : natural; -- tamanho da entrada de endereços da MI ou MP em bits (memi.vhd)
        fr_addr_width     : natural; -- tamanho da linha de endereços do banco de registradores em bits
        ula_ctrl_width    : natural; -- tamanho da linha de controle da ULA
        instr_width       : natural;  -- tamanho da instrução em bits
        MD_ADDR_WIDTH   : natural  -- tamanho do endereco da memoria de dados em bits
    );
    port (
        -- declare todas as portas da sua via_dados_ciclo_unico aqui.
        clock     : in std_logic;
        reset     : in std_logic;
        controle  : in std_logic_vector(dp_ctrl_bus_width - 1 downto 0);
        instrucao : in std_logic_vector(instr_width - 1 downto 0);
        pc_out    : out std_logic_vector(pc_width - 1 downto 0);
        saida     : out std_logic_vector(data_width - 1 downto 0);
        -- We are the champions:
        zero      : out std_logic;
        memd_data : in std_logic_vector(data_width - 1 downto 0);
        memd_address : out std_logic_vector(MD_ADDR_WIDTH - 1 downto 0);
        memd_write_data : out std_logic_vector(data_width - 1 downto 0)
    );
end entity via_de_dados_ciclo_unico;

architecture comportamento of via_de_dados_ciclo_unico is

    -- declare todos os componentes que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário
    component pc is
        generic (
            pc_width : natural := 32
        );
        port (
            entrada : in std_logic_vector(pc_width - 1 downto 0);
            saida   : out std_logic_vector(pc_width - 1 downto 0);
            clk     : in std_logic;
            we      : in std_logic;
            reset   : in std_logic
        );
    end component;

    component somador is
        generic (
            largura_dado : natural := 32
        );
        port (
            entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
            entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
            saida     : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component banco_registradores is
        generic (
            largura_dado : natural := 32;
            largura_ende : natural := 5
        );
        port (
            ent_rs_ende : in std_logic_vector((largura_ende - 1) downto 0);
            ent_rt_ende : in std_logic_vector((largura_ende - 1) downto 0);
            ent_rd_ende : in std_logic_vector((largura_ende - 1) downto 0);
            ent_rd_dado : in std_logic_vector((largura_dado - 1) downto 0);
            sai_rs_dado : out std_logic_vector((largura_dado - 1) downto 0);
            sai_rt_dado : out std_logic_vector((largura_dado - 1) downto 0);
            clk         : in std_logic;
            we          : in std_logic
        );
    end component;

    component ula is
        generic (
            largura_dado : natural := 32
        );
        port (
            entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
            entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
            seletor   : in std_logic_vector(3 downto 0);
            saida     : out std_logic_vector((largura_dado - 1) downto 0);
            zero      : out std_logic
        );
    end component;

    component mux21 is
        generic (
            largura_dado : natural := 32
        );
        port (
            dado_ent_0, dado_ent_1 : in std_logic_vector((largura_dado - 1) downto 0);
            sele_ent               : in std_logic;
            dado_sai               : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component registrador is
        generic (
            largura_dado : natural := 32
        );
        port (
            entrada_dados  : in std_logic_vector((largura_dado - 1) downto 0);
            WE, clk, reset : in std_logic;
            saida_dados    : out std_logic_vector((largura_dado - 1) downto 0)
        );
    end component;

    component extensor is
        generic (
            largura_dado  : natural := 12;
            largura_saida : natural := 32
        );

        port (
            entrada_Rs : in std_logic_vector((largura_dado - 1) downto 0);
            saida      : out std_logic_vector((largura_saida - 1) downto 0)
        );
    end component;

    component two_bits_shifter is
        generic (
            data_width : natural := 32
        );

        port (
            input           : in std_logic_vector((data_width - 1) downto 0);
            output          : out std_logic_vector((data_width - 1) downto 0)
        );
    end component;

    component interrupt_address_registers is
        generic (
            largura_dado : natural := 32;
            largura_ende : natural := 5
        );

        port (
            address : in std_logic_vector((largura_ende - 1) downto 0);
            input : in std_logic_vector((largura_dado - 1) downto 0);
            output : out std_logic_vector((largura_dado - 1) downto 0);
            clk, WE     : in std_logic
        );
    end component;



    -- Declare todos os sinais auxiliares que serão necessários na sua via_de_dados_ciclo_unico a partir deste comentário.
    -- Você só deve declarar sinais auxiliares se estes forem usados como "fios" para interligar componentes.
    -- Os sinais auxiliares devem ser compatíveis com o mesmo tipo (std_logic, std_logic_vector, etc.) e o mesmo tamanho dos sinais dos portos dos
    -- componentes onde serão usados.
    -- Veja os exemplos abaixo:
    signal aux_read_rs    : std_logic_vector(fr_addr_width - 1 downto 0);
    signal aux_read_rt    : std_logic_vector(fr_addr_width - 1 downto 0);
    signal aux_write_rd   : std_logic_vector(fr_addr_width - 1 downto 0);
    signal aux_data_in    : std_logic_vector(data_width - 1 downto 0);
    signal aux_data_outrs : std_logic_vector(data_width - 1 downto 0);
    signal aux_data_outrt : std_logic_vector(data_width - 1 downto 0);
    signal aux_reg_write  : std_logic;

    signal aux_ula_ctrl : std_logic_vector(ula_ctrl_width - 1 downto 0);

    signal aux_pc_out  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_novo_pc : std_logic_vector(pc_width - 1 downto 0);
    signal aux_we      : std_logic;

    -- We are the champions:
    -- Our Pattern: aux_<src>_<dst>_<dst_port>
    -- ALU signals
    signal aux_zero    : std_logic;

    -- mux_0 signals:
    signal aux_epc_m0_dado_ent_0  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_m5_m0_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_m0_m1_dado_sai  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_ctrl_m0_sele_ent  : std_logic;

    -- mux_1 signals:
    signal aux_ia_m1_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_m1_pc_entrada  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_ctrl_m1_sele_ent  : std_logic;

    -- mux_2 signals:
    signal aux_m2_reg_ent_Rd_dado  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_ctrl_m2_sele_ent  : std_logic;

    -- mux_3 signals:
    signal aux_ctrl_m3_sele_ent  : std_logic;
    signal aux_m3_ula_entrada_b  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_reg_m3_mmed  : std_logic_vector(pc_width - 1 downto 0);

    -- mux_4 signals:
    signal aux_s0_m4_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_ctrl_m4_sele_ent  : std_logic;

    -- mux_5 signals:
    signal aux_a1_m5_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);

    -- mux_6 signals:
    signal aux_ctrl_m6_sele_ent  : std_logic;
    signal aux_mmed_m6_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_m6_m2_dado_ent_1  : std_logic_vector(pc_width - 1 downto 0);
    signal aux_alu_m6_dado_ent_0  : std_logic_vector(pc_width - 1 downto 0);

    -- adder_0:
    signal aux_a0_m2_m5_pc4 : std_logic_vector(pc_width - 1 downto 0);
    signal aux_plus_four : unsigned(pc_width - 1 downto 0) := x"00000004";

    -- adder_1:
    signal aux_m4_a1_entrada_b : std_logic_vector(pc_width - 1 downto 0);

    -- process branch (BEQ, BNE)
    signal aux_branchNEQ : std_logic;
    signal aux_branchEQ : std_logic;
    signal aux_m5_sele_ent : std_logic;

    -- Sign Extend
    signal aux_mmi_se_entrada_Rs    : std_logic_vector(12 - 1 downto 0);
    signal aux_se_m3_m4_shifter    : std_logic_vector(pc_width - 1 downto 0);

    -- Alu
    signal aux_reg_alu_entrada_a    : std_logic_vector(pc_width - 1 downto 0);

    -- Reg
    signal aux_mmi_reg_ent_Rs_ende : std_logic_vector(19 downto 15);
    signal aux_mmi_reg_ent_Rt_ende : std_logic_vector(24 downto 20);
    signal aux_mmi_reg_ent_Rd_ende : std_logic_vector(11 downto 7);



begin

    -- A partir deste comentário faça associações necessárias das entradas declaradas na entidade da sua via_dados_ciclo_unico com
    -- os sinais que você acabou de definir.
    -- Veja os exemplos abaixo:
    aux_reg_write <= controle(2); -- RegWrite
    aux_ula_ctrl  <= controle(8 downto 5); -- AluOp
    aux_we        <= controle(4); -- MemWrite
    saida         <= aux_data_outrt;
    pc_out        <= aux_pc_out;

    -- We are the champions:
    aux_ctrl_m0_sele_ent   <= controle(1); -- PcSrc
    aux_ctrl_m1_sele_ent   <= controle(0); -- ItController
    aux_branchNEQ <= controle(11); -- BranchNEQ
    aux_branchEQ <= controle(10); -- BranchEQ
    aux_ctrl_m6_sele_ent <= controle(9); -- MemToReg
    aux_mmed_m6_dado_ent_1 <= memd_data;
    aux_mmi_se_entrada_Rs <= instrucao(31 downto 20);
    aux_ctrl_m2_sele_ent <= controle(13); -- RegDst
    aux_ctrl_m3_sele_ent <= controle(3); -- AluSrc
    memd_write_data <= aux_reg_m3_mmed;
    aux_mmi_reg_ent_Rs_ende   <= instrucao(19 downto 15);
    aux_mmi_reg_ent_Rt_ende   <= instrucao(24 downto 20);
    aux_mmi_reg_ent_Rd_ende  <= instrucao(11 downto 7);

    -- A partir deste comentário instancie todos o componentes que serão usados na sua via_de_dados_ciclo_unico.
    -- A instanciação do componente deve começar com um nome que você deve atribuir para a referida instancia seguido de : e seguido do nome
    -- que você atribuiu ao componente.
    -- Depois segue o port map do referido componente instanciado.
    -- Para fazer o port map, na parte da esquerda da atribuição "=>" deverá vir o nome de origem da porta do componente e na parte direita da
    -- ou ainda uma das saídas da entidade via_de_dados_ciclo_unico.
    -- atribuição deve aparecer um dos sinais ("fios") que você definiu anteriormente, ou uma das entradas da entidade via_de_dados_ciclo_unico,
    -- Veja os exemplos de instanciação a seguir:

    instancia_ula1 : component ula
          port map(
            entrada_a => aux_reg_alu_entrada_a,
            entrada_b => aux_m3_ula_entrada_b,
            seletor => aux_ula_ctrl,
            saida => aux_alu_m6_dado_ent_0,
            zero => aux_zero
         );

    instancia_banco_registradores : component banco_registradores
        port map(
            ent_rs_ende => aux_mmi_reg_ent_Rs_ende,
            ent_rt_ende => aux_mmi_reg_ent_Rt_ende,
            ent_rd_ende => aux_mmi_reg_ent_Rd_ende,
            ent_rd_dado => aux_m2_reg_ent_Rd_dado,
            sai_rs_dado => aux_reg_alu_entrada_a,
            sai_rt_dado => aux_reg_m3_mmed,
            clk => clock,
            we => aux_reg_write
        );

    instancia_pc : component pc
        port map(
            entrada => aux_m1_pc_entrada,
            saida => aux_pc_out,
            clk => clock,
            we => aux_we,
            reset => reset
          );

    instancia_somador0 : component somador
        port map(
            entrada_a => aux_pc_out,
            entrada_b => std_logic_vector(aux_plus_four),
            saida => aux_a0_m2_m5_pc4
        );

    instancia_somador1 : component somador
        port map(
            entrada_a => aux_pc_out,
            entrada_b => aux_m4_a1_entrada_b,
            saida => aux_a1_m5_dado_ent_1
        );

    instancia_sign_extend : component extensor
        port map(
            entrada_Rs => aux_mmi_se_entrada_Rs,
            saida => aux_se_m3_m4_shifter
        );

    -- instancia_epc : component registrador
    --     port map(
    --         entrada_dados => aux_m0_m1_dado_sai,
    --         -- WE => std_logic_vector("0001"),
    --         clk => clock,
    --         -- reset => std_logic_vector("0001"),
    --         saida_dados => aux_epc_m0_dado_ent_0
    --     );

    instancia_mux_0 : component mux21
        port map(
            dado_ent_0 => aux_epc_m0_dado_ent_0,
            dado_ent_1 => aux_m5_m0_dado_ent_1,
            sele_ent => aux_ctrl_m0_sele_ent,
            dado_sai => aux_m0_m1_dado_sai
        );

    instancia_mux_1 : component mux21
        port map(
            dado_ent_0 => aux_m0_m1_dado_sai,
            dado_ent_1 => aux_ia_m1_dado_ent_1,
            sele_ent => aux_ctrl_m1_sele_ent,
            dado_sai => aux_m1_pc_entrada
        );

    instancia_mux_2 : component mux21
        port map(
            dado_ent_0 => aux_a0_m2_m5_pc4,
            dado_ent_1 => aux_m6_m2_dado_ent_1,
            sele_ent => aux_ctrl_m2_sele_ent,
            dado_sai => aux_m2_reg_ent_Rd_dado
        );

    instancia_mux_3 : component mux21
        port map(
            dado_ent_0 => aux_reg_m3_mmed,
            dado_ent_1 => aux_se_m3_m4_shifter,
            sele_ent => aux_ctrl_m3_sele_ent,
            dado_sai => aux_m3_ula_entrada_b
        );

    instancia_mux_4 : component mux21
        port map(
            dado_ent_0 => aux_se_m3_m4_shifter,
            dado_ent_1 => aux_s0_m4_dado_ent_1,
            sele_ent => aux_ctrl_m4_sele_ent,
            dado_sai => aux_m4_a1_entrada_b
        );

    instancia_mux_5 : component mux21
        port map(
            dado_ent_0 => aux_a0_m2_m5_pc4,
            dado_ent_1 => aux_a1_m5_dado_ent_1,
            sele_ent => aux_m5_sele_ent,
            dado_sai => aux_m5_m0_dado_ent_1
        );

    instancia_mux_6 : component mux21
        port map(
            dado_ent_0 => aux_alu_m6_dado_ent_0,
            dado_ent_1 => aux_mmed_m6_dado_ent_1,
            sele_ent => aux_ctrl_m6_sele_ent,
            dado_sai => aux_m6_m2_dado_ent_1
        );

    -- instancia_interrupt_address_registers : component interrupt_address_registers
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

    instancia_shifter : component two_bits_shifter
        port map(
            input => aux_se_m3_m4_shifter,
            output => aux_s0_m4_dado_ent_1
        );

    process (aux_zero, aux_branchNEQ, aux_branchEQ) is
    begin
        aux_m5_sele_ent <= (aux_branchNEQ and (not(aux_zero))) or (aux_branchNEQ and aux_zero);
    end process;
end architecture comportamento;
