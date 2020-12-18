package com.glamourpromise.beauty.customer.custom.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.GridView;

public class RecommendGridView extends GridView {
    public RecommendGridView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public RecommendGridView(Context context) {
        super(context);
    }

    public RecommendGridView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }
    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2, MeasureSpec.AT_MOST);
        super.onMeasure(widthMeasureSpec, expandSpec);
    }
} 