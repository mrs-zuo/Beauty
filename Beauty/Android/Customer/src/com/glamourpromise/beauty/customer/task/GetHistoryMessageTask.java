package com.glamourpromise.beauty.customer.task;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.ChatMessageInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class GetHistoryMessageTask implements IConnectTask{
	private static final String CATEGORY_NAME = "Message";
	private static final String GET_HISTORY_MESSAGE = "getHistoryMessage";
	
	private String mCustomerID;
	private String thereUserID;
	private String oldestMessageID;
	private UserInfoApplication mApp;
	private HistoryMessageCallback mCallback;
	
	public interface HistoryMessageCallback{
		public void onLoaded(ArrayList<ChatMessageInformation> newMessages);
		public void onError(int errorCode, String message);
		public void onHttpCode(int httpCode, int errorMessage);
	}
	
	public GetHistoryMessageTask(String customerID, String thereUserID, String oldestMessageID, UserInfoApplication app) {
		mCustomerID = customerID;
		this.thereUserID = thereUserID;
		this.oldestMessageID = oldestMessageID;
		mApp = app;
	}

	public void setCallback(HistoryMessageCallback callback) {
		mCallback = callback;
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("HereUserID", mCustomerID);
			para.put("ThereUserID", thereUserID);
			para.put("MessageID", oldestMessageID);
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_HISTORY_MESSAGE, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_HISTORY_MESSAGE, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<ChatMessageInformation> list = (ArrayList<ChatMessageInformation>) response.mData;
				mCallback.onLoaded(list);
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				mCallback.onError(response.getCode(), response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				mCallback.onError(response.getCode(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}else{
			
		}
	}
	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<ChatMessageInformation> list = ChatMessageInformation.parseListByJson(response.getStringData());
		response.mData = list;
	}
}
