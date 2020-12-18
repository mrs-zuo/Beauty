package cn.com.antika.util;


import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.widget.Toast;

import cn.com.antika.business.R;

/*
 *
 * 对话框工具类
 * */
@SuppressLint("ResourceType")
public class DialogUtil {
	public static void createMakeSureDialog(Context context, String title,
			String message) {
		new AlertDialog.Builder(context,R.style.CustomerAlertDialog).setMessage(message)
				.setPositiveButton("确定", null).create().show();
	}
	public static AlertDialog createShortShowDialog(Context context, String title,
			String message){
		AlertDialog ad=new AlertDialog.Builder(context,R.style.CustomerAlertDialog).setMessage(message)
		.setPositiveButton("确定", null).create();
		return ad;
	}
	public static void createShortDialog(Context context, String message) {
		Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
	}
}
