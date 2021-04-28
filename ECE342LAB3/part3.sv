// This module uses parameterized instantiation. If values are not set in the testbench the default values specified here are used. 
// The values for EXP and MAN set here are for a IEEE-754 32-bit Floating point representation. 
// TO DO: Edit BITS and BIAS based on the EXP and MAN parameters. 

module part3
	#(parameter EXP = 8,			// Number of bits in the Exponent
	  parameter MAN = 23, 			// Number of bits in the Mantissa
	  parameter BITS = 1+ EXP + MAN,	// Total number of bits in the floating point number
	  parameter BIAS = 2**(EXP-1)-1		// Value of the bias, based on the exponent. 
	  )
	(
		input [BITS - 1:0] X,
		input [BITS - 1:0] Y,
		output inf, nan, zero, overflow, underflow,
		output reg[BITS - 1:0] result
);

// Design your 32-bit Floating Point unit here. 
	logic [EXP-1:0] exp_x, exp_y;
	logic [EXP:0] exp_m;
	logic [EXP:0] exp_b;
	logic [MAN:0] man_x, man_y;//with hidden 1
	logic [MAN:0] man;
	logic [MAN*2+1:0] man_product;
	logic [MAN+1:0] man_trun;
	logic sign;
	logic inf_out, nan_out, zero_out, overflow_out, underflow_out;
	
	assign sign = X[BITS-1] ^ Y[BITS-1];
	
	assign man_x = {1'b1, X[MAN-1:0]};
	assign man_y = {1'b1, Y[MAN-1:0]};
	assign man_product = man_x * man_y;
	assign man_trun = man_product[MAN*2+1:MAN];
	
	assign exp_x = X[BITS-2:MAN];
	assign exp_y = Y[BITS-2:MAN];
	
	assign exp_m = X[BITS-2:MAN] + Y[BITS-2:MAN] - BIAS;
	assign exp_b = (man_trun[MAN+1]==1'b1)?(exp_m+1):(exp_m);
	
	assign man = (man_trun[MAN+1]==1'b1)?man_trun[MAN:1]:man_trun[MAN-1:0];
	
	
	
always_comb 
	begin
	//Feature: Zero
	//Condition: E = 0, M = 0
	//expected_out: S = 0, E = 0, M = 0
	if(X==0 || Y==0)
		begin 
			result[BITS-1:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b1;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if(man == 0 && exp_b== 0)
		begin 
			result[BITS-1:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b1;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	
	//Feature: Not-a-Number
	//Condition: E = EB, M != 0
	//expected_out: S = 0, E = EB, M = 0
	else if ((exp_b[EXP]==0 && exp_b[EXP-1:0] == 2*BIAS+1)  && man != 0)
		begin
			result[BITS-1] = 1'b0;
			result[BITS-2:MAN] = 2*BIAS+1;
			result[MAN-1:0] = 0;
			inf_out = 1'b0;
			nan_out = 1'b1;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if ((exp_x == 2*BIAS+1 && X[MAN-1:0] != 0) || (exp_y == 2*BIAS+1 && Y[MAN-1:0] !=0 )) 
		begin
			result[BITS-1] = 1'b0;
			result[BITS-2:MAN] = 2*BIAS+1;
			result[MAN-1:0] = 0;
			inf_out = 1'b0;
			nan_out = 1'b1;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	
	//Feature: Infinity
	//Condition: E = EB , M = 0
	//expected_out: S = 0, E = EB, M = 0
	else if ((exp_b[EXP]==0 && exp_b[EXP-1:0] == 2*BIAS+1)  && man == 0) 
		begin
			result[BITS-1] = 1'b0;
			result[BITS-2:MAN] = 2*BIAS+1;
			result[MAN-1:0] = 0;
			inf_out = 1'b1;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	else if ((exp_x == 2*BIAS+1 && X[MAN-1:0] == 0) || (exp_y == 2*BIAS+1 && Y[MAN-1:0] ==0 )) 
		begin
			result[BITS-1] = 1'b0;
			result[BITS-2:MAN] = 2*BIAS+1;
			result[MAN-1:0] = 0;
			inf_out = 1'b1;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b0;
		end
	//Feature: Underflow
	//Condition: E < 0
	//expected_out: S = 0, E = 0, M = 0
	else if ( exp_y == 0 || exp_x == 0 || exp_b[EXP:0] == 0)
		begin
			result[BITS-1:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b1;
		end
	else if ( exp_x + exp_y +man_trun[MAN+1] < BIAS)
		begin
			result[BITS-1:0] = 32'b0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b0;
			underflow_out = 1'b1;
		end
		
	//Feature: Overflow
	//Condition: E > EB
	//expected_out: S = 0, E = EB, M = 0
	else if(exp_x > 2*BIAS || exp_y >  2*BIAS || exp_b>=2*BIAS+1)
		begin 
			result[BITS-1] = 1'b0;
			result[BITS-2:MAN] = 2*BIAS+1;
			result[MAN-1:0] = 0;
			inf_out = 1'b0;
			nan_out = 1'b0;
			zero_out = 1'b0;
			overflow_out = 1'b1;
			underflow_out = 1'b0;
		end
	
	//default
	else 
		begin
			result[MAN-1:0] = man;
			result[BITS-2:MAN] = exp_b;
			result[BITS-1] = sign;
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