`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:38:34 12/08/2016
// Design Name:   dist
// Module Name:   /afs/athena.mit.edu/user/m/o/mohamoud/6.111/project/simulations/dist_sim/dist_sim.v
// Project Name:  dist_sim
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dist
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dist_sim;

	// Inputs
	reg clk;
	reg [10:0] x_start;
	reg [10:0] x_end;
	reg [9:0] y_start;
	reg [9:0] y_end;

	// Outputs
	wire [21:0] sum_sqrs;
	wire [11:0] distance;

	// Instantiate the Unit Under Test (UUT)
	dist uut (
		.clk(clk), 
		.x_start(x_start), 
		.x_end(x_end), 
		.y_start(y_start), 
		.y_end(y_end), 
		.sum_sqrs(sum_sqrs),
		.distance(distance)
	);
   always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		x_start = 0;
		x_end = 0;
		y_start = 0;
		y_end = 0;

		// Wait 100 ns for global reset to finish
		#100;
       x_start = 100;
		 y_start = 200;
		 x_end = 400;
		 y_end = 230;
		// Add stimulus here

	end
      
endmodule

