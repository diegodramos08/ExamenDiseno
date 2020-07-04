module VGATest(
    input [11:0] random,
    input clk,
    input rst,
    input [7:0] keypad
);

    // VGA signals
    wire vga_we /*verilator public*/;
    wire [11:0] vga_addr; // VGA address
    wire [15:0] vga_data; // VGA data
    wire [15:0] vga_rd; // VGA data

    // Millis counter
    wire[31:0] ms_count;

    // VGA fsm
    KeypadSampleFSM kps_fsm (
        .random( random ),
        .clk( clk ),
        .rst( rst ),
        .timer( ms_count ),
        .keypad( keypad ),
        .vga_rd( vga_rd ),
        .vga_addr( vga_addr ),
        .vga_we( vga_we ),
        .vga_data( vga_data )
    );

    // Milliseconds counter
    MillisCounter ms_counter (
        .clk ( clk ),
        .reset ( rst ),
        .counter ( ms_count )
    );

    // VGA text mode video card
    /* verilator lint_off PINMISSING*/
    VGATextCard vga_text(
        .clk( clk ),
        .rst( rst ),
        .en( 1'b1 ),
        .we( vga_we ),
        .addr( vga_addr ),
        .wd( vga_data ),
        .rd( vga_rd )
    );

endmodule
