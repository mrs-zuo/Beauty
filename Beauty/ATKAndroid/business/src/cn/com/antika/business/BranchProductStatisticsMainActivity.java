package cn.com.antika.business;

import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;

public class BranchProductStatisticsMainActivity extends BaseActivity implements OnClickListener {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_product_statistics_main);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        findViewById(R.id.branch_product_statistics_pie_relativelayout).setOnClickListener(this);
        findViewById(R.id.branch_product_statistics_detail_list_relativelayout).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        Intent destIntent = null;
        switch (view.getId()) {
            //产品消费占比图表
            case R.id.branch_product_statistics_pie_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchProductStatisticsPieActivity.class);
                break;
            //产品消费排行榜
            case R.id.branch_product_statistics_detail_list_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, BranchProductStatisticsListActivity.class);
                break;
        }
        if (destIntent != null)
            startActivity(destIntent);
    }
}
