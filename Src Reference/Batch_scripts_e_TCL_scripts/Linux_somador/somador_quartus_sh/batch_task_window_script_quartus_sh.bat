:: You can develop scripts to automate common Quartus II software tasks, such as creating a project,
:: making assignments, compiling, performing timing analysis, and custom reporting.
:: You can run Tcl commands and scripts to control the Quartus II software from the command line,
:: the Quartus II Console, the Tcl Scripts dialog box, or the Tasks window.
::
:: Universidade Federal de Minas Gerais
:: Laboratório de Sistemas Digitais
:: Autor: Prof. Ricardo de Oliveira Duarte - DELT/EE/UFMG
:: Batch Script de execução de aplicativos do Quartus II por meio de uma Task window do MS-Winsows - versão 1.0
:: 
:: Esse script tem por objetivo:
:: Criar um projeto no quartus II por linha de comando
:: Gerar os arquivos .qpf e .qsf a partir de um TCL script gerado pela interface gráfica do Quartus II
:: Compilar um projeto completo já com o pin assignment incluso no próprio arquivo somador_quartus_sh.tcl
:: Gerar o arquivo para a gravação na SRAM do FPGA, ou seja, o arquivo de extensão .sof que será
:: criado na pasta output_files
:: Gravar a SRAM do FPGA com o executável quartus_pgm e o arquivo fonte somador.sof
:: Esse script pode ser executado como um arquivo em lotes (bat file) de uma janela de comandos do MS-Windows
:: Desde que o arquivo bat esteja na pasta (diretório) correto, assim como os demais arquivos fonte (.tcl e .vhd)
:: Obviamente que a variável de ambiente PATH do MS-Windows tem que apontar também para as pastas (diretórios)
:: das aplicações do Quartus II chamadas por esse script.
quartus_sh -t tcl_somador_quartus_sh.tcl
quartus_sh --flow compile somador
cd .\output_files\
:: Retire o comentário da linha abaixo se desejar gravar no kit DE10-Lite o arquivo somador.sof
::quartus_pgm --mode=JTAG --cable="USB-Blaster" -o "p;somador.sof"