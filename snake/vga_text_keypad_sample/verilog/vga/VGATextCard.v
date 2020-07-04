/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/*!
 * VGA Text Graphics Card
 * @type ram
 * @size 4096
 * @data_bits 8
 * @class MyVGATextCard
 * @create vgaTextCard_create
 * @eval vgaTextCard_eval
 * @destroy vgaTextCard_destroy
 */
module VGATextCard (
    input vclk, //! VGA clock input 25Mhz for 640x480 resolution. Not used in Digital
    input clk, //! Clock
    input rst, //! Reset
    input en, //! Enable 
    input we, //! Write enable
    input  [11:0] addr, //! Address
    input  [15:0] wd, //! Write data
    output [15:0] rd, //! Read data
    output [2:0] r, //! Red output. Not used in Digital
    output [2:0] g, //! Green output. Not used in Digital
    output [1:0] b, //! Blue output. Not used in Digital
    output hs,  //! Horizontal Sync. Not used in Digital
    output vs //! Vertical Sync. Not used in Digital
);

    // Text Buffer RAM Memory Signals, Port B (to VGA core)
    wire [15:0] rd2;
    wire [11:0] addr2;

    // Font ROM Memory Signals
    wire [11:0] fontrom_addr;
    wire [7:0]  fontrom_rd;

    // Palette ROM signal
    wire [3:0] palrom_addr1;
	wire [3:0] palrom_addr2;
	wire [7:0] palrom_data1;
	wire [7:0] palrom_data2;

`ifdef SYNTHESIS
    VGA80X30Color vgaproto (
        .clk(vclk),
        .rst(rst),
        .vgaram_addr(addr2), // vga memory address
        .vgaram_data(rd2),   // vga memory data
        .fontrom_addr(fontrom_addr),  // Font ROM memory address
        .fontrom_data(fontrom_rd),    // Font ROM memory data
        .palrom_addr1(palrom_addr1),
        .palrom_addr2(palrom_addr2),
        .palrom_data1(palrom_data1),
        .palrom_data2(palrom_data2),
        .r(r),
        .g(g),
        .b(b),
        .hs(hs),
        .vs(vs)
    );       
`endif    

    RomColorPalette palrom (
	  .addr1(palrom_addr1),
	  .addr2(palrom_addr2),
	  .color1(palrom_data1),
	  .color2(palrom_data2)
	);

    DualPortVGARam framebuff (
        .clk1(clk),
        .write_en(we),
        .addr1(addr),
        .write_data(wd),
        .read_data1(rd),
        .clk2(vclk),
        .addr2(addr2),
        .read_data2(rd2)
    );

    FontRom fontrom (
      .clk(vclk),
      .addr(fontrom_addr),
      .dout(fontrom_rd)
    );
endmodule

