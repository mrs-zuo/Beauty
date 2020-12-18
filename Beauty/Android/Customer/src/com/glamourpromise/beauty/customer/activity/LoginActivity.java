package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import cn.jpush.android.api.JPushInterface;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.LoginInformation;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask.DownFileTaskProgressCallback;
import com.glamourpromise.beauty.customer.managerService.DownLoadFileManager;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiConnectHelper;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.RSAUtil;
import com.glamourpromise.beauty.customer.util.RandomUUID;

public class LoginActivity extends Activity implements OnClickListener,
		IConnectTask {
	private EditText userNameText;
	private EditText passwordText;
	private Button loginBtn;
	private ProgressDialog progressDialog;
	private List<LoginInformation> loginInformationList;
	private SharedPreferences sharedPreferences;

	private int loginTimes = 0;
	private static UserInfoApplication userInfo;
	int flag=0;
	DownFileTaskProgressCallback progressCallback;

	@SuppressWarnings("deprecation")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_login);

		userNameText = (EditText) findViewById(R.id.login_username);
		passwordText = (EditText) findViewById(R.id.login_password);
		loginBtn = (Button) findViewById(R.id.login_btn);
		loginBtn.setOnClickListener(this);

		findViewById(R.id.forget_password).setOnClickListener(this);

		// 储存屏幕尺寸
		userInfo = (UserInfoApplication) getApplication();
		userInfo.setScreedHeight(getWindowManager().getDefaultDisplay()
				.getHeight());
		userInfo.setScreenWidth(getWindowManager().getDefaultDisplay()
				.getWidth());
		userInfo.setFormalFlag(0);// 表示正式用户
		sharedPreferences = userInfo.getSharedPreferences();
		userNameText.setText(sharedPreferences.getString("lastLoginAccount", ""));
	}

	@Override
	protected void onPause() {
		super.onPause();
		JPushInterface.onPause(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
		JPushInterface.onResume(this);
	}

	private void promptNewVersion() {
		Dialog dialog = new AlertDialog.Builder(this)
				.setTitle(getString(R.string.must_update_software_title))
				.setPositiveButton(getString(R.string.update_new_version),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								promptUpdateNewVersion();
							}
						})
				.setNegativeButton(getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								userInfo.AppExit(LoginActivity.this);
								finish();
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}

	private void promptUpdateNewVersion() {
		final ProgressDialog updateDialog = DialogUtil
				.createUpdateApkDialog(this);
		updateDialog.show();
		progressCallback = new DownFileTaskProgressCallback() {

			@Override
			public void onProgressUpdate(int progress) {
				// TODO Auto-generated method stub
				updateDialog.setProgress(progress);
			}

			@Override
			public void onPostExecute() {
				// TODO Auto-generated method stub
				updateDialog.cancel();
				AlertDialog installApkdialog = DialogUtil.showInstallDialog(
						LoginActivity.this,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								userInfo.installApk(LoginActivity.this);
							}
						});
				installApkdialog.show();
			}

			@Override
			public void onExecuteError() {
				// TODO Auto-generated method stub
				updateDialog.cancel();
				DialogUtil.createShortDialog(LoginActivity.this, "更新失败！");
				userInfo.AppExit(LoginActivity.this);
			}
		};
		flag=1;
		WebApiConnectHelper connect = userInfo.getConnect();
		connect.queueTask(this);
	}

	String userNameStr = "";
	String passwordStr = "";

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		userNameStr = userNameText.getText().toString();
		passwordStr = passwordText.getText().toString();
		switch (view.getId()) {
		case R.id.forget_password:
			Intent destIntent = new Intent(this,FindPasswordCheckAuthenticationCodeActivity.class);
			startActivity(destIntent);
			finish();
			break;
		case R.id.login_btn:
			if (null == userNameStr || ("").equals(userNameStr))
				DialogUtil.createMakeSureDialog(this, "登陆提示", "请输入登录账号");
			else if (null == passwordStr || ("").equals(passwordStr))
				DialogUtil.createMakeSureDialog(this, "登陆提示", "请输入密码");
			else
				login();
			break;
		default:
			break;
		}

	}

	private void login() {
		loginTimes++;
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("正在登陆...");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		progressDialog.setCancelable(false);
        flag=0;
		WebApiConnectHelper connect = userInfo.getConnect();
		connect.queueTask(this);
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		String categoryName = "Login";
		String methodName = "getCompanyList";
		WebApiHttpHead header = userInfo.createNotNeededCheckingWebConnectHead("getCompanyList");
		if(flag==1){
			categoryName="WebUtility";
			methodName="GetAndroidURL";
			header =userInfo.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		}else{
			String password = RSAUtil.encrypt(passwordStr);
			String userName = RSAUtil.encrypt(userNameStr);
			
			try {
				para.put("LoginMobile", userName);
				para.put("Password", password);
				para.put("ImageWidth", "80");
				para.put("ImageHeight", "80");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		WebApiRequest request = new WebApiRequest(categoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}

		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				handleLoginFalse(response.getCode());
				break;
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(flag==1){
					DownLoadFileManager.executeDownLoadTask(
							DownLoadFileManager.TYPE_DOWNLOAD_APK_FILE,
							userInfo.getfileCache(), progressCallback,response.getStringData());
				}else{
					String reslut = response.getStringData();
					handleLoginTrue(reslut);
				}
				break;
			case WebApiResponse.NEED_UPDATE:
				// 本地版本小于服务器版本且必须升级
				promptNewVersion();
				break;
			default:
				break;
			}
		} else {
			handleLoginFalse(response.getHttpCode());
		}

	}

	private void handleLoginTrue(String strCompanyList) {
		userInfo.setNormalLogin(true);
		loginInformationList = new ArrayList<LoginInformation>();
		try {
			JSONArray jarrCompanyList = new JSONArray(strCompanyList);
			int count = jarrCompanyList.length();
			JSONObject item;
			LoginInformation logInfo;
			for (int i = 0; i < count; i++) {
				item = jarrCompanyList.getJSONObject(i);
				logInfo = new LoginInformation();
				if (logInfo.ParseJson(item)) {
					loginInformationList.add(logInfo);
				}
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		userInfo.setLoginExtraInformation(userNameText.getText().toString(),passwordText.getText().toString(), userInfo.isFormalFlag());
		userInfo.setCompanyList(strCompanyList);
		userInfo.setIsNeedUpdateLogin(true);
		userInfo.setIsExit(false);
		// 密码正确后，根据情况可以跳转到3个页面
		// 只有一家公司，根据促销信息的情况选择跳转到HomePage或PromotionPage
		// 如果有多家公司，则跳转到选中页面
		if (JPushInterface.isPushStopped(getApplicationContext()))
			JPushInterface.resumePush(getApplicationContext());
		Intent destIntent = null;
		if (loginInformationList.size() == 1) {
			// 注册推送服务
			String uuid = RandomUUID.getRandomUUID(LoginActivity.this,loginInformationList.get(0).getCustomerID());
			JPushInterface.init(getApplicationContext());
			JPushInterface.setAlias(getApplicationContext(), uuid, null);
			userInfo.setLoginInformation(loginInformationList.get(0), 0);
			destIntent = new Intent(LoginActivity.this,NavigationNew.class);
			destIntent.putExtra("flag", "6");// HomePageActivity根据该标志判断是否需要更新登陆信息；1：需要更新,0：不需要更新
		} else if (loginInformationList.size() > 1) {
			destIntent = new Intent(LoginActivity.this,CompanySelectActivity.class);
			Bundle mBundle = new Bundle();
			mBundle.putSerializable("companyList",(Serializable) loginInformationList);
			destIntent.putExtras(mBundle);
		}
		startActivity(destIntent);
		LoginActivity.this.finish();
	}

	private void handleLoginFalse(int code) {
		if (loginTimes == 1) {
			userInfo.setFormalFlag(1);// 表示测试用户
			login();
		} else if (loginTimes == 2) {
			userInfo.setFormalFlag(2);
			login();
		} else {
			userInfo.setFormalFlag(0);// 表示正式用户
			loginTimes = 0;
			if (code == WebApiResponse.GET_DATA_NULL
					|| code == WebApiResponse.PARSING_ERROR) {
				DialogUtil.createShortDialog(LoginActivity.this,
						LoginActivity.this
								.getString(R.string.get_webservice_data_null));
			} else if(code == 404){
				DialogUtil.createMakeSureDialog(LoginActivity.this, "登陆提示",
						"登录账号或密码错误");
				//正式用户的账号验证错误（不适用于内网）
			}else {
				DialogUtil.createMakeSureDialog(LoginActivity.this, "登陆提示","网络错误，请检查后再试。");
			}
		}
	}

	@Override
	public void parseData(WebApiResponse response) {

	}
	
}