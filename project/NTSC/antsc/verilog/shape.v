////////
///line drawing module
///by Mubarik Mohamoud
///
//////


module get_shape#(parameter COLOR=8'hFF)(clk, hcount, start_x, end_x, vcount, start_y, end_y, pixel);
    input clk;
    input [10:0]   hcount, start_x, end_x;
    input [9:0] vcount, start_y, end_y;
    output reg [7:0] pixel;
    
    wire signed [10:0] _start_x,  _end_x;
	 wire signed [9:0]  _start_y,  _end_y;
    reg signed [10:0] deltax, dx;
    reg signed [9:0]  deltay, dy;
    reg right, down;
    
    reg signed [19:0] bx, by, _x, _y,diff,diff1, diff2;
    assign _start_x =start_x;
	 assign _start_y = start_y;
	 assign _end_y = end_y;
	 assign _end_x = end_x;

    //always @(posedge clk) begin 
    
    //end 
    always @(posedge clk) begin 
	     deltax = _start_x - _end_x;
        deltay = _start_y-_end_y;

        //right = deltax[10];
        //down = deltay[9];

        dx <= deltax;//(right)?(-deltax): deltax;
        dy <= deltay;//(down)?(-deltay): deltay;
        
        bx <= dy*start_x;
        by <= dx*start_y;
        _x<=dy*hcount;
        _y<=dx*vcount;
        
		  diff1 = _y -_x-by+bx;
		  diff2 = _x+by-bx-_y;
		  diff = (diff1[19])?diff2:diff1;
        if (diff>10) pixel<=0;
        else pixel <=COLOR; 
	end
  
endmodule 
