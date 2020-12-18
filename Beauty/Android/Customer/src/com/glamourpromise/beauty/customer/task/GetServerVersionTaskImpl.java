package com.glamourpromise.beauty.customer.task;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class GetServerVersionTaskImpl implements IConnectTask{
	private static final String methodName = "getServerVersion";
	private static final String methodParentName = "Version";
	private String mCurrentVersion;
	private UserInfoApplication mApp;
	private onReslutListener mListener;
	
	public interface onReslutListener{
		public void onHandleReslut(WebApiResponse response);
	}
	
	public GetServerVersionTaskImpl(String currentVersion, UserInfoApplication app, onReslutListener listener){
		mCurrentVersion = currentVersion;
		mApp = app;
		mListener = listener;
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("DeviceType", "1");// 1:android
			para.put("ClientType", "1");// 1:customer
			para.put("CurrentVersion",mCurrentVersion);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(methodParentName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(methodParentName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		mListener.onHandleReslut(response);
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

}
