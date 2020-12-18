package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByWebserviceThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountDetailInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetServerAccountDetailDataTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.ImageLoaderUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

@SuppressLint("ResourceType")
public class AccountDetailActivity extends BaseActivity{
	private AccountDetailActivityHandler mHandler = new AccountDetailActivityHandler(this);
	private Thread getAccountDetailDataThread;
	private ProgressDialog progressDialog;
	private TextView AccountNameTextView;
	private ImageView AccountHeadImage;
	private UserInfoApplication userInfoApplication;
	private ImageLoader imageLoader;
	private LayoutInflater mLayoutInflater;
	private GetServerAccountDetailDataTaskImpl getAccountDetailTask;
	private PackageUpdateUtil packageUpdateUtil;
	private AccountDetailInfo accountDetail;
	private DisplayImageOptions displayImageOptions;

	private static class AccountDetailActivityHandler extends Handler {
		private final AccountDetailActivity accountDetailActivity;

		private AccountDetailActivityHandler(AccountDetailActivity activity) {
			WeakReference<AccountDetailActivity> weakReference = new WeakReference<AccountDetailActivity>(activity);
			accountDetailActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			accountDetailActivity.dismissProgressDialog();
			if (accountDetailActivity.getAccountDetailDataThread != null) {
				accountDetailActivity.getAccountDetailDataThread.interrupt();
				accountDetailActivity.getAccountDetailDataThread = null;
			}
			if (msg.what == Constant.GET_DATA_NULL
					|| msg.what == Constant.PARSING_ERROR) {
				DialogUtil.createShortDialog(accountDetailActivity, "您的网络貌似不给力，请重试");
			} else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION
					|| msg.what == Constant.GET_WEB_DATA_FALSE) {
				DialogUtil.createShortDialog(accountDetailActivity, (String) msg.obj);
			} else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
				accountDetailActivity.imageLoader.displayImage(accountDetailActivity.accountDetail.getHeadImageURL(), accountDetailActivity.AccountHeadImage, accountDetailActivity.displayImageOptions);
				if (accountDetailActivity.accountDetail.getAccountName().equals("anyType{}") || accountDetailActivity.accountDetail.getAccountName().equals("")) {
					accountDetailActivity.AccountNameTextView.setText("无");
				} else {
					accountDetailActivity.AccountNameTextView.setText(accountDetailActivity.accountDetail.getAccountName());
				}
				accountDetailActivity.createMobileTableRow();
				accountDetailActivity.createTitleAndDepartment();
				accountDetailActivity.createExpertTableRow();
				accountDetailActivity.createBranchName();
				accountDetailActivity.createIntroductionTableRow();
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(accountDetailActivity, accountDetailActivity.getString(R.string.login_error_message));
				accountDetailActivity.userInfoApplication.exitForLogin(accountDetailActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + accountDetailActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(accountDetailActivity);
				accountDetailActivity.packageUpdateUtil = new PackageUpdateUtil(accountDetailActivity, accountDetailActivity.mHandler, fileCache, downloadFileUrl, false, accountDetailActivity.userInfoApplication);
				accountDetailActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				accountDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = accountDetailActivity.getFileStreamPath(filename);
				file.getName();
				accountDetailActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
		}
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_account_detail);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		AccountNameTextView = (TextView) findViewById(R.id.account_name);
		AccountHeadImage = (ImageView) findViewById(R.id.account_headimage);
		userInfoApplication = (UserInfoApplication) getApplication();
		mLayoutInflater = getLayoutInflater();
		imageLoader =ImageLoader.getInstance();
		displayImageOptions=ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
		accountDetail = new AccountDetailInfo();
		accountDetail.setAccountID(getIntent().getStringExtra("AccountID"));
		getAccountDetailData();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		
	}
	
	private void getAccountDetailData(){
		if(getAccountDetailDataThread == null){
			showProgressDialog();
			createGetAccountDetailTask();
			getAccountDetailDataThread = new GetBackendServerDataByWebserviceThread(getAccountDetailTask,false);
			getAccountDetailDataThread.start();
		}
	}
	
	private void createGetAccountDetailTask(){
		if(getAccountDetailTask == null){
			JSONObject  accountJsonParam=new JSONObject();
			try {
				accountJsonParam.put("AccountID", accountDetail.getAccountID());
				if (userInfoApplication.getScreenWidth() == 720) {
					accountJsonParam.put("ImageWidth", String.valueOf(150));
					accountJsonParam.put("ImageHeight", String.valueOf(150));
				} else if (userInfoApplication.getScreenWidth() == 480) {
					accountJsonParam.put("ImageWidth", String.valueOf(132));
					accountJsonParam.put("ImageHeight", String.valueOf(132));
				} else if (userInfoApplication.getScreenWidth() == 1080) {
					accountJsonParam.put("ImageWidth", String.valueOf(300));
					accountJsonParam.put("ImageHeight", String.valueOf(300));
				} else if (userInfoApplication.getScreenWidth() == 1536) {
					accountJsonParam.put("ImageWidth", String.valueOf(366));
					accountJsonParam.put("ImageHeight", String.valueOf(366));
				} else {
					accountJsonParam.put("ImageWidth", String.valueOf(150));
					accountJsonParam.put("ImageHeight", String.valueOf(150));
				}
			} catch (JSONException e) {
				
			}
			getAccountDetailTask = new GetServerAccountDetailDataTaskImpl(accountJsonParam, mHandler, accountDetail,userInfoApplication);
		}
	}
	
	private void createMobileTableRow() {
		TableLayout tableLayoutPhone = (TableLayout) findViewById(R.id.account_phone);
		tableLayoutPhone.removeAllViews();
		if (!accountDetail.getMobile().equals("")) {
			createTableLayout(tableLayoutPhone, 2, getString(R.string.phone), accountDetail.getMobile());
		} else {
			tableLayoutPhone.setVisibility(View.GONE);
		}
	}

	private void createTitleAndDepartment() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_title_and_department);
		tableLayout.removeAllViews();
		if ((accountDetail.getTitle().equals(""))
				&& (accountDetail.getDepartment().equals(""))) {
			tableLayout.setVisibility(View.GONE);
		}
		if (!accountDetail.getTitle().equals("")) {
			createTableLayout(tableLayout, 2, getString(R.string.title), accountDetail.getTitle());
		}

		if (!accountDetail.getDepartment().equals("")) {
			tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			createTableLayout(tableLayout, 2, getString(R.string.department),accountDetail.getDepartment());
		}

	}

	private void createBranchName() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_branch_name);
		tableLayout.removeAllViews();
		if (!accountDetail.getBranchName().equals("")) {
			createTableLayout(tableLayout, 1, getString(R.string.branch), accountDetail.getBranchName());
		} else {
			tableLayout.setVisibility(View.GONE);
		}

	}

	private void createExpertTableRow() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_expert);
		tableLayout.removeAllViews();
		if (!accountDetail.getExpert().equals("")) {
			createTableLayout(tableLayout, 1, getString(R.string.expert), accountDetail.getExpert());
		} else {
			tableLayout.setVisibility(View.GONE);
		}

	}

	private void createIntroductionTableRow() {
		TableLayout tableLayout = (TableLayout) findViewById(R.id.account_introduction);
		tableLayout.removeAllViews();
		if (!accountDetail.getIntroduction().equals("")) {
			createTableLayout(tableLayout, 1, getString(R.string.introduction),accountDetail.getIntroduction());
		} else {
			tableLayout.setVisibility(View.GONE);
		}

	}

	private void createTableLayout(TableLayout tableLayout, int flag,
			String title, String content) {
		// 一行显示一个textview
		if (flag == 1) {
			RelativeLayout titleLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
			RelativeLayout contentLayout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_one_child_view, null);
			TextView titleTextView = (TextView) titleLayout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.blue));
			TextView contentTextView = (TextView) contentLayout.findViewById(R.id.left_textview);
			contentTextView.setText(content);
			tableLayout.addView(titleLayout);
			tableLayout.addView(mLayoutInflater.inflate(R.xml.shape_straight_line, null),new TableLayout.LayoutParams(LayoutParams.MATCH_PARENT, 1));
			tableLayout.addView(contentLayout);
		} else if (flag == 2) {
			RelativeLayout Layout = (RelativeLayout) mLayoutInflater.inflate(R.xml.relativelayout_has_two_child_view, null);
			TextView titleTextView = (TextView) Layout.findViewById(R.id.left_textview);
			titleTextView.setText(title);
			titleTextView.setTextColor(this.getResources().getColor(R.color.blue));
			TextView contentTextView = (TextView) Layout.findViewById(R.id.right_textview);
			contentTextView.setText(content);			
			tableLayout.addView(Layout);
		}
	}
	
	private void showProgressDialog(){
		if(progressDialog == null){
			progressDialog = ProgressDialogUtil.createProgressDialog(this);
		}
	}
	
	private void dismissProgressDialog(){
		if (progressDialog != null) {
			progressDialog.dismiss();
		}
	}
}
