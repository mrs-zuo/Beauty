package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.FragmentViewPagerAdapter;
import com.glamourpromise.beauty.customer.base.BaseFragmentActivity;
import com.glamourpromise.beauty.customer.fragment.ExpiredBenefitsFragment;
import com.glamourpromise.beauty.customer.fragment.UnUsedBenefitsFragment;
import com.glamourpromise.beauty.customer.fragment.UsedBenefitsFragment;
import com.glamourpromise.beauty.customer.util.IntentUtil;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
public class CustomerBenefitsActivity extends BaseFragmentActivity implements OnClickListener{
	private List<Fragment>        fragmentList = new ArrayList<Fragment>();// 保存碎片的集合
	private ViewPager                customerBenefitsListViewPager;
	private FragmentViewPagerAdapter      fragmentViewPagerAdapter;
	private UnUsedBenefitsFragment        unUsedBenefitsFragment;//未使用优惠券
	private ExpiredBenefitsFragment       expiredBenefitsFragment;//已过期优惠券
	private UsedBenefitsFragment        usedBenefitsFragment;//已使用优惠券
	private LinearLayout tabCustomerBenefitsUnusedLL,tabCustomerBenefitsExpiredLL,tabCustomerBenefitsUsedLL;
	private View         tabCustomerBenefitsUnusedDivideView,tabCustomerBenefitsExpiredDivideView,tabCustomerBenefitsUsedDivideView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_benfits);
		initView();
	}
	private void initView(){
		customerBenefitsListViewPager = (ViewPager) findViewById(R.id.customer_benefits_list_view_pager);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		unUsedBenefitsFragment = new  UnUsedBenefitsFragment();
		expiredBenefitsFragment = new ExpiredBenefitsFragment();
		usedBenefitsFragment = new    UsedBenefitsFragment();
		fragmentList.add(unUsedBenefitsFragment);
		fragmentList.add(expiredBenefitsFragment);
		fragmentList.add(usedBenefitsFragment);
		tabCustomerBenefitsUnusedLL=(LinearLayout)findViewById(R.id.tab_customer_benefits_unused_ll);
		tabCustomerBenefitsUnusedDivideView=findViewById(R.id.tab_customer_benefits_unused_divide_view);
		tabCustomerBenefitsExpiredLL=(LinearLayout) findViewById(R.id.tab_customer_benefits_expired_ll);
		tabCustomerBenefitsExpiredDivideView=findViewById(R.id.tab_customer_benefits_expired_divide_view);
		tabCustomerBenefitsUsedLL=(LinearLayout)findViewById(R.id.tab_customer_benefits_used_ll);
		tabCustomerBenefitsUsedDivideView=findViewById(R.id.tab_customer_benefits_used_divide_view);
		fragmentViewPagerAdapter = new FragmentViewPagerAdapter(getSupportFragmentManager(), fragmentList);
		customerBenefitsListViewPager.setAdapter(fragmentViewPagerAdapter);
		customerBenefitsListViewPager.setCurrentItem(0);
		tabCustomerBenefitsUnusedLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				customerBenefitsListViewPager.setCurrentItem(0,false);
			}
		});
		tabCustomerBenefitsExpiredLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				customerBenefitsListViewPager.setCurrentItem(1,false);
			}
		});
		tabCustomerBenefitsUsedLL.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				customerBenefitsListViewPager.setCurrentItem(2,false);
			}
		});
		customerBenefitsListViewPager.setOnPageChangeListener(new OnPageChangeListener() {
					@Override
					public void onPageSelected(int state) {
						// TODO Auto-generated method stub
					}
					@Override
					public void onPageScrolled(int position, float offset,int offsetPiexls) {
						resetAllItem();
						switch (position) {
						case 0:
							setCurrentItemBackground(tabCustomerBenefitsUnusedDivideView);
							break;
						case 1:
							setCurrentItemBackground(tabCustomerBenefitsExpiredDivideView);
							break;
						case 2:
							setCurrentItemBackground(tabCustomerBenefitsUsedDivideView);
							break;
						}
					}
					@Override
					public void onPageScrollStateChanged(int position) {
						// TODO Auto-generated method stub
					}
				});
	}
	protected void setCurrentItemBackground(View currentDivideView){
		currentDivideView.setVisibility(View.VISIBLE);
	}
	protected void resetAllItem() {
		tabCustomerBenefitsUnusedDivideView.setVisibility(View.GONE);
		tabCustomerBenefitsExpiredDivideView.setVisibility(View.GONE);
		tabCustomerBenefitsUsedDivideView.setVisibility(View.GONE);
	}
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_main_home:
			IntentUtil.assignToDefault(this);
			break;
		case R.id.btn_main_back:
			finish();
			break;
		}
	}
}
