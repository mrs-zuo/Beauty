package com.glamourpromise.beauty.customer.application;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.client.HttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.Application;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;
import cn.jpush.android.api.JPushInterface;
import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.mapapi.SDKInitializer;
import com.glamourpromise.beauty.customer.bean.LoginInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.ConnectionManager;
import com.glamourpromise.beauty.customer.net.WebApiConnectHelper;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.presenter.ServicePresenter;
import com.glamourpromise.beauty.customer.util.FileCache;
import com.glamourpromise.beauty.customer.util.RSAUtil;
import com.glamourpromise.beauty.customer.util.ThreadExecutor;

public class UserInfoApplication extends Application {
	private LoginInformation mLoginInformation;
	private Integer formalFlag = null;// true:正式用户；false:测试用户
	private int mScreenWidth;
	private int mScreedHeight;
	private SharedPreferences sharedata;
	private long lastGetNewMessageTime;
	private FileCache fileCache;
	private Boolean isNeedUpdateLogin;
	private Boolean isExit;
	private String mGUID;
	private String mAppVersion;
	private ThreadExecutor mExecutor;
	public LocationClient mLocationClient;
    public MyLocationListener mMyLocationListener;
	private WebApiConnectHelper mWebConnect;
	private HttpClient mHttpClient;
	private boolean    isNormalLogin;
	@Override
	public void onCreate() {
		super.onCreate();
		//百度地图初始化
		SDKInitializer.initialize(this);
		sharedata = getSharedPreferences("customerInformation",Context.MODE_PRIVATE);
		lastGetNewMessageTime = 0;
		mScreenWidth = 720;
		mScreedHeight = 1280;
		isNeedUpdateLogin = false;
		isExit = false;

		mHttpClient =  ConnectionManager.getNewHttpClient();
		
		mWebConnect = new WebApiConnectHelper(getApplicationContext(), mHttpClient);
		mWebConnect.start();
		mWebConnect.getLooper();		
		
		mAppVersion = getPackageVersion();
		mLocationClient = new LocationClient(this.getApplicationContext());
        mMyLocationListener = new MyLocationListener();
        mLocationClient.registerLocationListener(mMyLocationListener);
		formalFlag = sharedata.getInt("formalFlag", 0);
		mGUID = sharedata.getString("GUID", "");
	}
	/**
     * 实现实时位置回调监听
     */
    public class MyLocationListener implements BDLocationListener {

        @Override
        public void onReceiveLocation(BDLocation location) {
            //Receive Location
            StringBuffer sb = new StringBuffer(256);
            sb.append("time : ");
            sb.append(location.getTime());
            sb.append("\nerror code : ");
            sb.append(location.getLocType());
            sb.append("\nlatitude : ");
            sb.append(location.getLatitude());
            sb.append("\nlontitude : ");
            sb.append(location.getLongitude());
            sb.append("\nradius : ");
            sb.append(location.getRadius());
            if (location.getLocType() == BDLocation.TypeGpsLocation){// GPS定位结果
                sb.append("\nspeed : ");
                sb.append(location.getSpeed());// 单位：公里每小时
                sb.append("\nsatellite : ");
                sb.append(location.getSatelliteNumber());
                sb.append("\nheight : ");
                sb.append(location.getAltitude());// 单位：米
                sb.append("\ndirection : ");
                sb.append(location.getDirection());
                sb.append("\naddr : ");
                sb.append(location.getAddrStr());
                sb.append("\ndescribe : ");
                sb.append("gps定位成功");

            } else if (location.getLocType() == BDLocation.TypeNetWorkLocation){// 网络定位结果
                sb.append("\naddr : ");
                sb.append(location.getAddrStr());
                //运营商信息
                sb.append("\noperationers : ");
                sb.append(location.getOperators());
                sb.append("\ndescribe : ");
                sb.append("网络定位成功");
            } else if (location.getLocType() == BDLocation.TypeOffLineLocation) {// 离线定位结果
                sb.append("\ndescribe : ");
                sb.append("离线定位成功，离线定位结果也是有效的");
            } else if (location.getLocType() == BDLocation.TypeServerError) {
                sb.append("\ndescribe : ");
                sb.append("服务端网络定位失败，可以反馈IMEI号和大体定位时间到loc-bugs@baidu.com，会有人追查原因");
            } else if (location.getLocType() == BDLocation.TypeNetWorkException) {
                sb.append("\ndescribe : ");
                sb.append("网络不同导致定位失败，请检查网络是否通畅");
            } else if (location.getLocType() == BDLocation.TypeCriteriaException) {
                sb.append("\ndescribe : ");
                sb.append("无法获取有效定位依据导致定位失败，一般是由于手机的原因，处于飞行模式下一般会造成这种结果，可以试着重启手机");
            }
            Log.i("BaiduLocationApiDem", sb.toString());
           // mLocationClient.setEnableGpsRealTimeTransfer(true);
        }


    }
	public ThreadExecutor getThreadExecutor(){
		if(mExecutor == null){
			mExecutor = new ThreadExecutor();
		}
		return mExecutor;
	}
		
	public HttpClient getHttpClient() {
		return mHttpClient;
	}

	public WebApiConnectHelper getConnect(){
		return mWebConnect;
	}
	
	@SuppressLint("DefaultLocale")
	public WebApiHttpHead createNeededCheckingWebConnectHead(String catoryName, String methodName, String para){
		LoginInformation tmp = getLoginInformation();
		WebApiHttpHead header;
		if(tmp != null)
			header = WebApiHttpHead.obtainNeededCheckHead(tmp.getCompanyID(), tmp.getCustomerID(), mGUID, catoryName, methodName, para, formalFlag, mAppVersion);
		else
			header = null;
		return header;
	}
	
	public WebApiHttpHead createNotNeededCheckingWebConnectHead(String methodName){
		WebApiHttpHead header = WebApiHttpHead.obtainNotNeededCheckHead(methodName, formalFlag, mAppVersion);
		return header;
	}

	public Boolean getIsNeedUpdateLogin() {
		return isNeedUpdateLogin;
	}

	public void setIsNeedUpdateLogin(Boolean isNeedUpdateLogin) {
		this.isNeedUpdateLogin = isNeedUpdateLogin;
	}
	
	public Boolean getIsExit() {
		return isExit;
	}

	public void setIsExit(Boolean isExit) {
		this.isExit = isExit;
	}

	/**
	 * 当前用户类型：正式用户、内网用户、测试用户
	 * @return
	 */
	public Integer isFormalFlag() {
		return formalFlag;
	}

	public void setFormalFlag(Integer formalFlag) {
		this.formalFlag = formalFlag;
	}
	
	public void setGUID(String guid){
		Editor editor = sharedata.edit();// 获取编辑器
		editor.putString("GUID", guid);
		editor.commit();// 提交修改
		mGUID = guid;
	}
	
	public String getGUID(){
		return mGUID;
	}

	public void setCompanyList(String strCompanyList) {
		Editor editor = sharedata.edit();// 获取编辑器
		editor.putString("companySelectList",strCompanyList);
		editor.commit();// 提交修改
	}

	public List<LoginInformation> getCompanyList(Context activity) {
		// 数据如果被回收则重新从SharedPreferences中恢复
		List<LoginInformation> loginInformationList = new ArrayList<LoginInformation>();
		String stringCompany = sharedata.getString("companySelectList", "");
		loginInformationList = new ArrayList<LoginInformation>();
		JSONArray companyListJson;
		try {
			companyListJson = new JSONArray(stringCompany);
			for (int i = 0; i < companyListJson.length(); i++) {
				LoginInformation loginInformation = new LoginInformation();
				JSONObject companyItemJson = companyListJson.getJSONObject(i);
				if (companyItemJson.has("CustomerID"))
					loginInformation.setCustomerID(companyItemJson
							.getString("CustomerID"));
				if (companyItemJson.has("CustomerName"))
					loginInformation.setCustomerName(companyItemJson
							.getString("CustomerName"));
				if (companyItemJson.has("CompanyName"))
					loginInformation.setCompanyName(companyItemJson
							.getString("CompanyName"));
				if (companyItemJson.has("CompanyCode"))
					loginInformation.setCompanyCode(companyItemJson
							.getString("CompanyCode"));
				if (companyItemJson.has("CompanyID"))
					loginInformation.setCompanyID(companyItemJson
							.getString("CompanyID"));
				if (companyItemJson.has("CompanyAbbreviation"))
					loginInformation.setCompanyAbbreviation(companyItemJson
							.getString("CompanyAbbreviation"));
				if (companyItemJson.has("BranchID"))
					loginInformation.setBranchID(companyItemJson
							.getString("BranchID"));
				if (companyItemJson.has("BranchCount"))
					loginInformation.setBranchCount(companyItemJson
							.getString("BranchCount"));
				if (companyItemJson.has("HeadImageURL"))
					loginInformation.setHeadImageURL(companyItemJson
							.getString("HeadImageURL"));
				if (companyItemJson.has("PromotionCount"))
					loginInformation.setPromotionCount(companyItemJson
							.getString("PromotionCount"));
				if (companyItemJson.has("Advanced"))
					loginInformation.setCompanyScale(companyItemJson
							.getString("Advanced"));
				if (companyItemJson.has("Discount"))
					loginInformation.setDisCount(companyItemJson
							.getString("Discount"));
				if (companyItemJson.has("CurrencySymbol"))
					loginInformation.setCurrencySymbols(companyItemJson.getString("CurrencySymbol"));
				loginInformationList.add(loginInformation);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		return loginInformationList;
	}

	// 设置登录信息
	public void setLoginInformation(LoginInformation loginInformation, int position) {
		Editor editor = sharedata.edit();// 获取编辑器
		editor.putInt("loginInfoPosition",position);
		editor.commit();// 提交修改
		this.mLoginInformation = loginInformation;
	}

	// 返回当前登陆信息
	public LoginInformation getLoginInformation() {
		if(mLoginInformation == null){
			mLoginInformation = getLoginInfoFromSharePref();
		}
		return mLoginInformation;
	}
	
	public void removeCurrentLoginData(){
		mLoginInformation = null;
	}
	
	private LoginInformation getLoginInfoFromSharePref(){
		LoginInformation loginInformation = new LoginInformation();
		int loginInfoPosition = sharedata.getInt("loginInfoPosition", 0);
		String stringCompany = sharedata.getString("companySelectList", "");
		JSONArray companyListJson;
		try {
			companyListJson = new JSONArray(stringCompany);
			JSONObject companyItemJson = companyListJson
					.getJSONObject(loginInfoPosition);
			if (companyItemJson.has("CustomerID"))
				loginInformation.setCustomerID(companyItemJson
						.getString("CustomerID"));
			if (companyItemJson.has("CustomerName"))
				loginInformation.setCustomerName(companyItemJson
						.getString("CustomerName"));
			if (companyItemJson.has("CompanyName"))
				loginInformation.setCompanyName(companyItemJson
						.getString("CompanyName"));
			if (companyItemJson.has("CompanyCode"))
				loginInformation.setCompanyCode(companyItemJson
						.getString("CompanyCode"));
			if (companyItemJson.has("CompanyID"))
				loginInformation.setCompanyID(companyItemJson
						.getString("CompanyID"));
			if (companyItemJson.has("CompanyAbbreviation"))
				loginInformation.setCompanyAbbreviation(companyItemJson
						.getString("CompanyAbbreviation"));
			if (companyItemJson.has("BranchID"))
				loginInformation.setBranchID(companyItemJson
						.getString("BranchID"));
			if (companyItemJson.has("BranchCount"))
				loginInformation.setBranchCount(companyItemJson
						.getString("BranchCount"));
			if (companyItemJson.has("HeadImageURL"))
				loginInformation.setHeadImageURL(companyItemJson
						.getString("HeadImageURL"));
			if (companyItemJson.has("PromotionCount"))
				loginInformation.setPromotionCount(companyItemJson
						.getString("PromotionCount"));
			if (companyItemJson.has("Advanced"))
				loginInformation.setCompanyScale(companyItemJson
						.getString("Advanced"));
			if (companyItemJson.has("Discount"))
				loginInformation.setDisCount(companyItemJson
						.getString("Discount"));
			if (companyItemJson.has("CurrencySymbols"))
				loginInformation.setCurrencySymbols(companyItemJson
						.getString("CurrencySymbols"));
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return loginInformation;
	}

	public int getCompanyCount() {
		String stringCompany = sharedata.getString("companySelectList", "");
		JSONArray companyListJson = null;
		try {
			companyListJson = new JSONArray(stringCompany);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return 0;
		}
		return companyListJson.length();
	}

	public void setLoginExtraInformation(String loginAccount,
			String loginPassword, Integer formalFlag) {
		Editor editor = sharedata.edit();// 获取编辑器
		if (loginAccount != null)
			editor.putString("lastLoginAccount",loginAccount);
		if (loginPassword != null)
			editor.putString("lastLoginPassword",RSAUtil.encrypt(loginPassword));
		if (formalFlag != null)
			editor.putInt("formalFlag", formalFlag);
		editor.commit();// 提交修改
	}

	public int getScreenWidth() {
		return mScreenWidth;
	}

	public void setScreenWidth(int mScreenWidth) {
		this.mScreenWidth = mScreenWidth;
	}

	public int getScreedHeight() {
		return mScreedHeight;
	}

	public void setScreedHeight(int mScreedHeight) {
		this.mScreedHeight = mScreedHeight;
	}

	public long getLastGetNewMessageTime() {
		return lastGetNewMessageTime;
	}

	public void setLastGetNewMessageTime(long lastGetNewMessageTime) {
		this.lastGetNewMessageTime = lastGetNewMessageTime;
	}
	public boolean isNormalLogin() {
		return isNormalLogin;
	}

	public void setNormalLogin(boolean isNormalLogin) {
		this.isNormalLogin = isNormalLogin;
	}

	public FileCache getfileCache() {
		if (fileCache == null) {
			fileCache = new FileCache(getApplicationContext());
		}
		return fileCache;

	}
	
	public SharedPreferences getSharedPreferences(){
		return sharedata;
	}

	/**
	 * 退出应用程序
	 */
	public void AppExit(Context activity) {
//		cancelExecutor();
		isExit = true;
		// 停止推送服务
		JPushInterface.stopPush(getApplicationContext());
		// 清除通知栏消息
		removeNotification();
		restPresenter();
		turnToStackBaseActivity(activity, "1");
	}
	
	public void AppExitToLoginActivity(Context activity) {
		isExit = true;
		cancelExecutor();
		// 停止推送服务
		JPushInterface.stopPush(getApplicationContext());
		// 清除通知栏消息
		removeNotification();
		clearLoginData();
		restPresenter();
		turnToStackBaseActivity(activity, "3");
	}
	
	public void cancelExecutor(){
		if(mExecutor!=null)
			mExecutor.cancelAllTask();
		if(mWebConnect!=null)
			mWebConnect.cancelAllTask();
	}
	
	public void clearLoginData(){
		// 清除登陆数据
		formalFlag = 0;
		Editor editor = sharedata.edit();// 获取编辑器
		editor.putString("lastLoginPassword","");
		editor.commit();// 提交修改

	}
	
	public void restPresenter(){
		LeftMenuPresenter.reset();
		ServicePresenter.reset();
	}
	
	public void removeNotification(){
		NotificationManager notificationManager = (NotificationManager) this.getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.cancelAll();
	}

	public void turnToStackBaseActivity(Context activity, String exitFlag) {
		// 跳转到栈底的Activity
		ActivityManager manager = (ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE);
		List<ActivityManager.RunningTaskInfo> tasks = manager.getRunningTasks(1);
		ComponentName baseActivity = tasks.get(0).baseActivity;
		Intent intent = new Intent();
		intent.setComponent(baseActivity);
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		intent.putExtra("exit", exitFlag);
		activity.startActivity(intent);
	}


	public void installApk(Context context) {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setDataAndType(Uri.fromFile(fileCache.getFileWithType(Constant.APK_FILE_NAME, ".apk")),"application/vnd.android.package-archive");
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(intent);
	}

	// 取得版本信息
	public String getPackageVersion() {
		String version = "";
		try {
			PackageManager pm = getPackageManager();
			PackageInfo pi = null;
			pi = pm.getPackageInfo(getPackageName(), 0);
			version = pi.versionName;
		} catch (Exception e) {
			version = ""; // failed, ignored
		}
		return version;
	}
}
