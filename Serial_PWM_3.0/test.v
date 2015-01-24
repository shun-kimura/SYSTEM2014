`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:14:58 12/18/2014
// Design Name:   SIO
// Module Name:   C:/ISE_Project_File/Serial_PWM_1.1/test.v
// Project Name:  Serial_RT
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SIO
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;
	// Inputs
	reg CLK;
	reg RESET;
	reg SW;
	reg RX;

	// Outputs
	wire TX;
	wire [7:0] rx_data_reg;
	wire DIR;

	// Instantiate the Unit Under Test (UUT)
	SIO uut (
		.CLK(CLK), 
		.RESET(RESET), 
		.SW(SW), 
		.RX(RX), 
		.TX(TX), 
		.rx_data_reg(rx_data_reg), 
		.DIR(DIR)
	);


	always
		#10 CLK = ~ CLK;

	initial begin
		// Initialize Inputs
		CLK = 0;
		RESET = 0;
		SW = 0;
		RX = 0;
	end
      
endmodule

