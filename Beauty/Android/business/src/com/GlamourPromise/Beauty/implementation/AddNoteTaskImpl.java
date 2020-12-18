package com.GlamourPromise.Beauty.implementation;

import org.json.JSONException;
import org.json.JSONObject;
import android.os.Handler;
import android.os.Message;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class AddNoteTaskImpl implements IGetBackendServerDataTask{
	private static final String methodName = "addNotepad";
	private static final String methodParentName = "Notepad";
	private JSONObject mParamHashMap;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public AddNoteTaskImpl(JSONObject paramHashMap, Handler handler,UserInfoApplication userinfoApplication){
		mParamHashMap = paramHashMap;
		mHandler = handler;
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
		return mParamHashMap;
	}
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = null;
		try {
			paramJsonObject = new JSONObject();
			paramJsonObject.put("CustomerID", mParamHashMap.get("CustomerID"));
			paramJsonObject.put("Content", mParamHashMap.get("Content"));
			paramJsonObject.put("TagIDs", mParamHashMap.get("TagIDs"));
			
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
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		msg.sendToTarget();
	}
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
