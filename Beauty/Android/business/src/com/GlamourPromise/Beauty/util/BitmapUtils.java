package com.GlamourPromise.Beauty.util;

import com.GlamourPromise.Beauty.Business.R;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BlurMaskFilter;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.PorterDuff.Mode;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.widget.ImageView;

/*
 * 图片处理类
 * */
public class BitmapUtils {
	/*
	 * 在图片上添加红色框
	 */
	public static Bitmap personUsedSchedule(Bitmap bitMap,int startHour,int startMinutes,int endHour,int endMinutes,int currentIndex) {
		Bitmap redRectBitMap = Bitmap.createBitmap(bitMap.getWidth(),bitMap.getHeight() / 2, Bitmap.Config.ARGB_8888);
		Canvas canvasRed = new Canvas(redRectBitMap);
		Paint paint = new Paint();
		paint.setColor(Color.RED);
		paint.setStrokeWidth(1);
		paint.setAlpha(0x90);
		paint.setStyle(Style.FILL);
		if(currentIndex==startHour){
			canvasRed.drawRect(new Rect(startMinutes,0,60,bitMap.getHeight() / 2), paint);
		}
		else if(currentIndex==endHour){
			canvasRed.drawRect(new Rect(0,0,endMinutes,bitMap.getHeight() / 2), paint);
		}
		else if(startHour<currentIndex && currentIndex<endHour){
			canvasRed.drawRect(new Rect(0,0,60,bitMap.getHeight() / 2), paint);
		}
		Bitmap resultBitMap = Bitmap.createBitmap(bitMap.getWidth(),bitMap.getHeight(), Bitmap.Config.ARGB_8888);
		Canvas canvasResult = new Canvas(resultBitMap);
		canvasResult.drawBitmap(bitMap, 0, 0, null);
		canvasResult.drawBitmap(redRectBitMap, 0,(float) (bitMap.getHeight() * 0.25), null);
		canvasResult.save();
		return resultBitMap;
	}

	/*
	 * 在图片上添加垂直红色框
	 */
	public static Bitmap personScheduleClockIcon(Bitmap bitMap, int height) {
		//在画布上画出红色的竖线
		Bitmap redRectBitMap = Bitmap.createBitmap(bitMap.getWidth() / 5,bitMap.getHeight()+height, Bitmap.Config.ARGB_8888);
		Canvas canvasRed = new Canvas(redRectBitMap);
		Paint paint = new Paint();
		paint.setColor(Color.RED);
		paint.setStrokeWidth(1);
		paint.setStyle(Style.FILL);
		canvasRed.drawRect(new Rect(0, 0, (bitMap.getWidth() / 5)-5, height), paint);
		Bitmap resultBitMap = Bitmap.createBitmap(bitMap.getWidth(),bitMap.getHeight()+height, Bitmap.Config.ARGB_8888);
		Canvas canvasResult = new Canvas(resultBitMap);
		canvasResult.drawBitmap(bitMap, 0, 0, null);
		canvasResult.drawBitmap(redRectBitMap,(float) (bitMap.getWidth() * 0.4), bitMap.getHeight(), null);
		canvasResult.save();
		return resultBitMap;
	}

	public static Bitmap getRoundCornerBitmap(Bitmap bitmap, float corner) {
		final int height = bitmap.getHeight();
		final int width = bitmap.getWidth();
		Bitmap returnBitmap = Bitmap.createBitmap(width, height,Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(returnBitmap);
		final int color = 0Xff424242;
		final Paint paint = new Paint();
		final Rect rect = new Rect(0, 0, width, height);
		final RectF rectF = new RectF(rect);
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		paint.setColor(color);
		canvas.drawRoundRect(rectF, corner, corner, paint);
		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, rect, rect, paint);
		return returnBitmap;
	}

	public static Bitmap reportItemLine(int screenWidth, ImageView imageView) {
		Bitmap bitmap = Bitmap.createBitmap(screenWidth, 20, Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);
		Paint paint = new Paint();
		paint.setColor(imageView.getContext().getResources()
				.getColor(R.color.blue));
		paint.setStrokeWidth(1);
		paint.setStyle(Style.FILL_AND_STROKE);
		// 绘制底图边框
		canvas.drawRect(new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight()),
				paint);
		return bitmap;
	}
	public static boolean compareBitMap(Activity activity, Drawable expectedDrawable,
			Drawable actualDrawable) {
		Bitmap actualBitmap = ((BitmapDrawable) actualDrawable).getBitmap();

		Bitmap expectedBitmap = ((BitmapDrawable) expectedDrawable).getBitmap();
		int nonMatchingPixels = 0;

		int allowedMaxNonMatchPixels = 10;

		if (expectedBitmap == null || actualBitmap == null || activity == null) {
			return false;
		}

		int[] expectedBmpPixels = new int[expectedBitmap.getWidth()
				* expectedBitmap.getHeight()];

		expectedBitmap.getPixels(expectedBmpPixels, 0,
				expectedBitmap.getWidth(), 0, 0, expectedBitmap.getWidth(),
				expectedBitmap.getHeight());

		int[] actualBmpPixels = new int[actualBitmap.getWidth()
				* actualBitmap.getHeight()];

		actualBitmap.getPixels(actualBmpPixels, 0, actualBitmap.getWidth(), 0,
				0, actualBitmap.getWidth(), actualBitmap.getHeight());

		if (expectedBmpPixels.length != actualBmpPixels.length) {
			return false;
		}

		for (int i = 0; i < expectedBmpPixels.length; i++) {

			if (expectedBmpPixels[i] != actualBmpPixels[i]) {
				nonMatchingPixels++;
			}

		}

		if (nonMatchingPixels > allowedMaxNonMatchPixels) {
			return false;
		}

		return true;

	}

}
