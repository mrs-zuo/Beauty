package cn.com.antika.business;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.Opportunity;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.os.Bundle;
import android.app.TabActivity;
import android.content.Intent;
import android.view.View;
import android.view.Window;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TabHost.OnTabChangeListener;

public class OpportunityDetailMainActivity extends TabActivity {
    private TabHost tabHost;
    private Intent opportunityDetailIntent, opportunityHistoryIntent;
    private TabWidget tabWidget;
    private UserInfoApplication userinfoApplication;
    private int tabWidgetHeight = 0;
    private int currentTab;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_opportunity_detail_main);
        int opportunityID = getIntent().getIntExtra("opportunityID", 0);
        int productType = getIntent().getIntExtra("productType", 0);
        String opportunityCustomerName = getIntent().getStringExtra("opportunityCustomerName");
        String opportunityResponsiblePersonName = getIntent().getStringExtra("opportunityResponsiblePersonName");
        //boolean opportunityIsAvailable=getIntent().getBooleanExtra("opportunityIsAvailable",true);
        Opportunity opportunity = (Opportunity) getIntent().getSerializableExtra("opportunity");
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
            tabWidgetHeight = 190;
        tabHost = getTabHost();
        opportunityDetailIntent = new Intent(this, OpportunityDetailActivity.class);
        Bundle bundle = new Bundle();
        bundle.putSerializable("opportunity", opportunity);
        opportunityDetailIntent.putExtra("opportunityID", opportunityID);
        opportunityDetailIntent.putExtra("productType", productType);
        opportunityDetailIntent.putExtra("opportunityCustomerName", opportunityCustomerName);
        opportunityDetailIntent.putExtra("opportunityResponsiblePersonName", opportunityResponsiblePersonName);
        //opportunityDetailIntent.putExtra("opportunityIsAvailable",opportunityIsAvailable);
        opportunityDetailIntent.putExtras(bundle);
        tabHost.addTab(tabHost.newTabSpec("opportunityDetailTab").setIndicator(null, null).setContent(opportunityDetailIntent));
        opportunityHistoryIntent = new Intent(this, OpportunityHistoryActivity.class);
        opportunityHistoryIntent.putExtra("productType", productType);
        opportunityHistoryIntent.putExtra("opportunityID", opportunityID);
        Bundle bundle2 = new Bundle();
        bundle2.putSerializable("opportunity", opportunity);
        opportunityHistoryIntent.putExtras(bundle2);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        tabHost.addTab(tabHost.newTabSpec("opportunityHistory").setIndicator(null, null).setContent(opportunityHistoryIntent));
        tabWidget = tabHost.getTabWidget();
        tabHost.setCurrentTab(currentTab);
        for (int i = 0; i < 2; i++) {
            View v = tabWidget.getChildAt(i);
            v.getLayoutParams().height = tabWidgetHeight;
            if (i == 0) {
                if (tabHost.getCurrentTab() == i) {
                    v.setBackgroundResource(R.drawable.opportunity_progress_current);
                } else
                    v.setBackgroundResource(R.drawable.opportunity_progress);
            } else if (i == 1) {
                if (tabHost.getCurrentTab() == i) {
                    v.setBackgroundResource(R.drawable.opportunity_history_current);
                } else
                    v.setBackgroundResource(R.drawable.opportunity_history);
            }

        }
        tabHost.setOnTabChangedListener(new OnTabChangeListener() {

            @Override
            public void onTabChanged(String tabId) {
                // TODO Auto-generated method stub
                for (int i = 0; i < 2; i++) {
                    View v = tabWidget.getChildAt(i);
                    v.getLayoutParams().height = tabWidgetHeight;
                    if (i == 0) {
                        if (tabHost.getCurrentTab() == i) {
                            v.setBackgroundResource(R.drawable.opportunity_progress_current);
                        } else
                            v.setBackgroundResource(R.drawable.opportunity_progress);

                    } else if (i == 1) {
                        if (tabHost.getCurrentTab() == i) {
                            v.setBackgroundResource(R.drawable.opportunity_history_current);
                        } else
                            v.setBackgroundResource(R.drawable.opportunity_history);
                    }
                }
            }
        });
    }
}
