module spi_slave_sclk_mosi_miso_pad_wrapper #(
    parameter integer DATA_WIDTH = 16,
    parameter logic   PAD_DS     = 1'b1
) (
    // Physical SPI pads
    inout  wire                  sclk_pad,
    inout  wire                  mosi_pad,
    inout  wire                  miso_pad,

    // CSB is intentionally still a core-level signal in Milestone 5A
    input  wire                  csb_n,

    // Internal ASIC-side data interface
    input  wire [DATA_WIDTH-1:0] tx_data,
    output wire [DATA_WIDTH-1:0] rx_data,
    output wire                  rx_valid
);

    wire sclk_core;
    wire mosi_core;

    wire miso_core;
    wire miso_oe_core;
    wire miso_pad_oen;

    wire miso_pad_c_unused;

    assign miso_pad_oen = ~miso_oe_core;

    // ========================================================
    // SCLK input PAD
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
    // SPI Slave core
    // ========================================================

    spi_slave #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_slave (
        .sclk     (sclk_core),
        .csb_n    (csb_n),
        .mosi     (mosi_core),
        .tx_data  (tx_data),

        .miso     (miso_core),
        .miso_oe  (miso_oe_core),

        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    // ========================================================
    // MISO output PAD
    // ========================================================

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
