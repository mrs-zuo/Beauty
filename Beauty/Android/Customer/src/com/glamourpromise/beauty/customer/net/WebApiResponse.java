package com.glamourpromise.beauty.customer.net;

import org.json.JSONException;
import org.json.JSONObject;

public class WebApiResponse {
	//返回代码 
	//后台的Code
	public static final int GET_WEB_DATA_TRUE = 1;
	public static final int GET_WEB_DATA_FALSE = 0;
	public static final int GET_WEB_DATA_EXCEPTION = -1;
	public static final int NEED_UPDATE = -3;
	//本地的Code
	public static final int GET_DATA_NULL = -4;
	public static final int PARSING_ERROR = -5;
	public static final int INIT_STATUS = -10;
	
	private int mHttpCode;
	private int mCode;
	private String mHttpErrorMessage="0";
	private String mMessage = "";
	private String mStrData;	
	public Object mData;
	
	public WebApiResponse(){
		init();
	}
	
	public WebApiResponse(String src){
		init();
		setByJson(src);
	}
	
	/**
	 * 初始化
	 */
	public void init(){
		mCode = INIT_STATUS;
	}
	
	public int getHttpCode() {
		return mHttpCode;
	}

	public void setHttpCode(int httpCode) {
		this.mHttpCode = httpCode;
	}

	public int getCode() {
		return mCode;
	}
	public void setCode(int code) {
		mCode = code;
	}
	
	public String getHttpErrorMessage() {
		return mHttpErrorMessage;
	}

	public void setHttpErrorMessage(String httpErrorMessage) {
		mHttpErrorMessage = httpErrorMessage;
	}

	public String getMessage() {
		return mMessage;
	}
	public void setMessage(String message) {
		mMessage = message;
	}
	public String getStringData() {
		return mStrData;
	}
	public void setStringData(String data) {
		mStrData = data;
	}

	public void setByJson(String src){
		init();
		if(src == null || src.equals("")){
			mCode = GET_DATA_NULL;
			return;
		}
		JSONObject json;
		try {
			String tmp = src;
			json = new JSONObject(tmp);
			this.mCode=json.getInt("Code");
			if(json.has("Data"))
				mStrData=json.getString("Data");
			if(json.has("Message"))
				mMessage=json.getString("Message");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			mCode = PARSING_ERROR;
		}
	}
}
