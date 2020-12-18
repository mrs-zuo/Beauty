package cn.com.antika.implementation;

import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.Customer;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class AddNewCustomerTaskImpl implements IGetBackendServerDataTask {
	private static final String methodName = "addCustomer";
	private static final String methodParentName = "Customer";
	private HashMap<String, String> mParamHashMap;
	private HashMap<String, JSONArray> mParamJsonMap;
	private Handler mHandler;
	private int     isNeedCheck;
	private UserInfoApplication userinfoApplication;
	public AddNewCustomerTaskImpl(HashMap<String, String> paramHashMap, HashMap<String, JSONArray> paramJsonMap, Handler handler,int isNeedCheck,UserInfoApplication userinfoApplication){
		mParamHashMap = paramHashMap;
		mParamJsonMap = paramJsonMap;
		mHandler = handler;
		this.isNeedCheck=isNeedCheck;
		this.userinfoApplication=userinfoApplication;
	}
	
	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return methodName;
	}

	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return methodParentName;
	}

	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		return getParamJsonObject();
	}
	
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = null;
		try {
			paramJsonObject = new JSONObject();
			paramJsonObject.put("IsCheck",isNeedCheck);
			paramJsonObject.put("ResponsiblePersonID", mParamHashMap.get("ResponsiblePersonID"));
			paramJsonObject.put("CustomerName", mParamHashMap.get("CustomerName"));
			paramJsonObject.put("Title",mParamHashMap.get("Title"));
			paramJsonObject.put("Gender",Integer.parseInt(mParamHashMap.get("Gender")));
			paramJsonObject.put("LoginMobile", mParamHashMap.get("LoginMobile"));
			paramJsonObject.put("HeadFlag", mParamHashMap.get("HeadFlag"));
			paramJsonObject.put("ImageString", mParamHashMap.get("ImageString"));
			paramJsonObject.put("ImageType", mParamHashMap.get("ImageType"));
			paramJsonObject.put("PhoneList", mParamJsonMap.get("PhoneList"));
			paramJsonObject.put("CardID",Integer.parseInt(mParamHashMap.get("CardID")));
			paramJsonObject.put("SourceType",Integer.parseInt(mParamHashMap.get("SourceType")));
			//是否是过去的 导入的顾客
			paramJsonObject.put("IsPast",Boolean.valueOf(mParamHashMap.get("IsPast")));
			if(mParamHashMap.get("SalesID")!=null && !"".equals(mParamHashMap.get("SalesID")) && !"[0]".equals(mParamHashMap.get("SalesID")))
			  paramJsonObject.put("SalesPersonIDList",new JSONArray(mParamHashMap.get("SalesID")));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return paramJsonObject;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			msg.what = resultObject.code;
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			msg.obj = handleJsonObjectResult(resultJsonObject);
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code==-2 || resultObject.code==-3){
			msg.what = resultObject.code;
			msg.obj = resultObject.result;
		}else if(resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.what = 3;
			msg.obj = resultObject.result;
		}
		else
			msg.what=resultObject.code;
		msg.sendToTarget();
	}
	private Customer handleJsonObjectResult(JSONObject contentJsonObject){
		//解析返回来的新的添加成功顾客Json数据
		Customer newCustomerForResult = new Customer();
		try {
			newCustomerForResult.setCustomerId(contentJsonObject.getInt("CustomerID"));
			newCustomerForResult.setCustomerName(contentJsonObject.getString("CustomerName"));
			newCustomerForResult.setLoginMobile(contentJsonObject.getString("LoginMobile"));
			newCustomerForResult.setHeadImageUrl(contentJsonObject.getString("HeadImageURL"));
			newCustomerForResult.setPinYin(contentJsonObject.getString("PinYin"));
			newCustomerForResult.setIsMyCustomer(contentJsonObject.getBoolean("IsMyCustomer"));
		} catch (JSONException e) {
		}
		return newCustomerForResult;
	}
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
