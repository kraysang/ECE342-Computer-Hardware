//Top module for game
module top_tb();

    logic                  clk     ;
    logic                  reset   ;
    logic                  enter   ;
    logic            [7:0] guess   ;
    logic            [7:0] actual  ;
    logic                  dp_over ;
    logic                  dp_under;
    logic                  dp_equal;


	top the_top
	(
		.clk     (clk     ),
		.reset   (reset   ),
		.enter   (enter   ),
		.guess   (guess   ),
		.actual  (actual  ),
		.dp_over (dp_over ),
		.dp_under(dp_under),
        .dp_equal(dp_equal)	
	);

 initial
begin
	clk=0;
	reset=1;
	enter=0;
	guess=8'b00000000;
	repeat(10)
		begin
		@(posedge clk)
		reset=1;
		end
		
	guess<=8'b00010000;	
	reset<=0;
	repeat(10)
		@(posedge clk);
		
	enter=1;
	repeat(1)
		@(posedge clk);
	enter=0;
	repeat(10)
		@(posedge clk);


	enter=1;
	guess<=8'b00001000;
	repeat(1)
		@(posedge clk);
	enter=0;
	repeat(10)
		@(posedge clk);		
		
	enter=1;
	guess<=8'b00001100;
	repeat(1)
		@(posedge clk);
	enter=0;
	repeat(10)
		@(posedge clk);			
	$stop;	
end  
	
   always #(20/2) clk = !clk;


endmodule
