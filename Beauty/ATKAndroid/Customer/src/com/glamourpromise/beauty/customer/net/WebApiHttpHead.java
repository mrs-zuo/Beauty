package com.glamourpromise.beauty.customer.net;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.BaseUtil;

public class WebApiHttpHead {
	public static final String ANDROID_DEVICE_TYPE = "2";
	public static final String CUSTOMER_CLIENT_TYPE = "2";
	
	private String mCompanyID="0";
	private String mBranchID="0";
	private String mUserID="0";
	private String mGUID="0";
	private String mAuthorization="";
	//必选
	private String mClient;
	private String mDeviceType;
	private String mAppVersion;
	private String mMethodName;
	private String mActionTime;
	
	private int mFormalFlag;
	
	public static WebApiHttpHead obtainNeededCheckHead(String companyID, String userID, String guid, String categoryName, String methodName, String params, int userType, String appVersion){
		WebApiHttpHead header = new WebApiHttpHead();
		header.setFormalFlag(userType);
		
		header.setActionTime(BaseUtil.getCurrentTime());
		header.setAppVersion(appVersion);
		header.setClient(WebApiHttpHead.CUSTOMER_CLIENT_TYPE);
		header.setDeviceType(WebApiHttpHead.ANDROID_DEVICE_TYPE);
		
		header.setBranchID("0");
		header.setCompanyID(companyID);
		
		header.setGUID(guid);
		header.setMethodName(methodName);
		header.setUserID(userID);
		
		String auth = methodName + params + companyID + guid + "HS";
		header.setAuthorization(BaseUtil.getMD5(auth.toUpperCase()));
		return header;
	}
	
	public static WebApiHttpHead obtainNotNeededCheckHead(String methodName, int userType, String appVersion){
		WebApiHttpHead header = new WebApiHttpHead();
		header.setFormalFlag(userType);
		
		header.setActionTime(BaseUtil.getCurrentTime());
		header.setAppVersion(appVersion);
		header.setMethodName(methodName);
		header.setClient(WebApiHttpHead.CUSTOMER_CLIENT_TYPE);
		header.setDeviceType(WebApiHttpHead.ANDROID_DEVICE_TYPE);
		
		header.setAuthorization("");
		header.setBranchID("0");
		header.setCompanyID("0");
		header.setGUID("");
		header.setUserID("0");
		return header;
	}
	
	public String getCompanyID() {
		return mCompanyID;
	}
	public void setCompanyID(String companyID) {
		mCompanyID = companyID;
	}
	public String getBranchID() {
		return mBranchID;
	}
	public void setBranchID(String branchID) {
		mBranchID = branchID;
	}
	public String getUserID() {
		return mUserID;
	}
	public void setUserID(String userID) {
		mUserID = userID;
	}
	public String getClient() {
		return mClient;
	}
	public void setClient(String client) {
		mClient = client;
	}
	public String getDeviceType() {
		return mDeviceType;
	}
	public void setDeviceType(String dT) {
		mDeviceType = dT;
	}
	public String getAppVersion() {
		return mAppVersion;
	}
	public void setAppVersion(String appVersion) {
		mAppVersion = appVersion;
	}
	public String getMethodName() {
		return mMethodName;
	}
	public void setMethodName(String methodName) {
		mMethodName = methodName;
	}
	public String getActionTime() {
		return mActionTime;
	}
	public void setActionTime(String actionTime) {
		mActionTime = actionTime;
	}
	public String getGUID() {
		return mGUID;
	}
	public void setGUID(String gUID) {
		mGUID = gUID;
	}
	public String getAuthorization() {
		return mAuthorization;
	}
	public void setAuthorization(String authorization) {
		mAuthorization = authorization;
	}
	public int getFormalFlag() {
		return mFormalFlag;
	}
	public void setFormalFlag(int formalFlag) {
		mFormalFlag = formalFlag;
	}
	
	public String getJson(){
		JSONObject sb = new JSONObject();
		try {
			sb.put("mCompanyID", mCompanyID);
			sb.put("mBranchID", mBranchID);
			sb.put("mUserID", mUserID);
			sb.put("mClient", mClient);
			sb.put("mDeviceType", mDeviceType);
			sb.put("mAppVersion", mAppVersion);
			sb.put("mMethodName", mMethodName);
			sb.put("mActionTime", mActionTime);
			sb.put("mGUID", mGUID);
			sb.put("mAuthorization", mAuthorization);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "";
		}
		
		return sb.toString();
		
	}
	
}
