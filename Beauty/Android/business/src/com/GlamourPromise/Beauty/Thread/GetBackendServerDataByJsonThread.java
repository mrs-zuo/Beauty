package com.GlamourPromise.Beauty.Thread;

import org.json.JSONException;
import org.json.JSONObject;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetBackendServerDataByJsonThread extends Thread{
	private IGetBackendServerDataTask mGetBackendServerDataTaskImpl;
	private WebDataObject resultObject;
	
	public GetBackendServerDataByJsonThread(IGetBackendServerDataTask getBackendServerDataTaskImpl){
		mGetBackendServerDataTaskImpl = getBackendServerDataTaskImpl;
		resultObject = new WebDataObject();
	}
	
	@Override
	public void run() {
		String methodName = mGetBackendServerDataTaskImpl.getmethodName();
		String endPoint = mGetBackendServerDataTaskImpl.getmethodParentName();
		JSONObject paramJson= (JSONObject) mGetBackendServerDataTaskImpl.getParamObject();
		UserInfoApplication userInfoApplication=mGetBackendServerDataTaskImpl.getApplication();
		String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,paramJson.toString(),userInfoApplication);
		if (serverRequestResult == null || serverRequestResult.equals("")){
			resultObject.code = Constant.GET_DATA_NULL;
		}
		else {
			JSONObject resultJson = null;
			try {
				resultJson=new JSONObject(serverRequestResult);
				resultObject.code=resultJson.getInt("Code");
				if(resultObject.code == Constant.GET_WEB_DATA_TRUE)
					resultObject.result=resultJson.get("Data");
				else
					resultObject.result=resultJson.getString("Message");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				resultObject.code = Constant.PARSING_ERROR;
			}
		}
		mGetBackendServerDataTaskImpl.handleResult(resultObject);
	}
}
