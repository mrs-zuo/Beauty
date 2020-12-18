package com.glamourpromise.beauty.customer.activity;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.util.IntentUtil;
import android.app.LocalActivityManager;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TextView;
import android.widget.TabHost.OnTabChangeListener;
public class ServiceOrderTreatmentServiceDetailTabActivity extends TabActivity implements OnClickListener{
	private TabHost tabHost;
	private Intent treatmentGroupDetailIntent,treatmentGroupEffectIntent,treatmentReviewIntent;
	private TabWidget tabWidget;
	private int tabWidgetHeight=0;
	private int currentTab;
	private LayoutInflater layoutInfalter;
	public final static int TREATEMENT_TG=0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_order_list_tab);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		WindowManager wm = (WindowManager)getSystemService(Context.WINDOW_SERVICE);
	    int screenWidth = wm.getDefaultDisplay().getWidth();
		currentTab=getIntent().getIntExtra("current_tab",0);
		if(screenWidth==720)
			tabWidgetHeight=110;
		else if(screenWidth==480)
			tabWidgetHeight=73;
		else if(screenWidth==540)
			tabWidgetHeight=83;
		else if(screenWidth==1080)
			tabWidgetHeight=165;
		else if(screenWidth==1536)
			tabWidgetHeight=220;
		tabHost = getTabHost();
		layoutInfalter=LayoutInflater.from(this);
		View tabServiceDetailView=layoutInfalter.inflate(R.xml.tab_service_detail,null);
		View tabServiceEffectView=layoutInfalter.inflate(R.xml.tab_service_effect,null);
		View tabServiceReviewView=layoutInfalter.inflate(R.xml.tab_service_treatment_review,null);
		
		Intent  intent=getIntent();
		treatmentGroupDetailIntent = new Intent(this,ServiceOrderTreatmentServiceDetailActivity.class);
		treatmentGroupDetailIntent.putExtra("GroupNo",intent.getStringExtra("GroupNo"));
		treatmentGroupDetailIntent.putExtra("OrderID",intent.getIntExtra("OrderID", 0));
		treatmentGroupDetailIntent.putExtra("BranchName",intent.getStringExtra("BranchName"));
		tabHost.addTab(tabHost.newTabSpec("treatmentServiceDetail").setIndicator(tabServiceDetailView).setContent(treatmentGroupDetailIntent));
		
		treatmentGroupEffectIntent=new Intent(this,ServiceOrderTreatmentGroupServiceEffectActivity.class);
		treatmentGroupEffectIntent.putExtra("GroupNo",intent.getStringExtra("GroupNo"));
		tabHost.addTab(tabHost.newTabSpec("treatmentGroupEffect").setIndicator(tabServiceEffectView).setContent(treatmentGroupEffectIntent));
		
		treatmentReviewIntent = new Intent(this,EvaluateServiceDetailActivity.class);
		treatmentReviewIntent.putExtra("GroupNo",Long.parseLong(intent.getStringExtra("GroupNo")));
		treatmentReviewIntent.putExtra("FROM_SOURCE", 1);
		tabHost.addTab(tabHost.newTabSpec("treatmentReviewDetail").setIndicator(tabServiceReviewView).setContent(treatmentReviewIntent));
		tabWidget = tabHost.getTabWidget();
		tabWidget.setDividerDrawable(null);
		tabHost.setCurrentTab(currentTab);
		updateTabBackground();
		tabHost.setOnTabChangedListener(new OnTabChangeListener() {
			@Override
			public void onTabChanged(String tabId) {
				updateTabBackground();
			}
		});
	}
	
	@SuppressWarnings("deprecation")
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	private void updateTabBackground(){
		for(int i=0;i<3;i++){
			View v = tabWidget.getChildAt(i);
			v.getLayoutParams().height=tabWidgetHeight;
			v.setBackgroundColor(Color.parseColor("#D5C5B5"));
			if (i == 0) {
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.navigation_title_text)).setText("服务详情");
					((TextView)v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.white));
				}
			}
			else if(i==1){
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.navigation_title_text)).setText("服务效果");
					((TextView)v.findViewById(R.id.tab_service_effect_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_effect_title)).setTextColor(getResources().getColor(R.color.white));
				}
			}
			else if (i == 2) {
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.navigation_title_text)).setText("服务评价");
					((TextView)v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.white));
				}
			}
		}
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
		default:
			break;
		}
	}
}
