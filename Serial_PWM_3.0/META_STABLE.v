`timescale 1ns / 1ps
//メタ・ステーブル対策回路
module META_STABLE(
	input CLK,
	SW,
	output META_OUT
    );
	 
reg [1:0] META_FF;
	
always @(posedge CLK)
		  META_FF <= {META_FF[0], SW};

assign META_OUT = META_FF[1];

endmodule
