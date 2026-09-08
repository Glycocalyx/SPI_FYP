`timescale 1ns/1ps

module spi_16bit_tb;

    // ============================================================
    // System signals
    // ============================================================

    logic clk;
    logic rst_n;


    // ============================================================
    // Master interface
    // ============================================================

    logic        start;
    logic        slave_sel;

    logic [15:0] master_tx_data;
    logic [15:0] master_rx_data;

    logic        master_busy;
    logic        master_done;

    logic        sclk;
    logic        mosi;
    logic        miso;

    logic [1:0]  csb_n;


    // ============================================================
    // Slave 0
    // ============================================================

    logic [15:0] slave0_tx_data;
    logic [15:0] slave0_rx_data;

    logic        slave0_miso;
    logic        slave0_miso_oe;
    logic        slave0_rx_valid;

    logic        saw_slave0_rx_valid;


    // ============================================================
    // Slave 1
    // ============================================================

    logic [15:0] slave1_tx_data;
    logic [15:0] slave1_rx_data;

    logic        slave1_miso;
    logic        slave1_miso_oe;
    logic        slave1_rx_valid;

    logic        saw_slave1_rx_valid;


    // ============================================================
    // SCLK edge counters
    // ============================================================

    integer sclk_rise_count;
    integer sclk_fall_count;

    integer error_count;


    // ============================================================
    // Verification Master
    //
    // DATA_WIDTH is intentionally not overridden here.
    // The default RTL configuration should now be 16 bit.
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
    // Slave 0
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
    // Slave 1
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
    // 100 MHz system clock
    // ============================================================

    initial begin

        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end

    end


    // ============================================================
    // Record rx_valid pulses
    // ============================================================

    always @(posedge slave0_rx_valid)
        saw_slave0_rx_valid = 1'b1;


    always @(posedge slave1_rx_valid)
        saw_slave1_rx_valid = 1'b1;


    // ============================================================
    // Count SCLK edges while a transaction is active
    // ============================================================

    always @(posedge sclk) begin

        if (csb_n != 2'b11)
            sclk_rise_count = sclk_rise_count + 1;

    end


    always @(negedge sclk) begin

        if (csb_n != 2'b11)
            sclk_fall_count = sclk_fall_count + 1;

    end


    // ============================================================
    // Transaction task
    // ============================================================

    task automatic run_transaction (
        input logic        sel,
        input logic [15:0] master_tx,
        input logic [15:0] slave_tx
    );

        begin

            // ----------------------------------------------------
            // Wait for idle
            // ----------------------------------------------------

            wait (
                (master_busy == 1'b0) &&
                (master_done == 1'b0) &&
                (csb_n == 2'b11)
            );


            // ----------------------------------------------------
            // Configure transaction
            // ----------------------------------------------------

            slave_sel      = sel;
            master_tx_data = master_tx;

            if (sel == 1'b0) begin

                slave0_tx_data       = slave_tx;
                saw_slave0_rx_valid  = 1'b0;

            end
            else begin

                slave1_tx_data       = slave_tx;
                saw_slave1_rx_valid  = 1'b0;

            end


            sclk_rise_count = 0;
            sclk_fall_count = 0;


            // ----------------------------------------------------
            // Start pulse
            // ----------------------------------------------------

            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;


            // ----------------------------------------------------
            // Wait for selected Slave
            // ----------------------------------------------------

            if (sel == 1'b0)
                wait (csb_n == 2'b10);

            else
                wait (csb_n == 2'b01);


            #1;


            // ----------------------------------------------------
            // Check MISO ownership
            // ----------------------------------------------------

            if (sel == 1'b0) begin

                if (
                    (slave0_miso_oe == 1'b1) &&
                    (slave1_miso_oe == 1'b0)
                )
                    $display(
                        "PASS: Only Slave 0 drives MISO"
                    );

                else begin

                    $display(
                        "FAIL: Incorrect MISO ownership for Slave 0"
                    );

                    error_count = error_count + 1;

                end

            end
            else begin

                if (
                    (slave0_miso_oe == 1'b0) &&
                    (slave1_miso_oe == 1'b1)
                )
                    $display(
                        "PASS: Only Slave 1 drives MISO"
                    );

                else begin

                    $display(
                        "FAIL: Incorrect MISO ownership for Slave 1"
                    );

                    error_count = error_count + 1;

                end

            end


            // ----------------------------------------------------
            // Wait for completion
            // ----------------------------------------------------

            wait (master_done == 1'b1);

            #1;


            // ----------------------------------------------------
            // Check Master RX
            // ----------------------------------------------------

            if (master_rx_data == slave_tx) begin

                $display(
                    "PASS: Master received 0x%h",
                    master_rx_data
                );

            end
            else begin

                $display(
                    "FAIL: Master received 0x%h, expected 0x%h",
                    master_rx_data,
                    slave_tx
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Check Slave RX
            // ----------------------------------------------------

            if (sel == 1'b0) begin

                if (slave0_rx_data == master_tx) begin

                    $display(
                        "PASS: Slave 0 received 0x%h",
                        slave0_rx_data
                    );

                end
                else begin

                    $display(
                        "FAIL: Slave 0 received 0x%h, expected 0x%h",
                        slave0_rx_data,
                        master_tx
                    );

                    error_count = error_count + 1;

                end


                if (saw_slave0_rx_valid)
                    $display(
                        "PASS: Slave 0 rx_valid asserted"
                    );

                else begin

                    $display(
                        "FAIL: Slave 0 rx_valid not detected"
                    );

                    error_count = error_count + 1;

                end

            end
            else begin

                if (slave1_rx_data == master_tx) begin

                    $display(
                        "PASS: Slave 1 received 0x%h",
                        slave1_rx_data
                    );

                end
                else begin

                    $display(
                        "FAIL: Slave 1 received 0x%h, expected 0x%h",
                        slave1_rx_data,
                        master_tx
                    );

                    error_count = error_count + 1;

                end


                if (saw_slave1_rx_valid)
                    $display(
                        "PASS: Slave 1 rx_valid asserted"
                    );

                else begin

                    $display(
                        "FAIL: Slave 1 rx_valid not detected"
                    );

                    error_count = error_count + 1;

                end

            end


            // ----------------------------------------------------
            // 16-bit transaction must contain exactly:
            //
            // 16 rising edges
            // 16 falling edges
            // ----------------------------------------------------

            if (sclk_rise_count == 16)
                $display(
                    "PASS: Exactly 16 SCLK rising edges"
                );

            else begin

                $display(
                    "FAIL: %0d SCLK rising edges, expected 16",
                    sclk_rise_count
                );

                error_count = error_count + 1;

            end


            if (sclk_fall_count == 16)
                $display(
                    "PASS: Exactly 16 SCLK falling edges"
                );

            else begin

                $display(
                    "FAIL: %0d SCLK falling edges, expected 16",
                    sclk_fall_count
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Wait for complete return to IDLE
            // ----------------------------------------------------

            wait (master_done == 1'b0);
            wait (csb_n == 2'b11);

            @(negedge clk);


            if (sclk !== 1'b0) begin

                $display(
                    "FAIL: SCLK did not return to Mode 0 idle"
                );

                error_count = error_count + 1;

            end

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================

    initial begin

        rst_n = 1'b0;

        start     = 1'b0;
        slave_sel = 1'b0;

        master_tx_data = 16'h0000;

        slave0_tx_data = 16'h0000;
        slave1_tx_data = 16'h0000;

        saw_slave0_rx_valid = 1'b0;
        saw_slave1_rx_valid = 1'b0;

        sclk_rise_count = 0;
        sclk_fall_count = 0;

        error_count = 0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #20;

        rst_n = 1'b1;

        #20;


        // ========================================================
        // Transaction 1
        //
        // Master <-> Slave 0
        // ========================================================

        $display(
            "=================================================="
        );

        $display(
            "16-bit Transaction 1: Slave 0"
        );

        run_transaction(
            1'b0,
            16'hA55A,
            16'h3CC3
        );


        // ========================================================
        // Transaction 2
        //
        // Master <-> Slave 1
        // ========================================================

        $display(
            "=================================================="
        );

        $display(
            "16-bit Transaction 2: Slave 1"
        );

        run_transaction(
            1'b1,
            16'h5AA5,
            16'hC33C
        );


        // ========================================================
        // Final result
        // ========================================================

        $display(
            "=================================================="
        );


        if (error_count == 0) begin

            $display(
                "16-BIT SPI TEST PASS"
            );

        end
        else begin

            $display(
                "16-BIT SPI TEST FAIL: %0d error(s)",
                error_count
            );

        end


        $display(
            "=================================================="
        );


        #50;

        $finish;

    end

endmodule