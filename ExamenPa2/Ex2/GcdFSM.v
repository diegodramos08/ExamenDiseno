module GcdFSM(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    input is_zero_result,
    output reg [4:0] rf_read_addr1,
    output reg [4:0] rf_read_addr2,
    output reg [4:0] rf_write_addr,
    output reg rf_write_en,
    output reg rf_write_data_sel,
    output reg [31:0] const_val,
    output reg alu_sel,
    output reg [1:0] alu_oper
);

   reg [3:0] cs/*verilator public*/;

   always @(posedge clk) begin

      case (cs)
         2'd0: begin
            rf_write_addr = 32'h1;
            rf_write_en = 1'b1;
            rf_write_data_sel = 1'b1;
            const_val = a;
         end
         2'd1: begin
            
         end
         2'd2: begin
            rf_write_data_sel = 1'b0;
            rf_write_en = 1'b1;
         end
         2'd3: begin

         end
      endcase

      case (cs)
         2'd0: ns = 2'd1;
      endcase

      if(rst)
         cs <= 2'd0;
      else
         cs <= ns;
   end

endmodule
