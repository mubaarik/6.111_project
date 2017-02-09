`timescale 1ns / 1ps
//
module erosion (clock,reset,hcount,vcount, color, pixel);
	input wire clock;
	input wire reset;
	input [10:0] hcount;
	input [9:0] vcount;
	input [7:0] color;
	output reg pixel;
	reg [1023:0] pixel_arr [767:0];
	reg [1023:0] eroded [767:0];
	reg [1023:0] accumul=0;
	reg [6:0] to_erode;
	wire start=(hcount==0&vcount==0);
        wire stop= (hcount==764);
	reg erode;
    always @(posedge clock) begin 
	erode = (start)?1:(stop)?0:erode;
	if(erode)begin  
    	eroded[hcount]=pixel_arr[hcount];
	   eroded[hcount+1]=pixel_arr[hcount+1];
	   eroded[hcount+2]=pixel_arr[hcount+2];
	   eroded[hcount+3]=pixel_arr[hcount+3];
	   eroded[hcount+4]=pixel_arr[hcount+4];
	end 
	if(hcount==1023&vcount<=767) pixel_arr[vcount]<=accumul;
	casez({color==8'hFF, hcount>0&hcount<1023, vcount>0&vcount<767})
	   3'b111: begin 
			
	      to_erode[0] = eroded[hcount][vcount];//eroded[hcount-1][vcount-1];//{, , ,, eroded[hcount][vcount+1], eroded[hcount+1][vcount+1], eroded[hcount+1][vcount]};
			to_erode[1] = 1;//eroded[hcount-1][vcount];
			to_erode[2] = 1;//eroded[hcount][vcount-1];
			to_erode[6:3] = 4'b1111;

	      accumul[hcount]<=1'b1;
	      pixel<=(to_erode==7'b1111111)?pixel<=255: pixel<=0;
	    end
	   3'b0zz:begin
	      //pixel_arr[hcount][vcount]<=1'b0;
	      accumul[hcount]<=1'b10;
	      pixel<=0;

	   end 
	   default: begin 
	      //pixel_arr[hcount][vcount]<=1'b0;
	      accumul[hcount]<=1'b10;
	      pixel<=0;
	   end 
	endcase
	end 
endmodule 
