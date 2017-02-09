`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:39:45 12/08/2016
// Design Name:   sqrt_function
// Module Name:   /afs/athena.mit.edu/user/m/o/mohamoud/6.111/project/simulations/sqrt_functions/test_bench.v
// Project Name:  sqrt_functions
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sqrt_function
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
	reg [15:0] x_in;
	reg clk;
	reg ce;

	// Outputs
	wire [15:0] x_out;
	wire rdy;

	// Instantiate the Unit Under Test (UUT)
	sqrt_function uut (
		.x_in(x_in), 
		.clk(clk), 
		.ce(ce), 
		.x_out(x_out), 
		.rdy(rdy)
	);
   always #5 clk = clk;
	initial begin
		// Initialize Inputs
		x_in = 0;
		clk = 0;
		ce = 0;

		// Wait 100 ns for global reset to finish
		#100;
      x_in = 18639;
		// Add stimulus here

	end
      
endmodule

