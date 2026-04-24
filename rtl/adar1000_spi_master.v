module adar1000_spi_master #(
    parameter integer FRAME_BITS = 24,
    parameter integer CLK_DIV    = 9
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  start,
    input  wire [FRAME_BITS-1:0] tx_data,
    output reg  [FRAME_BITS-1:0] rx_data,
    output reg                   busy,
    output reg                   done,
    output reg                   sclk,
    output reg                   mosi,
    input  wire                  miso,
    output reg                   cs_n
);

    reg [FRAME_BITS-1:0] shift_tx;
    reg [FRAME_BITS-1:0] shift_rx;
    reg [15:0]           div_cnt;
    reg [7:0]            bit_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_tx <= {FRAME_BITS{1'b0}};
            shift_rx <= {FRAME_BITS{1'b0}};
            div_cnt  <= 16'd0;
            bit_cnt  <= 8'd0;
            rx_data  <= {FRAME_BITS{1'b0}};
            busy     <= 1'b0;
            done     <= 1'b0;
            sclk     <= 1'b0;
            mosi     <= 1'b0;
            cs_n     <= 1'b1;
        end else begin
            done <= 1'b0;

            if (!busy) begin
                sclk <= 1'b0;
                cs_n <= 1'b1;
                if (start) begin
                    busy     <= 1'b1;
                    cs_n     <= 1'b0;
                    div_cnt  <= 16'd0;
                    bit_cnt  <= FRAME_BITS[7:0];
                    shift_tx <= tx_data;
                    shift_rx <= {FRAME_BITS{1'b0}};
                    mosi     <= tx_data[FRAME_BITS-1];
                end
            end else begin
                if (div_cnt == CLK_DIV[15:0]) begin
                    div_cnt <= 16'd0;

                    if (sclk == 1'b0) begin
                        sclk     <= 1'b1;
                        shift_rx <= {shift_rx[FRAME_BITS-2:0], miso};
                    end else begin
                        sclk <= 1'b0;

                        if (bit_cnt == 8'd1) begin
                            busy    <= 1'b0;
                            done    <= 1'b1;
                            cs_n    <= 1'b1;
                            mosi    <= 1'b0;
                            rx_data <= {shift_rx[FRAME_BITS-2:0], miso};
                        end else begin
                            bit_cnt  <= bit_cnt - 8'd1;
                            shift_tx <= {shift_tx[FRAME_BITS-2:0], 1'b0};
                            mosi     <= shift_tx[FRAME_BITS-2];
                        end
                    end
                end else begin
                    div_cnt <= div_cnt + 16'd1;
                end
            end
        end
    end

endmodule
