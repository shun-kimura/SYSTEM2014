`timescale 1ns / 1ps
module MODE(
	input CLK,
	input mode,
	
	output PWM1,
	output PWM2	
    );
	 
always @(posedge CLK)
	begin
		if(rx_data == "f")
			mode <= 3'h1;
		else if(rx_data == "r")
			mdoe <= 3'h2;
		else if(rx_data == "l")
			mode <= 3'h3;
		else if(rx_data == "b")
			mode <= 3'h4;
		else 
			mode <= 3'h0;
	end

endmodule
