package com.GlamourPromise.Beauty.application;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cn.jpush.android.api.JPushInterface;

import com.GlamourPromise.Beauty.Business.LoginActivity;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.RecordTemplate;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.handler.CrashHandler;
import com.baidu.mapapi.SDKInitializer;
import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.disc.naming.Md5FileNameGenerator;
import com.nostra13.universalimageloader.cache.memory.impl.UsingFreqLimitedMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.nostra13.universalimageloader.core.download.BaseImageDownloader;
import com.nostra13.universalimageloader.utils.StorageUtils;
import com.tencent.bugly.crashreport.CrashReport;

import android.app.ActivityManager;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
public class UserInfoApplication extends Application {
	private   AccountInfo accountInfo;
	private   OrderInfo orderInfo;
	// 保存订单列表中的customerID，用在更新服务效果
	private   int customerID;
	// 保存订单的ResponsiblePersonID
	private   int orderResponsiblePersonID;
	private   int orderCreatorID;
	// 选择后的客户信息
	private   int selectedCustomerID;
	private   int    selectedCustomerResponsiblePersonID;//选中顾客的专属顾问ID
	private   String selectedCustomerName;
	private   String selectedCustomerHeadImageURL;
	private   String selectedCustomerLoginMobile;
	private   boolean  selectedIsMyCustomer;
	private   double  customerEcardBblanceValue;
	private   int screenWidth;
	private   int screenHeight;
	//private List<Activity> liveActivitys;
	private  static UserInfoApplication instance;
	private  int codeTextSize;
	public   SharedPreferences accountInfoSharePreferences;
	private  int               accountNewMessageCount;
	private  int               accountNewRemindCount;
	private  long lastGetNewMessageTime;
	//private CrashHandler crashHandler;
	private boolean      needUpdateLoginInfo;
	private String       appVersion;
	private String       GUID;
	private String       rsaUserName;
	private String       rsaPassword;
	private boolean      isNormalLogin;
	private List<RecordTemplate> customerRecordTemplateTempList;//临时保存的专业模板列表
	public UserInfoApplication() {
		//liveActivitys = new LinkedList<Activity>();
		customerRecordTemplateTempList=new ArrayList<RecordTemplate>();
	}
	public static UserInfoApplication getInstance() {
		if (instance == null) {
			synchronized (UserInfoApplication.class) {
				if (instance == null) {
					instance = new UserInfoApplication();
				}
			}
		}
		return instance;
	}
	
	public AccountInfo getAccountInfo() {
		if(accountInfo==null){
			accountInfo=new AccountInfo();
			if(accountInfoSharePreferences==null)
				accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
			setConstantFlag();
			Constant.formalFlag=accountInfoSharePreferences.getInt("fromFlag",0);
			int loginAccountInfoPosition = accountInfoSharePreferences.getInt("loginInfoPosition",0);
			int loginBranchPosition = accountInfoSharePreferences.getInt("loginInfoBranchPosition",0);
			try {
				String localAccountString=accountInfoSharePreferences.getString("accountInfoList","");
				if(localAccountString!=null && !("").equals(localAccountString)){
					//账户信息
					JSONArray accountInfoJSONArray = new JSONArray(localAccountString);
					JSONObject accountInfoJSONObject = new JSONObject(accountInfoJSONArray.getString(loginAccountInfoPosition));
					accountInfo.setBaseInfoByJson(accountInfoJSONObject, loginBranchPosition);
				}
				String localPermissionString=accountInfoSharePreferences.getString("accountPermissionInfo","");
				if(localPermissionString!=null && !("").equals(localPermissionString)){
					//权限信息
					JSONObject accountPermissionInfoJSONObject = new JSONObject(accountInfoSharePreferences.getString("accountPermissionInfo",""));
					accountInfo.setPermissionInfoByJson(accountPermissionInfoJSONObject);
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		return accountInfo;
	}
	
	public ArrayList<AccountInfo> getAccountInfoList() {
		ArrayList<AccountInfo> accountInfoList = new ArrayList<AccountInfo>();
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		Constant.formalFlag=accountInfoSharePreferences.getInt("fromFlag",0);
		try {
			JSONArray accountInfoJSONArray = new JSONArray(accountInfoSharePreferences.getString("accountInfoList",""));
			JSONObject accountInfoJSONObject;
			AccountInfo accountInfo;
			for(int i = 0; i < accountInfoJSONArray.length(); i++){
				accountInfoJSONObject = new JSONObject(accountInfoJSONArray.getString(i));
				accountInfo = new AccountInfo();
				accountInfo.setBaseInfoByJson(accountInfoJSONObject, 0);
				accountInfoList.add(accountInfo);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return accountInfoList;
	}
	
	public ArrayList<ArrayList<BranchInfo>> getLoginBranchList(){
		ArrayList<ArrayList<BranchInfo>> branchList = new ArrayList<ArrayList<BranchInfo>>();
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		Constant.formalFlag=accountInfoSharePreferences.getInt("fromFlag",0);
		try {
			JSONArray accountInfoJSONArray = new JSONArray(accountInfoSharePreferences.getString("accountInfoList",""));
			JSONObject accountInfoJSONObject;
			JSONArray branchInfoJSONObject;
			BranchInfo branchInfo;
			ArrayList<BranchInfo> tmp;
			for(int i = 0; i < accountInfoJSONArray.length(); i++){
				tmp = new ArrayList<BranchInfo>();
				accountInfoJSONObject = new JSONObject(accountInfoJSONArray.getString(i));
				if(accountInfoJSONObject.has("BranchList") && !accountInfoJSONObject.isNull("BranchList")){
					branchInfoJSONObject = accountInfoJSONObject.getJSONArray("BranchList");
					for(int j = 0; j < branchInfoJSONObject.length(); j++){
						branchInfo = new BranchInfo();
						branchInfo.setId(branchInfoJSONObject.getJSONObject(j).getString("BranchID"));
						branchInfo.setName(branchInfoJSONObject.getJSONObject(j).getString("BranchName"));
						tmp.add(branchInfo);
					}
				}
				branchList.add(tmp);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return branchList;
		
	}
	
	public void setAccountHeadImage(String imageUrl){
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		Constant.formalFlag=accountInfoSharePreferences.getInt("fromFlag",0);
		int loginAccountInfoPosition = accountInfoSharePreferences.getInt("loginInfoPosition",0);
		try {
			//基本信息
			JSONArray accountInfoJSONArray = new JSONArray(accountInfoSharePreferences.getString("accountInfoList",""));
			JSONObject accountInfoJSONObject = new JSONObject(accountInfoJSONArray.getString(loginAccountInfoPosition));
			accountInfoJSONObject.put("HeadImageURL", imageUrl);
			accountInfoJSONArray.put(loginAccountInfoPosition, accountInfoJSONObject);
			Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
			editor.putString("accountInfoList", accountInfoJSONArray.toString());
			editor.commit();// 提交修改
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public int getAccountInfoListSize(){
		JSONArray accountInfoJSONArray = null;
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		try {
			accountInfoJSONArray = new JSONArray(accountInfoSharePreferences.getString("accountInfoList",""));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(accountInfoJSONArray != null)
			return accountInfoJSONArray.length();
		else
			return 0;
	}

	public void setAccountInfo(AccountInfo accountInfo) {
		this.accountInfo = accountInfo;
	}
	
	public void setAccountInfoPosition(int position, int branchPosition){
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putInt("loginInfoPosition", position);
		editor.putInt("loginInfoBranchPosition", branchPosition);
		editor.commit();// 提交修改
	}
	
	public void setAccountInfoList(JSONArray accountInfoList){
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("accountInfoList", accountInfoList.toString());
		editor.commit();// 提交修改
	}
	
	public void setPermissionInfo(JSONObject permissionInfo){
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("accountPermissionInfo", permissionInfo.toString());
		editor.commit();// 提交修改
	}
	
	public void setConstantFlag(){
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();
		editor.putInt("fromFlag",Constant.formalFlag);
		editor.commit();
	}

	public OrderInfo getOrderInfo() {
		return orderInfo;
	}

	public void setOrderInfo(OrderInfo orderInfo) {
		this.orderInfo = orderInfo;
	}

	public int getCustomerID() {
		return customerID;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}

	public int getSelectedCustomerID() {
		return selectedCustomerID;
	}

	public String getSelectedCustomerName() {
		return selectedCustomerName;
	}

	public void setSelectedCustomerID(int selectedCustomerID) {
		this.selectedCustomerID = selectedCustomerID;
	}
	
	public int getSelectedCustomerResponsiblePersonID() {
		return selectedCustomerResponsiblePersonID;
	}
	public void setSelectedCustomerResponsiblePersonID(
			int selectedCustomerResponsiblePersonID) {
		this.selectedCustomerResponsiblePersonID = selectedCustomerResponsiblePersonID;
	}
	public void setSelectedCustomerName(String selectedCustomerName) {
		this.selectedCustomerName = selectedCustomerName;
	}

	public String getSelectedCustomerLoginMobile() {
		return selectedCustomerLoginMobile;
	}
	public void setSelectedCustomerLoginMobile(String selectedCustomerLoginMobile) {
		this.selectedCustomerLoginMobile = selectedCustomerLoginMobile;
	}
	public String getSelectedCustomerHeadImageURL() {
		return selectedCustomerHeadImageURL;
	}

	public void setSelectedCustomerHeadImageURL(
			String selectedCustomerHeadImageURL) {
		this.selectedCustomerHeadImageURL = selectedCustomerHeadImageURL;
	}

	public boolean isNormalLogin() {
		return isNormalLogin;
	}
	public void setNormalLogin(boolean isNormalLogin) {
		this.isNormalLogin = isNormalLogin;
	}
	public int getScreenWidth() {
		if(screenWidth==0){
			screenWidth=accountInfoSharePreferences.getInt("screenWidth",0);
		}
		return screenWidth;
	}

	public int getScreenHeight() {
		if(screenHeight==0){
			screenHeight=accountInfoSharePreferences.getInt("screenHeight",0);
		}
		return screenHeight;
	}

	public void setScreenWidth(int screenWidth) {
		this.screenWidth = screenWidth;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putInt("screenWidth", screenWidth);
		editor.commit();
	}

	public void setScreenHeight(int screenHeight) {
		this.screenHeight = screenHeight;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putInt("screenHeight", screenHeight);
		editor.commit();
	}

	public int getOrderResponsiblePersonID() {
		return orderResponsiblePersonID;
	}

	public void setOrderResponsiblePersonID(int orderResponsiblePersonID) {
		this.orderResponsiblePersonID = orderResponsiblePersonID;
	}

	public int getOrderCreatorID() {
		return orderCreatorID;
	}

	public void setOrderCreatorID(int orderCreatorID) {
		this.orderCreatorID = orderCreatorID;
	}
	public boolean getSelectedIsMyCustomer() {
		return selectedIsMyCustomer;
	}

	public boolean isNeedUpdateLoginInfo() {
		return needUpdateLoginInfo;
	}
	public void setNeedUpdateLoginInfo(boolean needUpdateLoginInfo) {
		this.needUpdateLoginInfo = needUpdateLoginInfo;
	}


	public void setSelectedIsMyCustomer(boolean selectedIsMyCustomer) {
		this.selectedIsMyCustomer = selectedIsMyCustomer;
	}
	

	public int getCodeTextSize() {
		if(codeTextSize==0){
			codeTextSize=accountInfoSharePreferences.getInt("codeTextSize",0);
		}
		return codeTextSize;
	}

	public void setCodeTextSize(int codeTextSize) {
		this.codeTextSize = codeTextSize;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putInt("codeTextSize", codeTextSize);
		editor.commit();
	}


	public double getCustomerEcardBblanceValue() {
		return customerEcardBblanceValue;
	}

	public void setCustomerEcardBblanceValue(double customerEcardBblanceValue) {
		this.customerEcardBblanceValue = customerEcardBblanceValue;
	}

	// 遍历所有Activity并finish
	public void exit(Context currentActivity) {
		JPushInterface.stopPush(getApplicationContext());
		clearLoginInformation();
		ActivityManager manager = (ActivityManager) this.getSystemService(Context.ACTIVITY_SERVICE); 
		List<ActivityManager.RunningTaskInfo> tasks = manager.getRunningTasks(1);
		ComponentName baseActivity = tasks.get(0).baseActivity;
		Intent intent = new Intent();
		intent.setComponent(baseActivity);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		intent.putExtra("exit", "1");
		currentActivity.startActivity(intent);
	}
	// 登出
	public void exitForLogin(Context currentActivity) {
		clearLoginInformation();
		Intent destIntent = new Intent(this, LoginActivity.class);
		if (currentActivity != null) {
			exit(currentActivity);
			currentActivity.startActivity(destIntent);
		} else {
			this.startActivity(destIntent);
		}
	}
	//清除登陆信息
	private void clearLoginInformation(){
		if(customerRecordTemplateTempList!=null && customerRecordTemplateTempList.size()>0)
			customerRecordTemplateTempList.clear();
		setAccountInfo(null);
		setSelectedCustomerID(0);
		setSelectedCustomerName("");
		setSelectedCustomerHeadImageURL("");
		setSelectedCustomerLoginMobile("");
		setOrderInfo(null);
		setAccountNewMessageCount(0);
		setAccountNewRemindCount(0);
		Constant.formalFlag = 0;
		Editor editor=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();
		editor.remove("accountPermissionInfo");
		editor.remove("accountInfoList");
		editor.remove("loginInfoPosition");
		editor.commit();
	}
	public int getAccountNewMessageCount() {
		return accountNewMessageCount;
	}

	public void setAccountNewMessageCount(int accountNewMessageCount) {
		this.accountNewMessageCount = accountNewMessageCount;
	}
	
	public long getLastGetNewMessageTime() {
		return lastGetNewMessageTime;
	}

	public void setLastGetNewMessageTime(long lastGetNewMessageTime) {
		this.lastGetNewMessageTime = lastGetNewMessageTime;
	}
	public int getAccountNewRemindCount() {
		return accountNewRemindCount;
	}

	public void setAccountNewRemindCount(int accountNewRemindCount) {
		this.accountNewRemindCount = accountNewRemindCount;
	}
	public List<RecordTemplate> getCustomerRecordTemplateTempList() {
		return customerRecordTemplateTempList;
	}
	public void setCustomerRecordTemplateTempList(
			List<RecordTemplate> customerRecordTemplateTempList) {
		this.customerRecordTemplateTempList = customerRecordTemplateTempList;
	}
	public String getAppVersion() {
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		appVersion=accountInfoSharePreferences.getString("appVersion","");
		return appVersion;
	}
	public void setAppVersion(String appVersion) {
		this.appVersion = appVersion;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("appVersion",appVersion);
		editor.commit();
	}
	
	public String getGUID() {
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		GUID=accountInfoSharePreferences.getString("GUID","");
		return GUID;
	}
	public void setGUID(String gUID) {
		GUID = gUID;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("GUID",gUID);
		editor.commit();
	}
	public String getRsaUserName() {
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		rsaUserName=accountInfoSharePreferences.getString("rsaUserName","");
		return rsaUserName;
	}
	public void setRsaUserName(String rsaUserName) {
		this.rsaUserName = rsaUserName;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("rsaUserName",rsaUserName);
		editor.commit();
	}
	public String getRsaPassword() {
		if(accountInfoSharePreferences==null)
			accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		rsaPassword=accountInfoSharePreferences.getString("rsaPassword","");
		return rsaPassword;
	}
	public void setRsaPassword(String rsaPassword) {
		this.rsaPassword = rsaPassword;
		Editor editor = getSharedPreferences("AccountInfo",Context.MODE_PRIVATE).edit();// 获取编辑器
		editor.putString("rsaPassword",rsaPassword);
		editor.commit();
	}
	private  static void  initImageLoader(Context applicationContext){
		File imageCacheDIR=StorageUtils.getOwnCacheDirectory(applicationContext,"image/cache");
		//Log.v("ImageCache",imageCacheDIR.getAbsolutePath());
		ImageLoaderConfiguration imageLoaderConfig=new ImageLoaderConfiguration.Builder(applicationContext).memoryCacheExtraOptions(800,800).threadPoolSize(3).threadPriority(Thread.NORM_PRIORITY-2)
				.denyCacheImageMultipleSizesInMemory().memoryCache(new UsingFreqLimitedMemoryCache(2*1024*1024)).memoryCacheSize(2*1024*1024).discCacheSize(50*1024*1024).discCacheFileNameGenerator(new Md5FileNameGenerator())
				.tasksProcessingOrder(QueueProcessingType.LIFO).discCacheFileCount(100).discCache(new UnlimitedDiscCache(imageCacheDIR)).defaultDisplayImageOptions(DisplayImageOptions.createSimple()).imageDownloader(new BaseImageDownloader(applicationContext, 5*1000, 30*1000)).build();
		ImageLoader.getInstance().init(imageLoaderConfig);
	}
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		SDKInitializer.initialize(this);  
		instance=this;
		accountInfoSharePreferences=getSharedPreferences("AccountInfo",Context.MODE_PRIVATE);
		lastGetNewMessageTime = 0;
		needUpdateLoginInfo=false;
		initImageLoader(getApplicationContext());
		//自定义APP闪退处理程序
		CrashHandler.getInstance().init();
		/*
		 * CrashHandler crashHandler= CrashHandler.getInstance();
		 * Thread.setDefaultUncaughtExceptionHandler(crashHandler);
		 */
		// bugly(appid:4801ef7d10)
		CrashReport.initCrashReport(getApplicationContext(), "4801ef7d10", false);
	}
}
