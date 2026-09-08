`timescale 1ns/1ps

module spi_regression_tb;

    // ============================================================
    // Test configuration
    // ============================================================

    localparam integer DATA_WIDTH = 16;


    // ============================================================
    // Master signals
    // ============================================================

    logic       clk;
    logic       rst_n;

    logic       start;
    logic       slave_sel;

    logic [DATA_WIDTH-1:0] master_tx_data;
    logic [DATA_WIDTH-1:0] master_rx_data;

    logic       master_busy;
    logic       master_done;

    logic       sclk;
    logic       mosi;
    logic       miso;

    logic [1:0] csb_n;


    // ============================================================
    // Slave 0 signals
    // ============================================================

    logic [DATA_WIDTH-1:0] slave0_tx_data;
    logic [DATA_WIDTH-1:0] slave0_rx_data;

    logic       slave0_miso;
    logic       slave0_miso_oe;
    logic       slave0_rx_valid;

    logic       saw_slave0_rx_valid;


    // ============================================================
    // Slave 1 signals
    // ============================================================

    logic [DATA_WIDTH-1:0] slave1_tx_data;
    logic [DATA_WIDTH-1:0] slave1_rx_data;

    logic       slave1_miso;
    logic       slave1_miso_oe;
    logic       slave1_rx_valid;

    logic       saw_slave1_rx_valid;


    // ============================================================
    // Regression monitor signals
    // ============================================================

    logic       monitor_active;

    logic [DATA_WIDTH-1:0] expected_mosi_word;
    logic [DATA_WIDTH-1:0] expected_miso_word;

    integer bit_index;

    integer sclk_rise_count;
    integer sclk_fall_count;

    integer error_count;
    integer transaction_count;


    // ============================================================
    // Verification Master
    // ============================================================

    spi_master #(
        .CLK_DIV    (4),
        .DATA_WIDTH (DATA_WIDTH)
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
    // Synthesizable Slave 0
    // ============================================================

    spi_slave #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_slave0 (
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
    // Synthesizable Slave 1
    // ============================================================

    spi_slave #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_slave1 (
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
    // Verification system clock
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
    //
    // rising edge = sampling edge
    //
    // Check:
    //
    // 1. MOSI is MSB first
    // 2. MISO is MSB first
    // 3. correct number of rising edges
    // ============================================================

    always @(posedge sclk) begin

        if (monitor_active) begin

            sclk_rise_count = sclk_rise_count + 1;


            if (bit_index < DATA_WIDTH) begin

                // ------------------------------------------------
                // Check MOSI bit
                // ------------------------------------------------

                if (
                    mosi !==
                    expected_mosi_word[
                        DATA_WIDTH-1-bit_index
                    ]
                ) begin

                    $display(
                        "FAIL: MOSI bit %0d = %b, expected %b",
                        bit_index,
                        mosi,
                        expected_mosi_word[
                            DATA_WIDTH-1-bit_index
                        ]
                    );

                    error_count = error_count + 1;

                end


                // ------------------------------------------------
                // Check MISO bit
                // ------------------------------------------------

                if (
                    miso !==
                    expected_miso_word[
                        DATA_WIDTH-1-bit_index
                    ]
                ) begin

                    $display(
                        "FAIL: MISO bit %0d = %b, expected %b",
                        bit_index,
                        miso,
                        expected_miso_word[
                            DATA_WIDTH-1-bit_index
                        ]
                    );

                    error_count = error_count + 1;

                end


                bit_index = bit_index + 1;

            end

        end

    end


    // ============================================================
    // Count falling edges
    // ============================================================

    always @(negedge sclk) begin

        if (monitor_active)
            sclk_fall_count = sclk_fall_count + 1;

    end


    // ============================================================
    // Continuous MISO ownership check
    //
    // During a transaction, both Slaves must never drive
    // the shared MISO bus at the same time.
    // ============================================================

    always @(*) begin

        if (
            monitor_active &&
            slave0_miso_oe &&
            slave1_miso_oe
        ) begin

            $display(
                "FAIL: MISO bus contention detected"
            );

        end

    end


    // ============================================================
    // Generic SPI transaction task
    // ============================================================

    task automatic run_transaction (
        input logic                  sel,
        input logic [DATA_WIDTH-1:0] master_tx,
        input logic [DATA_WIDTH-1:0] slave_tx,
        input integer                test_id
    );

        begin

            transaction_count =
                transaction_count + 1;


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
            // Configure transaction
            // ----------------------------------------------------

            slave_sel      = sel;
            master_tx_data = master_tx;


            if (sel == 1'b0)
                slave0_tx_data = slave_tx;

            else
                slave1_tx_data = slave_tx;


            // ----------------------------------------------------
            // Prepare independent monitor
            // ----------------------------------------------------

            expected_mosi_word = master_tx;
            expected_miso_word = slave_tx;

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
            // Check CSB
            // ----------------------------------------------------

            if (
                ((sel == 1'b0) &&
                 (csb_n == 2'b10))
                ||
                ((sel == 1'b1) &&
                 (csb_n == 2'b01))
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

                error_count =
                    error_count + 1;

            end


            // ----------------------------------------------------
            // Check MISO output-enable ownership
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

                    error_count =
                        error_count + 1;

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

                    error_count =
                        error_count + 1;

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

                error_count =
                    error_count + 1;

            end


            // ----------------------------------------------------
            // Check selected Slave RX
            // ----------------------------------------------------

            if (sel == 1'b0) begin

                if (
                    slave0_rx_data == master_tx
                ) begin

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

                    error_count =
                        error_count + 1;

                end

            end
            else begin

                if (
                    slave1_rx_data == master_tx
                ) begin

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

                    error_count =
                        error_count + 1;

                end

            end


            // ----------------------------------------------------
            // Check rx_valid
            // ----------------------------------------------------

            if (
                ((sel == 1'b0) &&
                 (saw_slave0_rx_valid == 1'b1))
                ||
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

                error_count =
                    error_count + 1;

            end


            // ----------------------------------------------------
            // Check exact SCLK edge count
            // ----------------------------------------------------

            if (
                sclk_rise_count == DATA_WIDTH
            ) begin

                $display(
                    "PASS: Exactly %0d SCLK rising edges",
                    DATA_WIDTH
                );

            end
            else begin

                $display(
                    "FAIL: SCLK rising edges = %0d, expected %0d",
                    sclk_rise_count,
                    DATA_WIDTH
                );

                error_count =
                    error_count + 1;

            end


            if (
                sclk_fall_count == DATA_WIDTH
            ) begin

                $display(
                    "PASS: Exactly %0d SCLK falling edges",
                    DATA_WIDTH
                );

            end
            else begin

                $display(
                    "FAIL: SCLK falling edges = %0d, expected %0d",
                    sclk_fall_count,
                    DATA_WIDTH
                );

                error_count =
                    error_count + 1;

            end


            // ----------------------------------------------------
            // Wait for complete return to IDLE
            // ----------------------------------------------------

            wait (master_done == 1'b0);

            wait (csb_n == 2'b11);


            @(negedge clk);


            // ----------------------------------------------------
            // Final idle checks
            // ----------------------------------------------------

            if (sclk !== 1'b0) begin

                $display(
                    "FAIL: SCLK did not return to Mode 0 idle"
                );

                error_count =
                    error_count + 1;

            end


            if (
                (slave0_miso_oe !== 1'b0) ||
                (slave1_miso_oe !== 1'b0)
            ) begin

                $display(
                    "FAIL: A Slave is still driving MISO in IDLE"
                );

                error_count =
                    error_count + 1;

            end


            if (csb_n !== 2'b11) begin

                $display(
                    "FAIL: CSB did not return to idle"
                );

                error_count =
                    error_count + 1;

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

        master_tx_data = '0;

        slave0_tx_data = '0;
        slave1_tx_data = '0;

        saw_slave0_rx_valid = 1'b0;
        saw_slave1_rx_valid = 1'b0;

        monitor_active = 1'b0;

        expected_mosi_word = '0;
        expected_miso_word = '0;

        bit_index = 0;

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
        // Extreme patterns:
        // Master all zeros
        // Slave all ones
        // ========================================================

        run_transaction(
            1'b0,
            16'h0000,
            16'hFFFF,
            1
        );


        // ========================================================
        // TEST 2
        //
        // Same Slave again.
        // Reverse extreme pattern.
        // ========================================================

        run_transaction(
            1'b0,
            16'hFFFF,
            16'h0000,
            2
        );


        // ========================================================
        // TEST 3
        //
        // Switch to Slave 1.
        // Alternating pattern.
        // ========================================================

        run_transaction(
            1'b1,
            16'hA55A,
            16'h3CC3,
            3
        );


        // ========================================================
        // TEST 4
        //
        // Switch back to Slave 0.
        // ========================================================

        run_transaction(
            1'b0,
            16'h5AA5,
            16'hC33C,
            4
        );


        // ========================================================
        // TEST 5
        //
        // Non-symmetric pattern for bit-order checking.
        // ========================================================

        run_transaction(
            1'b1,
            16'h96C3,
            16'h691E,
            5
        );


        // ========================================================
        // TEST 6
        //
        // First / last bit and sparse transitions.
        // ========================================================

        run_transaction(
            1'b1,
            16'h8001,
            16'h1809,
            6
        );


        // ========================================================
        // TEST 7
        //
        // Switch back again to verify repeated Slave switching.
        // ========================================================

        run_transaction(
            1'b0,
            16'h7FFE,
            16'hE187,
            7
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
                "16-BIT REGRESSION PASS: all SPI tests passed"
            );

        end
        else begin

            $display(
                "16-BIT REGRESSION FAIL: %0d error(s) detected",
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