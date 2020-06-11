module MultU4Bits (
    input [3:0] x,
    input [3:0] y,
    output [7:0] prod
);
    wire [3:0] pp[0:3];

    genvar i;
    generate
        for (i = 0; i < 4; i = i+1)
        begin
          assign pp[i] = {4{y[i]}} & x;
        end
    endgenerate

    wire [5:0] sum0;
    wire [5:0] sum1;
    
    assign sum0 = {1'b0, pp[0]} + {pp[1], 1'b0};
    assign sum1 = {1'b0, pp[2]} + {pp[3], 1'b0};

    assign prod = {2'b00, sum0} + {sum1, 2'b00};
endmodule
