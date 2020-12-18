package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.BranchStatistics;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 *门店营业数据统计分析 列表
 * */
@SuppressLint("ResourceType")
public class BranchBusinessConditionsStatisticsBarChartDetailListActivity extends BaseActivity implements OnClickListener{
	private BranchBusinessConditionsStatisticsBarChartDetailListActivityHandler mHandler = new BranchBusinessConditionsStatisticsBarChartDetailListActivityHandler(this);
	private UserInfoApplication userinfoApplication;
	private ProgressDialog           progressDialog;
	private Thread                   requestWebServiceThread;
	private PackageUpdateUtil packageUpdateUtil;
	private List<BranchStatistics>   branchStatisticsList;
	private LinearLayout             branchStatisticsBarChartDetailListLinearlayout;
	private ImageButton              branchStatisticsBarChartBtn;
	private LayoutInflater           layoutInflater;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_branch_business_conditions_statistics_bar_chart_detail_list);
		initView();
	}
	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		branchStatisticsBarChartDetailListLinearlayout=(LinearLayout)findViewById(R.id.branch_business_conditions_bar_chart_detail_list_linearlayout);
		branchStatisticsBarChartBtn=(ImageButton)findViewById(R.id.branch_business_conditions_bar_chart_icon);
		branchStatisticsBarChartBtn.setOnClickListener(this);
		layoutInflater=LayoutInflater.from(this);
		userinfoApplication=(UserInfoApplication) getApplication();
		getBranchStatisticsPieData();
	}

	private static class BranchBusinessConditionsStatisticsBarChartDetailListActivityHandler extends Handler {
		private final BranchBusinessConditionsStatisticsBarChartDetailListActivity branchBusinessConditionsStatisticsBarChartDetailListActivity;

		private BranchBusinessConditionsStatisticsBarChartDetailListActivityHandler(BranchBusinessConditionsStatisticsBarChartDetailListActivity activity) {
			WeakReference<BranchBusinessConditionsStatisticsBarChartDetailListActivity> weakReference = new WeakReference<BranchBusinessConditionsStatisticsBarChartDetailListActivity>(activity);
			branchBusinessConditionsStatisticsBarChartDetailListActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (branchBusinessConditionsStatisticsBarChartDetailListActivity.progressDialog != null) {
				branchBusinessConditionsStatisticsBarChartDetailListActivity.progressDialog.dismiss();
				branchBusinessConditionsStatisticsBarChartDetailListActivity.progressDialog = null;
			}
			if (message.what == 1) {
				if (branchBusinessConditionsStatisticsBarChartDetailListActivity.branchStatisticsList != null && branchBusinessConditionsStatisticsBarChartDetailListActivity.branchStatisticsList.size() > 0) {
					for (BranchStatistics bs : branchBusinessConditionsStatisticsBarChartDetailListActivity.branchStatisticsList) {
						View view = branchBusinessConditionsStatisticsBarChartDetailListActivity.layoutInflater.inflate(R.xml.customer_statistics_bar_chart_detail_list_item, null);
						((TextView) view.findViewById(R.id.objet_count_title)).setText("到店人次");
						TextView objectNameText = (TextView) view.findViewById(R.id.object_name_text);
						TextView consumeAmountText = (TextView) view.findViewById(R.id.consume_amount_text);
						TextView objectCountText = (TextView) view.findViewById(R.id.objet_count_text);
						TextView rechargeAmountText = (TextView) view.findViewById(R.id.recharge_amount_text);
						objectNameText.setText(bs.getObjectName());
						consumeAmountText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(bs.getConsumeAmount())));
						objectCountText.setText(bs.getObjectCount() + "次");
						rechargeAmountText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(bs.getRechargeAmount())));
						branchBusinessConditionsStatisticsBarChartDetailListActivity.branchStatisticsBarChartDetailListLinearlayout.addView(view);
					}
				}
			} else if (message.what == 2)
				DialogUtil.createShortDialog(branchBusinessConditionsStatisticsBarChartDetailListActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(branchBusinessConditionsStatisticsBarChartDetailListActivity,branchBusinessConditionsStatisticsBarChartDetailListActivity.getString(R.string.login_error_message));
				branchBusinessConditionsStatisticsBarChartDetailListActivity.userinfoApplication.exitForLogin(branchBusinessConditionsStatisticsBarChartDetailListActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + branchBusinessConditionsStatisticsBarChartDetailListActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(branchBusinessConditionsStatisticsBarChartDetailListActivity);
				branchBusinessConditionsStatisticsBarChartDetailListActivity.packageUpdateUtil = new PackageUpdateUtil(branchBusinessConditionsStatisticsBarChartDetailListActivity, branchBusinessConditionsStatisticsBarChartDetailListActivity.mHandler, fileCache, downloadFileUrl, false, branchBusinessConditionsStatisticsBarChartDetailListActivity.userinfoApplication);
				branchBusinessConditionsStatisticsBarChartDetailListActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				branchBusinessConditionsStatisticsBarChartDetailListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = branchBusinessConditionsStatisticsBarChartDetailListActivity.getFileStreamPath(filename);
				file.getName();
				branchBusinessConditionsStatisticsBarChartDetailListActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (branchBusinessConditionsStatisticsBarChartDetailListActivity.requestWebServiceThread != null) {
				branchBusinessConditionsStatisticsBarChartDetailListActivity.requestWebServiceThread.interrupt();
				branchBusinessConditionsStatisticsBarChartDetailListActivity.requestWebServiceThread = null;
			}
		}
	}

	protected void getBranchStatisticsPieData(){
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
					getDataStatisticsJson.put("ObjectType",0);
					getDataStatisticsJson.put("MonthCount",6);
					getDataStatisticsJson.put("ExtractItemType",1);
					getDataStatisticsJson.put("AccountID",0);
					getDataStatisticsJson.put("StartTime",getIntent().getStringExtra("StartTime"));
					getDataStatisticsJson.put("EndTime",getIntent().getStringExtra("EndTime"));
					getDataStatisticsJson.put("TimeChooseFlag",getIntent().getIntExtra("TimeChooseFlag",0));
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
								int    objectCount=0;
							    String objectName="";
							    double consumeAmount=0;
							    double rechargeAmount=0;
								try {
									if(csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")){
										objectCount=csJson.getInt("ObjectCount");
									}
									if(csJson.has("ObjectName") && !csJson.isNull("ObjectName")){
										objectName=csJson.getString("ObjectName");
									}
									if(csJson.has("ConsumeAmout") && !csJson.isNull("ConsumeAmout")){
										consumeAmount=csJson.getDouble("ConsumeAmout");
									}
									if(csJson.has("RechargeAmout") && !csJson.isNull("RechargeAmout")){
										rechargeAmount=csJson.getDouble("RechargeAmout");
									}
								} catch (JSONException e) {
								}
								bs.setObjectCount(objectCount);
								bs.setObjectName(objectName);
								bs.setConsumeAmount(consumeAmount);
								bs.setRechargeAmount(rechargeAmount);
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
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		if(view.getId()==R.id.branch_business_conditions_bar_chart_icon){
			Intent destIntent=new Intent();
			destIntent.setClass(this,BranchBusinessConditionsBarChartActivity.class);
			destIntent.putExtra("EndTime",getIntent().getStringExtra("EndTime"));
			destIntent.putExtra("TimeChooseFlag",getIntent().getIntExtra("TimeChooseFlag",0));
			destIntent.putExtra("ListBackFlg",1);
			destIntent.putExtra("reportByOtherEndTimeTxt",getIntent().getStringExtra("reportByOtherEndTimeTxt"));
			startActivity(destIntent);
			this.finish();
		}
	}
}
