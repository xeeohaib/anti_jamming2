module zc702_j62_j63_adar1000_top #(
    parameter integer SPI_CLK_DIV = 9
) (
    input  wire sysclk_p,
    input  wire sysclk_n,
    input  wire rst_n,

    input  wire update_req,
    input  wire rx_load_on_update,
    input  wire tr_mode,
    input  wire pa_enable,

    input  wire [23:0] frame0,
    input  wire [23:0] frame1,
    input  wire [23:0] frame2,
    input  wire [23:0] frame3,
    input  wire [23:0] frame4,
    input  wire [23:0] frame5,
    input  wire [23:0] frame6,
    input  wire [23:0] frame7,

    output wire update_busy,
    output wire update_done,

    output wire j62_pin1_spi_sel_a,
    output wire j62_pin2_spi_mosi,
    input  wire j62_pin3_spi_miso,
    output wire j62_pin4_spi_clk,

    output wire j63_pin1_rx_load,
    output wire j63_pin3_tx_load,
    output wire j63_pin7_tr,
    output wire j63_pin9_pa_on
);

    wire clk_200;
    wire rst;

    IBUFDS #(
        .DIFF_TERM("TRUE"),
        .IOSTANDARD("LVDS_25")
    ) u_ibufds_sysclk (
        .I (sysclk_p),
        .IB(sysclk_n),
        .O (clk_200)
    );

    assign rst = ~rst_n;

    adar1000_beam_update #(
        .SPI_FRAME_BITS(24),
        .SPI_CLK_DIV(SPI_CLK_DIV)
    ) u_beam_update (
        .clk              (clk_200),
        .rst              (rst),
        .update_req       (update_req),
        .rx_load_on_update(rx_load_on_update),
        .tr_mode          (tr_mode),
        .pa_enable        (pa_enable),
        .frame0           (frame0),
        .frame1           (frame1),
        .frame2           (frame2),
        .frame3           (frame3),
        .frame4           (frame4),
        .frame5           (frame5),
        .frame6           (frame6),
        .frame7           (frame7),
        .spi_clk          (j62_pin4_spi_clk),
        .spi_mosi         (j62_pin2_spi_mosi),
        .spi_miso         (j62_pin3_spi_miso),
        .spi_sel_a        (j62_pin1_spi_sel_a),
        .rx_load          (j63_pin1_rx_load),
        .tx_load          (j63_pin3_tx_load),
        .tr_out           (j63_pin7_tr),
        .pa_on            (j63_pin9_pa_on),
        .update_busy      (update_busy),
        .update_done      (update_done)
    );

endmodule
