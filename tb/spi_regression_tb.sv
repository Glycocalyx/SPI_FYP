`timescale 1ns/1ps

module spi_regression_tb;

    // ============================================================
    // Master signals
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
    // Regression monitor signals
    // ============================================================

    logic       monitor_active;

    logic [7:0] expected_mosi_byte;
    logic [7:0] expected_miso_byte;

    integer bit_index;
    integer sclk_rise_count;
    integer sclk_fall_count;

    integer error_count;
    integer transaction_count;


    // ============================================================
    // Verification Master
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
    // Real synthesizable Slave 0
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
    // Real synthesizable Slave 1
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
    // Verification Master system clock
    //
    // 100 MHz
    // ============================================================

    initial begin

        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end

    end


    // ============================================================
    // Remember rx_valid pulses
    // ============================================================

    always @(posedge slave0_rx_valid) begin
        saw_slave0_rx_valid = 1'b1;
    end


    always @(posedge slave1_rx_valid) begin
        saw_slave1_rx_valid = 1'b1;
    end


    // ============================================================
    // SPI bit-level monitor
    //
    // Mode 0:
    // rising edge = sample edge
    //
    // This monitor independently checks:
    //
    // 1. MOSI is MSB first
    // 2. MISO is MSB first
    // 3. exactly 8 rising edges occur
    // ============================================================

    always @(posedge sclk) begin

        if (monitor_active) begin

            sclk_rise_count = sclk_rise_count + 1;

            if (bit_index < 8) begin

                // ------------------------------------------------
                // Check MOSI bit order
                // ------------------------------------------------

                if (mosi !== expected_mosi_byte[7-bit_index]) begin

                    $display(
                        "FAIL: MOSI bit %0d = %b, expected %b",
                        bit_index,
                        mosi,
                        expected_mosi_byte[7-bit_index]
                    );

                    error_count = error_count + 1;

                end


                // ------------------------------------------------
                // Check MISO bit order
                // ------------------------------------------------

                if (miso !== expected_miso_byte[7-bit_index]) begin

                    $display(
                        "FAIL: MISO bit %0d = %b, expected %b",
                        bit_index,
                        miso,
                        expected_miso_byte[7-bit_index]
                    );

                    error_count = error_count + 1;

                end


                bit_index = bit_index + 1;

            end

        end

    end


    // ============================================================
    // Count SCLK falling edges
    // ============================================================

    always @(negedge sclk) begin

        if (monitor_active)
            sclk_fall_count = sclk_fall_count + 1;

    end


    // ============================================================
    // Generic SPI transaction task
    //
    // sel       = selected Slave
    // master_tx = byte sent by Master
    // slave_tx  = byte returned by selected Slave
    // test_id   = transaction number
    // ============================================================

    task automatic run_transaction (
        input logic       sel,
        input logic [7:0] master_tx,
        input logic [7:0] slave_tx,
        input integer     test_id
    );

        begin

            transaction_count = transaction_count + 1;

            $display(
                "=================================================="
            );

            $display(
                "Transaction %0d: Slave=%0d MasterTX=0x%h SlaveTX=0x%h",
                test_id,
                sel,
                master_tx,
                slave_tx
            );


            // ----------------------------------------------------
            // Wait until Master is fully idle
            // ----------------------------------------------------

            wait (
                (master_busy == 1'b0) &&
                (master_done == 1'b0) &&
                (csb_n == 2'b11)
            );


            // ----------------------------------------------------
            // Configure this transaction
            // ----------------------------------------------------

            slave_sel      = sel;
            master_tx_data = master_tx;

            if (sel == 1'b0)
                slave0_tx_data = slave_tx;
            else
                slave1_tx_data = slave_tx;


            // ----------------------------------------------------
            // Prepare independent bit-level monitor
            // ----------------------------------------------------

            expected_mosi_byte = master_tx;
            expected_miso_byte = slave_tx;

            bit_index       = 0;
            sclk_rise_count = 0;
            sclk_fall_count = 0;

            if (sel == 1'b0)
                saw_slave0_rx_valid = 1'b0;
            else
                saw_slave1_rx_valid = 1'b0;


            monitor_active = 1'b1;


            // ----------------------------------------------------
            // Generate clean start pulse
            // ----------------------------------------------------

            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;


            // ----------------------------------------------------
            // Wait until selected Slave becomes active
            // ----------------------------------------------------

            if (sel == 1'b0)
                wait (csb_n[0] == 1'b0);
            else
                wait (csb_n[1] == 1'b0);

            #1;


            // ----------------------------------------------------
            // Check chip-select
            // ----------------------------------------------------

            if (
                ((sel == 1'b0) && (csb_n == 2'b10)) ||
                ((sel == 1'b1) && (csb_n == 2'b01))
            ) begin

                $display(
                    "PASS: Correct Slave selected, CSB=%b",
                    csb_n
                );

            end
            else begin

                $display(
                    "FAIL: Incorrect CSB=%b",
                    csb_n
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Check MISO output enable exclusivity
            // ----------------------------------------------------

            if (sel == 1'b0) begin

                if (
                    (slave0_miso_oe == 1'b1) &&
                    (slave1_miso_oe == 1'b0)
                ) begin

                    $display(
                        "PASS: Only Slave 0 drives MISO"
                    );

                end
                else begin

                    $display(
                        "FAIL: Wrong MISO OE state"
                    );

                    error_count = error_count + 1;

                end

            end
            else begin

                if (
                    (slave0_miso_oe == 1'b0) &&
                    (slave1_miso_oe == 1'b1)
                ) begin

                    $display(
                        "PASS: Only Slave 1 drives MISO"
                    );

                end
                else begin

                    $display(
                        "FAIL: Wrong MISO OE state"
                    );

                    error_count = error_count + 1;

                end

            end


            // ----------------------------------------------------
            // Wait for full transaction
            // ----------------------------------------------------

            wait (master_done == 1'b1);

            #1;

            monitor_active = 1'b0;


            // ----------------------------------------------------
            // Check Master RX
            // ----------------------------------------------------

            if (master_rx_data == slave_tx) begin

                $display(
                    "PASS: Master RX = 0x%h",
                    master_rx_data
                );

            end
            else begin

                $display(
                    "FAIL: Master RX = 0x%h, expected 0x%h",
                    master_rx_data,
                    slave_tx
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Check selected Slave RX
            // ----------------------------------------------------

            if (sel == 1'b0) begin

                if (slave0_rx_data == master_tx) begin

                    $display(
                        "PASS: Slave 0 RX = 0x%h",
                        slave0_rx_data
                    );

                end
                else begin

                    $display(
                        "FAIL: Slave 0 RX = 0x%h, expected 0x%h",
                        slave0_rx_data,
                        master_tx
                    );

                    error_count = error_count + 1;

                end

            end
            else begin

                if (slave1_rx_data == master_tx) begin

                    $display(
                        "PASS: Slave 1 RX = 0x%h",
                        slave1_rx_data
                    );

                end
                else begin

                    $display(
                        "FAIL: Slave 1 RX = 0x%h, expected 0x%h",
                        slave1_rx_data,
                        master_tx
                    );

                    error_count = error_count + 1;

                end

            end


            // ----------------------------------------------------
            // Check rx_valid
            // ----------------------------------------------------

            if (
                ((sel == 1'b0) &&
                 (saw_slave0_rx_valid == 1'b1)) ||

                ((sel == 1'b1) &&
                 (saw_slave1_rx_valid == 1'b1))
            ) begin

                $display(
                    "PASS: Selected Slave asserted rx_valid"
                );

            end
            else begin

                $display(
                    "FAIL: Selected Slave did not assert rx_valid"
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Check exact number of SPI clock edges
            //
            // 8-bit SPI transaction:
            // 8 rising edges
            // 8 falling edges
            // ----------------------------------------------------

            if (sclk_rise_count == 8) begin

                $display(
                    "PASS: Exactly 8 SCLK rising edges"
                );

            end
            else begin

                $display(
                    "FAIL: SCLK rising edges = %0d, expected 8",
                    sclk_rise_count
                );

                error_count = error_count + 1;

            end


            if (sclk_fall_count == 8) begin

                $display(
                    "PASS: Exactly 8 SCLK falling edges"
                );

            end
            else begin

                $display(
                    "FAIL: SCLK falling edges = %0d, expected 8",
                    sclk_fall_count
                );

                error_count = error_count + 1;

            end


            // ----------------------------------------------------
            // Wait for Master to return to IDLE
            // ----------------------------------------------------

            wait (master_done == 1'b0);
            wait (csb_n == 2'b11);

            @(negedge clk);


            // ----------------------------------------------------
            // Final bus idle checks
            // ----------------------------------------------------

            if (sclk !== 1'b0) begin

                $display(
                    "FAIL: SCLK did not return to Mode 0 idle"
                );

                error_count = error_count + 1;

            end


            if (
                (slave0_miso_oe !== 1'b0) ||
                (slave1_miso_oe !== 1'b0)
            ) begin

                $display(
                    "FAIL: A Slave is still driving MISO in IDLE"
                );

                error_count = error_count + 1;

            end


            $display(
                "Transaction %0d completed",
                test_id
            );

        end

    endtask


    // ============================================================
    // Main regression sequence
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------

        rst_n = 1'b0;

        start     = 1'b0;
        slave_sel = 1'b0;

        master_tx_data = 8'h00;

        slave0_tx_data = 8'h00;
        slave1_tx_data = 8'h00;

        saw_slave0_rx_valid = 1'b0;
        saw_slave1_rx_valid = 1'b0;

        monitor_active = 1'b0;

        expected_mosi_byte = 8'h00;
        expected_miso_byte = 8'h00;

        bit_index       = 0;
        sclk_rise_count = 0;
        sclk_fall_count = 0;

        error_count       = 0;
        transaction_count = 0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #20;

        rst_n = 1'b1;

        #20;


        // ========================================================
        // TEST 1
        //
        // All-zero Master TX
        // All-one Slave TX
        // ========================================================

        run_transaction(
            1'b0,
            8'h00,
            8'hFF,
            1
        );


        // ========================================================
        // TEST 2
        //
        // Same Slave immediately used again.
        //
        // All-one Master TX
        // All-zero Slave TX
        // ========================================================

        run_transaction(
            1'b0,
            8'hFF,
            8'h00,
            2
        );


        // ========================================================
        // TEST 3
        //
        // Switch to Slave 1.
        // Alternating bit pattern.
        // ========================================================

        run_transaction(
            1'b1,
            8'hA5,
            8'h3C,
            3
        );


        // ========================================================
        // TEST 4
        //
        // Switch back to Slave 0.
        // Opposite alternating pattern.
        // ========================================================

        run_transaction(
            1'b0,
            8'h5A,
            8'hA7,
            4
        );


        // ========================================================
        // TEST 5
        //
        // Switch to Slave 1.
        // Non-symmetric bit pattern.
        //
        // Useful for detecting bit-order mistakes.
        // ========================================================

        run_transaction(
            1'b1,
            8'h96,
            8'h69,
            5
        );


        // ========================================================
        // TEST 6
        //
        // Same Slave 1 again.
        // Another non-symmetric pattern.
        // ========================================================

        run_transaction(
            1'b1,
            8'h81,
            8'h18,
            6
        );


        // ========================================================
        // Final regression result
        // ========================================================

        $display(
            "=================================================="
        );

        $display(
            "Regression completed: %0d transactions",
            transaction_count
        );


        if (error_count == 0) begin

            $display(
                "REGRESSION PASS: all SPI tests passed"
            );

        end
        else begin

            $display(
                "REGRESSION FAIL: %0d error(s) detected",
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