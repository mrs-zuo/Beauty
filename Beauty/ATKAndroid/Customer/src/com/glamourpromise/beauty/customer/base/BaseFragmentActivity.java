package com.glamourpromise.beauty.customer.base;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.View.OnClickListener;
import cn.jpush.android.api.JPushInterface;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.activity.CompanySelectActivity;
import com.glamourpromise.beauty.customer.activity.LoginActivity;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.LoginInformation;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask.DownFileTaskProgressCallback;
import com.glamourpromise.beauty.customer.managerService.DownLoadFileManager;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiConnectHelper;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.RandomUUID;
import com.glamourpromise.beauty.customer.view.IBaseView;

@SuppressLint("Registered")
public abstract class BaseFragmentActivity extends FragmentActivity implements OnClickListener, IBaseView{
	protected static UserInfoApplication mApp;
	private ProgressDialog progressDialog;
	private static WebApiConnectHelper mNetConnect;
	protected LoginInformation mLogInInfo;
	protected String mCustomerID;
	protected String mCompanyID;
	protected String mCompanyCode;
	protected String mBranchID;
	protected int  mScreenWidth;
	private static BaseWebApiTask baseTask;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		mApp = (UserInfoApplication)getApplication();
		mLogInInfo = mApp.getLoginInformation();
		mCustomerID = mLogInInfo.getCustomerID();
		mCompanyID = mLogInInfo.getCompanyID();
		mCompanyCode = mLogInInfo.getCompanyCode();
		mBranchID = mLogInInfo.getBranchID();
		mScreenWidth = mApp.getScreenWidth();
		mNetConnect = mApp.getConnect();
		baseTask = new BaseWebApiTask(this);
	}
	@Override
	protected void onPause() {
		super.onPause();
		JPushInterface.onPause(this);
	}
	@Override
	public void onRestoreInstanceState(Bundle outState){
		super.onRestoreInstanceState(outState);
		SharedPreferences sharedPreferences = getSharedPreferences("customerInformation",Context.MODE_PRIVATE);
		mApp.setFormalFlag(Integer.valueOf(sharedPreferences.getInt("formalFlag", 0)));
	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
	}
	
	@Override
	protected void onStart(){
		super.onStart(); 
	}
	
	@Override
	protected void onUserLeaveHint() {
		super.onUserLeaveHint();
	}

	@Override
	protected void onResume() {
		super.onResume(); 
		mLogInInfo = mApp.getLoginInformation();
		//APP退出时。接收该FLag
		String exit = getIntent().getStringExtra("exit");
		if (exit != null && exit.equals("1")) {
			handleExit();
		}
		// 商家切换时执行
		else if (exit != null && exit.equals("2")) {
			handleChangeBranch();
		}else if (exit != null && exit.equals("3")) {
			//退出到登陆页
			SharedPreferences sharedata = getSharedPreferences("customerInformation",Context.MODE_PRIVATE);
			Editor editor = sharedata.edit();// 获取编辑器
			editor.putInt("formalFlag", 0);
			editor.putInt("loginInfoPosition", 0);
			editor.putString("companySelectList", "");
			editor.putBoolean("autoLogin",false);
			editor.commit();// 提交修改
			
			Intent destIntent = new Intent(this, LoginActivity.class);
			startActivity(destIntent);
			finish();
		}else{
			JPushInterface.onResume(this);
			if(JPushInterface.isPushStopped(getApplicationContext())){
				JPushInterface.resumePush(getApplicationContext());
				String uuid = RandomUUID.getRandomUUID(this, mCustomerID);
				JPushInterface.init(getApplicationContext());
				JPushInterface.setAlias(getApplicationContext(), uuid, null);
			}
		}
		
	}
	private void handleChangeBranch() {
		Intent destIntent = new Intent(this, CompanySelectActivity.class);
		Bundle mBundle = new Bundle();
		mBundle.putSerializable("companyList", (Serializable) mApp.getCompanyList(this));
		destIntent.putExtras(mBundle);
		startActivity(destIntent);
		finish();
	}
	private void handleExit() {
		finish();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	
	protected WebApiConnectHelper getNetConnect() {
		return mNetConnect;
	}
	
	
	protected final void asyncRefrshView(IConnectTask task) {
		if(!mApp.getIsExit()){
			baseTask.setCurrentTask(task);
			mNetConnect.queueTask(baseTask);
		}
	}
	
	protected void showProgressDialog(){
		if(progressDialog == null){
			progressDialog = new ProgressDialog(this);
			progressDialog.setCancelable(false);
			progressDialog.setMessage("正在加载数据，请稍侯。。。");
		}
		progressDialog.show();
	}
	
	protected void dismissProgressDialog(){
		if (progressDialog != null) {
			progressDialog.dismiss();
		}
	}
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_main_back:
			finish();
			break;

		}
	}
	public UserInfoApplication getUserInfoApplication() {
		return mApp;
	}

	
	public static class BaseWebApiTask implements IConnectTask {
		private WeakReference<BaseFragmentActivity> mActivity;
		private WeakReference<IConnectTask> currentTask;
		public BaseWebApiTask(BaseFragmentActivity activity) {
			mActivity = new WeakReference<BaseFragmentActivity>(activity);
		}

		@Override
		public WebApiRequest getRequest() {
			return currentTask.get().getRequest();
		}

		@Override
		public void onHandleResponse(WebApiResponse response) {
			if(mActivity != null && mActivity.get() != null && currentTask != null && currentTask.get() != null){
				boolean isExit = ((UserInfoApplication)mActivity.get().getApplication()).getIsExit();
				if(!isExit){
					mActivity.get().handleHttpResponse(response, currentTask.get());
				}
			}
		}

		public IConnectTask getCurrentTask() {
			return currentTask.get();
		}

		public void setCurrentTask(IConnectTask currentTask) {
			this.currentTask = new WeakReference<IConnectTask>(currentTask);
		}

		@Override
		public void parseData(WebApiResponse response) {
			if(currentTask != null && currentTask.get() != null){
				currentTask.get().parseData(response);
			}
		}

	}
	
	private void handleHttpResponse(WebApiResponse response, IConnectTask currentTask) {
		int httpCode = response.getHttpCode();
		int httpErrorMessage = Integer.valueOf(response.getHttpErrorMessage());
		handleHttpError(httpCode, httpErrorMessage);
		currentTask.onHandleResponse(response);
	}
	
	public void handleHttpError(int httpCode, int httpErrorMessage){
		if (httpCode == 500) {
			DialogUtil.createShortDialog(this, "服务器网络错误！");
		} else if (httpCode == 401) {
			switch (httpErrorMessage) {
			case 10001:
			case 10002:
			case 10003:
			case 10004:
			case 10005:
			case 10006:
			case 10007:
			case 10008:
			case 10009:
			case 10011:
			case 10012:
				handleHttpError_401(httpCode);
				break;
			case 10010:
				// 版本过低
				promptUpdate();
				break;
			case 10013:
				// 登陆异常
				handleLoginException();
				break;

			default:
				break;
			}
		} else if (httpCode != 200){
			handleHttpError_401(httpCode);
		}
	}
	
	public void promptUpdate() {
		showUpdateDialog();
	}

	public void handleLoginException() {
		DialogUtil.createShortDialog(this, "登录异常，请重新登陆！");
		mApp.AppExitToLoginActivity(this);
	}

	public void handleHttpError_401(int httpCode) {
		DialogUtil.createShortDialog(this, String.valueOf(httpCode) + "，网络错误！");
	}
	
	// 显示是否下载新版本的对话框
	private void showUpdateDialog() {
		StringBuffer versionInformation = new StringBuffer();
		versionInformation.append("请升级至最新版本！");
		Dialog dialog = new AlertDialog.Builder(this)
				.setTitle(getString(R.string.update_software_title))
				.setMessage(versionInformation)
				.setPositiveButton(getString(R.string.update_new_version),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								promptUpdateNewVersion();
							}
						})
				.setNegativeButton(getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								mApp.AppExit(BaseFragmentActivity.this);
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}
	
	private void promptUpdateNewVersion(){
		final ProgressDialog updateDialog = DialogUtil.createUpdateApkDialog(this);
		updateDialog.show();
		DownFileTaskProgressCallback progressCallback = new DownFileTaskProgressCallback() {
			
			@Override
			public void onProgressUpdate(int progress) {
				updateDialog.setProgress(progress);
			}
			
			@Override
			public void onPostExecute() {
				updateDialog.cancel();
				AlertDialog installApkdialog = DialogUtil.showInstallDialog(BaseFragmentActivity.this, new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog,int which) {
						mApp.installApk(BaseFragmentActivity.this);
					}
				});
				installApkdialog.show();
			}
			
			@Override
			public void onExecuteError() {
				updateDialog.cancel();
				DialogUtil.createShortDialog(BaseFragmentActivity.this, "更新失败！");
				mApp.AppExit(BaseFragmentActivity.this);
			}
		};
		UpdateNewVersionData updateNewVersionData = new  UpdateNewVersionData(progressCallback);
	}

	public static class UpdateNewVersionData implements IConnectTask{
		DownFileTaskProgressCallback progressCallback;
		private UpdateNewVersionData (DownFileTaskProgressCallback progressCallback){
			this.progressCallback=progressCallback;
			if(!mApp.getIsExit()){
				baseTask.setCurrentTask(this);
				mNetConnect.queueTask(baseTask);
			}
		}  
		
		@Override
		public WebApiRequest getRequest() {
			JSONObject para = new JSONObject();
			String methodName = "GetAndroidURL";
			WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead("WebUtility", methodName, para.toString());
			WebApiRequest request = new WebApiRequest("WebUtility", methodName, para.toString(), header);
			return request;
		}

		@Override
		public void parseData(WebApiResponse response) {
			
		}

		@Override
		public void onHandleResponse(WebApiResponse response) {
			if(response.getHttpCode() == 200){
				switch (response.getCode()) {
				case WebApiResponse.GET_WEB_DATA_TRUE:
					DownLoadFileManager.executeDownLoadTask(DownLoadFileManager.TYPE_DOWNLOAD_APK_FILE, mApp.getfileCache(), progressCallback,response.getStringData());
					break;
				case WebApiResponse.GET_WEB_DATA_EXCEPTION:
					break;
				case WebApiResponse.GET_WEB_DATA_FALSE:
					
					break;
				case WebApiResponse.GET_DATA_NULL:
					break;
				case WebApiResponse.PARSING_ERROR:
					
					break;
				default:
					break;
				}
			}
		}
		
	}
	
}
