package com.glamourpromise.beauty.customer.task;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class CategoryListHttpTask implements IConnectTask{
	private static final String CATEGORY_NAME ="Category";
	private static final String GET_CATEGORY_LIST = "GetCategoryList";	
	public static final int BY_COMPANYID_TASK = 1;
	public static final int BY_CATEGORYID_TASK = 2;
	private int taskFlag;
	private UserInfoApplication mApp;
	private int    mProductType;
	private String mNextCategoryID;
	private ResponseListener mListener;
	
	public interface ResponseListener{
		public void onHandleResponse(WebApiResponse response);
	}
	
	public CategoryListHttpTask(UserInfoApplication app,int  productType,ResponseListener listener) {
		mApp = app;
		mProductType = productType;
		mListener = listener;
	}
	
	public int getTaskFlag() {
		return taskFlag;
	}

	public void setTaskFlag(int taskFlag) {
		this.taskFlag = taskFlag;
	}

	public String getNextCategoryID() {
		return mNextCategoryID;
	}



	public void setNextCategoryID(String nextCategoryID) {
		mNextCategoryID = nextCategoryID;
	}



	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = CATEGORY_NAME;
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag == BY_COMPANYID_TASK){
			try {
				para.put("Type",mProductType);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag == BY_CATEGORYID_TASK){
			try {
				para.put("CategoryID",mNextCategoryID);
				para.put("Type",mProductType);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName,GET_CATEGORY_LIST,para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
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
		
	}

}
