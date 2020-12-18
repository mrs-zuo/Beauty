package cn.com.antika.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.PopupWindow;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import cn.com.antika.business.R;
import cn.com.antika.util.ImageLoaderUtil;

@SuppressLint("ResourceType")
public class OrigianlImageView {
	private Context      mContext;
	private View         originalImageLayout;
	private ImageView    originalImageView;
	private PopupWindow mOriginalImageWindow;
	private View        mParentView;
	private ImageLoader imageLoader;
	private DisplayImageOptions displayImageOptions;
	private String      imageURL;
	public OrigianlImageView(Context mContext,View parentView,String imageURL) {
		super();
		this.mContext = mContext;
		this.mParentView=parentView;
		imageLoader = ImageLoader.getInstance();
		displayImageOptions =ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
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
		imageLoader.displayImage(imageURL,originalImageView,displayImageOptions);
		mOriginalImageWindow.setBackgroundDrawable(new BitmapDrawable());
		mOriginalImageWindow.showAtLocation(mParentView,Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);
	}
}
