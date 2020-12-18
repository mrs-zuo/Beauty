package com.GlamourPromise.Beauty.Business;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.jpush.android.api.JPushInterface;

/*
 * 启动界面以及检查是否有新的版本更新
 * */
public class SplashActivity extends BaseActivity {
	private SplashActivityHandler mHandler = new SplashActivityHandler(this);
	private String url;
	private FileCache fileCache = null;
	private PackageUpdateUtil packageUpdateUtil;
	private UserInfoApplication userinfoApplication;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_splash);
		fileCache = new FileCache(this);
		url = Constant.SERVER_URL + getString(R.string.download_apk_address);
		userinfoApplication = UserInfoApplication.getInstance();
		// 获得本地的package信息
		String appVersion =getAppVersionInfo();
		userinfoApplication.setAppVersion(appVersion);
		packageUpdateUtil = new PackageUpdateUtil(this, mHandler, fileCache,url, true,userinfoApplication);
		packageUpdateUtil.getPackageVersionInfo();
		// 获得服务器版本信息
		packageUpdateUtil.getVersionInformation();
	}

	@Override
	protected void onPause() {
		super.onPause();
		JPushInterface.onPause(this);
	}

	@Override
	protected void onResume() { // 当用户使程序恢复为前台显示时执行onResume()方法,在其中判断是否超时.
		// TODO Auto-generated method stub
		super.onResume();
		JPushInterface.onResume(this);
	}

	private static class SplashActivityHandler extends Handler {
		private final SplashActivity splashActivity;

		private SplashActivityHandler(SplashActivity activity) {
			WeakReference<SplashActivity> weakReference = new WeakReference<SplashActivity>(activity);
			splashActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 1) {
				ServerPackageVersion serverPackageVersion = (ServerPackageVersion) msg.obj;
				splashActivity.packageUpdateUtil.compareVersionInformation(serverPackageVersion);
			} else if (msg.what == -1) {
				ServerPackageVersion serverPackageVersion = (ServerPackageVersion) msg.obj;
				splashActivity.packageUpdateUtil.compareVersionInformation(serverPackageVersion);
			} else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = splashActivity.getFileStreamPath(filename);
				file.getName();
				splashActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
		}
	}

	public class ReplaceBroadcastReceiver extends BroadcastReceiver {
		private static final String TAG = "ApkDelete";

		@Override
		public void onReceive(Context arg0, Intent arg1) {

		}
	}

	// 获得当前APK包的版本信息
	public String getAppVersionInfo() {
		String appVersion="";
		try {
			PackageManager pm =getPackageManager();
			PackageInfo pi = null;
			pi = pm.getPackageInfo(getPackageName(), 0);
			appVersion = pi.versionName;
		} catch (Exception e) {
			appVersion = ""; // failed, ignored
		}
		return appVersion;
	}
}
