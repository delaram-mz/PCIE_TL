#******************************************************************************
#	Filename:		mydo.tcl
#	Project:		PCIE
#   Version:		0.90
#	History:
#	Date:			8 Augest 2023
#	Last Author: 	Delaram
#  Copyright (C) 2022 University of Tehran
#  This source file may be used and distributed without
#  restriction provided that this copyright statement is not
#  removed from the file and that any derivative work contains
#  the original copyright notice and the associated disclaimer.
#
#******************************************************************************
#	File content description:
#	do file for simualting the PCIE EP TL                              
#******************************************************************************

#echo "argc = $argc"
if { $argc < 1 } {
    puts "The DO file requires one argument: "
    puts "1. TB_Name . "
    puts "Please try again with the following syntax: "
    puts "do doFileName.do TB_Name"
    puts "In my case is:   do mydo.do PCIE_EP_TL_TB"
} else {
    project compileall

    vsim work.$1

    if {[file exists wave.do]} {
        do wave.do
    }
	
	restart -force

    #run -all

}