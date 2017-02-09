`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:26:08 12/07/2016
// Design Name:   transform
// Module Name:   /afs/athena.mit.edu/user/m/o/mohamoud/6.111/project/simulations/transform/test_bench.v
// Project Name:  transform
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: transform
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_bench;

	// Inputs
	reg clk, start;
	reg [9:0] t_height;
	reg [10:0] t_width;
	reg [10:0] x;
	reg [9:0] y;

	// Outputs
	wire [12:0] cv_x;
	wire [12:0] cv_y;

	// Instantiate the Unit Under Test (UUT)
	transform uut (
		.clk(clk), .start(start),
		.t_height(t_height), 
		.t_width(t_width), 
		.x(x), 
		.y(y), 
		.cv_x(cv_x), 
		.cv_y(cv_y)
	);
   always #5 clk = clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		t_height = 0;
		t_width = 0;
		x = 0;
		y = 0;
		start = 0;

		// Wait 100 ns for global reset to finish
		
		#100;
      t_height = 80;
		t_width = 80;
		x = 230;
		y = 340;
		start = 1;
		#12;
		start = 0;
		
		// Add stimulus here

	end
      
endmodule

