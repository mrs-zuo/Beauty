package cn.com.antika.view.sign;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;

import java.io.ByteArrayOutputStream;

import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.Base64Util;
import cn.com.antika.util.UploadImageUtil;

@SuppressLint("ResourceType")
public class HandwritingActivity extends Activity {
	private Bitmap    mSignBitmap;
	private WritePadDialog writeTabletDialog;
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_hand_write);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
		writeTabletDialog = new WritePadDialog(HandwritingActivity.this,new DialogListener() {
					public void refreshActivity(Object object,int status) {
						mSignBitmap = (Bitmap) object;
						if(status==1){
							Intent resultIntent=new Intent();
							byte[] mContent = null;
							String signPicture ="";
							ByteArrayOutputStream baos = new ByteArrayOutputStream();
							// 压缩图片
							mSignBitmap = UploadImageUtil.resizeBitmap(mSignBitmap,Constant.RESIZEBITMAPMAXWIDTH,Constant.RESIZEBITMAPMAXWIDTH);
							mSignBitmap.compress(Bitmap.CompressFormat.JPEG,50,baos);
							if (baos != null)
								mContent = baos.toByteArray();
							if (mContent != null){
								signPicture= new String(Base64Util.encode(mContent));
							}
							resultIntent.putExtra("signPic",signPicture);
							HandwritingActivity.this.setResult(RESULT_OK,resultIntent);
							HandwritingActivity.this.finish();
						}
					}
				});
		writeTabletDialog.show();
	}
	/*
	 * 将文件写入到SD卡中
	 * private String createFile() {
		ByteArrayOutputStream baos = null;
		String _path = null;
		try {
			String sign_dir = Environment.getExternalStorageDirectory()+ File.separator;
			_path = sign_dir + System.currentTimeMillis() + ".png";
			baos = new ByteArrayOutputStream();
			mSignBitmap.compress(Bitmap.CompressFormat.PNG,90,baos);
			byte[] photoBytes = baos.toByteArray();
			FileOutputStream out=null;
			if (photoBytes != null) {
				out=new FileOutputStream(new File(_path));
				out.write(photoBytes);
			}
			if(out!=null){
				out.flush();
				out.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (baos != null)
					baos.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return _path;
	}
	*/
}