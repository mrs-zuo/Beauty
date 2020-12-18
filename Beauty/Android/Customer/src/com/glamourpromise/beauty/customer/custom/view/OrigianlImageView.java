package com.glamourpromise.beauty.customer.custom.view;
import com.glamourpromise.beauty.customer.R;
import com.squareup.picasso.Picasso;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.PopupWindow;
public class OrigianlImageView {
	private Context      mContext;
	private View         originalImageLayout;
	private ImageView    originalImageView;
	private PopupWindow mOriginalImageWindow;
	private View        mParentView;
	private String      imageURL;
	public OrigianlImageView(Context mContext,View parentView,String imageURL) {
		super();
		this.mContext = mContext;
		this.mParentView=parentView;
		this.imageURL=imageURL;
	}
	public  void showOrigianlImage(){
		LayoutInflater inflater = LayoutInflater.from(mContext);
		originalImageLayout = inflater.inflate(R.xml.original_image_view, null);
		mOriginalImageWindow = new PopupWindow(originalImageLayout, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT,true);
		originalImageLayout.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				mOriginalImageWindow.dismiss();
			}
		});
		originalImageView = (ImageView) originalImageLayout.findViewById(R.id.original_image);
		Picasso.with(mContext).load(imageURL).into(originalImageView);
		mOriginalImageWindow.setBackgroundDrawable(new BitmapDrawable());
		mOriginalImageWindow.showAtLocation(mParentView,Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);
	}
}
