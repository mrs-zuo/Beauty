package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.PromotionViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.TreatmentImageInformation;
import com.glamourpromise.beauty.customer.bean.TreatmentInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.squareup.picasso.Picasso;

public class ServiceOrderTreatmentGroupServiceEffectActivity extends BaseActivity implements IConnectTask {
	private static final String CATEGORY_NAME = "Image";
	private static final String GET_TREATMENT_IMAGE = "getServiceEffectImage";	
	private List<TreatmentImageInformation> beforeTreatmentImageList;
	private List<TreatmentImageInformation> afterTreatmentImageList;
	private LayoutInflater mLayoutInflater;
	private List<View> mViewListBefore = new ArrayList<View>();
	private List<View> mViewListAfter = new ArrayList<View>();
	private android.support.v4.view.ViewPager beforeEffectViewPager;// 治疗前
	private ViewPager afterEffectViewPager;// 治疗后
	private PromotionViewPagerAdapter viewPagerAdapter;
	private ImageView arrowRight;
	private ImageView arrowLeft;
	private ImageView arrowRight2;
	private ImageView arrowLeft2;
	private int beforeImageCount;
	private int afterImageCount;
	private List<TreatmentInformation>      treatmentList;
	private LinearLayout        treatmentListLinearLayout;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_service_order_treatment_group_effect);
		initView();
	}

	protected void initView() {
		afterEffectViewPager = (ViewPager) findViewById(R.id.after_treatment_viewpager);
		arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
		arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
		arrowRight2 = (ImageView) findViewById(R.id.arrow_right_icon_2);
		arrowLeft2 = (ImageView) findViewById(R.id.arrow_left_icon_2);
		beforeTreatmentImageList = new ArrayList<TreatmentImageInformation>();
		afterTreatmentImageList = new ArrayList<TreatmentImageInformation>();
		mLayoutInflater = getLayoutInflater();
		treatmentListLinearLayout=(LinearLayout)findViewById(R.id.treatment_list_linearlayout);
		requestWebService();
	}

	private void addImageToViewPager(List<View> viewList, List<TreatmentImageInformation> treatmentImageList) {
		View childView;
		ImageView beforeEffertImageView;
		String url;
		for (TreatmentImageInformation treatmentImage : treatmentImageList) {
			childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
			beforeEffertImageView = (ImageView) childView.findViewById(R.id.company_image);
			url = treatmentImage.getTreatmentImageURL();
			if(url.equals("") || url.equals("null")){
				Picasso.with(getApplicationContext()).load(R.drawable.head_image_null).into(beforeEffertImageView);
			}else{
				Picasso.with(getApplicationContext()).load(treatmentImage.getTreatmentImageURL()).error(R.drawable.head_image_null).into(beforeEffertImageView);
			}
			
			viewList.add(childView);
		}
	}

	private void createBeforeEffertImageViewPager(List<View> mViewList) {
		beforeImageCount = mViewList.size();
		arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
		Log.v("beforeImageCount", String.valueOf(beforeImageCount));
		if (beforeImageCount < 2) {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
		}
		beforeEffectViewPager = (ViewPager) findViewById(R.id.before_treatment_viewpager);
		viewPagerAdapter = new PromotionViewPagerAdapter(mViewList);
		beforeEffectViewPager.setAdapter(viewPagerAdapter);
		beforeEffectViewPager
				.setOnPageChangeListener(new OnPageChangeListener() {

					@Override
					public void onPageSelected(int position) {
						if (position == 0) {
							arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
						} else {
							arrowLeft.setBackgroundResource(R.drawable.arrow_left_red);
						}
						if (position == beforeImageCount - 1) {
							arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
						} else {
							arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
						}
					}

					@Override
					public void onPageScrolled(int position,float positionOffset, int positionOffsetPixels) {
						// TODO Auto-generated method stub

					}

					@Override
					public void onPageScrollStateChanged(int state) {
						// TODO Auto-generated method stub

					}
				});
	}

	private void createAffterEffertImageViewPager(List<View> mViewList) {
		afterImageCount = mViewList.size();
		arrowLeft2.setBackgroundResource(R.drawable.arrow_left_gray);
		if (afterImageCount < 2) {
			arrowRight2.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight2.setBackgroundResource(R.drawable.arrow_right_red);
		}
		afterEffectViewPager = (ViewPager) findViewById(R.id.after_treatment_viewpager);
		viewPagerAdapter = new PromotionViewPagerAdapter(mViewList);
		afterEffectViewPager.setAdapter(viewPagerAdapter);
		afterEffectViewPager.setOnPageChangeListener(new OnPageChangeListener() {

					@Override
					public void onPageSelected(int position) {
						if (position == 0) {
							arrowLeft2.setBackgroundResource(R.drawable.arrow_left_gray);
						} else {
							arrowLeft2.setBackgroundResource(R.drawable.arrow_left_red);
						}
						if (position == afterImageCount - 1) {
							arrowRight2.setBackgroundResource(R.drawable.arrow_right_gray);
						} else {
							arrowRight2.setBackgroundResource(R.drawable.arrow_right_red);
						}
					}

					@Override
					public void onPageScrolled(int position,
							float positionOffset, int positionOffsetPixels) {
						// TODO Auto-generated method stub
					}

					@Override
					public void onPageScrollStateChanged(int state) {
						// TODO Auto-generated method stub

					}
				});
	}
	protected void createTreatmentList(){
		//循环遍历出Treatment的列表
		if(treatmentList!=null && treatmentList.size()>0){
			treatmentListLinearLayout.removeAllViews();
			for(final TreatmentInformation treatment:treatmentList){
				View treatmentView=mLayoutInflater.inflate(R.xml.treatment_group_treatment_item,null);
				TextView  subServiceNameText=(TextView)treatmentView.findViewById(R.id.subservice_name);
				subServiceNameText.setText(treatment.getSubServiceName());
				treatmentView.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						Intent destIntent=new Intent();
						destIntent.putExtra("TreatmentID",Integer.parseInt(treatment.getTreatmentID()));
						destIntent.putExtra("current_tab",1);
						destIntent.setClass(ServiceOrderTreatmentGroupServiceEffectActivity.this,ServiceOrderTreatmentDetailActivityGroup.class);
						startActivity(destIntent);
					}
				});
				treatmentListLinearLayout.addView(treatmentView);
			}
		}
	}
	protected void requestWebService() {
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();		
		try {
			para.put("GroupNo",getIntent().getStringExtra("GroupNo"));
			if (mApp.getScreenWidth() == 720) {
				para.put("ImageThumbHeight","150");
				para.put("ImageThumbWidth","150");
			}
			else if (mApp.getScreenWidth() ==1536) {
				para.put("ImageThumbHeight", "300");
				para.put("ImageThumbWidth", "300");
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_TREATMENT_IMAGE, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_TREATMENT_IMAGE, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				try {
					JSONObject data = new JSONObject(response.getStringData());
					JSONArray list;
					list = data.getJSONArray("ImageBeforeTreatment");
					beforeTreatmentImageList = TreatmentImageInformation.parseListByJson(list.toString());
					list = data.getJSONArray("ImageAfterTreatment");
					afterTreatmentImageList = TreatmentImageInformation.parseListByJson(list.toString());
					addImageToViewPager(mViewListBefore, beforeTreatmentImageList);
					createBeforeEffertImageViewPager(mViewListBefore);
					addImageToViewPager(mViewListAfter, afterTreatmentImageList);
					createAffterEffertImageViewPager(mViewListAfter);
					if(data.has("TMList") && !data.isNull("TMList")){
						JSONArray  treatmentJsonArray=data.getJSONArray("TMList");
						if(treatmentJsonArray!=null){
							if(treatmentList==null)
								treatmentList=new ArrayList<TreatmentInformation>();
							else
								treatmentList.clear();
			        		for(int i=0;i<treatmentJsonArray.length();i++){
			        			JSONObject treatmentObjectJson=null;
			        			TreatmentInformation  treatment=new TreatmentInformation();
			        			try {
									treatmentObjectJson=treatmentJsonArray.getJSONObject(i);
								} catch (JSONException e) {
								}
			        			int treatmentID=0;
			        			String subserviceName="";
			        			try {
									if (treatmentObjectJson.has("TreatmentID") && !treatmentObjectJson.isNull("TreatmentID"))
										treatmentID = treatmentObjectJson.getInt("TreatmentID");
									if (treatmentObjectJson.has("SubServiceName") && !treatmentObjectJson.isNull("SubServiceName"))
										subserviceName = treatmentObjectJson.getString("SubServiceName");
								} catch (JSONException e) {
								
								}
								treatment.setTreatmentID(String.valueOf(treatmentID));
								treatment.setSubServiceName(subserviceName);
								treatmentList.add(treatment);
			        		}
			        	}
					}
					createTreatmentList();
				} catch (JSONException e) {
					e.printStackTrace();
				}
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
		
	}
}
