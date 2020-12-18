package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.UserInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.RSAUtil;

public class FindPasswordCheckAuthenticationCodeActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Login";
	private static final String CHECK_CODE = "checkAuthenticationCode";
	private static final String GET_CODE = "getAuthenticationCode";
	
	private static final int CHECK_CODE_FLAG = 1;
	private static final int GET_CODE_FLAG = 2;
	
	private int taskFlag;
	
	private List<UserInformation> userList;
	private String loginMobile;
	private String authenticationCode;
	private ProgressDialog progressDialog;
	private TextView getAuthenticationCodePromptView;

	private Timer countDownTimer;
	private TimerTask countDownTimerTask;
	private int time = 60;
	private EditText mobileView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_find_password_check_authentication_code);
		super.setTitle(getString(R.string.title_check_authentication_code));
		super.hideBackHome();
		findViewById(R.id.cancel).setOnClickListener(this);
		findViewById(R.id.next_step).setOnClickListener(this);
		findViewById(R.id.layout_three).setOnClickListener(this);
		getAuthenticationCodePromptView = (TextView) findViewById(R.id.get_authentication_code_prompt);
		mobileView = (EditText) findViewById(R.id.input_phone_number);
		SharedPreferences sharedPreferences = getSharedPreferences("customerInformation",Context.MODE_PRIVATE);
		mobileView.setText(sharedPreferences.getString("lastLoginAccount", ""));
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.next_step:
			EditText AuthenticationCodeView = (EditText) findViewById(R.id.input_authentication_code);
			loginMobile = mobileView.getText().toString();
			authenticationCode = AuthenticationCodeView.getText().toString();
			if (loginMobile.equals("") || authenticationCode.equals("")) {
				DialogUtil.createMakeSureDialog(this, "温馨提示", "账号或验证码不能为空！");
			} else {
				checkAuthenticationCode(loginMobile, authenticationCode);
			}
			break;
		case R.id.cancel:
			this.finish();
			break;
		case R.id.layout_three:
			loginMobile = mobileView.getText().toString();
			if (loginMobile.equals("")) {
				DialogUtil.createMakeSureDialog(this, "温馨提示", "账号不能为空！");
			} else {
				getAuthenticationCode(loginMobile);
			}
			break;
		default:
			break;
		}
	}

	
	@SuppressLint("HandlerLeak")
	Handler mhandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			
			if (msg.what == 1) {
				Intent destIntent = null;
				Log.v("size", String.valueOf(userList.size()));
				if (userList.size() == 1) {
					// updateCustomerPassword();
					destIntent = new Intent(
							FindPasswordCheckAuthenticationCodeActivity.this,
							FindPasswordUpdatePasswordActivity.class);
					destIntent.putExtra("customerID", userList.get(0).getUserID());
					destIntent.putExtra("LoginMobile", loginMobile);
					destIntent.putExtra("isAbleBack", "false");// 判断是否能返回
				} else {
					destIntent = new Intent(
							FindPasswordCheckAuthenticationCodeActivity.this,
							FindPasswordCompanySelectActivity.class);
					Bundle mBundle = new Bundle();
					mBundle.putSerializable("companyList",(Serializable) userList);
					destIntent.putExtra("LoginMobile", loginMobile);
					destIntent.putExtras(mBundle);
				}
				startActivity(destIntent);
				FindPasswordCheckAuthenticationCodeActivity.this.finish();
			} else if (msg.what == 2) {
				getAuthenticationCodePromptView.setText(String.valueOf(time));
			} else if (msg.what == 3) {
				countDownTimer.cancel();
				countDownTimerTask.cancel();
				getAuthenticationCodePromptView
						.setText(getString(R.string.get_authentication_code_prompt));
			} else if (msg.what == 4) {
				if (msg.obj.equals("0")) {
					DialogUtil.createShortDialog(
							FindPasswordCheckAuthenticationCodeActivity.this,
							"验证码发送失败");
				} else if (msg.obj.equals("1")) {
					DialogUtil.createShortDialog(
							FindPasswordCheckAuthenticationCodeActivity.this,
							"验证码发送成功");
					mApp.setLoginExtraInformation(mobileView.getText().toString(), null, null);
					
					
					if (time < 0 || time >= 60) {
						countDownTimer = new Timer();
						countDownTimerTask = new TimerTask() {
							public void run() {
								Message message = new Message();
								time--;
								if (time < 0) {
									time = 60;
									message.what = 3;
									mhandler.sendMessage(message);
								} else {
									message.what = 2;
									mhandler.sendMessage(message);
								}

							}
						};
						countDownTimer.schedule(countDownTimerTask, 0, 1000);
					}
				}
			}
		}
	};
	

	private void checkAuthenticationCode(String loginMobile, String authenticationCode) {
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("正在验证...");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		progressDialog.setCancelable(false);
		
		taskFlag = CHECK_CODE_FLAG;
		super.asyncRefrshView(this);
	}

	private void getAuthenticationCode(String loginMobile) {
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("正在获取...");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		progressDialog.setCancelable(false);
		
		taskFlag = GET_CODE_FLAG;
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		String catoryName = CATEGORY_NAME;
		String methodName = "";
		String strPara = "";
		if(taskFlag == CHECK_CODE_FLAG){
			methodName = CHECK_CODE;
			try {
				para.put("LoginMobile", RSAUtil.encrypt(loginMobile));
				para.put("AuthenticationCode", RSAUtil.encrypt(authenticationCode));
				strPara = para.toString();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag == GET_CODE_FLAG){
			methodName = GET_CODE;
			try {
				para.put("LoginMobile", RSAUtil.encrypt(loginMobile));
				strPara = para.toString();
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, strPara);
		WebApiRequest request = new WebApiRequest(catoryName, methodName, strPara, header);
		
		
		
		
		
		
		
		
		
		return request;	
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == CHECK_CODE_FLAG){
//					userList = UserInformation.parseListByJson(response.getStringData());
					userList = (List<UserInformation>) response.mData;
					Intent destIntent = null;
					if (userList.size() == 1) {
						// updateCustomerPassword();
						destIntent = new Intent(
								FindPasswordCheckAuthenticationCodeActivity.this,
								FindPasswordUpdatePasswordActivity.class);
						destIntent.putExtra("customerID", userList.get(0).getUserID());
						destIntent.putExtra("LoginMobile", loginMobile);
						destIntent.putExtra("isAbleBack", "false");// 判断是否能返回
					} else {
						destIntent = new Intent(
								FindPasswordCheckAuthenticationCodeActivity.this,
								FindPasswordCompanySelectActivity.class);
						Bundle mBundle = new Bundle();
						mBundle.putSerializable("companyList",(Serializable) userList);
						destIntent.putExtra("LoginMobile", loginMobile);
						destIntent.putExtras(mBundle);
					}
					startActivity(destIntent);
					this.finish();
				}else if(taskFlag == GET_CODE_FLAG){
					DialogUtil.createShortDialog(this, "验证码发送成功");
					mApp.setLoginExtraInformation(mobileView.getText().toString(), null, null);
					if (time < 0 || time >= 60) {
						countDownTimer = new Timer();
						countDownTimerTask = new TimerTask() {
							public void run() {
								Message message = new Message();
								time--;
								if (time < 0) {
									time = 60;
									message.what = 3;
									mhandler.sendMessage(message);
								} else {
									message.what = 2;
									mhandler.sendMessage(message);
								}

							}
						};
						countDownTimer.schedule(countDownTimerTask, 0, 1000);
					}
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	@Override
	public void parseData(WebApiResponse response) {
		if(taskFlag == CHECK_CODE_FLAG){
			ArrayList<UserInformation> userList = UserInformation.parseListByJson(response.getStringData());
			response.mData = userList;
		}
	}
}
