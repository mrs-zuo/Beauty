package com.GlamourPromise.Beauty.view.sign;

import com.GlamourPromise.Beauty.Business.R;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.Button;
import android.widget.FrameLayout;

/*
 * 电子签名的画面
 * */
public class WritePadDialog extends Dialog {
	Context context;
	LayoutParams p;
	DialogListener dialogListener;

	public WritePadDialog(Context context, DialogListener dialogListener) {
		super(context, R.style.dialog_full_screen);
		this.context = context;
		this.dialogListener = dialogListener;
	}

	static final int BACKGROUND_COLOR = Color.WHITE;
	static final int BRUSH_COLOR = Color.BLACK;
	PaintView mView;
	int mColorIndex;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.write_pad);
		WindowManager wm = (WindowManager) getContext().getSystemService(
				Context.WINDOW_SERVICE);
		p = getWindow().getAttributes();
		p.height = wm.getDefaultDisplay().getHeight();
		p.width = wm.getDefaultDisplay().getWidth();
		getWindow().setAttributes(p);
		mView = new PaintView(context);
		FrameLayout frameLayout = (FrameLayout) findViewById(R.id.tablet_view);
		frameLayout.addView(mView);
		mView.requestFocus();
		//清除按钮
		Button btnClear = (Button) findViewById(R.id.tablet_clear);
		btnClear.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				mView.clear();
			}
		});
		//确定按钮
		Button btnOk = (Button) findViewById(R.id.tablet_ok);
		btnOk.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				try {
					dialogListener.refreshActivity(mView.getCachebBitmap(), 1);
					WritePadDialog.this.dismiss();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
		//取消按钮
		Button btnCancel = (Button) findViewById(R.id.tablet_cancel);
		btnCancel.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				cancel();
				((Activity) context).finish();
			}
		});
	}

	class PaintView extends View {
		private Paint paint;
		private Canvas cacheCanvas;
		private Bitmap cachebBitmap;
		private Path path;

		public Bitmap getCachebBitmap() {
			return cachebBitmap;
		}

		public PaintView(Context context) {
			super(context);
			init();
		}

		private void init() {
			paint = new Paint();
			paint.setAntiAlias(true);
			paint.setStrokeWidth(15);
			paint.setStyle(Paint.Style.STROKE);
			paint.setColor(Color.BLACK);
			path = new Path();
			cachebBitmap = Bitmap.createBitmap(p.width, p.height,Config.ARGB_8888);
			cacheCanvas = new Canvas(cachebBitmap);
			cacheCanvas.drawColor(Color.WHITE);
		}

		public void clear() {
			if (cacheCanvas != null) {
				paint.setColor(BACKGROUND_COLOR);
				cacheCanvas.drawPaint(paint);
				paint.setColor(Color.BLACK);
				cacheCanvas.drawColor(Color.WHITE);
				invalidate();
			}
		}

		@Override
		protected void onDraw(Canvas canvas) {
			canvas.drawBitmap(cachebBitmap, 0, 0, null);
			canvas.drawPath(path, paint);
		}

		@Override
		protected void onSizeChanged(int w, int h, int oldw, int oldh) {
			int curW = cachebBitmap != null ? cachebBitmap.getWidth() : 0;
			int curH = cachebBitmap != null ? cachebBitmap.getHeight() : 0;
			if (curW >= w && curH >= h) {
				return;
			}
			if (curW < w)
				curW = w;
			if (curH < h)
				curH = h;
			Bitmap newBitmap = Bitmap.createBitmap(curW, curH,Bitmap.Config.ARGB_8888);
			Canvas newCanvas = new Canvas();
			newCanvas.setBitmap(newBitmap);
			if (cachebBitmap != null) {
				newCanvas.drawBitmap(cachebBitmap, 0, 0, null);
			}
			cachebBitmap = newBitmap;
			cacheCanvas = newCanvas;
		}

		private float cur_x, cur_y;

		@Override
		public boolean onTouchEvent(MotionEvent event) {
			float x = event.getX();
			float y = event.getY();
			switch (event.getAction()) {
			case MotionEvent.ACTION_DOWN: {
				cur_x = x;
				cur_y = y;
				path.moveTo(cur_x, cur_y);
				break;
			}
			case MotionEvent.ACTION_MOVE: {
				path.quadTo(cur_x, cur_y, x, y);
				cur_x = x;
				cur_y = y;
				break;
			}
			case MotionEvent.ACTION_UP: {
				cacheCanvas.drawPath(path, paint);
				path.reset();
				break;
			}
			}
			invalidate();
			return true;
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		// TODO Auto-generated method stub
		cancel();
		((Activity) context).finish();
		return super.onKeyDown(keyCode, event);
	}
}
