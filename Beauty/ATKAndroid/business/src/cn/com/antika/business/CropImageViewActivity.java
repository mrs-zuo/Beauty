package cn.com.antika.business;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.RectF;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.util.FloatMath;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;

import java.lang.reflect.Field;

import cn.com.antika.constant.Constant;
import cn.com.antika.view.ClipView;

/*
 * 对图片进行裁剪
 * */
public class CropImageViewActivity extends BaseActivity implements OnClickListener,
		OnTouchListener {
	private ImageView screenshot_imageView;
	private Button cancel_btn, ok_btn, rotate_btn;
	private ClipView clipview;
	private Bitmap bitmap;
	private int width;// 屏幕宽度
	private int height;// 屏幕高度
	private Rect rectIV;
	private int statusBarHeight = 0;
	private int titleBarHeight = 0;
	private int angleInt = 0; // 旋转次数
	private int n = 0;// angleInt % 4 的值，用于计算旋转后图片区域

	// These matrices will be used to move and zoom image
	Matrix matrix = new Matrix();
	Matrix savedMatrix = new Matrix();
	DisplayMetrics dm;

	float minScaleR;// 最小缩放比例
	static final float MAX_SCALE = 10f;// 最大缩放比例

	// We can be in one of these 3 states
	static final int NONE = 0;// 初始状态
	static final int DRAG = 1;// 拖动
	static final int ZOOM = 2;// 缩放
	private static final String TAG = "11";
	int mode = NONE;

	// Remember some things for zooming
	PointF prev = new PointF();
	PointF mid = new PointF();
	float oldDist = 1f;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_crop_image_view);

		setUpViews();
		setUpListeners();
		Intent intent = getIntent();
		Uri uri = intent.getData();
		if (uri != null) {
			bitmap = getBitmapFromUri(uri);
			if (bitmap != null) {
				screenshot_imageView.setImageBitmap(bitmap);
			}
		}
		rectIV = screenshot_imageView.getDrawable().getBounds();

		getStatusBarHeight();
		minZoom();
		center();
		screenshot_imageView.setImageMatrix(matrix);
	}

	/**
	 * 获取状态栏高度 下面方法在oncreate中调用时获得的状态栏高度为0，不能用 Rect frame = new Rect();
	 * getWindow().getDecorView().getWindowVisibleDisplayFrame(frame); int
	 * statusBarHeight = frame.top;
	 */
	private void getStatusBarHeight() {
		try {
			Class<?> c = Class.forName("com.android.internal.R$dimen");
			Object obj = c.newInstance();
			Field field = c.getField("status_bar_height");
			int x = Integer.parseInt(field.get(obj).toString());
			statusBarHeight = getResources().getDimensionPixelSize(x);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private Bitmap getBitmapFromUri(Uri uri) {
		try {
			// 读取uri所在的图片
			Bitmap bitmap = MediaStore.Images.Media.getBitmap(
					this.getContentResolver(), uri);
			return bitmap;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	private void setUpViews() {
		screenshot_imageView=(ImageView)findViewById(R.id.image_view);
		
		cancel_btn = (Button) findViewById(R.id.cancel_btn);
		ok_btn = (Button) findViewById(R.id.ok_btn);
		rotate_btn = (Button) findViewById(R.id.rotate_btn);
		clipview = (ClipView) findViewById(R.id.clipview);
		dm = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(dm);
		width = dm.widthPixels;
		height = dm.heightPixels;
		
		screenshot_imageView.setImageMatrix(matrix);
	}

	private void setUpListeners() {
		cancel_btn.setOnClickListener(this);
		ok_btn.setOnClickListener(this);
		rotate_btn.setOnClickListener(this);
		screenshot_imageView.setOnTouchListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.cancel_btn:
			finish();
			break;
		case R.id.ok_btn:
			Bitmap fianBitmap = getBitmap();
            System.out.println("最终图片宽度="+fianBitmap.getWidth());
            System.out.println("最终图片高度="+fianBitmap.getHeight());
            System.out.println("图片大小="+fianBitmap.getByteCount());
			Bundle extras = new Bundle();
			extras.putParcelable("data", fianBitmap);
			setResult(Constant.CROP_PICTURE, (new Intent()).setAction("inline-data")
					.putExtras(extras));
			this.finish();
			break;
		case R.id.rotate_btn:
			n = ++angleInt % 4;
			// 图片旋转-90度
			matrix.postRotate(-90, screenshot_imageView.getWidth() / 2,
					screenshot_imageView.getHeight() / 2);
			savedMatrix.postRotate(-90);
			screenshot_imageView.setImageMatrix(matrix);
			break;
		}
	}

	/**
	 * 下面的触屏方法摘自网上经典的触屏方法 只在判断是否在图片区域内做了少量修改
	 * 
	 */
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		ImageView view = (ImageView) v;
		// Handle touch events here...
		switch (event.getAction() & MotionEvent.ACTION_MASK) {
		// 主点按下
		case MotionEvent.ACTION_DOWN:
			savedMatrix.set(matrix);
			// 设置初始点位置
			prev.set(event.getX(), event.getY());
			if (isOnCP(event.getX(), event.getY())) {
				// 触点在图片区域内
				Log.d(TAG, "mode=DRAG");
				mode = DRAG;
			} else {
				mode = NONE;
			}
			break;
		case MotionEvent.ACTION_POINTER_DOWN:
			oldDist = spacing(event);
			// 判断触点是否在图片区域内
			boolean isonpic = isOnCP(event.getX(), event.getY());
			Log.d(TAG, "oldDist=" + oldDist);
			// 如果连续两点距离大于10，则判定为多点模式
			if (oldDist > 10f && isonpic) {
				savedMatrix.set(matrix);
				midPoint(mid, event);
				mode = ZOOM;
				Log.d(TAG, "mode=ZOOM");
			}
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_POINTER_UP:
			mode = NONE;
			Log.d(TAG, "mode=NONE");
			break;
		case MotionEvent.ACTION_MOVE:
			if (mode == DRAG) {
				// ...
				matrix.set(savedMatrix);
				matrix.postTranslate(event.getX() - prev.x, event.getY()
						- prev.y);
			} else if (mode == ZOOM) {
				float newDist = spacing(event);
				Log.d(TAG, "newDist=" + newDist);
				if (newDist > 10f) {
					matrix.set(savedMatrix);
					float scale = newDist / oldDist;
					matrix.postScale(scale, scale, mid.x, mid.y);
				}
			}
			break;
		}
		view.setImageMatrix(matrix);
		CheckView();
		return true; // indicate event was handled
	}

	/**
	 * 两点的距离 Determine the space between the first two fingers
	 */
	private float spacing(MotionEvent event) {
		float x = event.getX(0) - event.getX(1);
		float y = event.getY(0) - event.getY(1);
		return FloatMath.sqrt(x * x + y * y);
	}

	/**
	 * 两点的中点 Calculate the mid point of the first two fingers
	 * */
	private void midPoint(PointF point, MotionEvent event) {
		float x = event.getX(0) + event.getX(1);
		float y = event.getY(0) + event.getY(1);
		point.set(x / 2, y / 2);
	}

	/**
	 * 判断点所在的控制点
	 * 
	 * @param evx
	 * @param evy
	 * @return
	 */
	private boolean isOnCP(float evx, float evy) {
		float p[] = new float[9];
		matrix.getValues(p);
		float scale = Math.max(Math.abs(p[0]), Math.abs(p[1]));
		// 由于本人很久不用数学，矩阵的计算已经忘得差不多了，所以图片区域的计算只能按最笨的办法，
		// 根据旋转角度分四种情况计算图片区域，如果哪位达人修改一下只用一个表达式，那可以减少很多代码
		RectF rectf = null;
		switch (n) {
		case 0:
			rectf = new RectF(p[2], p[5], (p[2] + rectIV.width() * scale),
					(p[5] + rectIV.height() * scale));
			break;
		case 1:
			rectf = new RectF(p[2], p[5] - rectIV.width() * scale, p[2]
					+ rectIV.height() * scale, p[5]);
			break;
		case 2:
			rectf = new RectF(p[2] - rectIV.width() * scale, p[5]
					- rectIV.height() * scale, p[2], p[5]);
			break;
		case 3:
			rectf = new RectF(p[2] - rectIV.height() * scale, p[5], p[2], p[5]
					+ rectIV.width() * scale);
			break;
		}
		if (rectf != null && rectf.contains(evx, evy)) {
			return true;
		}
		return false;
	}

	/**
	 * 最小缩放比例，最大为100%
	 */
	private void minZoom() {
		minScaleR = Math.min((float) dm.widthPixels / (float) bitmap.getWidth()
				/ 2, (float) dm.widthPixels / (float) bitmap.getHeight() / 2);
		if (minScaleR < 1.0 / 2) {
			float scale = Math.max(
					(float) dm.widthPixels / (float) bitmap.getWidth(),
					(float) dm.widthPixels / (float) bitmap.getHeight());
			matrix.postScale(scale, scale);
		} else {
			minScaleR = 1.0f;
		}
	}

	/**
	 * 限制最大最小缩放比例
	 */
	private void CheckView() {
		float p[] = new float[9];
		matrix.getValues(p);
		float scale = Math.max(Math.abs(p[0]), Math.abs(p[1]));
		if (mode == ZOOM) {
			if (scale < minScaleR) {
				matrix.setScale(minScaleR, minScaleR);
				center();
			}
			if (scale > MAX_SCALE) {
				matrix.set(savedMatrix);
			}
		}
	}

	private void center() {
		center(true, true);
	}

	/**
	 * 横向、纵向居中
	 */
	protected void center(boolean horizontal, boolean vertical) {

		Matrix m = new Matrix();
		m.set(matrix);
		RectF rect = new RectF(0, 0, bitmap.getWidth(), bitmap.getHeight());
		m.mapRect(rect);

		float height = rect.height();
		float width = rect.width();

		float deltaX = 0, deltaY = 0;

		if (vertical) {
			// 图片小于屏幕大小，则居中显示。大于屏幕，上方留空则往上移，下方留空则往下移
			int screenHeight = dm.heightPixels;
			if (height < screenHeight) {
				deltaY = (screenHeight - height - statusBarHeight) / 2
						- rect.top;
			} else if (rect.top > 0) {
				deltaY = -rect.top;
			} else if (rect.bottom < screenHeight) {
				deltaY = screenshot_imageView.getHeight() - rect.bottom;
			}
		}

		if (horizontal) {
			int screenWidth = dm.widthPixels;
			if (width < screenWidth) {
				deltaX = (screenWidth - width) / 2 - rect.left;
			} else if (rect.left > 0) {
				deltaX = -rect.left;
			} else if (rect.right > screenWidth) {
				deltaX = (screenWidth - width) / 2 - rect.left;
			}
		}
		matrix.postTranslate(deltaX, deltaY);
		if (n % 4 != 0) {
			matrix.postRotate(-90 * (n % 4),
					screenshot_imageView.getWidth() / 2,
					screenshot_imageView.getHeight() / 2);
		}
	}

	/* 获取矩形区域内的截图 */
	private Bitmap getBitmap() {
		getBarHeight();
		Bitmap screenShoot = takeScreenShot();
		System.out.println("screenShoot Width="+screenShoot.getWidth());
		System.out.println("screenShoot height="+screenShoot.getHeight());
		Bitmap finalBitmap = Bitmap.createBitmap(screenShoot, ClipView.SX + 1,
				(height - width + statusBarHeight) / 2 + 1, width - ClipView.SX
						- ClipView.EX - 1, width - ClipView.SX - ClipView.EX
						- 1);
		return finalBitmap;
	}

	private void getBarHeight() {
		// 获取状态栏高度
		Rect frame = new Rect();
		this.getWindow().getDecorView().getWindowVisibleDisplayFrame(frame);

		statusBarHeight = frame.top;

		int contenttop = this.getWindow()
				.findViewById(Window.ID_ANDROID_CONTENT).getTop();
		// statusBarHeight是上面所求的状态栏的高度
		titleBarHeight = contenttop - statusBarHeight;

		Log.v(TAG, "statusBarHeight = " + statusBarHeight
				+ ", titleBarHeight = " + titleBarHeight);
	}

	// 获取Activity的截屏
	private Bitmap takeScreenShot() {
		View view = this.getWindow().getDecorView();
		view.setDrawingCacheEnabled(true);
		view.buildDrawingCache();
		return view.getDrawingCache();
	}

}
