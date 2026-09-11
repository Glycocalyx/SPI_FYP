module spi_slave_sclk_miso_pad_wrapper #(
    parameter integer DATA_WIDTH = 16,
    parameter PAD_DS = 1'b1
) (
    // Physical external interface
    inout  wire                  sclk_pad,
    input  wire                  csb_n,
    input  wire                  mosi,
    input  wire [DATA_WIDTH-1:0] tx_data,
    inout  wire                  miso_pad,

    output wire [DATA_WIDTH-1:0] rx_data,
    output wire                  rx_valid
);

    wire sclk_core;

    wire miso_core;
    wire miso_oe_core;
    wire miso_pad_oen;

    wire sclk_pad_c_unused;
    wire miso_pad_c_unused;

    assign miso_pad_oen = ~miso_oe_core;

    // --------------------------------------------------------
    // SCLK input pad
    //
    // PAD -> C is used as the input path.
    // IE  = 1 : enable input receiver
    // OEN = 1 : disable output driver
    // PE  = 0 : disable pull function
    // --------------------------------------------------------
    PDDW0208CSG u_sclk_pad (
        .I   (1'b0),
        .DS  (PAD_DS),
        .OEN (1'b1),
        .PAD (sclk_pad),
        .C   (sclk_core),
        .PE  (1'b0),
        .IE  (1'b1)
    );

    // --------------------------------------------------------
    // SPI core
    // --------------------------------------------------------
    spi_slave #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_slave (
        .sclk     (sclk_core),
        .csb_n    (csb_n),
        .mosi     (mosi),
        .tx_data  (tx_data),
        .miso     (miso_core),
        .miso_oe  (miso_oe_core),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    // --------------------------------------------------------
    // MISO output pad
    // --------------------------------------------------------
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
