package com.GlamourPromise.Beauty.Business;

import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;

public class BranchStatisticsMainActivity extends BaseActivity implements OnClickListener {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_statistics_main);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        findViewById(R.id.branch_business_conditions_analysis_relativelayout).setOnClickListener(this);
        findViewById(R.id.branch_employee_business_analysis_relativelayout).setOnClickListener(this);
        findViewById(R.id.branch_product_analysis_relativelayout).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        Intent destIntent = null;
        switch (view.getId()) {
            //营业状况统计
            case R.id.branch_business_conditions_analysis_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchBusinessConditionsBarChartActivity.class);
                break;
            //员工业务数据统计分析
            case R.id.branch_employee_business_analysis_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchEmployeeBusinessMainActivity.class);
                break;
            //产品数据统计分析
            case R.id.branch_product_analysis_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchProductStatisticsMainActivity.class);
                break;
        }
        if (destIntent != null)
            startActivity(destIntent);
    }
}
