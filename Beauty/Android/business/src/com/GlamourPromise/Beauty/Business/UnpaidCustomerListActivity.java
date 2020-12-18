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
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;

import com.GlamourPromise.Beauty.adapter.UnpaidCustomerListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.UnpaidCustomerInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
//结账列表-当前登录门店所有未结账的客户列表
public class UnpaidCustomerListActivity extends BaseActivity implements OnItemClickListener ,OnQueryTextListener{
	private UnpaidCustomerListActivityHandler mHandler = new UnpaidCustomerListActivityHandler(this);
	private ListView unpaidCustomerListView;
	private Thread requestWebServiceThread;
	private ProgressDialog progressDialog;
	private List<UnpaidCustomerInfo> unpaidCustomerList;
	private List<UnpaidCustomerInfo> customerList;
	private UserInfoApplication userinfoApplication;
	private UnpaidCustomerListAdapter  unpaidCustomerListAdapter;
	private PackageUpdateUtil packageUpdateUtil;
	private SearchView searchCustomerView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_unpaid_customer_list);
		userinfoApplication = UserInfoApplication.getInstance();
		searchCustomerView = (SearchView) findViewById(R.id.search_customer);
		searchCustomerView.setOnQueryTextListener(this);
		customerList = new ArrayList<UnpaidCustomerInfo>();
		initView();
	}

	private static class UnpaidCustomerListActivityHandler extends Handler {
		private final UnpaidCustomerListActivity unpaidCustomerListActivity;

		private UnpaidCustomerListActivityHandler(UnpaidCustomerListActivity activity) {
			WeakReference<UnpaidCustomerListActivity> weakReference = new WeakReference<UnpaidCustomerListActivity>(activity);
			unpaidCustomerListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message msg) {
			if (unpaidCustomerListActivity.progressDialog != null) {
				unpaidCustomerListActivity.progressDialog.dismiss();
				unpaidCustomerListActivity.progressDialog = null;
			}
			if (msg.what == 1) {
				unpaidCustomerListActivity.unpaidCustomerListAdapter = new UnpaidCustomerListAdapter(unpaidCustomerListActivity, unpaidCustomerListActivity.unpaidCustomerList);
				unpaidCustomerListActivity.unpaidCustomerListView.setAdapter(unpaidCustomerListActivity.unpaidCustomerListAdapter);
			} else if (msg.what == 0)
				DialogUtil.createShortDialog(unpaidCustomerListActivity, "您的网络貌似不给力，请重试");
			else if (msg.what == 2)
				DialogUtil.createShortDialog(unpaidCustomerListActivity, (String) msg.obj);
			else if (msg.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(unpaidCustomerListActivity, unpaidCustomerListActivity.getString(R.string.login_error_message));
				unpaidCustomerListActivity.userinfoApplication.exitForLogin(unpaidCustomerListActivity);
			} else if (msg.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + unpaidCustomerListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(unpaidCustomerListActivity);
				unpaidCustomerListActivity.packageUpdateUtil = new PackageUpdateUtil(unpaidCustomerListActivity, unpaidCustomerListActivity.mHandler, fileCache, downloadFileUrl, false, unpaidCustomerListActivity.userinfoApplication);
				unpaidCustomerListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) msg.obj);
				unpaidCustomerListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (msg.what == 5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = unpaidCustomerListActivity.getFileStreamPath(filename);
				file.getName();
				unpaidCustomerListActivity.packageUpdateUtil.showInstallDialog();
			} else if (msg.what == -5) {
				((DownloadInfo) msg.obj).getUpdateDialog().cancel();
			} else if (msg.what == 7) {
				int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
				((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (unpaidCustomerListActivity.requestWebServiceThread != null) {
				unpaidCustomerListActivity.requestWebServiceThread.interrupt();
				unpaidCustomerListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		unpaidCustomerListView = (ListView) findViewById(R.id.unpaid_customer_list_view);
		unpaidCustomerListView.setOnItemClickListener(this);
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebService();
	}

	private void requestWebService() {
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "getUnPaidList";
				String endPoint = "payment";
				JSONObject unpaidCustomerJson = new JSONObject();
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName, unpaidCustomerJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e2) {
				}
				if (serverRequestResult == null
						|| serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(0);
				else {
					int    code = 0;
					String message = "";
					try {
						code =   resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code =0;
					}
					if (code== 1) {
						JSONArray unpaidCustomerArray= null;
						unpaidCustomerList = new ArrayList<UnpaidCustomerInfo>();
						try {
							unpaidCustomerArray = resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						if (unpaidCustomerArray != null) {
							for (int i = 0; i < unpaidCustomerArray.length(); i++) {
								UnpaidCustomerInfo unpaidCustomerInfo = new UnpaidCustomerInfo();
								JSONObject unpaidCustomerJsonObj= null;
								try {
									unpaidCustomerJsonObj = (JSONObject)unpaidCustomerArray.get(i);
								} catch (JSONException e1) {									
								}
								int customerID = 0;
								String customerName ="";
								String lastTime ="";
								String loginMobile ="";
								String loginMobileShow="";
								int    unpaidOrderCount=0;
								try {
									if (unpaidCustomerJsonObj.has("CustomerID") && !unpaidCustomerJsonObj.isNull("CustomerID"))
										customerID = unpaidCustomerJsonObj.getInt("CustomerID");
									if (unpaidCustomerJsonObj.has("CustomerName") && !unpaidCustomerJsonObj.isNull("CustomerName"))
										customerName = unpaidCustomerJsonObj.getString("CustomerName");
									if (unpaidCustomerJsonObj.has("LastTime") && !unpaidCustomerJsonObj.isNull("LastTime"))
										lastTime = unpaidCustomerJsonObj.getString("LastTime");
									if (unpaidCustomerJsonObj.has("LoginMobileSearch") && !unpaidCustomerJsonObj.isNull("LoginMobileSearch"))
										loginMobile = unpaidCustomerJsonObj.getString("LoginMobileSearch");
									if (unpaidCustomerJsonObj.has("LoginMobileShow") && !unpaidCustomerJsonObj.isNull("LoginMobileShow"))
										loginMobileShow = unpaidCustomerJsonObj.getString("LoginMobileShow");
									if (unpaidCustomerJsonObj.has("OrderCount") && !unpaidCustomerJsonObj.isNull("OrderCount"))
										unpaidOrderCount = unpaidCustomerJsonObj.getInt("OrderCount");
								} catch (JSONException e) {
								}
								unpaidCustomerInfo.setCustomerID(customerID);
								unpaidCustomerInfo.setCustomerName(customerName);
								unpaidCustomerInfo.setLastOrderTime(lastTime);
								unpaidCustomerInfo.setCustomerLoginMobile(loginMobile);
								unpaidCustomerInfo.setUnPaidOrderCount(unpaidOrderCount);
								unpaidCustomerInfo.setCustomerLoginMobileShow(loginMobileShow);
								unpaidCustomerList.add(unpaidCustomerInfo);
							}
						mHandler.sendEmptyMessage(1);	
						}
						customerList=unpaidCustomerList;
					}
					else if(code==Constant.LOGIN_ERROR || code==Constant.APP_VERSION_ERROR){
						mHandler.sendEmptyMessage(code);
					}
					else{
						Message msg=new Message();
						msg.what=2;
						msg.obj=message;
						mHandler.sendMessage(msg);
					}
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
	//跳转到需结账的订单列表页
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		Intent destIntent=new Intent(this,CustomerUnpaidOrderActivity.class);
		destIntent.putExtra("FromSource",Constant.USER_ROLE_BUSINESS);
		destIntent.putExtra("CustomerID",customerList.get(position).getCustomerID());
		destIntent.putExtra("CustomerName",customerList.get(position).getCustomerName());
		destIntent.putExtra("BranchID",userinfoApplication.getAccountInfo().getBranchId());
		startActivity(destIntent);
	}

	@Override
	public boolean onQueryTextSubmit(String query) {
		return false;
	}

	@Override
	public boolean onQueryTextChange(String newText) {
		newText=newText.toLowerCase();
		List<UnpaidCustomerInfo> newUnpaidCustomerList = searchCustomer(newText);
		updateLayout(newUnpaidCustomerList);
		return false;
	}
	
	private List<UnpaidCustomerInfo> searchCustomer(String searchKeyWord) {
		List<UnpaidCustomerInfo> newUnpaidCustomerList = new ArrayList<UnpaidCustomerInfo>();
		if(searchKeyWord==null && searchKeyWord.equals("")){
			newUnpaidCustomerList=unpaidCustomerList;
		}else{
			for (UnpaidCustomerInfo unpaidCustomer : unpaidCustomerList) {
				if (unpaidCustomer.getCustomerLoginMobile().contains(searchKeyWord) || unpaidCustomer.getCustomerName().toLowerCase().contains(searchKeyWord.toLowerCase())) {
					newUnpaidCustomerList.add(unpaidCustomer);
				}
			}
		}
		return newUnpaidCustomerList;
	}
	private void updateLayout(List<UnpaidCustomerInfo> newUnpaidCustomerList) {
		customerList=newUnpaidCustomerList;
		unpaidCustomerListAdapter = new UnpaidCustomerListAdapter(this,customerList);
		unpaidCustomerListView.setAdapter(unpaidCustomerListAdapter);
		unpaidCustomerListAdapter.notifyDataSetChanged();
	}
}
