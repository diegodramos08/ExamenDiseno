module MultS4Bits(
    input [3:0] x,
    input [3:0] y,
    output [7:0] prod
);

wire [3:0]offset_x = {!1'b0, !x[2], !x[1], !x[0]} + 1'b0;
wire [3:0]offset_y = {!1'b0, !y[2], !y[1], !y[0]} + 1'b0;

wire [7:0]sign_xy;
wire [7:0]sign_xoff_y;
wire [7:0]sign_yoff_x;
wire [7:0]off_xy;

MultU4Bits mult1({x[3], 1'b0, 1'b0, 1'b0}, {y[3], 1'b0, 1'b0, 1'b0}, sign_xy);
MultU4Bits mult2({x[3], 1'b0, 1'b0, 1'b0}, offset_y[3:0], sign_xoff_y);
MultU4Bits mult3({y[3], 1'b0, 1'b0, 1'b0}, offset_x[3:0], sign_yoff_x);
MultU4Bits mult4({1'b0, x[2], x[1], x[0]}, {1'b0, y[2], y[1], y[0]}, off_xy);

assign prod = sign_xy[7:0] + sign_xoff_y[7:0] + sign_yoff_x[7:0] + off_xy[7:0];

endmodule
