package com.glamourpromise.beauty.customer.activity;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask.DownFileTaskProgressCallback;
import com.glamourpromise.beauty.customer.managerService.DownLoadFileManager;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.task.GetServerVersionTaskImpl;
import com.glamourpromise.beauty.customer.task.GetServerVersionTaskImpl.onReslutListener;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class SettingActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Image";
	private static final String UPDATE_HEAD_IMAGE = "updateUserHeadImage";
	private String updateHeadImageString;// 更换后头像的BASE64字符串
	private String currentVersion;
	private String newestVersion;
	private boolean mustUpgrade;
	int flag=0;
	DownFileTaskProgressCallback progressCallback ;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_setting);
		super.setTitle(getString(R.string.title_setting));
		findViewById(R.id.person_message_relativelayout).setOnClickListener(this);
		findViewById(R.id.layout_one).setOnClickListener(this);
		findViewById(R.id.layout_two).setOnClickListener(this);
		findViewById(R.id.layout_three).setOnClickListener(this);
		findViewById(R.id.layout_four).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.check_new_version_layout).setOnClickListener(this);
		//只有一家公司，隐藏商家切换
		if(mApp.getCompanyCount() == 1){
			findViewById(R.id.layout_four).setVisibility(View.GONE);
		}
		currentVersion = mApp.getPackageVersion();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		super.onClick(view);
		Intent destIntent;
		switch (view.getId()) {
		case R.id.person_message_relativelayout:
			destIntent=new Intent(this,PersonMessageActivity.class);
			startActivity(destIntent);
			break;
		case R.id.layout_one:
			destIntent = new Intent(this, PasswordSettingActivity.class);
			startActivity(destIntent);
			break;
		case R.id.layout_two:
			destIntent = new Intent(this, AboutUsActivity.class);
			startActivity(destIntent);
			break;
		case R.id.layout_three:
			AlertDialog paymentDialog = new AlertDialog.Builder(this)
					.setTitle("确认退出？")
					.setPositiveButton(this.getString(R.string.confirm),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface arg0,
										int arg1) {
									// TODO Auto-generated method stub
									mApp.AppExitToLoginActivity(SettingActivity.this);
									Editor editor=mApp.getSharedPreferences().edit();
									editor.putBoolean("autoLogin",false);
									editor.commit();
								}
							})
					.setNegativeButton(this.getString(R.string.cancel), null)
					.show();
			paymentDialog.setCancelable(false);
			break;
		case R.id.layout_four:
			//商家切换
			mApp.setIsExit(true);
			mApp.cancelExecutor();
			mApp.restPresenter();
			mApp.removeNotification();
			ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE); 
			List<ActivityManager.RunningTaskInfo> tasks = manager.getRunningTasks(1);
			ComponentName baseActivity = tasks.get(0).baseActivity;
			Intent intent = new Intent();
			intent.setComponent(baseActivity);
			intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			intent.putExtra("exit", "2");
			UserInfoApplication userinfo=(UserInfoApplication) getApplication();
			userinfo.setNormalLogin(false);
			startActivity(intent);
			break;
		case R.id.check_new_version_layout:
			checkNewVersion();
			break;
		}
	}
	
	/**
	 * 检测新版本
	 */
	private void checkNewVersion(){
		super.showProgressDialog();
		GetServerVersionTaskImpl getVersionTask = new GetServerVersionTaskImpl(currentVersion, mApp, new onReslutListener() {
			
			@Override
			public void onHandleReslut(WebApiResponse response) {
				// TODO Auto-generated method stub
				if(response.getHttpCode() == 200){
					switch (response.getCode()) {
					case WebApiResponse.GET_WEB_DATA_TRUE:
						JSONObject jsData;
						try {
							jsData = new JSONObject(response.getStringData());
							mustUpgrade = jsData.getBoolean("MustUpgrade");
							newestVersion = jsData.getString("Version");
						} catch (JSONException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
							return;
						}
						
						//本地版本小于服务器版本且必须升级
						if (currentVersion.compareTo(newestVersion) < 0 && mustUpgrade) {
							SettingActivity.super.promptUpdate();
						}
						//本地版本小，不强制升级
						else if(currentVersion.compareTo(newestVersion) < 0 && !mustUpgrade){
							showUpdateDialog(newestVersion);
						}
						//本地为最新版本
						else{
							DialogUtil.createShortDialog(SettingActivity.this, "已是最新版本！");
						}
						break;
					case WebApiResponse.GET_WEB_DATA_EXCEPTION:
					case WebApiResponse.GET_WEB_DATA_FALSE:
						DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
						break;
					case WebApiResponse.GET_DATA_NULL:
					case WebApiResponse.PARSING_ERROR:
						DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
						break;
					default:
						break;
					}
				}
				SettingActivity.super.dismissProgressDialog();
			}
		});
		super.asyncRefrshView(getVersionTask);
	}
	
	// 显示是否下载新版本的对话框
	private void showUpdateDialog(String serverVersion) {
		StringBuffer versionInformation = new StringBuffer();
		versionInformation.append(getString(R.string.current_version_title));
		versionInformation.append(currentVersion);
		versionInformation.append("\n");
		versionInformation.append(getString(R.string.new_version_title));
		versionInformation.append(serverVersion);

		Dialog dialog = new AlertDialog.Builder(this)
				.setTitle(getString(R.string.update_software_title))
				.setMessage(versionInformation)
				.setPositiveButton(getString(R.string.update_new_version),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								promptUpdateNewVersion();
							}
						})
				.setNegativeButton(getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}
	
	private void promptUpdateNewVersion(){
		final ProgressDialog updateDialog = DialogUtil.createUpdateApkDialog(this);
		updateDialog.show();
		progressCallback = new DownFileTaskProgressCallback() {
			
			@Override
			public void onProgressUpdate(int progress) {
				// TODO Auto-generated method stub
				updateDialog.setProgress(progress);
			}
			
			@Override
			public void onPostExecute() {
				// TODO Auto-generated method stub
				updateDialog.cancel();
				AlertDialog installApkdialog = DialogUtil.showInstallDialog(SettingActivity.this, new DialogInterface.OnClickListener() {

					@Override
					public void onClick(DialogInterface dialog,
							int which) {
						// TODO Auto-generated method stub
						mApp.installApk(SettingActivity.this);
					}
				});
				installApkdialog.show();
			}
			
			@Override
			public void onExecuteError() {
				// TODO Auto-generated method stub
				updateDialog.cancel();
				DialogUtil.createShortDialog(SettingActivity.this, "更新失败！");
				//必须升级
				if(mustUpgrade)
					mApp.AppExit(SettingActivity.this);
			}
		};
		flag=1;
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		String categoryName = CATEGORY_NAME;
		String methodName = UPDATE_HEAD_IMAGE;
		if(flag==1){
			categoryName="WebUtility";
			methodName="GetAndroidURL";
		}else{
			categoryName=CATEGORY_NAME;
			methodName=UPDATE_HEAD_IMAGE;
			try {
				para.put("CompanyID", mCompanyID);
				para.put("UserID", mCustomerID);
				para.put("UserType", "0");
				para.put("ImageString", updateHeadImageString);
				para.put("ImageType", ".jpg");// 后缀名
				para.put("ImageWidth", "60");// 后缀名
				para.put("ImageHeight", "60");// 后缀名
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(flag==1){
					DownLoadFileManager.executeDownLoadTask(DownLoadFileManager.TYPE_DOWNLOAD_APK_FILE, mApp.getfileCache(), progressCallback,response.getStringData());
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), "头像更新失败");
				break;
			default:
				break;
			}
		}
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}
}
