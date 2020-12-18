package com.GlamourPromise.Beauty.Business;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
/*
 * 展示考勤码界面
 * */
public class AccountAttendanceCodeActivity extends BaseActivity{
	private AccountAttendanceCodeActivityHandler mHandler = new AccountAttendanceCodeActivityHandler(this);
	private Thread requestWebServiceThread;
	private UserInfoApplication userinfoApplication;
	private ImageLoader  imageLoader;
	private DisplayImageOptions displayImageOptions;
	private PackageUpdateUtil packageUpdateUtil;
	private String       	 attendanceQRCodeUrl="";
	private ScheduledExecutorService scheduledExecutorService;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_account_attendance_code);
		initView();
	}
	protected void initView(){
		BusinessLeftImageButton bussinessLeftMenuBtn=(BusinessLeftImageButton)findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn=(BusinessRightImageButton)findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication=(UserInfoApplication)getApplication();
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		findViewById(R.id.attendance_code_refresh_icon).setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				// TODO Auto-generated method stub
				getAttendanceQRCode();
			}
		});
		//getAttendanceQRCode();
		scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
		scheduledExecutorService.scheduleAtFixedRate(new GetAttendanceQRCodeTask(),1,60,TimeUnit.SECONDS);
	}

	private static class AccountAttendanceCodeActivityHandler extends Handler {
		private final AccountAttendanceCodeActivity accountAttendanceCodeActivity;
		private AccountAttendanceCodeActivityHandler(AccountAttendanceCodeActivity activity) {
			WeakReference<AccountAttendanceCodeActivity> weakReference = new WeakReference<AccountAttendanceCodeActivity>(activity);
			accountAttendanceCodeActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (msg.what == 0) {
				DialogUtil.createShortDialog(accountAttendanceCodeActivity, "您的网络貌似不给力，请重试！");
			} else if (msg.what == 1) {
				ImageView qrCodeImage = (ImageView) accountAttendanceCodeActivity.findViewById(R.id.attendance_code_image);
				accountAttendanceCodeActivity.imageLoader.displayImage(accountAttendanceCodeActivity.attendanceQRCodeUrl, qrCodeImage, accountAttendanceCodeActivity.displayImageOptions);
			} else if (msg.what == 2) {
				DialogUtil.createShortDialog(accountAttendanceCodeActivity, (String) msg.obj);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(accountAttendanceCodeActivity, accountAttendanceCodeActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(accountAttendanceCodeActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + accountAttendanceCodeActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(accountAttendanceCodeActivity);
				accountAttendanceCodeActivity.packageUpdateUtil = new PackageUpdateUtil(accountAttendanceCodeActivity, accountAttendanceCodeActivity.mHandler, fileCache, downloadFileUrl, false, accountAttendanceCodeActivity.userinfoApplication);
				accountAttendanceCodeActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				accountAttendanceCodeActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = accountAttendanceCodeActivity.getFileStreamPath(filename);
				file.getName();
				accountAttendanceCodeActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (accountAttendanceCodeActivity.requestWebServiceThread != null) {
				accountAttendanceCodeActivity.requestWebServiceThread.interrupt();
				accountAttendanceCodeActivity.requestWebServiceThread = null;
			}
		}
	}

	private void getAttendanceQRCode(){
		requestWebServiceThread = new Thread() {
			public void run() {
				requestAttendanceQRCode();
			}
		};
		requestWebServiceThread.start();
	}
	class GetAttendanceQRCodeTask implements Runnable{

		@Override
		public void run() {
			// TODO Auto-generated method stub
			requestAttendanceQRCode();
		}
	}
	//请求考勤码的方法
	private void requestAttendanceQRCode(){
		String methodName ="GetAttendanceQRCode";
		String endPoint = "Account";
		JSONObject getAttendanceQRCodeJson=new JSONObject();
		String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,getAttendanceQRCodeJson.toString(),userinfoApplication);
		if (serverResult == null || ("").equals(serverResult))
			mHandler.sendEmptyMessage(0);
		else {
			JSONObject resultJson = null;
			try {
				resultJson = new JSONObject(serverResult);
			} catch (JSONException e) {
			}
			int     code = 0;
			String serverMessage = "";
			try {
				code = resultJson.getInt("Code");
				serverMessage = resultJson.getString("Message");
			} catch (JSONException e) {
				code = 0;
			}
			if (code== 1) {
				try {
					if(resultJson.has("Data") && !resultJson.isNull("Data"))
						attendanceQRCodeUrl=resultJson.getString("Data");
				} catch (JSONException e) {
				}
				mHandler.sendEmptyMessage(1);
			}
			else if(code==Constant.APP_VERSION_ERROR || code==Constant.LOGIN_ERROR)
				mHandler.sendEmptyMessage(code);
			else {
				Message msg = new Message();
				msg.what = 2;
				msg.obj = serverMessage;
				mHandler.sendMessage(msg);
			}
		}
	}
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if(scheduledExecutorService!=null){
			scheduledExecutorService.shutdown();
			scheduledExecutorService=null;
		}
	}
}
