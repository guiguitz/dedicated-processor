-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Guilherme Gomes, Felipe Freitas, Melissa Monni
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE interface_p IS
    TYPE interface_t IS ARRAY (0 TO 6) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
END PACKAGE interface_p;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.interface_p.ALL;

ENTITY mini_risc IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC
    );
END mini_risc;

ARCHITECTURE arch OF mini_risc IS

    -- control signals (will be ports of the control unit)
    SIGNAL RegWrite, ALUSrc, MemWrite, MemRead, MemToReg : STD_LOGIC;
    SIGNAL AluOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL PCSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL BrokenImm : STD_LOGIC;

    -- interruption signals (will be ports of the int. controller)
    SIGNAL IntCtrl : STD_LOGIC;
    SIGNAL IntAddr : STD_LOGIC_VECTOR(11 DOWNTO 0);

    -- miscellaneous relevant signals
    SIGNAL PC, PC4, NextPC, ProbablePC, EPC, BranchAddr, BranchIncr : STD_LOGIC_VECTOR (11 DOWNTO 0);

    SIGNAL Control : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL BranchImm, PreImm : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL Imm : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL R1_data, R2_data, MemOut, WriteBack : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_A, ALU_B, AluResult : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- output interface
    SIGNAL mem_interface : interface_t;
    TYPE display_t IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL display : display_t;

    COMPONENT mux21 IS
        GENERIC (
            largura_dado : NATURAL
        );
        PORT (
            dado_ent_0, dado_ent_1 : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sele_ent : IN STD_LOGIC;
            dado_sai : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT mux41 IS
        GENERIC (
            largura_dado : NATURAL := 12
        );
        PORT (
            dado_ent_0, dado_ent_1, dado_ent_2, dado_ent_3 : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sele_ent : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            dado_sai : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT hdl_register IS
        GENERIC (
            largura_dado : NATURAL := 12
        );
        PORT (
            entrada_dados : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            WE, clk, reset : IN STD_LOGIC;
            saida_dados : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT somador IS
        GENERIC (
            largura_dado : NATURAL := 12
        );

        PORT (
            entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT memi IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32; -- tamanho da instrucaoo em numero de bits
            MI_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de instrucoes em numero de bits
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            Endereco : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
            Instrucao : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT banco_registradores IS
        GENERIC (
            largura_dado : NATURAL := 32;
            largura_ende : NATURAL := 6
        );

        PORT (
            ent_R1_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_R2_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_Rd_ende : IN STD_LOGIC_VECTOR((largura_ende - 1) DOWNTO 0);
            ent_Rd_dado : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sai_R1_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            sai_R2_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            clk, WE : IN STD_LOGIC
        );
    END COMPONENT;
    COMPONENT deslocador IS
        GENERIC (
            largura_dado : NATURAL := 12;
            largura_qtde : NATURAL := 2
        );

        PORT (
            ent_rs_dado : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            ent_rt_ende : IN STD_LOGIC_VECTOR((largura_qtde - 1) DOWNTO 0); -- o campo de endereços de rt, representa a quantidade a ser deslocada nesse contexto.
            ent_tipo_deslocamento : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            sai_rd_dado : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
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
    COMPONENT ula IS
        GENERIC (
            largura_dado : NATURAL := 32
        );

        PORT (
            entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
            seletor : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT memd IS
        GENERIC (
            number_of_words : NATURAL := 736; -- número de words que a sua memória é capaz de armazenar
            MD_DATA_WIDTH : NATURAL := 32; -- tamanho da palavra em bits
            MD_ADDR_WIDTH : NATURAL := 12 -- tamanho do endereco da memoria de dados em bits
        );
        PORT (
            clk : IN STD_LOGIC;
            mem_write, mem_read : IN STD_LOGIC; --sinais do controlador
            write_data_mem : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            adress_mem : IN STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
            read_data_mem : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
            interface : OUT interface_t
        );
    END COMPONENT;

    -- unidade de controle
    COMPONENT single_cycle_control_unit IS
        GENERIC (
            INSTR_WIDTH : NATURAL := 32;
            OPCODE_WIDTH : NATURAL := 4;
            DP_CTRL_BUS_WIDTH : NATURAL := 11;
            ULA_CTRL_WIDTH : NATURAL := 4
        );
        PORT (
            instrucao : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0); -- instrução
            controle : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0) -- controle da via
        );
    END COMPONENT;

    COMPONENT seven_seg_decoder IS
        PORT (
            input : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            output : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    u_controler : single_cycle_control_unit PORT MAP(Inst, Control);

    BrokenImm <= Control (10);
    PCSrc <= Control (9 DOWNTO 8);
    RegWrite <= Control (7);
    ALUSrc <= Control (6);
    MemWrite <= Control (5);
    MemToReg <= Control (4);
    AluOp <= Control (3 DOWNTO 0);
    BranchImm <= Inst(31 DOWNTO 26) & Inst(13 DOWNTO 8);
    IntCtrl <= '0';

    PROCESS (BrokenImm, PreImm, Inst)
    BEGIN
        CASE BrokenImm IS
            WHEN '1' => PreImm <= Inst(31 DOWNTO 26) & Inst(13 DOWNTO 8);
            WHEN OTHERS => PreImm <= Inst(19 DOWNTO 8);
        END CASE;
    END PROCESS;

    display_1 <= display(0);
    display_2 <= display(1);
    display_3 <= display(2);
    display_4 <= display(3);
    display_5 <= display(4);
    display_6 <= display(5);

    u_mux_pc_1 : mux41 PORT MAP(PC4, BranchAddr, AluResult(11 DOWNTO 0), EPC, PCSrc, ProbablePC);
    u_mux_pc_2 : mux21 GENERIC MAP(largura_dado => 12) PORT MAP(ProbablePC, IntAddr, IntCtrl, NextPC);
    u_pc : hdl_register PORT MAP(NextPC, '1', clk, rst, PC);
    u_epc : hdl_register PORT MAP(ProbablePC, '1', clk, rst, EPC);
    u_pc4 : somador PORT MAP(PC, X"004", PC4);
    u_memi : memi PORT MAP(clk, rst, PC, Inst);
    u_reg_bank : banco_registradores PORT MAP(Inst(25 DOWNTO 20), Inst(19 DOWNTO 14), Inst(31 DOWNTO 26), WriteBack, R1_data, R2_data, clk, RegWrite);
    u_shift : deslocador PORT MAP(BranchImm, "00", "01", BranchIncr);
    u_branch_add : somador PORT MAP(PC, BranchIncr, BranchAddr);
    u_imm_gen : extensor PORT MAP(PreImm, Imm);
    u_mux_alu : mux21 GENERIC MAP(largura_dado => 32) PORT MAP(R2_data, Imm, AluSrc, ALU_B);

    ALU_A <= R1_data;
    u_alu : ula PORT MAP(ALU_A, ALU_B, AluOp, AluResult);
    u_mem : memd PORT MAP(clk, MemWrite, '1', R2_data, AluResult(11 DOWNTO 0), MemOut, mem_interface);
    u_mux_wb : mux21 GENERIC MAP(largura_dado => 32) PORT MAP(MemOut, AluResult, MemToReg, WriteBack);

    leds <= mem_interface(0)(9 DOWNTO 0);
    gen_display :
    FOR i IN 0 TO 5 GENERATE
        u_seven_seg : seven_seg_decoder PORT MAP(mem_interface(i + 1)(3 DOWNTO 0), display(i));
    END GENERATE gen_display;

END arch;
