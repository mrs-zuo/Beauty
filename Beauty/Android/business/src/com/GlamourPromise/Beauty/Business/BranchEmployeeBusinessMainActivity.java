package com.GlamourPromise.Beauty.Business;

import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;

public class BranchEmployeeBusinessMainActivity extends BaseActivity implements OnClickListener {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_employee_business_main);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        findViewById(R.id.branch_employess_business_pie_relativelayout).setOnClickListener(this);
        findViewById(R.id.branch_employee_business_detail_list_relativelayout).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        Intent destIntent = null;
        switch (view.getId()) {
            //员工业绩占比图标
            case R.id.branch_employess_business_pie_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchEmployeeBusinessStatisticsPieActivity.class);
                break;
            //员工业绩排行榜
            case R.id.branch_employee_business_detail_list_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchEmployeeBusinessListActivity.class);
                break;
        }
        if (destIntent != null)
            startActivity(destIntent);
    }
}
