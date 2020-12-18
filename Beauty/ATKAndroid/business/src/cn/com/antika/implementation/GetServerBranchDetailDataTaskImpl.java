package cn.com.antika.implementation;

import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.BranchInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerBranchDetailDataTaskImpl implements IGetBackendServerDataTask {
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
