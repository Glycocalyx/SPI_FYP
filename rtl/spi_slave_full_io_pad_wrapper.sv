module spi_slave_full_io_pad_wrapper #(
    parameter integer DATA_WIDTH = 16,
    parameter logic   PAD_DS     = 1'b1
) (
    // ========================================================
    // Physical SPI pads
    // ========================================================
    inout  wire                  sclk_pad,
    inout  wire                  mosi_pad,
    inout  wire                  csb_pad,
    inout  wire                  miso_pad,

    // ========================================================
    // Internal ASIC-side data interface
    // ========================================================
    input  wire [DATA_WIDTH-1:0] tx_data,

    output wire [DATA_WIDTH-1:0] rx_data,
    output wire                  rx_valid
);

    // ========================================================
    // Core-side SPI signals
    // ========================================================

    wire sclk_core;
    wire mosi_core;
    wire csb_core;

    wire miso_core;
    wire miso_oe_core;

    wire miso_pad_oen;
    wire miso_pad_c_unused;


    // ========================================================
    // MISO output-enable polarity conversion
    //
    // SPI core:
    //   miso_oe_core = 1 -> drive MISO
    //   miso_oe_core = 0 -> release MISO
    //
    // PDDW0208CSG:
    //   OEN = 0 -> output enabled
    //   OEN = 1 -> output disabled / High-Z
    // ========================================================

    assign miso_pad_oen = ~miso_oe_core;


    // ========================================================
    // SCLK input PAD
    //
    // External direction:
    //   FPGA -> PAD -> C -> SPI core
    //
    // IE  = 1 : input receiver enabled
    // OEN = 1 : output driver disabled
    // PE  = 0 : pull function disabled
    // ========================================================

    PDDW0208CSG u_sclk_pad (
        .I   (1'b0),
        .DS  (PAD_DS),
        .OEN (1'b1),
        .PAD (sclk_pad),
        .C   (sclk_core),
        .PE  (1'b0),
        .IE  (1'b1)
    );


    // ========================================================
    // MOSI input PAD
    //
    // External direction:
    //   FPGA -> PAD -> C -> SPI core
    // ========================================================

    PDDW0208CSG u_mosi_pad (
        .I   (1'b0),
        .DS  (PAD_DS),
        .OEN (1'b1),
        .PAD (mosi_pad),
        .C   (mosi_core),
        .PE  (1'b0),
        .IE  (1'b1)
    );


    // ========================================================
    // CSB input PAD
    //
    // External direction:
    //   FPGA -> PAD -> C -> SPI core
    //
    // CSB is special because the current SPI RTL uses csb_n
    // not only as a slave-select signal but also as an
    // asynchronous transaction-state control.
    //
    // Therefore the physical PAD is added here, while
    // recovery/removal timing will be analyzed separately.
    // ========================================================

    PDDW0208CSG u_csb_pad (
        .I   (1'b0),
        .DS  (PAD_DS),
        .OEN (1'b1),
        .PAD (csb_pad),
        .C   (csb_core),
        .PE  (1'b0),
        .IE  (1'b1)
    );


    // ========================================================
    // SPI Slave core
    // ========================================================

    spi_slave #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_slave (
        .sclk     (sclk_core),
        .csb_n    (csb_core),
        .mosi     (mosi_core),

        .tx_data  (tx_data),

        .miso     (miso_core),
        .miso_oe  (miso_oe_core),

        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );


    // ========================================================
    // MISO output PAD
    //
    // Internal direction:
    //   SPI core -> I -> PAD -> FPGA
    //
    // IE is disabled because MISO is output-only here.
    // ===S=====================================================

    PDDW0208CSG u_miso_pad (
        .I   (miso_core),
        .DS  (PAD_DS),
        .OEN (miso_pad_oen),
        .PAD (miso_pad),
        .C   (miso_pad_c_unused),
        .PE  (1'b0),
        .IE  (1'b0)
    );

endmodule
