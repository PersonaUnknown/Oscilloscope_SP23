vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../HW1.gen/sources_1/ip/clk_wiz_0" \
"D:/Xilinx_2020.2/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"D:/Xilinx_2020.2/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../HW1.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.vhdl" \


vlog -work xil_defaultlib \
"glbl.v"

