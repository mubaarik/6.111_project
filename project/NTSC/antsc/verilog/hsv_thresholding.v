`timescale 1ns / 1ps
/////
///HSV thresholding 
//by Mubarik Mohamoud
///
//////
module hsv_thresh #(parameter h_high_thresh = 255, parameter s_high_thresh = 230,parameter v_high_thresh = 255,
	parameter h_low_thresh = 246, parameter s_low_thresh = 80, parameter v_low_thresh = 220)
	(clock,red, reset, H, S, V, color);
	input wire clock, red;
	input wire reset;
	input wire [7:0] H;
	input wire [7:0] S;
	input wire [7:0] V;
	output reg [7:0] color;
        ////Good blue 140<h<170, 80<s<255, 100<v<255
	////Good red hue_thr = ((H<=h_high_thresh)&(H>=h_low_thresh))|((H<=6)&(H>=0));246<h<255, 80<s<230, 220<v<255
	///orange 15<h>35, 70<s>230, and 220<v255
        wire hue_thr = red?((H<=h_high_thresh)&(H>=h_low_thresh))|((H<=6)&(H>=0)):((H<=h_high_thresh)&(H>=h_low_thresh));
	wire saturation_thre =(S<=s_high_thresh)&(S>=s_low_thresh);
	wire value_thr = (V<=v_high_thresh)&(V>=v_low_thresh);
	wire [2:0] threshold={hue_thr,saturation_thre,value_thr};
    always @(posedge clock) begin 
		if (threshold==3'b111) color<=255;
		else color<=0;
	end 
endmodule 
