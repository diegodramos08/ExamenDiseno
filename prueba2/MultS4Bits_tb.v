//  A testbench for mult_4bits_tb
`timescale 1us/1ns

module MultS4Bits_tb;
    reg [3:0] x;
    reg [3:0] y;
    wire [7:0] prod;

    MultS4Bits mult_4bits0 (
        .x(x),
        .y(y),
        .prod(prod)
    );

    integer i, j;
    integer m0, m1, p;

    initial begin
        for (i = 0; i < 16; i = i + 1)
        begin
            for (j = 0; j < 16; j = j + 1)
            begin
                x = i;
                y = j;
                #10;
                
                m0 = {{28{x[3]}}, x};
                m1 = {{28{y[3]}}, y};
                p = m0 * m1;
                if (prod != p[7:0])
                begin
                    $display("%d:%d:prod: (assertion error). Expected %d, found %d",
                             $signed(x), $signed(y), $signed(p), $signed(prod));
                    $finish;
                end
            end
        end

        $display("All tests passed.");
    end
endmodule
