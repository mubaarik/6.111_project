//////
///module to perform the dialation operation
///Mubarik Mohamoud
//////
module dialate (clk, vclk, fvh, dv, pixel, d_pixel);
	input 	 clk;	// system clock
   input 	 vclk;	// video clock from camera
   input [2:0] 	 fvh;//hsync and vsync 
   input 	 dv;
   input [7:0] pixel;
   output reg [7:0] d_pixel;


   parameter 	 COL_START = 10'd0;
   parameter 	 ROW_START = 10'd0;

   // here put the luminance data from the ntsc decoder into the ram
   // this is for 1024 * 788 XGA display

   reg [9:0] 	 col = 0;
   reg [9:0] 	 row = 0;
   reg [7:0] 	 vdata = 0;
   reg 		 old_frame;	// frames are even / odd interlaced
   reg old_hsync;

   wire hsync_edge = fvh[0]&~old_hsync;
   wire 	 frame = fvh[2];
   wire 	 frame_edge = frame & ~old_frame;
   ///storing lines for dialation check 
   /// the pixels will be diagnolly shifted in this algorthm
   reg [524:0] line1=0;
   reg [524:0] line2=0;
   reg [524:0] line=0;
   reg high;

   always @ (posedge vclk) //LLC1 is reference
   begin
	    old_hsync<=fvh[0];
	    old_frame <= frame;

	    if (!fvh[2]) begin
	     col <= fvh[0] ? COL_START : (!fvh[2] && !fvh[1] && dv && (col < 1024)) ? col + 1 : col;
	     row <= fvh[1] ? ROW_START : (!fvh[2] && fvh[0] && (row < 768)) ? row + 2 : row;
	     vdata <= (dv && !fvh[2]) ? pixel : vdata;

	     line1<=(hsync_edge)?line: line1;
	  	 line2<=(hsync_edge)?line1: line2;

	  	 line[col]<=(col>500)?0:(!fvh[2] && !fvh[1] && dv)?((vdata==8'hFF)?1:0):line[col];

	  end
	  high = (line1[col]|line1[col-1]|line1[col-2]|line[col]|line[col-1]|line[col-2]|line2[col]|line2[col-1]|line2[col-2]);
	  //high = (line[col]&line[col-1]&line[col-2]);
	  if ((col<3)||(row<3)) d_pixel<=vdata;
	  else if(high) d_pixel<=(high)?8'hFF:8'h0;
     end
endmodule 
