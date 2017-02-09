`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:06:35 10/24/2016 
// Design Name: 
// Module Name:    read_ir_data 
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
module read_ir_data 
       #(parameter DATA_WIDTH=23)
        (input wire reset, input wire clk, input wire serial, output reg ready,
         output wire [10:0] x, output wire [9:0] y, output wire trigger, clear);

  parameter LOW = 0;
  parameter HIGH = 1;
  parameter INTER = 2; // intermediate between high and low
  
  parameter START = 32;
  parameter ONE_BIT = 16;
  parameter ZERO_BIT = 8;
  parameter OFF_LENGTH = 8;
  
  wire enable;
  reg [DATA_WIDTH-1:0] d = 0;
  reg [5:0] high_length;
  reg [4:0] index; 
  reg [1:0] state;
  reg start;
  
  divider_600us divide_75(.clk(clk), .reset(reset), .enable(enable));
  
  // retrieve data from parsed IR signal
  assign x = {d[0],d[1],d[2],d[3],d[4],d[5],d[6],d[7],d[8],d[9],d[10]};
  assign y = {d[11],d[12],d[13],d[14],d[15],d[16],d[17],d[18],d[19],d[20]};
  assign {trigger, clear} = {d[21],d[22]};
  
  always @ (posedge clk) begin
    if (reset) begin state <= LOW; high_length <= 0; d <= 0; index <= 0; end
    if (ready) begin ready <= 0; end
    // downsample signal
    if (enable) begin
    
      case (state) 
        HIGH: begin
          if (!serial) begin state <= INTER; end
          else begin state <= HIGH; high_length <= high_length + 1; end
        end
        
        INTER: begin
          state <= serial ? HIGH: LOW;
          if (~serial) begin 
            // we are going low. check length
            if (high_length >= 30 && high_length <= 32) begin
              start <= 1; d <= 0; index <= 0;
            end
            // 1
            else if (high_length >= 14 && high_length <= 18) begin
              if (start) begin d[DATA_WIDTH-(index + 1)] <= 1; index <= index + 1; end
            end
            // 0
            else if (high_length >= 6 && high_length <= 10) begin
              if (start) begin d[DATA_WIDTH-(index + 1)] <= 0; index <= index + 1; end
            end
            // false length. wait for new start pulse
            else begin start <= 0; state <= LOW; index <= 0; d <= 0; end
             
          end
        end
        
        LOW: begin
          high_length <= 0;
          if (serial) begin state <= INTER; high_length <= 1; end
        end
        
        default: begin end // do nothing
      endcase
    end
    
    if (index >= DATA_WIDTH-1) begin index <= 0; start <= 0; ready <= 1; end
  end

endmodule

