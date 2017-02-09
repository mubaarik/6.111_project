
///////////////////////////////////////////////////////////////////////////////
//
// 6.111 Remote Control Transmitter Module
//
// Outputs a 12-bit Sony remote control signal based on the Sony Infrared Command 
// (SIRC) specification. signal_out can be used to control a TSKS400S Infrared 
// Emitting Diode, using a BJT to produce a stronger driving signal.
// SIRC uses pulse-width modulation to encode the 10-bit signal, with a 600us 
// base frequency modulated by a 40kHz square wave with 25% duty cycle.
//
// Created: February 29, 2009
// Author: Adam Lerer,
// Updated October 4, 2010 - fixed 40Khz modulation, inserted 45ms between commands
//
///////////////////////////////////////////////////////////////////////////////
module ir_transmitter 
       #(parameter DATA_WIDTH=24)
        (input wire clock, //27 mhz clock
         input wire reset, //FPGA reset
         input wire trigger, clear,
         input wire [10:0] x, // 5-bit x position
         input wire [9:0] y, // 5-bit y position
         input wire transmit, // transmission occurs when transmit is asserted
         output wire signal_out, output wire [2:0] sstate); //output to IR transmitter

  wire [DATA_WIDTH-1:0] value;
  assign value = {x, y, trigger, clear}; //the value to be transmitted
  ///////////////////////////////////////////////////////////////////////////////////////
  //
  // here we count the number of "ones" in the signal, subtract from wait time
  // and pad the wait state to start the next command sequence exactly 45ms later. 
  
  wire [5:0] sum_ones; 
  assign sum_ones = trigger + clear + x[10]+ x[9] + x[8] + x[7] + x[6] + x[5] +
                          x[4] + x[3] + x[2] + x[1] + x[0] + y[9] + y[8] + y[7] +
                          y[6] + y[5] + y[4] + y[3] + y[2] + y[1] + y[0];
  wire[10:0] WAIT_TO_45MS;
  assign WAIT_TO_45MS = 10'd450 - (sum_ones*8); // was 376
  parameter TIMEOUT = 24_000_00;
  //
  ///////////////////////////////////////////////////////////////////////////////////////
  reg [26:0] kick_out;
  
  reg [2:0] next_state;
  // cur_value latches the value input when the transmission begins,
  // and gets right shifted in order to transmit each successive bit
  reg [DATA_WIDTH-1:0] cur_value;
  // cur_bit keeps track of how many bits have been transmitted
  reg [4:0] cur_bit;
  reg [2:0] state;
  
  assign sstate = state;
  
  wire [9:0] timer_length;  // large number of future options
  
  localparam IDLE =  3'd0;
  localparam WAIT =  3'd1;
  localparam START = 3'd2;
  localparam TRANS = 3'd3;
  localparam BIT =   3'd4;
  
  // this counter is used to modulate the transmitted signal 
  // by a 40kHz 25% duty cycle square wave  gph 10/2/2010
  reg [10:0] mod_count;  
  
  wire start_timer;
  wire expired;
    
  timer t (.clk(clock), .reset(reset), .start_timer(start_timer),
           .length(timer_length), .expired(expired));
  ///HACK to kick the the state out of WAIT
  always @(posedge clock) begin 
    if(reset) kick_out<=0;
	 else if (next_state!=WAIT) begin
	    kick_out<=0;
	 end 
	 else if(next_state==WAIT) begin
	     kick_out<=kick_out+1; 
	 end
  end
  //////////////////
  always@(posedge clock) 
  begin
    // signal modulation
	 mod_count <= (mod_count == 674) ? 0 : mod_count + 1;   // was 1349 
    if (reset)
	   state <= IDLE;
	 else begin
	   if (state == START) 
        begin
          cur_bit <= 0;
          cur_value <= value;
        end
		// when a bit finishes being transmitted, left shift cur_value
		// so that the next bit can be transmitted, and increment cur_bit
	   if (state == BIT && next_state == TRANS) 
        begin
          cur_bit <= cur_bit + 1;
          cur_value <= {1'b0, cur_value[DATA_WIDTH-1:1]};
        end
        state <= next_state;
    end
  end
  
  always@* 
  begin
    case(state)
	   IDLE:  next_state = transmit  ? WAIT : IDLE;
		WAIT:  next_state = ((kick_out>=TIMEOUT)|expired) ? (transmit ? START : IDLE) : WAIT;
		START: next_state =  expired? TRANS : START;
		TRANS: next_state = expired ? BIT : TRANS;
		BIT :  next_state = expired ? (cur_bit >= DATA_WIDTH-1 ? WAIT : TRANS) : BIT;
		default: next_state = IDLE;
	 endcase 
  end
  // always start the timer on a state transition
  assign start_timer = (state != next_state);
  assign timer_length = (next_state == WAIT) ? WAIT_TO_45MS :  // was 63; 600-4-24-6 = 566
                        (next_state == START) ? 10'd32 :
								(next_state == TRANS) ? 10'd8 :
								(next_state == BIT ) ? (cur_value[0] ? 10'd16 : 10'd8 ) : 10'd0;
  assign signal_out = ((state == START) || (state == BIT)) && (mod_count < 169);	// was 338  gph					
endmodule
