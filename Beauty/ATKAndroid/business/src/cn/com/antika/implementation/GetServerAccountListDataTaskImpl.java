package cn.com.antika.implementation;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountDetailInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetServerAccountListDataTaskImpl implements IGetBackendServerDataTask {
	private static final String methodName = "getAccountListForCustomer";
	private static final String methodParentName = "account";
	
	private JSONObject mParamJson;
	private Handler mHandler;
	private UserInfoApplication userInfoApplication;
	public GetServerAccountListDataTaskImpl(JSONObject mParamJson, Handler handler,UserInfoApplication userInfoApplication){
		this.mParamJson=mParamJson;
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
			ArrayList<AccountDetailInfo> accountInfoList = new ArrayList<AccountDetailInfo>();
			JSONArray resultJsonArray = (JSONArray) resultObject.result;
			handleSoapObjectResult(resultJsonArray,accountInfoList);
			msg.obj = accountInfoList;
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		else
			msg.obj=resultObject.result;
		msg.sendToTarget();
	}

	private JSONObject generateParamMap(){
		return mParamJson;
	}
	
	private void handleSoapObjectResult(JSONArray resultJsonArray, ArrayList<AccountDetailInfo> accountInfoList){
		AccountDetailInfo branchInfo;
		for(int i = 0; i < resultJsonArray.length(); i++){
			branchInfo = new AccountDetailInfo();
			try {
				branchInfo.setInfoByJsonObject(resultJsonArray.getJSONObject(i));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			accountInfoList.add(branchInfo);
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
