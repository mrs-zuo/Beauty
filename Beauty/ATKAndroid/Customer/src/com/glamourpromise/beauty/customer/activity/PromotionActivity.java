package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.PromotionViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.PromotionInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;

public class PromotionActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Promotion";
	private static final String GET_PROMOTION_LIST = "GetPromotionList";
	private ArrayList<View> mViewList = new ArrayList<View>();
	List<Map<String, Object>> PromotionList = new ArrayList<Map<String, Object>>();
	View childView;
	LayoutInflater mLayoutInflater;
	private TextView promotionTextView;
	private ImageView promotionImageView;
	private ViewPager viewPager;
	private List<ImageView> iamgeViewGroup;
	private int currentViewPagerPosition;
	private Dialog promotionInfoDialog;
	private ArrayList<PromotionInformation> promotionList;
	PromotionViewPagerAdapter mPagerAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_promotion_viewpager);
		mLayoutInflater = getLayoutInflater();
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.scan_info_button).setOnClickListener(this);
		findViewById(R.id.promotion_viewpager).setOnClickListener(this);
		promotionList = new ArrayList<PromotionInformation>();
		initActivity();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	
	@Override
	protected void onDestroy(){
		super.onDestroy();
		Bitmap bitmap;
		for (View view : mViewList) {
			bitmap = view.getDrawingCache();
			if(bitmap != null)
				bitmap.recycle();
		}
		System.gc();
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
		switch (v.getId()) {
		case R.id.scan_info_button:
			getCurrentPromotionInfo();
			break;
		case R.id.promotion_viewpager:
			getCurrentPromotionInfo();
			break;
		default:
			break;
		}
	}
	
	private void initActivity(){
		promotionList.clear();
		getData();
	}
	
	private void getData(){
		super.asyncRefrshView(this);
	}

	private void createPromotionViewPager(ArrayList<View> mViewList) {
		viewPager = (ViewPager) findViewById(R.id.promotion_viewpager);
		LinearLayout group = (LinearLayout) findViewById(R.id.viewGroup);
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

		mPagerAdapter = new PromotionViewPagerAdapter(mViewList);
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

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {
				
			}
		});

	}
	
	private void getCurrentPromotionInfo(){
		View view = getLayoutInflater().inflate(R.xml.promotion_info_view,null);
		promotionInfoDialog = new AlertDialog.Builder(this).setView(view).create();
		TextView branchNameView = (TextView) view.findViewById(R.id.branch_content);
		TextView branchTimeView = (TextView) view.findViewById(R.id.time_content);
		branchNameView.setText(promotionList.get(currentViewPagerPosition).getPromotionBranchInfo());
		branchTimeView.setText(promotionList.get(currentViewPagerPosition).getPromotionTime());
		promotionInfoDialog.show();
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("ImageHeight",1250);
			para.put("ImageWidth",720);
		} catch (JSONException e) {
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_PROMOTION_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_PROMOTION_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				promotionList = PromotionInformation.parseListByJson(response.getStringData());
				ProgressBar bar = (ProgressBar) findViewById(R.id.pb);
				bar.setVisibility(View.GONE);
				int promotionCount = promotionList.size();
				if(promotionCount > 0){
					findViewById(R.id.scan_info_button).setVisibility(View.VISIBLE);
				}else{
					findViewById(R.id.scan_info_button).setVisibility(View.INVISIBLE);
				}
				for (int i = 0; i < promotionCount; i++) {
					//该内容是文字促销
					if (promotionList.get(i).getPromotionType().equals("1")) {
						childView = mLayoutInflater.inflate(R.xml.promotion_textcontent_view, null);
						promotionTextView = (TextView) childView.findViewById(R.id.promotion_text_content);
						promotionTextView.setText(promotionList.get(i).getPromotionContent());
						mViewList.add(childView);
					} 
					//内容是图片促销
					else {
						childView = mLayoutInflater.inflate(R.xml.promotion_imagecontent_view, null);
						promotionImageView = (ImageView) childView.findViewById(R.id.promotion_image_content);
						if(!promotionList.get(i).getPromotionContent().equals("")){
							Picasso.with(getApplicationContext()).load(promotionList.get(i).getPromotionContent()).into(promotionImageView);
						}
						mViewList.add(childView);
					}
					//点击每个View，弹出具体的信息
					childView.setOnClickListener(new OnClickListener() {
						
						@Override
						public void onClick(View v) {
							getCurrentPromotionInfo();
						}
					});
				}
				createPromotionViewPager(mViewList);
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
		super.dismissProgressDialog();
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
}
