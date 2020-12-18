package com.glamourpromise.beauty.customer.custom.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.TableRow;

public class TableRowBorderUnder extends TableRow {
	private Paint mPaint;

	public TableRowBorderUnder(Context context, AttributeSet attrs) {
		super(context, attrs);
		mPaint = new Paint();
		mPaint.setAntiAlias(true);
		mPaint.setColor(Color.GREEN);

	}

	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		canvas.drawLine(0, getHeight() - 1, getWidth() - 1, getHeight() - 1, mPaint);

	}

}
