`timescale 1ns / 1ps

//�C�l�[�u��������H
module EN_GEN(
    input CLK,
    output ENABLE,
	 KHz_enable,
	 EN_05
    );

parameter SEC1_MAX = 50000000,	//50MHz�̐ݒ�
			 MAX_CNT = 16'hFFFF;		//KHz�C�l�[�u���̐ݒ�
			 
reg [25:0] tmp_count = 26'h0;		//1�b�J�E���^
wire ENABLE_tmp;						//1�b�C�l�[�u��

always @(posedge CLK)
begin
	  if (ENABLE_tmp == 1'b1)
			tmp_count <= 'b0;
	  else
			tmp_count <= tmp_count + 26'h1;	//1�b�J�E���^
end

assign ENABLE_tmp = (tmp_count == (SEC1_MAX - 1));	//50000000�N���b�N��1��1���o��
assign ENABLE = ENABLE_tmp;
assign KHz_enable = (tmp_count[15:0] == MAX_CNT);	//X"FFFF"��1��1���o�́i���܂ɋ�U�肷��j
assign EN_05 = (tmp_count <= (SEC1_MAX/2 - 1));		//0.5�b���Ƃ�1, 0���J��Ԃ�

endmodule
