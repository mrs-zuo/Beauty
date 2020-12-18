package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByWebserviceThread;
import com.GlamourPromise.Beauty.adapter.BranchListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetServerBranchListDataTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

public class BranchListActivity extends BaseActivity implements OnItemClickListener{
	private BranchListActivityHandler mHandler = new BranchListActivityHandler(this);
	private Thread getBranchListDataThread;
	private ProgressDialog progressDialog;
	private UserInfoApplication userInfoApplication;
	private ArrayList<BranchInfo> branchList;
	private BranchListAdapter branchListAdapter;
	private ListView branchListView;
	private GetServerBranchListDataTaskImpl getBranchListTask;
	private PackageUpdateUtil packageUpdateUtil;

	private static class BranchListActivityHandler extends Handler {
		private final BranchListActivity branchListActivity;

		private BranchListActivityHandler(BranchListActivity activity) {
			WeakReference<BranchListActivity> weakReference = new WeakReference<BranchListActivity>(activity);
			branchListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			branchListActivity.dismissProgressDialog();
			if (branchListActivity.getBranchListDataThread != null) {
				branchListActivity.getBranchListDataThread.interrupt();
				branchListActivity.getBranchListDataThread = null;
			}
			if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
				DialogUtil.createShortDialog(branchListActivity, "您的网络貌似不给力，请重试");
			} else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
				DialogUtil.createShortDialog(branchListActivity, (String) msg.obj);
			} else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
				branchListActivity.branchList = (ArrayList<BranchInfo>) msg.obj;
				branchListActivity.branchListAdapter = new BranchListAdapter(branchListActivity, branchListActivity.branchList);
				branchListActivity.branchListView.setAdapter(branchListActivity.branchListAdapter);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(branchListActivity, branchListActivity.getString(R.string.login_error_message));
				branchListActivity.userInfoApplication.exitForLogin(branchListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + branchListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(branchListActivity);
				branchListActivity.packageUpdateUtil = new PackageUpdateUtil(branchListActivity, branchListActivity.mHandler, fileCache, downloadFileUrl, false, branchListActivity.userInfoApplication);
				branchListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				branchListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = branchListActivity.getFileStreamPath(filename);
				file.getName();
				branchListActivity.packageUpdateUtil.showInstallDialog();
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
		setContentView(R.layout.activity_branch_list);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);

		branchListView = (ListView) findViewById(R.id.branch_listview);
		userInfoApplication = (UserInfoApplication) getApplication();
		branchListView.setOnItemClickListener(this);
		createGetBranchListTask();
		
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		getBranchListData();
	}
	
	private void createGetBranchListTask(){
		JSONObject branchListJson=new JSONObject();
		getBranchListTask = new GetServerBranchListDataTaskImpl(branchListJson,mHandler,userInfoApplication);
	}
	
	private void showProgressDialog(){
		if(progressDialog == null){
			progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
		}
		progressDialog.show();
	}
	
	private void dismissProgressDialog(){
		if (progressDialog != null) {
			progressDialog.dismiss();
		}
	}
	
	private void getBranchListData(){
		if(getBranchListDataThread == null){
//			showProgressDialog();
			progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
			progressDialog.setMessage(getString(R.string.please_wait));
			progressDialog.show();
			getBranchListDataThread = new GetBackendServerDataByWebserviceThread(getBranchListTask,true);
			getBranchListDataThread.start();
		}
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		// TODO Auto-generated method stub
		Intent intent = new Intent(this, BranchDetailActivity.class);
		intent.putExtra("BranchID", branchList.get(arg2).getId());
		intent.putExtra("Flag", AccountListActivity.BRANCH_ACCOUNT_LIST_FLAG);
		startActivity(intent);
	}

}
