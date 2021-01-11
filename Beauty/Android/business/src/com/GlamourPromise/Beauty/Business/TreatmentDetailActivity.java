package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.TabActivity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.TabHost;
import android.widget.TabHost.OnTabChangeListener;
import android.widget.TabWidget;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.bean.TreatmentGroup;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

@SuppressLint("ResourceType")
public class TreatmentDetailActivity extends TabActivity {
    private TabHost tabHost;
    private Intent treatmentServiceDetailIntent,
            treatmentTreatmentDetailIntent, treatmentReviewIntent;
    private TabWidget tabWidget;
    private UserInfoApplication userinfoApplication;
    private int tabWidgetHeight = 0;
    private int currentTab;
    private LayoutInflater layoutInfalter;
    public final static int TREATEMENT_TM = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_treatment_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        int screenWidth = userinfoApplication.getScreenWidth();
        int screenHeight = userinfoApplication.getScreenHeight();
        currentTab = getIntent().getIntExtra("current_tab", 0);
        if (screenWidth == 720)
            tabWidgetHeight = 110;
        else if (screenWidth == 480)
            tabWidgetHeight = 73;
        else if (screenWidth == 540)
            tabWidgetHeight = 83;
        else if (screenWidth == 1080)
            tabWidgetHeight = 165;
        else if (screenWidth == 1536)
            tabWidgetHeight = 220;
        else
            tabWidgetHeight = 220;
        tabHost = getTabHost();
        layoutInfalter = LayoutInflater.from(this);
        View tabServiceDetailView = layoutInfalter.inflate(R.xml.tab_service_detail, null);
        View tabServiceTreatmentView = layoutInfalter.inflate(R.xml.tab_service_treatment_detail, null);
        View tabServiceReviewView = layoutInfalter.inflate(R.xml.tab_service_treatment_review, null);
        Intent intent = getIntent();
        Treatment treatment = (Treatment) intent.getSerializableExtra("treatment");
        TreatmentGroup treatmentGroup = (TreatmentGroup) intent.getSerializableExtra("treatmentGroup");
        int customerID = intent.getIntExtra("CustomerID", 0);
        int orderEditFlag = intent.getIntExtra("orderEditFlag", 0);
        boolean isLastTreatment = intent.getBooleanExtra("isLastTreatment", false);
        Bundle bundle = new Bundle();
        bundle.putSerializable("treatment", treatment);
        bundle.putSerializable("treatmentGroup", treatmentGroup);
        treatmentServiceDetailIntent = new Intent(this, TreatmentServiceDetailActivity.class);
        treatmentServiceDetailIntent.putExtras(bundle);
        treatmentServiceDetailIntent.putExtra("isLastTreatment", isLastTreatment);
        treatmentServiceDetailIntent.putExtra("CustomerID", customerID);
        treatmentServiceDetailIntent.putExtra("orderEditFlag", orderEditFlag);
        tabHost.addTab(tabHost.newTabSpec("treatmentServiceDetail").setIndicator(tabServiceDetailView).setContent(treatmentServiceDetailIntent));
        treatmentTreatmentDetailIntent = new Intent(this, TreatmentTreatmentDetailActivity.class);
        treatmentTreatmentDetailIntent.putExtras(bundle);
        treatmentTreatmentDetailIntent.putExtra("orderEditFlag", orderEditFlag);
        treatmentTreatmentDetailIntent.putExtra("CustomerID", customerID);
        tabHost.addTab(tabHost.newTabSpec("treatmentTreatmentDetail").setIndicator(tabServiceTreatmentView).setContent(treatmentTreatmentDetailIntent));
        treatmentReviewIntent = new Intent(this, TreatmentReviewActivity.class);
        treatmentReviewIntent.putExtras(bundle);
        treatmentReviewIntent.putExtra("FROM_SOURCE", TREATEMENT_TM);
        tabHost.addTab(tabHost.newTabSpec("treatmentReviewDetail").setIndicator(tabServiceReviewView).setContent(treatmentReviewIntent));
        tabWidget = tabHost.getTabWidget();
        tabHost.setCurrentTab(currentTab);
        updateTabBackground();
        tabHost.setOnTabChangedListener(new OnTabChangeListener() {
            @Override
            public void onTabChanged(String tabId) {
                updateTabBackground();
            }
        });
    }

    private void updateTabBackground() {
        for (int i = 0; i < 3; i++) {
            View v = tabWidget.getChildAt(i);
            v.getLayoutParams().height = tabWidgetHeight;
            v.setBackgroundColor(Color.parseColor("#3EBEFF"));
            if (i == 0) {
                if (tabHost.getCurrentTab() == i) {
                    ((TextView) v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.white));
                }
            } else if (i == 1) {
                if (tabHost.getCurrentTab() == i) {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.white));
                }
            } else if (i == 2) {
                if (tabHost.getCurrentTab() == i) {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.white));
                }
            }
        }
    }
}
