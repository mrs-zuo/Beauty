package com.GlamourPromise.Beauty.Business;

import android.app.LocalActivityManager;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.RelatedOrderPagerAdapter;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.util.ArrayList;

public class OrderListTabActivity extends BaseActivity {
    private ArrayList<View> tabViewList = new ArrayList<View>();//保存Activity的集合
    private ViewPager relatedOrderViewPager;//显示我今日的服务和相关订单
    private TextView tabTodayServiceTitle, tabRelatedOrderTitle;
    private LinearLayout tabTodayServicell, tabRelatedOrderll;
    private LocalActivityManager manager;
    private RelatedOrderPagerAdapter relatedOrderPagerAdapter;
    private int currentItem;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_order_list_tab);
        manager = new LocalActivityManager(this, true);
        manager.dispatchCreate(savedInstanceState);
        initTabView();
    }

    //初始化选项卡数据
    protected void initTabView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        currentItem = getIntent().getIntExtra("currentItem", 0);
        relatedOrderViewPager = (ViewPager) findViewById(R.id.order_list_tab_view_pager);
        Intent todayServiceIntent = new Intent(this, TodayServiceListActivity.class);
        tabViewList.add(getView("TodayServiceListActivity", todayServiceIntent));
        Intent relatedOrderIntent = new Intent(this, OrderListActivity.class);
        relatedOrderIntent.putExtra("USER_ROLE", Constant.USER_ROLE_BUSINESS);
        tabViewList.add(getView("OrderListActivity", relatedOrderIntent));
        tabTodayServiceTitle = (TextView) findViewById(R.id.today_service_tab_title);
        tabTodayServicell = (LinearLayout) findViewById(R.id.today_service_tab_ll);
        tabRelatedOrderTitle = (TextView) findViewById(R.id.related_order_tab_title);
        tabRelatedOrderll = (LinearLayout) findViewById(R.id.related_order_tab_ll);
        relatedOrderPagerAdapter = new RelatedOrderPagerAdapter(tabViewList);
        relatedOrderViewPager.setAdapter(relatedOrderPagerAdapter);
        relatedOrderViewPager.setCurrentItem(currentItem);
        tabTodayServicell.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                relatedOrderViewPager.setCurrentItem(0, false);
            }
        });
        tabRelatedOrderll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                relatedOrderViewPager.setCurrentItem(1, false);
            }
        });
        relatedOrderViewPager.setOnPageChangeListener(new OnPageChangeListener() {
            @Override
            public void onPageSelected(int state) {
            }

            @Override
            public void onPageScrolled(int position, float offset, int offsetPiexls) {
                resetAllItem();
                switch (position) {
                    case 0:
                        tabTodayServiceTitle.setTextColor(getResources().getColor(R.color.blue));
                        break;
                    case 1:
                        tabRelatedOrderTitle.setTextColor(getResources().getColor(R.color.blue));
                        break;
                }
            }

            @Override
            public void onPageScrollStateChanged(int position) {
            }
        });
    }

    private View getView(String id, Intent intent) {
        return manager.startActivity(id, intent).getDecorView();
    }

    protected void resetAllItem() {
        tabTodayServiceTitle.setTextColor(getResources().getColor(R.color.white));
        tabRelatedOrderTitle.setTextColor(getResources().getColor(R.color.white));
    }

    //处理点击订单高级筛选，将onActivityResult捕获  传递给子Activity处理
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        super.onActivityResult(requestCode, resultCode, data);
        //订单高级筛选
        if (requestCode == 1) {
            OrderListActivity orderListActivity = (OrderListActivity) manager.getActivity("OrderListActivity");
            orderListActivity.onActivityResult(requestCode, resultCode, data);
        }
        //服务高级筛选
        else if (requestCode == 2) {
            TodayServiceListActivity todayServiceListActivity = (TodayServiceListActivity) manager.getActivity("TodayServiceListActivity");
            todayServiceListActivity.onActivityResult(requestCode, resultCode, data);
        }

    }
}
