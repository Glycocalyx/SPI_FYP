`timescale 1ns/1ps

module spi_master #(
    parameter int unsigned CLK_DIV = 4
)(
    input  logic       clk,
    input  logic       rst_n,

    input  logic       start,
    input  logic       slave_sel,
    input  logic [7:0] tx_data,

    output logic       busy,
    output logic       done,
    output logic [7:0] rx_data,

    output logic       sclk,
    output logic       mosi,
    input  logic       miso,

    output logic [1:0] csb_n
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSFER,
        FINISH
    } state_t;

    state_t state;

    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;

    localparam int CLK_DIV_WIDTH =
        (CLK_DIV <= 1) ? 1 : $clog2(CLK_DIV);

    logic [CLK_DIV_WIDTH-1:0] clk_div_cnt;

    // Mode 0, MSB first:
    // MOSI always outputs the current MSB.
    assign mosi = tx_shift_reg[7];

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state        <= IDLE;

            tx_shift_reg <= 8'b0;
            rx_shift_reg <= 8'b0;
            rx_data      <= 8'b0;

            bit_cnt      <= 3'd0;
            clk_div_cnt  <= '0;

            sclk         <= 1'b0;
            csb_n        <= 2'b11;

            busy         <= 1'b0;
            done         <= 1'b0;

        end
        else begin

            case (state)

                IDLE: begin

                    sclk        <= 1'b0;
                    csb_n       <= 2'b11;
                    clk_div_cnt <= '0;

                    busy        <= 1'b0;
                    done        <= 1'b0;

                    if (start) begin
                        busy  <= 1'b1;
                        state <= LOAD;
                    end

                end


                LOAD: begin

                    tx_shift_reg <= tx_data;
                    rx_shift_reg <= 8'b0;

                    bit_cnt     <= 3'd7;
                    clk_div_cnt <= '0;

                    sclk <= 1'b0;
                    busy <= 1'b1;
                    done <= 1'b0;

                    // Active-low chip select.
                    // slave_sel = 0 -> Slave 0
                    // slave_sel = 1 -> Slave 1
                    if (slave_sel == 1'b0)
                        csb_n <= 2'b10;
                    else
                        csb_n <= 2'b01;

                    state <= TRANSFER;

                end


                TRANSFER: begin

                    busy <= 1'b1;
                    done <= 1'b0;

                    if (clk_div_cnt == CLK_DIV - 1) begin

                        clk_div_cnt <= '0;

                        if (sclk == 1'b0) begin

                            // Mode 0 rising edge:
                            // sample MISO.
                            sclk <= 1'b1;

                            rx_shift_reg <= {
                                rx_shift_reg[6:0],
                                miso
                            };

                        end
                        else begin

                            // Mode 0 falling edge:
                            // move to the next transmit bit.
                            sclk <= 1'b0;

                            if (bit_cnt == 3'd0) begin

                                state <= FINISH;

                            end
                            else begin

                                tx_shift_reg <= {
                                    tx_shift_reg[6:0],
                                    1'b0
                                };

                                bit_cnt <= bit_cnt - 1'b1;

                            end

                        end

                    end
                    else begin

                        clk_div_cnt <= clk_div_cnt + 1'b1;

                    end

                end


                FINISH: begin

                    sclk  <= 1'b0;
                    csb_n <= 2'b11;

                    busy <= 1'b0;
                    done <= 1'b1;

                    rx_data <= rx_shift_reg;

                    state <= IDLE;

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule