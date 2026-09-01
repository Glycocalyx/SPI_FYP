`timescale 1ns/1ps

module spi_two_slave_tb;

    // ============================================================
    // Verification Master signals
    // ============================================================

    logic       clk;
    logic       rst_n;

    logic       start;
    logic       slave_sel;

    logic [7:0] master_tx_data;
    logic [7:0] master_rx_data;

    logic       master_busy;
    logic       master_done;

    logic       sclk;
    logic       mosi;
    logic       miso;

    logic [1:0] csb_n;


    // ============================================================
    // Slave 0 signals
    // ============================================================

    logic [7:0] slave0_tx_data;
    logic [7:0] slave0_rx_data;

    logic       slave0_miso;
    logic       slave0_miso_oe;
    logic       slave0_rx_valid;

    logic       saw_slave0_rx_valid;


    // ============================================================
    // Slave 1 signals
    // ============================================================

    logic [7:0] slave1_tx_data;
    logic [7:0] slave1_rx_data;

    logic       slave1_miso;
    logic       slave1_miso_oe;
    logic       slave1_rx_valid;

    logic       saw_slave1_rx_valid;


    // ============================================================
    // Verification SPI Master
    //
    // This Master exists only for system-level verification.
    // It is not intended to be part of the final Slave tapeout.
    // ============================================================

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


    // ============================================================
    // Real SPI Slave 0
    //
    // This is the synthesizable Slave RTL.
    // ============================================================

    spi_slave u_slave0 (
        .sclk     (sclk),
        .csb_n    (csb_n[0]),
        .mosi     (mosi),

        .tx_data  (slave0_tx_data),

        .miso     (slave0_miso),
        .miso_oe  (slave0_miso_oe),

        .rx_data  (slave0_rx_data),
        .rx_valid (slave0_rx_valid)
    );


    // ============================================================
    // Real SPI Slave 1
    // ============================================================

    spi_slave u_slave1 (
        .sclk     (sclk),
        .csb_n    (csb_n[1]),
        .mosi     (mosi),

        .tx_data  (slave1_tx_data),

        .miso     (slave1_miso),
        .miso_oe  (slave1_miso_oe),

        .rx_data  (slave1_rx_data),
        .rx_valid (slave1_rx_valid)
    );


    // ============================================================
    // Shared MISO bus
    //
    // Only the selected Slave should drive MISO.
    //
    // miso_oe = 1:
    //     Slave is allowed to drive the bus.
    //
    // miso_oe = 0:
    //     Slave is disconnected from the shared MISO bus.
    // ============================================================

    always_comb begin

        if (slave0_miso_oe)
            miso = slave0_miso;

        else if (slave1_miso_oe)
            miso = slave1_miso;

        else
            miso = 1'b0;

    end


    // ============================================================
    // Verification Master system clock
    //
    // Period    = 10 ns
    // Frequency = 100 MHz
    // ============================================================

    initial begin

        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end

    end


    // ============================================================
    // Remember whether each Slave asserted rx_valid.
    //
    // rx_valid may disappear when CSB is released, so the
    // testbench records whether the pulse occurred.
    // ============================================================

    always @(posedge slave0_rx_valid) begin
        saw_slave0_rx_valid = 1'b1;
    end


    always @(posedge slave1_rx_valid) begin
        saw_slave1_rx_valid = 1'b1;
    end


    // ============================================================
    // Main test sequence
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial conditions
        // --------------------------------------------------------

        rst_n = 1'b0;

        start     = 1'b0;
        slave_sel = 1'b0;

        master_tx_data = 8'h00;

        slave0_tx_data = 8'h3C;
        slave1_tx_data = 8'hA7;

        saw_slave0_rx_valid = 1'b0;
        saw_slave1_rx_valid = 1'b0;


        // Reset the verification Master.
        #20;

        rst_n = 1'b1;

        #20;


        // ========================================================
        // TRANSACTION 1
        //
        // Select Slave 0.
        //
        // Master -> Slave 0:
        //     0xA5
        //
        // Slave 0 -> Master:
        //     0x3C
        //
        // Expected:
        //     CSB = 2'b10
        //     Slave0 RX = 0xA5
        //     Master RX = 0x3C
        // ========================================================

        $display(
            "=================================================="
        );

        $display(
            "Starting Transaction 1: Master <-> Slave 0"
        );


        master_tx_data = 8'hA5;
        slave_sel      = 1'b0;


        // Generate a clean start pulse.
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // Wait until Slave 0 is selected.
        wait (csb_n[0] == 1'b0);

        #1;


        // --------------------------------------------------------
        // Check chip select
        // --------------------------------------------------------

        if (csb_n == 2'b10) begin

            $display(
                "PASS: Transaction 1 selected Slave 0 correctly"
            );

        end
        else begin

            $display(
                "FAIL: Transaction 1 CSB = %b, expected 10",
                csb_n
            );

        end


        // --------------------------------------------------------
        // Check MISO output enable
        // --------------------------------------------------------

        if ((slave0_miso_oe == 1'b1) &&
            (slave1_miso_oe == 1'b0)) begin

            $display(
                "PASS: Only Slave 0 drives MISO"
            );

        end
        else begin

            $display(
                "FAIL: Wrong MISO OE state: Slave0=%b Slave1=%b",
                slave0_miso_oe,
                slave1_miso_oe
            );

        end


        // Wait for complete transaction.
        wait (master_done == 1'b1);

        #1;


        // --------------------------------------------------------
        // Check Master -> Slave 0
        // --------------------------------------------------------

        if (slave0_rx_data == 8'hA5) begin

            $display(
                "PASS: Slave 0 received 0x%h",
                slave0_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Slave 0 received 0x%h, expected 0xA5",
                slave0_rx_data
            );

        end


        // --------------------------------------------------------
        // Check Slave 0 -> Master
        // --------------------------------------------------------

        if (master_rx_data == 8'h3C) begin

            $display(
                "PASS: Master received 0x%h from Slave 0",
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
        // Check Slave 0 rx_valid
        // --------------------------------------------------------

        if (saw_slave0_rx_valid == 1'b1) begin

            $display(
                "PASS: Slave 0 rx_valid asserted"
            );

        end
        else begin

            $display(
                "FAIL: Slave 0 rx_valid was never asserted"
            );

        end


        // Allow the Master to return fully to IDLE.
        @(negedge clk);
        @(negedge clk);


        // ========================================================
        // TRANSACTION 2
        //
        // Select Slave 1.
        //
        // Master -> Slave 1:
        //     0x5A
        //
        // Slave 1 -> Master:
        //     0xA7
        //
        // Expected:
        //     CSB = 2'b01
        //     Slave1 RX = 0x5A
        //     Master RX = 0xA7
        // ========================================================

        $display(
            "=================================================="
        );

        $display(
            "Starting Transaction 2: Master <-> Slave 1"
        );


        master_tx_data = 8'h5A;
        slave_sel      = 1'b1;


        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // Wait until Slave 1 is selected.
        wait (csb_n[1] == 1'b0);

        #1;


        // --------------------------------------------------------
        // Check chip select
        // --------------------------------------------------------

        if (csb_n == 2'b01) begin

            $display(
                "PASS: Transaction 2 selected Slave 1 correctly"
            );

        end
        else begin

            $display(
                "FAIL: Transaction 2 CSB = %b, expected 01",
                csb_n
            );

        end


        // --------------------------------------------------------
        // Check MISO output enable
        // --------------------------------------------------------

        if ((slave0_miso_oe == 1'b0) &&
            (slave1_miso_oe == 1'b1)) begin

            $display(
                "PASS: Only Slave 1 drives MISO"
            );

        end
        else begin

            $display(
                "FAIL: Wrong MISO OE state: Slave0=%b Slave1=%b",
                slave0_miso_oe,
                slave1_miso_oe
            );

        end


        // Wait for complete transaction.
        wait (master_done == 1'b1);

        #1;


        // --------------------------------------------------------
        // Check Master -> Slave 1
        // --------------------------------------------------------

        if (slave1_rx_data == 8'h5A) begin

            $display(
                "PASS: Slave 1 received 0x%h",
                slave1_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Slave 1 received 0x%h, expected 0x5A",
                slave1_rx_data
            );

        end


        // --------------------------------------------------------
        // Check Slave 1 -> Master
        // --------------------------------------------------------

        if (master_rx_data == 8'hA7) begin

            $display(
                "PASS: Master received 0x%h from Slave 1",
                master_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Master received 0x%h, expected 0xA7",
                master_rx_data
            );

        end


        // --------------------------------------------------------
        // Check Slave 1 rx_valid
        // --------------------------------------------------------

        if (saw_slave1_rx_valid == 1'b1) begin

            $display(
                "PASS: Slave 1 rx_valid asserted"
            );

        end
        else begin

            $display(
                "FAIL: Slave 1 rx_valid was never asserted"
            );

        end


        // Allow everything to return to IDLE.
        @(negedge clk);
        @(negedge clk);


        // ========================================================
        // Final system checks
        // ========================================================

        $display(
            "=================================================="
        );


        if (csb_n == 2'b11) begin

            $display(
                "PASS: Both Slaves deselected in IDLE"
            );

        end
        else begin

            $display(
                "FAIL: CSB = %b in IDLE, expected 11",
                csb_n
            );

        end


        if ((slave0_miso_oe == 1'b0) &&
            (slave1_miso_oe == 1'b0)) begin

            $display(
                "PASS: Both Slaves released MISO in IDLE"
            );

        end
        else begin

            $display(
                "FAIL: MISO OE active while bus should be idle"
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


        // Slave 0 should retain the byte from Transaction 1.
        if (slave0_rx_data == 8'hA5) begin

            $display(
                "PASS: Slave 0 retained its received byte"
            );

        end
        else begin

            $display(
                "FAIL: Slave 0 data changed unexpectedly"
            );

        end


        // Slave 1 should retain the byte from Transaction 2.
        if (slave1_rx_data == 8'h5A) begin

            $display(
                "PASS: Slave 1 retained its received byte"
            );

        end
        else begin

            $display(
                "FAIL: Slave 1 data changed unexpectedly"
            );

        end


        $display(
            "=================================================="
        );

        $display(
            "1-Master / 2-Slave RTL verification completed."
        );

        $display(
            "=================================================="
        );


        #50;

        $finish;

    end

endmodule