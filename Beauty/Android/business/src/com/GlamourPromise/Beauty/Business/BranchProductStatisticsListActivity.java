package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ListView;
import android.widget.RelativeLayout;
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
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

@SuppressLint("ResourceType")
public class BranchProductStatisticsListActivity extends BaseActivity implements OnClickListener {
    private BranchProductStatisticsListActivityHandler mHandler = new BranchProductStatisticsListActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private List<CustomerStatistics> branchStatisticsList;
    private ListView branchStatisticsListView;
    private Button switchServiceBtn, switchCommodityBtn;
    private int objectType = 0;
    //时间弹出
    private TextView reportFilterTagView, filterbyperiodtitletxtbr1;
    //时间选项
    private RelativeLayout filterRelativelayout, filterPeriodItemRelativeLayout, filterbyperiodtitlebr1;
    //周期时间
    private String reportByOtherStartTime, reportByOtherEndTime, reportByOtherStartTimeTxt, reportByOtherEndTimeTxt;
    private int startyear, startmonthOfYear, startdayOfMonth,
            endyear, endmonthOfYear, enddayOfMonth,
            datechangeflg = 0, startdateflg = 0, enddateflg = 0,
            nowYear, nowMonth, nowDay;
    private Date enddate, startdate;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_product_statistics_list);
        initView();
    }

    @SuppressLint("SimpleDateFormat")
    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        branchStatisticsListView = (ListView) findViewById(R.id.branch_product_statistics_list_listview);
        switchServiceBtn = (Button) findViewById(R.id.switch_service_btn);
        switchServiceBtn.setOnClickListener(this);
        switchCommodityBtn = (Button) findViewById(R.id.switch_commodity_btn);
        switchCommodityBtn.setOnClickListener(this);
        objectType = 0;
        // 周期选择
        reportFilterTagView = (TextView) findViewById(R.id.report_filter_tag_view_br5);
        reportFilterTagView.setOnClickListener(this);
        filterRelativelayout = (RelativeLayout) findViewById(R.id.filter_relativelayout_br1);
        //统计范围字样
        filterbyperiodtitlebr1 = (RelativeLayout) findViewById(R.id.filter_by_period_title_br1);
        filterbyperiodtitletxtbr1 = (TextView) findViewById(R.id.filter_by_period_title_txt_br1);
        filterbyperiodtitletxtbr1.setText(R.string.filter_by_count_between);
        //日期输入框
        filterPeriodItemRelativeLayout = (RelativeLayout) filterRelativelayout.findViewById(R.id.filter_period_relativelayout_br1);
        // 周期时间初始化
        Calendar nowDate = Calendar.getInstance();
        nowYear = nowDate.get(Calendar.YEAR);
        nowMonth = nowDate.get(Calendar.MONTH) + 1;
        nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
        reportByOtherStartTime = nowYear + "-" + nowMonth + "-1";
        reportByOtherStartTimeTxt = nowYear + "年" + nowMonth + "月1日";
        reportByOtherEndTime = nowYear + "-" + nowMonth + "-" + nowDay;
        reportByOtherEndTimeTxt = nowYear + "年" + nowMonth + "月" + nowDay + "日";
        DateFormat enddateformat = new SimpleDateFormat("yyyy-MM-dd");
        try {
            enddate = enddateformat.parse(reportByOtherEndTime);
            startdate = enddate;
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        getCustomerStatisticsPieData();
    }

    private static class BranchProductStatisticsListActivityHandler extends Handler {
        private final BranchProductStatisticsListActivity branchProductStatisticsListActivity;

        private BranchProductStatisticsListActivityHandler(BranchProductStatisticsListActivity activity) {
            WeakReference<BranchProductStatisticsListActivity> weakReference = new WeakReference<BranchProductStatisticsListActivity>(activity);
            branchProductStatisticsListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (branchProductStatisticsListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (branchProductStatisticsListActivity.progressDialog != null) {
                branchProductStatisticsListActivity.progressDialog.dismiss();
                branchProductStatisticsListActivity.progressDialog = null;
            }
            if (message.what == 1) {
                branchProductStatisticsListActivity.branchStatisticsListView.setAdapter(new CustomerStatisticsListAdapter(branchProductStatisticsListActivity, branchProductStatisticsListActivity.branchStatisticsList, branchProductStatisticsListActivity.objectType));
            } else if (message.what == 2)
                DialogUtil.createShortDialog(branchProductStatisticsListActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(branchProductStatisticsListActivity, branchProductStatisticsListActivity.getString(R.string.login_error_message));
                branchProductStatisticsListActivity.userinfoApplication.exitForLogin(branchProductStatisticsListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + branchProductStatisticsListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(branchProductStatisticsListActivity);
                branchProductStatisticsListActivity.packageUpdateUtil = new PackageUpdateUtil(branchProductStatisticsListActivity, branchProductStatisticsListActivity.mHandler, fileCache, downloadFileUrl, false, branchProductStatisticsListActivity.userinfoApplication);
                branchProductStatisticsListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                branchProductStatisticsListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = branchProductStatisticsListActivity.getFileStreamPath(filename);
                file.getName();
                branchProductStatisticsListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (branchProductStatisticsListActivity.requestWebServiceThread != null) {
                branchProductStatisticsListActivity.requestWebServiceThread.interrupt();
                branchProductStatisticsListActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void getCustomerStatisticsPieData() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        progressDialog.setCanceledOnTouchOutside(false);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetBranchDataStatisticsList";
                String endPoint = "Statistics";
                JSONObject getDataStatisticsJson = new JSONObject();
                try {
                    getDataStatisticsJson.put("ObjectType", objectType);
                    getDataStatisticsJson.put("MonthCount", 6);
                    getDataStatisticsJson.put("ExtractItemType", 3);
                    getDataStatisticsJson.put("AccountID", 0);
                    getDataStatisticsJson.put("StartTime", reportByOtherStartTime);
                    getDataStatisticsJson.put("EndTime", reportByOtherEndTime);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getDataStatisticsJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray statisticsJsonArray = null;
                        try {
                            statisticsJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        branchStatisticsList = new ArrayList<CustomerStatistics>();
                        if (statisticsJsonArray != null) {
                            for (int i = 0; i < statisticsJsonArray.length(); i++) {
                                CustomerStatistics bs = new CustomerStatistics();
                                JSONObject csJson = null;
                                try {
                                    csJson = (JSONObject) statisticsJsonArray.get(i);
                                } catch (JSONException e) {
                                }
                                double rechargeAmount = 0;//充值业绩
                                int objectCount = 0;//操作业绩
                                double consumeAmout = 0;
                                String objectName = "";//抽取名
                                double totalAmount = 0;
                                try {
                                    if (csJson.has("RechargeAmout") && !csJson.isNull("RechargeAmout")) {
                                        rechargeAmount = csJson.getDouble("RechargeAmout");
                                    }
                                    if (csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")) {
                                        objectCount = csJson.getInt("ObjectCount");
                                    }
                                    if (csJson.has("ConsumeAmout") && !csJson.isNull("ConsumeAmout")) {
                                        consumeAmout = csJson.getDouble("ConsumeAmout");
                                    }
                                    if (csJson.has("ObjectName") && !csJson.isNull("ObjectName")) {
                                        objectName = csJson.getString("ObjectName");
                                    }
                                    if (csJson.has("TotalAmout") && !csJson.isNull("TotalAmout")) {
                                        totalAmount = csJson.getDouble("TotalAmout");
                                    }
                                } catch (JSONException e) {
                                }
                                bs.setRechargeAmount(rechargeAmount);
                                bs.setObjectCount(objectCount);
                                bs.setConsumeAmount(consumeAmout);
                                bs.setObjectName(objectName);
                                bs.setTotalAmount(totalAmount);
                                branchStatisticsList.add(bs);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void switchServiceCommodity(int productType) {
        if (productType == 0) {
            switchServiceBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
            switchServiceBtn.setTextColor(getResources().getColor(R.color.white));
            switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
            switchCommodityBtn.setTextColor(getResources().getColor(R.color.blue));
            objectType = 0;
            getCustomerStatisticsPieData();
        } else if (productType == 1) {
            switchServiceBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
            switchServiceBtn.setTextColor(getResources().getColor(R.color.blue));
            switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
            switchCommodityBtn.setTextColor(getResources().getColor(R.color.white));
            objectType = 1;
            getCustomerStatisticsPieData();
        }
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.switch_service_btn:
                switchServiceCommodity(0);
                break;
            case R.id.switch_commodity_btn:
                switchServiceCommodity(1);
                break;
            //周期选项弹出
            case R.id.report_filter_tag_view_br5:
                if (filterRelativelayout.getVisibility() == View.VISIBLE) {
                    filterRelativelayout.setVisibility(View.GONE);
                    filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                    filterbyperiodtitlebr1.setVisibility(View.GONE);
                } else {
                    //周期选项弹出设置
                    showFilterPopwindow();
                }
                break;
        }
    }

    //周期选项弹出设置
    protected void showFilterPopwindow() {
        //周期选项显示
        filterRelativelayout.setVisibility(View.VISIBLE);
        filterbyperiodtitlebr1.setVisibility(View.VISIBLE);
        //日期输入框显示
        filterPeriodItemRelativeLayout.setVisibility(View.VISIBLE);
        Button queryDateBtn = (Button) filterRelativelayout.findViewById(R.id.report_query_btn_br1);
        DateSelect();
        //完成按钮
        queryDateBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                getCustomerStatisticsPieData();
                filterRelativelayout.setVisibility(View.GONE);
            }
        });
    }

    //日期选择
    private void DateSelect() {
        enddate = new Date();
        //结束日期选择
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date_br1)).setText(reportByOtherEndTimeTxt);
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date_br1)).setOnClickListener(new OnClickListener() {

            @SuppressLint("SimpleDateFormat")
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                final TextView endDateText = (TextView) view;
                Calendar calendarEnd = Calendar.getInstance();
                if (startdateflg == 0) {
                    startyear = nowYear;
                    startmonthOfYear = nowMonth - 1;
                    startdayOfMonth = 1;
                }
                if (enddateflg == 0) {
                    endyear = calendarEnd.get(calendarEnd.YEAR);
                    endmonthOfYear = calendarEnd.get(calendarEnd.MONTH);
                    enddayOfMonth = calendarEnd.get(calendarEnd.DAY_OF_MONTH);
                }
                DatePickerDialog endDateDialog = new DatePickerDialog(BranchProductStatisticsListActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        endDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                        reportByOtherEndTimeTxt = year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日";
                        reportByOtherEndTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                        endyear = year;
                        endmonthOfYear = monthOfYear;
                        enddayOfMonth = dayOfMonth;
                        datechangeflg = 0;
                        int enddatecompare, startdatecompare;
                        enddatecompare = endyear * 10000 + endmonthOfYear * 100 + enddayOfMonth;
                        startdatecompare = startyear * 10000 + startmonthOfYear * 100 + startdayOfMonth;
                        if (enddatecompare < startdatecompare) {
                            datechangeflg = 1;
                        }
                        if (datechangeflg == 1) {
                            reportByOtherStartTimeTxt = reportByOtherEndTimeTxt;
                            reportByOtherStartTime = reportByOtherEndTime;
                            startyear = endyear;
                            startmonthOfYear = endmonthOfYear;
                            startdayOfMonth = enddayOfMonth;
                            startdateflg = 1;
                            ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_start_date_br1)).setText(reportByOtherStartTimeTxt);
                        }
                        DateFormat startdateformat = new SimpleDateFormat("yyyy-MM-dd");
                        try {
                            startdate = startdateformat.parse(reportByOtherEndTime);
                        } catch (ParseException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                        enddateflg = 1;
                    }
                }, endyear,
                        endmonthOfYear,
                        enddayOfMonth);
                DatePicker endDatePicker = endDateDialog.getDatePicker();
                endDatePicker.setMaxDate(enddate.getTime());
                endDateDialog.show();
            }
        });
        //开始日期选择
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_start_date_br1)).setText(reportByOtherStartTimeTxt);
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_start_date_br1)).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                Calendar calendarStart = Calendar.getInstance();
                if (startdateflg == 0) {
                    startyear = calendarStart.get(calendarStart.YEAR);
                    startmonthOfYear = calendarStart.get(calendarStart.MONTH);
                    startdayOfMonth = 1;
                }
                final TextView startDateText = (TextView) view;
                DatePickerDialog startDateDialog = new DatePickerDialog(BranchProductStatisticsListActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        startDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                        reportByOtherStartTimeTxt = year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日";
                        reportByOtherStartTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                        startyear = year;
                        startmonthOfYear = monthOfYear;
                        startdayOfMonth = dayOfMonth;
                        startdateflg = 1;
                    }
                }, startyear,
                        startmonthOfYear,
                        startdayOfMonth);
                DatePicker startDatePicker = startDateDialog.getDatePicker();
                startDatePicker.setMaxDate(startdate.getTime());
                startDateDialog.show();
            }
        });
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            mHandler = null;
        }
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
