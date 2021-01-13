package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import cn.com.antika.adapter.CustomerEcardBalanceChangeListItemAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerEcardBalanceChange;
import cn.com.antika.bean.DownloadInfo;
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
 * 顾客E卡余额变动分析
 * */

public class CustomerEcardBalanceChangeAnalyticsActivity extends BaseActivity {
    private CustomerEcardBalanceChangeAnalyticsActivityHandler mHandler = new CustomerEcardBalanceChangeAnalyticsActivityHandler(this);
    private ListView customerEcardBalanceChangeAnalyticsListView;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private List<CustomerEcardBalanceChange> customerEcardBalanceChangeList;
    private String startTime, endTime;
    private int cycleType, objectType, objectID, orderType, productType,
            extractItemType, reportType;
    private TextView customerEcardBalanceChangeTitleText, reportDetailListByOtherStartTimeText, reportDetailListByOtherEndTimeText;
    // 其他日期查询
    private RelativeLayout reportDetailListByOtherRelativelayout;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_ecard_balance_change_analytics);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class CustomerEcardBalanceChangeAnalyticsActivityHandler extends Handler {
        private final CustomerEcardBalanceChangeAnalyticsActivity customerEcardBalanceChangeAnalyticsActivity;

        private CustomerEcardBalanceChangeAnalyticsActivityHandler(CustomerEcardBalanceChangeAnalyticsActivity activity) {
            WeakReference<CustomerEcardBalanceChangeAnalyticsActivity> weakReference = new WeakReference<CustomerEcardBalanceChangeAnalyticsActivity>(activity);
            customerEcardBalanceChangeAnalyticsActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (customerEcardBalanceChangeAnalyticsActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerEcardBalanceChangeAnalyticsActivity.progressDialog != null) {
                customerEcardBalanceChangeAnalyticsActivity.progressDialog.dismiss();
                customerEcardBalanceChangeAnalyticsActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                customerEcardBalanceChangeAnalyticsActivity.customerEcardBalanceChangeAnalyticsListView
                        .setAdapter(new CustomerEcardBalanceChangeListItemAdapter(
                                customerEcardBalanceChangeAnalyticsActivity,
                                customerEcardBalanceChangeAnalyticsActivity.customerEcardBalanceChangeList));
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(
                        customerEcardBalanceChangeAnalyticsActivity,
                        "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(
                        customerEcardBalanceChangeAnalyticsActivity,
                        customerEcardBalanceChangeAnalyticsActivity.getString(R.string.login_error_message));
                customerEcardBalanceChangeAnalyticsActivity.userinfoApplication
                        .exitForLogin(customerEcardBalanceChangeAnalyticsActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerEcardBalanceChangeAnalyticsActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerEcardBalanceChangeAnalyticsActivity);
                customerEcardBalanceChangeAnalyticsActivity.packageUpdateUtil = new PackageUpdateUtil(customerEcardBalanceChangeAnalyticsActivity, customerEcardBalanceChangeAnalyticsActivity.mHandler, fileCache, downloadFileUrl, false, customerEcardBalanceChangeAnalyticsActivity.userinfoApplication);
                customerEcardBalanceChangeAnalyticsActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                customerEcardBalanceChangeAnalyticsActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerEcardBalanceChangeAnalyticsActivity.getFileStreamPath(filename);
                file.getName();
                customerEcardBalanceChangeAnalyticsActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (customerEcardBalanceChangeAnalyticsActivity.requestWebServiceThread != null) {
                customerEcardBalanceChangeAnalyticsActivity.requestWebServiceThread.interrupt();
                customerEcardBalanceChangeAnalyticsActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        customerEcardBalanceChangeAnalyticsListView = (ListView) findViewById(R.id.customer_ecard_balance_change_analytics_list);
        customerEcardBalanceChangeTitleText = (TextView) findViewById(R.id.customer_ecard_balance_change_analytics_title);
        reportDetailListByOtherRelativelayout = (RelativeLayout) findViewById(R.id.report_detail_list_by_other_relativelayout);
        reportDetailListByOtherStartTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_start_date);
        reportDetailListByOtherEndTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_end_date);
        Intent intent = getIntent();
        reportType = intent.getIntExtra("REPORT_TYPE", 0);
        cycleType = intent.getIntExtra("CYCLE_TYPE", 0);
        orderType = intent.getIntExtra("ORDER_TYPE", 0);
        productType = intent.getIntExtra("PRODUCT_TYPE", 0);
        extractItemType = intent.getIntExtra("EXTRACT_ITEM_TYPE", 0);
        if (reportType == Constant.ALL_BRANCH_REPORT || reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT)
            objectID = intent.getIntExtra("OBJECT_ID", 0);
        if (reportType == Constant.MY_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.MY_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.COMPANY_REPORT) {
            objectType = 2;
        } else if (reportType == Constant.EMPLOYEE_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.ALL_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.GROUP_REPORT) {
            objectType = 3;
        }
        String dateTypeStr = "";
        if (cycleType == 0)
            dateTypeStr = "(日)";
        else if (cycleType == 1)
            dateTypeStr = "(月)";
        else if (cycleType == 2)
            dateTypeStr = "(季)";
        else if (cycleType == 3)
            dateTypeStr = "(年)";
        else if (cycleType == 4) {
            startTime = intent.getStringExtra("START_TIME");
            endTime = intent.getStringExtra("END_TIME");
            reportDetailListByOtherRelativelayout.setVisibility(View.VISIBLE);
            reportDetailListByOtherStartTimeText.setText(convertStringToDate(startTime));
            reportDetailListByOtherEndTimeText.setText(convertStringToDate(endTime));
        }
        customerEcardBalanceChangeTitleText.setText(getString(R.string.customer_ecard_balance_change_analytics_title_text) + dateTypeStr);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getReportDetail_1_7_2";
                String endPoint = "report";
                JSONObject reportDetailJson = new JSONObject();
                try {
                    if (reportType == Constant.ALL_BRANCH_REPORT)
                        reportDetailJson.put("BranchID", objectID);
                    else
                        reportDetailJson.put("BranchID", userinfoApplication
                                .getAccountInfo().getBranchId());
                    if (reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT) {
                        reportDetailJson.put("AccountID", objectID);
                    } else
                        reportDetailJson.put("AccountID", userinfoApplication
                                .getAccountInfo().getAccountId());
                    reportDetailJson.put("CycleType", cycleType);
                    reportDetailJson.put("ObjectType", objectType);
                    reportDetailJson.put("OrderType", orderType);
                    reportDetailJson.put("ProductType", productType);
                    reportDetailJson.put("ExtractItemType", extractItemType);
                    reportDetailJson.put("StartTime", startTime);
                    reportDetailJson.put("EndTime", endTime);
                    reportDetailJson.put("SortType", 1);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil
                        .requestWebServiceWithSSLUseJson(endPoint, methodName,
                                reportDetailJson.toString(),
                                userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                    // TODO Auto-generated catch block
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray balanceDetailArray = null;
                        try {
                            balanceDetailArray = resultJson.getJSONObject("Data").getJSONArray("BalanceDetail");
                        } catch (JSONException e) {
                        }
                        customerEcardBalanceChangeList = new ArrayList<CustomerEcardBalanceChange>();
                        if (balanceDetailArray != null) {
                            for (int i = 0; i < balanceDetailArray.length(); i++) {
                                CustomerEcardBalanceChange customerEcardBalanceChange = new CustomerEcardBalanceChange();
                                JSONObject balanceDetailJson = null;
                                try {
                                    balanceDetailJson = balanceDetailArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    // TODO Auto-generated catch block
                                }
                                String customerName = "";
                                String customerEcardBalanceChangeBalance = "";
                                String customerEcardBalanceChangeRecharge = "";
                                String customerEcardBalanceChangeOut = "";
                                try {
                                    if (balanceDetailJson.has("CustomerName") && !balanceDetailJson.isNull("CustomerName"))
                                        customerName = balanceDetailJson.getString("CustomerName");
                                    if (balanceDetailJson.has("RechargeAmount") && !balanceDetailJson.isNull("RechargeAmount"))
                                        customerEcardBalanceChangeRecharge = balanceDetailJson.getString("RechargeAmount");
                                    if (balanceDetailJson.has("PayAmount") && !balanceDetailJson.isNull("PayAmount"))
                                        customerEcardBalanceChangeOut = balanceDetailJson.getString("PayAmount");
                                    if (balanceDetailJson.has("BalanceAmount") && !balanceDetailJson.isNull("BalanceAmount"))
                                        customerEcardBalanceChangeBalance = balanceDetailJson.getString("BalanceAmount");
                                } catch (JSONException e) {
                                    // TODO Auto-generated catch block
                                }
                                customerEcardBalanceChange.setCustomerName(customerName);
                                customerEcardBalanceChange.setCustomerEcardBalanceChangeBalance(new BigDecimal(customerEcardBalanceChangeBalance));
                                customerEcardBalanceChange.setCustomerEcardBalanceChangeOut(new BigDecimal(customerEcardBalanceChangeOut));
                                customerEcardBalanceChange.setCustomerEcardBalanceChangeRecharge(new BigDecimal(customerEcardBalanceChangeRecharge));
                                customerEcardBalanceChangeList.add(customerEcardBalanceChange);
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

    private String convertStringToDate(String dateSource) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Calendar calendar = Calendar.getInstance();
        Date date = null;
        try {
            date = simpleDateFormat.parse(dateSource);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            date = null;
        }
        if (date != null) {
            calendar.setTime(date);
        }
        return calendar.get(Calendar.YEAR) + "年"
                + (calendar.get(Calendar.MONTH) + 1) + "月"
                + calendar.get(Calendar.DAY_OF_MONTH) + "日";
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
