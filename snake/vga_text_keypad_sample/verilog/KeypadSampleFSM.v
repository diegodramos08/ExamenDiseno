module KeypadSampleFSM(
    input [11:0] random,
    input clk,
    input rst,
    input [31:0] timer,
    input [7:0] keypad,
    input [15:0] vga_rd,
    output reg [11:0] vga_addr,
    output reg vga_we,
    output reg [15:0] vga_data
);
    reg [2:0] cs /*verilator public*/; // Current state
    reg [2:0] ns; // Next state
    reg [1:0] test;

    reg [1:0] direccion;
    parameter left = 2'd0;
    parameter right = 2'd1;
    parameter down = 2'd2;
    parameter up = 2'd3;

    reg hasTailMoved;
    reg bool2;
    reg flipped;
    reg bool3;
    reg bool4;
    reg bool5;
    reg hasCollectedFruit;
    reg hasLost;

    reg [11:0] cabeza;
    reg [11:0] cola;
    reg [6:0] tamano;

    reg [255:0] queue;
 
    always @(*) begin
       if(rst) begin
          hasLost = 1'b0;
          bool5 = 1'b0;
          tamano = 7'd4;
          queue = {246'b0, 10'b0101010101};
          cabeza = 12'd810;
          cola = 12'd806;
          hasTailMoved = 1'b1;
          bool2 = 1'b1;
          bool4 = 1'b0;
          flipped = 1'b0;
          direccion = right;
          hasCollectedFruit = 1'b0;
          queue[tamano*2 - 2] = direccion[0];
          queue[tamano*2 - 1] = direccion[1];
       end
        case (cs)
            3'd00: begin
                vga_we = 1'b0;
                cabeza = 12'd810;
                vga_data = 16'hx;
            end
            3'd01: begin
                vga_we = 1'b1;
                if(hasTailMoved) begin
                   vga_data = 16'h0a00;
                   hasCollectedFruit = 1'b0;
                   if(cabeza % 80 == 12'd0)
                      cabeza = cabeza + 12'd79;
                   else
                      cabeza = cabeza - 12'd1;
                      hasTailMoved = 1'b0;
                end
                if(!flipped) begin
                   bool2 = !bool2;
                   bool3 = 1'b1;
                   bool4 = 1'b1;
                   flipped = 1'b1;
                end
                   bool5 = 1'b1;
            end
            3'd02: begin
                vga_we = 1'b1;
                //$write("cs: 2 tail: %b", hasTailMoved);
                if(hasTailMoved) begin
                   hasCollectedFruit = 1'b0;
                   vga_data = 16'h0a00;
                   if(cabeza % 80 == 12'd79)
                      cabeza = cabeza - 12'd79;
                   else
                      cabeza = cabeza + 12'd1;
                      hasTailMoved = 1'b0;
                end
                if(!flipped) begin
                   bool2 = !bool2;
                   bool3 = 1'b1;
                   bool4 = 1'b1;
                   flipped = 1'b1;
                end
                   bool5 = 1'b1;
                //$display(" -> %b", hasTailMoved);
            end
            3'd03: begin
                vga_we = 1'b1;
                if(hasTailMoved) begin
                   hasCollectedFruit = 1'b0;
                   vga_data = 16'h0a00;
                   if(cabeza / 100 == 24)
                      cabeza = cabeza % 100;
                   else
                      cabeza = cabeza + 12'd80;
                      hasTailMoved = 1'b0;
                end
                if(!flipped) begin
                   bool2 = !bool2;
                   bool3 = 1'b1;
                   bool4 = 1'b1;
                   flipped = 1'b1;
                end
                   bool5 = 1'b1;
            end
            3'd04: begin
                vga_we = 1'b1;
                if(hasTailMoved) begin
                   hasCollectedFruit = 1'b0;
                   vga_data = 16'h0a00;
                   if(cabeza / 80 == 0)
                      cabeza = 12'd2400 + cabeza % 100;
                   else
                      cabeza = cabeza - 12'd80;
                      hasTailMoved = 1'b0;
                end
                if(!flipped) begin
                   bool3 = 1'b1;
                   bool2 = !bool2;
                   bool4 = 1'b1;
                   flipped = 1'b1;
                end
                   bool5 = 1'b1;
            end
            3'd07: begin
               vga_we = 1'b1;
               vga_data = 16'h0500;
               vga_addr = random;
               while(vga_rd == 16'h0e00 || vga_rd == 16'h0a00)
                  vga_addr = vga_addr + 1;
               bool5 = 1'b0;
            end
            default: begin
                //$write("cs: 5 tail: %b", hasTailMoved);
                vga_we = 1'b0;
                vga_data = 16'hx;
                flipped = 1'b0;
                if(bool2)
                   hasTailMoved = 1'b1;
                //$display(" -> %b", hasTailMoved);
            end
        endcase
      case (cs)
         3'd0: ns = 3'd07;
         3'd5: begin
            if (keypad[0] && direccion != right && hasTailMoved && bool4)
                direccion = left;
            else if (keypad[1] && direccion != left && hasTailMoved && bool4)
                direccion = right;
            else if (keypad[2] && direccion != up && hasTailMoved && bool4)
                direccion = down;
            else if (keypad[3] && direccion != down && hasTailMoved && bool4)
                direccion = up;
            else
                direccion = direccion;
            ns = 3'd0;
            bool4 = 1'b0;
         end
         3'd06: ns = 3'd06;
         default: begin
            ns = 3'd5;
         end
        endcase
        if(ns != 3'd5 && ns != 3'd7) begin
           case(direccion) 
              left: ns = 3'd1;
              right: ns = 3'd2;
              down: ns = 3'd3;
              up: ns = 3'd4;
           endcase
        end
        if(bool3 && bool2 && !hasTailMoved) begin
           if(!hasCollectedFruit) begin
              case({queue[1],queue[0]})
                 left:begin
                   if(cola % 80 == 12'd0)
                      cola = cola + 12'd79;
                   else
                      cola = cola - 12'd1;
                end
                right: begin
                   if(cola % 80 == 12'd79)
                      cola = cola - 12'd79;
                   else
                      cola = cola + 12'd1;
                end
                down: begin
                   if(cola / 100 == 24)
                      cola = cola % 100;
                   else
                      cola = cola + 12'd80;
                end
                up: begin
                   if(cola / 80 == 0)
                      cola = 12'd2400 + cola % 100;
                   else
                      cola = cola - 12'd80;
                end
              endcase
              queue = queue >> 2;
           end 
           else begin
              tamano = tamano + 1;
              hasCollectedFruit = 1'b0;
           end
           queue[tamano*2 - 2] = direccion[0];
           queue[tamano*2 - 1] = direccion[1];
           vga_data = 16'h0000;
           bool3 = 1'b0;
           $display("queue: \n%b", queue);
        end
        if(bool5) begin
           if(!bool2) begin
             vga_addr = cabeza;
             case(vga_rd)
                16'h0000: begin end
                16'h0500: begin 
                   hasCollectedFruit = 1'b1;
                   ns = 3'd7;
                end
                default: begin
                   ns = 3'd6;
                   vga_data = 16'h0e00;
                end
             endcase
          end
          else 
             vga_addr = cola;
       end
    end

    always @ (posedge clk)
    begin
        if (rst)
            cs <= 3'd0;
        else
            cs <= ns;
    end
endmodule
