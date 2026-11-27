# RK-XCKU5P-F V1.2 (xcku5p-ffvb676-2-i)

# 200 MHz differential system clock
set_property PACKAGE_PIN T24 [get_ports sys_clk_p]
set_property PACKAGE_PIN U24 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports {sys_clk_p sys_clk_n}]
create_clock -name sys_clk -period 5.000 [get_ports sys_clk_p]

# LEDs
set_property PACKAGE_PIN H9  [get_ports {led[0]}]
set_property PACKAGE_PIN J9  [get_ports {led[1]}]
set_property PACKAGE_PIN G11 [get_ports {led[2]}]
set_property PACKAGE_PIN H11 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# Push buttons
set_property PACKAGE_PIN K9  [get_ports {key[0]}]
set_property PACKAGE_PIN K10 [get_ports {key[1]}]
set_property PACKAGE_PIN J10 [get_ports {key[2]}]
set_property PACKAGE_PIN J11 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[*]}]

# Buttons and LEDs are asynchronous, no I/O timing to meet
set_false_path -from [get_ports {key[*]}]
set_false_path -to   [get_ports {led[*]}]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# Other pins, for reference:
#   UART rxd/txd           AD13 / AC14 (LVCMOS33)
#   PL_CLK 50 MHz          AC13 (LVCMOS33, doesn't work on my board)
#   QSFP28 GT clk 156.25   V7 / V6
#   PCIe ref clk           AB7 / AB6
#   SD clk                 Y15
#   QSPI0 sclk             Y11
