package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.AddTagTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.io.File;
import java.lang.ref.WeakReference;

public class AddLabelActivity extends BaseActivity{
	private AddLabelActivityHandler mHandler = new AddLabelActivityHandler(this);
	public final static String LABEL_Content_TITLE = "label_content";
	private EditText labelContentView;
	private GetBackendServerDataByJsonThread addDataThread;
	private AddTagTaskImpl addTagTask;
	private UserInfoApplication userInfo;
	private ProgressDialog progressDialog;
	private PackageUpdateUtil packageUpdateUtil;

	private static class AddLabelActivityHandler extends Handler {
		private final AddLabelActivity addLabelActivity;

		private AddLabelActivityHandler(AddLabelActivity activity) {
			WeakReference<AddLabelActivity> weakReference = new WeakReference<AddLabelActivity>(activity);
			addLabelActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			addLabelActivity.dismissProgressDialog();
			if (addLabelActivity.addDataThread != null) {
				addLabelActivity.addDataThread.interrupt();
				addLabelActivity.addDataThread = null;
			}
			if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
				DialogUtil.createShortDialog(addLabelActivity, "您的网络貌似不给力，请重试");
			} else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
				DialogUtil.createShortDialog(addLabelActivity, (String) msg.obj);
			} else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
				DialogUtil.createShortDialog(addLabelActivity, "添加标签成功！");
				String content = String.valueOf(addLabelActivity.labelContentView.getText());
				addLabelActivity.finishActivity(content);
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(addLabelActivity, addLabelActivity.getString(R.string.login_error_message));
				addLabelActivity.userInfo.exitForLogin(addLabelActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + addLabelActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(addLabelActivity);
				addLabelActivity.packageUpdateUtil = new PackageUpdateUtil(addLabelActivity, addLabelActivity.mHandler, fileCache, downloadFileUrl, false, addLabelActivity.userInfo);
				addLabelActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				addLabelActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = addLabelActivity.getFileStreamPath(filename);
				file.getName();
				addLabelActivity.packageUpdateUtil.showInstallDialog();
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
		setContentView(R.layout.activity_add_label);
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		
		labelContentView = (EditText) findViewById(R.id.content_edit);
		((Button)findViewById(R.id.confirm_button)).setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View view) {
				if(ProgressDialogUtil.isFastClick())
					return;
				if(labelContentView.getText().toString().trim().equals("")){
					DialogUtil.createShortDialog(AddLabelActivity.this, "内容不能为空");
				}else{
					addTag();
				}
			}
		});
		
		userInfo = (UserInfoApplication) getApplication();
	}
	
	private void addTag(){
		String content = String.valueOf(labelContentView.getText().toString());
		if(addTagTask == null)
			addTagTask = new AddTagTaskImpl(userInfo.getAccountInfo().getCompanyId(), userInfo.getAccountInfo().getBranchId(), userInfo.getAccountInfo().getAccountId(), content, mHandler,userInfo);
		addTagTask.setLabelContent(content);
		if(addDataThread == null){
			showProgressDialog();
			addDataThread = new GetBackendServerDataByJsonThread(addTagTask);
			addDataThread.start();
		}
	}
	
	private void finishActivity(String labelContent){
		Intent intent = new Intent();
		intent.putExtra(LABEL_Content_TITLE, labelContent);
		setResult(RESULT_OK, intent);
		this.finish();
	}
	
	private void showProgressDialog(){
		if(progressDialog == null){
			progressDialog=ProgressDialogUtil.createProgressDialog(this);
		}
	}
	
	private void dismissProgressDialog(){
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog=null;
		}
	}
}
