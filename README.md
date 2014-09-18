verilog-code
============
# workflow
iverilog -o output filename.v -y ./

# make sure the following two lines are in your testbench
# immediately after initial begin block

# Insert the dumps here
$dumpfile("testbench.vcd")
$dumpvars(0,testbench)

# you can run an output file directly by typing 
./a.out
# Ctrl-C to stop and help to see commands

# to run gtkwave type
gtkwave testbench.vcd


