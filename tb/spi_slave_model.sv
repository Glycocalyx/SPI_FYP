`timescale 1ns/1ps

module spi_slave_model #(
    parameter logic [7:0] RESPONSE = 8'h3C
)(
    input  logic       sclk,
    input  logic       csb_n,
    input  logic       mosi,

    output logic       miso,
    output logic [7:0] received_data
);

    logic [7:0] rx_shift_reg;
    logic [2:0] tx_bit_cnt;

    /*
     * Mode 0 transmit behavior:
     *
     * The first MISO bit must already be available before
     * the first rising edge of SCLK.
     *
     * While CSB is high, tx_bit_cnt is reset to zero.
     * Therefore when CSB goes low, RESPONSE[7] immediately
     * appears on MISO.
     *
     * MISO changes to the next bit on each falling edge.
     */
    always_ff @(negedge sclk or posedge csb_n) begin

        if (csb_n) begin

            tx_bit_cnt <= 3'd0;

        end
        else begin

            if (tx_bit_cnt != 3'd7)
                tx_bit_cnt <= tx_bit_cnt + 1'b1;

        end

    end


    assign miso =
        (!csb_n) ? RESPONSE[7 - tx_bit_cnt] : 1'b0;


    /*
     * Mode 0 receive behavior:
     * sample MOSI on each rising edge of SCLK.
     */
    always_ff @(posedge sclk or posedge csb_n) begin

        if (csb_n) begin

            rx_shift_reg <= 8'b0;

        end
        else begin

            rx_shift_reg <= {
                rx_shift_reg[6:0],
                mosi
            };

        end

    end


    /*
     * When CSB returns high, the transaction is finished.
     * Save the complete byte received from the Master.
     */
    always @(posedge csb_n) begin

        received_data <= rx_shift_reg;

    end

endmodule