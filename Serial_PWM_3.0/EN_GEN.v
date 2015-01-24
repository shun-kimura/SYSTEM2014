`timescale 1ns / 1ps

//イネーブル生成回路
module EN_GEN(
    input CLK,
    output ENABLE,
	 KHz_enable,
	 EN_05
    );

parameter SEC1_MAX = 50000000,	//50MHzの設定
			 MAX_CNT = 16'hFFFF;		//KHzイネーブルの設定
			 
reg [25:0] tmp_count = 26'h0;		//1秒カウンタ
wire ENABLE_tmp;						//1秒イネーブル

always @(posedge CLK)
begin
	  if (ENABLE_tmp == 1'b1)
			tmp_count <= 'b0;
	  else
			tmp_count <= tmp_count + 26'h1;	//1秒カウンタ
end

assign ENABLE_tmp = (tmp_count == (SEC1_MAX - 1));	//50000000クロックに1回1を出力
assign ENABLE = ENABLE_tmp;
assign KHz_enable = (tmp_count[15:0] == MAX_CNT);	//X"FFFF"に1回1を出力（たまに空振りする）
assign EN_05 = (tmp_count <= (SEC1_MAX/2 - 1));		//0.5秒ごとに1, 0を繰り返す

endmodule
