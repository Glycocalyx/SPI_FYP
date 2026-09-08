`timescale 1ns/1ps

module spi_master #(
    parameter integer CLK_DIV    = 4,
    parameter integer DATA_WIDTH = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  start,
    input  logic                  slave_sel,

    input  logic [DATA_WIDTH-1:0] tx_data,

    output logic                  busy,
    output logic                  done,

    output logic [DATA_WIDTH-1:0] rx_data,

    output logic                  sclk,
    output logic                  mosi,

    input  logic                  miso,

    output logic [1:0]            csb_n
);

    // ============================================================
    // Local parameters
    // ============================================================

    localparam integer CNT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);


    // ============================================================
    // FSM definition
    // ============================================================

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSFER,
        FINISH
    } state_t;

    state_t state;


    // ============================================================
    // Internal registers
    // ============================================================

    logic [DATA_WIDTH-1:0] tx_shift_reg;
    logic [DATA_WIDTH-1:0] rx_shift_reg;

    logic [CNT_WIDTH-1:0] bit_cnt;

    integer clk_div_cnt;


    // ============================================================
    // MOSI
    //
    // MSB-first transmission.
    // The MSB is valid before the first rising SCLK edge.
    // ============================================================

    always_comb begin

        mosi = tx_shift_reg[DATA_WIDTH-1];

    end


    // ============================================================
    // Main Master controller
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state <= IDLE;

            busy <= 1'b0;
            done <= 1'b0;

            sclk <= 1'b0;

            csb_n <= 2'b11;

            tx_shift_reg <= '0;
            rx_shift_reg <= '0;

            rx_data <= '0;

            bit_cnt <= '0;

            clk_div_cnt <= 0;

        end
        else begin

            case (state)

                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    busy <= 1'b0;
                    done <= 1'b0;

                    sclk <= 1'b0;

                    csb_n <= 2'b11;

                    clk_div_cnt <= 0;


                    if (start) begin

                        busy  <= 1'b1;
                        state <= LOAD;

                    end

                end


                // =================================================
                // LOAD
                //
                // Load TX data and select the requested Slave.
                // =================================================

                LOAD: begin

                    busy <= 1'b1;
                    done <= 1'b0;

                    sclk <= 1'b0;

                    tx_shift_reg <= tx_data;
                    rx_shift_reg <= '0;

                    bit_cnt <= DATA_WIDTH-1;

                    clk_div_cnt <= 0;


                    if (slave_sel == 1'b0)
                        csb_n <= 2'b10;

                    else
                        csb_n <= 2'b01;


                    state <= TRANSFER;

                end


                // =================================================
                // TRANSFER
                //
                // Mode 0:
                //
                // current SCLK = 0:
                //     next transition is rising edge
                //     sample MISO
                //
                // current SCLK = 1:
                //     next transition is falling edge
                //     shift MOSI / prepare next bit
                // =================================================

                TRANSFER: begin

                    busy <= 1'b1;
                    done <= 1'b0;


                    if (clk_div_cnt == CLK_DIV-1) begin

                        clk_div_cnt <= 0;


                        // -----------------------------------------
                        // Rising SCLK edge
                        // -----------------------------------------

                        if (sclk == 1'b0) begin

                            sclk <= 1'b1;

                            rx_shift_reg <= {
                                rx_shift_reg[DATA_WIDTH-2:0],
                                miso
                            };

                        end


                        // -----------------------------------------
                        // Falling SCLK edge
                        // -----------------------------------------

                        else begin

                            sclk <= 1'b0;


                            // -------------------------------------
                            // Last bit completed
                            // -------------------------------------

                            if (bit_cnt == 0) begin

                                rx_data <= rx_shift_reg;

                                state <= FINISH;

                            end


                            // -------------------------------------
                            // Prepare next MOSI bit
                            // -------------------------------------

                            else begin

                                tx_shift_reg <= {
                                    tx_shift_reg[DATA_WIDTH-2:0],
                                    1'b0
                                };

                                bit_cnt <= bit_cnt - 1'b1;

                            end

                        end

                    end
                    else begin

                        clk_div_cnt <= clk_div_cnt + 1;

                    end

                end


                // =================================================
                // FINISH
                // =================================================

                FINISH: begin

                    busy <= 1'b0;
                    done <= 1'b1;

                    sclk <= 1'b0;

                    csb_n <= 2'b11;

                    clk_div_cnt <= 0;

                    state <= IDLE;

                end


                // =================================================
                // Default recovery
                // =================================================

                default: begin

                    state <= IDLE;

                    busy <= 1'b0;
                    done <= 1'b0;

                    sclk <= 1'b0;

                    csb_n <= 2'b11;

                    clk_div_cnt <= 0;

                end

            endcase

        end

    end

endmodule