package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.MapView;
import com.baidu.mapapi.map.MarkerOptions;
import com.baidu.mapapi.map.OverlayOptions;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.model.LatLngBounds;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.ViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CompanyInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.HSClickSpan;
import com.squareup.picasso.Picasso;

public class BranchDetailActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Company";
	private static final String GET_BRANCH_DETAIL = "GetBusinessDetail";
	private TableLayout tableLayoutCompanySummary;
	private int    branchID;
	private String flag;// 表示该页面显示的是分店信息还是总店信息
	private List<View> mViewList = new ArrayList<View>();
	private View childView;
	private LayoutInflater mLayoutInflater;
	private ViewPager viewPager;
	private ViewPagerAdapter PagerAdapter;
	private BaiduMap mBaiduMap;
	private MapView mMapView = null;
	private int imageCount;
	private ImageView arrowRight;
	private ImageView arrowLeft;	
	private CompanyInformation companyInformation;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_company_information);
		// 取参数
		Intent intent = getIntent();
		branchID = intent.getIntExtra("BranchID",0);
		intent.getStringExtra("strCompanyID");
		flag = intent.getStringExtra("flag");// 1:总店信息 2:分店的信息
		mMapView = (MapView) findViewById(R.id.bmapView);
		mLayoutInflater = getLayoutInflater();
		refreshData();
	}
	
	@Override
	protected void onResume() {
		mMapView.onResume(); 
		super.onResume();
		//leftMenu.getMenu().showContent();
	}
	
	@Override
	protected void onPause(){
		 mMapView.onPause();  
		super.onPause();
	}
	
	@Override
	protected void onDestroy(){
		mMapView.onDestroy();  
		super.onDestroy();
	}

	private void refreshView() {
		RelativeLayout accountAccountLayout = (RelativeLayout) findViewById(R.id.account_count_layout);
		if(companyInformation.getAccountCount().equals("0"))
			accountAccountLayout.setVisibility(View.GONE);
		else {
			TextView accountCountView = (TextView) findViewById(R.id.account_list_count);
			accountCountView.setText("(" + companyInformation.getAccountCount()
					+ ")");
			accountAccountLayout.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					Intent destIntent = new Intent(BranchDetailActivity.this, AccountListActivity.class);
					destIntent.putExtra("flag", flag);// 确定取总店还是分店的accountList；1：总店的；2：分店的
					destIntent.putExtra("branchID", branchID);
					StringBuilder branchName = new StringBuilder();
					if (companyInformation.getAbbreviation().equals(""))
						branchName.append(companyInformation.getName());
					else
						branchName.append(companyInformation.getAbbreviation());
					branchName.append("的服务团队");
					destIntent.putExtra("branchName", branchName.toString());
					startActivity(destIntent);
				}
			});
		}
		createTableName();
		createImageLayout();
		createTableSummary();
		createTableBusinessHours();
		createTableContact();
		createTableAddress();
		createTableZip();
		createTableWeb();
		createTableAbbreviation();
		createMapView();
	}

	private void createImageLayout() {
		ImageView CompanyImage;
		if(companyInformation!=null){
			if (!companyInformation.getIamgeCount().equals("0")) {
				String url;
				for (int i = 0; i < companyInformation.getImageURL().size(); i++) {
					childView = mLayoutInflater.inflate(R.xml.viewpager_image_view, null);
					CompanyImage = (ImageView) childView.findViewById(R.id.company_image);
					url = companyInformation.getImageURL().get(i);
					if(!url.equals("") && !url.equals("null")){
						Picasso.with(getApplicationContext()).load(companyInformation.getImageURL().get(i)).into(CompanyImage);
					}					
					mViewList.add(childView);
				}
				createViewPager(mViewList);
			} else {
				RelativeLayout layout = (RelativeLayout) findViewById(R.id.company_image_layout);
				layout.setVisibility(View.GONE);
			}
		}

	}

	private void createMapView() {
		TableLayout layout = (TableLayout) findViewById(R.id.company_map);
		if (!companyInformation.getLatitude().equals("-1") && !companyInformation.getLongitude().equals("-1") && branchID!=0) {
			layout.setVisibility(View.VISIBLE);
			//定义Maker坐标点  
			LatLng point = new LatLng(Double.valueOf(companyInformation.getLatitude()), Double.valueOf(companyInformation.getLongitude()));  
			//构建Marker图标  
			BitmapDescriptor bitmap = BitmapDescriptorFactory.fromResource(R.drawable.icon_map_point);  
			//构建MarkerOption，用于在地图上添加Marker  
			OverlayOptions option = new MarkerOptions().position(point).perspective(false).icon(bitmap);  
			//在地图上添加Marker，并显示  
			mBaiduMap = mMapView.getMap();
			MapStatusUpdate msu = MapStatusUpdateFactory.zoomTo(18.0f);
			mBaiduMap.setMapStatus(msu);
			mBaiduMap.addOverlay(option);
			LatLngBounds bounds = new LatLngBounds.Builder().include(point).build();
			MapStatusUpdate u = MapStatusUpdateFactory.newLatLng(bounds.getCenter());
			mBaiduMap.setMapStatus(u);
		}
		else{
			layout.setVisibility(View.GONE);
		}
	}

	private void createViewPager(List<View> mViewList) {
		arrowRight = (ImageView) findViewById(R.id.arrow_right_icon);
		arrowLeft = (ImageView) findViewById(R.id.arrow_left_icon);
		imageCount = mViewList.size();
		arrowLeft.setBackgroundResource(R.drawable.arrow_left_gray);
		if (imageCount == 1) {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
		} else {
			arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
		}
		viewPager = (ViewPager) findViewById(R.id.company_image_viewpager);

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
					arrowRight.setBackgroundResource(R.drawable.arrow_right_gray);
				} else {
					arrowRight.setBackgroundResource(R.drawable.arrow_right_red);
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

	protected void createTableSummary() {
		tableLayoutCompanySummary = (TableLayout) findViewById(R.id.company_Summary);
		if (!companyInformation.getSummary().equals("")) {
			createTableLayout(tableLayoutCompanySummary, 1,getString(R.string.summary),companyInformation.getSummary(),0);
		} else {
			tableLayoutCompanySummary.setVisibility(View.GONE);
		}
	}

	protected void createTableBusinessHours() {
		TableLayout tableLayoutBusinessHours = (TableLayout) findViewById(R.id.company_business_hours);
		if (!companyInformation.getbBusinessHours().equals("")) {
			createTableLayout(tableLayoutBusinessHours, 1,getString(R.string.business_time),companyInformation.getbBusinessHours(),0);
		} else {
			tableLayoutBusinessHours.setVisibility(View.GONE);
		}

	}

	protected void createTableContact() {
		TableLayout tableLayoutContactInformation = (TableLayout) findViewById(R.id.company_contact_information);
		if (!companyInformation.getContact().equals("")) {
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.company_detail_contact_layout, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(getString(R.string.contact_person));
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			contentTextView.setText(companyInformation.getContact());
			tableLayoutContactInformation.addView(Layout);
		}
		if (!companyInformation.getPhone().equals("")) {
			tableLayoutContactInformation.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.company_detail_contact_layout, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(getString(R.string.phone));
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			String content=companyInformation.getPhone();
			SpannableString spannableString=new SpannableString(content);
			ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,2);
			spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
			contentTextView.setAutoLinkMask(Linkify.PHONE_NUMBERS);
			contentTextView.setMovementMethod(LinkMovementMethod.getInstance());
			contentTextView.setText(spannableString);
			tableLayoutContactInformation.addView(Layout);
		}

		if (!companyInformation.getFax().equals("")) {
			tableLayoutContactInformation.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.company_detail_contact_layout, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(getString(R.string.fax));
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			contentTextView.setText(companyInformation.getFax());
			tableLayoutContactInformation.addView(Layout);
		}

		if ((companyInformation.getContact().equals("")) && (companyInformation.getPhone().equals("")) && (companyInformation.getFax().equals(""))) {
			tableLayoutContactInformation.setVisibility(View.GONE);
		}
	}

	protected void createTableAddress() {
		TableLayout tableLayoutAddress = (TableLayout) findViewById(R.id.company_address);
		if (!companyInformation.getAddress().equals("") && !flag.equals("1")) {
			// 显示邮编
			if (!companyInformation.getZip().equals("")) {
				createTableLayout(tableLayoutAddress, 2,getString(R.string.address),"",0);
			} else {
				createTableLayout(tableLayoutAddress, 2,getString(R.string.address), "",0);
			}
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
			TextView contentTextView = (TextView) contentLayout.findViewById(R.id.left_textview);
			contentTextView.setText(companyInformation.getAddress());
			tableLayoutAddress.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			tableLayoutAddress.addView(contentLayout);
		} else {
			tableLayoutAddress.setVisibility(View.GONE);
		}

	}
	protected void createTableZip() {
		TableLayout tableLayoutZip = (TableLayout) findViewById(R.id.company_business_zip);
		if (!companyInformation.getZip().equals("") ) {
			createTableLayout(tableLayoutZip, 2,"邮编",companyInformation.getZip(),0);
		} else {
			tableLayoutZip.setVisibility(View.GONE);
		}
	}
	protected void createTableAbbreviation() {
		TableLayout tableLayoutAbbreviation = (TableLayout) findViewById(R.id.company_business_abbreviation);
		if (!companyInformation.getAbbreviation().equals("") && branchID==0) {
			createTableLayout(tableLayoutAbbreviation, 2,getString(R.string.company_business_abbreviation),companyInformation.getAbbreviation(),0);
		} else {
			tableLayoutAbbreviation.setVisibility(View.GONE);
		}
	}
	protected void createTableName() {
		TableLayout tableLayoutName = (TableLayout) findViewById(R.id.company_business_name);
		if (!companyInformation.getName().equals("")) {
			((TextView)findViewById(R.id.company_business_name_text)).setText(companyInformation.getName());
		} else {
			tableLayoutName.setVisibility(View.GONE);
		}

	}
	protected void createTableWeb() {
		TableLayout tableLayoutWeb = (TableLayout) findViewById(R.id.company_web);
		if (!companyInformation.getWeb().equals("")) {
			createTableLayout(tableLayoutWeb, 1,getString(R.string.web_address),companyInformation.getWeb(),1);
		} else {
			tableLayoutWeb.setVisibility(View.GONE);
		}

	}

	private void createTableLayout(TableLayout tableLayout, int flag,String title, String content,int linkFlag) {
		//linkFlag 0: 不匹配  1：匹配网址  2：匹配电话号码
		// 一行显示一个textview
		if (flag == 1) {
			RelativeLayout titleLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_content_view, null);
			TextView titleTextView = (TextView) titleLayout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			TextView contentTextView = (TextView) contentLayout.findViewById(R.id.content_textview);
			SpannableString spannableString=new SpannableString(content);
			if(linkFlag==1){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,1);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.WEB_URLS);
			}
			else if(linkFlag==2){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,2);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.PHONE_NUMBERS);
			}
			if(linkFlag!=0){
				contentTextView.setMovementMethod(LinkMovementMethod.getInstance());
				contentTextView.setText(spannableString);
			}
			else{
				contentTextView.setText(content);
			}
			tableLayout.addView(titleLayout);
			tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			tableLayout.addView(contentLayout);
		} else if (flag == 2) {
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_two_child_view, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.text_color));
			TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			SpannableString spannableString=new SpannableString(content);
			if(linkFlag==1){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,1);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.WEB_URLS);
			}
			else if(linkFlag==2){
				ClickableSpan clickSpan=new HSClickSpan(contentTextView,this,2);
				spannableString.setSpan(clickSpan,0,content.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
				contentTextView.setAutoLinkMask(Linkify.PHONE_NUMBERS);
			}
			if(linkFlag!=0){
				contentTextView.setMovementMethod(LinkMovementMethod.getInstance());
				contentTextView.setText(spannableString);
			}
			else{
				contentTextView.setText(content);
			}
			tableLayout.addView(Layout);
		}
	}
	
	private void refreshData(){
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("BranchID", branchID);
			para.put("ImageWidth",mApp.getScreenWidth());
			para.put("ImageHeight",(mApp.getScreenWidth()/4)*3);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_BRANCH_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_BRANCH_DETAIL, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				companyInformation = (CompanyInformation) response.mData;
				refreshView();
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
	}

	@Override
	public void parseData(WebApiResponse response) {
		if(response.getHttpCode() == 200 && response.getCode() == WebApiResponse.GET_WEB_DATA_TRUE){
			CompanyInformation companyInformation = new CompanyInformation();
			companyInformation.parseByJson(response.getStringData());
			response.mData = companyInformation;
		}
	}
}
