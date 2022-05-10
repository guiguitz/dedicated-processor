#!/bin/bash

# Analyzing vhdl files
ghdl -a banco_registradores.vhd
ghdl -a deslocador.vhd
ghdl -a memd.vhd
ghdl -a multiplicador.vhd
ghdl -a mux41.vhd
ghdl -a registrador.vhd
ghdl -a ula.vhd
ghdl -a extensor.vhd
ghdl -a memi.vhd
ghdl -a mux21.vhd
ghdl -a pc.vhd
ghdl -a somador.vhd
ghdl -a unidade_de_controle_ciclo_unico.vhd
ghdl -a via_de_dados_ciclo_unico.vhd
ghdl -a processador_ciclo_unico.vhd
ghdl -a tb_processador_ciclo_unico.vhd

# # Elaborating SoC
# ghdl -e tb_processador_ciclo_unico.vhd
# ghdl -r tb_processador_ciclo_unico --vcd=tb_processador_ciclo_unico.vcd

# # Wave view
# gtkwave -f tb_processador_ciclo_unico.vcd
