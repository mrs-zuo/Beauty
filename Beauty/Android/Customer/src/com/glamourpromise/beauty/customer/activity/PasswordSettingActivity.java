package com.glamourpromise.beauty.customer.activity;

import org.json.JSONException;
import org.json.JSONObject;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.RSAUtil;

public class PasswordSettingActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Login";
	private static final String UPDATE_PASSWORD = "updateUserPassword";
	private EditText oldPassword;
	private EditText newPassword;
	private EditText newPasswordConfirm;
	private ProgressDialog progressDialog;
	private String strNewPassword;
	private String strOldPassword;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_password_setting);
		super.setTitle(getString(R.string.title_password_setting));
		oldPassword = (EditText) findViewById(R.id.input_old_password);
		newPassword = (EditText) findViewById(R.id.input_new_password);
		newPasswordConfirm = (EditText) findViewById(R.id.input_new_password_again);
		findViewById(R.id.confirm_button).setOnClickListener(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		super.onClick(view);
		switch (view.getId()) {
		case R.id.confirm_button:
			strOldPassword = oldPassword.getText().toString();
			strNewPassword = newPassword.getText().toString();
			String strNewPasswordConfirm = newPasswordConfirm.getText()
					.toString();
			if (strOldPassword.equals("") || strNewPassword.equals("")
					|| strNewPasswordConfirm.equals("")) {
				DialogUtil.createMakeSureDialog(this, "确认ʾ",getString(R.string.input_compelete_information));
			} else if (strNewPassword.length() < 6) {
				DialogUtil.createMakeSureDialog(this, "确认ʾ",getString(R.string.password_small_six));
			} else if (!strNewPassword.equals(strNewPasswordConfirm)) {
				DialogUtil.createMakeSureDialog(this, "确认ʾ",getString(R.string.password_not_equal));
			} else {
				updateNewPassword();
			}
			break;
		default:
			break;
		}
	}

	private void updateNewPassword() {
		progressDialog = new ProgressDialog(this);
		progressDialog.setMessage("正在修改...");
		progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		progressDialog.show();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("UserID", mCustomerID);
			para.put("OldPassword", RSAUtil.encrypt(strOldPassword));
			para.put("NewPassword", RSAUtil.encrypt(strNewPassword));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, UPDATE_PASSWORD, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, UPDATE_PASSWORD, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				mApp.AppExitToLoginActivity(this);
				PasswordSettingActivity.this.finish();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
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
		
	}
}
