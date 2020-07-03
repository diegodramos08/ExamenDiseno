module Exp(
    input clk,
    input rst,
    input [31:0] x,
    input [31:0] n,
    output [31:0] res
);

   reg [1:0] cs/*verilator public*/;
   reg [1:0] ns;

   reg [31:0] x_in;
   reg [31:0] n_in;
   reg [31:0] y;

   assign res = x_in * y;

   always @(posedge clk) begin
      case (cs)
         2'd0: begin
            y = 32'd1;
            x_in = x;
            n_in = n;
         end
         2'd1: begin
            x_in = x_in * x_in;
            n_in = n_in / 2;
         end
         2'd2: begin
            y = x_in * y;
            x_in = x_in * x_in;
            n_in = (n_in - 1) / 2;
         end
         default: begin end
      endcase

      case (cs) 
         2'd3: begin
            ns = 2'd3;
         end
         default: begin
            if(n_in > 1) begin
               if((n_in & 1) == 0)
                  ns = 2'd1;
               else
                  ns = 2'd2;
            end
            else
               ns = 2'd3;
         end
      endcase

      if(rst)
         cs <= 2'd0;
      else
         cs <= ns;
   end

endmodule
