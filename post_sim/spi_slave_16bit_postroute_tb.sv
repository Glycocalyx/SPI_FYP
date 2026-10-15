`timescale 1ns/1ps

module spi_slave_16bit_postroute_tb;

    // ============================================================
    // Verification Master signals
    // ============================================================

    logic        clk;
    logic        rst_n;
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
    // SPI Slave signals
    // ============================================================

    logic [15:0] slave_tx_data;
    logic [15:0] slave_rx_data;

    logic        miso_oe;
    logic        slave_rx_valid;

    logic        saw_rx_valid;

    integer      sclk_rise_count;


    // ============================================================
    // Verification Master
    //
    // Master reference clock = 200 MHz
    // CLK_DIV = 1
    //
    // SCLK toggles every CLK_DIV master-clock cycles:
    //
    //     f_SCLK = f_clk / (2 * CLK_DIV)
    //
    //            = 200 MHz / 2
    //            = 100 MHz
    //
    // Therefore SPI SCLK period = 10 ns.
    // ============================================================

    spi_master #(
        .CLK_DIV(1)
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
    // Post-route SPI Slave DUT
    //
    // IMPORTANT:
    // The module spi_slave is supplied by:
    //
    // ../syn/outputs/spi_slave_core_postroute.v
    //
    // Do NOT compile rtl/spi_slave.sv together with this test,
    // because both files define module spi_slave.
    // ============================================================

    spi_slave u_slave (
        .sclk     (sclk),
        .csb_n    (csb_n[0]),
        .mosi     (mosi),

        .tx_data  (slave_tx_data),

        .miso     (miso),
        .miso_oe  (miso_oe),

        .rx_data  (slave_rx_data),
        .rx_valid (slave_rx_valid)
    );


    // ============================================================
    // Post-route SDF back-annotation
    //
    // Innovus-generated post-route SDF:
    //
    // ../syn/outputs/spi_slave_core_postroute.sdf
    //
    // The SDF is annotated onto DUT instance u_slave.
    //
    // MAXIMUM selects the maximum value from the SDF
    // min/typ/max delay tuple.
    // ============================================================

    initial begin
        $sdf_annotate(
            "../syn/outputs/spi_slave_core_postroute.sdf",
            u_slave,
            ,
            "sdf_annotate.log",
            "MAXIMUM"
        );
    end


    // ============================================================
    // 200 MHz verification-master clock
    //
    // Period = 5 ns
    // Half-period = 2.5 ns
    //
    // Together with CLK_DIV = 1:
    //
    // SPI SCLK = 100 MHz
    // ============================================================

    initial begin
        clk = 1'b0;

        forever begin
            #2.5 clk = ~clk;
        end
    end


    // ============================================================
    // Record the Slave rx_valid pulse
    // ============================================================

    always @(posedge slave_rx_valid) begin
        saw_rx_valid = 1'b1;
    end


    // ============================================================
    // Count rising SCLK edges during the selected transaction
    //
    // A correct 16-bit SPI transfer should contain exactly
    // 16 rising SCLK edges while CSB is low.
    // ============================================================

    always @(posedge sclk) begin
        if (csb_n[0] === 1'b0) begin
            sclk_rise_count = sclk_rise_count + 1;
        end
    end


    // ============================================================
    // Main verification
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------

        rst_n = 1'b0;

        start = 1'b0;

        // Select Slave 0 from the verification Master.
        //
        // For the Master's two-CSB interface:
        //
        // slave_sel = 0  -> csb_n = 2'b10
        //
        // Therefore csb_n[0] selects our DUT.
        slave_sel = 1'b0;

        master_tx_data = 16'hA5A5;
        slave_tx_data  = 16'h3C3C;

        saw_rx_valid   = 1'b0;
        sclk_rise_count = 0;


        // --------------------------------------------------------
        // Reset verification Master
        // --------------------------------------------------------

        #20;

        rst_n = 1'b1;

        #20;


        // --------------------------------------------------------
        // Start one 16-bit full-duplex SPI transaction
        //
        // Master -> Slave : A5A5
        // Slave  -> Master: 3C3C
        // --------------------------------------------------------

        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // --------------------------------------------------------
        // Wait until Slave is selected
        // --------------------------------------------------------

        wait (csb_n[0] === 1'b0);

        #1;


        // --------------------------------------------------------
        // Check CSB selection
        // --------------------------------------------------------

        if (csb_n === 2'b10) begin

            $display(
                "PASS: Slave selected correctly"
            );

        end
        else begin

            $display(
                "FAIL: Incorrect CSB selection: csb_n = %b",
                csb_n
            );

        end


        // --------------------------------------------------------
        // Check MISO output enable
        // --------------------------------------------------------

        if (miso_oe === 1'b1) begin

            $display(
                "PASS: MISO OE enabled"
            );

        end
        else begin

            $display(
                "FAIL: MISO OE not enabled"
            );

        end


        // --------------------------------------------------------
        // Wait until Master reports transaction complete
        // --------------------------------------------------------

        wait (master_done === 1'b1);

        #1;


        // --------------------------------------------------------
        // Check Master -> Slave data
        // --------------------------------------------------------

        if (slave_rx_data === 16'hA5A5) begin

            $display(
                "PASS: Slave received %h",
                slave_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Slave received %h, expected A5A5",
                slave_rx_data
            );

        end


        // --------------------------------------------------------
        // Check Slave -> Master data
        // --------------------------------------------------------

        if (master_rx_data === 16'h3C3C) begin

            $display(
                "PASS: Master received %h",
                master_rx_data
            );

        end
        else begin

            $display(
                "FAIL: Master received %h, expected 3C3C",
                master_rx_data
            );

        end


        // --------------------------------------------------------
        // Check rx_valid and number of transferred bits
        // --------------------------------------------------------

        if (
            (saw_rx_valid === 1'b1) &&
            (sclk_rise_count == 16)
        ) begin

            $display(
                "PASS: rx_valid asserted after 16 bits"
            );

        end
        else begin

            $display(
                "FAIL: rx_valid/bit-count error: rx_valid=%b, rising_edges=%0d",
                saw_rx_valid,
                sclk_rise_count
            );

        end


        // --------------------------------------------------------
        // Wait for Master to completely return to IDLE
        // --------------------------------------------------------

        wait (master_done === 1'b0);

        wait (csb_n === 2'b11);

        #1;


        // --------------------------------------------------------
        // Check CSB release
        // --------------------------------------------------------

        if (csb_n === 2'b11) begin

            $display(
                "PASS: CSB released"
            );

        end
        else begin

            $display(
                "FAIL: CSB not released: csb_n=%b",
                csb_n
            );

        end


        // --------------------------------------------------------
        // Mode-0 idle state:
        //
        // CPOL = 0
        // Therefore SCLK must return low after the transaction.
        // --------------------------------------------------------

        if (sclk === 1'b0) begin

            $display(
                "PASS: SCLK idle low"
            );

        end
        else begin

            $display(
                "FAIL: SCLK not idle low"
            );

        end


        // --------------------------------------------------------
        // Slave must release MISO when deselected
        // --------------------------------------------------------

        if (miso_oe === 1'b0) begin

            $display(
                "PASS: MISO released"
            );

        end
        else begin

            $display(
                "FAIL: MISO still enabled after CSB release"
            );

        end


        // --------------------------------------------------------
        // End of verification
        // --------------------------------------------------------

        $display(
            "=================================================="
        );

        $display(
            "16-bit SPI Slave verification completed."
        );

        $display(
            "=================================================="
        );


        #50;

        $finish;

    end

endmodule
