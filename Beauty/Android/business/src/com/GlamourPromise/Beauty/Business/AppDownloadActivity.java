package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.ViewPagerAdapter;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.ArrayList;
import java.util.List;

@SuppressLint("ResourceType")
public class AppDownloadActivity extends BaseActivity{
	private static final String customerQRcodeURL = "http://beauty.glamise.com/assets/img/customerdownload.png";
	private static final String businessQRcodeURL = "http://beauty.glamise.com/assets/img/businessdownload.png";
	private LayoutInflater mLayoutInflater;
	private ImageLoader imageLoader;
	private List<ImageView> iamgeViewGroup;
	private int currentViewPagerPosition;
	private LinearLayout group;
	private ArrayList<String> imageList;
	private String[] appDownloadTexts=new String[]{"顾客端下载","商家端下载"};
	private DisplayImageOptions displayImageOptions;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_app_download);
		BusinessLeftImageButton bussinessLeftMenuBtn=(BusinessLeftImageButton)findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn=(BusinessRightImageButton)findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		group = (LinearLayout) findViewById(R.id.viewGroup);
		mLayoutInflater = getLayoutInflater();
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.goods_image_null);
		imageList = new ArrayList<String>();
		imageList.add(customerQRcodeURL);
		imageList.add(businessQRcodeURL);
		createPromotionView();
	}
	
	private void createPromotionView(){
		View childView;
		ArrayList<View> mViewList = new ArrayList<View>();
		ImageView promotionImageView;
		TextView  appDownloadText;
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(15, 15);
		params.setMargins(15, 0, 15, 0);
		for (int i = 0; i < imageList.size(); i++) {
			childView = mLayoutInflater.inflate(R.xml.app_download_image_view, null);
			appDownloadText=(TextView) childView.findViewById(R.id.app_download_text);
			promotionImageView = (ImageView) childView.findViewById(R.id.app_download_image);
			appDownloadText.setText(appDownloadTexts[i]);
			imageLoader.displayImage(imageList.get(i), promotionImageView,displayImageOptions);
			mViewList.add(mViewList.size(), childView);
		}
		createViewPager(mViewList);
	}
	
	private void createViewPager(ArrayList<View> mViewList) {
		ViewPager viewPager = (ViewPager) findViewById(R.id.app_download_viewpager);
		
		iamgeViewGroup = new ArrayList<ImageView>(mViewList.size());
		currentViewPagerPosition = 0;
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(15, 15);
		params.setMargins(15, 0, 15, 0);
		for (int i = 0; i < mViewList.size(); i++) {
			ImageView currentPositionPromptView = new ImageView(this);
			iamgeViewGroup.add(currentPositionPromptView);
			if (i == 0) {
				iamgeViewGroup.get(i).setBackgroundResource(R.drawable.redpoint);
			} else {
				iamgeViewGroup.get(i).setBackgroundResource(R.drawable.graypoint);
			}
			group.addView(iamgeViewGroup.get(i), params);
		}

		ViewPagerAdapter mPagerAdapter = new ViewPagerAdapter(mViewList);
		viewPager.setAdapter(mPagerAdapter);
		viewPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int position) {
				iamgeViewGroup.get(position).setBackgroundResource(R.drawable.redpoint);
				iamgeViewGroup.get(currentViewPagerPosition).setBackgroundResource(R.drawable.graypoint);
				currentViewPagerPosition = position;
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {
				// TODO Auto-generated method stub

			}
		});
	}
}
