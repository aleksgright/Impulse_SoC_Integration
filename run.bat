iverilog -g2012 -o sim f.sv tb.sv
vvp sim

gtkwave wave.vcd