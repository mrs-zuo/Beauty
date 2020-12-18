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
import com.GlamourPromise.Beauty.bean.BranchStatistics;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.chart.BarChartView;
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
/*
 *员工数据统计柱状图
 * */
@SuppressLint("ResourceType")
public class BranchEmployeeBusinessDetailBarChartActivity extends BaseActivity implements OnClickListener{
	private BranchEmployeeBusinessDetailBarChartActivityHandler mHandler = new BranchEmployeeBusinessDetailBarChartActivityHandler(this);
	private UserInfoApplication      userinfoApplication;
	private ProgressDialog           progressDialog;
	private Thread                   requestWebServiceThread;
	private PackageUpdateUtil        packageUpdateUtil;
	private List<BranchStatistics>   branchStatisticsList;
	private int  	 objectID,objectType;
	private Button   switchRechargeBtn,switchOperationBtn,switchSalesBtn;
	private Intent   intent;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_branch_employee_business_detail_bar_chart);
		initView();
	}
	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		userinfoApplication=UserInfoApplication.getInstance();
		switchRechargeBtn=(Button)findViewById(R.id.switch_recharge_btn);
		switchRechargeBtn.setOnClickListener(this);
		switchOperationBtn=(Button)findViewById(R.id.switch_operation_btn);
		switchOperationBtn.setOnClickListener(this);
		switchSalesBtn=(Button)findViewById(R.id.switch_sales_btn);
		switchSalesBtn.setOnClickListener(this);
		intent=getIntent();
		objectID=intent.getIntExtra("objectID",0);
		objectType=intent.getIntExtra("objectType",0);
		((TextView)findViewById(R.id.branch_employee_business_detail_bar_chart_title)).setText("个人业绩分类统计("+intent.getStringExtra("objectName")+")");
		switchBusinessType(objectType);
	}

	private static class BranchEmployeeBusinessDetailBarChartActivityHandler extends Handler {
		private final BranchEmployeeBusinessDetailBarChartActivity branchEmployeeBusinessDetailBarChartActivity;

		private BranchEmployeeBusinessDetailBarChartActivityHandler(BranchEmployeeBusinessDetailBarChartActivity activity) {
			WeakReference<BranchEmployeeBusinessDetailBarChartActivity> weakReference = new WeakReference<BranchEmployeeBusinessDetailBarChartActivity>(activity);
			branchEmployeeBusinessDetailBarChartActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (branchEmployeeBusinessDetailBarChartActivity.progressDialog != null) {
				branchEmployeeBusinessDetailBarChartActivity.progressDialog.dismiss();
				branchEmployeeBusinessDetailBarChartActivity.progressDialog = null;
			}
			if (message.what == 1) {
				if (branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList != null && branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.size() > 0) {
					((LinearLayout) branchEmployeeBusinessDetailBarChartActivity.findViewById(R.id.branch_employee_business_detail_bar_chart_linearlayout)).removeAllViews();
					List<String> objectName = new ArrayList<String>();
					double[] objectCount = new double[branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.size()];
					double[] totalAmount = new double[branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.size()];
					objectName.add("");
					for (int j = 0; j < branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.size(); j++) {
						objectName.add(branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.get(j).getObjectName());
						//操作业绩
						if (branchEmployeeBusinessDetailBarChartActivity.objectType == 1) {
							objectCount[j] = branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.get(j).getObjectCount();
						}
						//销售业绩
						else if (branchEmployeeBusinessDetailBarChartActivity.objectType == 2) {
							objectCount[j] = branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.get(j).getConsumeAmount();
						}
						//充值业绩
						else if (branchEmployeeBusinessDetailBarChartActivity.objectType == 3) {
							objectCount[j] = branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.get(j).getRechargeAmount();
						}
						totalAmount[j] = branchEmployeeBusinessDetailBarChartActivity.branchStatisticsList.get(j).getTotalAmount();
					}
					//员工个人业绩统计
					BarChartView barChartViewCount = new BarChartView(branchEmployeeBusinessDetailBarChartActivity.getApplicationContext(), true);
					barChartViewCount.initData(objectCount, totalAmount, objectName, "个人业绩统计");
					View viewCount = barChartViewCount.getBarChartView();
					((LinearLayout) branchEmployeeBusinessDetailBarChartActivity.findViewById(R.id.branch_employee_business_detail_bar_chart_linearlayout)).addView(viewCount);
				}
			} else if (message.what == 2)
				DialogUtil.createShortDialog(branchEmployeeBusinessDetailBarChartActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(branchEmployeeBusinessDetailBarChartActivity, branchEmployeeBusinessDetailBarChartActivity.getString(R.string.login_error_message));
				branchEmployeeBusinessDetailBarChartActivity.userinfoApplication.exitForLogin(branchEmployeeBusinessDetailBarChartActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + branchEmployeeBusinessDetailBarChartActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(branchEmployeeBusinessDetailBarChartActivity);
				branchEmployeeBusinessDetailBarChartActivity.packageUpdateUtil = new PackageUpdateUtil(branchEmployeeBusinessDetailBarChartActivity, branchEmployeeBusinessDetailBarChartActivity.mHandler, fileCache, downloadFileUrl, false, branchEmployeeBusinessDetailBarChartActivity.userinfoApplication);
				branchEmployeeBusinessDetailBarChartActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				branchEmployeeBusinessDetailBarChartActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "com.glamourpromise.beauty.business.apk";
				File file = branchEmployeeBusinessDetailBarChartActivity.getFileStreamPath(filename);
				file.getName();
				branchEmployeeBusinessDetailBarChartActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (branchEmployeeBusinessDetailBarChartActivity.requestWebServiceThread != null) {
				branchEmployeeBusinessDetailBarChartActivity.requestWebServiceThread.interrupt();
				branchEmployeeBusinessDetailBarChartActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void getBranchEmployeeBusinessDetailBarChartData(){
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		progressDialog.setCanceledOnTouchOutside(false);
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName = "GetBranchDataStatisticsList";
				String endPoint = "Statistics";
				JSONObject getDataStatisticsJson=new JSONObject();
				try {
					getDataStatisticsJson.put("ObjectType",objectType);
					getDataStatisticsJson.put("MonthCount",6);
					getDataStatisticsJson.put("ExtractItemType",2);
					getDataStatisticsJson.put("AccountID",objectID);
					getDataStatisticsJson.put("StartTime",intent.getStringExtra("StartTime"));
					getDataStatisticsJson.put("EndTime",intent.getStringExtra("EndTime"));
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
						branchStatisticsList = new ArrayList<BranchStatistics>();
						if (statisticsJsonArray != null) {
							for (int i = 0; i < statisticsJsonArray.length(); i++) {
								BranchStatistics bs=new BranchStatistics();
								JSONObject csJson = null;
								try {
									csJson = (JSONObject) statisticsJsonArray.get(i);
								} catch (JSONException e) {
								}
								double rechargeAmount=0;//充值业绩
								int    objectCount=0;//操作业绩
								double consumeAmout=0;
							    String objectName="";//抽取名
							    double totalAmount=0;
							    int   objectId=0;
								try {
									if(csJson.has("RechargeAmout") && !csJson.isNull("RechargeAmout")){
										rechargeAmount=csJson.getDouble("RechargeAmout");
									}
									if(csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")){
										objectCount=csJson.getInt("ObjectCount");
									}
									if(csJson.has("ConsumeAmout") && !csJson.isNull("ConsumeAmout")){
										consumeAmout=csJson.getDouble("ConsumeAmout");
									}
									if(csJson.has("ObjectName") && !csJson.isNull("ObjectName")){
										objectName=csJson.getString("ObjectName");
									}
									if(csJson.has("TotalAmout") && !csJson.isNull("TotalAmout")){
										totalAmount=csJson.getDouble("TotalAmout");
									}
								} catch (JSONException e) {
								}
								bs.setRechargeAmount(rechargeAmount);
								bs.setObjectCount(objectCount);
								bs.setConsumeAmount(consumeAmout);
								bs.setObjectName(objectName);
								bs.setTotalAmount(totalAmount);
								bs.setObjectId(objectId);
								branchStatisticsList.add(bs);
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
	//businessType   1:操作业绩  2：销售业绩  3：充值业绩
	protected void  switchBusinessType(int businessType){
			if(businessType==1){
				switchOperationBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
				switchOperationBtn.setTextColor(getResources().getColor(R.color.white));
				switchRechargeBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchRechargeBtn.setTextColor(getResources().getColor(R.color.blue));
				switchSalesBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchSalesBtn.setTextColor(getResources().getColor(R.color.blue));
				objectType=1;
				getBranchEmployeeBusinessDetailBarChartData();
			}
			else if(businessType==2){
				switchSalesBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
				switchSalesBtn.setTextColor(getResources().getColor(R.color.white));
				switchRechargeBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchRechargeBtn.setTextColor(getResources().getColor(R.color.blue));
				switchOperationBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchOperationBtn.setTextColor(getResources().getColor(R.color.blue));
				objectType=2;
				getBranchEmployeeBusinessDetailBarChartData();
			}
			else if(businessType==3){
				switchRechargeBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
				switchRechargeBtn.setTextColor(getResources().getColor(R.color.white));
				switchSalesBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchSalesBtn.setTextColor(getResources().getColor(R.color.blue));
				switchOperationBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
				switchOperationBtn.setTextColor(getResources().getColor(R.color.blue));
				objectType=3;
				getBranchEmployeeBusinessDetailBarChartData();
			}
		}	
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch(view.getId()){
		//操作业绩
		case R.id.switch_operation_btn:
			switchBusinessType(1);
			break;
		//销售业绩
		case R.id.switch_sales_btn:
			switchBusinessType(2);
			break;
		//充值业绩
		case R.id.switch_recharge_btn:
			switchBusinessType(3);
			break;
		}
	}
}
