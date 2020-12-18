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
import android.widget.ImageView;
import android.widget.ListView;

import com.GlamourPromise.Beauty.Thread.GetBackendServerDataByJsonThread;
import com.GlamourPromise.Beauty.adapter.LabelListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.implementation.GetTagListTaskImpl;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;

public class LabelListActivity extends BaseActivity{
	private LabelListActivityHandler mHandler = new LabelListActivityHandler(this);
	public final static String LABEL_CONTENT_LIST = "label_content_list";
	public final static String SELECT_LABEL_LIST_ID = "select_label_list_id";
	public final static String LIMIT_NUM_FLAG = "limit_num_flag";
	public final static String IS_SHOW_ADD_NEW_LABEL_BUTTON_PROMPT = "isShowButton";
	
	private ArrayList<Integer> hasSelectedLabelIDList;
	private Boolean limitSelectNumFlag = false;
	private ListView labelListView;
	private ImageView addNewLabelButton;
	private ArrayList<LabelInfo> labelList;
	private LabelListAdapter labelListAdpter;
	private GetBackendServerDataByJsonThread getDataThread;
	private GetTagListTaskImpl getTagListTask;
	private UserInfoApplication userInfo;
	private ProgressDialog progressDialog;
	private PackageUpdateUtil packageUpdateUtil;

	private static class LabelListActivityHandler extends Handler {
		private final LabelListActivity labelListActivity;

		private LabelListActivityHandler(LabelListActivity activity) {
			WeakReference<LabelListActivity> weakReference = new WeakReference<LabelListActivity>(activity);
			labelListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			labelListActivity.dismissProgressDialog();
			if (labelListActivity.getDataThread != null) {
				labelListActivity.getDataThread.interrupt();
				labelListActivity.getDataThread = null;
			}
			if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
				DialogUtil.createShortDialog(labelListActivity, "您的网络貌似不给力，请重试");
			} else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION || msg.what == Constant.GET_WEB_DATA_FALSE) {
				DialogUtil.createShortDialog(labelListActivity, (String) msg.obj);
			} else if (msg.what == Constant.GET_WEB_DATA_TRUE) {
				labelListActivity.labelList.clear();
				labelListActivity.labelList.addAll((ArrayList<LabelInfo>) msg.obj);
				if (labelListActivity.limitSelectNumFlag) {
					labelListActivity.labelListAdpter = new LabelListAdapter(labelListActivity, labelListActivity.labelList, labelListActivity.hasSelectedLabelIDList, 3);
				} else {
					labelListActivity.labelListAdpter = new LabelListAdapter(labelListActivity, labelListActivity.labelList, labelListActivity.hasSelectedLabelIDList, -1);
				}
				labelListActivity.labelListView.setAdapter(labelListActivity.labelListAdpter);
				labelListActivity.labelListAdpter.notifyDataSetChanged();
			} else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(labelListActivity, labelListActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(labelListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + labelListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(labelListActivity);
				labelListActivity.packageUpdateUtil = new PackageUpdateUtil(labelListActivity, labelListActivity.mHandler, fileCache, downloadFileUrl, false, labelListActivity.userInfo);
				labelListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				labelListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = labelListActivity.getFileStreamPath(filename);
				file.getName();
				labelListActivity.packageUpdateUtil.showInstallDialog();
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
		setContentView(R.layout.activity_label_seelct);
		Intent intent = getIntent();
		if(intent.hasExtra(LIMIT_NUM_FLAG)){
			limitSelectNumFlag = intent.getBooleanExtra(LIMIT_NUM_FLAG, false);
		}
		if(intent.hasExtra(SELECT_LABEL_LIST_ID)){
			hasSelectedLabelIDList = intent.getIntegerArrayListExtra(SELECT_LABEL_LIST_ID);
		}
		//是否显示增加标签按钮
		addNewLabelButton = (ImageView)findViewById(R.id.add_new_label_icon);
		if(intent.hasExtra(IS_SHOW_ADD_NEW_LABEL_BUTTON_PROMPT)){
			Boolean tmp = intent.getBooleanExtra(IS_SHOW_ADD_NEW_LABEL_BUTTON_PROMPT, true);
			if(tmp){
				addNewLabelButton.setOnClickListener(new OnClickListener() {
					
					@Override
					public void onClick(View arg0) {
						// TODO Auto-generated method stub
						Intent intent = new Intent(LabelListActivity.this, AddLabelActivity.class);
						startActivityForResult(intent, 0);
					}
				});
			}else{
				addNewLabelButton.setVisibility(View.GONE);
			}
		}else{
			addNewLabelButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					// TODO Auto-generated method stub
					Intent intent = new Intent(LabelListActivity.this, AddLabelActivity.class);
					startActivityForResult(intent, 0);
				}
			});
		}
		
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		((Button)findViewById(R.id.confirm_button)).setOnClickListener(new OnClickListener() {

					@Override
					public void onClick(View arg0) {
						// TODO Auto-generated method stub
						setResult(RESULT_OK);
						finishActivity();
					}
				});
		labelListView = (ListView) findViewById(R.id.label_listview);
		userInfo = (UserInfoApplication) getApplication();
		labelList = new ArrayList<LabelInfo>();
	}
	
	@Override
	protected void onResume(){
		super.onResume();
		getData();
	}
	
	private void getData(){
		if(getDataThread == null){
			getDataThread = new GetBackendServerDataByJsonThread(getBackendServerDataTask());
			getDataThread.start();
		}
	}
	
	private GetTagListTaskImpl getBackendServerDataTask(){
		if(getTagListTask == null){
			showProgressDialog();
			getTagListTask = new GetTagListTaskImpl(mHandler,userInfo,1);
		}
		return getTagListTask;
	}
	
	private void finishActivity(){
		HashMap<Integer, LabelInfo> selectLabelHashMap = labelListAdpter.getSelectLabelHashMap();
		Intent intent = new Intent();
		Bundle mBundle = new Bundle();
		mBundle.putSerializable(LABEL_CONTENT_LIST,(Serializable)selectLabelHashMap);
		intent.putExtras(mBundle);
		setResult(RESULT_OK, intent);
		this.finish();
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode == RESULT_OK){
			if(labelList != null){
				getData();
			}
			
		}
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
}
