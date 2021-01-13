package cn.com.antika.business;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.TextView;

public class CustomerStatisticsMainActivity extends BaseActivity implements OnClickListener {
    private UserInfoApplication userinfoApplication;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_statistics_main);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        ((TextView) findViewById(R.id.customer_statistics_main_title_text)).setText("消费倾向分析" + "(" + userinfoApplication.getSelectedCustomerName() + ")");

        findViewById(R.id.consumption_accounting_analysis_relativelayout).setOnClickListener(this);
        findViewById(R.id.consumer_product_ranking_relativelayout).setOnClickListener(this);
        findViewById(R.id.consumption_price_analysis_relativelayout).setOnClickListener(this);
        findViewById(R.id.to_store_cycle_and_consumption_relativelayout).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        Intent destIntent = null;
        switch (view.getId()) {
            //消费占比分析图表
            case R.id.consumption_accounting_analysis_relativelayout:
                destIntent = new Intent();
                destIntent.putExtra("Type", 1);
                destIntent.setClass(this, CustomerStatisticsPieActivity.class);
                break;
            //消费产品排行榜
            case R.id.consumer_product_ranking_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, CustomerStatisticsListActivity.class);
                break;
            //消费价格分析图表
            case R.id.consumption_price_analysis_relativelayout:
                destIntent = new Intent();
                destIntent.putExtra("Type", 2);
                destIntent.setClass(this, CustomerStatisticsPieActivity.class);
                break;
            //到店周期及分析图表
            case R.id.to_store_cycle_and_consumption_relativelayout:
                destIntent = new Intent();
                destIntent.setClass(this, CustomerStatisticsBarChartActivity.class);
                break;
        }
        if (destIntent != null)
            startActivity(destIntent);
    }
}
