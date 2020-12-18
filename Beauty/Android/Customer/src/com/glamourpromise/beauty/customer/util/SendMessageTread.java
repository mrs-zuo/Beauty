package com.glamourpromise.beauty.customer.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.NewMessageInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.net.WebServiceUtil;

public class SendMessageTread<Token> extends HandlerThread {
	private static final String CATEGORY_NAME = "Message";
	private static final String ADD_MESSAGE = "addMessage";
	private static final int MESSAGE_SEND = 1;
	private static final String TAG = "SendMessageTread";
	
	private Handler mHandler;
	private Handler mResponseHandler;
	private WeakReference<Listener<Token>> mListener;
	private Map<Token, NewMessageInformation> requestMap;
	private UserInfoApplication mApp;
	private Context mContext;
	private HttpClient mHttpClient;
	public SendMessageTread(Handler responseHandler, UserInfoApplication app, Context context, HttpClient httpClient){
		super(TAG);
		mApp = app;
		mHttpClient = httpClient;
		mResponseHandler = responseHandler;
		requestMap = Collections.synchronizedMap(new HashMap<Token, NewMessageInformation>());
		mContext = context;
	}
	
	public interface Listener<Token>{
		void onMessageSended(Token token, int sendReturnFlag, int messageID);
		void onHttpError(int httpCode, int message);
	}
	
	public void setListener(Listener<Token> listener){
		mListener = new WeakReference<SendMessageTread.Listener<Token>>(listener);
	}
	
	@Override
	protected void onLooperPrepared(){
		mHandler = new Handler(){
			@Override 
			public void handleMessage(Message msg){
				if(msg.what == MESSAGE_SEND){
					@SuppressWarnings("unchecked")
					Token position = (Token)msg.obj;
					handleRequest(position);
				}
			}
		};
	} 
	
	public void queueMessage(Token position, NewMessageInformation newMessage){
		requestMap.put(position, newMessage);
		mHandler.obtainMessage(MESSAGE_SEND, position).sendToTarget();
	}
	
	private void handleRequest(final Token position){
		//生成參數
		JSONObject para = new JSONObject();
		try {
			para.put("FromUserID",Integer.valueOf(requestMap.get(position).getmSenderID()));
			para.put("ToUserIDs", requestMap.get(position).getmReceiverIDs());
			para.put("MessageContent", requestMap.get(position).getmMessageContent());
			para.put("MessageType", Integer.valueOf(requestMap.get(position).getmMessageType()));
			para.put("GroupFlag", Integer.valueOf(requestMap.get(position).getmGroupFlag()));
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		//生成http头
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, ADD_MESSAGE, para.toString());
		
		//调用网络
		HttpResponse httpResponse = WebServiceUtil.requestWebApiAction_2(CATEGORY_NAME, para.toString(), header, mHttpClient);
		WebApiResponse response = new WebApiResponse();
		if(httpResponse == null){
			response.setCode(WebApiResponse.GET_DATA_NULL);
		}else{
			int httpCode = httpResponse.getStatusLine().getStatusCode();
			response.setHttpCode(httpCode);
			switch (httpCode) {
			case 200:
				// 解析返回的内容  
			    String resultString="";
				StringBuilder builder = new StringBuilder();
				BufferedReader bufferedReader2 = null;
				InputStreamReader inputReader;
				try {
					inputReader = new InputStreamReader(httpResponse.getEntity().getContent(), "UTF-8");
					bufferedReader2 = new BufferedReader(inputReader);
					for (String s = bufferedReader2.readLine(); s != null; s = bufferedReader2.readLine()) {
						builder.append(s);
					}
					bufferedReader2.close();
					inputReader.close();
				} catch (IllegalStateException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				resultString = builder.toString();
				response.setByJson(resultString);
				break;
			case 500:
				break;
			case 401:
				Header responseHeader = httpResponse.getFirstHeader("errorMessage");
				String httpErrorMessage = responseHeader.getValue();
				response.setHttpErrorMessage(httpErrorMessage);
				break;

			default:
				break;
			}
		}
		
		//根据httpcode做不同的处理
		if (response.getHttpCode() == 200){
			handleHttpSucessResult(position, response);
		}else{
			handleHttpError(response);
		}
		
	}

	private void handleHttpError(WebApiResponse response) {
		int httpErrorMessage = 0;
		//当返回401时，取出返回的HttpErrorMessage
		if (response.getHttpCode() == 401){
			httpErrorMessage = Integer.valueOf(response.getHttpErrorMessage());
		}
		
		final int msg = httpErrorMessage;
		final int code = response.getHttpCode();
		mResponseHandler.post(new Runnable() {

			@Override
			public void run() {
				if(mListener != null && mListener.get() != null){
					mListener.get().onHttpError(code, msg);
				}
			}
		});
	}

	private void handleHttpSucessResult(final Token position, WebApiResponse response) {
		final int flag = response.getCode();
		int messageID = 0;
		switch (response.getCode()) {
		case WebApiResponse.GET_WEB_DATA_TRUE:
			try {
				JSONArray tmp = new JSONArray(response.getStringData());
				JSONObject item = (JSONObject) tmp.get(0);
				messageID = item.getInt("NewMessageID");
			} catch (JSONException e) {
				e.printStackTrace();
			}
			break;
		case WebApiResponse.GET_WEB_DATA_EXCEPTION:
		case WebApiResponse.GET_WEB_DATA_FALSE:
			DialogUtil.createShortDialog(mContext.getApplicationContext(),response.getMessage());
			break;
		case WebApiResponse.GET_DATA_NULL:
		case WebApiResponse.PARSING_ERROR:
			DialogUtil.createShortDialog(mContext.getApplicationContext(), Constant.NET_ERR_PROMPT);
			break;
		default:
			break;
		}
		
		final int id = messageID;
		mResponseHandler.post(new Runnable() {
			
			@Override
			public void run() {
				if(mListener != null && mListener.get() != null){
					mListener.get().onMessageSended(position, flag, id);
				}
			}
		});
	}	
}
