package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CustomerInfoPagerAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
public class CustomerAppointmentRelatedActivity extends BaseActivity implements OnClickListener{
	private UserInfoApplication userInfo;
	private ViewPager customerAppointmentRelatedViewPager;
	private CustomerInfoPagerAdapter customerInfoFragmentAdapter;
	private LinearLayout tabRecommendedServiceLL,tabUnfinishOrderLL,tabBoughtServiceLL;
	private View         tabRecommendedServiceDivideView,tabUnfinishOrderDivideView,tabBoughtServiceDivideView;
	LocalActivityManager manager = null;
	private int       branchID;
	private String    branchName;
	private TextView allServiceBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_customer_appointment_related);
		super.setTitle("预约");
		manager = new LocalActivityManager(this ,true);
        manager.dispatchCreate(savedInstanceState);
        Intent intent = getIntent();
		branchID = intent.getIntExtra("BranchID",0);
		branchName=intent.getStringExtra("BranchName");
		userInfo = (UserInfoApplication)getApplication();
		allServiceBtn=(TextView)findViewById(R.id.all_service_btn);
		allServiceBtn.setOnClickListener(this);
		initView();
	}

	private void initView(){
		customerAppointmentRelatedViewPager = (ViewPager) findViewById(R.id.customer_appointment_related_view_pager);
		ArrayList<View> viewList=new ArrayList<View>();
		Intent recommendServiceIntent=new Intent(this,RecommendServiceListActivity.class);
		recommendServiceIntent.putExtra("BranchID",branchID);
		recommendServiceIntent.putExtra("BranchName",branchName);
		viewList.add(getView("RecommendServiceListActivity",recommendServiceIntent));
		Intent unfinihsOrderIntent=new Intent(this,UnfinishOrderListActivity.class);
		unfinihsOrderIntent.putExtra("BranchID",branchID);
		unfinihsOrderIntent.putExtra("BranchName",branchName);
		viewList.add(getView("UnfinishOrderListActivity",unfinihsOrderIntent));
		Intent boughtServiceIntent=new Intent(this,BoughtServiceListActivity.class);
		boughtServiceIntent.putExtra("BranchID",branchID);
		boughtServiceIntent.putExtra("BranchName",branchName);
		viewList.add(getView("BoughtServiceListActivity",boughtServiceIntent));
		tabRecommendedServiceLL=(LinearLayout)findViewById(R.id.tab_recommend_service_ll);
		tabRecommendedServiceDivideView=findViewById(R.id.tab_recommend_service_divide_view);
		tabUnfinishOrderLL=(LinearLayout) findViewById(R.id.tab_unfinish_order_ll);
		tabUnfinishOrderDivideView=findViewById(R.id.tab_unfinish_order_divide_view);
		tabBoughtServiceLL=(LinearLayout)findViewById(R.id.tab_bought_service_ll);
		tabBoughtServiceDivideView=findViewById(R.id.tab_bought_service_divide_view);
		customerInfoFragmentAdapter = new CustomerInfoPagerAdapter(viewList);
		customerAppointmentRelatedViewPager.setAdapter(customerInfoFragmentAdapter);
		customerAppointmentRelatedViewPager.setCurrentItem(0);
		tabRecommendedServiceLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentRelatedViewPager.setCurrentItem(0,false);
			}
		});
		tabUnfinishOrderLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentRelatedViewPager.setCurrentItem(1,false);
			}
		});
		tabBoughtServiceLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerAppointmentRelatedViewPager.setCurrentItem(2,false);
			}
		});
		customerAppointmentRelatedViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			@Override
			public void onPageSelected(int state) {
			}
			@Override
			public void onPageScrolled(int position, float offset,int offsetPiexls) {
				resetAllItem();
				switch (position) {
				case 0:
					setCurrentItemBackground(tabRecommendedServiceDivideView);
					break;
				case 1:
					setCurrentItemBackground(tabUnfinishOrderDivideView);
					break;
				case 2:
					setCurrentItemBackground(tabBoughtServiceDivideView);
					break;
				}
			}
			@Override
			public void onPageScrollStateChanged(int position) {
			}
		});
	}
	protected void setCurrentItemBackground(View currentDivideView){
		currentDivideView.setVisibility(View.VISIBLE);
	}
	protected void resetAllItem() {
		tabRecommendedServiceDivideView.setVisibility(View.GONE);
		tabUnfinishOrderDivideView.setVisibility(View.GONE);
		tabBoughtServiceDivideView.setVisibility(View.GONE);
	}
	 private View getView(String id, Intent intent) {
	        return manager.startActivity(id, intent).getDecorView();
	 }
	@Override
	protected void onResume() {
		super.onResume();
	}
    @Override
	public void onClick(View view) {
    	super.onClick(view);
		switch (view.getId()) {
		case R.id.all_service_btn:
			Intent it=new Intent();
			it.setClass(this,ServiceCategoryListActivity.class);
			startActivity(it);
			break;
		}
	}
}
