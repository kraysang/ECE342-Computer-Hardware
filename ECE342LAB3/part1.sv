module part1
	(
		input [31:0] X,
		input [31:0] Y,
		output [31:0] result
);

// Design your 32-bit Floating Point unit here. 
	logic [7:0] exp_out;
	logic [23:0] man_x, man_y;//with hidden 1
	logic [47:0] man_product;
	logic [24:0] man_trun;
	logic sign;
	
	assign sign = X[31] ^ Y[31];
	
	assign man_x = {1'b1, X[22:0]};
	assign man_y = {1'b1, Y[22:0]};
	assign man_product = man_x * man_y;
	assign man_trun = man_product[47:23];
	
	assign exp_out[7:0] = X[30:23] + Y[30:23] - 127;
	
	assign result[22:0] = (man_trun[24]==1'b1)?man_trun[23:1]:man_trun[22:0];
	assign result[30:23] = (man_trun[24]==1'b1)?(exp_out[7:0]+1):exp_out[7:0];
	assign result[31] = sign;

endmodule
