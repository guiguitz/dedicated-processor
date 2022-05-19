-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Banco de registradores com entradas e saída de dados de tamanho genérico
-- entradas de endereço de tamanho genérico
-- clock e sinal de WE
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_address_registers is
    generic (
        largura_dado : natural;
        largura_ende : natural
    );

    port (
        address : in std_logic_vector((largura_ende - 1) downto 0);
        input : in std_logic_vector((largura_dado - 1) downto 0);
        output : out std_logic_vector((largura_dado - 1) downto 0);
        clk, WE     : in std_logic
    );
end interrupt_address_registers;

architecture comportamental of interrupt_address_registers is
    type registerfile is array(0 to ((2 ** largura_ende) - 1)) of std_logic_vector((largura_dado - 1) downto 0);
    signal banco : registerfile;
begin
    leitura : process (clk) is
    begin
        output <= banco(to_integer(unsigned(address)));
    end process;

    escrita : process (clk) is
    begin
        if rising_edge(clk) then
            if WE = '1' then
                banco(to_integer(unsigned(address))) <= input;
            end if;
        end if;
    end process;
end comportamental;
