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
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CustomerInfoPagerAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class BranchActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private UserInfoApplication userInfo;
	private ViewPager customerInfoViewPager;// 显示商家  门店  公告
	private CustomerInfoPagerAdapter customerInfoFragmentAdapter;
	private LinearLayout tabCompanyDetailLl, tabBranchListLl,tabUnreadNoticeLl;
	private View        tabCompanyDetailDivideView, tabBranchListDivideView,tabUnreadNoticeDivideView;
	LocalActivityManager manager = null;
	private int  branchID;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_branch);
		super.setTitle("门店信息");
		manager = new LocalActivityManager(this , true);
        manager.dispatchCreate(savedInstanceState);
        Intent intent = getIntent();
		branchID = intent.getIntExtra("BranchID",0);
		userInfo = (UserInfoApplication)getApplication();
		initView();
	}

	private void initView(){
		customerInfoViewPager = (ViewPager) findViewById(R.id.customer_info_view_pager);
		ArrayList<View> viewList=new ArrayList<View>();
		Intent it0=new Intent(this,BranchDetailActivity.class);
		it0.putExtra("BranchID",branchID);
		it0.putExtra("strCompanyID", super.mCompanyID);
		it0.putExtra("flag", "2");// 2:分店的信息
		viewList.add(getView("BranchDetailActivity", it0));
		Intent it1=new Intent(this,BranchPromotionActivity.class);
		it1=it1.putExtra("FROM_SOURCE", 1);
		it1=it1.putExtra("BranchID",branchID);
		viewList.add(getView("BranchPromotionActivity", it1));
		Intent it2=new Intent(this,AccountListActivity.class);
		it2.putExtra("flag", "2");
		it2.putExtra("branchID",branchID);
		// 3：与顾客相关的Account（顾客有消费的分店，聊过天的，顾客所在分店）
		it2.putExtra("branchName", userInfo.getLoginInformation().getCompanyAbbreviation() + "的服务团队");
		viewList.add(getView("NoticeListActivity", it2));
		tabCompanyDetailLl=(LinearLayout)findViewById(R.id.tab_company_detail_ll);
		tabCompanyDetailDivideView=findViewById(R.id.tab_company_detail_divide_view);
		tabBranchListLl=(LinearLayout) findViewById(R.id.tab_branch_list_ll);
		tabBranchListDivideView=findViewById(R.id.tab_branch_list_divide_view);
		tabUnreadNoticeLl=(LinearLayout)findViewById(R.id.tab_unread_notice_ll);
		tabUnreadNoticeDivideView=findViewById(R.id.tab_unread_notice_divide_view);
		customerInfoFragmentAdapter = new CustomerInfoPagerAdapter(viewList);
		customerInfoViewPager.setAdapter(customerInfoFragmentAdapter);
		customerInfoViewPager.setCurrentItem(0);
		tabCompanyDetailLl.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerInfoViewPager.setCurrentItem(0,false);
			}
		});
		tabBranchListLl.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerInfoViewPager.setCurrentItem(1,false);
			}
		});
		tabUnreadNoticeLl.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				customerInfoViewPager.setCurrentItem(2,false);
			}
		});
		customerInfoViewPager.setOnPageChangeListener(new OnPageChangeListener() {
			@Override
			public void onPageSelected(int state) {
			}
			@Override
			public void onPageScrolled(int position, float offset,int offsetPiexls) {
				resetAllItem();
				switch (position) {
				case 0:
					setCurrentItemBackground(tabCompanyDetailDivideView);
					break;
				case 1:
					setCurrentItemBackground(tabBranchListDivideView);
					break;
				case 2:
					setCurrentItemBackground(tabUnreadNoticeDivideView);
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
		tabCompanyDetailDivideView.setVisibility(View.GONE); 
		tabBranchListDivideView.setVisibility(View.GONE);
		tabUnreadNoticeDivideView.setVisibility(View.GONE);
	}
	 private View getView(String id, Intent intent) {
	        return manager.startActivity(id, intent).getDecorView();
	 }
	 
	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public WebApiRequest getRequest() {
		return null;
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		
	}
}
