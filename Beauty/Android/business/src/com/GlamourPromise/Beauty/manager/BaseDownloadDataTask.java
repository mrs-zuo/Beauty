package com.GlamourPromise.Beauty.manager;

import org.json.JSONException;
import org.json.JSONObject;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

/**
 * 从后台下载数据任务基类
 * @author hongchuan.du
 *
 */
public abstract class BaseDownloadDataTask implements Runnable{
	private String mMethodName;
	private String mMethodCategoryName;
	protected BaseDownloadDataTask(String methodName, String methodCategoryName){
		mMethodName = methodName;
		mMethodCategoryName = methodCategoryName;
	}

	@Override
	public void run() {
		// TODO Auto-generated method stub
		String serverRequestResult = "";
		WebDataObject resultObject = new WebDataObject();
		try {
			JSONObject paramJson = (JSONObject) getParamObject();
			serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(mMethodCategoryName, mMethodName,paramJson.toString(),UserInfoApplication.getInstance());
		} catch (Exception e) {
			e.printStackTrace();
			resultObject.code = Constant.PARSING_ERROR;
		}
		
		if (serverRequestResult == null || serverRequestResult.equals("")){
			resultObject.code = Constant.GET_DATA_NULL;
		}
		else {
			JSONObject resultJson = null;
			try {
				resultJson=new JSONObject(serverRequestResult);
				resultObject.code=resultJson.getInt("Code");
				//-3 表示登陆时检测到需要强制升级
				if(resultObject.code == Constant.GET_WEB_DATA_TRUE || resultObject.code==-3)
					resultObject.result=resultJson.get("Data");
				else
					resultObject.result=resultJson.getString("Message");
				
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				resultObject.code = Constant.PARSING_ERROR;
			}
		}
		handleResult(resultObject);	
	}
	
	abstract protected Object getParamObject();
	abstract protected void handleResult(WebDataObject webData);
}
