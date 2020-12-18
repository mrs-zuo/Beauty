package com.glamourpromise.beauty.customer.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Collections;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.PhotoAlbumDetailActivity;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Bitmap.Config;
import android.graphics.PorterDuff.Mode;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

public class ImageLoader {
	MemoryCache memoryCache = new MemoryCache();
	FileCache fileCache;
	private Map<ImageView, String> imageViews = Collections
			.synchronizedMap(new WeakHashMap<ImageView, String>());
	ExecutorService executorService;

	private int stub_id;
	private Handler handler;

//	public ImageLoader(Context context, int type, boolean isOriginalImage) {
//		fileCache = new FileCache(context);
//		executorService = Executors.newFixedThreadPool(5);
//		handler = null;
//		// this.isOriginalImage = isOriginalImage;
//
//		// 头像默认图片
//		if (type == 1) {
//			stub_id = com.glamourpromise.beauty.customer.R.drawable.head_image_null;
//		} else if (type == 2) {
//			stub_id = com.glamourpromise.beauty.customer.R.drawable.commodity_image_null;
//		} else if (type == 3) {
//			stub_id = -1;
//		}
//	}
//
//	public ImageLoader(Context context, int imageID) {
//		fileCache = new FileCache(context);
//		executorService = Executors.newFixedThreadPool(5);
//		handler = null;
//		stub_id = imageID;
//	}
//	public ImageLoader(Context context, Handler handler, int type,
//			boolean isOriginalImage) {
//		fileCache = new FileCache(context);
//		executorService = Executors.newFixedThreadPool(5);
//		this.handler = handler;
//		// this.isOriginalImage = isOriginalImage;
//
//		// 头像默认图片
//		if (type == 1) {
//			stub_id = com.glamourpromise.beauty.customer.R.drawable.head_image_null;
//		} else if (type == 2) {
//			stub_id = com.glamourpromise.beauty.customer.R.drawable.commodity_image_null;
//		} else if (type == 3) {
//			stub_id = -1;
//		}
//	}

	public void DisplayImage(String url, ImageView imageView) {
		imageViews.put(imageView, url);
		Bitmap bitmap = memoryCache.get(url);
		if (bitmap != null) {
			imageView.setImageBitmap(bitmap);

			if (handler != null) {
				handler.sendEmptyMessage(111);
			}

		}

		else {
			queuePhoto(url, imageView);
			if (stub_id != -1) {
				imageView.setImageResource(stub_id);
			}

		}
	}

	public Bitmap getImageBitmap(Context context, String url,
			ImageView imageView) {
		imageViews.put(imageView, url);
		Bitmap bitmap = memoryCache.get(url);
		if (bitmap != null)
			return bitmap;
		else {
			queueCompoundBitmap(context, url, imageView);
			return null;
		}
	}

	private void queueCompoundBitmap(Context context, String url,
			ImageView imageView) {
		PhotoToLoad p = new PhotoToLoad(url, imageView);
		executorService.submit(new PhotosLoaderAndCompound(context, p));
	}

	private void queuePhoto(String url, ImageView imageView) {
		PhotoToLoad p = new PhotoToLoad(url, imageView);
		executorService.submit(new PhotosLoader(p));
	}

	private Bitmap getBitmap(String url) {
		File f = fileCache.getFile(url);
		Bitmap b = decodeFile(f);
		if (b != null)
			return b;
		try {
			// Bitmap bitmap=null;
			URL imageUrl = new URL(url);
			HttpURLConnection conn = (HttpURLConnection) imageUrl
					.openConnection();
			conn.setConnectTimeout(30000);
			conn.setReadTimeout(30000);
			conn.setInstanceFollowRedirects(true);
			InputStream is = conn.getInputStream();
			// OutputStream os = new FileOutputStream(f);
			// StreamUtils.CopyStream(is, os);
			// os.close();
			// bitmap = decodeFile(f);
			// return bitmap;
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			byte[] b1 = new byte[4096];
			int len = 0;
			while ((len = is.read(b1, 0, 1024)) != -1) {
				baos.write(b1, 0, len);
				baos.flush();
			}
			byte[] bytes = baos.toByteArray();
			Bitmap orginImage = BitmapFactory.decodeByteArray(bytes, 0,
					bytes.length);
			return orginImage;
		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}
	}

	private Bitmap decodeFile(File f) {
		try {
			BitmapFactory.Options o = new BitmapFactory.Options();
			o.inJustDecodeBounds = true;
			BitmapFactory.decodeStream(new FileInputStream(f), null, o);
			final int REQUIRED_SIZE = 70;
			int width_tmp = o.outWidth, height_tmp = o.outHeight;
			int scale = 1;
			while (true) {
				if (width_tmp / 2 < REQUIRED_SIZE
						|| height_tmp / 2 < REQUIRED_SIZE)
					break;
				width_tmp /= 2;
				height_tmp /= 2;
				scale *= 2;
			}

			BitmapFactory.Options o2 = new BitmapFactory.Options();
			o2.inSampleSize = scale;
			return BitmapFactory.decodeStream(new FileInputStream(f), null, o2);
		} catch (FileNotFoundException e) {
		}
		return null;
	}

	private class PhotoToLoad {
		public String url;
		public ImageView imageView;

		public PhotoToLoad(String u, ImageView i) {
			url = u;
			imageView = i;
		}
	}

	class PhotosLoader implements Runnable {
		PhotoToLoad photoToLoad;

		PhotosLoader(PhotoToLoad photoToLoad) {
			this.photoToLoad = photoToLoad;
		}

		@Override
		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			Bitmap bmp = getBitmap(photoToLoad.url);
			memoryCache.put(photoToLoad.url, bmp);
			if (imageViewReused(photoToLoad))
				return;
			BitmapDisplayer bd = new BitmapDisplayer(bmp, photoToLoad);
			Activity a = (Activity) photoToLoad.imageView.getContext();
			a.runOnUiThread(bd);
			if (handler != null) {
				handler.sendEmptyMessage(111);
			}
		}
	}

	class PhotosLoaderAndCompound implements Runnable {
		Context context;
		PhotoToLoad photoToLoad;

		PhotosLoaderAndCompound(Context context, PhotoToLoad photoToLoad) {
			this.context = context;
			this.photoToLoad = photoToLoad;
		}

		@Override
		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			Bitmap bmp = getBitmap(photoToLoad.url);
			memoryCache.put(photoToLoad.url, bmp);
			if (imageViewReused(photoToLoad))
				return;
			BitmapCompoundAndDisplayer bd = new BitmapCompoundAndDisplayer(
					context, bmp, photoToLoad);
			Activity a = (Activity) photoToLoad.imageView.getContext();
			a.runOnUiThread(bd);
		}
	}

	boolean imageViewReused(PhotoToLoad photoToLoad) {
		String tag = imageViews.get(photoToLoad.imageView);
		if (tag == null || !tag.equals(photoToLoad.url))
			return true;
		return false;
	}

	class BitmapCompoundAndDisplayer implements Runnable {
		Context context;
		Bitmap bitmap;
		PhotoToLoad photoToLoad;

		public BitmapCompoundAndDisplayer(Context context, Bitmap b,
				PhotoToLoad p) {
			this.context = context;
			bitmap = b;
			photoToLoad = p;
		}

		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			if (bitmap != null)
			// photoToLoad.imageView.setImageBitmap(bitmap);
			{
				CompoundImage(context, bitmap, photoToLoad.imageView);
			}

			// if(isOriginalImage){
			// // PhotoAlbumDetailActivity.removeProgressBar();
			// Log.v("isOriginalImage", "ok");
			// }

			else
			// photoToLoad.imageView.setImageResource(stub_id);
			{
				if (stub_id != -1) {
					CompoundImage(context, ((BitmapDrawable) context
							.getResources().getDrawable(stub_id)).getBitmap(),
							photoToLoad.imageView);
				}

			}
		}
	}

	private void CompoundImage(Context context, Bitmap bitmap,
			ImageView imageView) {
		Log.v("CompoundImage", "ok");
		Bitmap bitmap1 = ((BitmapDrawable) context.getResources().getDrawable(
				R.drawable.photo_album_backgroup)).getBitmap();
		bitmap = getRoundCornerBitmap(bitmap, 10);
		Drawable[] array = new Drawable[2];
		array[0] = new BitmapDrawable(bitmap1);
		array[1] = new BitmapDrawable(bitmap);
		LayerDrawable la = new LayerDrawable(array);
		// ���е�һ������Ϊ�������ţ�������ĸ�����ֱ�Ϊleft��top��right��bottom
		la.setLayerInset(0, 0, 0, 0, 0);

		la.setLayerInset(1, 1, 5, 3, 1);
		imageView.setImageDrawable(la);
	}

	public static Bitmap getRoundCornerBitmap(Bitmap bitmap, float roundPX) {
		int width = bitmap.getWidth();
		int height = bitmap.getHeight();

		Bitmap bitmap2 = Bitmap.createBitmap(width, height, Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap2);

		final int color = 0xff424242;
		final Paint paint = new Paint();
		final Rect rect = new Rect(0, 0, width, height);
		final RectF rectF = new RectF(rect);

		paint.setColor(color);
		paint.setAntiAlias(true);
		canvas.drawARGB(0, 0, 0, 0);
		canvas.drawRoundRect(rectF, roundPX, roundPX, paint);

		paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
		canvas.drawBitmap(bitmap, rect, rect, paint);

		return bitmap2;
	}

	class BitmapDisplayer implements Runnable {
		Bitmap bitmap;
		PhotoToLoad photoToLoad;

		public BitmapDisplayer(Bitmap b, PhotoToLoad p) {
			bitmap = b;
			photoToLoad = p;
		}

		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			if (bitmap != null)
				photoToLoad.imageView.setImageBitmap(bitmap);
			else {
				if (stub_id != -1) {
					photoToLoad.imageView.setImageResource(stub_id);
				}
			}

		}
	}

	public void clearCache() {
		memoryCache.clear();
		fileCache.clear();
	}

}