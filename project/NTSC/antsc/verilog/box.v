/////////
////Module to display box around a region on the vga display
/////Mubarik Mohamoud
///////////
module bounding_box#(parameter HEIGHT=200, WIDTH=200, COLOR=8'hFF)(clock,params, hcount,width, x, vcount,height, y, pixel);
	input clock, params;
	input [10:0] x, hcount, width;
	input [9:0] y, vcount, height;
	output reg [7:0] pixel;
	reg [10:0] wdth;
	reg [9:0] hght;
	//parameter HALF_H = HEIGHT/2;
	//parameter HALF_W = WIDTH/2;
	always @(posedge clock) begin 
		hght=(params)?HEIGHT:height;
		wdth=(params)?WIDTH:width;
		if ((hcount==(x-(wdth>>1))|(hcount==(x+(wdth>>1))))&(vcount<=(y+(hght>>1))&(vcount>=(y-(hght>>1))))|(vcount==(y-(hght>>1))|(vcount==(y+(hght>>1))))&(hcount<=(x+(wdth>>1))&(hcount>=(x-(wdth>>1)))))
			pixel=COLOR;
		else pixel = 0;
	    end 
endmodule 
