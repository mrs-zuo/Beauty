package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
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
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.PromotionViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.PromotionDetail;
import com.glamourpromise.beauty.customer.bean.PromotionDetail.BranchList;
import com.glamourpromise.beauty.customer.bean.PromotionInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;

public class PromotionDetailActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Promotion";
	private static final String GET_PROMOTION_DETAIL = "GetPromotionDetail";
	private ArrayList<View> mViewList = new ArrayList<View>();
	List<Map<String, Object>> PromotionList = new ArrayList<Map<String, Object>>();
	View childView;
	LayoutInflater mLayoutInflater;
	private ArrayList<PromotionInformation> promotionList;
	private PromotionDetail promotionDetail = new PromotionDetail();
	private ImageView promotionImg;
	private TextView promotionStartTime;
	private TextView promotionEndTime;
	private TextView promotionName;
	private TextView campaignContent;
	private RelativeLayout asignmentCommodityList;
	private LinearLayout branchList;
	private WindowManager wm;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_promotion_detail);
		super.setTitle(getString(R.string.menu_promotion_detail));
		super.showProgressDialog();
		mLayoutInflater = getLayoutInflater();
		promotionList = new ArrayList<PromotionInformation>();
		initActivity();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		Bitmap bitmap;
		for (View view : mViewList) {
			bitmap = view.getDrawingCache();
			if (bitmap != null)
				bitmap.recycle();
		}
		System.gc();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
	}
	private void initActivity() {
		promotionImg = (ImageView) findViewById(R.id.activity_promotion_detail_image_view);
		promotionStartTime = (TextView) findViewById(R.id.activity_promotion_detail_promotion_start_time);
		promotionEndTime = (TextView) findViewById(R.id.activity_promotion_detail_promotion_end_time);
		promotionName = (TextView) findViewById(R.id.activity_promotion_detail_promotion_name);
		campaignContent = (TextView) findViewById(R.id.activity_promotion_detail_campaign_content);
		asignmentCommodityList = (RelativeLayout) findViewById(R.id.promotion_detail_content);
		branchList = (LinearLayout) findViewById(R.id.activity_promotion_detail_branch_list);
		promotionList.clear();
		getData();
	}

	private void getData() {
		super.asyncRefrshView(this);
	}
	@SuppressWarnings("deprecation")
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			wm = getWindowManager();
			para.put("ImageHeight",wm.getDefaultDisplay().getWidth()*0.75);
			para.put("ImageWidth", wm.getDefaultDisplay().getWidth());
			para.put("Prama",getIntent().getStringExtra("PromotionCode"));
		} catch (JSONException e) {
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_PROMOTION_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_PROMOTION_DETAIL, para.toString(), header);
		return request;
	}

	@SuppressLint("NewApi")
	@Override
	public void onHandleResponse(WebApiResponse response) {
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				promotionDetail.parseByJson(response.getStringData());
				if (promotionDetail.getPromotionPictureURL() != null && !promotionDetail.getPromotionPictureURL().equals(""))
					Picasso.with(this).load(promotionDetail.getPromotionPictureURL()).error(R.drawable.logo).into(promotionImg);
				else
					promotionImg.setBackgroundResource(R.drawable.logo);
				promotionName.setText(promotionDetail.getTitle());
				String[] promotionList = promotionDetail.getDescription().split("/r/n");
				if (promotionList.length > 1) {
					campaignContent.setVisibility(View.GONE);
					for (int i = 0; i < promotionList.length; i++) {
						final int position = i;
						final String[] promotion = promotionList;
						addAssimentCommodityList(position, promotion);
					}
				} else {
					campaignContent.setVisibility(View.VISIBLE);
					campaignContent.setText(promotionDetail.getDescription());
				}

				promotionStartTime.setText(promotionDetail.getStartDate());
				promotionEndTime.setText(promotionDetail.getEndDate());
				for (int j = 0; j < promotionDetail.getBranchList().size(); j++)
					addAdaptBranchList(j, promotionDetail.getBranchList());
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
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

	private void addAssimentCommodityList(int position, String[] promotionList) {
		View commodityListItem = LayoutInflater.from(this).inflate(R.xml.promotion_detail_of_asignment_commodity_list_item, null);
		TextView commodity = (TextView) commodityListItem.findViewById(R.id.promotion_detail_of_asignment_commodity_list_item_commodity_name);
		asignmentCommodityList.addView(commodityListItem);
		commodity.setText(promotionList[position]);
	}

	private void addAdaptBranchList(int position,ArrayList<BranchList> branchNameList) {
		View branchCell = LayoutInflater.from(this).inflate(R.xml.promotion_detail_branch_list_item, null);
		TextView branchName = (TextView) branchCell.findViewById(R.id.promotion_detail_branch_list_item_branch_name);
		branchList.addView(branchCell);
		branchName.setText(branchNameList.get(position).getBranchName());
		final int finalPosition = position;
		final ArrayList<BranchList> finalBranchNameList = branchNameList;
		branchCell.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent destIntent = new Intent();
				destIntent.putExtra("BranchID",finalBranchNameList.get(finalPosition).getBranchID());
				destIntent.setClass(PromotionDetailActivity.this,BranchActivity.class);
				startActivity(destIntent);
				finish();
			}

		});
	}
}
