`timescale 1ns/1ps

module spi_slave_tb;

    // ------------------------------------------------------------
    // Testbench signals
    // ------------------------------------------------------------
    logic clk;
    logic rst_n;

    logic start;
    logic slave_sel;

    logic [7:0] master_tx_data;
    logic [7:0] master_rx_data;

    logic master_busy;
    logic master_done;

    logic sclk;
    logic mosi;
    logic miso;

    logic [1:0] csb_n;


    // ------------------------------------------------------------
    // SPI Slave signals
    // ------------------------------------------------------------
    logic [7:0] slave_tx_data;
    logic [7:0] slave_rx_data;

    logic slave_rx_valid;
    logic slave_miso_oe;

    logic saw_rx_valid;


    // ------------------------------------------------------------
    // Verification Master
    //
    // This Master is used only to generate SPI transactions
    // for testing the real SPI Slave RTL.
    // ------------------------------------------------------------
    spi_master #(
        .CLK_DIV(4)
    ) u_master (
        .clk       (clk),
        .rst_n     (rst_n),

        .start     (start),
        .slave_sel (slave_sel),
        .tx_data   (master_tx_data),

        .busy      (master_busy),
        .done      (master_done),
        .rx_data   (master_rx_data),

        .sclk      (sclk),
        .mosi      (mosi),
        .miso      (miso),

        .csb_n     (csb_n)
    );


    // ------------------------------------------------------------
    // Real SPI Slave DUT
    //
    // This is the RTL intended for later synthesis.
    // ------------------------------------------------------------
    spi_slave u_slave (
        .sclk     (sclk),
        .csb_n    (csb_n[0]),
        .mosi     (mosi),

        .tx_data  (slave_tx_data),

        .miso     (miso),
        .miso_oe  (slave_miso_oe),

        .rx_data  (slave_rx_data),
        .rx_valid (slave_rx_valid)
    );


    // ------------------------------------------------------------
    // System clock for verification Master
    //
    // Period    = 10 ns
    // Frequency = 100 MHz
    // ------------------------------------------------------------
    initial begin

        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end

    end


    // ------------------------------------------------------------
    // Monitor whether the Slave generated rx_valid
    //
    // rx_valid belongs to the SCLK clock domain and may return
    // low before the final test checks are performed.
    // Therefore the testbench remembers whether it was observed.
    // ------------------------------------------------------------
    always @(posedge slave_rx_valid) begin

        saw_rx_valid = 1'b1;

    end


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------
        rst_n          = 1'b0;
        start          = 1'b0;
        slave_sel      = 1'b0;

        master_tx_data = 8'h00;
        slave_tx_data  = 8'h00;

        saw_rx_valid   = 1'b0;


        // Hold Master reset active for 20 ns.
        #20;

        rst_n = 1'b1;

        // Wait after reset release.
        #20;


        // ========================================================
        // TRANSACTION 1
        //
        // Master -> Slave:
        //     Master sends 0xA5
        //
        // Slave -> Master:
        //     Slave returns 0x3C
        //
        // Expected:
        //     slave_rx_data  = 0xA5
        //     master_rx_data = 0x3C
        // ========================================================

        master_tx_data = 8'hA5;
        slave_tx_data  = 8'h3C;

        // We currently use CSB0 / Slave 0.
        slave_sel = 1'b0;


        // Generate a clean one-clock start pulse.
        //
        // The Master samples start on the rising edge of clk,
        // so the testbench changes start on falling edges.
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // --------------------------------------------------------
        // Check that the real Slave becomes selected.
        // --------------------------------------------------------
        wait (master_busy == 1'b1);

        // Wait until LOAD has driven the chip-select output.
        wait (csb_n[0] == 1'b0);

        #1;


        if (csb_n == 2'b10) begin

            $display(
                "PASS: Slave 0 selected correctly, CSB = %b",
                csb_n
            );

        end
        else begin

            $display(
                "FAIL: CSB = %b, expected 10",
                csb_n
            );

        end


        // The selected Slave should enable its MISO output.
        if (slave_miso_oe == 1'b1) begin

            $display(
                "PASS: Slave MISO output enable asserted"
            );

        end
        else begin

            $display(
                "FAIL: Slave MISO output enable was not asserted"
            );

        end


        // --------------------------------------------------------
        // Wait for complete SPI transaction
        // --------------------------------------------------------
        wait (master_done == 1'b1);

        // Allow all non-blocking assignments to settle.
        #1;


        // --------------------------------------------------------
        // Check Master -> Slave direction
        // --------------------------------------------------------
        if (slave_rx_data == 8'hA5) begin

            $display(
                "PASS: Slave received 0x%h from Master",
                slave_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Slave received 0x%h, expected 0xA5",
                slave_rx_data
            );

        end


        // --------------------------------------------------------
        // Check Slave -> Master direction
        // --------------------------------------------------------
        if (master_rx_data == 8'h3C) begin

            $display(
                "PASS: Master received 0x%h from Slave",
                master_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Master received 0x%h, expected 0x3C",
                master_rx_data
            );

        end


        // --------------------------------------------------------
        // Check rx_valid behavior
        // --------------------------------------------------------
        if (saw_rx_valid == 1'b1) begin

            $display(
                "PASS: Slave rx_valid was asserted after 8 bits"
            );

        end
        else begin

            $display(
                "FAIL: Slave rx_valid was never asserted"
            );

        end


        // --------------------------------------------------------
        // Wait for controller to return to idle
        // --------------------------------------------------------
        @(negedge clk);
        @(negedge clk);


        if (csb_n == 2'b11) begin

            $display(
                "PASS: CSB released after transaction"
            );

        end
        else begin

            $display(
                "FAIL: CSB did not return to idle, CSB = %b",
                csb_n
            );

        end


        if (sclk == 1'b0) begin

            $display(
                "PASS: SCLK returned to Mode 0 idle level"
            );

        end
        else begin

            $display(
                "FAIL: SCLK did not return to 0"
            );

        end


        if (slave_miso_oe == 1'b0) begin

            $display(
                "PASS: Slave released MISO after transaction"
            );

        end
        else begin

            $display(
                "FAIL: Slave MISO output enable remained active"
            );

        end


        $display(
            "=================================================="
        );

        $display(
            "SPI Slave RTL verification completed."
        );

        $display(
            "=================================================="
        );


        #50;

        $finish;

    end

endmodule