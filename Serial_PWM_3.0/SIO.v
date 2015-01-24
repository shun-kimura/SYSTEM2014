`timescale 1ns / 1ps
//シリアル通信
module SIO(
	input CLK, 
	RESET,  
	SW, 
	RX, 
	output reg TX, 
	output reg [7:0] rx_data_reg,
	output reg DIR1,		//モータの方向制御(A9ピン)
   output reg DIR2,		//モータの方向制御(C12ピン)
	output reg PWM1,		//モータ制御(B9ピン)
	output reg PWM2			//モータ制御(A13)
		
		
	);

parameter CLOCK_RATE = 20;		//50MHz : 20ns
parameter BAUD_RATE = 115200;  //TeraTermでのボーレート             //432600;	//ボーレートの定義		データの転送速度
parameter START_BIT = 1;		//スタートビット	1ビット
parameter DATA_LENGTH = 8;		//データ長
parameter PARITY_ON = 0;		//パリティビットの有無
parameter STOP_BIT = 1;			//ストップビット	1ビット
parameter CHAR_LENGTH = START_BIT + DATA_LENGTH + PARITY_ON + STOP_BIT;	//キャラクタ長の計算
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

reg [25:0] PWM_count;			//モータ制御のためのカウンタ



always @(posedge CLK)
	rx_reg <= {rx_reg[1:0], RX_META};											//メタ・ステーブル除去信号からの立ち上がり検出を行う
	
assign rx_start_trigger = (rx_char_cnt == 4'hF)? ~rx_reg[1] & rx_reg[2] : 1'b0;	//受信開始のトリガ信号

always @(posedge CLK or posedge RESET)											//受信カウンタのイネーブル信号
	if (RESET == 1'b1)
		rx_cnt_en <= 1'b0;
	else if (tx_start_trigger == 1'b1 || (rx_count_end == 1'b1 && rx_baud_cnt_carry == 1'b1))	
		rx_cnt_en <= 1'b0;															//送信トリガが来た時もクリア
	else if (rx_start_trigger == 1'b1)	
		rx_cnt_en <= 1'b1;
		
always @(posedge CLK or posedge RESET)											//ボーレートカウンタ
	if (RESET == 1'b1)
		rx_baud_cnt <= 'b0;
	else if(rx_cnt_en == 1'b1)
		if  (rx_baud_cnt_carry == 1'b1)
			  rx_baud_cnt <= 'b0;
		else
			  rx_baud_cnt <= rx_baud_cnt + 'b1;
	else
		rx_baud_cnt <= 'b0;
		
assign rx_baud_cnt_carry = (rx_baud_cnt == (BAUD_CNT_MAX - 1));		//最大値までカウントしてキャリー出力

always @(posedge CLK or posedge RESET)											//ボーレートカウンタのキャリーによってインクリメント
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
		 
assign rx_count_end = (rx_char_cnt == 4'h8);										//受信カウンタの終了フラグ

assign rx_data_trigger = (rx_baud_cnt == (BAUD_CNT_MAX/2 - 1));			//受信データ取り込みのトリガ　ボーレートカウンタの真中

META_STABLE i0(.CLK(CLK), .SW(RX), .META_OUT(RX_META));						//メタ・ステーブル対策

always @(posedge CLK or posedge RESET) 											//受信データレジスタ
	if (RESET == 1'b1)
		 rx_data_reg <= 8'h00;
	else if (rx_start_trigger == 1'b1)
		 rx_data_reg <= 8'h00;
	else if (rx_data_trigger == 1'b1 && rx_char_cnt[3] == 1'b0)
		 rx_data_reg [rx_char_cnt[2:0]] <= RX_META;								//受信データの取り込み 1データ長の半分		 
		 
		 
EN_GEN i1(.CLK(CLK), .ENABLE(), .KHz_enable(KHz_enable), .EN_05());		//KHz_enableの生成
SW_GEN i2(.CLK(CLK), .SW(SW), .KHz_enable(KHz_enable), .sw_one_shot(sw_one_shot)); //スイッチの立ち上がり信号生成

assign tx_start_trigger = (rx_char_cnt == 4'hF && sw_one_shot == 1'b1);	//送信開始のトリガ（スイッチ）受信中はマスク

always @(posedge CLK or posedge RESET) 											//送信カウンタのイネーブル
	if (RESET == 1'b1)
		 tx_cnt_en <= 1'b0;
	else if (rx_start_trigger == 1'b1 || (tx_count_end == 1'b1 && tx_baud_cnt_carry == 1'b1))
		 tx_cnt_en <= 1'b0;
	else if (tx_start_trigger == 1'b1)
		 tx_cnt_en <= 1'b1;
		 
always @(posedge CLK or posedge RESET)												//送信用ボーレートカウンタ
	if (RESET == 1'b1)
		 tx_baud_cnt <= 'b0;
	else if (tx_cnt_en == 1'b1)
		 if (tx_baud_cnt_carry == 1'b1)
			  tx_baud_cnt <= 'b0;
		 else
			  tx_baud_cnt <= tx_baud_cnt + 'b1;
	else
		 tx_baud_cnt <= 'b0;
		 
assign tx_baud_cnt_carry = (tx_baud_cnt == (BAUD_CNT_MAX - 1));			//ボーレートカウンタのキャリー

always @(posedge CLK or posedge RESET)												//送信用キャラクタカウンタ
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
		  
assign tx_count_end = (tx_char_cnt == 4'h8);									//送信用キャラクタカウンタの終了フラグ

always @(posedge CLK or posedge RESET)											//送信
	 if (RESET == 1'b1)
		  TX <= 1'b1;
	 else
		  TX <= RX;																		//そのまま折り返し


/*モータ用モジュール
分割できなければ削除
PWM i3(.CLK(CLK), .rx_data(rx_data_reg), .count(PWM_count), .rx_cnt_en(rx_cnt_en), 
			.PWM1(PWM1), .PWM2(PWM2), .DIR1(DIR1), .DIR2(DIR2));
	*/		

/***********************
以下モータ制御テスト用
出来ればモジュールを作って分割する
デューティ比70%
Active 3500
Period 5000
2015/1/15
@任意の方向へのモータ制御		済
@周期的な受信チェック			未
@受信チェックによるモータの停止	未
************************/
reg [24:0] period;		//PWM制御の周波数
reg [24:0] active;		//PWM制御のActive
reg mode;


/*******************
　　　　モータ制御
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
				if(rx_data_reg == 8'b01100010)		//後退(受信文字:b)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data_reg == 8'b01100110)	//前進(受信文字:f)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b1;
					end
				else if(rx_data_reg == 8'b01110010)	//右旋回(受信文字:r)
					begin
						PWM1 <= 1'b1;
						PWM2 <= 1'b0;
					end
				else if(rx_data_reg == 8'b01101100)	//左旋回(受信文字:l)
					begin
						PWM1 <= 1'b0;
						PWM2 <= 1'b1;
					end
				else											//上記以外は停止
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
	if(rx_data_reg == 8'b01100010)				//後退
		begin
			DIR1 <= 1'b0;
			DIR2 <= 1'b0;
		end
	else										//前進・左右旋回
		begin
			DIR1 <= 1;
			DIR2 <= 1;
		end 
/******************
モータ制御ここまで
******************/



endmodule
