module wallace_mult (
  input [7:0] x,
  input [7:0] y,
  output [15:0] out,
  output [15:0] pp [4]
);

// These signals are created to help you map the wires you need with the diagram provided in the lab document.

wire [15:0] s_lev01; //the first "save" output of level0's CSA array
wire [15:0] c_lev01; //the first "carry" output of level0's CSA array
wire [15:0] s_lev02; //the second "save" output of level0's CSA array
wire [15:0] c_lev02;
wire [15:0] s_lev11;
wire [15:0] c_lev11;
wire [15:0] s_lev12; //the second "save" output of level1's CSA array
wire [15:0] c_lev12;
wire [15:0] s_lev21;
wire [15:0] c_lev21;
wire [15:0] s_lev31;
wire [15:0] c_lev31;

// TODO: complete the hardware design for instantiating the CSA blocks per level.
logic [15:0] i [9];
logic cout;
 
genvar row, col;
//genvar temp;
generate
 for (row=0; row<8 ; row++) begin: p_row
   for (col=0; col<16 ; col++) begin: p_column
     if( col>row+7 ) begin
       assign i[row][col]=1'b0;
     end
	 else if( col<row ) begin
       assign i[row][col]=1'b0;
     end
     else begin  
		assign i[row][col]=x[col-row] & y[row];
     end
   end
 end
endgenerate

//level 0
csa level0_1(i[0][15:0], i[1][15:0], i[2][15:0], s_lev01, c_lev01);
csa level0_2(i[3][15:0], i[4][15:0], i[5][15:0], s_lev02, c_lev02);
//level 1
csa level1_1(s_lev01, c_lev01<<1, s_lev02, s_lev11, c_lev11);
csa level1_2(c_lev02<<1, i[6][15:0], i[7][15:0],s_lev12, c_lev12);
//level 2, the save and carry output of level 2 will be pp[2] and pp[3]
csa level2_1(c_lev11<<1, s_lev11, s_lev12, s_lev21, c_lev21);
  assign pp[0] = s_lev21;
  assign pp[1] = c_lev21;

//level 3, the save and carry output of level 3 will be pp[2] and pp[3]
csa level3_1(s_lev21, c_lev21<<1, c_lev12<<1, s_lev31, c_lev31);
  assign pp[2] = s_lev31;
  assign pp[3] = c_lev31;

// Ripple carry adder to calculate the final output.
rca rca_out(s_lev31, c_lev31<<1, 1'b0, out, cout);
endmodule





// These modules are provided for you to use in your designs.
// They also serve as examples of parameterized module instantiation.
module rca #(width=16) (
    input  [width-1:0] op1,
    input  [width-1:0] op2,
    input  cin,
    output [width-1:0] sum,
    output cout
);

wire [width:0] temp;
assign temp[0] = cin;
assign cout = temp[width];

genvar i;
for( i=0; i<width; i=i+1) begin
    full_adder u_full_adder(
        .a      (   op1[i]     ),
        .b      (   op2[i]     ),
        .cin    (   temp[i]    ),
        .cout   (   temp[i+1]  ),
        .s      (   sum[i]     )
    );
end

endmodule


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

module csa #(width=16) (
	input [width-1:0] op1,
	input [width-1:0] op2,
	input [width-1:0] op3,
	output [width-1:0] S,
	output [width-1:0] C
);

genvar i;
generate
	for(i=0; i<width; i++) begin
		full_adder u_full_adder(
			.a      (   op1[i]    ),
			.b      (   op2[i]    ),
			.cin    (   op3[i]    ),
			.cout   (   C[i]	  ),
			.s      (   S[i]      )
		);
	end
endgenerate

endmodule

