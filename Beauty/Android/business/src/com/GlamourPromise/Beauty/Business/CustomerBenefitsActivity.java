package com.GlamourPromise.Beauty.Business;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.CustomerServicingFragmentAdapter;
import com.GlamourPromise.Beauty.fragment.ExpiredBenefitsFragment;
import com.GlamourPromise.Beauty.fragment.UnUsedBenefitsFragment;
import com.GlamourPromise.Beauty.fragment.UsedBenefitsFragment;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.util.ArrayList;
import java.util.List;

/*
 * 顾客福利包页
 * */
public class CustomerBenefitsActivity extends FragmentActivity {
    private List<Fragment> fragmentList = new ArrayList<Fragment>();// 保存碎片的集合
    private ViewPager customerBenefitsViewPager;
    private UnUsedBenefitsFragment unUsedBenefitsFragment;//未使用优惠券
    private ExpiredBenefitsFragment expiredBenefitsFragment;//已过期优惠券
    private UsedBenefitsFragment usedBenefitsFragment;//已使用优惠券
    private CustomerServicingFragmentAdapter customerServicingFragmentAdapter;
    private TextView tabUnUsedBenefitsTitle, tabExpiredBenefitsTitle, tabUsedBenefitsTitle;
    private RelativeLayout tabUnUsedBenefitsll, tabExpiredBenefitsll, tabUsedBenefitsll;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_benefits);
        initView();
    }

    // 初始化视图
    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        customerBenefitsViewPager = (ViewPager) findViewById(R.id.customer_benefits_list_view_pager);
        unUsedBenefitsFragment = new UnUsedBenefitsFragment();
        expiredBenefitsFragment = new ExpiredBenefitsFragment();
        usedBenefitsFragment = new UsedBenefitsFragment();
        fragmentList.add(unUsedBenefitsFragment);
        fragmentList.add(expiredBenefitsFragment);
        fragmentList.add(usedBenefitsFragment);
        tabUnUsedBenefitsTitle = (TextView) findViewById(R.id.customer_benefits_unused_title);
        tabUnUsedBenefitsll = (RelativeLayout) findViewById(R.id.tab_customer_benefits_unused_ll);
        tabExpiredBenefitsTitle = (TextView) findViewById(R.id.customer_benefits_expired_title);
        tabExpiredBenefitsll = (RelativeLayout) findViewById(R.id.tab_customer_benefits_expired_ll);
        tabUsedBenefitsTitle = (TextView) findViewById(R.id.customer_benefits_used_title);
        tabUsedBenefitsll = (RelativeLayout) findViewById(R.id.tab_customer_benefits_used_ll);
        customerServicingFragmentAdapter = new CustomerServicingFragmentAdapter(this.getSupportFragmentManager(), fragmentList);
        customerBenefitsViewPager.setAdapter(customerServicingFragmentAdapter);
        customerBenefitsViewPager.setCurrentItem(0);
        tabUnUsedBenefitsll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerBenefitsViewPager.setCurrentItem(0, false);
            }
        });
        tabExpiredBenefitsll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerBenefitsViewPager.setCurrentItem(1, false);
            }
        });
        tabUsedBenefitsll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                customerBenefitsViewPager.setCurrentItem(2, false);
            }
        });
        customerBenefitsViewPager.setOnPageChangeListener(new OnPageChangeListener() {
            @Override
            public void onPageSelected(int state) {
                // TODO Auto-generated method stub
            }

            @Override
            public void onPageScrolled(int position, float offset, int offsetPiexls) {
                resetAllItem();
                switch (position) {
                    case 0:
                        setCurrentItemBackground(tabUnUsedBenefitsTitle);
                        break;
                    case 1:
                        setCurrentItemBackground(tabExpiredBenefitsTitle);
                        break;
                    case 2:
                        setCurrentItemBackground(tabUsedBenefitsTitle);
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int position) {
                // TODO Auto-generated method stub
            }
        });
    }

    protected void onRestart() {
        super.onRestart();
    }

    protected void setCurrentItemBackground(TextView currentItemText) {
        currentItemText.setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
    }

    protected void resetAllItem() {
        tabUnUsedBenefitsTitle.setTextColor(getResources().getColor(R.color.white));
        tabExpiredBenefitsTitle.setTextColor(getResources().getColor(R.color.white));
        tabUsedBenefitsTitle.setTextColor(getResources().getColor(R.color.white));
    }

    protected void onDestroy() {
        super.onDestroy();
    }
}
