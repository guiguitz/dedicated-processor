:: You can develop scripts to automate common ModelSim software tasks, such as creating a project,
:: making assignments, compiling, performing timing analysis, and custom reporting.
:: You can run Tcl commands and scripts to control the ModelSim software from the command line,
:: the ModelSim Tcl Console, the Tcl Scripts dialog box, or the Tasks window.
::
:: Universidade Federal de Minas Gerais
:: Laboratório de Sistemas Digitais
:: Autor: Prof. Ricardo de Oliveira Duarte - DELT/EE/UFMG
:: Batch Script de execução de aplicativos do ModelSim por meio de uma Task window do MS-Winsows - versão 1.0
:: 
:: Esse script tem por objetivo:
:: Criar um projeto no ModelSim por linha de comando
:: Compilar um fonte .vhd sintetizável com a library ieee 1993 sem o pin assignment
:: Compilar um fonte .vhd não sintetizável com a library ieee 1993 para fins de simulação (testbench)
:: Simular o DUT com a entidade tb_somador
:: Incluir todos as formas de onda dos sinais simulados pela entidade tb_somador, com o tipo de exibição (radix) unsigned
:: Visualizar todas as formas de onda geradas no arquivo .vcd 
:: Visualizar todas as estruturas geradas no arquivo .vcd 
:: Visualizar todas os signals geradas no arquivo .vcd 
:: Executar a simulação por 60ns
:: Aplicar zoom full na janela de visualização de forma de ondas.
::
:: Esse script pode ser executado como um arquivo em lotes (bat file) de uma janela de comandos do MS-Windows
:: Desde que o arquivo bat esteja na pasta (diretório) correto, assim como os demais arquivos fonte (.tcl e .vhd)
:: Obviamente que a variável de ambiente PATH do MS-Windows tem que apontar também para as pastas (diretórios)
:: das aplicações do ModelSim chamadas por esse script.
:: 
:: Para executar esse script de uma janela cmd do MS-Windows (Command MS-Windows Task window) na pasta que contiver esse arquivo digite:
:: C:\Users\UFMG\Downloads\somador> .\batch_script_tb_somador_modelsim_call.bat<ENTER>
vlib work
vcom -explicit  -93 "somador.vhd"
vcom -explicit  -93 "tb_somador.vhd"
vsim -t 1ns   -lib work tb_somador -do "add wave -radix unsigned sim:/tb_somador/*" -do "view wave" -do "view structure" -do "view signals" -do "run 60ns" -do "wave zoom full"