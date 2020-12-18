package com.glamourpromise.beauty.customer.activity;

import java.util.List;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.ListView;
import cn.jpush.android.api.JPushInterface;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CompanySelectAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.LoginInformation;
import com.glamourpromise.beauty.customer.net.WebApiConnectHelper;
import com.glamourpromise.beauty.customer.task.UpdateLoginTask;
import com.glamourpromise.beauty.customer.task.UpdateLoginTask.IUpdateLoginCallback;
import com.glamourpromise.beauty.customer.util.RSAUtil;
import com.glamourpromise.beauty.customer.util.RandomUUID;

public class CompanySelectActivity extends Activity implements
		OnItemClickListener {
	private List<LoginInformation> companyList;
	private CompanySelectAdapter companySelectAdapter;
	private ListView companySelectListView;
	private ImageButton backButton;
	private UserInfoApplication userInfo;
	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_company_select);
		companyList=((UserInfoApplication)getApplication()).getCompanyList(this);
		companySelectListView = (ListView) findViewById(R.id.company_list);
		backButton = (ImageButton) findViewById(R.id.btn_main_back_menu);
		userInfo = (UserInfoApplication)getApplication();
		companySelectAdapter = new CompanySelectAdapter(this, companyList);
		companySelectListView.setAdapter(companySelectAdapter);
		companySelectListView.setOnItemClickListener(this);
		
		backButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View arg0) {
				exit();
			}
		});

	}

	@Override
	protected void onPause() {
		super.onPause();
		JPushInterface.onPause(this);
	}

	@Override
	protected void onResume() { // 当用户使程序恢复为前台显示时执行onResume()方法,在其中判断是否超时.
		// TODO Auto-generated method stub
		super.onResume();
		JPushInterface.onResume(this);
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		// TODO Auto-generated method stub
		userInfo.setIsNeedUpdateLogin(true);
		userInfo.setIsExit(false);
		//设置登录信息
		userInfo.setLoginInformation(companyList.get(position), position);
		// 注册推送服务
		if (JPushInterface.isPushStopped(getApplicationContext()))
			JPushInterface.resumePush(getApplicationContext());
		String uuid = RandomUUID.getRandomUUID(CompanySelectActivity.this, userInfo.getLoginInformation().getCustomerID());
		JPushInterface.init(getApplicationContext());
		JPushInterface.setAlias(getApplicationContext(), uuid, null);
		
		Intent destIntent = new Intent(this,NavigationNew.class);
		destIntent.putExtra("flag", "6");// HomePageActivity根据该标志判断是否需要更新登陆信息；1：需要更新// // 0：不需要更新
		destIntent.putExtra("intentSourceActivityName", "companySelectActivity");
		startActivity(destIntent);
		this.finish();
	}

	private void updateLoginInfo() {
		SharedPreferences sharedata = userInfo.getSharedPreferences();
		String password = RSAUtil.encrypt(sharedata.getString("lastLoginPassword", ""));
		String userName = RSAUtil.encrypt(sharedata.getString("lastLoginAccount", ""));
		String uuid = sharedata.getString("pushUUID", "");
		LoginInformation loginInfo = userInfo.getLoginInformation();
		UpdateLoginTask updateTask = new UpdateLoginTask(userInfo, password, userName, loginInfo.getCustomerID(), loginInfo.getCompanyID(), uuid, new IUpdateLoginCallback() {
			
			@Override
			public void onUpdateSuccess(String guid) {
				handleReslut(guid);
			}
			
			@Override
			public void onError() {
				exit();
			}
		});
		WebApiConnectHelper connect = userInfo.getConnect();
		connect.queueTask(updateTask);
	}
	
	private void handleReslut(String guid) {
		userInfo.setGUID(guid);
	}
	
	private void exit() {
		Intent destIntent = new Intent(CompanySelectActivity.this,LoginActivity.class);
		startActivity(destIntent);
		SharedPreferences sharedPreferences = getSharedPreferences("customerInformation", Context.MODE_PRIVATE);
		Editor editor = sharedPreferences.edit();// 获取编辑器
		editor.putInt("formalFlag", 0);
		editor.putInt("loginInfoPosition", 0);
		editor.putString("lastLoginPassword","");
		editor.putBoolean("autoLogin",false);
		editor.commit();// 提交修改
		userInfo.setFormalFlag(0);
		CompanySelectActivity.this.finish();
	}
}
