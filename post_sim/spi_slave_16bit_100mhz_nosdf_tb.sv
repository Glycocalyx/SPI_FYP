`timescale 1ns/1ps

module spi_slave_16bit_tb;

    logic clk;
    logic rst_n;

    logic start;
    logic slave_sel;

    logic [15:0] master_tx_data;
    logic [15:0] master_rx_data;

    logic master_busy;
    logic master_done;

    logic sclk;
    logic mosi;
    logic miso;

    logic [1:0] csb_n;


    logic [15:0] slave_tx_data;
    logic [15:0] slave_rx_data;

    logic slave_rx_valid;
    logic slave_miso_oe;

    logic saw_rx_valid;


    // ------------------------------------------------------------
    // SPI Master
    // ------------------------------------------------------------
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


    // ------------------------------------------------------------
    // SPI Slave DUT
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
    // 100 MHz system clock
    // ------------------------------------------------------------
    initial begin
        clk = 1'b0;

        forever begin
            #2.5 clk = ~clk;
        end
    end


    always @(posedge slave_rx_valid) begin
        saw_rx_valid = 1'b1;
    end


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        rst_n          = 1'b0;
        start          = 1'b0;
        slave_sel      = 1'b0;

        master_tx_data = 16'h0000;
        slave_tx_data  = 16'h0000;

        saw_rx_valid   = 1'b0;


        #20;
        rst_n = 1'b1;

        #20;


        // ========================================================
        // Transaction
        //
        // Master -> Slave:
        //      16'hA5A5
        //
        // Slave -> Master:
        //      16'h3C3C
        // ========================================================

        master_tx_data = 16'hA5A5;
        slave_tx_data  = 16'h3C3C;


        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        wait(master_busy == 1'b1);

        wait(csb_n[0] == 1'b0);

        #1;


        if(csb_n == 2'b10)
            $display("PASS: Slave selected correctly");
        else
            $display("FAIL: CSB error %b", csb_n);



        if(slave_miso_oe == 1'b1)
            $display("PASS: MISO OE enabled");
        else
            $display("FAIL: MISO OE not enabled");



        wait(master_done == 1'b1);

        #1;



        if(slave_rx_data == 16'hA5A5)
            $display(
                "PASS: Slave received %h",
                slave_rx_data
            );
        else
            $display(
                "FAIL: Slave received %h expected A5A5",
                slave_rx_data
            );



        if(master_rx_data == 16'h3C3C)
            $display(
                "PASS: Master received %h",
                master_rx_data
            );
        else
            $display(
                "FAIL: Master received %h expected 3C3C",
                master_rx_data
            );



        if(saw_rx_valid)
            $display(
                "PASS: rx_valid asserted after 16 bits"
            );
        else
            $display(
                "FAIL: rx_valid not detected"
            );



        @(negedge clk);
        @(negedge clk);



        if(csb_n == 2'b11)
            $display("PASS: CSB released");
        else
            $display(
                "FAIL: CSB not released %b",
                csb_n
            );



        if(sclk == 1'b0)
            $display("PASS: SCLK idle low");
        else
            $display("FAIL: SCLK idle error");



        if(slave_miso_oe == 1'b0)
            $display("PASS: MISO released");
        else
            $display("FAIL: MISO still enabled");



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
