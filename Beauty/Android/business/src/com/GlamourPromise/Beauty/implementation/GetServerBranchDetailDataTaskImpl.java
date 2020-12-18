package com.GlamourPromise.Beauty.implementation;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;
import org.ksoap2.serialization.SoapObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerBranchDetailDataTaskImpl implements IGetBackendServerDataTask{
	private static final String methodName = "getBusinessDetail";
	private static final String methodParentName = "Company";
	private JSONObject  jsonParam;
	private Handler mHandler;
	private UserInfoApplication userInfoApplication;
	public GetServerBranchDetailDataTaskImpl(JSONObject jsonParam, Handler handler,UserInfoApplication userInfoApplication){
		this.jsonParam = jsonParam;
		mHandler = handler;
		this.userInfoApplication=userInfoApplication;
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
		return generateParamMap();
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			BranchInfo branchInfo = new BranchInfo();
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			handleJsonObjectResult(resultJsonObject,branchInfo);
			msg.obj = branchInfo;
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		msg.sendToTarget();
	}

	private JSONObject generateParamMap(){
		return jsonParam;
	}
	
	private void handleJsonObjectResult(JSONObject contentJsonObject, BranchInfo branchInfo){
		branchInfo.setDetailInfoByJsonObject(contentJsonObject);
	}

	/* (non-Javadoc)
	 * @return
	 * @see com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getApplication()
	 */
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userInfoApplication;
	}

}
