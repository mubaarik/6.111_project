module center_calc(clk,inframe, hcount, vcount,pixel, cx,cy);
   input clk, inframe;
   input [10:0] hcount;
   input [9:0] vcount;
   input [7:0] pixel;
   output reg [10:0] cx;
   output reg [9:0] cy;
   
   wire divide = (hcount==990 & vcount==767);
   reg [31:0] sum_x, sum_y;
   reg [19:0] white_count;
   reg [10:0] last_hcount;
   reg [9:0] last_vcount;
   wire ready,ready1;
   reg last_ready,last_ready1;
   wire reset = (hcount ==0 & vcount==0); 
   always @ (posedge clk) begin
      last_ready<=ready;
		last_ready1<=ready1;
      last_hcount<=hcount;
      last_vcount<=vcount;
      if (reset) begin 
		  sum_x<= 0;
		  sum_y<=0;
	     white_count<=0;
		end 
  else if ((hcount<=1023 & vcount<=767)) begin
	
	sum_x<=(pixel==8'hFF)?sum_x+hcount:sum_x;
	sum_y<=(pixel==8'hFF)?sum_y+vcount: sum_y;
	white_count<=(pixel==8'hFF)?white_count+1:white_count;
	
	 
	end 
   end
	wire [31:0] x, remainder1,remainder2 , y;

  _divider #(.WIDTH(32)) 
 div1 (.clk(clk), .sign(0), .start(divide),
   .dividend(sum_x), .divisor({12'b0, white_count}),
   .quotient(x), .remainder(remainder1),.ready(ready));

  _divider #(.WIDTH(32)) 
 div2 (.clk(clk), .sign(0), .start(divide),
   .dividend(sum_y), .divisor({12'b0, white_count}),
   .quotient(y), .remainder(remainder2),.ready(ready1));
	
	//core_divider core4(.clk(vclk),.dividend(x_hold),.divisor(count_hold),.quot(x),.remd(x_rem),.rfd(x_rdy));
	//core_divider core5(.clk(vclk),.dividend(y_hold),.divisor(count_hold),.quot(y),.remd(y_rem),.rfd(y_rdy));
 always @(posedge clk) begin
	cx<=(ready)?x[10:0]: cx;
	cy<=(ready1)?y[9:0]: cy;
	end
endmodule
