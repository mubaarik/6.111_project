/*
Basic video filter module. Applies various color filters to RGB data, and selects between outputs.
Filters (from value of "option" bus):
0 - none
1 - red tint
2 - blue tint
3 - grayscale
in_frame input makes display black outside of video area
*/

module video_filter(clk, rgb_in, option, rgb_out, in_frame);

   input clk;
   input [23:0] rgb_in;
   input [1:0] option;

   input in_frame;

   output reg [23:0] rgb_out;



   // Individual color components for RGB in/outs
   wire [7:0] r_in, g_in, b_in;
   assign r_in = rgb_in[23:16];
   assign g_in = rgb_in[15:8];
   assign b_in = rgb_in[7:0];

/*
   wire [7:0] r_out, g_out, b_out;
   assign r_out = rgb_out[23:16];
   assign g_out = rgb_out[15:8];
   assign b_out = rgb_out[7:0];
*/

   // Recalculate intensity value from RGB coefficients
   wire [7:0] intensity;
   assign intensity = (r_in >> 2) + (r_in >> 5)
                     + (g_in >> 1) + (g_in >> 4)
                     + (b_in >> 4) + (b_in >> 5);

   // Mux between outputs
   always @(posedge clk) begin
      if (~in_frame) begin
         rgb_out <= 24'b0;
      end
      else begin
         case (option)
            2'd1: rgb_out <= {r_in, g_in >> 2, b_in >> 2};
            2'd2: rgb_out <= {r_in >> 2, g_in >> 2, b_in};
            2'd3: rgb_out <= {intensity, intensity, intensity};
            default: rgb_out <= rgb_in;
         endcase
      end

   end // always


endmodule //video_filter
