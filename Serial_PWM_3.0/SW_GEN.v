`timescale 1ns / 1ps
//�`���^�����O�h�~�E�����オ�茟�o��H
module SW_GEN(
    input CLK,
	 SW,
	 KHz_enable,
	 output sw_one_shot
    );

reg [4:0] shift_FF;
reg [1:0] sw_shift;
wire sw_chata;

// �`���^�����O�h�~
always @(posedge CLK)
			if (KHz_enable == 1'b1)
				 shift_FF <= {shift_FF[3:0], SW};	//�X�C�b�`���͂����_���̎��ɂ͂����𔽓]������
				 
//�V�t�g���W�X�^�̒l���S��1�Ȃ�`���^�����O�͂Ȃ�
assign sw_chata = &shift_FF;

//�����オ�茟�o��H
always @(posedge CLK)
		  sw_shift <= {sw_shift[0], sw_chata};
		  
assign sw_one_shot = sw_shift[0] & ~sw_shift[1];

endmodule
