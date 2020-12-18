package cn.com.antika.business;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;

public class MyReportMainActivity extends BaseActivity implements OnClickListener {
	private UserInfoApplication userinfoApplication;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_my_report_main);
		initView();
	}
	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		//我的报表业绩
		findViewById(R.id.my_report_achievement_relativelayout).setOnClickListener(this);
		//我的报表提成
		findViewById(R.id.my_report_percentage_relativelayout).setOnClickListener(this);
		userinfoApplication=UserInfoApplication.getInstance();
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		Intent destIntent=null;
		if(view.getId()==R.id.my_report_achievement_relativelayout){
			destIntent = new Intent(this, ReportByDateActivity.class);
			destIntent.putExtra("REPORT_TYPE", Constant.MY_REPORT);
			
		}
		else if(view.getId()==R.id.my_report_percentage_relativelayout){
			destIntent = new Intent(this,MyReportPercentageActivity.class);
		}
		if(destIntent!=null)
			startActivity(destIntent);
	}
}
