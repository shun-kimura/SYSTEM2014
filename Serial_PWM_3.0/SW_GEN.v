`timescale 1ns / 1ps
//チャタリング防止・立ち上がり検出回路
module SW_GEN(
    input CLK,
	 SW,
	 KHz_enable,
	 output sw_one_shot
    );

reg [4:0] shift_FF;
reg [1:0] sw_shift;
wire sw_chata;

// チャタリング防止
always @(posedge CLK)
			if (KHz_enable == 1'b1)
				 shift_FF <= {shift_FF[3:0], SW};	//スイッチ入力が負論理の時にはここを反転させる
				 
//シフトレジスタの値が全て1ならチャタリングはなし
assign sw_chata = &shift_FF;

//立ち上がり検出回路
always @(posedge CLK)
		  sw_shift <= {sw_shift[0], sw_chata};
		  
assign sw_one_shot = sw_shift[0] & ~sw_shift[1];

endmodule
