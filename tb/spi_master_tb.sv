`timescale 1ns/1ps

module spi_master_tb;

    logic clk;
    logic rst_n;

    logic start;
    logic slave_sel;
    logic [7:0] tx_data;

    logic busy;
    logic done;
    logic [7:0] rx_data;

    logic sclk;
    logic mosi;
    logic miso;
    logic [1:0] csb_n;

    logic [7:0] slave_received_data;


    // ------------------------------------------------------------
    // SPI Master DUT
    // ------------------------------------------------------------
    spi_master #(
        .CLK_DIV(4)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),

        .start     (start),
        .slave_sel (slave_sel),
        .tx_data   (tx_data),

        .busy      (busy),
        .done      (done),
        .rx_data   (rx_data),

        .sclk      (sclk),
        .mosi      (mosi),
        .miso      (miso),

        .csb_n     (csb_n)
    );


    // ------------------------------------------------------------
    // Slave 0 verification model
    //
    // Master sends 0xA5.
    // Slave returns 0x3C.
    // ------------------------------------------------------------
    spi_slave_model #(
        .RESPONSE(8'h3C)
    ) slave0 (
        .sclk          (sclk),
        .csb_n         (csb_n[0]),
        .mosi          (mosi),
        .miso          (miso),
        .received_data (slave_received_data)
    );


    // ------------------------------------------------------------
    // System clock
    //
    // Period = 10 ns
    // Frequency = 100 MHz
    // ------------------------------------------------------------
    initial begin
        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end
    end


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        // Initial values
        rst_n     = 1'b0;
        start     = 1'b0;
        slave_sel = 1'b0;
        tx_data   = 8'h00;

        // Hold reset active for 20 ns
        #20;

        rst_n = 1'b1;

        // Wait after reset release
        #20;


        // --------------------------------------------------------
        // Transaction 1
        //
        // Select Slave 0
        // Master sends 0xA5
        // Slave returns 0x3C
        // --------------------------------------------------------
        tx_data   = 8'hA5;
        slave_sel = 1'b0;


        // Drive start on the falling edge of clk.
        //
        // The DUT samples start on the rising edge of clk.
        // Changing start on the falling edge avoids a race
        // between the testbench and DUT.
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // Wait until transaction finishes
        wait (done == 1'b1);

        // Allow non-blocking assignments to settle
        #1;


        // --------------------------------------------------------
        // Check Slave -> Master direction
        // --------------------------------------------------------
        if (rx_data == 8'h3C) begin

            $display(
                "PASS: Master received 0x%h",
                rx_data
            );

        end
        else begin

            $display(
                "FAIL: Master received 0x%h, expected 0x3C",
                rx_data
            );

        end


        // --------------------------------------------------------
        // Check Master -> Slave direction
        // --------------------------------------------------------
        if (slave_received_data == 8'hA5) begin

            $display(
                "PASS: Slave received 0x%h",
                slave_received_data
            );

        end
        else begin

            $display(
                "FAIL: Slave received 0x%h, expected 0xA5",
                slave_received_data
            );

        end


        #50;

        $finish;

    end

endmodule