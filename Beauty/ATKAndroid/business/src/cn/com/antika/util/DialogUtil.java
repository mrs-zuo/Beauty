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
		if (context != null) {
			new AlertDialog.Builder(context, R.style.CustomerAlertDialog).setMessage(message)
					.setPositiveButton("确定", null).create().show();
		}
	}
	public static AlertDialog createShortShowDialog(Context context, String title,
			String message){
		AlertDialog ad = null;
		if (context != null) {
			ad = new AlertDialog.Builder(context, R.style.CustomerAlertDialog).setMessage(message)
					.setPositiveButton("确定", null).create();
		}
		return ad;
	}
	public static void createShortDialog(Context context, String message) {
		if (context != null) {
			Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
		}
	}
}
