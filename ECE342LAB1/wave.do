onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/the_top/the_datapath/clk
add wave -noupdate /top_tb/the_top/the_datapath/reset
add wave -noupdate /top_tb/the_top/enter
add wave -noupdate /top_tb/the_top/the_datapath/i_guess
add wave -noupdate /top_tb/the_top/actual
add wave -noupdate /top_tb/the_top/dp_over
add wave -noupdate /top_tb/the_top/dp_under
add wave -noupdate /top_tb/the_top/dp_equal
add wave -noupdate /top_tb/the_top/the_datapath/i_inc_actual
add wave -noupdate /top_tb/the_top/the_control/state
add wave -noupdate /top_tb/the_top/the_control/nextstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {488 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {864 ps}
