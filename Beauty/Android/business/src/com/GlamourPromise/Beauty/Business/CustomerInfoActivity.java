package com.GlamourPromise.Beauty.Business;

import android.app.TabActivity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TabHost.OnTabChangeListener;
import android.widget.TabWidget;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
/*
 * 我的顾客---选项卡
 * */
public class CustomerInfoActivity extends TabActivity{
	private TabHost tabHost;
	private Intent basicInfoIntent,detailInfoIntent,vocationInfoIntent,notePadInfoIntent;
	private TabWidget tabWidget;
	private UserInfoApplication userinfoApplication;
	private int tabWidgetHeight=0;
	private int tabWidgetWidth=0;
	private int currentTab;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_info);
		userinfoApplication=UserInfoApplication.getInstance();
		currentTab=getIntent().getIntExtra("current_tab",0);
		int screenWidth=userinfoApplication.getScreenWidth();
		if(screenWidth==720){
			tabWidgetHeight=90;
			tabWidgetWidth=screenWidth/10;
		}
		else if(screenWidth==480){
			tabWidgetHeight=62;
			tabWidgetWidth=screenWidth/10;
		}
		else if(screenWidth==540){
			tabWidgetHeight=83;
			tabWidgetWidth=screenWidth/10;
		}
		else if(screenWidth==1080){
			tabWidgetHeight=165;
			tabWidgetWidth=screenWidth/10;
		}
		else if(screenWidth==1536){
			tabWidgetHeight=220;
			tabWidgetWidth=screenWidth/10;
		}
		else{
			tabWidgetHeight=165;
			tabWidgetWidth=screenWidth/10;
		}
		tabHost = getTabHost();
		basicInfoIntent = new Intent(this,CustomerBasicInfoActivity.class);
		tabHost.addTab(tabHost.newTabSpec("basic").setIndicator(null, null).setContent(basicInfoIntent));
		detailInfoIntent = new Intent(this, CustomerDetailActivity.class);
		tabHost.addTab(tabHost.newTabSpec("detail").setIndicator(null, null).setContent(detailInfoIntent));
		notePadInfoIntent = new Intent(this,NotepadListActivity.class);
		notePadInfoIntent.putExtra("isByCustomerID", true);
		tabHost.addTab(tabHost.newTabSpec("notepad").setIndicator(null, null).setContent(notePadInfoIntent));
		vocationInfoIntent = new Intent(this,CustomerRecordTemplateActivity.class);
		vocationInfoIntent.putExtra("USER_ROLE",Constant.USER_ROLE_CUSTOMER);
		tabHost.addTab(tabHost.newTabSpec("record").setIndicator(null, null).setContent(vocationInfoIntent));
		tabWidget = tabHost.getTabWidget();
		tabHost.setCurrentTab(currentTab);
		undateTabBackground();
		tabHost.setOnTabChangedListener(new OnTabChangeListener() {
			@Override
			public void onTabChanged(String tabId) {
				undateTabBackground();
			}
		});
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
	}
	private void undateTabBackground(){
		for (int i = 0; i < 4; i++) {
			View v = tabWidget.getChildAt(i);
			ImageView iv=(ImageView)v.findViewById(android.R.id.icon);
			RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)iv.getLayoutParams();
			params.addRule(RelativeLayout.CENTER_IN_PARENT,RelativeLayout.TRUE); //设置背景图居中
			iv.getLayoutParams().height = tabWidgetHeight;
			iv.getLayoutParams().width = tabWidgetWidth;
			v.setBackgroundColor(Color.parseColor("#3EBEFF"));
			if (i == 0) {
				if (tabHost.getCurrentTab() == i) {
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_basic_info_selected));
				} else
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_basic_info_unselectd));
			} else if (i == 1) {
				if (tabHost.getCurrentTab() == i) {
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_detail_selected));
				} else
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_detail__unselected));
			}
			else if (i == 2) {
				if (tabHost.getCurrentTab() == i) {
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_notepad_selected));
				} else
				    iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_notepad_unselected));
			}
			else if (i == 3) {
				if (tabHost.getCurrentTab() == i) {
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_record_template_selected));
				} else
					iv.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_customer_record_template_unselected));
			}
		}
	}
}
