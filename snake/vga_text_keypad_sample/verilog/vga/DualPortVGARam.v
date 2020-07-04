module DualPortVGARam (
    input clk1,
    input write_en,
    input [11:0] addr1,
    input [15:0] write_data,
    output reg [15:0] read_data1,
    input clk2,
    input[11:0] addr2,
    output reg [15:0] read_data2
);
    reg [15:0] memory [0:4095] /*verilator public*/;

`ifdef verilator
import "DPI-C" function void updateVGA(int addr, int write_data);
`endif

    always @ (posedge clk1)
    begin
        if (write_en)
        begin
            memory[addr1] <= write_data;
            read_data1 <= memory[addr1];
`ifdef verilator
            /*verilator lint_off WIDTH*/
            updateVGA(addr1, write_data);
`endif            
        end
    end

    always @ (posedge clk2)
    begin
        read_data2 <= memory[addr2];
    end

    initial begin
        //$readmemh("vga_ram.mif", memory, 0, 2047);
    end
    
endmodule
