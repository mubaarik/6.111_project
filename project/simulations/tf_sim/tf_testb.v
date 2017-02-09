`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:31:54 12/09/2016
// Design Name:   transform
// Module Name:   /afs/athena.mit.edu/user/m/o/mohamoud/6.111/project/simulations/tf_sim/tf_testb.v
// Project Name:  tf_sim
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

module tf_testb;

	// Inputs
	reg clk;
	reg [10:0] t_height;
	reg [10:0] t_width;
	reg [10:0] x;
	reg [9:0] y;

	// Outputs
	wire [21:0] x_prod;
	wire [21:0] y_prod;

	// Instantiate the Unit Under Test (UUT)
	transform uut (
		.clk(clk), 
		.t_height(t_height), 
		.t_width(t_width), 
		.x(x), 
		.y(y), 
		.x_prod(x_prod), 
		.y_prod(y_prod)
	);
   always #5 clk = ~clk;
	initial begin
		// Initialize Inputs
		clk = 0;
		t_height = 0;
		t_width = 0;
		x = 0;
		y = 0;

		// Wait 100 ns for global reset to finish
		#100;
      t_height=120;
		t_width = 120;
		x = 124;
		y = 300;
		// Add stimulus here

	end
      
endmodule

