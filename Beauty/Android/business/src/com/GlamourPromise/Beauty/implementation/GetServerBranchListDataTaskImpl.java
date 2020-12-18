package com.GlamourPromise.Beauty.implementation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.ksoap2.serialization.SoapObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerBranchListDataTaskImpl implements IGetBackendServerDataTask{
	private static final String methodName = "GetBranchList";
	private static final String methodParentName = "Company";
	private JSONObject  jsonParam;
	private Handler mHandler;
	private UserInfoApplication userInfoApplication;
	public GetServerBranchListDataTaskImpl(JSONObject jsonParam, Handler handler,UserInfoApplication userInfoApplication){
		this.jsonParam=jsonParam;
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
		return generateParamJson();
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			ArrayList<BranchInfo> branchInfoList = new ArrayList<BranchInfo>();
			JSONArray resultJsonObject = (JSONArray)resultObject.result;
			handleJsonObjectResult(resultJsonObject,branchInfoList);
			msg.obj = branchInfoList;
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		msg.sendToTarget();
	}
	
	private JSONObject generateParamJson(){
		return jsonParam;
	}
	
	private void handleJsonObjectResult(JSONArray contentJsonArray, ArrayList<BranchInfo> branchInfoList){
		BranchInfo branchInfo;
		JSONArray resultJsonArray = (JSONArray)contentJsonArray;
		for(int i = 0; i < resultJsonArray.length(); i++){
			branchInfo = new BranchInfo();
			try {
				branchInfo.setListInfoByJsonObject(resultJsonArray.getJSONObject(i));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				branchInfo.setListInfoByJsonObject(null);
			}
			branchInfoList.add(branchInfo);
		}
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
