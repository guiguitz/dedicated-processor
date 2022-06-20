-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade Lógica e Aritmética com capacidade para 8 operações distintas, além de entradas e saída de dados genérica.
-- Os três bits que selecionam o tipo de operação da ULA são os 3 bits menos significativos do OPCODE (vide aqrquivo: par.xls)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ula IS
    GENERIC (
        largura_dado : NATURAL
    );

    PORT (
        entrada_a : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        entrada_b : IN STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        seletor : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- aluop
        saida : OUT STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
        zero : OUT STD_LOGIC
    );
END ula;

ARCHITECTURE comportamental OF ula IS
    SIGNAL resultado_ula : STD_LOGIC_VECTOR((largura_dado - 1) DOWNTO 0);
BEGIN
    PROCESS (entrada_a, entrada_b, seletor) IS
    BEGIN
        CASE(seletor) IS
            WHEN "0001" => -- ADD = soma com sinal
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_a) + signed(entrada_b));
            zero <= '0';
            WHEN "0010" => -- SUB = Subtração com sinal
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_a) - signed(entrada_b));
            zero <= '0';
            WHEN "0011" => -- ADDI = soma com sinal
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_a) + signed(entrada_b));
            zero <= '0';
            WHEN "0100" => -- SLL = Shift Left Logical
            resultado_ula <= STD_LOGIC_VECTOR(unsigned(entrada_a) SLL to_integer(unsigned(entrada_b)));
            zero <= '0';
            WHEN "0101" => -- SRL = Shift Right Logical
            resultado_ula <= STD_LOGIC_VECTOR(unsigned(entrada_a) SRL to_integer(unsigned(entrada_b)));
            zero <= '0';
            WHEN "0110" => -- LW = Load Word
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_b));
            zero <= '0';
            WHEN "0111" => -- SW = Store Word
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_b));
            zero <= '0';
            WHEN "1000" => -- LB = soma com sinal
            resultado_ula <= STD_LOGIC_VECTOR(signed(entrada_b));
            zero <= '0';
            -- when "1001" => -- SB = Store byte
            --     resultado_ula <= std_logic_vector(x"FF" and signed(entrada_b));
            --     zero <= '0';
            WHEN "1010" => -- BEQ = Branch Equal
            resultado_ula <= (OTHERS => '0');
            IF (signed(entrada_a) = signed(entrada_b)) THEN
                zero <= '1';
            ELSE
                zero <= '0';
            END IF;
            WHEN "1011" => -- BNE = Branch Not Equal
            resultado_ula <= (OTHERS => '0');
            IF (signed(entrada_a) /= signed(entrada_b)) THEN
                zero <= '1';
            ELSE
                zero <= '0';
            END IF;
            WHEN "1100" => -- SLT = Set On Less Than
            IF (signed(entrada_a) < signed(entrada_b)) THEN
                resultado_ula <= (OTHERS => '1');
            ELSE
                resultado_ula <= (OTHERS => '0');
            END IF;
            zero <= '0';
            WHEN "1101" => -- SLTI = Set On Less Than Imme
            IF (signed(entrada_a) < signed(entrada_b)) THEN
                resultado_ula <= (OTHERS => '1');
            ELSE
                resultado_ula <= (OTHERS => '0');
            END IF;
            zero <= '0';
            WHEN OTHERS =>
            resultado_ula <= (OTHERS => '0');
        END CASE;
    END PROCESS;
    saida <= resultado_ula;
END comportamental;
