package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ReportTotal;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ReportTotalActivity extends BaseActivity {
    private ReportTotalActivityHandler mHandler = new ReportTotalActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private TextView reportTotalEndDateText;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_report_total);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        reportTotalEndDateText = (TextView) findViewById(R.id.report_total_end_date_text);
        SimpleDateFormat simpleDateFormate = new SimpleDateFormat("yyyy年MM月dd日");
        reportTotalEndDateText.setText(getString(R.string.report_total_end_date_title_text) + simpleDateFormate.format(new Date()));
        getReportTotalByWebService();
    }

    private static class ReportTotalActivityHandler extends Handler {
        private final ReportTotalActivity reportTotalActivity;

        private ReportTotalActivityHandler(ReportTotalActivity activity) {
            WeakReference<ReportTotalActivity> weakReference = new WeakReference<ReportTotalActivity>(activity);
            reportTotalActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (reportTotalActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (reportTotalActivity.progressDialog != null) {
                reportTotalActivity.progressDialog.dismiss();
                reportTotalActivity.progressDialog = null;
            }
            if (reportTotalActivity.requestWebServiceThread != null) {
                reportTotalActivity.requestWebServiceThread.interrupt();
                reportTotalActivity.requestWebServiceThread = null;
            }
            // 显示累计数据统计在视图上
            if (message.what == 1) {
                ReportTotal reportTotal = (ReportTotal) message.obj;
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_effective_customer_number_text)).setText(reportTotal.getTotalCustomerNumber() + "人");
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_effective_customer_app_number_text)).setText(reportTotal.getTotalCustomerApp() + "人");
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_effective_customer_touch_text)).setText(reportTotal.getTotalCustomerTouch() + "人");
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_complete_order_number_text)).setText(reportTotal.getTotalCompleteOrderNumber() + "个");
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_effect_order_number_text)).setText(reportTotal.getTotalEffectOrderNumber() + "个");
                ((TextView) reportTotalActivity.findViewById(R.id.report_total_order_sales_text)).setText(reportTotalActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(reportTotal.getTotalSales())));

            } else if (message.what == 2)
                DialogUtil.createShortDialog(reportTotalActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(reportTotalActivity, reportTotalActivity.getString(R.string.login_error_message));
                reportTotalActivity.userinfoApplication.exitForLogin(reportTotalActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + reportTotalActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(reportTotalActivity);
                reportTotalActivity.packageUpdateUtil = new PackageUpdateUtil(reportTotalActivity, reportTotalActivity.mHandler, fileCache, downloadFileUrl, false, reportTotalActivity.userinfoApplication);
                reportTotalActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                reportTotalActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = reportTotalActivity.getFileStreamPath(filename);
                file.getName();
                reportTotalActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void getReportTotalByWebService() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getTotalCountReport";
                String endPoint = "report";
                JSONObject reportTotalJson = new JSONObject();
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportTotalJson.toString(), userinfoApplication);
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
                        JSONObject reportTotal = null;
                        try {
                            reportTotal = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        if (reportTotal != null) {
                            int reportTotalCustomerNumber = 0;//有效顾客数量
                            int reportTotalCustomerAppNumber = 0;//顾客端用户
                            int reportTotalCustomerTouchNumber = 0;//公众号用户

                            int reportTotalCompleteOrderNumber = 0;// 完成订单数量
                            int reportTotalEffectiveOrderNumber = 0;// 有效订单数量
                            double reportTotalOrderTotalSalePrice = 0;// 订单总金额
                            try {
                                if (reportTotal.has("AllCustomerCount") && !reportTotal.isNull("AllCustomerCount"))
                                    reportTotalCustomerNumber = reportTotal.getInt("AllCustomerCount");
                                if (reportTotal.has("ClientCount") && !reportTotal.isNull("ClientCount"))
                                    reportTotalCustomerAppNumber = reportTotal.getInt("ClientCount");
                                if (reportTotal.has("WeChatCount") && !reportTotal.isNull("WeChatCount"))
                                    reportTotalCustomerTouchNumber = reportTotal.getInt("WeChatCount");

                                if (reportTotal.has("CompleteOrderCount") && !reportTotal.isNull("CompleteOrderCount"))
                                    reportTotalCompleteOrderNumber = reportTotal.getInt("CompleteOrderCount");
                                if (reportTotal.has("EffectOrderCount") && !reportTotal.isNull("EffectOrderCount"))
                                    reportTotalEffectiveOrderNumber = reportTotal.getInt("EffectOrderCount");
                                if (reportTotal.has("OrderTotalSalePrice") && !reportTotal.isNull("OrderTotalSalePrice"))
                                    reportTotalOrderTotalSalePrice = reportTotal.getDouble("OrderTotalSalePrice");

                            } catch (JSONException e) {

                            }
                            ReportTotal rt = new ReportTotal();
                            rt.setTotalCustomerNumber(reportTotalCustomerNumber);
                            rt.setTotalCustomerApp(reportTotalCustomerAppNumber);
                            rt.setTotalCustomerTouch(reportTotalCustomerTouchNumber);
                            rt.setTotalEffectOrderNumber(reportTotalEffectiveOrderNumber);
                            rt.setTotalCompleteOrderNumber(reportTotalCompleteOrderNumber);
                            rt.setTotalSales(reportTotalOrderTotalSalePrice);
                            Message message = new Message();
                            message.obj = rt;
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
        if (mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
            // mHandler = null;
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
