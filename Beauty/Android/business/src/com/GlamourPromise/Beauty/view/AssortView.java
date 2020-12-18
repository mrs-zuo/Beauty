package com.GlamourPromise.Beauty.view;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.Button;
public class AssortView extends Button {
	public interface OnTouchAssortListener {
		public void onTouchAssortListener(String s);
		public void onTouchAssortUP();
	}
	public AssortView(Context context) {
		super(context);
	}
	public AssortView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	public AssortView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	private String[] assort = {"#","A", "B", "C", "D", "E", "F", "G",
			"H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
			"U", "V", "W", "X", "Y", "Z"};
	private Paint paint = new Paint();
	private int selectIndex = -1;
	private OnTouchAssortListener onTouch;
	public void setOnTouchAssortListener(OnTouchAssortListener onTouch) {
		this.onTouch = onTouch;
	}
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		super.onDraw(canvas);
		canvas.drawColor(Color.TRANSPARENT);
		int height = getHeight();
		int width = getWidth();
		int interval = height / assort.length-1;
		for (int i = 0, length = assort.length; i < length; i++) {
			paint.setAntiAlias(true);//抗锯齿设置
			paint.setTypeface(Typeface.DEFAULT_BOLD);//字体设置为默认的粗体
			paint.setTextSize(20);
			//当选中该字母时，则设置字体大小和颜色
			/*if (i == selectIndex) {
				paint.setColor(Color.parseColor("#3399ff"));
				paint.setFakeBoldText(true);
				paint.setTextSize(50);
			}*/
			float xPos = width / 2 - paint.measureText(assort[i]) / 2;
			float yPos = interval * i + interval;
			canvas.drawText(assort[i], xPos, yPos, paint);
			paint.reset();
		}
	}
	@Override
	public boolean dispatchTouchEvent(MotionEvent event) {
		// TODO Auto-generated method stub
		float y = event.getY();
		int index = (int) (y / getHeight() * assort.length);
		if (index >= 0 && index < assort.length) {
			switch (event.getAction()) {
			case MotionEvent.ACTION_MOVE:
				if (selectIndex != index) {
					selectIndex = index;
					if (onTouch != null) {
						onTouch.onTouchAssortListener(assort[selectIndex]);
					}
				}
				break;
			case MotionEvent.ACTION_DOWN:
				selectIndex = index;
				if (onTouch != null) {
					onTouch.onTouchAssortListener(assort[selectIndex]);
				}
				break;
			case MotionEvent.ACTION_UP:
				if (onTouch != null) {
					onTouch.onTouchAssortUP();
				}
				selectIndex = -1;
				break;
			}
		} else {
			selectIndex = -1;
			if (onTouch != null) {
				onTouch.onTouchAssortUP();
			}
		}
		invalidate();
		return true;
	}
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		return super.onTouchEvent(event);
	}
}
