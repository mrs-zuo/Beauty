package com.glamourpromise.beauty.customer.base;
import java.lang.ref.WeakReference;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import com.baidu.location.LocationClient;
import com.glamourpromise.beauty.customer.R;
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
import com.glamourpromise.beauty.customer.view.IBaseView;

@SuppressLint("Registered")
public abstract class BaseFragment extends Fragment implements OnClickListener, IBaseView{
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
	public View onCreateView(LayoutInflater inflater, ViewGroup container,Bundle savedInstanceState) {
		super.onCreateView(inflater, container, savedInstanceState);
		mApp = (UserInfoApplication)getActivity().getApplication();
		mLogInInfo = mApp.getLoginInformation();
		mCustomerID = mLogInInfo.getCustomerID();
		mCompanyID = mLogInInfo.getCompanyID();
		mCompanyCode = mLogInInfo.getCompanyCode();
		mBranchID = mLogInInfo.getBranchID();
		mScreenWidth = mApp.getScreenWidth();
		mNetConnect = mApp.getConnect();
		baseTask = new BaseWebApiTask(this);
		return null;
	};
	
	protected WebApiConnectHelper getNetConnect() {
		return mNetConnect;
	}
	
	
	protected final void asyncRefrshView(IConnectTask task) {
		baseTask.setCurrentTask(task);
		mNetConnect.queueTask(baseTask);
	}
	
	protected void showProgressDialog(){
		if(progressDialog == null){
			progressDialog = new ProgressDialog(getActivity());
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
	public UserInfoApplication getUserInfoApplication() {
		return mApp;
	}
	public static class BaseWebApiTask implements IConnectTask {
		private WeakReference<BaseFragment> mFragment;
		private WeakReference<IConnectTask> currentTask;
		public BaseWebApiTask(BaseFragment activity) {
			mFragment = new WeakReference<BaseFragment>(activity);
		}

		@Override
		public WebApiRequest getRequest() {
			return currentTask.get().getRequest();
		}

		@Override
		public void onHandleResponse(WebApiResponse response) {
			if(mFragment != null && mFragment.get() != null && currentTask != null && currentTask.get() != null){
				boolean isExit = ((UserInfoApplication)mFragment.get().getUserInfoApplication()).getIsExit();
				if(!isExit){
					mFragment.get().handleHttpResponse(response, currentTask.get());
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
			DialogUtil.createShortDialog(getActivity(),"服务器网络错误！");
		} else if (httpCode == 401) {
			switch (httpErrorMessage) {
			case 10001:
				break;
			case 10002:
				break;
			case 10003:
				break;
			case 10004:
				break;
			case 10005:
				break;
			case 10006:
				break;
			case 10007:
				break;
			case 10008:
				break;
			case 10009:
				break;
			case 10011:
				break;
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
		DialogUtil.createShortDialog(getActivity(),"登录异常，请重新登陆！");
		mApp.AppExitToLoginActivity(getActivity());
	}

	public void handleHttpError_401(int httpCode) {
		DialogUtil.createShortDialog(getActivity(),String.valueOf(httpCode) + "，网络错误！");
	}
	
	// 显示是否下载新版本的对话框
	private void showUpdateDialog() {
		StringBuffer versionInformation = new StringBuffer();
		versionInformation.append("请升级至最新版本！");
		Dialog dialog = new AlertDialog.Builder(getActivity())
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
								mApp.AppExit(getActivity());
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}
	
	private void promptUpdateNewVersion(){
		final ProgressDialog updateDialog = DialogUtil.createUpdateApkDialog(getActivity());
		updateDialog.show();
		DownFileTaskProgressCallback progressCallback = new DownFileTaskProgressCallback() {
			
			@Override
			public void onProgressUpdate(int progress) {
				updateDialog.setProgress(progress);
			}
			
			@Override
			public void onPostExecute() {
				updateDialog.cancel();
				AlertDialog installApkdialog = DialogUtil.showInstallDialog(getActivity(),new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog,int which) {
						mApp.installApk(getActivity());
					}
				});
				installApkdialog.show();
			}
			
			@Override
			public void onExecuteError() {
				updateDialog.cancel();
				DialogUtil.createShortDialog(getActivity(),"更新失败！");
				mApp.AppExit(getActivity());
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
