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

import com.GlamourPromise.Beauty.adapter.AllEcardHistroyListItemAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AllEcardHistroy;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.minterface.RefreshListViewWithWebservice;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.RefreshListView;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
public class AllEcardHistoryListActivity extends BaseActivity implements OnItemClickListener {
	private AllEcardHistoryListActivityHandler mHandler = new AllEcardHistoryListActivityHandler(this);
	private RefreshListView allEcardHistoryListView;
	private Thread          requestWebServiceThread;
	private ProgressDialog  progressDialog;
	private List<AllEcardHistroy> allEcardHistroyList;
	private UserInfoApplication userinfoApplication;
	private PackageUpdateUtil packageUpdateUtil;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_all_ecard_history_list);
		userinfoApplication = UserInfoApplication.getInstance();
		initView();
	}

	private static class AllEcardHistoryListActivityHandler extends Handler {
		private final AllEcardHistoryListActivity allEcardHistoryListActivity;

		private AllEcardHistoryListActivityHandler(AllEcardHistoryListActivity activity) {
			WeakReference<AllEcardHistoryListActivity> weakReference = new WeakReference<AllEcardHistoryListActivity>(activity);
			allEcardHistoryListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (allEcardHistoryListActivity.progressDialog != null) {
				allEcardHistoryListActivity.progressDialog.dismiss();
				allEcardHistoryListActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				allEcardHistoryListActivity.allEcardHistoryListView.setAdapter(new AllEcardHistroyListItemAdapter(allEcardHistoryListActivity, allEcardHistoryListActivity.allEcardHistroyList));
			} else if (msg.what == 2)
				DialogUtil.createShortDialog(allEcardHistoryListActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(allEcardHistoryListActivity, allEcardHistoryListActivity.getString(R.string.login_error_message));
				UserInfoApplication.getInstance().exitForLogin(allEcardHistoryListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + allEcardHistoryListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(allEcardHistoryListActivity);
				allEcardHistoryListActivity.packageUpdateUtil = new PackageUpdateUtil(allEcardHistoryListActivity, allEcardHistoryListActivity.mHandler, fileCache, downloadFileUrl, false, allEcardHistoryListActivity.userinfoApplication);
				allEcardHistoryListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				allEcardHistoryListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = allEcardHistoryListActivity.getFileStreamPath(filename);
				file.getName();
				allEcardHistoryListActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (allEcardHistoryListActivity.requestWebServiceThread != null) {
				allEcardHistoryListActivity.requestWebServiceThread.interrupt();
				allEcardHistoryListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		allEcardHistoryListView = (RefreshListView) findViewById(R.id.all_ecard_history_list_view);
		allEcardHistoryListView.setOnItemClickListener(this);
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		allEcardHistoryListView.setOnRefreshListener(new RefreshListViewWithWebservice() {

					@Override
					public Object refreshing() {
						// TODO Auto-generated method stub
						String returncode = "ok";
						if (requestWebServiceThread == null) {
							requestWebService();
						}
						return returncode;
					}

					@Override
					public void refreshed(Object obj) {
						// TODO Auto-generated method stub

					}
				});
		requestWebService();
	}

	private void requestWebService() {
		allEcardHistroyList = new ArrayList<AllEcardHistroy>();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				String methodName = "GetBalanceListByCustomerID";
				String endPoint = "ECard";
				JSONObject allEcardHistoryJsonParam=new JSONObject();
				try {
					allEcardHistoryJsonParam.put("CustomerID",userinfoApplication.getSelectedCustomerID());
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,allEcardHistoryJsonParam.toString(),userinfoApplication);
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					JSONObject resultJson=null;
					JSONArray  historyArray=null;
					int code=0;
					try {
						resultJson=new JSONObject(serverRequestResult);
						code=resultJson.getInt("Code");
					} catch (JSONException e) {
					}
					if(code==1){
						try {
							historyArray=resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						for (int i = 0; i < historyArray.length(); i++) {
							JSONObject historyJson=null;
							try {
								historyJson=historyArray.getJSONObject(i);
							} catch (JSONException e) {
							}
							int  balanceID=0;
							String changeTypeName="";
							String createTime="";
							int    changeType=0;
							int    targetAccount=0;
							try {
								if (historyJson.has("BalanceID") &&  !historyJson.isNull("BalanceID"))
									balanceID = historyJson.getInt("BalanceID");
								if (historyJson.has("ChangeTypeName") &&  !historyJson.isNull("ChangeTypeName"))
									changeTypeName =historyJson.getString("ChangeTypeName");
								if (historyJson.has("CreateTime") &&  !historyJson.isNull("CreateTime"))
									createTime = historyJson.getString("CreateTime");
								if (historyJson.has("ChangeType") &&  !historyJson.isNull("ChangeType"))
									changeType = historyJson.getInt("ChangeType");
								if (historyJson.has("TargetAccount") &&  !historyJson.isNull("TargetAccount"))
									targetAccount = historyJson.getInt("TargetAccount");
							} catch (JSONException e) {
							}
							AllEcardHistroy allEcardHistroy=new AllEcardHistroy();
							allEcardHistroy.setBalanceID(balanceID);
							allEcardHistroy.setChangeTypeName(changeTypeName);
							allEcardHistroy.setCreateTime(createTime);
							allEcardHistroy.setChangeType(changeType);
							allEcardHistroy.setTargetAccount(targetAccount);
							allEcardHistroyList.add(allEcardHistroy);
						}
						mHandler.sendEmptyMessage(1);
					}
					else
						mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		if (progressDialog != null) {
			progressDialog.dismiss();
			progressDialog = null;
		}
	}

	// 查看消费
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		// TODO Auto-generated method stub
		if(position!=0){
			int balanceID=allEcardHistroyList.get(position-1).getBalanceID();
			int cardType=allEcardHistroyList.get(position-1).getTargetAccount();
			int changeType=allEcardHistroyList.get(position-1).getChangeType();
			Intent destIntent=new Intent(this,EcardHistoryDetailActivity.class);
			destIntent.putExtra("balanceID",balanceID);
			destIntent.putExtra("cardType",cardType);
			destIntent.putExtra("changeType",changeType);
			startActivity(destIntent);
		}
	}
}
