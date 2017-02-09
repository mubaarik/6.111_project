module centroid(clk, vclk, fvh, dv, din, c_x, c_y);

   input 	 clk;	// system clock
   input 	 vclk;	// video clock from camera
   input [2:0] 	 fvh;
   input 	 dv;
   input [7:0] 	 din;
   output [10:0] c_x;
   output [9:0] c_y;
   parameter 	 COL_START = 10'd00;
   parameter 	 ROW_START = 10'd00;
   
   reg [32:0] sum_x = 0;
   reg [32:0] sum_y = 0;
   reg [19:0] white_count=0;
   // here put the luminance data from the ntsc decoder into the ram
   // this is for 1024 * 788 XGA display

   reg [9:0] 	 col = 0;
   reg [9:0] 	 row = 0;
   reg [17:0] 	 vdata = 0;
   reg 		 vwe;
   reg 		 old_dv;
   reg 		 old_frame;	// frames are even / odd interlaced
   reg 		 even_odd;	// decode interlaced frame to this wire
   
   wire 	 frame = fvh[2];
   wire 	 frame_edge = frame & ~old_frame;

   always @ (posedge vclk) //LLC1 is reference
     begin
	old_dv <= dv;
	vwe <= dv && !fvh[2] & ~old_dv; // if data valid, write it
	old_frame <= frame;
	even_odd = frame_edge ? ~even_odd : even_odd;

	if (!fvh[2])
	  begin
	     col <= fvh[0] ? COL_START : 
		    (!fvh[2] && !fvh[1] && dv && (col < 1024)) ? col + 1 : col;
	     row <= fvh[1] ? ROW_START : 
		    (!fvh[2] && fvh[0] && (row < 768)) ? row + 1 : row;
	     vdata <= (dv && !fvh[2]) ? din : vdata;
	  end
     end

reg [9:0] x[1:0],y[1:0];
   //reg [7:0] data[1:0];
reg [7:0] data[1:0];

always @(posedge clk)
begin
   {x[1],x[0]} <= {x[0],col};
   {y[1],y[0]} <= {y[0],row};
   {data[1],data[0]} <= {data[0],vdata};
end
reg [9:0] last_x;
wire divide=((x[1]==990)&(y[1]==767));

wire ready,ready1;
reg last_ready,last_ready1;

always @(posedge clk) begin
     last_ready<=ready;
     last_ready1<=ready1;
     last_x<=x[1];
     if (vwe) begin 
      sum_x<=(x[1]>88)?sum_x+x[0]:sum_x;
      sum_y<=(x[1]>99)?sum_y+y[0]:sum_y;
      white_count<=(x[1]>88)?white_count+1:white_count;
    end 
end 
wire [31:0] _x, remainder1,remainder2 , _y;

  _divider #(.WIDTH(32)) 
 div1 (.clk(clk), .sign(0), .start(divide),
   .dividend(sum_x), .divisor({12'b0, white_count}),
   .quotient(_x), .remainder(remainder1),.ready(ready));

  _divider #(.WIDTH(32)) 
 div2 (.clk(clk), .sign(0), .start(divide),
   .dividend(sum_y), .divisor({12'b0, white_count}),
   .quotient(_y), .remainder(remainder2),.ready(ready1));
assign c_x=(last_ready!=ready & ready)?_x[10:0]: c_x;
assign c_y=(last_ready1!=ready1 & ready1)?_y[9:0]: c_y;
   
endmodule 
