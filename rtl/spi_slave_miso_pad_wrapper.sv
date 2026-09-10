module spi_slave_miso_pad_wrapper #(
    parameter integer DATA_WIDTH = 16,
    parameter PAD_DS = 1'b1
) (
    input  wire                  sclk,
    input  wire                  csb_n,
    input  wire                  mosi,
    input  wire [DATA_WIDTH-1:0] tx_data,

    inout  wire                  miso_pad,

    output wire [DATA_WIDTH-1:0] rx_data,
    output wire                  rx_valid
);

    wire miso_core;
    wire miso_oe_core;
    wire pad_c_unused;
    wire pad_oen;

    // Current SPI RTL uses:
    //   miso_oe = 1 -> drive
    //   miso_oe = 0 -> high-Z
    //
    // PDDW0208CSG uses active-low OEN:
    //   OEN = 0 -> drive
    //   OEN = 1 -> high-Z
    assign pad_oen = ~miso_oe_core;

    spi_slave #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_slave (
        .sclk     (sclk),
        .csb_n    (csb_n),
        .mosi     (mosi),
        .tx_data  (tx_data),
        .miso     (miso_core),
        .miso_oe  (miso_oe_core),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    PDDW0208CSG u_miso_pad (
        .I   (miso_core),
        .DS  (PAD_DS),
        .OEN (pad_oen),
        .PAD (miso_pad),
        .C   (pad_c_unused),
        .PE  (1'b0),
        .IE  (1'b0)
    );

endmodule
