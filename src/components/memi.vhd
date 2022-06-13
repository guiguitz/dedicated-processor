-- Universidade Federal de Minas Gerais
-- Escola de Engenharia
-- Departamento de Engenharia Eletronica
-- Autoria: Professor Ricardo de Oliveira Duarte
-- Memória de Programas ou Memória de Instruções de tamanho genérico
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memi IS
    GENERIC (
        INSTR_WIDTH : NATURAL := 32; -- tamanho da instrução em número de bits
        MI_ADDR_WIDTH : NATURAL := 32 -- tamanho do endereço da memória de instruções em número de bits
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        Endereco : IN STD_LOGIC_VECTOR(MI_ADDR_WIDTH - 1 DOWNTO 0);
        Instrucao : OUT STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamental OF memi IS
    TYPE rom_type IS ARRAY (0 TO 2 ** (MI_ADDR_WIDTH - 20)) OF STD_LOGIC_VECTOR(INSTR_WIDTH - 1 DOWNTO 0);
    SIGNAL rom : rom_type;
BEGIN
    PROCESS (clk, reset) IS
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (reset = '1') THEN
                rom <= (
                    0 => B"00000000000000000000000000000001",
                    4 => B"00000000000000000000000000000010",
                    8 => B"00000000000000000000000000000011",
                    12 => B"00000000000000000000000000000100",
                    16 => B"00000000000000000000000000000101",
                    OTHERS => B"00000000000000000000000000000000"
                    );
            ELSE
                Instrucao <= rom(to_integer(unsigned(Endereco)));
            END IF;
        END IF;
    END PROCESS;
END comportamental;
