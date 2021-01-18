package com.GlamourPromise.Beauty.Business;

import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.DatePicker;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BranchTotalReport;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.SegmentBar;
import com.GlamourPromise.Beauty.view.SegmentBar.OnSegmentBarChangedListener;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Calendar;

public class BranchTotalReportActivity extends BaseActivity implements OnClickListener {
    private BranchTotalReportActivityHandler mHandler = new BranchTotalReportActivityHandler(this);
    private SegmentBar segmentBar;
    private RelativeLayout reportByOtherRelativeLayout;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private TextView reportByOtherStartDate, reportByOtherEndDate,
            branchTotalCustomerCountText, branchTotalTGExecutingCountText,
            branchTotalTGFinishedCountText, branchTotalServiceOrderCountText,
            branchTotalCommodityOrderCountText, branchTotalSalesAmountText;
    private UserInfoApplication userinfoApplication;
    private ImageView reportByDateOtherQueryBtn;
    private String reportByOtherStartTime, reportByOtherEndTime;
    private PackageUpdateUtil packageUpdateUtil;
    private int cycleType;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_branch_total_report);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        reportByDateOtherQueryBtn = (ImageView) findViewById(R.id.branch_total_report_by_date_query_btn);
        reportByDateOtherQueryBtn.setOnClickListener(this);
        branchTotalCustomerCountText = (TextView) findViewById(R.id.branch_total_customer_count_text);
        branchTotalTGExecutingCountText = (TextView) findViewById(R.id.branch_total_tg_executing_count_text);
        branchTotalTGFinishedCountText = (TextView) findViewById(R.id.branch_total_tg_finished_count_text);
        branchTotalServiceOrderCountText = (TextView) findViewById(R.id.branch_total_service_order_count_text);
        branchTotalCommodityOrderCountText = (TextView) findViewById(R.id.branch_total_commodity_order_count_text);
        branchTotalSalesAmountText = (TextView) findViewById(R.id.branch_total_sales_amount_text);
        reportByOtherStartDate = (TextView) findViewById(R.id.report_by_other_start_date);
        reportByOtherStartDate.setOnClickListener(this);
        reportByOtherEndDate = (TextView) findViewById(R.id.report_by_other_end_date);
        reportByOtherEndDate.setOnClickListener(this);
        reportByOtherRelativeLayout = (RelativeLayout) findViewById(R.id.branch_total_report_by_other_relativelayout);
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
        segmentBar = (SegmentBar) findViewById(R.id.branch_total_segment_bar);
        segmentBar.setValue(this, new String[]{"日", "月", "季", "年", "..."});
        if (userinfoApplication.getScreenWidth() == 1536)
            segmentBar.setTextSize(20);
        else
            segmentBar.setTextSize(12);
        segmentBar.setTextColor(this.getResources().getColor(R.color.blue));
        cycleType = 0;
        segmentBar.setDefaultBarItem(0);
        segmentBar
                .setOnSegmentBarChangedListener(new OnSegmentBarChangedListener() {
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

    private static class BranchTotalReportActivityHandler extends Handler {
        private final BranchTotalReportActivity branchTotalReportActivity;

        private BranchTotalReportActivityHandler(BranchTotalReportActivity activity) {
            WeakReference<BranchTotalReportActivity> weakReference = new WeakReference<BranchTotalReportActivity>(activity);
            branchTotalReportActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (branchTotalReportActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (branchTotalReportActivity.progressDialog != null) {
                branchTotalReportActivity.progressDialog.dismiss();
                branchTotalReportActivity.progressDialog = null;
            }
            if (branchTotalReportActivity.requestWebServiceThread != null) {
                branchTotalReportActivity.requestWebServiceThread.interrupt();
                branchTotalReportActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                BranchTotalReport btr = (BranchTotalReport) message.obj;
                branchTotalReportActivity.branchTotalCustomerCountText.setText(String.valueOf(btr.getCustomerCount()));
                branchTotalReportActivity.branchTotalTGExecutingCountText.setText(String.valueOf(btr.getTgExecutingCount()));
                branchTotalReportActivity.branchTotalTGFinishedCountText.setText(String.valueOf(btr.getTgFinishedCount()));
                ((TextView) branchTotalReportActivity.findViewById(R.id.branch_total_tg_unconfirmed_count_text)).setText(String.valueOf(btr.getTgUnConfirmedCount()));
                branchTotalReportActivity.branchTotalServiceOrderCountText.setText(String.valueOf(btr.getServiceOrderCount()));
                branchTotalReportActivity.branchTotalCommodityOrderCountText.setText(String.valueOf(btr.getCommodityOrderCount()));
                ((TextView) branchTotalReportActivity.findViewById(R.id.branch_total_cancel_service_order_count_text)).setText(String.valueOf(btr.getCancelServiceOrderCount()));
                ((TextView) branchTotalReportActivity.findViewById(R.id.branch_total_cancel_commodity_order_count_text)).setText(String.valueOf(btr.getCancelCommodityOrderCount()));
                branchTotalReportActivity.branchTotalSalesAmountText.setText(branchTotalReportActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(btr.getSaleAmount()));
            } else if (message.what == 2)
                DialogUtil.createShortDialog(branchTotalReportActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(branchTotalReportActivity, branchTotalReportActivity.getString(R.string.login_error_message));
                branchTotalReportActivity.userinfoApplication.exitForLogin(branchTotalReportActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + branchTotalReportActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(branchTotalReportActivity);
                branchTotalReportActivity.packageUpdateUtil = new PackageUpdateUtil(branchTotalReportActivity, branchTotalReportActivity.mHandler, fileCache, downloadFileUrl, false, branchTotalReportActivity.userinfoApplication);
                branchTotalReportActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                branchTotalReportActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = branchTotalReportActivity.getFileStreamPath(filename);
                file.getName();
                branchTotalReportActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    private void requestWebService(int cycleType) {
        final int ct = cycleType;
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetBranchBusinessDetail";
                String endPoint = "Report";
                JSONObject branchTotalJson = new JSONObject();
                try {
                    branchTotalJson.put("CycleType", ct);
                    // 如果是按照日期查询
                    if (ct == 4) {
                        branchTotalJson.put("StartTime", reportByOtherStartTime);
                        branchTotalJson.put("EndTime", reportByOtherEndTime);
                    }
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, branchTotalJson.toString(), userinfoApplication);
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
                        JSONObject branchTotal = null;
                        try {
                            branchTotal = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {

                        }
                        if (branchTotal != null) {
                            int customerCount = 0;//到店顾客数
                            int tgExecutingCount = 0;//正在做的服务
                            int tgFinishedCount = 0;//完成的服务
                            int tgUnconfirmedCount = 0;
                            int serviceOrderCount = 0;//服务订单数
                            int commodityOrderCount = 0;//商品订单数
                            int cancelServiceOrderCount = 0;//取消服务订单数
                            int cancelCommodityOrderCount = 0;//取消商品订单数
                            String saleAmount = "0";//今日营业额
                            try {
                                if (branchTotal.has("CustomerCount"))
                                    customerCount = branchTotal.getInt("CustomerCount");
                                if (branchTotal.has("TGExecutingCount"))
                                    tgExecutingCount = branchTotal.getInt("TGExecutingCount");
                                if (branchTotal.has("TGFinishedCount"))
                                    tgFinishedCount = branchTotal.getInt("TGFinishedCount");
                                if (branchTotal.has("TGUnConfirmed"))
                                    tgUnconfirmedCount = branchTotal.getInt("TGUnConfirmed");
                                if (branchTotal.has("ServiceOrder"))
                                    serviceOrderCount = branchTotal.getInt("ServiceOrder");
                                if (branchTotal.has("CommodityOrder"))
                                    commodityOrderCount = branchTotal.getInt("CommodityOrder");
                                if (branchTotal.has("ServiceCancelCount"))
                                    cancelServiceOrderCount = branchTotal.getInt("ServiceCancelCount");
                                if (branchTotal.has("CommodityCancelCount"))
                                    cancelCommodityOrderCount = branchTotal.getInt("CommodityCancelCount");
                                if (branchTotal.has("SalesAmount"))
                                    saleAmount = branchTotal.getString("SalesAmount");
                            } catch (JSONException e) {
                                // TODO Auto-generated catch block
                                e.printStackTrace();
                            }
                            BranchTotalReport btr = new BranchTotalReport();
                            btr.setCustomerCount(customerCount);
                            btr.setTgExecutingCount(tgExecutingCount);
                            btr.setTgFinishedCount(tgFinishedCount);
                            btr.setTgUnConfirmedCount(tgUnconfirmedCount);
                            btr.setServiceOrderCount(serviceOrderCount);
                            btr.setCommodityOrderCount(commodityOrderCount);
                            btr.setCancelServiceOrderCount(cancelServiceOrderCount);
                            btr.setCancelCommodityOrderCount(cancelCommodityOrderCount);
                            btr.setSaleAmount(saleAmount);
                            Message message = new Message();
                            message.obj = btr;
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
            case R.id.branch_total_report_by_date_query_btn:
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
                DatePickerDialog endDateDialog = new DatePickerDialog(this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
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
