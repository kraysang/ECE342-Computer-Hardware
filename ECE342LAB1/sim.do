
vlog -sv -work work +incdir+C:/Users/GV-ZQ/Desktop/GuessThe\ Number_svV0.1 {C:/Users/GV-ZQ/Desktop/GuessThe Number_svV0.1/top.sv}

vlog -sv -work work +incdir+C:/Users/GV-ZQ/Desktop/GuessThe\ Number_svV0.1 {C:/Users/GV-ZQ/Desktop/GuessThe Number_svV0.1/top_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  top_tb

do wave.do
view structure
view signals
run -all
