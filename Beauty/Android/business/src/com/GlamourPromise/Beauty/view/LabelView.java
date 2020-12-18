package com.GlamourPromise.Beauty.view;

import com.GlamourPromise.Beauty.Business.R;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

public class LabelView extends FrameLayout  {
	private TextView contentView;
	private DeleteOnClickListener mDeleteClickListener;
	
	private String labelContent;
	
	public interface DeleteOnClickListener{
		public void onClick(LabelView labelView);
	}

	public LabelView(Context context) {
		this(context, null);
	}

	public LabelView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public LabelView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		// TODO Auto-generated constructor stub
//		TypedArray mTypedArray = context.obtainStyledAttributes(attrs,R.styleable.LabelView);
//		labelContent = mTypedArray.getString(R.styleable.LabelView_labelContent);
//		mTypedArray.recycle();
		init(context);
	}
	
	@SuppressLint({ "ResourceAsColor", "NewApi" })
	private void init(Context context){
		contentView = new TextView(context);
		FrameLayout.LayoutParams textViewLP = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		textViewLP.rightMargin = 20;
		textViewLP.topMargin = 20;
		contentView.setMaxWidth(300);
		contentView.setSingleLine();
		contentView.setTextColor(R.color.blue);
		contentView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
//		contentView.setText(labelContent);
		addView(contentView, textViewLP);
		
		FrameLayout.LayoutParams layoutLP = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		layoutLP.gravity = Gravity.RIGHT;
		ImageView deleteIcon = new ImageView(context);
		deleteIcon.setImageResource(R.drawable.note_label_delete_icon);

		addView(deleteIcon, layoutLP);

		deleteIcon.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				if(mDeleteClickListener != null)
					mDeleteClickListener.onClick(LabelView.this);
			}
		});
	}
	
	public void setLabelContent(String content){
		contentView.setText(content);
		contentView.invalidate();
	}
	
	public void setOnDeleteClickListener(DeleteOnClickListener deleteClickListener){
		mDeleteClickListener = deleteClickListener;
	}


}
