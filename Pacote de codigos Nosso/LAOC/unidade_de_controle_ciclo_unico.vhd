-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade de controle ciclo único (look-up table) do processador
-- puramente combinacional
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- unidade de controle
entity unidade_de_controle_ciclo_unico is
    generic (
        INSTR_WIDTH       : natural := 32;
        OPCODE_WIDTH      : natural := 7;
        DP_CTRL_BUS_WIDTH : natural := 14;
        ULA_CTRL_WIDTH    : natural := 4
    );
    port (
        instrucao : in std_logic_vector(INSTR_WIDTH - 1 downto 0);       -- instrução
        controle  : out std_logic_vector(DP_CTRL_BUS_WIDTH - 1 downto 0) -- controle da via
    );
end unidade_de_controle_ciclo_unico;

architecture beh of unidade_de_controle_ciclo_unico is
    -- As linhas abaixo não produzem erro de compilação no Quartus II, mas no Modelsim (GHDL) produzem.
    --signal inst_aux : std_logic_vector (INSTR_WIDTH-1 downto 0);            -- instrucao
    --signal opcode   : std_logic_vector (OPCODE_WIDTH-1 downto 0);           -- opcode
    --signal ctrl_aux : std_logic_vector (DP_CTRL_BUS_WIDTH-1 downto 0);      -- controle

    signal inst_aux : std_logic_vector (31 downto 0); -- instrucao
    signal opcode   : std_logic_vector (6 downto 0);  -- opcode
    signal funct3   : std_logic_vector (2 downto 0);  -- funct3
    signal ctrl_aux : std_logic_vector (13 downto 0);  -- controle
        -- RegDst | Jump | Branch NEQ | Branch EQ | MemToReg | AluOp (4) | MemWrite | AluSrc | RegWrite | PcSrc | ITController

begin
    inst_aux <= instrucao;
    -- A linha abaixo não produz erro de compilação no Quartus II, mas no Modelsim (GHDL) produz.
    --    opcode <= inst_aux (INSTR_WIDTH-1 downto INSTR_WIDTH-OPCODE_WIDTH);
    opcode <= inst_aux (6 downto 0); -- opcode
    funct3 <= inst_aux (14 downto 12); -- funct3

    process (opcode, funct3)
    begin
        case opcode is
            when "0110011" => -- Rtype
                case funct3 is
                    -- ADD
                    when "000" =>
                        ctrl_aux <= "10000000100110";
                    -- SUB
                    when "001" =>
                        ctrl_aux <= "10000001000110";
                    -- SLL
                    when "010" =>
                        ctrl_aux <= "10000010000110";
                    -- SRL
                    when "011" =>
                        ctrl_aux <= "10000010100110";
                    -- SLT
                    when "100" =>
                        ctrl_aux <= "10000110000110";
                    when others =>
                        ctrl_aux <= "10000000000010"; -- nop
                end case; -- funct3
            -- Rtype

            when "0110011" => -- ADDI, SLTI, NOP
                case funct3 is
                    -- ADDI
                    when "000" =>
                        ctrl_aux <= "10000001101110";
                    -- SLTI
                    when "001" =>
                        ctrl_aux <= "10000110101110";
                    -- NOP
                    when "010" =>
                        ctrl_aux <= "10000000000010";
                    when others =>
                        ctrl_aux <= "10000000000010";
                end case; -- funct3
            -- ADDI, SLTI, NOP

            when "0000011" => -- LW, LB
                case funct3 is
                    -- LB
                    when "000" =>
                        ctrl_aux <= "10001100001110";
                    -- LW
                    when "010" =>
                        ctrl_aux <= "10001011001110";
                    when others =>
                        ctrl_aux <= "10000000000010"; -- nop
                end case; -- funct3
            -- LW, LB

            when "0100011" => -- SW, SB, BEQ, BNE
                case funct3 is
                    -- SB
                    when "000" =>
                        ctrl_aux <= "10000100111010";
                    -- BNE
                    when "001" =>
                        ctrl_aux <= "10100101100010";
                    -- SW
                    when "010" =>
                        ctrl_aux <= "10000011111010";
                    -- BEQ
                    when "011" =>
                        ctrl_aux <= "10010101000010";
                    when others =>
                        ctrl_aux <= "10000000000010"; -- nop
                end case; -- funct3
            -- SW, SB, BEQ, BNE

            when "0000010" => -- J
                -- J
                ctrl_aux <= "11110000000010";
            -- J

            when "1101111" => -- JAL
                -- JAL
                ctrl_aux <= "00110000000110";
            -- JAL

            when "1100111" => -- JARL
                -- JARL
                ctrl_aux <= "00110000001110";
            -- JARL

            when "1110011" => -- ECALL
                -- ECALL
                ctrl_aux <= "00000000000001";
            -- ECALL

            -- None, nop
            when others =>
                ctrl_aux <= "10000000000010"; -- nop
            -- None, nop

        end case; -- opcode

    end process;
    controle <= ctrl_aux;
end beh;
