module adar1000_beam_update #(
    parameter integer SPI_FRAME_BITS = 24,
    parameter integer SPI_CLK_DIV    = 9
) (
    input  wire                     clk,
    input  wire                     rst,

    input  wire                     update_req,
    input  wire                     rx_load_on_update,
    input  wire                     tr_mode,
    input  wire                     pa_enable,

    input  wire [SPI_FRAME_BITS-1:0] frame0,
    input  wire [SPI_FRAME_BITS-1:0] frame1,
    input  wire [SPI_FRAME_BITS-1:0] frame2,
    input  wire [SPI_FRAME_BITS-1:0] frame3,
    input  wire [SPI_FRAME_BITS-1:0] frame4,
    input  wire [SPI_FRAME_BITS-1:0] frame5,
    input  wire [SPI_FRAME_BITS-1:0] frame6,
    input  wire [SPI_FRAME_BITS-1:0] frame7,

    output wire                     spi_clk,
    output wire                     spi_mosi,
    input  wire                     spi_miso,
    output wire                     spi_sel_a_n,
    output reg                      rx_load,
    output reg                      tx_load,
    output reg                      tr_out,
    output reg                      pa_on,

    output reg                      update_busy,
    output reg                      update_done
);

    localparam [2:0] ST_IDLE      = 3'd0;
    localparam [2:0] ST_LOAD_WORD = 3'd1;
    localparam [2:0] ST_WAIT_SPI  = 3'd2;
    localparam [2:0] ST_PULSE     = 3'd3;
    localparam [2:0] ST_DONE      = 3'd4;

    reg [2:0] state;
    reg [2:0] frame_idx;

    reg                      spi_start;
    reg [SPI_FRAME_BITS-1:0] spi_tx_data;
    wire [SPI_FRAME_BITS-1:0] spi_rx_data;
    wire                     spi_busy;
    wire                     spi_done;

    function [SPI_FRAME_BITS-1:0] frame_mux;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: frame_mux = frame0;
                3'd1: frame_mux = frame1;
                3'd2: frame_mux = frame2;
                3'd3: frame_mux = frame3;
                3'd4: frame_mux = frame4;
                3'd5: frame_mux = frame5;
                3'd6: frame_mux = frame6;
                3'd7: frame_mux = frame7;
                // Defensive default for unexpected index corruption.
                default: frame_mux = {SPI_FRAME_BITS{1'b0}};
            endcase
        end
    endfunction

    adar1000_spi_master #(
        .FRAME_BITS(SPI_FRAME_BITS),
        .CLK_DIV(SPI_CLK_DIV)
    ) u_spi_master (
        .clk    (clk),
        .rst    (rst),
        .start  (spi_start),
        .tx_data(spi_tx_data),
        .rx_data(spi_rx_data),
        .busy   (spi_busy),
        .done   (spi_done),
        .sclk   (spi_clk),
        .mosi   (spi_mosi),
        .miso   (spi_miso),
        .cs_n   (spi_sel_a_n)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= ST_IDLE;
            frame_idx   <= 3'd0;
            spi_start   <= 1'b0;
            spi_tx_data <= {SPI_FRAME_BITS{1'b0}};
            rx_load     <= 1'b0;
            tx_load     <= 1'b0;
            tr_out      <= 1'b0;
            pa_on       <= 1'b0;
            update_busy <= 1'b0;
            update_done <= 1'b0;
        end else begin
            spi_start   <= 1'b0;
            update_done <= 1'b0;
            tr_out      <= tr_mode;
            pa_on       <= pa_enable;

            case (state)
                ST_IDLE: begin
                    rx_load     <= 1'b0;
                    tx_load     <= 1'b0;
                    update_busy <= 1'b0;

                    if (update_req) begin
                        update_busy <= 1'b1;
                        frame_idx   <= 3'd0;
                        state       <= ST_LOAD_WORD;
                    end
                end

                ST_LOAD_WORD: begin
                    spi_tx_data <= frame_mux(frame_idx);
                    spi_start   <= 1'b1;
                    state       <= ST_WAIT_SPI;
                end

                ST_WAIT_SPI: begin
                    if (spi_done) begin
                        if (frame_idx == 3'd7) begin
                            state <= ST_PULSE;
                        end else begin
                            frame_idx <= frame_idx + 3'd1;
                            state     <= ST_LOAD_WORD;
                        end
                    end
                end

                ST_PULSE: begin
                    tx_load <= 1'b1;
                    rx_load <= rx_load_on_update;
                    state   <= ST_DONE;
                end

                ST_DONE: begin
                    tx_load     <= 1'b0;
                    rx_load     <= 1'b0;
                    update_busy <= 1'b0;
                    update_done <= 1'b1;
                    state       <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
