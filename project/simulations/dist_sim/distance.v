module dist(clk, x_start, x_end, y_start, y_end, sum_sqrs, distance);
    input clk;
    input [10:0] x_start, x_end;
    input [9:0] y_start, y_end;
    output reg [11:0] distance;
	 output [21:0] sum_sqrs;
    
    reg [10:0] dx, manhattan;
    reg [9:0] dy;
    reg [21:0] square_x, square_y, sum_sqrs;
    wire [11:0] dist;
    wire rdy;
  
    always @(posedge clk) begin
	     dx <= (x_start>=x_end)?(x_start-x_end):(x_end - x_start);
        dy <= (y_start>=y_end)?(y_start-y_end):(y_end - y_start);
        square_x<=dx*dx;
		  square_y<=dy*dy;
		  sum_sqrs<= square_x+square_y;
	 end 
    
     
     sqrt sqrt1(.x_in(sum_sqrs), .clk(clk), .x_out(dist), .rdy(rdy) );
    always @(posedge clk) distance<=(rdy)?dist:distance;
endmodule 
