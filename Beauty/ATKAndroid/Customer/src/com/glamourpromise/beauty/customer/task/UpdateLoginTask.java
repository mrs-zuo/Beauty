package com.glamourpromise.beauty.customer.task;

import java.lang.ref.WeakReference;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.RSAUtil;

public class UpdateLoginTask implements IConnectTask{
	private static final String CATEGORY = "Login";
	private static final String METHOD_NAME = "updateLoginInfo";
	
	private UserInfoApplication mApp;
	private String mPassword;
	private String mUserName;
	private String mCustomerID;
	private String mCompanyID;
	private String mUUID;
	
	private WeakReference<IUpdateLoginCallback> mCallback;
	
	public interface IUpdateLoginCallback{
		public void onUpdateSuccess(String guid);
		public void onError();
	}
	
	

	public UpdateLoginTask(UserInfoApplication app, String password,
			String userName, String customerID, String companyID, String uUID,
			IUpdateLoginCallback callback) {
		super();
		mApp = app;
		mPassword = password;
		mUserName = userName;
		mCustomerID = customerID;
		mCompanyID = companyID;
		mUUID = uUID;
		mCallback = new WeakReference<UpdateLoginTask.IUpdateLoginCallback>(callback);
	}

	@Override
	public WebApiRequest getRequest() {
		String password = RSAUtil.encrypt(mPassword);
		String userName = RSAUtil.encrypt(mUserName);
		
		JSONObject para = new JSONObject();
		try {
			para.put("LoginMobile", userName);
			para.put("Password", password);
			para.put("DeviceID", mUUID);
			para.put("DeviceModel", android.os.Build.MODEL);
			para.put("OSVersion", android.os.Build.VERSION.RELEASE);
			para.put("UserID", mCustomerID);
			para.put("CompanyID", mCompanyID);
			para.put("APPVersion", mApp.getPackageVersion());
			para.put("ClientType", 2);
			para.put("DeviceType", 2);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY, METHOD_NAME, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY, METHOD_NAME, para.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200 && response.getCode() == WebApiResponse.GET_WEB_DATA_TRUE){
			try {
				JSONObject data = new JSONObject(response.getStringData());
				String guid = data.getString("GUID");
				if(mCallback != null && mCallback.get() != null)
					mCallback.get().onUpdateSuccess(guid);
			} catch (JSONException e) {
				e.printStackTrace();
				if(mCallback != null && mCallback.get() != null)
					mCallback.get().onError();
			}
		}else{
			if(mCallback != null && mCallback.get() != null)
				mCallback.get().onError();
		}
	}

}
