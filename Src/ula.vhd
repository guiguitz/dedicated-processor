-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletrônica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Unidade Lógica e Aritmética com capacidade para 8 operações distintas, além de entradas e saída de dados genérica.
-- Os três bits que selecionam o tipo de operação da ULA são os 3 bits menos significativos do OPCODE (vide aqrquivo: par.xls)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    generic (
        largura_dado : natural
    );

    port (
        entrada_a : in std_logic_vector((largura_dado - 1) downto 0);
        entrada_b : in std_logic_vector((largura_dado - 1) downto 0);
        seletor   : in std_logic_vector(3 downto 0); -- aluop
        saida     : out std_logic_vector((largura_dado - 1) downto 0);
        zero : out std_logic
    );
end ula;

architecture comportamental of ula is
    signal resultado_ula : std_logic_vector((largura_dado - 1) downto 0);
begin
    process (entrada_a, entrada_b, seletor) is
    begin
        case(seletor) is
            when "0001" => -- ADD = soma com sinal
                resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
                zero <= '0';
            when "0010" => -- SUB = Subtração com sinal
                resultado_ula <= std_logic_vector(signed(entrada_a) - signed(entrada_b));
                zero <= '0';
            when "0011" => -- ADDI = soma com sinal
                resultado_ula <= std_logic_vector(signed(entrada_a) + signed(entrada_b));
                zero <= '0';
            when "0100" => -- SLL = Shift Left Logical
                resultado_ula <= std_logic_vector(unsigned(entrada_a) sll to_integer(unsigned(entrada_b)));
                zero <= '0';
            when "0101" => -- SRL = Shift Right Logical
                resultado_ula <= std_logic_vector(unsigned(entrada_a) srl to_integer(unsigned(entrada_b)));
                zero <= '0';
            when "0110" => -- LW = Load Word
                resultado_ula <= std_logic_vector(signed(entrada_b));
                zero <= '0';
            when "0111" => -- SW = Store Word
                resultado_ula <= std_logic_vector(signed(entrada_b));
                zero <= '0';
            when "1000" => -- LB = soma com sinal
                resultado_ula <= std_logic_vector(signed(entrada_b));
                zero <= '0';
            -- when "1001" => -- SB = Store byte
            --     resultado_ula <= std_logic_vector(x"FF" and signed(entrada_b));
            --     zero <= '0';
            when "1010" => -- BEQ = Branch Equal
                resultado_ula <= (others => '0');
                if (signed(entrada_a) = signed(entrada_b)) then
                    zero <= '1';
                else
                    zero <= '0';
                end if;
            when "1011" => -- BNE = Branch Not Equal
                resultado_ula <= (others => '0');
                if (signed(entrada_a) /= signed(entrada_b)) then
                    zero <= '1';
                else
                    zero <= '0';
                end if;
            when "1100" => -- SLT = Set On Less Than
                if (signed(entrada_a) < signed(entrada_b)) then
                    resultado_ula <= (others => '1');
                else
                    resultado_ula <= (others => '0');
                end if;
                zero <= '0';
            when "1101" => -- SLTI = Set On Less Than Imme
                if (signed(entrada_a) < signed(entrada_b)) then
                    resultado_ula <= (others => '1');
                else
                    resultado_ula <= (others => '0');
                end if;
                zero <= '0';
            when others =>
                resultado_ula <= (others => '0');
        end case;
    end process;
    saida <= resultado_ula;
end comportamental;
