///////
///Module to display co-centric circles on the Vga display
//by Mubarik Mohamoud
//////

module circles #(parameter RADIUS = 384, RADIUS1 = 288, RADIUS2 = 192, RADIUS3=96, COLOR = 24'h61_61_61, COLOR1 = 24'hFF_00_00, COLOR2 = 24'hFF_8F_00, COLOR3 = 24'h8F_FF_00, COLOR4=24'h00_FF_00, COLOR5 = 24'hFF) 
 (input clk, input [10:0] x,x1,x2,x3, hcount, input [9:0] y,y1,y2,y3, vcount, output reg [23:0] pixel);

  reg [10:0] deltax, deltax1, deltax2, deltax3;
  reg [9:0] deltay, deltay1, deltay2, deltay3;
  reg constraint,constraint1,constraint2,constraint3, constraint4;
  reg rect, rect1, rect2, rect3;   
  always @ (posedge clk)  begin
	
	// compute x-xcenter and y-ycenter
	rect <= ((hcount<=187)&(vcount<=187));
	rect1<=((hcount<=187)&(vcount>=580));
	rect2<=((hcount>=840)&(vcount<=187));
	rect3<=((hcount>=840)&(vcount>=580));
	// RADIUS is a paramater
	deltax <= (hcount > (x+RADIUS)) ? (hcount-(x+RADIUS)) : ((x+RADIUS)-hcount);
	deltay <= (vcount > (y+RADIUS)) ? (vcount-(y+RADIUS)) : ((y+RADIUS)-vcount);
	
	deltax1 <= (hcount > (x1+RADIUS1)) ? (hcount-(x1+RADIUS1)) : ((x1+RADIUS1)-hcount);
	deltay1 <= (vcount > (y1+RADIUS1)) ? (vcount-(y1+RADIUS1)) : ((y1+RADIUS1)-vcount);

	deltax2 <= (hcount > (x2+RADIUS2)) ? (hcount-(x2+RADIUS2)) : ((x2+RADIUS2)-hcount);
	deltay2 <= (vcount > (y2+RADIUS2)) ? (vcount-(y2+RADIUS2)) : ((y2+RADIUS2)-vcount);
        
	deltax3 <= (hcount > (x3+RADIUS3)) ? (hcount-(x3+RADIUS3)) : ((x3+RADIUS3)-hcount);
	deltay3 <= (vcount > (y3+RADIUS3)) ? (vcount-(y3+RADIUS3)) : ((y3+RADIUS3)-vcount);
	
	constraint<=(deltax*deltax+deltay*deltay <= RADIUS*RADIUS);
	constraint1<=(deltax1*deltax1+deltay1*deltay1 <= RADIUS1*RADIUS1);
	constraint2<=(deltax2*deltax2+deltay2*deltay2 <= RADIUS2*RADIUS2);
	constraint3<=(deltax3*deltax3+deltay3*deltay3 <= RADIUS3*RADIUS3);
	constraint4<=rect|rect1|rect2|rect3;
	// check if distance is less than radius squared
	casez({constraint4,constraint3,constraint2,constraint1, constraint})
	   5'bz1zzz: pixel<=COLOR4;
	   5'bz01zz: pixel<=COLOR3;
	   5'bz001z: pixel<=COLOR2;
	   5'bz0001: pixel<=COLOR1;
		5'b10000: pixel<=COLOR5;
	   5'b0: pixel<=COLOR;
	   default: pixel<=COLOR;
	endcase
end
endmodule 
