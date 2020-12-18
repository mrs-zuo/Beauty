package com.glamourpromise.beauty.customer.net;

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

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;
import android.util.SparseArray;

public class WebApiConnectHelper extends HandlerThread{
	private static final String TAG = "WebApiConnectHelper";
	
	private static WebApiConnectHelper sConnect;
	private Map<Integer, WeakReference<IConnectTask>> mRequestMap;
	private Handler mRequestHandler;
	private Handler mResponseHandler;
	private HttpClient mHttpClient;
	@SuppressLint("UseSparseArrays")
	public WebApiConnectHelper(Context context, HttpClient httpClient) {
		super(TAG);
		mHttpClient = httpClient;
		mRequestMap = Collections.synchronizedMap(new HashMap<Integer, WeakReference<IConnectTask>>());
		mResponseHandler = new Handler(context.getMainLooper()){

			@Override
			public void handleMessage(Message msg) {
				int taskID = msg.what;
				SparseArray<WebApiResponse> data = (SparseArray<WebApiResponse>) msg.obj;
				WebApiResponse response = data.get(0);
				if(mRequestMap.get(taskID) != null){
					IConnectTask newTask = mRequestMap.get(taskID).get();
					mRequestMap.remove(taskID);
					if(newTask != null){
						newTask.onHandleResponse(response);
					}
				}
			}
		};
	}
	
	public static WebApiConnectHelper getConnect(Context context, HttpClient httpClient){
		if(sConnect == null){
			sConnect = new WebApiConnectHelper(context, httpClient);
			sConnect.start();
			sConnect.getLooper();
		}
		return sConnect;
	}
	
	@SuppressLint("HandlerLeak")
	@Override
	protected void onLooperPrepared(){
		mRequestHandler = new Handler(){
			@SuppressLint("UseValueOf")
			@Override 
			public void handleMessage(Message msg){
				int taskID = msg.what;
				IConnectTask newTask=null;
				if(mRequestMap!=null && mRequestMap.get(taskID)!=null)
					newTask= mRequestMap.get(taskID).get();
				WebApiResponse response = handleWebApiRequestTask_2(newTask);//处理任务
				if(response!=null && response.getHttpCode() == 200 && response.getCode() == WebApiResponse.GET_WEB_DATA_TRUE){
					if(newTask!=null)
						newTask.parseData(response);
				}
				SparseArray<WebApiResponse> data = new SparseArray<WebApiResponse>(1);
				data.put(0, response);
				mResponseHandler.obtainMessage(taskID, data).sendToTarget();;
			}
		};
	}
	
	/**
	 * 插入新任务
	 * @param newTask
	 */
	public void queueTask(IConnectTask newTask){
		int taskID = newTask.hashCode();
		mRequestMap.put(taskID, new WeakReference<IConnectTask>(newTask));
		mRequestHandler.obtainMessage(taskID).sendToTarget();
	}
	
	public void cancelAllTask(){
		mRequestMap.clear();
		mResponseHandler.removeCallbacksAndMessages(null);
		mRequestHandler.removeCallbacksAndMessages(null);
	}

	private WebApiResponse handleWebApiRequestTask_2(IConnectTask requestTask){
		WebApiResponse response=null;
		if(requestTask!=null){
			WebApiRequest request = requestTask.getRequest();
			WebApiHttpHead header = request.getHeader();
			String para = request.getParameters();
			String categoryName = request.getCategoryName();
			HttpResponse httpResponse = WebServiceUtil.requestWebApiAction_2(categoryName, para, header, mHttpClient);
			response= new WebApiResponse();
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
					Log.d("resultString", resultString);
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
		}
		return response;
	}
}
