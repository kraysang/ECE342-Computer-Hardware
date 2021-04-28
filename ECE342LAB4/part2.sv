module avalon_fp_mult
(
	input clk,
	input reset,
	
	// Avalon Slave
	input [2:0] avs_s1_address,
	input avs_s1_read,
	input avs_s1_write,
	input [31:0] avs_s1_writedata,
	output logic [31:0] avs_s1_readdata,
	output logic avs_s1_waitrequest
);

	logic [31:0] data_1;
	logic [31:0] data_2;
	logic [31:0] res;
	logic [31:0] flags;
	logic waitin;
	//logic [4:0] cc;
	
	assign flags[31:4] = 0;

	avalon_slave avs
	(
		.clk(clk),
		.reset(reset),
		.avs_s1_address(avs_s1_address),
		.avs_s1_read(avs_s1_read),
		.avs_s1_write(avs_s1_write),
		.avs_s1_writedata(avs_s1_writedata),
		.avs_s1_readdata(avs_s1_readdata),
		.avs_s1_waitrequest(avs_s1_waitrequest),

		// FP_MULT
		// STUDENTS TO ADD THESE
		.fpm_res(res),
		.fpm_flags(flags),
		//.waitin(waitin),
		.operand1(data_1),
		.operand2(data_2)
	);


	fp_mult fpm
	(
        // STUDENTS TO ADD THESE
		.aclr(reset),
		  .clk_en(avs_s1_waitrequest),
		  .clock(clk),
		  .dataa(data_1),
		  .datab(data_2),
		  .nan(flags[0]),
		  .overflow(flags[3]),
		  .result(res),
		  .underflow(flags[2]),
		  .zero(flags[1])
	);

endmodule

//_____________________________________________________________
//_____________________________________________________________


module avalon_slave
(
	input clk,
	input reset,
	
	// Avalon Slave
	input [2:0] avs_s1_address,
	input avs_s1_read,
	input avs_s1_write,
	input [31:0] avs_s1_writedata,
	output logic [31:0] avs_s1_readdata,
	output logic avs_s1_waitrequest,

	// FP_MULT
    // STUDENTS TO ADD THESE
	input [31:0] fpm_res,
	input [31:0] fpm_flags,
	//input waitin,
	output logic [31:0] operand1,
	output logic [31:0] operand2
);

// Mem-mapped regs
// Reg0-32:			A
// Reg1-32:			B
// Reg2-04:			Start/Busy
// Reg3-32:			Result
// Reg4-04:			Status (Flags)
	reg [31:0] mul_op_1;
	reg [31:0] mul_op_2;
	reg [31:0] mul_start;
	reg [31:0] mul_result;
	reg [31:0] mul_status;

	// STUDENTS TO ADD THESE
	logic [4:0] cc;
	logic  waitin;
	
	always_ff @ (posedge clk) 
	begin
		if(reset == 1'b1)
		begin
			cc <= 0;
			waitin <= 0;
		end
		
		
		else if(avs_s1_waitrequest)
		begin
			if(cc == 11)
			begin
				waitin <= 0;
				cc <= 0;
			end
			
			else
			begin
				waitin <= avs_s1_waitrequest;
				cc <= cc+1;
			end
		end
		
		else if(!avs_s1_waitrequest)
		begin
			cc <= cc;
			waitin <= avs_s1_waitrequest;
		end
	end

	always_ff @ (posedge clk) 
	begin
	//reset
		if(reset==1'b1)
			begin
				mul_op_1 = 32'b0;
				mul_op_2 = 32'b0;
				avs_s1_readdata = 1'b0;
			end
			
		//write
		else if(!avs_s1_read && avs_s1_write)
			begin
			avs_s1_readdata = 0;
			case (avs_s1_address)
				3'b000: mul_op_1 = avs_s1_writedata;
				3'b001: mul_op_2 = avs_s1_writedata;
			endcase
			end
		
		//read
		else if(avs_s1_read && !avs_s1_write)
			begin
				case (avs_s1_address)
				3'b000: avs_s1_readdata = mul_op_1;
				3'b001: avs_s1_readdata = mul_op_2;
				3'b010: avs_s1_readdata = mul_start;
				3'b011: avs_s1_readdata = mul_result;
				3'b100: avs_s1_readdata = mul_status;
				default: avs_s1_readdata = avs_s1_readdata;
				endcase
			end
	end
	assign mul_start = (avs_s1_write && avs_s1_address==3'b010)?((avs_s1_writedata[0]==1 && waitin!=mul_start[0])?{31'b0, waitin}:avs_s1_writedata): {31'b0, waitin};
	assign avs_s1_waitrequest = mul_start[0];
	
	assign operand1 = mul_op_1;
	assign operand2 = mul_op_2;
	
	assign mul_result = (waitin == 0)?fpm_res:mul_result;
	assign mul_status = (waitin == 0)?fpm_flags:mul_status;
	

	
	
endmodule
