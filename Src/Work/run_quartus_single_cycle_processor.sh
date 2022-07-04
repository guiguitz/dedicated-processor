#!/bin/bash

quartus_sh -t single_cycle_processor.tcl
quartus_sh --flow compile single_cycle_processor

quartus_pgm --mode=JTAG --cable="USB-Blaster" -o "p;single_cycle_processor.sof"
