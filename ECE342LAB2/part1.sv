/*******************************************************/
/********************Multiplier module********************/
/*****************************************************/
// add additional modules as needs, such as full adder, and others

// multiplier module
module mult
(
	input [7:0] x,
	input [7:0] y,
	output logic[15:0] out,   // Result of the multiplication
	output [7:0] pp [9] // for automarker to check partial products of a multiplication 
);
	// Declare a 9-high, 16-deep array of signals holding sums of the partial products.
	// They represent the _input_ partial sums for that row, coming from above.
	// The input for the "ninth row" is actually the final multiplier output.
	// The first row is tied to 0.
	//assign pp[0] = '0;
	
	// Make another array to hold the carry signals
	logic [7:0] cin[9];
	logic [7:0] sum[9];

	// Cin signals for the final (fast adder) row
	logic [16:8] cin_final;
	assign cin_final[8] = '0;
	assign cin_final[16:9] =out[15:8];
	assign pp=sum;
	// TODO: complete the following digital logic design of a carry save multiplier (unsigned)
	// Note: generate_hw tutorial can help you describe duplicated modules efficiently
	
	// Note: partial product of each row is the result coming out from a full adder at the end of that row
	
	// Note: a "Fast adder" operates on columns 8 through 15 of final row.
 genvar i,j;
 generate 
	for(i=0;i<7;i=i+1) 
	begin:row
		if (i==0)
		begin
			for(j=0;j<8;j=j+1) 
			begin:bit1
				if (j==0)
					begin
					assign out[i]=x[j]&y[i];
					assign sum[i][j]='b0;
					full_adder full_adder1(
						.a   (x[j+1]&y[i]),
						.b   (x[j]&y[i+1]),
						.cin (1'b0),
						.cout(cin[i][j]),
						.s   (out[i+1])
					);	
					end			
				else if(j==7)
					full_adder full_adder2(
						.a   (1'b0),
						.b   (x[j]&y[i+1]),
						.cin (x[j-1]&y[i+2]),
						.cout(cin[i][j]),
						.s   (sum[i][j])
					);				
				else
					full_adder full_adder3(
						.a   (x[j+1]&y[i]),
						.b   (x[j]&y[i+1]),
						.cin (x[j-1]&y[i+2]),
						.cout(cin[i][j]),
						.s   (sum[i][j])
					);			
			end
		end
		else if (i==6)
		begin
			for(j=0;j<8;j=j+1) 
			begin:bit1
				if (j==0)
					begin
					assign sum[i][j]='b0;
					full_adder full_adder(
						.a   (sum[i-1][j+1]),
						.b   (cin[i-1][j]),
						.cin (1'b0),
						.cout(cin[i][j]),
						.s   (out[i+1])
					);	
					end
				else if(j==7)
					full_adder full_adder(
						.a   (x[i+1]&y[j]),
						.b   (cin[i-1][j]),
						.cin (cin[i][j-1]),
						.cout(out[i+1+j+1]),
						.s   (out[i+1+j])
					);				
				else
					full_adder full_adder(
						.a   (sum[i-1][j+1]),
						.b   (cin[i-1][j]),
						.cin (cin[i][j-1]),
						.cout(cin[i][j]),
						.s   (out[i+1+j])
					);			
			end
		end	
		else if((i>0)&(i<6))
		begin
			for(j=0;j<8;j=j+1) 
			begin:bit1
				if (j==0)
					begin
					assign sum[i][j]='b0;	
					full_adder full_adder1(
						.a   (sum[i-1][j+1]),
						.b   (1'b0),
						.cin (cin[i-1][j]),
						.cout(cin[i][j]),
						.s   (out[i+1])
					);	
					end			
				else if(j==7)
					full_adder full_adder2(
						.a   (x[j]&y[i+1]),
						.b   (x[j-1]&y[i+2]),
						.cin (cin[i-1][j]),
						.cout(cin[i][j]),
						.s   (sum[i][j])
					);				
				else
					full_adder full_adder3(
						.a   (sum[i-1][j+1]),
						.b   (x[j-1]&y[i+2]),
						.cin (cin[i-1][j]),
						.cout(cin[i][j]),
						.s   (sum[i][j])
					);			
			end
		end		
	end
 endgenerate
	
	//assign out[7:0] = pp[8][7:0];
		  
endmodule

// The following code is provided for you to use in your design

module full_adder(
    input a,
    input b,
    input cin,
    output cout,
    output s
);

assign s = a ^ b ^ cin;
assign cout = a & b | (cin & (a ^ b));

endmodule
