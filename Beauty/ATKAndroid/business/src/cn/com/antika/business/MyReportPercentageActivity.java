package cn.com.antika.business;

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
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Calendar;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ReportAccountCommProfit;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 我的报表提成页面
 * */
public class MyReportPercentageActivity extends BaseActivity {
    private MyReportPercentageActivityHandler mHandler = new MyReportPercentageActivityHandler(this);
    private PackageUpdateUtil packageUpdateUtil;
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private String reportByOtherStartTime, reportByOtherEndTime;
    private Thread requestWebServiceThread;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_my_report_percentage);
        initView();
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        Calendar nowDate = Calendar.getInstance();
        userinfoApplication = UserInfoApplication.getInstance();
        int nowYear = nowDate.get(Calendar.YEAR);
        int nowMonth = nowDate.get(Calendar.MONTH) + 1;
        int nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
        reportByOtherStartTime = nowYear + "-" + nowMonth + "-" + nowDay;
        reportByOtherEndTime = nowYear + "-" + nowMonth + "-" + nowDay;
        ((TextView) findViewById(R.id.report_by_other_start_date)).setText(nowYear + "年" + nowMonth + "月" + nowDay + "日");
        ((TextView) findViewById(R.id.report_by_other_start_date)).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                Calendar calendarStart = Calendar.getInstance();
                final TextView startDateText = (TextView) view;
                DatePickerDialog startDateDialog = new DatePickerDialog(MyReportPercentageActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        startDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                        reportByOtherStartTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                    }
                }, calendarStart.get(calendarStart.YEAR),
                        calendarStart.get(calendarStart.MONTH),
                        calendarStart.get(calendarStart.DAY_OF_MONTH));
                startDateDialog.show();
            }
        });
        ((TextView) findViewById(R.id.report_by_other_end_date)).setText(nowYear + "年" + nowMonth + "月" + nowDay + "日");
        ((TextView) findViewById(R.id.report_by_other_end_date)).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                final TextView endDateText = (TextView) view;
                Calendar calendarEnd = Calendar.getInstance();
                DatePickerDialog endDateDialog = new DatePickerDialog(MyReportPercentageActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                        endDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                        reportByOtherEndTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                    }
                }, calendarEnd.get(calendarEnd.YEAR),
                        calendarEnd.get(calendarEnd.MONTH),
                        calendarEnd.get(calendarEnd.DAY_OF_MONTH));
                endDateDialog.show();
            }
        });
        Button queryDateBtn = (Button) findViewById(R.id.report_query_btn);
        queryDateBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                requestWebService();
            }
        });
        requestWebService();
    }

    private static class MyReportPercentageActivityHandler extends Handler {
        private final MyReportPercentageActivity myReportPercentageActivity;

        private MyReportPercentageActivityHandler(MyReportPercentageActivity activity) {
            WeakReference<MyReportPercentageActivity> weakReference = new WeakReference<MyReportPercentageActivity>(activity);
            myReportPercentageActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (myReportPercentageActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (myReportPercentageActivity.progressDialog != null) {
                myReportPercentageActivity.progressDialog.dismiss();
                myReportPercentageActivity.progressDialog = null;
            }
            if (myReportPercentageActivity.requestWebServiceThread != null) {
                myReportPercentageActivity.requestWebServiceThread.interrupt();
                myReportPercentageActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                ReportAccountCommProfit rac = (ReportAccountCommProfit) message.obj;
                NumberFormat numberFormat = NumberFormat.getInstance();
                numberFormat.setMaximumFractionDigits(2);
                //服务销售
                BigDecimal serviceAndProductSalesAchievementBigDecimal = new BigDecimal(rac.getServiceAndProductSalesAchievement());
                BigDecimal serviceAndProductSalesPercentageBigDecimal = new BigDecimal(rac.getServiceAndProductSalesPercentage());
                BigDecimal serviceOperationAchievementBigDecimal = new BigDecimal(rac.getServiceOperationAchievement());
                BigDecimal serviceOperationPercentageBigDecimal = new BigDecimal(rac.getServiceOperationPercentage());
                BigDecimal ecardSalesAchievementBigDecimal = new BigDecimal(rac.getEcardSalesAchievement());
                BigDecimal ecardSalesPercentageBigDecimal = new BigDecimal(rac.getEcardSalesPercentage());
                ((TextView) myReportPercentageActivity.findViewById(R.id.service_and_product_sale_achievement_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceAndProductSalesAchievementBigDecimal));
                ((TextView) myReportPercentageActivity.findViewById(R.id.service_and_product_sale_percentage_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceAndProductSalesPercentageBigDecimal));
                ((TextView) myReportPercentageActivity.findViewById(R.id.service_operation_achievement_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceOperationAchievementBigDecimal));
                ((TextView) myReportPercentageActivity.findViewById(R.id.service_operation_percentage_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceOperationPercentageBigDecimal));
                ((TextView) myReportPercentageActivity.findViewById(R.id.ecard_sale_achievement_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesAchievementBigDecimal));
                ((TextView) myReportPercentageActivity.findViewById(R.id.ecard_sale_percentage_text)).setText(myReportPercentageActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesPercentageBigDecimal));
            } else if (message.what == 2)
                DialogUtil.createShortDialog(myReportPercentageActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(myReportPercentageActivity, myReportPercentageActivity.getString(R.string.login_error_message));
                myReportPercentageActivity.userinfoApplication.exitForLogin(myReportPercentageActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + myReportPercentageActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(myReportPercentageActivity);
                myReportPercentageActivity.packageUpdateUtil = new PackageUpdateUtil(myReportPercentageActivity, myReportPercentageActivity.mHandler, fileCache, downloadFileUrl, false, myReportPercentageActivity.userinfoApplication);
                myReportPercentageActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                myReportPercentageActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = myReportPercentageActivity.getFileStreamPath(filename);
                file.getName();
                myReportPercentageActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    private void requestWebService() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetAccountCommProfit";
                String endPoint = "report";
                JSONObject reportJson = new JSONObject();
                try {
                    reportJson.put("StartTime", reportByOtherStartTime);
                    reportJson.put("EndTime", reportByOtherEndTime);
                } catch (JSONException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResult);
                } catch (JSONException e) {

                }
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String serverMessage = "";
                    try {
                        code = resultJson.getInt("Code");
                        serverMessage = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        JSONObject accountReportJson = null;
                        try {
                            accountReportJson = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        if (accountReportJson != null) {
                            double serviceAndProductSalesAchievement = 0;//产品销售业绩
                            double serviceAndProductSalesPercentage = 0;//产品销售提成
                            double serviceOperationAchievement = 0;//服务操作业绩
                            double serviceOperationPercentage = 0;//服务操作提成
                            double ecardSalesAchievement = 0;//储值卡销售业绩
                            double ecardSalesPercentage = 0;//储值卡销售提成

                            try {
                                if (accountReportJson.has("SalesProfit"))
                                    serviceAndProductSalesAchievement = accountReportJson.getDouble("SalesProfit");
                                if (accountReportJson.has("SalesComm"))
                                    serviceAndProductSalesPercentage = accountReportJson.getDouble("SalesComm");
                                if (accountReportJson.has("OptProfit"))
                                    serviceOperationAchievement = accountReportJson.getDouble("OptProfit");
                                if (accountReportJson.has("OptComm"))
                                    serviceOperationPercentage = accountReportJson.getDouble("OptComm");
                                if (accountReportJson.has("ECardProfit"))
                                    ecardSalesAchievement = accountReportJson.getDouble("ECardProfit");
                                if (accountReportJson.has("ECardComm"))
                                    ecardSalesPercentage = accountReportJson.getDouble("ECardComm");
                            } catch (JSONException e) {
                            }
                            ReportAccountCommProfit rac = new ReportAccountCommProfit();
                            rac.setServiceAndProductSalesAchievement(serviceAndProductSalesAchievement);
                            rac.setServiceAndProductSalesPercentage(serviceAndProductSalesPercentage);
                            rac.setServiceOperationAchievement(serviceOperationAchievement);
                            rac.setServiceOperationPercentage(serviceOperationPercentage);
                            rac.setEcardSalesAchievement(ecardSalesAchievement);
                            rac.setEcardSalesPercentage(ecardSalesPercentage);
                            Message message = new Message();
                            message.obj = rac;
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
