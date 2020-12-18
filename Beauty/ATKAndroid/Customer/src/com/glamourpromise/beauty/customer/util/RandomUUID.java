package com.glamourpromise.beauty.customer.util;

import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.UUID;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class RandomUUID {
	private static String uuidRaw;
	private static SharedPreferences sharedPreferences;
	public static String getRandomUUID(Context context, String customerID){
		uuidRaw = "";
		sharedPreferences = context.getSharedPreferences("customerInformation", Context.MODE_PRIVATE);
		if(sharedPreferences.getString("lastLoginAccount", "").equals(customerID) && !sharedPreferences.getString("pushUUID", "").equals(""))
			uuidRaw = sharedPreferences.getString("pushUUID", "");
		else
			uuidRaw = createRandomUUID(customerID);
		return uuidRaw;
	}
	
	private static String createRandomUUID(String customerID){
		SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
		String data = sDateFormat.format(new java.util.Date());
		data += customerID;
		String uuidRaw = "";
		try {
			uuidRaw = UUID.nameUUIDFromBytes(data.getBytes("utf8")).toString();
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		uuidRaw = uuidRaw.replaceAll("-", "");
		Editor editor = sharedPreferences.edit();// 获取编辑器
		editor.putString("pushUUID", uuidRaw);
		editor.commit();// 提交修改
		return uuidRaw;
	}
}
