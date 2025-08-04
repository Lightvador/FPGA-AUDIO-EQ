### Clock (Uncomment and use only one create_clock line)
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports clk]

### Reset
set_property PACKAGE_PIN R18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

### SPI Interface
set_property PACKAGE_PIN AB9 [get_ports miso]
set_property IOSTANDARD LVCMOS33 [get_ports miso]

set_property PACKAGE_PIN AA8 [get_ports sclk]
set_property IOSTANDARD LVCMOS33 [get_ports sclk]

set_property PACKAGE_PIN AB11 [get_ports ss]
set_property IOSTANDARD LVCMOS33 [get_ports ss]

#
set_property PACKAGE_PIN V8 [get_ports SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports SCLK]

set_property PACKAGE_PIN V12 [get_ports SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports SYNC]

set_property PACKAGE_PIN W10 [get_ports SDATA]
set_property IOSTANDARD LVCMOS33 [get_ports SDATA]
