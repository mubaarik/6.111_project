`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:26:36 12/05/2016 
// Design Name: 
// Module Name:    score 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module score(input wire [10:0] x, center_x, input wire [9:0] y, center_y, input wire clk, 
             trigger, clear, output reg [6:0] score, output reg [17:0] score_text, 
             output wire [9:0] cumm_sc);
   
   parameter ALPHA = 0.5;
   parameter MAX_SCORE = 100;
   parameter R_ONE = 97*97;
   parameter R_TWO = 4*R_ONE;
   parameter R_THREE = 9*R_ONE;
   parameter R_FOUR = 16*R_ONE;
   parameter ZERO_INDEX = 53; // A-Za-z occupy 1-52
   
   wire [10:0] dx;
   wire [9:0] dy;
   wire [3:0] hundreds, tens, ones;
   wire [5:0] d_100, d_10, d_1;
   wire ready;
   reg store, can_store, start;
   
   reg [32:0] r_square;
   reg [9:0] cummulative_score = 0;
   reg store_trigger=0;

   // convert score in binary to decimal for text display module
   convert_bcd score_digits(.clock(clk), .start(start), .data(cummulative_score),
                            .d(ones), .d10(tens), .d100(hundreds), .ready(ready));
                             
   assign d_100 = hundreds + ZERO_INDEX; 
   assign d_10 = tens + ZERO_INDEX;
   assign d_1 = ones + ZERO_INDEX;   
   assign dx = (x > center_x) ? x - center_x : center_x - x;
   assign dy = (y > center_y) ? y - center_y : center_y - y;
   assign cumm_sc = cummulative_score;
   
   always @ (posedge clk) begin
     if (clear) begin cummulative_score <= 0; end
     if (start) begin start <= 0; end
     if (trigger && !store_trigger) begin store <= 1; end
     
     r_square <= dx*dx + dy*dy; store_trigger <= trigger; can_store <= store;
     // calculate score based on ranges
     if (r_square > 0 && r_square <= R_ONE ) score <= 20;
     else if (r_square > R_ONE && r_square <= R_TWO) score <= 10;
     else if (r_square > R_TWO && r_square <= R_THREE) score <= 5;
     else if (r_square > R_THREE && r_square <= R_FOUR) score <= 1;
     else score <= 0;
     
     if (can_store) begin // pipeline the store signal
       cummulative_score <= score + cummulative_score;
       start <= 1; store <= 0; can_store <= 0;
     end

     if (ready) score_text <= {d_1, d_10, d_100}; // make bits to be send to text display
   end

   
endmodule


module convert_bcd(
  input wire clock,
  input wire start,
  input wire [9:0] data,
  output wire [3:0] d,
  output wire [3:0] d10,
  output wire [3:0] d100,
  output wire ready);
  
  wire [9:0] remainder, hundreds, tens, ones;
  wire ready_one;
  // divide by 100
  divider #(.WIDTH(10)) divide_hundred(.clk(clock), .sign(1'b0), .start(start),
  .dividend(data), .divider(10'd100), .quotient(hundreds), .remainder(remainder),
  .ready(ready_one));
  // divide by 10
  divider #(.WIDTH(10)) divide_ten(.clk(clock), .sign(1'b0), .start(ready_one),
  .dividend(remainder), .divider(10'd10), .quotient(tens), .remainder(ones),
  .ready(ready));
  // assign outputs
  assign d = ones[3:0];
  assign d10 = tens[3:0];
  assign d100 = hundreds[3:0];
  
endmodule

  //From MIT 6.111 website
  //The divider module divides one number by another. It
  //produces a signal named "ready" when the quotient output
  //is ready, and takes a signal named "start" to indicate
  //the the input dividend and divider is ready.
  //sign -- 0 for unsigned, 1 for twos complement
  // It uses a simple restoring divide algorithm.
  // http://en.wikipedia.org/wiki/Division_(digital)#Restoring_division
module divider #(parameter WIDTH = 8)
                (input wire clk, sign, start,
                input wire [WIDTH-1:0] dividend,
                input wire [WIDTH-1:0] divider,
                output reg [WIDTH-1:0] quotient,
                output wire [WIDTH-1:0] remainder,
                output wire ready);
                
  reg [WIDTH-1:0] quotient_temp;
  reg [WIDTH*2-1:0] dividend_copy, divider_copy, diff;
  reg negative_output;
  assign remainder = (!negative_output) ? dividend_copy[WIDTH-1:0] : 
                              ~dividend_copy[WIDTH-1:0] + 1'b1;
  reg [5:0] bit;
  reg del_ready = 1;
  assign ready = (!bit) & ~del_ready;
  wire [WIDTH-2:0] zeros = 0;
  initial bit = 0;
  initial negative_output = 0;
  
  always @( posedge clk ) begin
    del_ready <= !bit;
    if( start ) begin
      bit = WIDTH;
      quotient = 0;
      quotient_temp = 0;
      dividend_copy = (!sign || !dividend[WIDTH-1]) ?{1'b0,zeros,dividend} :
                                                {1'b0,zeros,~dividend + 1'b1};
      divider_copy = (!sign || !divider[WIDTH-1]) ? {1'b0,divider,zeros} :
                                                  {1'b0,~divider + 1'b1,zeros};
      negative_output = sign &&((divider[WIDTH-1] && !dividend[WIDTH-1])
                        ||(!divider[WIDTH-1] && dividend[WIDTH-1]));
    end
    else if ( bit > 0 ) begin
      diff = dividend_copy - divider_copy;
      quotient_temp = quotient_temp << 1;
      if( !diff[WIDTH*2-1] ) begin
        dividend_copy = diff;
        quotient_temp[0] = 1'd1;
      end
      quotient = (!negative_output) ?
      quotient_temp :
      ~quotient_temp + 1'b1;
      divider_copy = divider_copy >> 1;
      bit = bit - 1'b1;
    end
  end
endmodule
