package com.glamourpromise.beauty.customer.activity;

import java.io.File;
import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.format.DateFormat;
import android.util.Log;
import android.view.Window;
import cn.jpush.android.api.JPushInterface;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask.DownFileTaskProgressCallback;
import com.glamourpromise.beauty.customer.managerService.DownLoadFileManager;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.net.WebServiceUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.FileCache;

public class SplashActivity extends Activity {
	private static final String FILE_NAME = "com.glamourpromise.beauty.customer";
	private static final String DOWNLOAD_FILE_ERROR = "更新失败!";
	private Thread subThread;
	private ProgressDialog updateDialog;
	private long startTime;
	private long loadingTime;
	private String serverVersion = "0";// 服务器上的版本号
	private boolean mustUpgrade = false;
	private UserInfoApplication userInfo;
	private FileCache fileCache;
	private int apkFileSize = 0;
	private int downloadFileSize = 0;
	String  apkURL="";
	DownFileTaskProgressCallback progressCallback;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.splash);
		JPushInterface.setDebugMode(false);
		userInfo = (UserInfoApplication)getApplication();
		userInfo.setFormalFlag(userInfo.getSharedPreferences().getInt("formalFlag",0));
		getVersionInformationByWebService();
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		JPushInterface.onPause(this);
		mhandler.removeCallbacksAndMessages(null);
		if(subThread != null){
			subThread.interrupt();
			subThread = null;
		}
	}
	
	@Override
	protected void onResume() { // 当用户使程序恢复为前台显示时执行onResume()方法,在其中判断是否超时.
		super.onResume(); 
		JPushInterface.onResume(this);
	}

	private Handler mhandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			if (subThread != null) {
				subThread.interrupt();
				subThread = null;
			}
			if (msg.what == 1) {
				compareVersionInformation();
			} else if (msg.what == -1) {
				// timer();
				compareVersionInformation();
			} else if (msg.what == 5) {
				Log.v("downFileSucess", "ok");
				updateDialog.cancel();
				File file = getFileStreamPath(FILE_NAME);
				Log.v("fileExist", file.getName());
				showInstallDialog();
			} else if (msg.what == -5) {
				updateDialog.cancel();
				DialogUtil.createShortDialog(SplashActivity.this, DOWNLOAD_FILE_ERROR);
				//必须升级
				if(mustUpgrade)
					SplashActivity.this.finish();
				else
					isAutoLogin();
			}else if(msg.what == 6){
				updateDialog.setMax(apkFileSize);
			}else if(msg.what == 7){
				updateDialog.setProgress(downloadFileSize);
			}
			else if(msg.what==2){
				DialogUtil.createShortDialog(SplashActivity.this, Constant.NET_ERR_PROMPT);
				isAutoLogin();
			}else if(msg.what==3){
				String httpMsg = (String) msg.obj;
				DialogUtil.createShortDialog(SplashActivity.this, httpMsg);
				isAutoLogin();
			}else if(msg.what==8){
				showProgressBar();
			}
		}
	};

	// 比较版本，判断是否需要更新app
	private void compareVersionInformation() {
		fileCache = new FileCache(this.getApplicationContext());
		String currentVersion = getPackageVersion();// 获取本地的版本号
		if (currentVersion.compareTo(serverVersion) < 0) {
			if (mustUpgrade) {
				//必须升级，直接下载
				//showProgressBar();
				StringBuffer versionInformation = new StringBuffer();
				versionInformation.append(getString(R.string.current_version_title));
				versionInformation.append(currentVersion);
				versionInformation.append("\n");
				versionInformation.append(getString(R.string.new_version_title));
				versionInformation.append(serverVersion);

				Dialog dialog = new AlertDialog.Builder(this)
						.setTitle(getString(R.string.must_update_software_title))
						.setMessage(versionInformation)
						.setPositiveButton(getString(R.string.update_new_version),
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										getVersionInformationURL();
									}
								})
						.setNegativeButton(getString(R.string.cancel_update),
								new DialogInterface.OnClickListener() {

									@Override
									public void onClick(DialogInterface dialog,
											int which) {
										// TODO Auto-generated method stub
										SplashActivity.this.finish();
									}
								}).create();
				dialog.show();
				dialog.setCancelable(false);
			} else {
				//提示是否升级
				showUpdateDialog(currentVersion);
			}
		} else {
			isAutoLogin();
		}

	}

	// 通过webservice取得下载apk URL
	private void getVersionInformationURL() {
		subThread = new Thread() {
			@Override
			public void run() {
				WebApiHttpHead header = new WebApiHttpHead();
				header.setMethodName("GetAndroidURL");
				header.setDeviceType(WebApiHttpHead.ANDROID_DEVICE_TYPE);
				header.setClient(WebApiHttpHead.CUSTOMER_CLIENT_TYPE);
				String time = "yyyy-MM-dd kk:mm";
				time = (String) DateFormat.format(time, new Date());
				header.setActionTime(time);
				String tmp = WebServiceUtil.requestWebApiAction("WebUtility", "", header);
				WebApiResponse response = new WebApiResponse(tmp);
				switch (response.getCode()) {
				case WebApiResponse.GET_WEB_DATA_TRUE:
					apkURL=response.getStringData();
					mhandler.sendEmptyMessage(8);
					break;
				case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				case WebApiResponse.GET_WEB_DATA_FALSE:
					mhandler.obtainMessage(3, response.getMessage());
					break;
				case WebApiResponse.GET_DATA_NULL:
				case WebApiResponse.PARSING_ERROR:
					mhandler.sendEmptyMessage(2);
					break;
				default:
					break;
				}
			}
		
		};
		subThread.start();
	}	
	
	@SuppressLint("NewApi")
	private void showProgressBar() {
		updateDialog = new ProgressDialog(this);
		updateDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		updateDialog.setTitle(getString(R.string.updating_title));
		updateDialog.setMessage(getString(R.string.wait));
		updateDialog.setProgressNumberFormat("");
		updateDialog.show();
		updateDialog.setCancelable(false);
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
				AlertDialog installApkdialog = DialogUtil.showInstallDialog(
						SplashActivity.this,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								userInfo.installApk(SplashActivity.this);
							}
						});
				installApkdialog.show();
			}

			@Override
			public void onExecuteError() {
				// TODO Auto-generated method stub
				updateDialog.cancel();
				DialogUtil.createShortDialog(SplashActivity.this,"更新失败！");
				userInfo.AppExit(SplashActivity.this);
			}
		};
		downFile();
	}

	// 取得版本信息
	private String getPackageVersion() {
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

	// 计时器
	private void isAutoLogin() {
		SharedPreferences sharedata = userInfo.getSharedPreferences();
		String  userName=sharedata.getString("lastLoginAccount","");
		String  userPassword=sharedata.getString("lastLoginPassword","");
		boolean isAutoLogin=sharedata.getBoolean("autoLogin",false);
		if(userName!=null && !"".equals(userName) && userPassword!=null && !"".equals(userPassword) && isAutoLogin){
			userInfo.setFormalFlag(sharedata.getInt("formalFlag",0));
			gotoHomePage();
		}
		else{
			loadingTime = System.currentTimeMillis() - startTime;
			if (loadingTime < 800) {
				try {
					Thread.sleep(800 - loadingTime);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			gotoLoginActivity();
		}
	}

	// 跳转到登陆页面
	private void gotoLoginActivity() {
		Intent destIntent = new Intent(this,LoginActivity.class);
		startActivity(destIntent);
		mhandler.removeCallbacksAndMessages(null);
		this.finish();
	}
	
	//跳转到首页
	private void gotoHomePage() {
		Intent destIntent = new Intent(this,NavigationNew.class);
		startActivity(destIntent);
		this.finish();
    }

	// 显示是否下载新版本的对话框
	private void showUpdateDialog(String currentVersion) {
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
								getVersionInformationURL();
//								showProgressBar();
							}
						})
				.setNegativeButton(getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								gotoLoginActivity();
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}

	// 显示是否安装新版本的对话框
	private void showInstallDialog() {
		Dialog dialog = new AlertDialog.Builder(this)
				.setTitle(getString(R.string.install_software_title))
				.setMessage(getString(R.string.install_software_content))
				.setPositiveButton(getString(R.string.confirm),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								installNewApk();
							}
						})
				.create();
		dialog.show(); 
		dialog.setCancelable(false);
	}

	private void installNewApk() {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		intent.setDataAndType(Uri.fromFile(fileCache.getFileWithType(FILE_NAME, ".apk")), "application/vnd.android.package-archive");
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK); 
		startActivity(intent);
		finish();
	}

	// 下载文件的线程
	private void downFile() {
		DownLoadFileManager.executeDownLoadTask(DownLoadFileManager.TYPE_DOWNLOAD_APK_FILE,userInfo.getfileCache(), progressCallback,apkURL);
	}

	// 通过webservice取得版本信息
	private void getVersionInformationByWebService() {
		subThread = new Thread() {
			@Override
			public void run() {
				WebApiHttpHead header = new WebApiHttpHead();
				header.setAppVersion(getPackageVersion());
				header.setMethodName("getServerVersion");
				header.setDeviceType(WebApiHttpHead.ANDROID_DEVICE_TYPE);
				header.setClient(WebApiHttpHead.CUSTOMER_CLIENT_TYPE);
				String time = "yyyy-MM-dd kk:mm";
				time = (String) DateFormat.format(time, new Date());
				header.setActionTime(time);
				
				JSONObject para = new JSONObject();
				try {
					para.put("DeviceType", "2");
					para.put("ClientType", "2");
					para.put("CurrentVersion", getPackageVersion());
				} catch (JSONException e) {
					e.printStackTrace();
				}
				String tmp = WebServiceUtil.requestWebApiAction("Version", para.toString(), header);
				WebApiResponse response = new WebApiResponse(tmp);
				switch (response.getCode()) {
				case WebApiResponse.GET_WEB_DATA_TRUE:
					try {
						JSONObject data = new JSONObject(response.getStringData());
						mustUpgrade = data.getBoolean("MustUpgrade");
						serverVersion = data.getString("Version");
						mhandler.sendEmptyMessage(1);
					} catch (JSONException e) {
						e.printStackTrace();
						mhandler.sendEmptyMessage(2);
					}
					break;
				case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				case WebApiResponse.GET_WEB_DATA_FALSE:
					mhandler.obtainMessage(3, response.getMessage());
					break;
				case WebApiResponse.GET_DATA_NULL:
				case WebApiResponse.PARSING_ERROR:
					mhandler.sendEmptyMessage(2);
					break;
				default:
					break;
				}
			}
		
		};
		subThread.start();
	}
}
