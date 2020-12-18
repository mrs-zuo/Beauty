package cn.com.antika.util;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.support.v4.content.FileProvider;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.URL;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.LoginActivity;
import cn.com.antika.business.R;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class PackageUpdateUtil {
	private PackageUpdateUtilHandler getDownLoadUrlHandler = new PackageUpdateUtilHandler(this);
	private Context mContext;
	private Handler mHandler;
	private FileCache fileCache;
	private long requestStartTime;
	private String downloadFileUrl;
	private String localPackageVersion;
	private ProgressDialog updateDialog;
	private boolean needGoToLoginActivity;// 是否需要跳转到登陆页
	private UserInfoApplication userinfoApplication;
	private JSONObject  getAndroidURLJson;

	public PackageUpdateUtil(Context mContext, Handler mHandler,
			FileCache fileCache, String downloadFileUrl,
			boolean needGoToLoginActivity,
			UserInfoApplication userInfoApplication) {
		this.mContext = mContext;
		this.mHandler = mHandler;
		this.fileCache = fileCache;
		this.needGoToLoginActivity = needGoToLoginActivity;
		this.userinfoApplication = userInfoApplication;
	}

	// 获得当前APK包的版本信息
	public void getPackageVersionInfo() {
		try {
			PackageManager pm = mContext.getPackageManager();
			PackageInfo pi = null;
			pi = pm.getPackageInfo(mContext.getPackageName(), 0);
			localPackageVersion = pi.versionName;
		} catch (Exception e) {
			localPackageVersion = ""; // failed, ignored
		}
	}

	// 获得服务器上的Business Android版本信息
	public void getVersionInformation() {
		Thread requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				UserInfoApplication userInfoApplication=UserInfoApplication.getInstance();
				userInfoApplication.setAppVersion(localPackageVersion);
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				requestStartTime = System.currentTimeMillis();
				serverPackageVersion.setRequestStartTime(requestStartTime);
				String methodName ="getServerVersion";
				String endPoint ="Version";
				String serverRequestResult=WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,"",userInfoApplication);
				Message message = new Message();
				if (serverRequestResult != null && !("").equals(serverRequestResult)) {
					int code=0;
					JSONObject serverVersionJson=null;
					try {
						serverVersionJson=new JSONObject(serverRequestResult);
						code = serverVersionJson.getInt("Code");
					} catch (JSONException e) {
						code=0;
					}
					if(code==1){
						String packageVersion = "";
						boolean mustUpgrade = false;
						try {
							JSONObject versionJson=serverVersionJson.getJSONObject("Data");
							if(versionJson.has("Version")){
								packageVersion=versionJson.getString("Version");
							}
							if(versionJson.has("MustUpgrade"))
								mustUpgrade=versionJson.getBoolean("MustUpgrade");
						} catch (JSONException e) {
							
						}
						serverPackageVersion.setPackageVersion(packageVersion);
						serverPackageVersion.setMustUpdate(mustUpgrade);
						message.obj = serverPackageVersion;
						message.what = 1;
						mHandler.sendMessage(message);
					}
					else{
						serverPackageVersion.setPackageVersion("0");
						serverPackageVersion.setMustUpdate(false);
						message.obj = serverPackageVersion;
						message.what = -1;
						mHandler.sendMessage(message);
					}
				} else {
					serverPackageVersion.setPackageVersion("0");
					serverPackageVersion.setMustUpdate(false);
					message.obj = serverPackageVersion;
					message.what = -1;
					mHandler.sendMessage(message);
				}

			}
		};
		requestWebServiceThread.start();
	}

	// 比较版本，判断是否需要更新app
	public ProgressDialog compareVersionInformation(ServerPackageVersion serverPackageVersion) {
		int compareRes = localPackageVersion.compareTo(serverPackageVersion.getPackageVersion());
		if (compareRes < 0) {
			// 必须升级
			if (serverPackageVersion.isMustUpdate()) {
				mustUpdate(serverPackageVersion);
			} else {
				showUpdateDialog(localPackageVersion,serverPackageVersion.getPackageVersion());
			}
		} else {
			if (needGoToLoginActivity)
				timer();
			// 软件已经是最新版本
			else
				mHandler.sendEmptyMessage(6);
		}
		return updateDialog;
	}

	// 强制升级
	public void mustUpdate(ServerPackageVersion serverPackageVersion) {
		Dialog dialog = new AlertDialog.Builder(mContext,R.style.CustomerAlertDialog)
				.setTitle(mContext.getString(R.string.must_update_current_version_title))
				.setMessage("\n请升级至最新版")
				.setPositiveButton(mContext.getString(R.string.update_new_version),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								getApkDownLoadURL();
							}
						})
				.setNegativeButton(mContext.getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								// 启动画面，则销毁启动画面即可
								if (needGoToLoginActivity)
									((Activity) mContext).finish();
								// 在登陆和设置界面，则退出整个APP
								else {
									userinfoApplication.exit(mContext);
									((Activity) mContext).finish();
								}
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}

	// 计时器
	private void timer() {	
		long loadingTime = System.currentTimeMillis() - requestStartTime;
		if (loadingTime < 800) {
			try {
				Thread.sleep(800 - loadingTime);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		gotoLoginActivity();
	}

	// 跳转到登陆页面
	private void gotoLoginActivity() {
		Intent destIntent = new Intent(mContext, LoginActivity.class);
		mContext.startActivity(destIntent);
		((Activity) mContext).finish();
	}
	// 显示是否安装新版本的对话框
	public void showInstallDialog() {
		Dialog dialog = new AlertDialog.Builder(mContext,
				R.style.CustomerAlertDialog)
				.setTitle(mContext.getString(R.string.install_software_title))
				.setMessage(mContext.getString(R.string.install_software_content))
				.setPositiveButton(mContext.getString(R.string.confirm),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								installNewApk();
							}
						})
				.setNegativeButton(mContext.getString(R.string.cancel),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,int which) {
								// TODO Auto-generated method stub
								((Activity) mContext).finish();
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}

	// 显示是否下载新版本的对话框
	private void showUpdateDialog(String currentVersion,
			String serverPackageVersion) {
		StringBuffer versionInformation = new StringBuffer();
		versionInformation.append(mContext.getString(R.string.current_version_title));
		versionInformation.append(currentVersion);
		versionInformation.append("\n");
		versionInformation.append(mContext.getString(R.string.new_version_title));
		versionInformation.append(serverPackageVersion);
		Dialog dialog = new AlertDialog.Builder(mContext,R.style.CustomerAlertDialog)
				.setTitle(mContext.getString(R.string.update_software_title))
				.setMessage(versionInformation)
				.setPositiveButton(
						mContext.getString(R.string.update_new_version),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,
									int which) {
								// TODO Auto-generated method stub
								getApkDownLoadURL();
							}
						})
				.setNegativeButton(mContext.getString(R.string.cancel_update),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog,int which) {
								// TODO Auto-generated method stub
								if (needGoToLoginActivity)
									gotoLoginActivity();
							}
						}).create();
		dialog.show();
		dialog.setCancelable(false);
	}

	// 显示下载进度条
	public ProgressDialog showProgressBar() {
		ProgressDialog updateDialog = new ProgressDialog(mContext,R.style.CustomerProgressDialog);
		updateDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		updateDialog.setTitle(mContext.getString(R.string.updating_title));
		updateDialog.setMessage(mContext.getString(R.string.wait));
		updateDialog.setProgressNumberFormat("");
		updateDialog.show();
		updateDialog.setCancelable(false);
		downLoadFile(updateDialog);
		return updateDialog;
	}
	//获得下载的apk地址
	public void getApkDownLoadURL() {
		getAndroidURLJson=new JSONObject();
		try {
			getAndroidURLJson.put("ClientID","ADK");
		} catch (JSONException e) {
			e.printStackTrace();
		}
		Thread requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="GetAndroidURL";
				String endPoint ="WebUtility";
				String serverRequestResult=WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getAndroidURLJson.toString(),userinfoApplication);
				if (serverRequestResult != null && !("").equals(serverRequestResult)) {
					int code=0;
					JSONObject serverVersionJson=null;
					try {
						serverVersionJson=new JSONObject(serverRequestResult);
						code = serverVersionJson.getInt("Code");
					} catch (JSONException e) {
						code=0;
					}
					if(code==1){
						try {
							downloadFileUrl=serverVersionJson.getString("Data");
						} catch (JSONException e) {
							downloadFileUrl="";
						}
						getDownLoadUrlHandler.sendEmptyMessage(1);
					}
				} 
			}
		};
		requestWebServiceThread.start();
	}

	private static class PackageUpdateUtilHandler extends Handler {
		private final PackageUpdateUtil packageUpdateUtil;

		private PackageUpdateUtilHandler(PackageUpdateUtil activity) {
			WeakReference<PackageUpdateUtil> weakReference = new WeakReference<PackageUpdateUtil>(activity);
			packageUpdateUtil = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 1) {
				packageUpdateUtil.showProgressBar();
			}
		}
	}

	// 下载服务器新的版本的APK包
	public void downLoadFile(final ProgressDialog updateDialog) {
		Thread requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				try {
					URL imageUrl = new URL(downloadFileUrl);
					HttpURLConnection conn = (HttpURLConnection) imageUrl
							.openConnection();
					conn.setInstanceFollowRedirects(true);
					conn.setRequestMethod("GET");
					conn.setDoInput(true);
					conn.connect();
					InputStream is = conn.getInputStream();
					int apkFileSize = conn.getContentLength();
					File file = fileCache.getFileWithType("cn.com.antika.business", ".apk");
					FileOutputStream fileOutPutStream = new FileOutputStream(file);
					byte[] buffer = new byte[4096];
					int len = 0;
					int count = 0;
					Message message = null;
					do {
						len = is.read(buffer);
						if (len <= 0)
							break;
						fileOutPutStream.write(buffer, 0, len);
						count += len;
						int downloadFileSize = (int) (((float) count / apkFileSize) * 100);
						message = new Message();
						DownloadInfo downloadInfo = new DownloadInfo();
						downloadInfo.setDownloadApkSize(downloadFileSize);
						downloadInfo.setUpdateDialog(updateDialog);
						message.obj = downloadInfo;
						message.what = 7;
						mHandler.sendMessage(message);
					} while (true);
					is.close();
					fileOutPutStream.close();
					message = new Message();
					DownloadInfo downloadInfo = new DownloadInfo();
					downloadInfo.setUpdateDialog(updateDialog);
					message.obj = downloadInfo;
					message.what = 5;
					mHandler.sendMessage(message);
				} catch (Exception ex) {
					ex.printStackTrace();
					Message message = new Message();
					DownloadInfo downloadInfo = new DownloadInfo();
					downloadInfo.setUpdateDialog(updateDialog);
					message.obj = downloadInfo;
					message.what = -5;
					mHandler.sendMessage(message);
				}
			}
		};
		requestWebServiceThread.start();
	}

	// 安装新版本APK
	public void installNewApk() {
		Intent intent = new Intent(Intent.ACTION_VIEW);
		String filename = "cn.com.antika.business";
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		// intent.setDataAndType(Uri.fromFile(fileCache.getFileWithType(filename, ".apk")),"application/vnd.android.package-archive");
		File outputFile = fileCache.getFileWithType(filename, ".apk");
		if (Build.VERSION.SDK_INT >= 24) {
			Uri apkUri = FileProvider.getUriForFile(mContext, "cn.com.antika.business.fileprovider", outputFile);
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
		} else {
			intent.setDataAndType(Uri.fromFile(outputFile),"application/vnd.android.package-archive");
		}
		mContext.startActivity(intent);
	}
}
