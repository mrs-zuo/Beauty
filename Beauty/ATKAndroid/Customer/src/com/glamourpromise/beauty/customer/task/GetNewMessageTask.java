package com.glamourpromise.beauty.customer.task;

import java.lang.ref.WeakReference;
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

public class GetNewMessageTask implements IConnectTask{
	private static final String CATEGORY_NAME = "Message";
	private static final String GET_NEW_MESSAGE = "getNewMessage";
	
	private String customerID;
	private String thereUserID;
	private String oldestMessageID;
	
	private UserInfoApplication mApp;
	private WeakReference<NewMessageCallback> mCallback;
	
	public interface NewMessageCallback{
		public void onLoaded(ArrayList<ChatMessageInformation> newMessages);
		public void onError(int errorCode, String message);
	}
	
	
	
	public GetNewMessageTask(String customerID, String thereUserID, String oldestMessageID, UserInfoApplication app, NewMessageCallback callback) {
		super();
		this.customerID = customerID;
		this.thereUserID = thereUserID;
		this.oldestMessageID = oldestMessageID;
		mApp = app;
		mCallback = new WeakReference<GetNewMessageTask.NewMessageCallback>(callback);
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("HereUserID", customerID);
			para.put("ThereUserID", thereUserID);
			para.put("MessageID", oldestMessageID);
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_NEW_MESSAGE, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_NEW_MESSAGE, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<ChatMessageInformation> list = (ArrayList<ChatMessageInformation>) response.mData;
				if(mCallback != null && mCallback.get() != null){
					mCallback.get().onLoaded(list);
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				if(mCallback != null && mCallback.get() != null){
					mCallback.get().onError(response.getCode(), response.getMessage());
				}
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				if(mCallback != null && mCallback.get() != null){
					mCallback.get().onError(response.getCode(), Constant.NET_ERR_PROMPT);
				}
				break;
			default:
				break;
			}
		}
		
	}
	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<ChatMessageInformation> list = ChatMessageInformation.parseListByJson(response.getStringData());
		response.mData = list;
	}
}
