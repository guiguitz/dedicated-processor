-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memd IS
    GENERIC (
        number_of_words : NATURAL; -- número de words que a sua memória é capaz de armazenar
        MD_DATA_WIDTH : NATURAL; -- tamanho da palavra em bits
        MD_ADDR_WIDTH : NATURAL -- tamanho do endereco da memoria de dados em bits
    );
    PORT (
        clk : IN STD_LOGIC;
        write_data : IN STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
        memd_address : IN STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
        read_data : OUT STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0)
    );
END memd;

ARCHITECTURE comportamental OF memd IS
    --alocar espaço para a memoria e iniciar com 0
    TYPE data_mem IS ARRAY (0 TO number_of_words - 1) OF STD_LOGIC_VECTOR(MD_DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL ram : data_mem := (OTHERS => (OTHERS => '0'));
    SIGNAL ram_addr : STD_LOGIC_VECTOR(MD_ADDR_WIDTH - 1 DOWNTO 0);
BEGIN
    ram_addr <= memd_address(MD_ADDR_WIDTH - 1 DOWNTO 0);
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            ram(to_integer(unsigned(ram_addr))) <= write_data;
        END IF;
    END PROCESS;
    read_data <= ram(to_integer(unsigned(ram_addr)));
END comportamental;