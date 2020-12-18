package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.DatePicker;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.BranchJournalInfo;
import cn.com.antika.bean.BranchJournalOut;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.SegmentBar;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint("ResourceType")
public class BranchJournalReportActivity extends BaseActivity implements OnClickListener {
	private BranchJournalReportActivityHandler mHandler = new BranchJournalReportActivityHandler(this);
	private SegmentBar segmentBar;
	private RelativeLayout reportByOtherRelativeLayout;
	private TextView       reportByOtherStartDate, reportByOtherEndDate;
	private ProgressDialog progressDialog;
	private Thread requestWebServiceThread;
	private UserInfoApplication userinfoApplication;
	private ImageView reportByDateOtherQueryBtn;
	private String reportByOtherStartTime,reportByOtherEndTime;
	private PackageUpdateUtil packageUpdateUtil;
	private LayoutInflater    layoutInflater;
	private int   cycleType;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_branch_journal_report);
		userinfoApplication = UserInfoApplication.getInstance();
		layoutInflater=LayoutInflater.from(this);
		initView();
	}

	private void initView() {
		BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
		GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
		BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
		GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
		reportByDateOtherQueryBtn=(ImageView)findViewById(R.id.branch_journal_report_by_date_query_btn);
		reportByDateOtherQueryBtn.setOnClickListener(this);
		reportByOtherStartDate = (TextView) findViewById(R.id.report_by_other_start_date);
		reportByOtherStartDate.setOnClickListener(this);
		reportByOtherEndDate = (TextView) findViewById(R.id.report_by_other_end_date);
		reportByOtherEndDate.setOnClickListener(this);
		reportByOtherRelativeLayout = (RelativeLayout)findViewById(R.id.branch_journal_report_by_other_relativelayout);
		reportByOtherRelativeLayout.setVisibility(View.GONE);
		
		Calendar nowDate = Calendar.getInstance();
		int nowYear = nowDate.get(Calendar.YEAR);
		int nowMonth = nowDate.get(Calendar.MONTH) + 1;
		int nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
		reportByOtherStartTime = nowYear + "-" + nowMonth + "-" + nowDay;
		reportByOtherEndTime = nowYear + "-" + nowMonth + "-" + nowDay;
		reportByOtherStartDate.setText(nowYear + "年" + nowMonth + "月"
				+ nowDay + "日");
		reportByOtherEndDate.setText(nowYear + "年" + nowMonth + "月"
				+ nowDay + "日");
		segmentBar=(SegmentBar)findViewById(R.id.branch_journal_segment_bar);
		segmentBar.setValue(this, new String[] { "日", "月", "季", "年", "..." });
		if (userinfoApplication.getScreenWidth() == 1536)
			segmentBar.setTextSize(20);
		else
			segmentBar.setTextSize(12);
		segmentBar.setTextColor(this.getResources().getColor(R.color.title_font));
		cycleType=0;
		segmentBar.setDefaultBarItem(0);
		segmentBar
				.setOnSegmentBarChangedListener(new SegmentBar.OnSegmentBarChangedListener() {
					@Override
					public void onBarItemChanged(int segmentItemIndex) {
						if (segmentItemIndex == 0) {
							cycleType = 0;
							if (reportByOtherRelativeLayout.getVisibility() == View.VISIBLE)
								reportByOtherRelativeLayout
										.setVisibility(View.GONE);
						} else if (segmentItemIndex == 1) {
							cycleType = 1;
							if (reportByOtherRelativeLayout.getVisibility() == View.VISIBLE)
								reportByOtherRelativeLayout
										.setVisibility(View.GONE);
						} else if (segmentItemIndex == 2) {
							cycleType = 2;
							if (reportByOtherRelativeLayout.getVisibility() == View.VISIBLE)
								reportByOtherRelativeLayout
										.setVisibility(View.GONE);
						} else if (segmentItemIndex == 3) {
							cycleType = 3;
							if (reportByOtherRelativeLayout.getVisibility() == View.VISIBLE)
								reportByOtherRelativeLayout
										.setVisibility(View.GONE);
						} else if (segmentItemIndex == 4) {
							cycleType = 4;
							if (reportByOtherRelativeLayout.getVisibility() == View.GONE)
								reportByOtherRelativeLayout
										.setVisibility(View.VISIBLE);
						}
						if (cycleType != 4) {
							requestWebService(cycleType);
						}
					}
				});
		requestWebService(cycleType);
	}

	private static class BranchJournalReportActivityHandler extends Handler {
		private final BranchJournalReportActivity branchJournalReportActivity;

		private BranchJournalReportActivityHandler(BranchJournalReportActivity activity) {
			WeakReference<BranchJournalReportActivity> weakReference = new WeakReference<BranchJournalReportActivity>(activity);
			branchJournalReportActivity = weakReference.get();
		}

		@Override
		public void handleMessage(Message message) {
			if (branchJournalReportActivity.progressDialog != null) {
				branchJournalReportActivity.progressDialog.dismiss();
				branchJournalReportActivity.progressDialog = null;
			}
			if (message.what == 1) {
				BranchJournalInfo bji = (BranchJournalInfo) message.obj;
				NumberFormat numberFormat = NumberFormat.getInstance();
				numberFormat.setMinimumFractionDigits(2);
				numberFormat.setMaximumFractionDigits(2);
				BigDecimal incomeAmountBigDecimal = new BigDecimal(bji.getIncomeAmount());
				BigDecimal salesAllBigDecimal = new BigDecimal(bji.getSalesAll());
				BigDecimal salesServiceBigDecimal = new BigDecimal(bji.getSalesService());
				BigDecimal salesCommodityBigDecimal = new BigDecimal(bji.getSalesCommodity());
				BigDecimal salesEcardBigDecimal = new BigDecimal(bji.getSalesEcard());
				BigDecimal incomeOthersBigDecimal = new BigDecimal(bji.getIncomeOthers());
				BigDecimal balanceAmountBigDecimal = new BigDecimal(bji.getBalanceAmount());
				BigDecimal outAmountBigDecimal = new BigDecimal(bji.getOutAmount());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(incomeAmountBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(salesAllBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_ratio_text)).setText(bji.getSalesAllRatio());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_service_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(salesServiceBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_service_ratio_text)).setText(bji.getSalesServiceRatio());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_commodity_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(salesCommodityBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_commodity_ratio_text)).setText(bji.getSalesCommodityRatio());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_ecard_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(salesEcardBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_ecard_ratio_text)).setText(bji.getSalesEcardRatio());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_other_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(incomeOthersBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_income_sales_other_ratio_text)).setText(bji.getIncomeOthersRatio());
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_balance_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(balanceAmountBigDecimal));
				((TextView) branchJournalReportActivity.findViewById(R.id.my_branch_journal_out_text)).setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(outAmountBigDecimal));
				TableLayout outTableLayout = (TableLayout) branchJournalReportActivity.findViewById(R.id.my_branch_journal_out_tablelayout);
				//修改bug:当年有数据而当日没有数据时，当日数据不清零的bug
				int childCount = outTableLayout.getChildCount();
				if (childCount > 1) {
					outTableLayout.removeViews(1, childCount - 1);
				}
				List<BranchJournalOut> bjiList = bji.getOutList();
				if (bjiList != null && bjiList.size() > 0) {
					//outTableLayout.removeViews(1,outTableLayout.getChildCount()-1);
					for (int i = 0; i < bjiList.size(); i++) {
						BranchJournalOut bjio = bjiList.get(i);
						View outItemView = branchJournalReportActivity.layoutInflater.inflate(R.xml.branch_journal_out_item, null);
						TextView outName = (TextView) outItemView.findViewById(R.id.out_name);
						TextView outAmount = (TextView) outItemView.findViewById(R.id.out_amount);
						TextView outItemRatio = (TextView) outItemView.findViewById(R.id.out_item_ratio);
						outName.setText(bjio.getOutName());
						outAmount.setText(branchJournalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(new BigDecimal(bjio.getOutAmount())));
						outItemRatio.setText(bjio.getOutItemRatio());
						outTableLayout.addView(outItemView, 1 + i);
					}
				}

			} else if (message.what == 2)
				DialogUtil.createShortDialog(branchJournalReportActivity, "您的网络貌似不给力，请重试");
			else if (message.what == Constant.LOGIN_ERROR) {
				DialogUtil.createShortDialog(branchJournalReportActivity, branchJournalReportActivity.getString(R.string.login_error_message));
				branchJournalReportActivity.userinfoApplication.exitForLogin(branchJournalReportActivity);
			} else if (message.what == Constant.APP_VERSION_ERROR) {
				String downloadFileUrl = Constant.SERVER_URL + branchJournalReportActivity.getString(R.string.download_apk_address);
				FileCache fileCache = new FileCache(branchJournalReportActivity);
				branchJournalReportActivity.packageUpdateUtil = new PackageUpdateUtil(branchJournalReportActivity, branchJournalReportActivity.mHandler, fileCache, downloadFileUrl, false, branchJournalReportActivity.userinfoApplication);
				branchJournalReportActivity.packageUpdateUtil.getPackageVersionInfo();
				ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
				serverPackageVersion.setPackageVersion((String) message.obj);
				branchJournalReportActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
			}
			//包进行下载安装升级
			else if (message.what == 5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
				String filename = "cn.com.antika.business.apk";
				File file = branchJournalReportActivity.getFileStreamPath(filename);
				file.getName();
				branchJournalReportActivity.packageUpdateUtil.showInstallDialog();
			} else if (message.what == -5) {
				((DownloadInfo) message.obj).getUpdateDialog().cancel();
			} else if (message.what == 7) {
				int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
				((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
			}
			if (branchJournalReportActivity.requestWebServiceThread != null) {
				branchJournalReportActivity.requestWebServiceThread.interrupt();
				branchJournalReportActivity.requestWebServiceThread = null;
			}
		}
	}

	private void requestWebService(int cycleType) {
		final int ct=cycleType;
		progressDialog = new ProgressDialog(this,R.style.CustomerProgressDialog);
		progressDialog.setMessage(getString(R.string.please_wait));
		progressDialog.show();
		requestWebServiceThread = new Thread() {
			@Override
			public void run() {
				String methodName ="GetJournalInfo";
				String endPoint = "Report";
				JSONObject para = new JSONObject();
				try {
					para.put("CycleType",ct);
					if(ct == 4) {
						para.put("StartTime", reportByOtherStartTime);
						para.put("EndTime", reportByOtherEndTime);
					}
				} catch (JSONException e) {
				}
				String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName,para.toString(),userinfoApplication);
				JSONObject resultJson = null;
				try {
					resultJson = new JSONObject(serverResult);
				} catch (JSONException e) {

				}
				if (serverResult == null || ("").equals(serverResult))
					mHandler.sendEmptyMessage(2);
				else {
					int    code = 0;
					String serverMessage = "";
					try {
						code = resultJson.getInt("Code");
						serverMessage = resultJson.getString("Message");
					} catch (JSONException e) {
						code = 0;
					}
					if (code== 1) {
						JSONObject branchJournal = null;
						try {
							branchJournal = resultJson.getJSONObject("Data");
						} catch (JSONException e) {

						}
						if (branchJournal != null) {
							double  incomeAmount=0;
							double  salesAll=0;
							double  salesService=0;
							double  salesCommodity=0;
							double  salesEcard=0;
							double  incomeOthers=0;
							double  outAmount=0;
							double  balanceAmount = 0;
							String  salesAllRatio="0%";
							String  salesServiceRatio="0%";
							String  salesCommodityRatio="0%";
							String  salesEcardRatio="0%";
							String  incomeOthersRatio="0%";
							List<BranchJournalOut> outList=new ArrayList<BranchJournalOut>();
							try {
								if(branchJournal.has("IncomeAmount"))
									incomeAmount=branchJournal.getDouble("IncomeAmount");
								if(branchJournal.has("SalesAll"))
									salesAll=branchJournal.getDouble("SalesAll");
								if(branchJournal.has("SalesAllRatio")) 
									salesAllRatio= branchJournal.getString("SalesAllRatio");
								if(branchJournal.has("SalesService"))
									salesService=branchJournal.getDouble("SalesService");
								if(branchJournal.has("SalesServiceRatio")) 
									salesServiceRatio= branchJournal.getString("SalesServiceRatio");
								if(branchJournal.has("SalesCommodity"))
									salesCommodity=branchJournal.getDouble("SalesCommodity");
								if(branchJournal.has("SalesCommodityRatio")) 
									salesCommodityRatio= branchJournal.getString("SalesCommodityRatio");
								if(branchJournal.has("SalesEcard"))
									salesEcard=branchJournal.getDouble("SalesEcard");
								if(branchJournal.has("SalesEcardRatio")) 
									salesEcardRatio= branchJournal.getString("SalesEcardRatio");
								if(branchJournal.has("IncomeOthers"))
									incomeOthers=branchJournal.getDouble("IncomeOthers");
								if(branchJournal.has("IncomeOthersRatio")) 
									incomeOthersRatio= branchJournal.getString("IncomeOthersRatio");
								if(branchJournal.has("BalanceAmount"))
									balanceAmount=branchJournal.getDouble("BalanceAmount");
								if(branchJournal.has("OutAmout"))
									outAmount=branchJournal.getDouble("OutAmout");
								if(branchJournal.has("listOutInfo") && !branchJournal.isNull("listOutInfo")){
									JSONArray outArray=branchJournal.getJSONArray("listOutInfo");
									for(int i=0;i<outArray.length();i++){
										JSONObject outJson=outArray.getJSONObject(i);
										BranchJournalOut bjo=new BranchJournalOut();
										String outName="";
										double outItemAmount=0;
										String  outItemRatio="0%";
										if(outJson.has("OutItemName") && !outJson.isNull("OutItemName"))
											outName=outJson.getString("OutItemName");
										bjo.setOutName(outName);
										if(outJson.has("OutItemAmountRatio") && !outJson.isNull("OutItemAmountRatio"))
											outItemRatio=outJson.getString("OutItemAmountRatio");
										bjo.setOutItemRatio(outItemRatio);
										if(outJson.has("OutItemAmount") && !outJson.isNull("OutItemAmount"))
											outItemAmount=outJson.getDouble("OutItemAmount");
										bjo.setOutAmount(outItemAmount);
										outList.add(bjo);
									}
								}
							} catch (JSONException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							BranchJournalInfo bji=new BranchJournalInfo();
							bji.setIncomeAmount(incomeAmount);
							bji.setSalesAll(salesAll);
							bji.setSalesAllRatio(salesAllRatio);
							bji.setSalesService(salesService);
							bji.setSalesServiceRatio(salesServiceRatio);
							bji.setSalesCommodity(salesCommodity);
							bji.setSalesCommodityRatio(salesCommodityRatio);
							bji.setSalesEcard(salesEcard);
							bji.setSalesEcardRatio(salesEcardRatio);
							bji.setIncomeOthers(incomeOthers);
							bji.setIncomeOthersRatio(incomeOthersRatio);
							bji.setBalanceAmount(balanceAmount);
							bji.setOutAmount(outAmount);
							bji.setOutList(outList);
							Message message = new Message();
							message.obj = bji;
							message.what = 1;
							mHandler.sendMessage(message);
						}
					} else
						mHandler.sendEmptyMessage(code);
				}
			}
		};
		requestWebServiceThread.start();
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.branch_journal_report_by_date_query_btn:
			requestWebService(4);
			break;
		case R.id.report_by_other_start_date:
			Calendar calendarStart = Calendar.getInstance();
			DatePickerDialog startDateDialog = new DatePickerDialog(this,
					R.style.CustomerAlertDialog, new OnDateSetListener() {

						@Override
						public void onDateSet(DatePicker view, int year,
								int monthOfYear, int dayOfMonth) {
							reportByOtherStartDate.setText(year + "年"
									+ (monthOfYear + 1) + "月" + dayOfMonth
									+ "日");
							reportByOtherStartTime = year + "-"
									+ (monthOfYear + 1) + "-" + dayOfMonth;
						}
					}, calendarStart.get(calendarStart.YEAR),
					calendarStart.get(calendarStart.MONTH),
					calendarStart.get(calendarStart.DAY_OF_MONTH));
			startDateDialog.show();
			break;
		case R.id.report_by_other_end_date:
			Calendar calendarEnd = Calendar.getInstance();
			DatePickerDialog endDateDialog = new DatePickerDialog(this,R.style.CustomerAlertDialog, new OnDateSetListener() {
						@Override
						public void onDateSet(DatePicker view, int year,int monthOfYear, int dayOfMonth) {
							reportByOtherEndDate.setText(year + "年"
									+ (monthOfYear + 1) + "月" + dayOfMonth
									+ "日");
							reportByOtherEndTime = year + "-"
									+ (monthOfYear + 1) + "-" + dayOfMonth;
						}
					}, calendarEnd.get(calendarEnd.YEAR),
					calendarEnd.get(calendarEnd.MONTH),
					calendarEnd.get(calendarEnd.DAY_OF_MONTH));
			endDateDialog.show();
			break;
		}
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
}
