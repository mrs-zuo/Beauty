package com.glamourpromise.beauty.customer.custom.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.TextView;

public class TextViewBorderUnder extends TextView {
	private Paint mPaint;

	public TextViewBorderUnder(Context context, AttributeSet attrs) {
		super(context, attrs);
		mPaint = new Paint();
		mPaint.setAntiAlias(true);
		mPaint.setColor(Color.GRAY);
	}

	@SuppressLint("ResourceAsColor")
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		canvas.drawLine(0, this.getHeight() / 2, this.getWidth(), this.getHeight() / 2, mPaint);

	}
}
