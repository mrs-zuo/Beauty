package cn.com.antika.Thread;

import org.json.JSONException;
import org.json.JSONObject;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.com.antika.webservice.WebServiceUtil;


public abstract class BaseThread extends Thread{
	abstract protected JSONObject getParamJsonObject();
	abstract protected String getmethodName();
	abstract protected String getmethodParentName();
	abstract protected void handleResult(WebDataObject resultObject);
	abstract protected UserInfoApplication getApplication();
	@Override
	public void run() {
		String methodName = getmethodName();
		String endPoint = getmethodParentName();
		JSONObject paramJson=getParamJsonObject();
		UserInfoApplication userinfoApplication=getApplication();
		String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,paramJson.toString(),userinfoApplication);
		WebDataObject resultObject = new WebDataObject();
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
}
