package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CustomerStatistics;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.chart.AChartPie;
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
public class CustomerStatisticsPieActivity extends BaseActivity implements OnClickListener{
	private CustomerStatisticsPieActivityHandler mHandler = new CustomerStatisticsPieActivityHandler(this);
	private UserInfoApplication      userinfoApplication;
	private ProgressDialog           progressDialog;
	private Thread                   requestWebServiceThread;
	private PackageUpdateUtil        packageUpdateUtil;
	private List<CustomerStatistics> customerStatisticsList;
	private int                      type;
	private Button                   switchServiceBtn,switchCommodityBtn;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_customer_statistics_pie);
		initView();
	}
	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication=UserInfoApplication.getInstance();
		((TextView)findViewById(R.id.customer_statistics_pie_title_text)).setText("消费倾向分析"+"("+userinfoApplication.getSelectedCustomerName()+")");
		switchServiceBtn=(Button)findViewById(R.id.switch_service_btn);
		switchServiceBtn.setOnClickListener(this);
		switchCommodityBtn=(Button)findViewById(R.id.switch_commodity_btn);
		switchCommodityBtn.setOnClickListener(this);
		Intent intent=getIntent();
		type=intent.getIntExtra("Type",1);
		if(type==1){
			((TextView)findViewById(R.id.customer_statistics_pie_small_title)).setText(getResources().getString(R.string.customer_statistics_pie_small_title));
		}
		else if(type==2){
			((TextView)findViewById(R.id.customer_statistics_pie_small_title)).setText(getResources().getString(R.string.customer_statistics_pie_small2_title));
		}
		getCustomerStatisticsPieData(0);
	}

	private static class CustomerStatisticsPieActivityHandler extends Handler {
		private final CustomerStatisticsPieActivity customerStatisticsPieActivity;

		private CustomerStatisticsPieActivityHandler(CustomerStatisticsPieActivity activity) {
			WeakReference<CustomerStatisticsPieActivity> weakReference = new WeakReference<CustomerStatisticsPieActivity>(activity);
			customerStatisticsPieActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (customerStatisticsPieActivity.progressDialog != null) {
				customerStatisticsPieActivity.progressDialog.dismiss();
				customerStatisticsPieActivity.progressDialog = null;
			}
			if (message.what == 1) {
				((LinearLayout) customerStatisticsPieActivity.findViewById(R.id.customer_statistics_pie_linearlayout)).removeAllViews();
				if (customerStatisticsPieActivity.customerStatisticsList != null && customerStatisticsPieActivity.customerStatisticsList.size() > 0) {
					String[] objectName = null;
					double[] objectCount = null;
					double total = 0;
					//如果消费小于十个
					if (customerStatisticsPieActivity.customerStatisticsList.size() <= 10) {
						objectName = new String[customerStatisticsPieActivity.customerStatisticsList.size()];
						objectCount = new double[customerStatisticsPieActivity.customerStatisticsList.size()];
						for (int j = 0; j < customerStatisticsPieActivity.customerStatisticsList.size(); j++) {
							objectName[j] = customerStatisticsPieActivity.customerStatisticsList.get(j).getObjectName();
							objectCount[j] = customerStatisticsPieActivity.customerStatisticsList.get(j).getObjectCount();
							total += objectCount[j];
						}
					}
					//如果消费大于十个
					else if (customerStatisticsPieActivity.customerStatisticsList.size() > 10) {
						objectName = new String[11];
						objectCount = new double[11];
						//取出前十个
						for (int j = 0; j < 10; j++) {
							objectName[j] = customerStatisticsPieActivity.customerStatisticsList.get(j).getObjectName();
							objectCount[j] = customerStatisticsPieActivity.customerStatisticsList.get(j).getObjectCount();
							total += objectCount[j];
						}
						objectName[10] = "其他";
						double totalOther = 0;
						for (int a = 10; a < customerStatisticsPieActivity.customerStatisticsList.size(); a++) {
							totalOther += customerStatisticsPieActivity.customerStatisticsList.get(a).getObjectCount();
						}
						objectCount[10] = totalOther;
						total += totalOther;
					}
					if (total != 0) {
						View view = new AChartPie(objectName, objectCount).execute(customerStatisticsPieActivity.getApplicationContext());
						((LinearLayout) customerStatisticsPieActivity.findViewById(R.id.customer_statistics_pie_linearlayout)).addView(view);
					}
				}
			} else if (message.what == 2)
				DialogUtil.createShortDialog(customerStatisticsPieActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(customerStatisticsPieActivity, customerStatisticsPieActivity.getString(R.string.login_error_message));
				customerStatisticsPieActivity.userinfoApplication.exitForLogin(customerStatisticsPieActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + customerStatisticsPieActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(customerStatisticsPieActivity);
				customerStatisticsPieActivity.packageUpdateUtil = new PackageUpdateUtil(customerStatisticsPieActivity, customerStatisticsPieActivity.mHandler, fileCache, downloadFileUrl, false, customerStatisticsPieActivity.userinfoApplication);
				customerStatisticsPieActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				customerStatisticsPieActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = customerStatisticsPieActivity.getFileStreamPath(filename);
				file.getName();
				customerStatisticsPieActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (customerStatisticsPieActivity.requestWebServiceThread != null) {
				customerStatisticsPieActivity.requestWebServiceThread.interrupt();
				customerStatisticsPieActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void getCustomerStatisticsPieData(final int objectType){
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
					if(type==1)
						getDataStatisticsJson.put("ExtractItemType",1);
					else if(type==2)
						getDataStatisticsJson.put("ExtractItemType",2);
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
									e.printStackTrace();
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
	//productType 0:服务  1:商品
	protected void  switchServiceCommodity(int productType){
		if(productType==0){
			switchServiceBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
			switchServiceBtn.setTextColor(getResources().getColor(R.color.white));
			switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
			switchCommodityBtn.setTextColor(getResources().getColor(R.color.blue));
			getCustomerStatisticsPieData(0);
		}
		else if(productType==1){
			switchServiceBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
			switchServiceBtn.setTextColor(getResources().getColor(R.color.blue));
			switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
			switchCommodityBtn.setTextColor(getResources().getColor(R.color.white));
			getCustomerStatisticsPieData(1);
		}
	}
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
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
