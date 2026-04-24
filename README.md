# anti_jamming2

Verilog RTL to interface **ZC702 (J62/J63 PMOD GPIO)** with **ADAR1000-EVALZ P3** for real-time beam-weight updates.

## Architecture

This design is a practical **PS+PL split**:
- **PS (Cortex-A9 software):** runs anti-jamming/null-steering math and generates ADAR1000 SPI frames.
- **PL (Verilog in this repo):** deterministic SPI/GPIO engine that pushes frames to ADAR1000 quickly.

## Implemented modules

- `rtl/adar1000_spi_master.v`
  - Synthesizable SPI master (mode-0 behavior), 24-bit frame default, programmable clock divider.
- `rtl/adar1000_beam_update.v`
  - Sends 8 SPI frames per `update_req`, then pulses `TX_LOAD` and optional `RX_LOAD`.
  - Drives `TR` and `PA_ON` control lines.
- `rtl/zc702_j62_j63_adar1000_top.v`
  - Top wrapper using differential board clock input (`sysclk_p/sysclk_n`) and exposing J62/J63 signal ports.

## ZC702 ↔ ADAR1000 P3 mapping used

- `j62_pin1_spi_sel_a_n` -> P3 pin 2 (`SPI_SEL_A`, active-low)
- `j62_pin2_spi_mosi`  -> P3 pin 4 (`SPI_MOSI`)
- `j62_pin3_spi_miso`  <- P3 pin 6 (`SPI_MISO`)
- `j62_pin4_spi_clk`   -> P3 pin 8 (`SPI_CLK`)
- `j63_pin1_rx_load`   -> P3 pin 1 (`GPIO0 / RX_LOAD`)
- `j63_pin3_tx_load`   -> P3 pin 3 (`GPIO1 / TX_LOAD`)
- `j63_pin7_tr`        -> P3 pin 5 (`GPIO4 / TR`)
- `j63_pin9_pa_on`     -> P3 pin 7 (`GPIO5 / PA_ON`)

> J63 even pins are intentionally not used to avoid PJTAG conflict on J41.

## Constraints

Use `constraints/zc702_j62_j63_adar1000_template.xdc`:
- Fill the `PACKAGE_PIN` placeholders from the ZC702 board docs/schematic.
- Keep J63 even-pin restriction if J41 PJTAG is active.

## Software integration flow

1. PS computes per-update beam/null weights for your 1D array at 11 GHz.
2. PS converts those weights into ADAR1000 register write frames (`frame0..frame7`).
3. PS pulses `update_req`.
4. PL writes all frames over SPI and pulses `TX_LOAD` (and optionally `RX_LOAD`).

This keeps real-time update timing stable in PL while the adaptive algorithm remains flexible in software.
