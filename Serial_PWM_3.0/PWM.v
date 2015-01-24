`timescale 1ns / 1ps
/*******************************************
�ύX�O�̃��[�^���䕔��
�����ł��Ȃ���ΑS�č폜
********************************************/

module PWM(
	input CLK,

	input rx_data,
	input count,
	input rx_cnt_en,
	
	output reg PWM1,
	output reg PWM2,
	output reg DIR1,
	output reg DIR2
	
   );

reg [24:0] period;		//PWM����̎��g��
reg [24:0] active;		//PWM�����Active
parameter mode = 1;


/*******************
�@�@�@�@���[�^����
*******************/
always @(posedge CLK)
	begin
	period = period + 'b1;
		if(active == 24'd3000)
			begin
				if(period == 24'd5000)
					begin 
						active = 16'b0;
						period = 16'b0;
						//mode <= 0;
					end
			end
		else
			begin
				active = active + 'b1;
			//	mode <= 1;
			end
	end


always @(posedge CLK)
	//if(rx_cnt_en == 1'b1)
	begin
		//if(mode == 1)
			begin
				if(rx_data == 8'b01100010)			//���
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data == 8'b01100110)	//�O�i
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data == 8'b01110010)	//�E����
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b0;
					end
				else if(rx_data == 8'b01101100)	//������
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else										//��L�ȊO�͒�~
					begin
						PWM1 <= 1'b0;
						PWM2 <= 1'b0;
					end
			end
		/*else if(mode == 0)							
			begin
				PWM1 <= 1'b0;
				PWM2 <= 1'b0;
			end*/
	end
	
	
always @(posedge CLK)
	if(rx_data == 8'b01100010)				//���
		begin
			DIR1 <= 1'b0;
			DIR2 <= 1'b0;
		end
	else										//�O�i�E���E����
		begin
			DIR1 <= 1;
			DIR2 <= 1;
		end 

endmodule
