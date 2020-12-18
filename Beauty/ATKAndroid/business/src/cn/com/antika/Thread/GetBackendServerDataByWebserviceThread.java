package cn.com.antika.Thread;
import org.json.JSONException;
import org.json.JSONObject;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.com.antika.webservice.WebServiceUtil;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetBackendServerDataByWebserviceThread extends Thread{
	private IGetBackendServerDataTask mGetBackendServerDataTaskImpl;
	private WebDataObject webDataObject;
	private boolean       isJsonArray;//是否是jsonArray返回结果
	public GetBackendServerDataByWebserviceThread(IGetBackendServerDataTask getBackendServerDataTaskImpl,boolean isJsonArray){
		mGetBackendServerDataTaskImpl = getBackendServerDataTaskImpl;
		webDataObject = new WebDataObject();
		this.isJsonArray=isJsonArray;
	}
	
	@Override
	public void run() {
		// TODO Auto-generated method stub
		String methodName = mGetBackendServerDataTaskImpl.getmethodName();
		String endPoint = mGetBackendServerDataTaskImpl.getmethodParentName();
		@SuppressWarnings("unchecked")
		JSONObject jsonParam = (JSONObject)mGetBackendServerDataTaskImpl.getParamObject();
		UserInfoApplication userInfoApplication=mGetBackendServerDataTaskImpl.getApplication();
		String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,jsonParam.toString(),userInfoApplication);
		if (serverRequestResult == null || ("").equals(serverRequestResult))
			webDataObject.code = Constant.GET_DATA_NULL;
		else {
			int code=Constant.GET_WEB_DATA_EXCEPTION;
			Object contentJson=null;
			String message="";
			try {
				JSONObject  resultJson=new JSONObject(serverRequestResult);
				code = resultJson.getInt("Code");
				contentJson = null;
				if(code==1){
					if(isJsonArray)
						contentJson=resultJson.getJSONArray("Data");
					else
						contentJson=resultJson.getJSONObject("Data");
				}
				message = resultJson.getString("Message");
			} catch (JSONException e) {
				e.printStackTrace();
				code=Constant.GET_WEB_DATA_EXCEPTION;
			}
			webDataObject.code = code;
			if (code == Constant.GET_WEB_DATA_EXCEPTION || code == Constant.GET_WEB_DATA_FALSE)
				webDataObject.result = message;
			else {
				webDataObject.result = contentJson;
			}
		}
		mGetBackendServerDataTaskImpl.handleResult(webDataObject);
	}
}
