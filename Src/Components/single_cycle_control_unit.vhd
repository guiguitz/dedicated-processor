LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_control_unit IS
    GENERIC (
        INSTR_WIDTH : NATURAL := 32;
        OPCODE_WIDTH : NATURAL := 7;
        DP_CTRL_BUS_WIDTH : NATURAL := 14;
        ALU_CTRL_WIDTH : NATURAL := 4
    );
    PORT (
        instruction : IN STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
        control : OUT STD_LOGIC_VECTOR(DP_CTRL_BUS_WIDTH - 1 DOWNTO 0)
    );
END single_cycle_control_unit;

ARCHITECTURE beh OF single_cycle_control_unit IS

    SIGNAL aux_instruction : STD_LOGIC_VECTOR (31 DOWNTO 0); -- instruction
    SIGNAL aux_opcode : STD_LOGIC_VECTOR (6 DOWNTO 0); -- opcode
    SIGNAL aux_funct3 : STD_LOGIC_VECTOR (2 DOWNTO 0); -- funct3

    SIGNAL aux_control : STD_LOGIC_VECTOR (13 DOWNTO 0); -- control
    -- RegDst & Jump & Branch NEQ & Branch EQ & MemToReg & AluOp(3) & AluOp(2) & AluOp(1) & AluOp(0) & MemWrite & AluSrc & RegWrite & PcSrc & ITController

BEGIN
    aux_instruction <= instruction;
    aux_opcode <= aux_instruction (6 DOWNTO 0);
    aux_funct3 <= aux_instruction (14 DOWNTO 12);

    PROCESS (aux_opcode, aux_funct3)
    BEGIN
        CASE aux_opcode IS
            WHEN "0110011" => -- Rtype
                CASE aux_funct3 IS -- ADD
                    WHEN "000" =>
                        aux_control <= "10000000100110"; -- X'2026
                    WHEN "001" => -- SUB
                        aux_control <= "10000001000110";
                    WHEN "010" => -- SLL
                        aux_control <= "10000010000110"; -- X'2086
                    WHEN "011" => -- SRL
                        aux_control <= "10000010100110";
                    WHEN "100" => -- SLT
                        aux_control <= "10000110000110";
                    WHEN OTHERS => -- NOP
                        aux_control <= "10000000000010";
                END CASE; -- aux_funct3

            WHEN "0010011" => -- ADDI, SLTI, NOP
                CASE aux_funct3 IS
                    WHEN "000" => -- ADDI
                        aux_control <= "10000001101110"; -- X'206E
                    WHEN "001" => -- SLTI
                        aux_control <= "10000110101110";
                    WHEN "010" => -- NOP
                        aux_control <= "10000000000010"; -- X'2002
                    WHEN OTHERS => -- NOP
                        aux_control <= "10000000000010";
                END CASE; -- aux_funct3

            WHEN "0000011" => -- LW, LB
                CASE aux_funct3 IS
                    WHEN "000" => -- LB
                        aux_control <= "10001100001110";
                    WHEN "010" => -- LW
                        aux_control <= "10001011001110"; -- X'22CE
                    WHEN OTHERS => -- NOP
                        aux_control <= "10000000000010";
                END CASE; -- aux_funct3

            WHEN "0100011" => -- SW, SB, BEQ, BNE
                CASE aux_funct3 IS
                    WHEN "000" => -- SB
                        aux_control <= "10000100111010";
                    WHEN "001" => -- BNE
                        aux_control <= "10100101100010"; -- X'2962
                    WHEN "010" => -- SW
                        aux_control <= "10000011111010"; -- X'20FA
                    WHEN "011" => -- BEQ
                        aux_control <= "10010101000010"; -- X'2542
                    WHEN OTHERS => -- NOP
                        aux_control <= "10000000000010";
                END CASE; -- aux_funct3

            WHEN "0000010" => -- J
                aux_control <= "11110000000010"; -- X'3C02

            WHEN "1101111" => -- JAL
                aux_control <= "00110000000110";

            WHEN "1100111" => -- JARL
                aux_control <= "00110000001110";

            WHEN "1110011" => -- ECALL
                aux_control <= "00000000000001";

            WHEN OTHERS => -- none, NOP
                aux_control <= "10000000000010";

        END CASE; -- aux_opcode

    END PROCESS;
    control <= aux_control;
END beh;
