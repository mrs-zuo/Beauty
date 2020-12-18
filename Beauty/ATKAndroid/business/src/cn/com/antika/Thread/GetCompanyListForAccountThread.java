package cn.com.antika.Thread;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AccountInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;

public class GetCompanyListForAccountThread extends BaseThread{
	private Handler mHandler;
	private String methodName;
	private String methodParentName;
	private String mloginMobile;
	private String mPassword;
	private UserInfoApplication userinfoApplication;
	public GetCompanyListForAccountThread(String methodName, String methodParentName,Handler handler, String loginMobile, String password, int imageWidth, int imageHeight,UserInfoApplication userinfoApplication){
		this.methodName = methodName;
		this.methodParentName = methodParentName;
		mHandler = handler;
		mloginMobile = loginMobile;
		mPassword = password;
		this.userinfoApplication=userinfoApplication;
	}
	//参数转换成Json格式
	protected JSONObject getParamJsonObject(){
		JSONObject paramJsonObject = null;
		try {
			paramJsonObject = new JSONObject();
			paramJsonObject.put("LoginMobile",mloginMobile);
			paramJsonObject.put("Password",mPassword);
		} catch (JSONException e) {
		}
		return paramJsonObject;
	}

	@Override
	protected String getmethodName() {
		// TODO Auto-generated method stub
		return methodName;
	}

	@Override
	protected String getmethodParentName() {
		// TODO Auto-generated method stub
		return methodParentName;
	}
	@SuppressLint("NewApi")
	@Override
	protected void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			ArrayList<AccountInfo> accountInfoList = new ArrayList<AccountInfo>();
			AccountInfo accountInfo;
			try {
				JSONArray jsonArray = (JSONArray) resultObject.result;
				for(int i = 0; i < jsonArray.length(); i++){
					accountInfo = new AccountInfo();
					accountInfo.setBaseInfoByJson(jsonArray.getJSONObject(i),0);
					accountInfoList.add(accountInfo);
				}
				msg.obj = accountInfoList;
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				//解析数据出错
				msg.what =  Constant.PARSING_ERROR;
			}
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		//-3表示登陆时检测到当前版本需要强制升级
		else if(resultObject.code==-3){
			try {
				msg.obj=((JSONObject)resultObject.result).getString("Version");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				msg.obj="";
			}
		}
		msg.sendToTarget();
	}
	@Override
	protected UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
