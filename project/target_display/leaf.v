`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:50:33 12/11/2016 
// Design Name: 
// Module Name:    leaf 
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

module leaf
     #(parameter WIDTH = 315,     // default picture width
      HEIGHT = 262)     // default picture height
     (input clk, input [10:0] x,hcount, input [9:0] y,vcount, 
      output reg [23:0] pixel);
      
     wire [16:0] image_addr; 
     wire [7:0] image_bits;
     wire [23:0] mapped;
     wire inrange1, inrange2;
     reg [16:0] addr;
          
     assign inrange1 = ((hcount >= x && hcount < (x+WIDTH)) 
                         && (vcount >= y && vcount < (y+HEIGHT)));
                         
     assign inrange2 = ((hcount >= (x + WIDTH) && hcount < (x+(2*WIDTH)))
                         && (vcount >= y && vcount < (y+HEIGHT))); 
                        
                       
     always @ (posedge clk) begin
        addr <= (vcount-y) * WIDTH;
        if (inrange1 || inrange2)  pixel <= mapped;  
        else pixel <= 0;
     end   
     
     // calculate rom address and read the location. 2d image was converted to 1d
     assign image_addr = inrange1 ? (hcount-x) + addr:
                         (inrange2 ? ((hcount-x-WIDTH) + addr):0);
     
     // get map address
     black_leaf_img rom1(.clka(clk), .addra(image_addr), .douta(image_bits)); 
     
     // use color map to create RGB     
     black_leaf_map map_leaf(.clka(clk), .addra(image_bits), .douta(mapped));  

     
endmodule
