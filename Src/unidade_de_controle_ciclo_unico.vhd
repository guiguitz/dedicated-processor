-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade de controle ciclo único (look-up table) do processador
-- puramente combinacional
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- unidade de controle
ENTITY unidade_de_controle_ciclo_unico IS
    GENERIC (
        INSTR_WIDTH : NATURAL := 32;
        OPCODE_WIDTH : NATURAL := 7;
        DP_CTRL_BUS_WIDTH : NATURAL := 14;
        ULA_CTRL_WIDTH : NATURAL := 4
    );
    PORT (
        instrucao : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0); -- instrução
        controle : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0) -- controle da via
    );
END unidade_de_controle_ciclo_unico;

ARCHITECTURE beh OF unidade_de_controle_ciclo_unico IS
    -- As linhas abaixo não produzem erro de compilação no Quartus II, mas no Modelsim (GHDL) produzem.
    --signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);            -- instrucao
    --signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);           -- opcode
    --signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);      -- controle

    SIGNAL inst_aux : STD_LOGIC_VECTOR (31 DOWNTO 0); -- instrucao
    SIGNAL opcode : STD_LOGIC_VECTOR (6 DOWNTO 0); -- opcode
    SIGNAL funct3 : STD_LOGIC_VECTOR (2 DOWNTO 0); -- funct3
    SIGNAL ctrl_aux : STD_LOGIC_VECTOR (13 DOWNTO 0); -- controle
    -- RegDst | Jump | Branch NEQ | Branch EQ | MemToReg | AluOp (4) | MemWrite | AluSrc | RegWrite | PcSrc | ITController

BEGIN
    inst_aux <= instrucao;
    -- A linha abaixo não produz erro de compilação no Quartus II, mas no Modelsim (GHDL) produz.
    --    opcode <= inst_aux (INSTR_WIDTH-1 downto INSTR_WIDTH-OPCODE_WIDTH);
    opcode <= inst_aux (6 DOWNTO 0); -- opcode
    funct3 <= inst_aux (14 DOWNTO 12); -- funct3

    PROCESS (opcode, funct3)
    BEGIN
        CASE opcode IS
            WHEN "0110011" => -- Rtype
                CASE funct3 IS
                        -- ADD
                    WHEN "000" =>
                        ctrl_aux <= "10000000100110";
                        -- SUB
                    WHEN "001" =>
                        ctrl_aux <= "10000001000110";
                        -- SLL
                    WHEN "010" =>
                        ctrl_aux <= "10000010000110";
                        -- SRL
                    WHEN "011" =>
                        ctrl_aux <= "10000010100110";
                        -- SLT
                    WHEN "100" =>
                        ctrl_aux <= "10000110000110";
                    WHEN OTHERS =>
                        ctrl_aux <= "10000000000010"; -- nop
                END CASE; -- funct3
                -- Rtype

            WHEN "0010011" => -- ADDI, SLTI, NOP
                CASE funct3 IS
                        -- ADDI
                    WHEN "000" =>
                        ctrl_aux <= "10000001101110";
                        -- SLTI
                    WHEN "001" =>
                        ctrl_aux <= "10000110101110";
                        -- NOP
                    WHEN "010" =>
                        ctrl_aux <= "10000000000010";
                    WHEN OTHERS =>
                        ctrl_aux <= "10000000000010"; -- nop
                END CASE; -- funct3
                -- ADDI, SLTI, NOP

            WHEN "0000011" => -- LW, LB
                CASE funct3 IS
                        -- LB
                    WHEN "000" =>
                        ctrl_aux <= "10001100001110";
                        -- LW
                    WHEN "010" =>
                        ctrl_aux <= "10001011001110";
                    WHEN OTHERS =>
                        ctrl_aux <= "10000000000010"; -- nop
                END CASE; -- funct3
                -- LW, LB

            WHEN "0100011" => -- SW, SB, BEQ, BNE
                CASE funct3 IS
                        -- SB
                    WHEN "000" =>
                        ctrl_aux <= "10000100111010";
                        -- BNE
                    WHEN "001" =>
                        ctrl_aux <= "10100101100010";
                        -- SW
                    WHEN "010" =>
                        ctrl_aux <= "10000011111010";
                        -- BEQ
                    WHEN "011" =>
                        ctrl_aux <= "10010101000010";
                    WHEN OTHERS =>
                        ctrl_aux <= "10000000000010"; -- nop
                END CASE; -- funct3
                -- SW, SB, BEQ, BNE

            WHEN "0000010" => -- J
                -- J
                ctrl_aux <= "11110000000010";
                -- J

            WHEN "1101111" => -- JAL
                -- JAL
                ctrl_aux <= "00110000000110";
                -- JAL

            WHEN "1100111" => -- JARL
                -- JARL
                ctrl_aux <= "00110000001110";
                -- JARL

            WHEN "1110011" => -- ECALL
                -- ECALL
                ctrl_aux <= "00000000000001";
                -- ECALL

                -- None, nop
            WHEN OTHERS =>
                ctrl_aux <= "10000000000010"; -- nop
                -- None, nop

        END CASE; -- opcode

    END PROCESS;
    controle <= ctrl_aux;
END beh;