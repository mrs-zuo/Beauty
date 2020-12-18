package com.GlamourPromise.Beauty.implementation;

import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;
import org.ksoap2.serialization.SoapObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountDetailInfo;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerAccountDetailDataTaskImpl implements IGetBackendServerDataTask{
	private static final String methodName = "getAccountDetail";
	private static final String methodParentName = "Account";
	
	private JSONObject mParamJson;
	private Handler mHandler;
	private AccountDetailInfo mAccountDetail;
	private UserInfoApplication userinfoApplication;
	public GetServerAccountDetailDataTaskImpl(JSONObject mParamJson, Handler handler, AccountDetailInfo accountDetail,UserInfoApplication userinfoApplication){
		this.mParamJson = mParamJson;
		mHandler = handler;
		mAccountDetail = accountDetail;
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
		return generateParamMap();
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			handleSoapObjectResult(resultJsonObject);
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		else
			msg.obj = resultObject.result;
		msg.sendToTarget();
	}
	
	private void handleSoapObjectResult(JSONObject contentJosnObject){
		mAccountDetail.setInfoByJsonObject(contentJosnObject);
	}

	private JSONObject generateParamMap(){
		return mParamJson;
	}

	/* (non-Javadoc)
	 * @return
	 * @see com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getApplication()
	 */
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
