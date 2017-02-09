`timescale 1ns / 1ps
`default_nettype none 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:38:32 11/26/2016 
// Design Name: 
// Module Name:    text_display 
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
module text_display
       #(parameter COLOR=24'hFF_FF_FF, WIDTH=31, HEIGHT=31, READ_WIDTH=31)
        (input wire [10:0] x, hcount,input wire [9:0] y, vcount, 
         input wire [5:0] alphabet_num,input wire clk, output reg [23:0] pixel);
       
  // alphabet_num is a number in [1,26] representing A-Z, [27,52] a-z, [53,62] 0-9
  
  wire [10:0] address;
  wire [10:0] x_index;
  wire in_x_range, in_y_range;
  wire [READ_WIDTH-1:0] dout; // dout2,dout3,dout4;

  letters let(.clka(clk), .addra(address), .douta(dout));

  assign in_y_range = (vcount >= y) && (vcount < y+HEIGHT);
  assign in_x_range = (hcount >= x) && (hcount < x+WIDTH);
  
  assign address = (vcount-y+1) + ((alphabet_num-1)*HEIGHT);
  assign x_index = (x-hcount+1);
  
  always @ (posedge clk) begin

    if (in_x_range && in_y_range) begin
        // read from rom to fill the color
        pixel <= dout[x_index] ? COLOR : 0;
    end   
    else pixel <= 0;    
  end
  
endmodule


// This module can't tell the difference between zero (A) and no text. 
// For this reason, shift all letter indexes up by 1. 1->A etc.

module multiple_text (input wire [95:0] text, // texts comes in 6 bit spaces and start first 
                                                // letter in the lowest 6 bits. 16 letters possible
                       input wire [10:0] x, hcount, input wire [9:0] y, vcount,
                       input wire clk, output wire [23:0] pixel);

    parameter MAX_LETTERS = 16;
    parameter CHAR_LEN = 31;
    parameter CHAR_BITS = 6;
    
    reg [5:0] texts[MAX_LETTERS-1:0];
    wire [23:0] pixels[MAX_LETTERS:0];
    
    assign pixels[0] = 0;
            
    integer idx;
    always @ (posedge clk) begin
      // fill arrays with 6 bits for each letter
      for (idx = 0; idx < MAX_LETTERS; idx=idx+1) begin
        texts[idx] <= text[idx*CHAR_BITS+:6];
      end
    end

    genvar i;
    generate 
      for (i=0; i < MAX_LETTERS; i=i+1) begin : generate_letters
        wire [23:0] temp_pixel;       
        // each letter starts 23 pixels from the start of the previous
        text_display single_text(.x(x+(i*23)), .y(y), .hcount(hcount), 
                          .vcount(vcount),.alphabet_num(texts[i]), 
                          .clk(clk), .pixel(temp_pixel));
        // add pixel if a character exists in register
        assign pixels[i+1] = (texts[i] == 0) ? pixels[i] : temp_pixel | pixels[i];
      end
    endgenerate
    
    assign pixel = pixels[MAX_LETTERS];

endmodule
