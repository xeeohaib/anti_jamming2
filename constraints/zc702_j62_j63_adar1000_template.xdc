## ZC702 to ADAR1000-EVALZ P3 template constraints
## IMPORTANT:
## 1) Fill PACKAGE_PIN values from ZC702 user guide/schematic before implementation.
## 2) Do NOT use J63 even-numbered pins when J41 PJTAG is connected / used.
## 3) All PMOD/P3 digital lines are 3.3V logic.

## 200 MHz differential clock source (Y9/Y8 path)
#set_property PACKAGE_PIN <SYSCLK_P_PIN> [get_ports sysclk_p]
#set_property PACKAGE_PIN <SYSCLK_N_PIN> [get_ports sysclk_n]
set_property IOSTANDARD LVDS_25 [get_ports {sysclk_p sysclk_n}]

## Active-low reset and control from PS/PL fabric
#set_property PACKAGE_PIN <RSTN_PIN> [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## Example control inputs if routed to top pins (otherwise driven internally by AXI/EMIO logic)
set_property IOSTANDARD LVCMOS33 [get_ports {update_req rx_load_on_update tr_mode pa_enable}]
## Uncomment only when frame buses are routed to external FPGA pins.
#set_property IOSTANDARD LVCMOS33 [get_ports {frame0[*] frame1[*] frame2[*] frame3[*] frame4[*] frame5[*] frame6[*] frame7[*]}]

## J62 mapping (recommended SPI group)
## J62 pin1 -> P3 pin2  (SPI_SEL_A)
## J62 pin2 -> P3 pin4  (SPI_MOSI)
## J62 pin3 <- P3 pin6  (SPI_MISO)
## J62 pin4 -> P3 pin8  (SPI_CLK)
#set_property PACKAGE_PIN <J62_PIN1> [get_ports j62_pin1_spi_sel_a_n]
#set_property PACKAGE_PIN <J62_PIN2> [get_ports j62_pin2_spi_mosi]
#set_property PACKAGE_PIN <J62_PIN3> [get_ports j62_pin3_spi_miso]
#set_property PACKAGE_PIN <J62_PIN4> [get_ports j62_pin4_spi_clk]
set_property IOSTANDARD LVCMOS33 [get_ports {j62_pin1_spi_sel_a_n j62_pin2_spi_mosi j62_pin3_spi_miso j62_pin4_spi_clk}]

## J63 odd-pin-only mapping (avoid even pins due PJTAG sharing)
## J63 pin1 -> P3 pin1  (GPIO0 RX_LOAD)
## J63 pin3 -> P3 pin3  (GPIO1 TX_LOAD)
## J63 pin7 -> P3 pin5  (GPIO4 TR)
## J63 pin9 -> P3 pin7  (GPIO5 PA_ON)
#set_property PACKAGE_PIN <J63_PIN1> [get_ports j63_pin1_rx_load]
#set_property PACKAGE_PIN <J63_PIN3> [get_ports j63_pin3_tx_load]
#set_property PACKAGE_PIN <J63_PIN7> [get_ports j63_pin7_tr]
#set_property PACKAGE_PIN <J63_PIN9> [get_ports j63_pin9_pa_on]
set_property IOSTANDARD LVCMOS33 [get_ports {j63_pin1_rx_load j63_pin3_tx_load j63_pin7_tr j63_pin9_pa_on}]

set_property IOSTANDARD LVCMOS33 [get_ports {update_busy update_done}]
