module hit #(parameter HEIGHT = 16, WIDTH = 4, RADIUS=12, RADIUS1=10, COLOR = 24'hFFFFFF)
  		(input clk, input [10:0] x, hcount, input [9:0] y, vcount, output reg [23:0] pixel);
		initial begin 
		pixel<=0;
		end 
		
  		reg constrnt_x1[1:0], constrnt_x2[1:0], constrnt_y1[1:0], constrnt_y2[1:0],c_constrnt,c_constrnt1;
  		reg [10:0] deltax;
  		reg [9:0] deltay;
		
  		always @(posedge clk) begin 
  			deltax <= (hcount > x) ? (hcount-x) : (x-hcount);
  			deltay <= (vcount>y)?(vcount-y): (y-vcount);
			
  			c_constrnt<=(deltax*deltax+deltay*deltay<= RADIUS*RADIUS);
			c_constrnt1<=(deltax*deltax+deltay*deltay<= RADIUS1*RADIUS1);
			
  			{constrnt_x1[1],constrnt_x1[0]} <= {constrnt_x1[0],((hcount>=x-WIDTH)&(hcount<=x+WIDTH))};
  			{constrnt_x2[1],constrnt_x2[0]} <= {constrnt_x2[0],((hcount>=x-HEIGHT)&(hcount<=x+HEIGHT))};

  			{constrnt_y1[1],constrnt_y1[0]} <= {constrnt_y1[0],((vcount>=y-HEIGHT)&(vcount<=y+HEIGHT))};
  			{constrnt_y2[1],constrnt_y2[0]} <= {constrnt_y2[0],((vcount>=y-WIDTH)&(vcount<=y+WIDTH))};
			
			
  			if ((constrnt_x1[1]&&constrnt_y1[1])||(constrnt_x2[1]&&constrnt_y2[1])) pixel <= COLOR;
  			else if(c_constrnt&~c_constrnt1) pixel <= COLOR;
  			else pixel<=0;

  		end
endmodule 