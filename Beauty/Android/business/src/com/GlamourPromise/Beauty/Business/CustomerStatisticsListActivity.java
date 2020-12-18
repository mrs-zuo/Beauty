package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.CustomerStatisticsListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CustomerStatistics;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
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

@SuppressLint("ResourceType")
public class CustomerStatisticsListActivity extends BaseActivity implements OnClickListener{
	private CustomerStatisticsListActivityHandler mHandler = new CustomerStatisticsListActivityHandler(this);
	private UserInfoApplication      userinfoApplication;
	private ProgressDialog           progressDialog;
	private Thread                   requestWebServiceThread;
	private PackageUpdateUtil        packageUpdateUtil;
	private List<CustomerStatistics> customerStatisticsList;
	private ListView                 customerStatisticsListView;
	private Button                   switchServiceBtn,switchCommodityBtn;
	private int                      objectType=0;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_statistics_list);
		initView();
	}
	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication=UserInfoApplication.getInstance();
		((TextView)findViewById(R.id.customer_statistics_list_title_text)).setText("消费倾向分析"+"("+userinfoApplication.getSelectedCustomerName()+")");
		customerStatisticsListView=(ListView)findViewById(R.id.customer_statistics_list_listview);
		switchServiceBtn=(Button)findViewById(R.id.switch_service_btn);
		switchServiceBtn.setOnClickListener(this);
		switchCommodityBtn=(Button)findViewById(R.id.switch_commodity_btn);
		switchCommodityBtn.setOnClickListener(this);
		objectType=0;
		getCustomerStatisticsPieData();
	}

	private static class CustomerStatisticsListActivityHandler extends Handler {
		private final CustomerStatisticsListActivity customerStatisticsListActivity;

		private CustomerStatisticsListActivityHandler(CustomerStatisticsListActivity activity) {
			WeakReference<CustomerStatisticsListActivity> weakReference = new WeakReference<CustomerStatisticsListActivity>(activity);
			customerStatisticsListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (customerStatisticsListActivity.progressDialog != null) {
				customerStatisticsListActivity.progressDialog.dismiss();
				customerStatisticsListActivity.progressDialog = null;
			}
			if (message.what == 1) {
				customerStatisticsListActivity.customerStatisticsListView.setAdapter(new CustomerStatisticsListAdapter(customerStatisticsListActivity, customerStatisticsListActivity.customerStatisticsList, customerStatisticsListActivity.objectType));
			} else if (message.what == 2)
				DialogUtil.createShortDialog(customerStatisticsListActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(customerStatisticsListActivity, customerStatisticsListActivity.getString(R.string.login_error_message));
				customerStatisticsListActivity.userinfoApplication.exitForLogin(customerStatisticsListActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + customerStatisticsListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(customerStatisticsListActivity);
				customerStatisticsListActivity.packageUpdateUtil = new PackageUpdateUtil(customerStatisticsListActivity, customerStatisticsListActivity.mHandler, fileCache, downloadFileUrl, false, customerStatisticsListActivity.userinfoApplication);
				customerStatisticsListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				customerStatisticsListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = customerStatisticsListActivity.getFileStreamPath(filename);
				file.getName();
				customerStatisticsListActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (customerStatisticsListActivity.requestWebServiceThread != null) {
				customerStatisticsListActivity.requestWebServiceThread.interrupt();
				customerStatisticsListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void getCustomerStatisticsPieData(){
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		progressDialog.setCanceledOnTouchOutside(false);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetDataStatisticsList";
				String endPoint = "Statistics";
				JSONObject getDataStatisticsJson=new JSONObject();
				try {
					getDataStatisticsJson.put("CustomerID",userinfoApplication.getSelectedCustomerID());
					getDataStatisticsJson.put("ObjectType",objectType);
					getDataStatisticsJson.put("ExtractItemType",1);
				} catch (JSONException e) {
				}
				String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint,methodName,getDataStatisticsJson.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverRequestResult);
				} catch (JSONException e2) {
				}
				if (serverRequestResult == null || serverRequestResult.equals(""))
					mHandler.sendEmptyMessage(2);
				else {
					int    code = 0;
					String message = "";
					try {
						code = resultJson.getInt("Code");
						message = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						JSONArray statisticsJsonArray = null;
						try {
							statisticsJsonArray=resultJson.getJSONArray("Data");
						} catch (JSONException e) {
						}
						customerStatisticsList = new ArrayList<CustomerStatistics>();
						if (statisticsJsonArray != null) {
							for (int i = 0; i < statisticsJsonArray.length(); i++) {
								CustomerStatistics cs=new CustomerStatistics();
								JSONObject csJson = null;
								try {
									csJson = (JSONObject) statisticsJsonArray.get(i);
								} catch (JSONException e) {
								}
								int    objectCount=0;//服务次数或者商品个数
							    String objectName="";//抽取名
								try {
									if(csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")){
										objectCount=csJson.getInt("ObjectCount");
									}
									if(csJson.has("ObjectName") && !csJson.isNull("ObjectName")){
										objectName=csJson.getString("ObjectName");
									}
								} catch (JSONException e) {
								}
								cs.setObjectCount(objectCount);
								cs.setObjectName(objectName);
								customerStatisticsList.add(cs);
							}
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
	protected void  switchServiceCommodity(int productType){
		if(productType==0){
			switchServiceBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
			switchServiceBtn.setTextColor(getResources().getColor(R.color.white));
			switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
			switchCommodityBtn.setTextColor(getResources().getColor(R.color.blue));
			objectType=0;
			getCustomerStatisticsPieData();
		}
		else if(productType==1){
			switchServiceBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
			switchServiceBtn.setTextColor(getResources().getColor(R.color.blue));
			switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
			switchCommodityBtn.setTextColor(getResources().getColor(R.color.white));
			objectType=1;
			getCustomerStatisticsPieData();
		}
	}
	@Override
	public void onClick(View view) {
		switch(view.getId()){
		case R.id.switch_service_btn:
			switchServiceCommodity(0);
			break;
		case R.id.switch_commodity_btn:
			switchServiceCommodity(1);
			break;
		}
	}
}
