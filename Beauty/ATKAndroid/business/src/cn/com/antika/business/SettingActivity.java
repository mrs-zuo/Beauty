package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class SettingActivity extends BaseActivity implements OnClickListener {
	private SettingActivityHandler mHandler = new SettingActivityHandler(this);
	public static final String TAG = "SettingActivity";
	private RelativeLayout personalMessageRelativeLayout;
	private RelativeLayout aboutUsRelativeLayout;
	private RelativeLayout changeRelativeLayout;
	private View personalMessageBeforeView;
	private View personalMessageAfterView;
	private RelativeLayout memorySpaceRelativeLayout;// 空间使用
	private RelativeLayout loginOutRelativeLayout;// 登出
	private UserInfoApplication userInfoApplication;
	private RelativeLayout softwareCheckUpdateRelativelayout;// 检查更新
	private Thread  requestWebServiceThread;
	private String 	url;
	private FileCache fileCache = null;
	private PackageUpdateUtil packageUpdateUtil;
	private ProgressDialog progressDialog;

	// 过期时间设置
	private RelativeLayout appExpiredRelativelayout;
	private TextView appExpiredValueText;
	private LayoutInflater layoutInflater;
	private SharedPreferences  sharedPerferences;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_setting);
		userInfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	protected void initView() {
		personalMessageRelativeLayout = (RelativeLayout) findViewById(R.id.personal_message_relativelayout);
		aboutUsRelativeLayout = (RelativeLayout) findViewById(R.id.about_us_relativelayout);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		((RelativeLayout) findViewById(R.id.app_download_relativelayout))
				.setOnClickListener(this);
		personalMessageRelativeLayout.setOnClickListener(this);
		aboutUsRelativeLayout.setOnClickListener(this);
		if (userInfoApplication.getAccountInfoListSize() > 1
				|| (userInfoApplication.getLoginBranchList().size() >= 1 && userInfoApplication.getLoginBranchList().get(0).size() > 1)) {
			changeRelativeLayout = (RelativeLayout) findViewById(R.id.change_company_relativelayout);
			((View) findViewById(R.id.change_company_relativelayout_before_line))
					.setVisibility(View.VISIBLE);
			((View) findViewById(R.id.change_company_relativelayout_after_line))
					.setVisibility(View.VISIBLE);
			changeRelativeLayout.setVisibility(View.VISIBLE);
			changeRelativeLayout.setOnClickListener(this);
		}
		personalMessageBeforeView = (View) findViewById(R.id.personal_message_before_view);
		personalMessageAfterView = (View) findViewById(R.id.personal_message_after_view);
		// memorySpaceRelativeLayout=(RelativeLayout)
		// findViewById(R.id.memory_space_relativelayout);
		// memorySpaceRelativeLayout.setOnClickListener(this);
		int authMyInfoWrite = userInfoApplication.getAccountInfo()
				.getAuthMyInfoWrite();
		if (authMyInfoWrite == 0) {
			personalMessageBeforeView.setVisibility(View.GONE);
			personalMessageRelativeLayout.setVisibility(View.GONE);
			personalMessageAfterView.setVisibility(View.GONE);
		}
		loginOutRelativeLayout = (RelativeLayout) findViewById(R.id.login_out_relativelayout);
		loginOutRelativeLayout.setOnClickListener(this);
		userInfoApplication = UserInfoApplication.getInstance();
		softwareCheckUpdateRelativelayout = (RelativeLayout) findViewById(R.id.software_check_update_relativelayout);
		softwareCheckUpdateRelativelayout.setOnClickListener(this);

		
		sharedPerferences=getSharedPreferences("AppExpiredValue", MODE_PRIVATE);
		int appExpiredTime=sharedPerferences.getInt("APP_EXPIRED_VALUE",30);
		appExpiredRelativelayout = (RelativeLayout) findViewById(R.id.app_expired_relativelayout);
		appExpiredValueText = (TextView)findViewById(R.id.app_expired_value_text);
		appExpiredValueText.setText(appExpiredTime+"分钟");
		appExpiredRelativelayout.setOnClickListener(this);
		layoutInflater=LayoutInflater.from(this);
	}
	private void loginOut(){
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "Logout";
				String endPoint = "Login";
				WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,"",userInfoApplication);
				mHandler.sendEmptyMessage(8);
			}
		};
		requestWebServiceThread.start();
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		Intent destIntent = null;
		switch (view.getId()) {
		// 个人信息
		case R.id.personal_message_relativelayout:
			destIntent = new Intent(this, EditPersonalMessageActivity.class);
			startActivity(destIntent);
			break;
		// 关于我们
		case R.id.about_us_relativelayout:
			destIntent = new Intent(this, AboutUsActivity.class);
			startActivity(destIntent);
			break;
		case R.id.change_company_relativelayout:
			// 商家切换
			ActivityManager manager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
			List<ActivityManager.RunningTaskInfo> tasks = manager.getRunningTasks(1);
			ComponentName baseActivity = tasks.get(0).baseActivity;
			Intent intent = new Intent();
			intent.setComponent(baseActivity);
			intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
			intent.putExtra("exit", "2");
			userInfoApplication.setNormalLogin(false);
			startActivity(intent);
			break;
		// 应用下载
		case R.id.app_download_relativelayout:
			destIntent = new Intent(this, AppDownloadActivity.class);
			startActivity(destIntent);
			break;
		/*
		 * case R.id.memory_space_relativelayout: destIntent = new
		 * Intent(this,MemorySpaceActivity.class); startActivity(destIntent);
		 * break;
		 */
		// 检查更新
		case R.id.software_check_update_relativelayout:
			checkUpdate();
			break;
		case R.id.app_expired_relativelayout:
			View updateAppExpiredDialogView = layoutInflater.inflate(R.xml.update_app_expired_time_dialog_view,null);
			final EditText appExpiredNewValueText = (EditText)updateAppExpiredDialogView.findViewById(R.id.app_expired_time_new_value);
			appExpiredNewValueText.setText(String.valueOf(sharedPerferences.getInt("APP_EXPIRED_VALUE",30)));
			//弹出修改过期时间的对话框
			final AlertDialog updateOrderTotalSalePriceDialog = new AlertDialog.Builder(
					this, R.style.CustomerAlertDialog)
					.setTitle("设置自动登出时间(多长时间软件无操作即需重新登录)")
					.setView(updateAppExpiredDialogView)
					.setPositiveButton("确定",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(
										DialogInterface dialogInterface,
										int which) {
									if(appExpiredNewValueText.getText().toString()!=null && !(("").equals(appExpiredNewValueText.getText().toString()))){
										Editor editor = sharedPerferences.edit();// 获取编辑器
										editor.putInt("APP_EXPIRED_VALUE",Integer.parseInt(appExpiredNewValueText.getText().toString()));
										editor.commit();
										appExpiredValueText.setText(Integer.parseInt(appExpiredNewValueText.getText().toString())+"分钟");
									}
									else{
										DialogUtil.createShortDialog(SettingActivity.this,"自动登出时间不能为空!");
									}
								}
							})
					.setNegativeButton("取消",
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(
										DialogInterface dialogInterface,
										int which) {
									// TODO Auto-generated method stub

								}
							}).show();
			break;
		case R.id.login_out_relativelayout:
			Dialog dialog = new AlertDialog.Builder(SettingActivity.this,
					R.style.CustomerAlertDialog)
					.setTitle(getString(R.string.delete_dialog_title))
					.setMessage(R.string.confirm_login_out)
					.setPositiveButton(getString(R.string.yes),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									dialog.dismiss();
									loginOut();
								}
							})
					.setNegativeButton(getString(R.string.no),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									// TODO Auto-generated method
									// stub
									dialog.dismiss();
									dialog = null;
								}
							}).create();
			dialog.show();
			dialog.setCancelable(false);
			break;
		}
	}

	// 检查更新功能模块
	private void checkUpdate() {
		progressDialog = new ProgressDialog(this,
				R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		fileCache = new FileCache(this);
		url = Constant.SERVER_URL + getString(R.string.download_apk_address);
		packageUpdateUtil = new PackageUpdateUtil(this, mHandler, fileCache,
				url, false,userInfoApplication);
		// 获得本地的package信息
		packageUpdateUtil.getPackageVersionInfo();
		// 获得服务器版本信息
		packageUpdateUtil.getVersionInformation();
	}

	private static class SettingActivityHandler extends Handler {
		private final SettingActivity settingActivity;

		private SettingActivityHandler(SettingActivity activity) {
			WeakReference<SettingActivity> weakReference = new WeakReference<SettingActivity>(activity);
			settingActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (settingActivity.progressDialog != null) {
				settingActivity.progressDialog.dismiss();
				settingActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				ServerPackageVersion serverPackageVersion = (ServerPackageVersion) msg.obj;
				settingActivity.packageUpdateUtil
						.compareVersionInformation(serverPackageVersion);
			} else if (msg.what == -1) {
				ServerPackageVersion serverPackageVersion = (ServerPackageVersion) msg.obj;
				settingActivity.packageUpdateUtil
						.compareVersionInformation(serverPackageVersion);
			} else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = settingActivity.getFileStreamPath(filename);
				file.getName();
				settingActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj)
						.getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(
						downLoadFileSize);
			} else if (msg.what == 2) {
				DialogUtil.createMakeSureDialog(settingActivity, "温馨提示",
						"您的网络貌似不给力，请检查网络设置");
			}
			//登出
			else if (msg.what == 8) {
				settingActivity.userInfoApplication.setAccountInfo(null);
				settingActivity.userInfoApplication.setSelectedCustomerID(0);
				settingActivity.userInfoApplication.setSelectedCustomerName("");
				settingActivity.userInfoApplication.setSelectedCustomerHeadImageURL("");
				settingActivity.userInfoApplication.setSelectedCustomerLoginMobile("");
				settingActivity.userInfoApplication.setOrderInfo(null);
				settingActivity.userInfoApplication.exitForLogin(settingActivity);
				settingActivity.userInfoApplication.setAccountNewMessageCount(0);
				settingActivity.userInfoApplication.setAccountNewRemindCount(0);
				Constant.formalFlag = 0;
			} else if (msg.what == 6)
				DialogUtil.createShortDialog(settingActivity, "已经是最新版本！");
		}
	}
}
