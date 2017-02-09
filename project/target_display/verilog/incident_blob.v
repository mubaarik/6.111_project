`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:45:12 11/28/2016 
// Design Name: 
// Module Name:    incident_blob 
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
module incident_blob #(parameter SHOT_LIMIT=20)
     (input wire clk, clear, trigger, input wire [10:0] x, input wire [9:0] y,
      input wire [10:0] hcount, input wire [9:0] vcount, output reg [23:0] pixel=0,
		output see_counting);

  parameter WAIT_TIME = 32_500_000 >> 1; // on 64mhz clk
  parameter IDLE = 0;
  parameter WAIT = 1;
  
  // array to store bullet positions
  reg [10:0] bullet_x[SHOT_LIMIT-1:0]; 
  reg [9:0] bullet_y[SHOT_LIMIT-1:0];
  // store if an array slot has a bullet in it (to distinguish from a bullet at pos 0,0)
  reg [SHOT_LIMIT-1:0] has_bullet;
  //reg [23:0] pixel = 0;
  reg [SHOT_LIMIT >> 1:0] pointer=0;
  reg store_trigger = 0;
  reg [10:0] store_x=0;
  reg [9:0] store_y=0;
  reg [31:0] counter=0;
  reg state = IDLE;
  reg counting;
  wire reset;
  wire [23:0] bullet_pixel[SHOT_LIMIT:0];
  
  assign bullet_pixel[0] = 0;
  assign reset = clear;
  assign see_counting = counting;

  
  integer idx;
  always @(posedge clk) begin
  
    store_trigger <= trigger;
	 
    if (clear || (pointer >= SHOT_LIMIT)) begin 
      pointer <= 0; has_bullet <= 0; state <= IDLE;
      for (idx=0; idx<SHOT_LIMIT; idx=idx+1) begin
        bullet_x[idx] <= 0; bullet_y[idx] <= 0;
      end
    end
    
    case(state)
      IDLE: begin
        if (trigger && !store_trigger) begin
          bullet_x[pointer] <= x; bullet_y[pointer] <= y; 
          has_bullet[pointer] <= 1'b1; // shows that bullet exists here
          pointer <= pointer + 1; // store_x <= x; store_y <= y;
          
          state <= WAIT; counting <= 1;
        end
        else state <= IDLE;
      end
      
      WAIT: begin
		  if (counter >= WAIT_TIME) begin
			  state <= IDLE;
			  counting <= 0;
		  end 
		  else begin
		     state <= WAIT;
			  counting <= 1;
		  end

      end
      
      default: begin end // do nothing
    endcase
	 
	 if (counting)begin
	   counter <= counter + 1;
	 end
	 else counter <= 0;
    
  end
  
  // use the array to make blobs
  genvar i;
  generate
    for (i=0; i<SHOT_LIMIT; i=i+1) begin: display_shot
      wire [23:0] current_pixel;
      hit hit_blob(.clk(clk),.x(bullet_x[i]),.y(bullet_y[i]),.hcount(hcount), 
                       .vcount(vcount),.pixel(current_pixel));
      assign bullet_pixel[i+1] = (clear)? 0: ((has_bullet[i]) ? current_pixel | bullet_pixel[i] :
                                    bullet_pixel[i]);
    end
  endgenerate
  always @(posedge clk)
     pixel <= bullet_pixel[SHOT_LIMIT];
	  
endmodule

/*module incident_blob #(parameter SHOT_LIMIT=20)
     (input wire clk, clear, trigger, input wire [10:0] x, input wire [9:0] y,
      input wire [10:0] hcount, input wire [9:0] vcount, output [23:0] pixel);

  parameter HALF_SECOND = 32_500_000; // on 64mhz clk
  
  // array to store bullet positions
  reg [10:0] bullet_x[SHOT_LIMIT-1:0]; 
  reg [9:0] bullet_y[SHOT_LIMIT-1:0];
  // store if an array slot has a bullet in it (to distinguish from a bullet at pos 0,0)
  reg [SHOT_LIMIT-1:0] has_bullet;
  
  reg [SHOT_LIMIT >> 1:0] pointer;
  reg store_trigger = 0;
  reg [10:0] store_x=0;
  reg [9:0] store_y=0;
  reg [31:0] counter;
  // use write_enabled to make blob positioning robust to fluctuations in data read from ir transmission
  reg store_we,write_enabled, counting; 
//  wire start_timer, expired;
  wire [21:0] bullet_pos;
  wire [23:0] bullet_pixel[SHOT_LIMIT:0];
  
  
  assign bullet_pixel[0] = 0;
           
  integer idx;
  always @(posedge clk) begin
    //counting <= counting ? counting : store_we && !write_enabled;
    store_trigger <= trigger; store_we <= write_enabled;
    // only write in intervals of half seconds since ir sends a lot of redundant data
    // if (counter >= HALF_SECOND) begin write_enabled <= 1; counter <= 0; end    
    if (clear || (pointer >= SHOT_LIMIT)) begin 
      pointer <= 0; 
      has_bullet <= 0;
      for (idx=0; idx<SHOT_LIMIT; idx=idx+1) begin
        bullet_x[idx] <= 0; bullet_y[idx] <= 0;
      end
    end
    
    // detect rising edge of trigger pulse
    else if (trigger && !store_trigger) begin
      // only add unique positions since we are transmitting streams of possibly 
      // redundant positions
       //  if (write_enabled) begin
       //if ({x,y} != {store_x, store_y}) begin
          bullet_x[pointer] <= x; bullet_y[pointer] <= y; 
          has_bullet[pointer] <= 1'b1; // shows that bullet exists here
          pointer <= pointer + 1;
          store_x <= x; store_y <= y;
          // write_enabled <= 0;
       //end
    end
    
  end
  
  // use the array to make blobs
  genvar i;
  generate
    for (i=0; i<SHOT_LIMIT; i=i+1) begin: display_shot
      wire [23:0] current_pixel;
      hit h1(.clk(clk), .x(bullet_x[i]), .hcount(hcount), .y(bullet_y[i]), .vcount(vcount), .pixel(current_pixel));
      assign bullet_pixel[i+1] = has_bullet[i] ? current_pixel | bullet_pixel[i] : bullet_pixel[i];
    end
  endgenerate
  assign pixel = bullet_pixel[SHOT_LIMIT];
endmodule
*/