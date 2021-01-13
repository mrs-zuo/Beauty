package cn.com.antika.business;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.os.Bundle;
import android.app.TabActivity;
import android.content.Intent;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TextView;
import android.widget.TabHost.OnTabChangeListener;

public class TreatmentGroupDetailTabActivity extends TabActivity {
    private TabHost tabHost;
    private Intent treatmentGroupDetailIntent, treatmentGroupTreatmentDetailIntent, treatmentReviewIntent;
    private TabWidget tabWidget;
    private UserInfoApplication userinfoApplication;
    private int tabWidgetHeight = 0;
    private int currentTab;
    private LayoutInflater layoutInfalter;
    private int orderID;
    public final static int TREATEMENT_TG = 0;

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
        int orderEditFlag = intent.getIntExtra("orderEditFlag", 0);
        String treatmentGroupNo = intent.getStringExtra("GroupNo");
        orderID = intent.getIntExtra("OrderID", 0);
        int customerID = intent.getIntExtra("CustomerID", 0);
        treatmentGroupDetailIntent = new Intent(this, TreatmentGroupDetailActivity.class);
        treatmentGroupDetailIntent.putExtra("orderEditFlag", orderEditFlag);
        treatmentGroupDetailIntent.putExtra("GroupNo", treatmentGroupNo);
        treatmentGroupDetailIntent.putExtra("OrderID", orderID);
        tabHost.addTab(tabHost.newTabSpec("treatmentServiceDetail").setIndicator(tabServiceDetailView).setContent(treatmentGroupDetailIntent));
        treatmentGroupTreatmentDetailIntent = new Intent(this, TreatmentGroupTreatmentDetailActivity.class);
        treatmentGroupTreatmentDetailIntent.putExtra("CustomerID", customerID);
        treatmentGroupTreatmentDetailIntent.putExtra("GroupNo", treatmentGroupNo);
        treatmentGroupTreatmentDetailIntent.putExtra("orderEditFlag", orderEditFlag);
        tabHost.addTab(tabHost.newTabSpec("treatmentGroupTreatmentDetail").setIndicator(tabServiceTreatmentView).setContent(treatmentGroupTreatmentDetailIntent));
        treatmentReviewIntent = new Intent(this, TreatmentGroupReviewActivity.class);
        treatmentReviewIntent.putExtra("GroupNo", treatmentGroupNo);
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
                    ((TextView) v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.title_font));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_detail_title)).setTextColor(getResources().getColor(R.color.white));
                }
            } else if (i == 1) {
                if (tabHost.getCurrentTab() == i) {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.title_font));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_title)).setTextColor(getResources().getColor(R.color.white));
                }
            } else if (i == 2) {
                if (tabHost.getCurrentTab() == i) {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.title_font));
                } else {
                    ((TextView) v.findViewById(R.id.tab_service_treatment_review_title)).setTextColor(getResources().getColor(R.color.white));
                }
            }

        }
    }
}
