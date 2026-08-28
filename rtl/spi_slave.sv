`timescale 1ns/1ps

module spi_slave (
    input  logic       sclk,
    input  logic       csb_n,
    input  logic       mosi,

    input  logic [7:0] tx_data,

    output logic       miso,
    output logic       miso_oe,

    output logic [7:0] rx_data,
    output logic       rx_valid
);

    // ------------------------------------------------------------
    // Internal registers
    // ------------------------------------------------------------

    // Receive shift register:
    // collects MOSI bits from the external SPI Master.
    logic [7:0] rx_shift_reg;

    // Receive bit counter:
    // counts the 8 rising edges of SCLK.
    logic [2:0] rx_bit_cnt;

    // Transmit bit counter:
    // determines which bit of tx_data is currently placed on MISO.
    logic [2:0] tx_bit_cnt;


    // ------------------------------------------------------------
    // MISO output
    //
    // SPI Mode 0, MSB first.
    //
    // tx_bit_cnt = 0 -> tx_data[7]
    // tx_bit_cnt = 1 -> tx_data[6]
    // ...
    // tx_bit_cnt = 7 -> tx_data[0]
    // ------------------------------------------------------------

    always_comb begin

        if (!csb_n) begin

            miso    = tx_data[7 - tx_bit_cnt];
            miso_oe = 1'b1;

        end
        else begin

            miso    = 1'b0;
            miso_oe = 1'b0;

        end

    end


    // ------------------------------------------------------------
    // Receive path
    //
    // SPI Mode 0:
    // MOSI is sampled on the rising edge of SCLK.
    //
    // CSB high means that the Slave is inactive and the
    // current transaction state is reset.
    // ------------------------------------------------------------

    always_ff @(posedge sclk or posedge csb_n) begin

        if (csb_n) begin

            rx_shift_reg <= 8'b0;
            rx_bit_cnt    <= 3'd0;
            rx_valid      <= 1'b0;

        end
        else begin

            // Shift the newly sampled MOSI bit into the register.
            rx_shift_reg <= {
                rx_shift_reg[6:0],
                mosi
            };


            // The eighth rising edge completes one 8-bit word.
            if (rx_bit_cnt == 3'd7) begin

                // Include the current MOSI bit directly because
                // rx_shift_reg itself is updated by non-blocking
                // assignment after this clock edge.
                rx_data <= {
                    rx_shift_reg[6:0],
                    mosi
                };

                rx_valid   <= 1'b1;
                rx_bit_cnt <= 3'd0;

            end
            else begin

                rx_valid   <= 1'b0;
                rx_bit_cnt <= rx_bit_cnt + 1'b1;

            end

        end

    end


    // ------------------------------------------------------------
    // Transmit path
    //
    // SPI Mode 0:
    // MISO changes on the falling edge of SCLK.
    //
    // Before the first rising edge, tx_bit_cnt = 0, so
    // tx_data[7] is already available on MISO.
    // ------------------------------------------------------------

    always_ff @(negedge sclk or posedge csb_n) begin

        if (csb_n) begin

            tx_bit_cnt <= 3'd0;

        end
        else begin

            if (tx_bit_cnt == 3'd7)
                tx_bit_cnt <= 3'd0;
            else
                tx_bit_cnt <= tx_bit_cnt + 1'b1;

        end

    end

endmodule