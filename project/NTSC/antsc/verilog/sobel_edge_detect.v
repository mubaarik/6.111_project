module sobel (clk, reset, vclk, fvh, dv, pixel, pixel_out); 
  input 	 clk, reset;	// system clock
   input 	 vclk;	// video clock from camera
   input [2:0] 	 fvh;//hsync and vsync 
   input 	 dv;
   input [7:0] pixel; //black and white pixel
   output [7:0] pixel;

   parameter 	 COL_START = 10'd0;
	////////////
   parameter 	 ROW_START = 10'd0;

   reg [9:0] 	 col = 0;
   reg [9:0] 	 row = 0;
   reg [7:0] 	 vdata = 0;
   reg 		 old_frame;	// frames are even / odd interlaced
	reg frame_lag;
	

   reg frame_range, rect_range, lrect_range;
   wire lag_edge=old_frame&~frame_lag;
   wire 	 frame = fvh[2];
   wire 	 frame_edge = frame & ~old_frame;
   wire x_rdy, y_rdy;
   always @ (posedge vclk) begin
	if (reset) begin 
	height<=HEIGHT;
	last_height<=HEIGHT;
	width<=WIDTH;
	last_width<=WIDTH;end 
	
      old_frame <= frame;
      frame_lag<=old_frame;
      if (!fvh[2]) begin
	      col <= fvh[0] ? COL_START : (!fvh[2] && !fvh[1] && dv && (col < 1024)) ? col + 1 : col;
	      row <= fvh[1] ? ROW_START : (!fvh[2] && fvh[0] && (row < 768)) ? row + 2 : row;
	      vdata <= (dv && !fvh[2]) ? pixel : vdata;
end end 
endmodule
