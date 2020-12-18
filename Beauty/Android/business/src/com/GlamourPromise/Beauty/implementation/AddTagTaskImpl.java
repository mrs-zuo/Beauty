package com.GlamourPromise.Beauty.implementation;

import org.json.JSONException;
import org.json.JSONObject;
import android.os.Handler;
import android.os.Message;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class AddTagTaskImpl implements IGetBackendServerDataTask{
	private static final String METHOD_NAME = "addTag";
	private static final String METHOD_PARENT_NAME = "Tag";
	private String mCompanyID;
	private String mBranchID;
	private String mContent;
	private String mCreateID;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public AddTagTaskImpl(int companyID, int branchID, int createID, String content, Handler handler,UserInfoApplication userinfoApplication){
		mCompanyID = String.valueOf(companyID);
		mBranchID = String.valueOf(branchID);
		mCreateID = String.valueOf(createID);
		mContent = content;
		mHandler = handler;
		this.userinfoApplication=userinfoApplication;
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
		return getParamJsonObject();
	}
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = new JSONObject();
		try {
			paramJsonObject.put("CompanyID", mCompanyID);
			paramJsonObject.put("BranchID", mBranchID);
			paramJsonObject.put("Name", mContent);
			paramJsonObject.put("CreatorID", mCreateID);
			paramJsonObject.put("Type",1);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return paramJsonObject;
	}
	@Override
	public void handleResult(WebDataObject resultObject) {
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
//			msg.what = resultObject.code;
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		else
			msg.obj=resultObject.result;
		msg.sendToTarget();
	}
	
	public void setLabelContent(String Content){
		mContent = Content;
	}
	@Override
	public UserInfoApplication getApplication() {
		return userinfoApplication;
	}

}
