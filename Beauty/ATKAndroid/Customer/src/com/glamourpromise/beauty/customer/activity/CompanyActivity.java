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
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class CompanyActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private ViewPager customerInfoViewPager;
	private CustomerInfoPagerAdapter customerInfoFragmentAdapter;
	private LinearLayout tabCompanyDetailLl, tabBranchListLl,tabUnreadNoticeLl;
	private View        tabCompanyDetailDivideView, tabBranchListDivideView,tabUnreadNoticeDivideView;
	LocalActivityManager manager = null;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_company);
		super.setTitle("商家详情");
		manager = new LocalActivityManager(this , true);
        manager.dispatchCreate(savedInstanceState);
		initView();
	}

	private void initView(){
		customerInfoViewPager = (ViewPager) findViewById(R.id.customer_info_view_pager);
		ArrayList<View> viewList=new ArrayList<View>();
		Intent it0=new Intent(this,BranchDetailActivity.class);
		it0.putExtra("BranchID", "0");
		it0.putExtra("strCompanyID", mCompanyID);
		it0.putExtra("flag", "1");
		viewList.add(getView("BranchDetailActivity", it0));
		Intent it1=new Intent(this,BranchListActivity.class);
		viewList.add(getView("BranchListActivity", it1));
		Intent it2=new Intent(this,NoticeListActivity.class);
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
	public void onClick(View view) {
		super.onClick(view);
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
