`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:29:07 12/10/2016 
// Design Name: 
// Module Name:    keyboard 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module keyboard(input wire clk, reset, kbd_clk, data, output reg kbd_start,
                 output wire [59:0] name, output reg backspace, enter);

   parameter IDLE=0;
   parameter ADD_LETTER=1;
   
   initial begin
     kbd_start = 0; backspace = 0; enter = 0;
   end
   
   reg state=IDLE;
   wire kbd_ready, restart;
   reg [3:0] pointer=0;
   wire [5:0] curr_let;
   reg [5:0] l1, l2, l3, l4, l5, l6, l7, l8, l9, l10;
   
   wire [7:0] ascii;
   
   kbd_ascii_input kbd(.clock_27mhz(clk), .reset(reset), .clock(kbd_clk), 
                    .data(data), .ascii(ascii), .ascii_ready(kbd_ready));
                
   assign curr_let = ascii[5:0] + 1; // shift ascii values up by 1 to distinguish empty space from A.
   assign name = {l10, l9, l8, l7, l6, l5, l4, l3, l2, l1};
   assign restart = reset;
   
   always @ (posedge kbd_ready) begin
     
     if (ascii==99) begin // enter
       enter <= ~enter;
       l1 <= 0; l2 <= 0; l3 <= 0; l4 <= 0; l5 <= 0; l6 <= 0;
       l7 <= 0; l8 <= 0; l9 <= 0; l10 <= 0; pointer <= 0; 
     end
     else if (ascii == 98 && pointer > 0) begin // backspace
        backspace <= ~backspace;
        case(pointer)
          4'd1: l1 <= 0;
          4'd2: l2 <= 0;
          4'd3: l3 <= 0;
          4'd4: l4 <= 0;
          4'd5: l5 <= 0;
          4'd6: l6 <= 0;
          4'd7: l7 <= 0;
          4'd8: l8 <= 0;
          4'd9: l9 <= 0;
          default: begin l10 <= 0; end
        endcase
        pointer <= pointer - 1;
     end
   
     else if (ascii < 62 && pointer < 10) begin
        // toggle signals were more reliable than pulses
        kbd_start <= ~kbd_start;
        
        case(pointer)
          4'd0: l1 <= curr_let;
          4'd1: l2 <= curr_let;
          4'd2: l3 <= curr_let;
          4'd3: l4 <= curr_let;
          4'd4: l5 <= curr_let;
          4'd5: l6 <= curr_let;
          4'd6: l7 <= curr_let;
          4'd7: l8 <= curr_let;
          4'd8: l9 <= curr_let;
          4'd9: l10 <= curr_let;
          default: begin end
        endcase
     
        pointer <= pointer + 1;
     end
   end

endmodule


//
// File:   ps2_kbd.v
// Date:   24-Oct-05
// Author: C. Terman / I. Chuang
//
// PS2 keyboard input for 6.111 labkit
//
// INPUTS:
//
//   clock_27mhz   - master clock
//   reset         - active high
//   clock         - keyboard interface clock
//   data          - keyboard interface data
//
// OUTPUTS:
//
//   ascii         - 8 bit ascii code for current character
//   ascii_ready   - one clock cycle pulse indicating new char received


/////////////////////////////////////////////////////////////////////////////

module kbd_ascii_input(clock_27mhz, reset, clock, data, ascii, ascii_ready);
   
   // module to generate ascii code for keyboard input
   // this is module works synchronously with the system clock

   input clock_27mhz;
   input reset; 	 // Active high asynchronous reset
   input clock; 	 // PS/2 clock
   input data;  	 // PS/2 data
   output [7:0] ascii;   // ascii code (1 character)
   output ascii_ready;	 // ascii ready (one clock_27mhz cycle active high)

   reg [7:0]   ascii_val;	// internal combinatorial ascii decoded value
   reg [7:0]   lastkey;		// last keycode
   reg [7:0]   curkey;		// current keycode
   reg [7:0]   ascii;		// ascii output (latched & synchronous)
   reg 	       ascii_ready;	// synchronous one-cycle ready flag

   // get keycodes

   wire        fifo_rd;		// keyboard read request
   wire [7:0]  fifo_data;	// keyboard data
   wire        fifo_empty;	// flag: no keyboard data
   wire        fifo_overflow;	// keyboard data overflow

   ps2 myps2(reset, clock_27mhz, clock, data, fifo_rd, fifo_data, 
	     fifo_empty,fifo_overflow);

   assign      fifo_rd = ~fifo_empty;	// continous read
   reg 	       key_ready;

   always @(posedge clock_27mhz)
     begin

	// get key if ready

	curkey <= ~fifo_empty ? fifo_data : curkey;
	lastkey <= ~fifo_empty ? curkey : lastkey;
	key_ready  <= ~fifo_empty;

	// raise ascii_ready for last key which was read

	ascii_ready <= key_ready & ~(curkey[7]|lastkey[7]);
	ascii <=  (key_ready & ~(curkey[7]|lastkey[7])) ? ascii_val : ascii;

     end

   always @(curkey) begin //convert PS/2 keyboard make code ==> ascii code
     case (curkey)
       8'h1C: ascii_val = 8'h0;         //A
       8'h32: ascii_val = 8'h1;         //B
       8'h21: ascii_val = 8'h2;         //C
       8'h23: ascii_val = 8'h3;         //D
       8'h24: ascii_val = 8'h4;         //E
       8'h2B: ascii_val = 8'h5;         //F
       8'h34: ascii_val = 8'h6;         //G
       8'h33: ascii_val = 8'h7;         //H
       8'h43: ascii_val = 8'h8;         //I
       8'h3B: ascii_val = 8'h9;         //J
       8'h42: ascii_val = 8'ha;         //K
       8'h4B: ascii_val = 8'hb;         //L
       8'h3A: ascii_val = 8'hc;         //M
       8'h31: ascii_val = 8'hd;         //N
       8'h44: ascii_val = 8'he;         //O
       8'h4D: ascii_val = 8'hf;         //P
       8'h15: ascii_val = 8'h10;        //Q
       8'h2D: ascii_val = 8'h11;        //R
       8'h1B: ascii_val = 8'h12;        //S
       8'h2C: ascii_val = 8'h13;        //T
       8'h3C: ascii_val = 8'h14;        //U
       8'h2A: ascii_val = 8'h15;        //V
       8'h1D: ascii_val = 8'h16;        //W
       8'h22: ascii_val = 8'h17;        //X
       8'h35: ascii_val = 8'h18;        //Y
       8'h1A: ascii_val = 8'h19;        //Z

       
       8'h45: ascii_val = 8'h34;        //0
       8'h16: ascii_val = 8'h35;        //1
       8'h1E: ascii_val = 8'h36;        //2
       8'h26: ascii_val = 8'h37;        //3
       8'h25: ascii_val = 8'h38;        //4
       8'h2E: ascii_val = 8'h39;        //5
       8'h36: ascii_val = 8'h3a;        //6
       8'h3D: ascii_val = 8'h3b;        //7
       8'h3E: ascii_val = 8'h3c;        //8
       8'h46: ascii_val = 8'h3d;        //9
     
       8'h5A: ascii_val = 8'h63;	// enter (CR)
       8'h66: ascii_val = 8'h62;	// backspace
       
       default: ascii_val = 8'h61;		
     endcase
   end
endmodule // ps2toascii

/////////////////////////////////////////////////////////////////////////////
// new synchronous ps2 keyboard driver, with built-in fifo, from Chris Terman

module ps2(reset, clock_27mhz, ps2c, ps2d, fifo_rd, fifo_data, 
	   fifo_empty,fifo_overflow);

   input clock_27mhz,reset;
   input ps2c;			// ps2 clock
   input ps2d;			// ps2 data
   input fifo_rd;		// fifo read request (active high)
   output [7:0] fifo_data;	// fifo data output
   output 	fifo_empty;	// fifo empty (active high)
   output 	fifo_overflow;	// fifo overflow - too much kbd input

  reg [3:0] count;      // count incoming data bits
  reg [9:0] shift;      // accumulate incoming data bits

  reg [7:0] fifo[7:0];   // 8 element data fifo
  reg fifo_overflow;
  reg [2:0] wptr,rptr;   // fifo write and read pointers

  wire [2:0] wptr_inc = wptr + 1;

  assign fifo_empty = (wptr == rptr);
  assign fifo_data = fifo[rptr];

  // synchronize PS2 clock to local clock and look for falling edge
  reg [2:0] ps2c_sync;
  always @ (posedge clock_27mhz) ps2c_sync <= {ps2c_sync[1:0],ps2c};
  wire sample = ps2c_sync[2] & ~ps2c_sync[1];

  always @ (posedge clock_27mhz) begin
    if (reset) begin
      count <= 0;
      wptr <= 0;
      rptr <= 0;
      fifo_overflow <= 0;
    end
    else if (sample) begin
           // order of arrival: 0,8 bits of data (LSB first),odd parity,1
           if (count==10) begin
              // just received what should be the stop bit
              if (shift[0]==0 && ps2d==1 && (^shift[9:1])==1) begin
		 fifo[wptr] <= shift[8:1];
		 wptr <= wptr_inc;
		 fifo_overflow <= fifo_overflow | (wptr_inc == rptr);
              end
              count <= 0;
	   end else begin
              shift <= {ps2d,shift[9:1]};
              count <= count + 1;
	   end
         end
    // bump read pointer if we're done with current value.
    // Read also resets the overflow indicator
    if (fifo_rd && !fifo_empty) begin
      rptr <= rptr + 1;
      fifo_overflow <= 0;
    end
  end

endmodule
