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
   reg [3:0] ns;

   always @(posedge clk) begin

      case (cs)
         4'd0: begin
            rf_write_en = 1'b1;
            rf_write_addr = 5'd0; //reg[0]
            rf_write_data_sel = 1'b1; //write const_val
            const_val = a; //reg[0] = a
            ns = 4'd1;
         end
         4'd1: begin
            rf_write_en = 1'b1; 
            rf_write_addr = 5'd1; //reg[1]
            rf_write_data_sel = 1'b1; //write const_val
            const_val = b; //reg[1] = b
            ns = 4'd2;
         end
         4'd2: begin
            rf_write_en = 1'b1;
            rf_write_addr = 5'd2;
            rf_write_data_sel = 1'b1;
            const_val = 0;
            alu_sel = 1'b0; // ALU op2 -> read_data_2
            alu_oper = 2'd1; // ALU oper -
            rf_read_addr1 = 5'd0; // reg[0]
            rf_read_addr2 = 5'd1; // reg[1]
            //reg[0] - reg[1]
            ns = 4'd3;
         end
         4'd3: begin
            if(is_zero_result) //reg[0] - reg[1] == 0 -> a == b
               ns = 4'hf; // FINAL
            else  begin
               rf_write_en = 1'b1; 
               rf_write_addr = 5'd2; //write reg[2]
               rf_write_data_sel = 1'b0; //write Alu result
               rf_read_addr1 = 5'd1; //read1 reg[1] (b)
               rf_read_addr2 = 5'd0; //read2 reg[0] (a)
               alu_sel = 1'b0; // ALU op2 -> read_data_2
               alu_oper = 2'd3; // ALU oper <
               // b < a
               ns = 4'd4;
            end
         end
         4'd4: begin
            rf_read_addr1 = 5'd2; // reg[2]
            const_val = 0; 
            alu_sel = 1'b1; // reg[2](resultado de b < a) + 0
            alu_oper = 2'd0; // ALU oper + 
            // reg[2] + 0 
            // terminaria siendo 1 + 0  o  0 + 0
            ns = 4'd6;
         end
         4'd6: begin
            if(is_zero_result) begin 
               //basicamente 1 + 0 == 0  o  0 + 0 == 0
               rf_write_en = 1'b1;
               rf_write_addr = 5'd2; // write reg[2]
               rf_read_addr1 = 5'd1; // read1 reg[1]
               rf_read_addr2 = 5'd0; // read2 reg[0]
               rf_write_data_sel = 1'b0; // write ALU Result
               alu_oper = 2'd1; // ALU oper -
               alu_sel = 1'b0; // ALU op2 -> read2 
               // reg[2] = reg[1](b) - reg[0](a) 
               ns = 4'd7;
            end
            else begin
               rf_write_en = 1'b1; 
               rf_write_addr = 5'd2; // write reg[2]
               rf_read_addr1 = 5'd0; // read1 reg[0]
               rf_read_addr2 = 5'd1; // read2 reg[1]
               rf_write_data_sel = 1'b0; // wrtie ALU Result
               alu_oper = 2'b1; // ALU oper -
               alu_sel = 1'b0; // ALU op2 read2
               // reg[2] = reg[0](a) - reg[1](b)
               ns = 4'd8;
            end
         end
         4'd7: begin
            rf_write_en = 1'b1;
            rf_write_addr = 5'd1;
            rf_write_data_sel = 1'b0;
            rf_read_addr1 = 5'd2;
            const_val = 0;
            alu_sel = 1'b1;
            alu_oper = 2'd0;
            ns = 4'd2;
         end
         4'd8: begin
            rf_write_en = 1'b1;
            rf_write_addr = 5'd0;
            rf_write_data_sel = 1'b0;
            rf_read_addr1 = 5'd2;
            const_val = 1;
            alu_sel = 1'b1;
            alu_oper = 2'd2;
            ns = 4'd2;
         end
         default: begin
            ns = 4'hf;
         end
      endcase
      $display("cs: %d", cs);

      if(rst)
         cs <= 4'd0;
      else
         cs <= ns;
   end

endmodule
