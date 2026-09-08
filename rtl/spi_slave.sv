`timescale 1ns/1ps

module spi_slave #(
    parameter integer DATA_WIDTH = 16
)(
    input  logic                  sclk,
    input  logic                  csb_n,
    input  logic                  mosi,

    input  logic [DATA_WIDTH-1:0] tx_data,

    output logic                  miso,
    output logic                  miso_oe,

    output logic [DATA_WIDTH-1:0] rx_data,
    output logic                  rx_valid
);

    // ============================================================
    // Local parameters
    // ============================================================

    localparam integer CNT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);


    // ============================================================
    // Internal registers
    // ============================================================

    logic [DATA_WIDTH-1:0] rx_shift_reg;

    logic [CNT_WIDTH-1:0] rx_bit_cnt;
    logic [CNT_WIDTH-1:0] tx_bit_cnt;


    // ============================================================
    // MISO output logic
    //
    // SPI Mode 0:
    //   - data is sampled on rising edge
    //   - data changes/prepares on falling edge
    //
    // The MSB is already available when CSB becomes active.
    // ============================================================

    always_comb begin

        if (!csb_n) begin

            miso =
                tx_data[DATA_WIDTH-1-tx_bit_cnt];

            miso_oe = 1'b1;

        end
        else begin

            miso    = 1'b0;
            miso_oe = 1'b0;

        end

    end


    // ============================================================
    // Receive path
    //
    // Mode 0:
    // MOSI is sampled on the rising edge of SCLK.
    // ============================================================

    always_ff @(posedge sclk or posedge csb_n) begin

        if (csb_n) begin

            rx_shift_reg <= '0;
            rx_bit_cnt    <= '0;
            rx_valid      <= 1'b0;

        end
        else begin

            rx_shift_reg <= {
                rx_shift_reg[DATA_WIDTH-2:0],
                mosi
            };


            // ----------------------------------------------------
            // Complete one DATA_WIDTH-bit word
            // ----------------------------------------------------

            if (rx_bit_cnt == DATA_WIDTH-1) begin

                rx_data <= {
                    rx_shift_reg[DATA_WIDTH-2:0],
                    mosi
                };

                rx_valid   <= 1'b1;
                rx_bit_cnt <= '0;

            end
            else begin

                rx_valid   <= 1'b0;
                rx_bit_cnt <= rx_bit_cnt + 1'b1;

            end

        end

    end


    // ============================================================
    // Transmit bit counter
    //
    // Mode 0:
    // advance to the next output bit on falling edge.
    // ============================================================

    always_ff @(negedge sclk or posedge csb_n) begin

        if (csb_n) begin

            tx_bit_cnt <= '0;

        end
        else begin

            if (tx_bit_cnt == DATA_WIDTH-1)
                tx_bit_cnt <= '0;

            else
                tx_bit_cnt <= tx_bit_cnt + 1'b1;

        end

    end

endmodule