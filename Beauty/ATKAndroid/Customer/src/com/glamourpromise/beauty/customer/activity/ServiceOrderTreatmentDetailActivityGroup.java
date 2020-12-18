package com.glamourpromise.beauty.customer.activity;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TextView;
import android.widget.TabHost.OnTabChangeListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.bean.TreatmentInformation;
import com.glamourpromise.beauty.customer.util.IntentUtil;

@SuppressWarnings("deprecation")
public class ServiceOrderTreatmentDetailActivityGroup extends TabActivity implements OnClickListener {
	private TreatmentInformation treatmentInformation;
	private String orderID;
	int[] arraySelectBottomImage = { R.drawable.service_detail_red,R.drawable.service_effect_red };
	int[] arrayNotSelectBottomImage = { R.drawable.service_detail_white,R.drawable.service_effect_white };
	private int treatmentID;
	private int currentTab;
	private TabWidget tabWidget;
	private int tabWidgetHeight=0;
	private TabHost tabHost;
	private Intent treatmentDetailIntent,treatmentReviewIntent,treatmentTreatmentDetailIntent;
	private LayoutInflater layoutInfalter;
	private String   groupNo;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_group_service_order_treatment_detail);
		treatmentInformation = (TreatmentInformation) getIntent().getSerializableExtra("TreatmentItem");
		treatmentID = getIntent().getIntExtra("TreatmentID", 0);
		orderID = getIntent().getStringExtra("OrderID");
		groupNo=getIntent().getStringExtra("GroupNo");
		WindowManager wm = (WindowManager)getSystemService(Context.WINDOW_SERVICE);
	    int screenWidth = wm.getDefaultDisplay().getWidth();
	    findViewById(R.id.btn_main_back).setOnClickListener(this);
	    findViewById(R.id.btn_main_home).setOnClickListener(this);
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
		View tabServiceTreatmentView=layoutInfalter.inflate(R.xml.tab_service_treatment_detail,null);
		View tabServiceReviewView=layoutInfalter.inflate(R.xml.tab_service_treatment_review,null);
		treatmentDetailIntent = new Intent(ServiceOrderTreatmentDetailActivityGroup.this, TreatmentDetailActivity.class);
		treatmentDetailIntent.putExtra("TreatmentID",treatmentID);
		tabHost.addTab(tabHost.newTabSpec("treatmentServiceDetail").setIndicator(tabServiceDetailView).setContent(treatmentDetailIntent));
		treatmentTreatmentDetailIntent = new Intent(ServiceOrderTreatmentDetailActivityGroup.this,ServiceOrderTreatmentServiceEffectActivity.class);
		treatmentTreatmentDetailIntent.putExtra("TreatmentID",treatmentID);
		tabHost.addTab(tabHost.newTabSpec("treatmentTreatmentDetail").setIndicator(tabServiceTreatmentView).setContent(treatmentTreatmentDetailIntent));
		
		treatmentReviewIntent = new Intent(ServiceOrderTreatmentDetailActivityGroup.this,ServiceOrderTreatmentServiceReviewActivity.class);
		treatmentReviewIntent.putExtra("TreatmentID", treatmentID);
		treatmentReviewIntent.putExtra("OrderID", orderID);
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
	
	private void updateTabBackground(){
		for(int i=0;i<3;i++){
			View v = tabWidget.getChildAt(i);
			v.getLayoutParams().height=tabWidgetHeight;
			v.setBackgroundColor(Color.parseColor("#D5C5B5"));
			if (i == 0) {
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.treatment_detail_title)).setText("操作详情");
					((TextView)v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.white));
				}
				
			} 
			else if (i == 1) {
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.treatment_detail_title)).setText("操作效果");
					((TextView)v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.white));
				}
				
			}
			else if (i == 2) {
				if (tabHost.getCurrentTab() == i) {
					((TextView)findViewById(R.id.treatment_detail_title)).setText("操作评价");
					((TextView)v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.text_color));
				} else{
					((TextView)v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.white));
				}
				
			}
		}
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public void onClick(View view) {
		switch (view.getId()) {
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
