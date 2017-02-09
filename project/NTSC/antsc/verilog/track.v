///////
//Module to bound region around a centroid with adjustable boxes

module track #(parameter HEIGHT=150, WIDTH=150, INCREMENT=10, TRACK_DIFF=10, TRACKBOUND_DIFF=30) 
	(clk, vclk, reset, fvh, dv, pixel, cx, cy, height, width);

   input 	 clk, reset;	// system clock
   input 	 vclk;	// video clock from camera
   input [2:0] 	 fvh;//hsync and vsync 
   input 	 dv;
   input [7:0] pixel; //black and white pixel
   input [10:0] cx;
   input [9:0] cy;
   output [10:0] width;
   output [9:0] height;
   
   reg [19:0] frame_count;
   reg [19:0] rect_count, lrect_count;
   reg [10:0] width, last_width;
   reg [9:0] height, last_height;
	/////
   parameter 	 COL_START = 10'd0;
	////////////
   parameter 	 ROW_START = 10'd0;

   reg [9:0] 	 col = 0;
   reg [9:0] 	 row = 0;
   reg [7:0] 	 vdata = 0;
   reg 		 old_frame;	// frames are even / odd interlaced
	reg frame_lag;
   reg [10:0] x_w_diff, x_w_sum, x_lw_diff, x_lw_sum, x_W_diff, x_W_sum;
   reg [9:0] y_h_diff, y_h_sum, y_lh_diff, y_lh_sum, y_H_diff, y_H_sum;

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
			//////////////////////
         //high_data<=(vdata==8'hF0);
			//high_x<=(sum_x>90);
			///////////////////////
			
        
		  
		  
      end
	   ////////////edge cases 
	   x_w_diff = (cx<width)?0:cx-width;
	   x_w_sum = (cx+width>524)?524:cx+width;

           y_h_diff = (cy<height)?0: cy-height;
           y_h_sum = (cy+height>524)?524: cy+height;


           x_lw_diff = (cx<last_width)?0:cx-last_width;
	   x_lw_sum = (cx+last_width>524)?524:cx+last_width;

           y_lh_diff = (cy<last_height)?0: cy-last_height;
           y_lh_sum = (cy+last_height>524)?524: cy+last_height;

	   
           x_W_diff = (cx<WIDTH)?0:cx-WIDTH;
	   x_W_sum = (cx+WIDTH>524)?524:cx+WIDTH;

           y_H_diff = (cy<HEIGHT)?0: cy-HEIGHT;
           y_H_sum = (cy+HEIGHT>524)?524: cy+HEIGHT;
	   ////////////Checking regions
	   frame_range = ((row>=(y_H_diff))&(row<=(y_H_sum)))&((col>=(x_W_diff))&(col<=(x_W_sum)));
	   rect_range = ((row>=y_h_diff)&(row<=y_h_sum))&((col>=x_w_diff)&(col<=x_w_sum));
	   lrect_range = ((row>=y_lh_diff)&(row<=y_lh_sum))&((col>=x_lw_diff)&(col<=x_lw_sum));
	   
           frame_count <=(frame_edge)?1:frame_range&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?frame_count+1:frame_count;
	   rect_count<=(frame_edge)?1:rect_range&frame_range&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?rect_count+1:rect_count;
	   lrect_count<=(frame_edge)?1:lrect_range&frame_range&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?lrect_count+1:lrect_count;
          if(frame_edge) begin 
		if(frame_count-rect_count<TRACKBOUND_DIFF) begin
		   height<=(height<=INCREMENT)?height:((lrect_count-rect_count)<TRACK_DIFF)?height-INCREMENT:height;
		   last_height<=(height<=INCREMENT)?last_height:((lrect_count-rect_count)<TRACK_DIFF)?height:last_height;

		end
		else begin 
		   height<=height+INCREMENT;
		   last_height<=last_height+INCREMENT;
		end 
		width<=height;
		last_width<=last_height;
		end 
	   
		
	
    end
   
 
endmodule 
