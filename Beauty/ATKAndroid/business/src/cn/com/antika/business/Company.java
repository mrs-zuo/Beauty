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
import android.widget.RelativeLayout;

public class Company extends BaseActivity implements OnClickListener {
	private UserInfoApplication userInfoApplication;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_company);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userInfoApplication = (UserInfoApplication) getApplication();
		((RelativeLayout) findViewById(R.id.layout_one)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_two)).setOnClickListener(this);
		if (userInfoApplication.getAccountInfo().getBranchId() == 0) {
			((RelativeLayout) findViewById(R.id.layout_three)).setVisibility(View.GONE);
		} else {
			((RelativeLayout) findViewById(R.id.layout_three)).setOnClickListener(this);
		}
		((RelativeLayout) findViewById(R.id.layout_four)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_five)).setOnClickListener(this);
	}

	@Override
	public void onClick(View arg0) {
		// TODO Auto-generated method stub
		Intent intent = null;
		switch (arg0.getId()) {
		case R.id.layout_one:
			intent = new Intent(this, BranchDetailActivity.class);
			intent.putExtra("BranchID", "");
			intent.putExtra("Flag",AccountListActivity.COMPANY_ACCOUNT_LIST_FLAG);
			break;
		case R.id.layout_two:
			intent = new Intent(this, BranchListActivity.class);
			break;
		case R.id.layout_three:
			intent = new Intent(this, BranchDetailActivity.class);
			intent.putExtra("BranchID", String.valueOf(userInfoApplication.getAccountInfo().getBranchId()));
			intent.putExtra("Flag",AccountListActivity.BRANCH_ACCOUNT_LIST_FLAG);
			break;
		case R.id.layout_four:
			intent = new Intent(this, AccountDetailActivity.class);
			intent.putExtra("AccountID", String.valueOf(userInfoApplication.getAccountInfo().getAccountId()));
			break;
		case R.id.layout_five:
			intent = new Intent(this, NoticeListActivity.class);
			break;
		default:
			break;
		}
		startActivity(intent);
	}
}
