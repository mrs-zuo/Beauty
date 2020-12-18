package com.glamourpromise.beauty.customer.task;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.RSAUtil;

public class UpdatePasswordHttpTask implements IConnectTask{
	private static final String CATEGORY_NAME = "Login";
	private static final String UPDATE_PASSWORD = "updateCustomerPassword";
	
	private ResponseListener mListener;
	private UserInfoApplication mApp;
	private String mCustomerIDs;
	private String mNewPassword;
	private String mLoginMobile;
	
	public interface ResponseListener{
		public void onHandleResponse(WebApiResponse response);
	}
	
	

	public UpdatePasswordHttpTask(UserInfoApplication app, String loginMobile, ResponseListener listener) {
		mListener = listener;
		mApp = app;
		mLoginMobile = loginMobile;
	}
	
	

	public String getCustomerIDs() {
		return mCustomerIDs;
	}



	public void setCustomerIDs(String customerIDs) {
		mCustomerIDs = customerIDs;
	}



	public String getNewPassword() {
		return mNewPassword;
	}



	public void setNewPassword(String newPassword) {
		mNewPassword = newPassword;
	}



	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerIDs", mCustomerIDs);
			para.put("Password", RSAUtil.encrypt(mNewPassword));
			para.put("LoginMobile", RSAUtil.encrypt(mLoginMobile));
			para.put("ImageWidth", String.valueOf(60));
			para.put("ImageHeight", String.valueOf(60));
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
		// TODO Auto-generated method stub
		if(mListener != null){
			mListener.onHandleResponse(response);
		}
	}



	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

}
