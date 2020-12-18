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
import com.GlamourPromise.Beauty.bean.NoticeInfo;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerNoticeListDataTaskImpl implements IGetBackendServerDataTask{
	private static final String METHOD_NAME = "getNoticeList";
	private static final String METHOD_PARENT_NAME = "Notice";
	
	private JSONObject mJsonParam;
	private Handler mHandler;
	private UserInfoApplication userInfoApplication;
	public GetServerNoticeListDataTaskImpl(JSONObject mJsonParam, Handler handler,UserInfoApplication userInfoApplication){
		this.mJsonParam = mJsonParam;
		mHandler = handler;
		this.userInfoApplication=userInfoApplication;
	}
	
	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return METHOD_NAME;
	}

	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return METHOD_PARENT_NAME;
	}

	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		return generateParamMap();
	}
	
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = null;
		
		return paramJsonObject;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			ArrayList<NoticeInfo> noticeInfoList = new ArrayList<NoticeInfo>();
			JSONArray resultJsonArray = (JSONArray) resultObject.result;
			handleSoapObjectResult(resultJsonArray, noticeInfoList);
			msg.obj = noticeInfoList;
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		msg.sendToTarget();
	}
	
	private JSONObject generateParamMap(){
		return mJsonParam;
	}
	
	private void handleSoapObjectResult(JSONArray contentJsonArray, ArrayList<NoticeInfo> noticeInfoList){
		NoticeInfo noticeInfo;
		if(contentJsonArray!=null && contentJsonArray.length()!=0){
			for(int i = 0; i < contentJsonArray.length(); i++){
				noticeInfo = new NoticeInfo();
				JSONObject noticeJson=null;
				try {
					noticeJson=contentJsonArray.getJSONObject(i);
				} catch (JSONException e) {
				}
				noticeInfo.setInfoByJsonObject(noticeJson);
				noticeInfoList.add(noticeInfo);
			}
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
