package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.ViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.bean.SubServiceInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.OrigianlImageView;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.IntentUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.squareup.picasso.Picasso;

public class ServiceDetailActivity extends BaseActivity implements
		OnClickListener, IConnectTask{
	private static final String GET_SERVICE_CATEGORY_NAME = "Service";
	private static final String GET_SERVICE_DETAIL = "getServiceDetailByServiceCode_2_1";
	private static final String ADD_CART_CATEGORY_NAME = "Cart";
	private static final String ADD_CART = "addCart";
	private static final String ADD_FAVORITE_CATEGORY_NAME = "Customer";
	private static final String ADD_FAVORITE = "AddFavorite";
	private static final String CANCEL_FAVORITE = "DelFavorite";
	private static final int GET_SERVICE_TASK_FLAG = 1;
	private static final int ADD_CART_FLAG = 2;
	private static final int ADD_FAVORITE_FLAG = 3;
	private static final int CANCEL_FAVORITE_FLAG = 4;
	private static final int ADD_ORDER_FLAG = 5;
	private int taskFlag;
	private String serviceCode;
	private int imageCount=0;
	private ServiceInformation serviceInfo;
	private RelativeLayout serviceImageShowLinearlayout;
	private View childView;
	private ViewPager viewPager;
	private ViewPagerAdapter PagerAdapter;
	private ImageView arrowRight;
	private ImageView arrowLeft;
	private List<View> mViewList = new ArrayList<View>();
	private LayoutInflater mLayoutInflater;	
	private TableLayout productEnalbeInfoLayout;
	private HashMap<String, Boolean> branchSelectFlagMap;
	private String lastSelectBranchID;
	private String lastSelectBranchName;
	private Button addServiceToCartBtn,addServiceToOrderBtn;
	ArrayList<HashMap<String, String>> productEnalbeInfoList;
	private ImageButton  addAppointmentButton,addServiceToFavoriteBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_service_detail);
		super.setTitle("服务详情");
		serviceCode = getIntent().getStringExtra("serviceCode");
		initActivity();
	}

	private void initActivity() {
		mLayoutInflater = getLayoutInflater();
		serviceImageShowLinearlayout = (RelativeLayout) findViewById(R.id.service_image_show_linearlayout);
		arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
		arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
		addAppointmentButton=(ImageButton) findViewById(R.id.add_appointment_button);
		addAppointmentButton.setOnClickListener(this);
		productEnalbeInfoLayout = (TableLayout) findViewById(R.id.product_enalbe_info_layout);
		addServiceToCartBtn = (Button) findViewById(R.id.add_cart_button);
		addServiceToCartBtn.setOnClickListener(this);	
		addServiceToFavoriteBtn=(ImageButton)findViewById(R.id.add_favorite_button);
		addServiceToFavoriteBtn.setOnClickListener(this);
		findViewById(R.id.add_favorite_relativelayout).setOnClickListener(this);
		addServiceToOrderBtn=(Button) findViewById(R.id.add_order_button);
		addServiceToOrderBtn.setOnClickListener(this);
		taskFlag = GET_SERVICE_TASK_FLAG;
		super.asyncRefrshView(this);
	}
	
	private void createProductEnalbeInfoLayout(ArrayList<HashMap<String, String>> productEnalbeInfoList){
		productEnalbeInfoLayout.removeViews(1,productEnalbeInfoLayout.getChildCount()-1);
		TextView branchNameView;
		for(HashMap<String, String> item:productEnalbeInfoList){
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.service_in_branch_detail_item, null);
			branchNameView = (TextView) contentLayout.findViewById(R.id.branch_name);
			branchNameView.setText(item.get("BranchName"));
			ImageButton selectButton=(ImageButton) contentLayout.findViewById(R.id.branch_select);
			selectButton.setTag(item.get("BranchID"));
			OnClickListener branchClickListener=getBranchSelectListener(); 
			selectButton.setOnClickListener(branchClickListener);
			if(productEnalbeInfoList.size() == 1){
				selectButton.setBackgroundResource(R.drawable.one_select_icon);
				selectButton.setOnClickListener(null);
				lastSelectBranchID = (String) selectButton.getTag();
				lastSelectBranchName=branchNameView.getText().toString();
			}
			productEnalbeInfoLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			productEnalbeInfoLayout.addView(contentLayout);
		}
	}
	
	private OnClickListener getBranchSelectListener(){
		OnClickListener clickListener = new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String branchID = (String) v.getTag();
				if(branchSelectFlagMap.get(branchID) == null || !branchSelectFlagMap.get(branchID)){
					branchSelectFlagMap.put(branchID, true);
					v.setBackgroundResource(R.drawable.one_select_icon);
					if(!lastSelectBranchID.equals("0") && lastSelectBranchID != branchID){
						branchSelectFlagMap.put(lastSelectBranchID, false);
						int size = productEnalbeInfoLayout.getChildCount();
						View view;
						View button;
						View branchText;
						for(int i = 0; i <size; i++){
							view = productEnalbeInfoLayout.getChildAt(i);
							button = view.findViewById(R.id.branch_select);
							branchText = view.findViewById(R.id.branch_name);
							if(button != null && ((String) button.getTag()).equals(lastSelectBranchID)){
								button.setBackgroundResource(R.drawable.one_unselect_icon);
							}
						}
					}
					lastSelectBranchID = branchID;
					for(HashMap<String, String> item:productEnalbeInfoList){
						if(item.get("BranchID")==lastSelectBranchID){
							lastSelectBranchName=item.get("BranchName");
						}
					}
				}else if(branchSelectFlagMap.get(branchID)){
					branchSelectFlagMap.put(branchID, false);
					lastSelectBranchID = "0";
					lastSelectBranchName="";
					v.setBackgroundResource(R.drawable.one_unselect_icon);
				}
			}
		};
		return clickListener;
	}

	private void setServiceDetail() {
		imageCount = serviceInfo.getImageCount();
		if (imageCount == 0)
			serviceImageShowLinearlayout.setVisibility(View.GONE);
		else
			createServiceImageView();
		if (serviceInfo.getServiceDescribe() != null && !(("").equals(serviceInfo.getServiceDescribe()))) {
			createServiceIntroudction();
		}else{
			((TableLayout) findViewById(R.id.service_introduction)).setVisibility(View.GONE);
		}
		createServiceNameTableRow();
		createServicePriceTableRow();
	}

	private void createServiceImageView() {
		if(mViewList==null)
			mViewList=new ArrayList<View>();
		else
			mViewList.clear();
		if (null != serviceInfo.getThumbnail() && !(("").equals(serviceInfo.getThumbnail()))) {
			String[] imageUrlArray = serviceInfo.getThumbnail().trim().split(",");
			for (int i = 0; i < imageUrlArray.length; i++) {
				childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
				final ImageView companyImage = (ImageView) childView.findViewById(R.id.company_image);
				final String imageURL=imageUrlArray[i];
				companyImage.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View view) {
						// TODO Auto-generated method stub
						String originalImageUrl=imageURL.split("&")[0];
						new OrigianlImageView(ServiceDetailActivity.this,companyImage,originalImageUrl).showOrigianlImage();
					}
				});
				Picasso.with(getApplicationContext()).load(imageUrlArray[i]).into(companyImage);
				mViewList.add(childView);
			}
		}
		createServiceViewPager(mViewList);
	}

	private void createServiceViewPager(List<View> mViewList) {
		imageCount = mViewList.size();
		arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
		if (imageCount == 1) {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
		}
		viewPager = (ViewPager) findViewById(R.id.commodity_image_viewpager);
		PagerAdapter = new ViewPagerAdapter(mViewList);
		viewPager.setAdapter(PagerAdapter);
		viewPager.setOnPageChangeListener(new OnPageChangeListener() {

			@Override
			public void onPageSelected(int position) {
				if (position == 0) {
					arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
				} else {
					arrowLeft.setBackgroundResource(R.drawable.arrow_left_red);
				}
				if (position == imageCount - 1) {
					arrowRight
							.setBackgroundResource(R.drawable.arrow_right_gray);
				} else {
					arrowRight
							.setBackgroundResource(R.drawable.arrow_right_red);
				}
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2) {

			}

			@Override
			public void onPageScrollStateChanged(int arg0) {

			}
		});

	}

	private void createServiceIntroudction() {
		if (serviceInfo.getServiceDescribe().equals("")
				|| serviceInfo.getServiceDescribe().equals("anyType{}"))
			((TableLayout) findViewById(R.id.service_introduction))
					.setVisibility(View.GONE);
		else {
			((TextView) findViewById(R.id.service_introduction_content))
					.setText(serviceInfo.getServiceDescribe());
		}
	}

	private void createServiceNameTableRow() {
		TextView serviceNameView = (TextView) findViewById(R.id.service_name_text);
		serviceNameView.setText(serviceInfo.getName());
		// 如果有子服务，则显示子服务的名称 和 服务时间列表
		if (serviceInfo.isHasSubService()) {
			TableLayout serviceNameTable = (TableLayout) findViewById(R.id.service_name);
			serviceNameTable.removeViews(3,serviceNameTable.getChildCount()-3);
			for (SubServiceInformation subService : serviceInfo.getSubServiceList()) {
				View subServiceView = mLayoutInflater.inflate(R.xml.sub_service_list_item, null);
				TextView subServiceNameView = (TextView) subServiceView.findViewById(R.id.sub_service_name);
				TextView subServiceTimeView = (TextView) subServiceView.findViewById(R.id.sub_service_spend_time);
				subServiceNameView.setText(subService.getSubServiceName());
				subServiceTimeView.setText(subService.getSubServiceSpendTime()+ "分钟");
				serviceNameTable.addView(subServiceView);
			}
		} else {
			findViewById(R.id.service_detail_service_time_divide_view).setVisibility(View.VISIBLE);
			findViewById(R.id.service_detail_service_time_relativelayout).setVisibility(View.VISIBLE);
			findViewById(R.id.service_detail_service_count_divide_view).setVisibility(View.VISIBLE);
			findViewById(R.id.service_detail_service_count_relativelayout).setVisibility(View.VISIBLE);
			TextView serviceTimeView = (TextView) findViewById(R.id.service_time_content_text);
			TextView serviceCountView = (TextView) findViewById(R.id.service_count_content_text);
			serviceTimeView.setText(String.valueOf(serviceInfo.getServiceSpendTime()) + "分钟");
			if(serviceInfo.getServiceCourseFrequency()==0)
				serviceCountView.setText("不限次");
			else
				serviceCountView.setText(String.valueOf(serviceInfo.getServiceCourseFrequency()) + "次");
		}

	}

	private void createServicePriceTableRow() {
		TextView serviceUnitPriceView = (TextView) findViewById(R.id.service_unit_price_content_text);
		String tmpUnitPrice = serviceInfo.getUnitPrice();
		serviceUnitPriceView.setText(NumberFormatUtil.StringFormatToString(this, tmpUnitPrice));
		TextView serviceExpirationDateText=(TextView)findViewById(R.id.service_expiration_date_text);
		int serviceExpirationDate=serviceInfo.getExpirationDate();
		boolean haveExpiration=serviceInfo.isHaveExpiration();
		if(haveExpiration){
			if(serviceExpirationDate==0)
				serviceExpirationDateText.setText("当天有效");
			else
				serviceExpirationDateText.setText(serviceExpirationDate+"天");
		}
		else{
			findViewById(R.id.service_expiration_date_divide_view).setVisibility(View.GONE);
			findViewById(R.id.service_expiration_date_relativelayout).setVisibility(View.GONE);
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.btn_main_home:
			IntentUtil.assignToDefault(this);
			break;
		case R.id.btn_main_back:
			finish();
			break;
		case R.id.add_cart_button:
			if(lastSelectBranchID.equals("0")){
				DialogUtil.createShortDialog(this, "请选择购买门店");
			}else{
				addServiceToCart();
			}
			break;
		case R.id.add_order_button:
			if(lastSelectBranchID.equals("0")){
				DialogUtil.createShortDialog(this, "请选择购买门店");
			}else{
				addServiceToOrder();
			}
			break;
		case R.id.add_favorite_relativelayout:
			addServiceToFavorite();
			break;
		case R.id.add_favorite_button:
			addServiceToFavorite();
			break;
		case R.id.add_appointment_button:
			if(lastSelectBranchID.equals("0")){
				DialogUtil.createShortDialog(this, "请选择预约门店");
			}else{
				Intent it =new Intent(this,AppointmentCreateActivity.class);
				it.putExtra("branchID",lastSelectBranchID);
				it.putExtra("branchName",lastSelectBranchName);
				it.putExtra("taskSourceType",1);
				Bundle bu = new Bundle();
				bu.putInt("serviceID", serviceInfo.getID());
				bu.putString("serviceName", serviceInfo.getName());
				bu.putString("serviceCode", serviceCode);
				bu.putBoolean("isOldOrder", false);
				it.putExtras(bu);
				startActivity(it);
			}
			break;
		}
	}
	private void addServiceToCart() {
		taskFlag = ADD_CART_FLAG;
		super.asyncRefrshView(this);
	}
	private void addServiceToOrder() {
		taskFlag = ADD_ORDER_FLAG;
		super.asyncRefrshView(this);
	}
	private void addServiceToFavorite() {
		String mFavoriteID=serviceInfo.getmFavoriteID();
		if(mFavoriteID!=null && !mFavoriteID.equals(""))
			taskFlag = CANCEL_FAVORITE_FLAG;
		else
			taskFlag = ADD_FAVORITE_FLAG;
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag==GET_SERVICE_TASK_FLAG){
			catoryName =GET_SERVICE_CATEGORY_NAME;
			methodName =GET_SERVICE_DETAIL;
			try {
				para.put("CustomerID", mCustomerID);
				para.put("ProductCode",serviceCode);
				para.put("ImageHeight",String.valueOf(400));
				para.put("ImageWidth", String.valueOf(400));
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==ADD_CART_FLAG){
			catoryName =ADD_CART_CATEGORY_NAME;
			methodName = ADD_CART;
			try {
				para.put("ProductCode",serviceCode);
				para.put("Quantity",1);
				para.put("ProductType",0);
				para.put("BranchID",lastSelectBranchID);
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==ADD_FAVORITE_FLAG){
			catoryName =ADD_FAVORITE_CATEGORY_NAME;
			methodName = ADD_FAVORITE;
			try {
				para.put("ProductType",0);
				para.put("ProductCode",serviceCode);
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==CANCEL_FAVORITE_FLAG){
			catoryName =ADD_FAVORITE_CATEGORY_NAME;
			methodName = CANCEL_FAVORITE;
			try {
				para.put("UserFavoriteID",serviceInfo.getmFavoriteID());
			} catch (JSONException e) {
			}
		}
		else if(taskFlag==ADD_ORDER_FLAG){
			catoryName =ADD_CART_CATEGORY_NAME;
			methodName = ADD_CART;
			try {
				para.put("ProductCode",serviceCode);
				para.put("Quantity",1);
				para.put("ProductType",0);
				para.put("BranchID",lastSelectBranchID);
			} catch (JSONException e) {
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName,methodName,para.toString());
		WebApiRequest request = new WebApiRequest(catoryName,methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag==GET_SERVICE_TASK_FLAG){
					serviceInfo = new ServiceInformation();
					serviceInfo.parseByJson(response.getStringData());
					setServiceDetail();
					productEnalbeInfoList = serviceInfo.getProductEnalbeInfoMap();
					branchSelectFlagMap = new HashMap<String, Boolean>();
					lastSelectBranchID = "0";
					createProductEnalbeInfoLayout(productEnalbeInfoList);
					String mFavoriteID=serviceInfo.getmFavoriteID();
					if(mFavoriteID!=null && !mFavoriteID.equals(""))
						addServiceToFavoriteBtn.setBackgroundResource(R.drawable.favorite_icon);
					else
						addServiceToFavoriteBtn.setBackgroundResource(R.drawable.un_favorite_icon);
				}
				else if(taskFlag==ADD_CART_FLAG){
					LeftMenuPresenter.getInstace(mApp).addCartCount(1);
					DialogUtil.createShortDialog(this,response.getMessage());
				}
				else if(taskFlag==ADD_FAVORITE_FLAG || taskFlag==CANCEL_FAVORITE_FLAG){
					DialogUtil.createShortDialog(this,response.getMessage());
					taskFlag = GET_SERVICE_TASK_FLAG;
					super.asyncRefrshView(this);
				}
				else if(taskFlag==ADD_ORDER_FLAG){
					LeftMenuPresenter.getInstace(mApp).addCartCount(1);
					DialogUtil.createShortDialog(this,response.getMessage());
					Intent destIntent=new Intent(this,NavigationNew.class);
					destIntent.putExtra("NavigationType",2);
					startActivity(destIntent);
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
