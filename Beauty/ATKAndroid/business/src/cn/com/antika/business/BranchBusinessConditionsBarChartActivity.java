package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

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

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.BranchStatistics;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.chart.BarChartView;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 *门店营业状况 柱状图  服务顾客数量统计  营业收入统计
 * */
@SuppressLint("ResourceType")
public class BranchBusinessConditionsBarChartActivity extends BaseActivity implements OnClickListener {
    private BranchBusinessConditionsBarChartActivityHandler mHandler = new BranchBusinessConditionsBarChartActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private List<BranchStatistics> branchStatisticsList;
    private ImageButton branchBusinessConditionsBarChartDetailListBtn;
    //周期弹出
    private TextView reportFilterTagView, reportbyotherdatedividebr1, reportbyotherstartdatebr1, reportbyotherdatetxtbr1;
    //周期选项
    private RelativeLayout filterRelativelayout, filterPeriodItemRelativeLayout, filterbyperiodtitlebr1;
    private LinearLayout filterperiodlinearlayoutbr1;
    //周期类型
    private int cycleType = 2, endyear, endmonthOfYear, enddayOfMonth, enddateflg = 0;
    //周期时间
    private String reportByOtherEndTime, reportByOtherEndTimeTxt;
    private Date enddate;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_business_conditions_bar_chart);
        initView();
    }

    @SuppressLint("SimpleDateFormat")
    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        branchBusinessConditionsBarChartDetailListBtn = (ImageButton) findViewById(R.id.branch_business_conditions_detail_list_btn);
        branchBusinessConditionsBarChartDetailListBtn.setOnClickListener(this);
        // 周期选择
        reportFilterTagView = (TextView) findViewById(R.id.report_filter_tag_view_br1);
        reportFilterTagView.setOnClickListener(this);
        filterperiodlinearlayoutbr1 = (LinearLayout) findViewById(R.id.filter_period_linearlayout_br1);
        filterbyperiodtitlebr1 = (RelativeLayout) findViewById(R.id.filter_by_period_title_br1);
        filterRelativelayout = (RelativeLayout) findViewById(R.id.filter_relativelayout_br1);
        //日期输入框
        filterPeriodItemRelativeLayout = (RelativeLayout) filterRelativelayout.findViewById(R.id.filter_period_relativelayout_br1);
        reportbyotherdatedividebr1 = (TextView) findViewById(R.id.report_by_other_date_divide_br1);
        reportbyotherdatedividebr1.setVisibility(View.GONE);
        reportbyotherstartdatebr1 = (TextView) findViewById(R.id.report_by_other_start_date_br1);
        reportbyotherstartdatebr1.setVisibility(View.GONE);
        reportbyotherdatetxtbr1 = (TextView) findViewById(R.id.report_by_other_date_txt_br1);

        // 周期时间初始化
        Calendar nowDate = Calendar.getInstance();
        int nowYear = nowDate.get(Calendar.YEAR);
        int nowMonth = nowDate.get(Calendar.MONTH) + 1;
        int nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
        reportByOtherEndTime = nowYear + "-" + nowMonth + "-" + nowDay;
        reportByOtherEndTimeTxt = nowYear + "年" + nowMonth + "月" + nowDay + "日";
        if (getIntent().getIntExtra("ListBackFlg", 0) == 1) {
            reportByOtherEndTime = getIntent().getStringExtra("EndTime");
            reportByOtherEndTimeTxt = getIntent().getStringExtra("reportByOtherEndTimeTxt");
            cycleType = getIntent().getIntExtra("TimeChooseFlag", 0);
        }
        DateFormat enddateformat = new SimpleDateFormat("yyyy-MM-dd");
        try {
            enddate = enddateformat.parse(reportByOtherEndTime);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        getCustomerStatisticsPieData();
    }

    private static class BranchBusinessConditionsBarChartActivityHandler extends Handler {
        private final BranchBusinessConditionsBarChartActivity branchBusinessConditionsBarChartActivity;

        private BranchBusinessConditionsBarChartActivityHandler(BranchBusinessConditionsBarChartActivity activity) {
            WeakReference<BranchBusinessConditionsBarChartActivity> weakReference = new WeakReference<BranchBusinessConditionsBarChartActivity>(activity);
            branchBusinessConditionsBarChartActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (branchBusinessConditionsBarChartActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (branchBusinessConditionsBarChartActivity.progressDialog != null) {
                branchBusinessConditionsBarChartActivity.progressDialog.dismiss();
                branchBusinessConditionsBarChartActivity.progressDialog = null;
            }
            if (message.what == 1) {
                ((LinearLayout) branchBusinessConditionsBarChartActivity.findViewById(R.id.branch_business_conditions_bar_chart_linearlayout)).removeAllViews();
                ((LinearLayout) branchBusinessConditionsBarChartActivity.findViewById(R.id.branch_business_conditions_bar_chart2_linearlayout)).removeAllViews();
                if (branchBusinessConditionsBarChartActivity.branchStatisticsList != null && branchBusinessConditionsBarChartActivity.branchStatisticsList.size() > 0) {
                    List<String> objectName = new ArrayList<String>();
                    double[] objectCount = new double[branchBusinessConditionsBarChartActivity.branchStatisticsList.size()];
                    double[] totalAmount = new double[branchBusinessConditionsBarChartActivity.branchStatisticsList.size()];
                    objectName.add("");
                    for (int j = 0; j < branchBusinessConditionsBarChartActivity.branchStatisticsList.size(); j++) {
                        objectName.add(branchBusinessConditionsBarChartActivity.branchStatisticsList.get(j).getObjectName());
                        objectCount[j] = branchBusinessConditionsBarChartActivity.branchStatisticsList.get(j).getObjectCount();
                        totalAmount[j] = branchBusinessConditionsBarChartActivity.branchStatisticsList.get(j).getTotalAmount();
                    }
                    //服务顾客数量统计
                    BarChartView barChartViewCount = new BarChartView(branchBusinessConditionsBarChartActivity.getApplicationContext(), true);
                    barChartViewCount.initData(objectCount, totalAmount, objectName, "服务顾客数量统计");
                    View viewCount = barChartViewCount.getBarChartView();
                    //营业收入统计
                    BarChartView barChartViewAmount = new BarChartView(branchBusinessConditionsBarChartActivity.getApplicationContext(), true);
                    barChartViewAmount.initData(totalAmount, totalAmount, objectName, "营业收入统计");
                    View viewAmount = barChartViewAmount.getBarChartView();
                    ((LinearLayout) branchBusinessConditionsBarChartActivity.findViewById(R.id.branch_business_conditions_bar_chart_linearlayout)).addView(viewCount);
                    ((LinearLayout) branchBusinessConditionsBarChartActivity.findViewById(R.id.branch_business_conditions_bar_chart2_linearlayout)).addView(viewAmount);
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(branchBusinessConditionsBarChartActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(branchBusinessConditionsBarChartActivity, branchBusinessConditionsBarChartActivity.getString(R.string.login_error_message));
                branchBusinessConditionsBarChartActivity.userinfoApplication.exitForLogin(branchBusinessConditionsBarChartActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + branchBusinessConditionsBarChartActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(branchBusinessConditionsBarChartActivity);
                branchBusinessConditionsBarChartActivity.packageUpdateUtil = new PackageUpdateUtil(branchBusinessConditionsBarChartActivity, branchBusinessConditionsBarChartActivity.mHandler, fileCache, downloadFileUrl, false, branchBusinessConditionsBarChartActivity.userinfoApplication);
                branchBusinessConditionsBarChartActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                branchBusinessConditionsBarChartActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = branchBusinessConditionsBarChartActivity.getFileStreamPath(filename);
                file.getName();
                branchBusinessConditionsBarChartActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (branchBusinessConditionsBarChartActivity.requestWebServiceThread != null) {
                branchBusinessConditionsBarChartActivity.requestWebServiceThread.interrupt();
                branchBusinessConditionsBarChartActivity.requestWebServiceThread = null;
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
                    if (cycleType == 0) {
                        // 日的场合
                        getDataStatisticsJson.put("ObjectType", 1);
                        getDataStatisticsJson.put("MonthCount", 7);
                        getDataStatisticsJson.put("ExtractItemType", 1);
                        getDataStatisticsJson.put("AccountID", 0);
                        getDataStatisticsJson.put("StartTime", reportByOtherEndTime);
                        getDataStatisticsJson.put("EndTime", reportByOtherEndTime);
                        getDataStatisticsJson.put("TimeChooseFlag", cycleType);
                    } else {
                        // 月，季，年，自定义的场合
                        getDataStatisticsJson.put("ObjectType", 1);
                        getDataStatisticsJson.put("MonthCount", 6);
                        getDataStatisticsJson.put("ExtractItemType", 1);
                        getDataStatisticsJson.put("AccountID", 0);
                        getDataStatisticsJson.put("StartTime", reportByOtherEndTime);
                        getDataStatisticsJson.put("EndTime", reportByOtherEndTime);
                        getDataStatisticsJson.put("TimeChooseFlag", cycleType);
                    }
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
                        branchStatisticsList = new ArrayList<BranchStatistics>();
                        if (statisticsJsonArray != null) {
                            for (int i = 0; i < statisticsJsonArray.length(); i++) {
                                BranchStatistics bs = new BranchStatistics();
                                JSONObject csJson = null;
                                try {
                                    csJson = (JSONObject) statisticsJsonArray.get(i);
                                } catch (JSONException e) {
                                }
                                int objectCount = 0;//服务次数或者商品个数
                                String objectName = "";//抽取名
                                double totalAmount = 0;
                                try {
                                    if (csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")) {
                                        objectCount = csJson.getInt("ObjectCount");
                                    }
                                    if (csJson.has("ObjectName") && !csJson.isNull("ObjectName")) {
                                        objectName = csJson.getString("ObjectName");
                                    }
                                    if (csJson.has("TotalAmout") && !csJson.isNull("TotalAmout")) {
                                        totalAmount = csJson.getDouble("TotalAmout");
                                    }
                                } catch (JSONException e) {
                                }
                                bs.setObjectCount(objectCount);
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

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.branch_business_conditions_detail_list_btn:
                Intent destIntent = new Intent();
                destIntent.setClass(this, BranchBusinessConditionsStatisticsBarChartDetailListActivity.class);
                destIntent.putExtra("ObjectType", 1);
                destIntent.putExtra("MonthCount", 6);
                destIntent.putExtra("ExtractItemType", 1);
                destIntent.putExtra("AccountID", 0);
                destIntent.putExtra("StartTime", reportByOtherEndTime);
                destIntent.putExtra("EndTime", reportByOtherEndTime);
                destIntent.putExtra("TimeChooseFlag", cycleType);
                destIntent.putExtra("reportByOtherEndTimeTxt", reportByOtherEndTimeTxt);
                startActivity(destIntent);
                this.finish();
                break;
            //周期选项弹出
            case R.id.report_filter_tag_view_br1:
                if (filterRelativelayout.getVisibility() == View.VISIBLE) {
                    filterRelativelayout.setVisibility(View.GONE);
                    filterperiodlinearlayoutbr1.setVisibility(View.GONE);
                    filterbyperiodtitlebr1.setVisibility(View.GONE);
                    filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                    reportbyotherdatetxtbr1.setVisibility(View.GONE);
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
        filterperiodlinearlayoutbr1.setVisibility(View.VISIBLE);
        filterbyperiodtitlebr1.setVisibility(View.VISIBLE);
        //日期输入框显示
        filterPeriodItemRelativeLayout.setVisibility(View.VISIBLE);
        reportbyotherdatetxtbr1.setVisibility(View.VISIBLE);
        DateSelect();
        final LinearLayout filterPeriodLinearlayout = (LinearLayout) filterRelativelayout.findViewById(R.id.filter_period_linearlayout_br1);
        final TextView filterByDay = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_day_br1);
        final TextView filterByMonth = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_month_br1);
        final TextView filterBySeason = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_season_br1);
        final TextView filterByYear = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_year_br1);
        final TextView filterByWeek = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_week_br1);
        resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
        // 周期类型判断
        if (cycleType == 0)
            filterByDay.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 1)
            filterByWeek.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 2)
            filterByMonth.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 3)
            filterBySeason.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 4)
            filterByYear.setBackgroundResource(R.xml.report_shape_corner_round);
        Button queryDateBtn = (Button) filterRelativelayout.findViewById(R.id.report_query_btn_br1);
        //日
        filterByDay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
                //选中效果
                filterByDay.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 0;
                //日期选择
                DateSelect();
            }
        });
        //周
        filterByWeek.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
                //选中效果
                filterByWeek.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 1;
                //日期选择
                DateSelect();
            }
        });
        //月
        filterByMonth.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
                //选中效果
                filterByMonth.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 2;
                //日期选择
                DateSelect();
            }
        });
        //季
        filterBySeason.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
                //选中效果
                filterBySeason.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 3;
                //日期选择
                DateSelect();
            }
        });
        //年
        filterByYear.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByWeek, filterByMonth, filterBySeason, filterByYear);
                //选中效果
                filterByYear.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 4;
                //日期选择
                DateSelect();
            }
        });
        //完成按钮
        queryDateBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                getCustomerStatisticsPieData();
                filterRelativelayout.setVisibility(View.GONE);
            }
        });
        filterRelativelayout.setVisibility(View.VISIBLE);
    }

    //日期选择
    private void DateSelect() {
        //结束日期选择
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date_br1)).setText(reportByOtherEndTimeTxt);
        ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date_br1)).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                final TextView endDateText = (TextView) view;
                Calendar calendarEnd = Calendar.getInstance();
                if (enddateflg == 0) {
                    endyear = calendarEnd.get(calendarEnd.YEAR);
                    endmonthOfYear = calendarEnd.get(calendarEnd.MONTH);
                    enddayOfMonth = calendarEnd.get(calendarEnd.DAY_OF_MONTH);
                }
                DatePickerDialog endDateDialog = new DatePickerDialog(BranchBusinessConditionsBarChartActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        endDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                        reportByOtherEndTimeTxt = year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日";
                        reportByOtherEndTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                        endyear = year;
                        endmonthOfYear = monthOfYear;
                        enddayOfMonth = dayOfMonth;
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
    }

    //选中效果去除
    protected void resetFilterPeroid(TextView filterByDay, TextView filterByWeek, TextView filterByMonth, TextView filterBySeason, TextView filterByYear) {
        filterByDay.setBackgroundDrawable(null);
        filterByWeek.setBackgroundDrawable(null);
        filterByMonth.setBackgroundDrawable(null);
        filterBySeason.setBackgroundDrawable(null);
        filterByYear.setBackgroundDrawable(null);
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        exit = true;
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

}
