module transform #(parameter HEIGHT=525, WIDTH=525) 
	(clk,start, t_height, t_width, x, y, cv_x, cv_y);
     input clk, start;
     input [10:0] t_width, x;
     input [9:0]  t_height, y;
     output reg [12:0] cv_x;
     output reg [12:0] cv_y;
     
     reg [10:0] w_x_diff;
     reg [9:0] h_y_diff;
     reg [21:0] x_prod;
     reg [21:0] y_prod;
     
     wire rdy_x, rdy_y;
     wire [21:0] remdx, remdy, x_val, y_val;
     always @(posedge clk) begin 
     	w_x_diff <= (x>=(WIDTH/2))?(x-(WIDTH/2)):((WIDTH/2)-x);
     	h_y_diff<=(y>=(HEIGHT/2))?(y-(HEIGHT/2)):((HEIGHT/2)-y);

     	x_prod<=w_x_diff*WIDTH;
     	y_prod<=h_y_diff*HEIGHT;
        
        cv_x<=(rdy_x)?x_val[12:0]:cv_x;
        cv_y<=(rdy_y)?y_val[12:0]:cv_y;

     end
    n20_divider divx( .clk(clk),.start(start),
	.dividend(x_prod),.divisor({9'b0,width}),
	.quotation(x_val),.remainder(remdx),
	.rfd(rdy_x));
   n20_divider divy(
	.clk(clk),
	.start(start),
	.dividend(y_prod),
	.divisor({9'b0,height}),
	.quotation(y_val),
	.remainder(remdy),
	.rfd(rdy_y));



endmodule 
