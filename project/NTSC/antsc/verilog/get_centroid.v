///////
///Centroid calculation
///If bound is 0 it calculates the centroid of the whole frame
///if bound is 1  it calculates the centroid of region bounded by h, and w.
////if bound is 2 it calculates the centroid of qaudrant 1 centered at _x, and _y
////if bound is 3 second quadrant and so on
////Mubarik
/////////
module get_centroid #(parameter HEIGHT=200,WIDTH=200) (clk, vclk, fvh, dv,_x,_y,bound,h,w, pixel, cx, cy);

   input     clk; // system clock
   input     vclk;   // video clock from camera
   input [2:0]     fvh, bound;//hsync and vsync, bound indicates whether to calculate the centroid of bounded region and which region
   input [10:0] _x;
   input [9:0] _y,w,h;
   input     dv;
   input [7:0] pixel; //black and white pixel
   output reg [10:0] cx;
   output reg [9:0] cy;
   //////////
   reg [31:0] x_hold;
   reg [31:0] y_hold;
   reg [31:0] count_hold;
   
   reg [31:0] sum_x, sum_x1;
   reg [31:0] sum_y, sum_y1;
   reg [31:0] white_count, white_count1;
   reg high_data;
   wire [31:0] x,y;
   /////
   parameter    COL_START = 10'd0;
   ////////////
   parameter    ROW_START = 10'd0;

   reg [9:0]    col = 0;
   reg [9:0]    row = 0;
   reg [7:0]    vdata = 0;
   reg       old_frame; // frames are even / odd interlaced
   reg frame_lag, in_box;
   reg [10:0] w_x_diff, w_x_sum, x_plus_w, x_minus_w;
   reg [9:0]  h_y_diff, h_y_sum, y_plus_h, y_minus_h;
      

  
   wire lag_edge=old_frame&~frame_lag;
   wire   frame = fvh[2];
   wire   frame_edge = frame & ~old_frame;
   wire x_rdy, y_rdy;
   always @ (posedge vclk) begin
   
      old_frame <= frame;
      frame_lag<=old_frame;
      if (!fvh[2]) begin
         col <= fvh[0] ? COL_START : (!fvh[2] && !fvh[1] && dv && (col < 1024)) ? col + 1 : col;
         row <= fvh[1] ? ROW_START : (!fvh[2] && fvh[0] && (row < 768)) ? row + 2 : row;
         vdata <= (dv && !fvh[2]) ? pixel : vdata;
         //////////////////////
         high_data<=(vdata==8'hF0);
         //high_x<=(sum_x>90);
         ///////////////////////
         
      end 
      
      //////Selecting the regiong to calculate the center for
      case(bound)
         3'b0: begin
            sum_x <=(frame_edge)?0:((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF))?sum_x+col: sum_x;
            sum_y <=(frame_edge)?0:((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?sum_y+row: sum_y;
            white_count <=(frame_edge)?1:((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?white_count+1:white_count;
         end 
         3'b1: begin
            x_plus_w=_x+w;
            x_minus_w = _x-w;
            y_plus_h  = _y+h;
            y_minus_h = _y-h;

            w_x_diff = (_x<=w)?0:x_minus_w;
            w_x_sum = (x_plus_w>624)?624: x_plus_w;

            h_y_diff = (_y<=h)?0:y_minus_h;
            h_y_sum = (y_plus_h>624)?624:y_plus_h;
            in_box = (((col>=w_x_diff)&(col<=x_plus_w))&((row>=h_y_diff)&(row<=y_plus_h)));
            
            sum_x <= (frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF)))?sum_x+col: sum_x;
            sum_y<=(frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?sum_y+row: sum_y;
            white_count<=(frame_edge)?1:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?white_count+1:white_count;
         end 
         3'b10: begin 
            in_box = ((col>_x)&(row<_y));
            
            sum_x <= (frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF)))?sum_x+col: sum_x;
            sum_y<=(frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?sum_y+row: sum_y;
            white_count<=(frame_edge)?1:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?white_count+1:white_count;
         end 
         3'b11: begin
            in_box = ((col<_x)&(row<_y));
            
            sum_x <= (frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF)))?sum_x+col: sum_x;
            sum_y<=(frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?sum_y+row: sum_y;
            white_count<=(frame_edge)?1:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?white_count+1:white_count;
         end 
         3'b100: begin
            in_box = ((col<_x)&(row>_y));
            
            sum_x <= (frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF)))?sum_x+col: sum_x;
            sum_y<=(frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?sum_y+row: sum_y;
            white_count<=(frame_edge)?1:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?white_count+1:white_count;
         end 
         3'b101:begin
            in_box = ((col>_x)&(row>_y));
            
            sum_x <= (frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF)))?sum_x+col: sum_x;
            sum_y<=(frame_edge)?0:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?sum_y+row: sum_y;
            white_count<=(frame_edge)?1:(in_box&&((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF)))?white_count+1:white_count;
         end 
         default:begin
            sum_x <=(frame_edge)?0:((!fvh[2] && !fvh[1] && dv &&(col < 1024))&&(vdata==8'hFF))?sum_x+col: sum_x;
            sum_y <=(frame_edge)?0:((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?sum_y+row: sum_y;
            white_count <=(frame_edge)?1:((!fvh[2] && !fvh[1] && dv&&(col < 1024))&&(vdata==8'hFF))?white_count+1:white_count;
         end 
         
         
      endcase 
      ////////////////
 
           ///holding the values for the dividers 
      x_hold<=(frame_edge)?sum_x:x_hold;
      y_hold<=(frame_edge)?sum_y:y_hold;
      count_hold<=(frame_edge)?white_count:count_hold;
      
      ///Updating the centroids
      cx <= (x_rdy)?x[10:0]:cx;
      cy <= (y_rdy)?y[9:0]:cy;
    end
  ///wire [31:0] x,y, 
  wire [31:0] x_rem,y_rem;
  
 
  core_divider core1(.clk(vclk),.dividend(x_hold),.divisor(count_hold),.quot(x),.remd(x_rem),.rfd(x_rdy));
  core_divider core2(.clk(vclk),.dividend(y_hold),.divisor(count_hold),.quot(y),.remd(y_rem),.rfd(y_rdy));
endmodule 
