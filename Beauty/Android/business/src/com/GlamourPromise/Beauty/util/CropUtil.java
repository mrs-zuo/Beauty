package com.GlamourPromise.Beauty.util;

import java.io.FileNotFoundException;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
public class CropUtil {
	//由相机发送的裁剪意图
	public static void cropImageByCamera(Activity activity,Uri uri, int outputX, int outputY, int requestCode) {
		// 裁剪图片意图
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri,"image/*");
		intent.putExtra("crop","true");
		// 裁剪框的比例，1：1
		intent.putExtra("aspectX",1);
		intent.putExtra("aspectY",1);
		// 裁剪后输出图片的尺寸大小
		intent.putExtra("outputX",outputX);
		intent.putExtra("outputY",outputY);
		// 图片格式
		intent.putExtra("outputFormat", "JPEG");
		intent.putExtra("noFaceDetection", true);
		intent.putExtra("return-data",false);
		intent.putExtra("scale", true);
		intent.putExtra(MediaStore.EXTRA_OUTPUT,uri);
		intent.putExtra("outputFormat",Bitmap.CompressFormat.JPEG.toString());
		activity.startActivityForResult(intent,requestCode);
	}
	//由相册选取
	public static void cropImageByPhoto(Activity activity,Uri uri,Uri imageUri,int outputX, int outputY, int requestCode) {
		// 裁剪图片意图
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri,"image/*");
		intent.putExtra("crop","true");
		// 裁剪框的比例，1：1
		intent.putExtra("aspectX",1);
		intent.putExtra("aspectY",1);
		// 裁剪后输出图片的尺寸大小
		intent.putExtra("outputX",outputX);
		intent.putExtra("outputY",outputY);
		// 图片格式
		intent.putExtra("outputFormat", "JPEG");
		intent.putExtra("noFaceDetection", true);
		intent.putExtra("return-data",false);
		intent.putExtra(MediaStore.EXTRA_OUTPUT,imageUri);
		intent.putExtra("outputFormat",Bitmap.CompressFormat.JPEG.toString());
		activity.startActivityForResult(intent,requestCode);
	}
	//从给的的Uri读取出Bitmap
	public static Bitmap decodeBitmapImageUri(Activity activity,Uri uri){
		Bitmap bitmap=null;
		try {
			bitmap=BitmapFactory.decodeStream(activity.getContentResolver().openInputStream(uri));
		} catch (FileNotFoundException e) {
			
		}
		return bitmap;
	}
}
