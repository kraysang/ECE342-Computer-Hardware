module part2
	(
		input [31:0] X,
		input [31:0] Y,
		output inf, nan, zero, overflow, underflow,
		output reg[31:0] result
);

// Design your 32-bit Floating Point unit here. 
	logic [7:0] exp_x, exp_y;
	logic [8:0] exp_m;
	logic [8:0] exp_b;
	logic [23:0] man_x, man_y;//with hidden 1
	logic [23:0] man;
	logic [47:0] man_product;
	logic [24:0] man_trun;
	logic sign;
	//logic sum_xym;
	logic inf_out, nan_out, zero_out, overflow_out, underflow_out;
	
	assign sign = X[31] ^ Y[31];
	
	assign man_x = {1'b1, X[22:0]};
	assign man_y = {1'b1, Y[22:0]};
	assign man_product = man_x * man_y;
	assign man_trun = man_product[47:23];
	
	assign exp_x = X[30:23];
	assign exp_y = Y[30:23];
	assign exp_m = X[30:23] + Y[30:23] - 127;
	assign exp_b = (man_trun[24]==1'b1)?(exp_m+1):(exp_m);
	assign man = (man_trun[24]==1'b1)?man_trun[23:1]:man_trun[22:0];
	//assign sum_xym = exp_x + exp_y +man_trun[24];
	
	always_comb 
	begin
	//Feature: Zero
	//Condition: E = 0, M = 0
	//expected_out: S = 0, E = 0, M = 0
	if(X==0 || Y==0)
		begin 
			result[31:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b1;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if(man == 24'b0 && exp_b==8'b0)
		begin 
			result[31:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b1;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	
	//Feature: Not-a-Number
	//Condition: E = EB, M != 0
	//expected_out: S = 0, E = EB, M = 0
	else if ((exp_b[8]==1'b0 && exp_b[7:0] == 255)  && man != 24'b0)
		begin
			result[31] = 1'b0;
			result[30:23] = 255;
			result[22:0] = 23'b0;
			inf_out = 1'b0;
			nan_out = 1'b1;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if ((exp_x == 255 && X[22:0] != 0) || (exp_y == 255 && Y[22:0] !=0 )) 
		begin
			result[31] = 1'b0;
			result[30:23] = 255;
			result[22:0] = 23'b0;
			inf_out = 1'b0;
			nan_out = 1'b1;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	
	//Feature: Infinity
	//Condition: E = EB , M = 0
	//expected_out: S = 0, E = EB, M = 0
	else if ((exp_b[8]==1'b0 && exp_b[7:0] == 255)  && man == 24'b0) 
		begin
			result[31] = 1'b0;
			result[30:23] = 255;
			result[22:0] = 23'b0;
			inf_out = 1'b1;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if ((exp_x == 255 && X[22:0] == 0) || (exp_y == 255 && Y[22:0] ==0 )) 
		begin
			result[31] = 1'b0;
			result[30:23] = 255;
			result[22:0] = 23'b0;
			inf_out = 1'b1;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	//Feature: Underflow
	//Condition: E < 0
	//expected_out: S = 0, E = 0, M = 0
	else if ( exp_y == 8'b0 || exp_x == 8'b0 || exp_b[8:0] == 9'b0)
		begin
			result[31:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b1;
		end
	else if ( exp_x + exp_y +man_trun[24] < 127)
		begin
			result[31:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b1;
		end
		
	//Feature: Overflow
	//Condition: E > EB
	//expected_out: S = 0, E = EB, M = 0
	else if(exp_x > 8'd254 || exp_y >  8'd254 || exp_b[8:0]>=9'd255)
		begin 
			result[31] = 1'b0;
			result[30:23] = 255;
			result[22:0] = 23'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b1;
			underflow_out = 1'b0;
		end
	
	//default
	else 
		begin
			result[22:0] = man;
			result[30:23] = exp_b;
			result[31] = sign;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	end
	
	assign inf = inf_out;
	assign nan = nan_out;
	assign zero = zero_out;
	assign overflow = overflow_out;
	assign underflow = underflow_out;
	

endmodule