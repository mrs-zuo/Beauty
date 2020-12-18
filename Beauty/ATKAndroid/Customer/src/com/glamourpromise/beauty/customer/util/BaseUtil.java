package com.glamourpromise.beauty.customer.util;

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap.CompressFormat;
import android.text.format.DateFormat;
import android.util.Base64;

public class BaseUtil {
	private static final String TIME_FORMAT = "yyyy-MM-dd kk:mm";
	
	public static String  getPackageVersion(Context context) {
		String version = "";
		try {
			PackageManager pm = context.getPackageManager();
			PackageInfo pi = null;
			pi = pm.getPackageInfo(context.getPackageName(), 0);
			version = pi.versionName;
		} catch (Exception e) {
			version = ""; // failed, ignored
		}
		return version;
	}
	
	public static String getCurrentTime(){
		return (String) DateFormat.format(TIME_FORMAT, new Date());
	}
	
	public static String getMD5(String val) {
		try {
			byte[] hash = MessageDigest.getInstance("MD5").digest(val.getBytes("UTF-8"));
			return getString(hash);
		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
		
	}
	
	public static Bitmap stringtoBitmap(String string) {
		Bitmap bitmap = null;
		try {
			byte[] bitmapArray;
			bitmapArray = Base64.decode(string, Base64.DEFAULT);
			bitmap = BitmapFactory.decodeByteArray(bitmapArray, 0,
					bitmapArray.length);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return bitmap;
	}
	
	public static String bitmaptoString(Bitmap bitmap, int bitmapQuality) {

		String string = null;
		ByteArrayOutputStream bStream = new ByteArrayOutputStream();
		bitmap.compress(CompressFormat.PNG, bitmapQuality, bStream);
		byte[] bytes = bStream.toByteArray();
		string = Base64.encodeToString(bytes, Base64.DEFAULT);
		return string;
	}

	private static String getString(byte[] hash) {
		StringBuilder hex = new StringBuilder(hash.length * 2);
	     for (byte b : hash) {
	         if ((b & 0xFF) < 0x10) hex.append("0");
	         hex.append(Integer.toHexString(b & 0xFF));
	     }
	     return hex.toString();
	}

	

}
