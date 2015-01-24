package jp.example.bluetooth_01;

import java.io.IOException;
import java.io.OutputStream;
import java.util.UUID;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.widget.Button;

public class MainActivity extends ActionBarActivity {

	private BluetoothAdapter mBluetoothAdapter;				//BTアダプタ
	private BluetoothDevice  mBtDevice;						//BTデバイス
	private BluetoothSocket  mBtSocket;						//BTソケット	
	private OutputStream     mOutput;						//出力ストリーム
	private Button           btn1, btn2, btn3, btn4, btn5 ;	//送信ボタン（直進、左旋回、右旋回、後退、停止）	
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		//ボタンのインスタンスを取得
		btn1 = (Button) findViewById(R.id.button1);
		btn2 = (Button) findViewById(R.id.button2);
		btn3 = (Button) findViewById(R.id.button3);
		btn4 = (Button) findViewById(R.id.button4);
		btn5 = (Button) findViewById(R.id.button5);
		
		//BTの準備------------------------------------------------------------------
		//BTアダプタのインスタンスを取得
		mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		
		//相手先BTデバイスのインスタンスを取得
		//相手のMACアドレスを打ち込む
		//FPGA用
		mBtDevice = mBluetoothAdapter.getRemoteDevice("00:06:66:43:97:81");
		
		//BTソケットのインスタンスを取得
		try {
			//接続に使用するプロファイルを指定
			mBtSocket = mBtDevice.createRfcommSocketToServiceRecord(
					UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		
		//ソケットを接続する
		try {
			mBtSocket.connect();
			mOutput = mBtSocket.getOutputStream();	//出力ストリームオブジェクトを取得
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		
		//ボタン1(直進)のイベントリスナ
		btn1.setOnClickListener(new View.OnClickListener(){
			public void onClick(View v) {
				// TODO Auto-generated method stub
				try {
					mOutput.write('f');
				}
				catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}			
		});
		
		//ボタン2(左旋回)のイベントリスナ
		btn2.setOnClickListener(new View.OnClickListener(){
			public void onClick(View v) {
				// TODO Auto-generated method stub
				try {
					mOutput.write('l');
				}
				catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
		
		//ボタン3(右旋回)のイベントリスナ
		btn3.setOnClickListener(new View.OnClickListener(){
			public void onClick(View v) {
				// TODO Auto-generated method stub
				try {
					mOutput.write('r');
				}
				catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});

		//ボタン4(後退)のイベントリスナ
		btn4.setOnClickListener(new View.OnClickListener(){
			public void onClick(View v) {
				// TODO Auto-generated method stub
				try {
					mOutput.write('b');
				}
				catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
		
		
		//ボタン5(停止)のイベントリスナ
		btn5.setOnClickListener(new View.OnClickListener(){
		public void onClick(View v) {
			// TODO Auto-generated method stub
			try {
				mOutput.write('s');
			}
			catch (IOException e) {
			// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		});
		
		
		
	}
	
	


	
	@Override	
	protected void onDestroy() {
		super.onDestroy();
		
		//ソケットを閉じる
		try {
			mBtSocket.close();
		}
		catch(IOException e) {
			e.printStackTrace();
		}
	}
	
}
