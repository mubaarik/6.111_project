///////////////////////////////////////////////////////////////////////////////
//
// blob display module 
//
///////////////////////////////////////////////////////////////////////////////

module centroid_disp #(parameter HEIGHT=8, WIDTH=8, COLOR=8'hFF)  (reset, clk, hcount, vcount, x, y, pixel);
   input reset, clk;
   input [10:0] hcount, x;
   input [9:0] vcount, y;
   output reg [7:0] pixel; 
   
   always @ (posedge clk) begin
      if ((hcount >= x && hcount < (x+WIDTH)) &&(vcount >= y && vcount < (y+HEIGHT))) pixel = COLOR;
      else pixel = 0;
   end
   
endmodule
