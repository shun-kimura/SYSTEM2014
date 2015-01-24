`timescale 1ns / 1ps
//�V���A���ʐM
module SIO(
	input CLK, 
	RESET,  
	SW, 
	RX, 
	output reg TX, 
	output reg [7:0] rx_data_reg,
	output reg DIR1,		//���[�^�̕�������(A9�s��)
   output reg DIR2,		//���[�^�̕�������(C12�s��)
	output reg PWM1,		//���[�^����(B9�s��)
	output reg PWM2			//���[�^����(A13)
		
		
	);

parameter CLOCK_RATE = 20;		//50MHz : 20ns
parameter BAUD_RATE = 115200;  //TeraTerm�ł̃{�[���[�g             //432600;	//�{�[���[�g�̒�`		�f�[�^�̓]�����x
parameter START_BIT = 1;		//�X�^�[�g�r�b�g	1�r�b�g
parameter DATA_LENGTH = 8;		//�f�[�^��
parameter PARITY_ON = 0;		//�p���e�B�r�b�g�̗L��
parameter STOP_BIT = 1;			//�X�g�b�v�r�b�g	1�r�b�g
parameter CHAR_LENGTH = START_BIT + DATA_LENGTH + PARITY_ON + STOP_BIT;	//�L�����N�^���̌v�Z
parameter BAUD_CNT_MAX =  8680/CLOCK_RATE;    //2312 / CLOCK_RATE ; 
parameter CNT_LENGTH = 9;

wire RX_META;
reg [2:0] rx_reg;
wire rx_start_trigger, rx_baud_cnt_carry, rx_count_end, rx_data_trigger;
wire tx_start_trigger, tx_baud_cnt_carry, tx_count_end;
reg rx_cnt_en, tx_cnt_en;
reg [(CNT_LENGTH - 1):0] rx_baud_cnt, tx_baud_cnt;
reg [3:0] rx_char_cnt, tx_char_cnt;
wire sw_one_shot, KHz_enable;

reg [25:0] PWM_count;			//���[�^����̂��߂̃J�E���^



always @(posedge CLK)
	rx_reg <= {rx_reg[1:0], RX_META};											//���^�E�X�e�[�u�������M������̗����オ�茟�o���s��
	
assign rx_start_trigger = (rx_char_cnt == 4'hF)? ~rx_reg[1] & rx_reg[2] : 1'b0;	//��M�J�n�̃g���K�M��

always @(posedge CLK or posedge RESET)											//��M�J�E���^�̃C�l�[�u���M��
	if (RESET == 1'b1)
		rx_cnt_en <= 1'b0;
	else if (tx_start_trigger == 1'b1 || (rx_count_end == 1'b1 && rx_baud_cnt_carry == 1'b1))	
		rx_cnt_en <= 1'b0;															//���M�g���K�����������N���A
	else if (rx_start_trigger == 1'b1)	
		rx_cnt_en <= 1'b1;
		
always @(posedge CLK or posedge RESET)											//�{�[���[�g�J�E���^
	if (RESET == 1'b1)
		rx_baud_cnt <= 'b0;
	else if(rx_cnt_en == 1'b1)
		if  (rx_baud_cnt_carry == 1'b1)
			  rx_baud_cnt <= 'b0;
		else
			  rx_baud_cnt <= rx_baud_cnt + 'b1;
	else
		rx_baud_cnt <= 'b0;
		
assign rx_baud_cnt_carry = (rx_baud_cnt == (BAUD_CNT_MAX - 1));		//�ő�l�܂ŃJ�E���g���ăL�����[�o��

always @(posedge CLK or posedge RESET)											//�{�[���[�g�J�E���^�̃L�����[�ɂ���ăC���N�������g
	if	(RESET == 1'b1)
		 rx_char_cnt <= 4'hF;
	else if(rx_cnt_en == 1'b1)
		 begin
		 if (rx_baud_cnt_carry == 1'b1)
			  if (rx_count_end == 1'b1)
					rx_char_cnt <= 4'hF;
			  else
					rx_char_cnt <= rx_char_cnt + 'b1;
		 end
	else
		 rx_char_cnt <= 4'hF;
		 
assign rx_count_end = (rx_char_cnt == 4'h8);										//��M�J�E���^�̏I���t���O

assign rx_data_trigger = (rx_baud_cnt == (BAUD_CNT_MAX/2 - 1));			//��M�f�[�^��荞�݂̃g���K�@�{�[���[�g�J�E���^�̐^��

META_STABLE i0(.CLK(CLK), .SW(RX), .META_OUT(RX_META));						//���^�E�X�e�[�u���΍�

always @(posedge CLK or posedge RESET) 											//��M�f�[�^���W�X�^
	if (RESET == 1'b1)
		 rx_data_reg <= 8'h00;
	else if (rx_start_trigger == 1'b1)
		 rx_data_reg <= 8'h00;
	else if (rx_data_trigger == 1'b1 && rx_char_cnt[3] == 1'b0)
		 rx_data_reg [rx_char_cnt[2:0]] <= RX_META;								//��M�f�[�^�̎�荞�� 1�f�[�^���̔���		 
		 
		 
EN_GEN i1(.CLK(CLK), .ENABLE(), .KHz_enable(KHz_enable), .EN_05());		//KHz_enable�̐���
SW_GEN i2(.CLK(CLK), .SW(SW), .KHz_enable(KHz_enable), .sw_one_shot(sw_one_shot)); //�X�C�b�`�̗����オ��M������

assign tx_start_trigger = (rx_char_cnt == 4'hF && sw_one_shot == 1'b1);	//���M�J�n�̃g���K�i�X�C�b�`�j��M���̓}�X�N

always @(posedge CLK or posedge RESET) 											//���M�J�E���^�̃C�l�[�u��
	if (RESET == 1'b1)
		 tx_cnt_en <= 1'b0;
	else if (rx_start_trigger == 1'b1 || (tx_count_end == 1'b1 && tx_baud_cnt_carry == 1'b1))
		 tx_cnt_en <= 1'b0;
	else if (tx_start_trigger == 1'b1)
		 tx_cnt_en <= 1'b1;
		 
always @(posedge CLK or posedge RESET)												//���M�p�{�[���[�g�J�E���^
	if (RESET == 1'b1)
		 tx_baud_cnt <= 'b0;
	else if (tx_cnt_en == 1'b1)
		 if (tx_baud_cnt_carry == 1'b1)
			  tx_baud_cnt <= 'b0;
		 else
			  tx_baud_cnt <= tx_baud_cnt + 'b1;
	else
		 tx_baud_cnt <= 'b0;
		 
assign tx_baud_cnt_carry = (tx_baud_cnt == (BAUD_CNT_MAX - 1));			//�{�[���[�g�J�E���^�̃L�����[

always @(posedge CLK or posedge RESET)												//���M�p�L�����N�^�J�E���^
	 if (RESET == 1'b1)
		  tx_char_cnt <= 4'hF;
	 else if(tx_cnt_en == 1'b1)
		  begin
		  if (tx_baud_cnt_carry == 1'b1)
				if(tx_count_end == 1'b1)
					tx_char_cnt <= 4'hF;
				else
					tx_char_cnt <= tx_char_cnt + 'b1;
		  end
	 else
		  tx_char_cnt <= 4'hF;
		  
assign tx_count_end = (tx_char_cnt == 4'h8);									//���M�p�L�����N�^�J�E���^�̏I���t���O

always @(posedge CLK or posedge RESET)											//���M
	 if (RESET == 1'b1)
		  TX <= 1'b1;
	 else
		  TX <= RX;																		//���̂܂ܐ܂�Ԃ�


/*���[�^�p���W���[��
�����ł��Ȃ���΍폜
PWM i3(.CLK(CLK), .rx_data(rx_data_reg), .count(PWM_count), .rx_cnt_en(rx_cnt_en), 
			.PWM1(PWM1), .PWM2(PWM2), .DIR1(DIR1), .DIR2(DIR2));
	*/		

/***********************
�ȉ����[�^����e�X�g�p
�o����΃��W���[��������ĕ�������
�f���[�e�B��70%
Active 3500
Period 5000
2015/1/15
@�C�ӂ̕����ւ̃��[�^����		��
@�����I�Ȏ�M�`�F�b�N			��
@��M�`�F�b�N�ɂ�郂�[�^�̒�~	��
************************/
reg [24:0] period;		//PWM����̎��g��
reg [24:0] active;		//PWM�����Active
reg mode;


/*******************
�@�@�@�@���[�^����
*******************/
always @(posedge CLK)
	begin
	period = period + 'b1;
		if(active == 24'd3500)
			begin
				mode <= 0;
				if(period == 24'd5000)
					begin 
						active = 16'b0;
						period = 16'b0;
					end
			end
		else
			begin
				active = active + 'b1;
				mode <= 1;
			end
	end

always @(posedge CLK)
	//if(rx_cnt_en == 1'b1)
	begin
		if(mode == 1)
			begin
				if(rx_data_reg == 8'b01100010)		//���(��M����:b)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data_reg == 8'b01100110)	//�O�i(��M����:f)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data_reg == 8'b01110010)	//�E����(��M����:r)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b0;
					end
				else if(rx_data_reg == 8'b01101100)	//������(��M����:l)
					begin
						PWM1 <= 1'b0;
						PWM2 <= 1'b1;
					end
				else											//��L�ȊO�͒�~
					begin
						PWM1 <= 1'b0;
						PWM2 <= 1'b0;
					end
			end
		else if(mode == 0)							
			begin
				PWM1 <= 1'b0;
				PWM2 <= 1'b0;
		end
	end
	
always @(posedge CLK)
	if(rx_data_reg == 8'b01100010)				//���
		begin
			DIR1 <= 1'b0;
			DIR2 <= 1'b0;
		end
	else										//�O�i�E���E����
		begin
			DIR1 <= 1;
			DIR2 <= 1;
		end 
/******************
���[�^���䂱���܂�
******************/



endmodule
