# You can develop scripts to automate common ModelSim software tasks, such as creating a project,
# making assignments, compiling, performing timing analysis, and custom reporting.
# You can run Tcl commands and scripts to control the ModelSim software from the command line,
# the ModelSim Tcl Console, the Tcl Scripts dialog box, or the Tasks window.
#
# Universidade Federal de Minas Gerais
# Laboratório de Sistemas Digitais
# Autor: Prof. Ricardo de Oliveira Duarte - DELT/EE/UFMG
# Script de execução de aplicativos do ModelSim por meio da janela shell de comandos TCL do Modelsim - versão 1.0
# 
# Esse script tem por objetivo:
# Criar um projeto no ModelSim por linha de comando
# Compilar um fonte .vhd sintetizável com a library ieee 1993 sem o pin assignment
# Compilar um fonte .vhd não sintetizável com a library ieee 1993 para fins de simulação (testbench)
# Simular o DUT com a entidade tb_somador
# Incluir todos as formas de onda dos sinais simulados pela entidade tb_somador, com o tipo de exibição (radix) unsigned
# Visualizar todas as formas de onda geradas no arquivo .vcd 
# Visualizar todas as estruturas geradas no arquivo .vcd 
# Visualizar todas os signals geradas no arquivo .vcd 
# Executar a simulação por 60ns
# Aplicar zoom full na janela de visualização de forma de ondas.
#
# De dentro do ModelSim na janela de interpretação de comandos TCL tclsh: do tb_somador_modelsim_script.tcl
#
# De dentro na janela de interpretação de comandos do MS-Windows, você pode digitar (testar) qualquer comando
# como por exzemplo, o da linha abaixo:
#vsim -do tb_somador_modelsim_script.tcl

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vcom -explicit  -93 "somador.vhd"
vcom -explicit  -93 "tb_somador.vhd"
vsim -t 1ns   -lib work tb_somador -do "do_wave_sim.tcl"
add wave -radix unsigned sim:/tb_somador/*
#do {wave.do}
view wave
view structure
view signals
run 60ns
wave zoom full
#quit -force
