package cn.com.antika.Thread;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Handler;
import android.os.Message;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;

public class UpdateLoginInfoForAccountThread extends BaseThread{
	private static final String methodName = "updateLoginInfo";
	private static final String methodParentName = "Login";
	private Handler mHandler;
	private String mDeviceID;
	private UserInfoApplication userinfoApplication;
	public UpdateLoginInfoForAccountThread(Handler handler, String deviceID,UserInfoApplication userinfoApplication){
		mHandler = handler;
		mDeviceID = deviceID;
		this.userinfoApplication=userinfoApplication;
	}

	@Override
	protected JSONObject getParamJsonObject() {
		// TODO Auto-generated method stub
		JSONObject paramJsonObject = null;
		try {
			paramJsonObject = new JSONObject();
			paramJsonObject.put("DeviceID", mDeviceID);
			//操作系统版本
			paramJsonObject.put("OSVersion",android.os.Build.VERSION.RELEASE);
			paramJsonObject.put("LoginMobile",userinfoApplication.getRsaUserName());
			paramJsonObject.put("Password",userinfoApplication.getRsaPassword());
			//手机型号
			paramJsonObject.put("DeviceModel",android.os.Build.MODEL);
			//当前账号的登陆信息
			paramJsonObject.put("CompanyID",userinfoApplication.getAccountInfo().getCompanyId());
			paramJsonObject.put("BranchID",userinfoApplication.getAccountInfo().getBranchId());
			paramJsonObject.put("UserID",userinfoApplication.getAccountInfo().getAccountId());
			paramJsonObject.put("ClientType",Constant.CLIENT_TYPE_BUSINESS);
			paramJsonObject.put("DeviceType",Constant.DEVICE_ANDROID);
			paramJsonObject.put("APPVersion",userinfoApplication.getAppVersion());
			paramJsonObject.put("IsNormalLogin",userinfoApplication.isNormalLogin());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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

	@Override
	protected void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		//获取得到数据
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			
			msg.what = 6;
			msg.obj = (JSONObject) resultObject.result;
		}else if((resultObject.code == Constant.GET_WEB_DATA_FALSE) || (resultObject.code == Constant.GET_WEB_DATA_EXCEPTION)){
			msg.obj = resultObject.result;
		}
		msg.sendToTarget();
	}

	@Override
	protected UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
