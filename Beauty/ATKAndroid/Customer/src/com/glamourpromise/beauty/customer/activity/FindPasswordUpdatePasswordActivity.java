package com.glamourpromise.beauty.customer.activity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.task.UpdatePasswordHttpTask;
import com.glamourpromise.beauty.customer.task.UpdatePasswordHttpTask.ResponseListener;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class FindPasswordUpdatePasswordActivity extends BaseActivity implements OnClickListener {
	private String customerID;
	private String password;
	private String isAbleBack;
	private ProgressDialog progressDialog;
	private String mLonginMobile;
	
	private UpdatePasswordHttpTask updateTask;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_find_password_update_password);
		super.setTitle(getString(R.string.title_update_password));
		customerID = getIntent().getStringExtra("customerID");
		isAbleBack = getIntent().getStringExtra("isAbleBack");
		mLonginMobile = getIntent().getStringExtra("LoginMobile");

		findViewById(R.id.complete).setOnClickListener(this);
		findViewById(R.id.cancel).setOnClickListener(this);
		if (isAbleBack.equals("true")) {
			findViewById(R.id.btn_main_back).setOnClickListener(this);
		} else {
			findViewById(R.id.btn_main_back).setVisibility(View.GONE);
		}
		findViewById(R.id.btn_main_home).setVisibility(View.VISIBLE);
		updateTask = new UpdatePasswordHttpTask(mApp, mLonginMobile, new ResponseListener() {
			
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
						DialogUtil.createShortDialog(FindPasswordUpdatePasswordActivity.this, "密码修改成功");
						Intent destIntent = new Intent(FindPasswordUpdatePasswordActivity.this, LoginActivity.class);
						startActivity(destIntent);
						setResult(RESULT_OK);
						FindPasswordUpdatePasswordActivity.this.finish();
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
		});

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.btn_main_back_menu:
			this.finish();
			break;
		case R.id.cancel:
			if (isAbleBack.equals("true")) {
				setResult(RESULT_OK, null);
			}
			this.finish();
			break;
		case R.id.complete:
			EditText newPasswordView = (EditText) findViewById(R.id.input_new_password);
			EditText newPasswordAgainView = (EditText) findViewById(R.id.input_new_password_again);
			password = newPasswordView.getText().toString();
			String passwordConfirm = newPasswordAgainView.getText().toString();

			if (password.equals("") || passwordConfirm.equals("")) {
				DialogUtil.createShortDialog(
						FindPasswordUpdatePasswordActivity.this, "密码不能为空");
			} else if (!password.equals(passwordConfirm)) {
				DialogUtil.createShortDialog(
						FindPasswordUpdatePasswordActivity.this, "两次密码不相同");
			} else if(password.length() < 6){
				DialogUtil.createShortDialog(
						FindPasswordUpdatePasswordActivity.this, "密码必须为6~20位");
			}else {
				progressDialog = new ProgressDialog(this);
				progressDialog.setMessage("正在修改...");
				progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
				progressDialog.show();
				progressDialog.setCancelable(false);				
				updateTask.setCustomerIDs(customerID);
				updateTask.setNewPassword(password);
				super.asyncRefrshView(updateTask);
			}

			break;
		default:
			break;
		}
	}
}
