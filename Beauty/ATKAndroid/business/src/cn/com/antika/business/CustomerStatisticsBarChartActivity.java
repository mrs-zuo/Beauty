package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
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
import cn.com.antika.bean.CustomerStatistics;
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
 * 顾客到店次数及消费金额柱状图
 * */
@SuppressLint("LongLogTag")
public class CustomerStatisticsBarChartActivity extends BaseActivity implements OnClickListener {
    private CustomerStatisticsBarChartActivityHandler mHandler = new CustomerStatisticsBarChartActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private List<CustomerStatistics> customerStatisticsList;
    private LinearLayout customerStatisticsBarChartLinearlayout;
    private ImageButton customerStatisticsBarChartDetailListBtn;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_statistics_bar_chart);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        ((TextView) findViewById(R.id.customer_statistics_bar_chart_title_text)).setText("消费倾向分析" + "(" + userinfoApplication.getSelectedCustomerName() + ")");
        customerStatisticsBarChartLinearlayout = (LinearLayout) findViewById(R.id.customer_statistics_bar_chart_linearlayout);
        customerStatisticsBarChartDetailListBtn = (ImageButton) findViewById(R.id.customer_statistics_bar_chart_detail_list_btn);
        customerStatisticsBarChartDetailListBtn.setOnClickListener(this);
        getCustomerStatisticsPieData();
    }

    private static class CustomerStatisticsBarChartActivityHandler extends Handler {
        private final CustomerStatisticsBarChartActivity customerStatisticsBarChartActivity;

        private CustomerStatisticsBarChartActivityHandler(CustomerStatisticsBarChartActivity activity) {
            WeakReference<CustomerStatisticsBarChartActivity> weakReference = new WeakReference<CustomerStatisticsBarChartActivity>(activity);
            customerStatisticsBarChartActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerStatisticsBarChartActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerStatisticsBarChartActivity.progressDialog != null) {
                customerStatisticsBarChartActivity.progressDialog.dismiss();
                customerStatisticsBarChartActivity.progressDialog = null;
            }
            if (message.what == 1) {
                if (customerStatisticsBarChartActivity.customerStatisticsList != null && customerStatisticsBarChartActivity.customerStatisticsList.size() > 0) {
                    List<String> objectName = new ArrayList<String>();
                    double[] objectCount = new double[customerStatisticsBarChartActivity.customerStatisticsList.size()];
                    double[] totalAmount = new double[customerStatisticsBarChartActivity.customerStatisticsList.size()];
                    objectName.add("");
                    for (int j = 0; j < customerStatisticsBarChartActivity.customerStatisticsList.size(); j++) {
                        objectName.add(customerStatisticsBarChartActivity.customerStatisticsList.get(j).getObjectName());
                        objectCount[j] = customerStatisticsBarChartActivity.customerStatisticsList.get(j).getObjectCount();
                        totalAmount[j] = customerStatisticsBarChartActivity.customerStatisticsList.get(j).getTotalAmount();
                    }
                    //顾客到店次数
                    BarChartView barChartViewCount = new BarChartView(customerStatisticsBarChartActivity.getApplicationContext(), true);
                    barChartViewCount.initData(objectCount, totalAmount, objectName, "每月到店次数");
                    View viewCount = barChartViewCount.getBarChartView();
                    //顾客消费金额
                    BarChartView barChartViewAmount = new BarChartView(customerStatisticsBarChartActivity.getApplicationContext(), true);
                    barChartViewAmount.initData(totalAmount, totalAmount, objectName, "每月消费额");
                    View viewAmount = barChartViewAmount.getBarChartView();
                    customerStatisticsBarChartActivity.customerStatisticsBarChartLinearlayout.addView(viewCount);
                    ((LinearLayout) customerStatisticsBarChartActivity.findViewById(R.id.customer_statistics_bar_chart2_linearlayout)).addView(viewAmount);
                    Log.d("customerStatisticsBarChartLinearlayout ChildCount", String.valueOf(customerStatisticsBarChartActivity.customerStatisticsBarChartLinearlayout.getChildCount()));
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(customerStatisticsBarChartActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerStatisticsBarChartActivity, customerStatisticsBarChartActivity.getString(R.string.login_error_message));
                customerStatisticsBarChartActivity.userinfoApplication.exitForLogin(customerStatisticsBarChartActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerStatisticsBarChartActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerStatisticsBarChartActivity);
                customerStatisticsBarChartActivity.packageUpdateUtil = new PackageUpdateUtil(customerStatisticsBarChartActivity, customerStatisticsBarChartActivity.mHandler, fileCache, downloadFileUrl, false, customerStatisticsBarChartActivity.userinfoApplication);
                customerStatisticsBarChartActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerStatisticsBarChartActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerStatisticsBarChartActivity.getFileStreamPath(filename);
                file.getName();
                customerStatisticsBarChartActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (customerStatisticsBarChartActivity.requestWebServiceThread != null) {
                customerStatisticsBarChartActivity.requestWebServiceThread.interrupt();
                customerStatisticsBarChartActivity.requestWebServiceThread = null;
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
                String methodName = "GetDataStatisticsList";
                String endPoint = "Statistics";
                JSONObject getDataStatisticsJson = new JSONObject();
                try {
                    getDataStatisticsJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    getDataStatisticsJson.put("ExtractItemType", 3);
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
                        customerStatisticsList = new ArrayList<CustomerStatistics>();
                        if (statisticsJsonArray != null) {
                            for (int i = 0; i < statisticsJsonArray.length(); i++) {
                                CustomerStatistics cs = new CustomerStatistics();
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
                                cs.setObjectCount(objectCount);
                                cs.setObjectName(objectName);
                                cs.setTotalAmount(totalAmount);
                                customerStatisticsList.add(cs);
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
        if (view.getId() == R.id.customer_statistics_bar_chart_detail_list_btn) {
            Intent destIntent = new Intent();
            destIntent.setClass(this, CustomerStatisticsBarChartDetailListActivity.class);
            startActivity(destIntent);
            this.finish();
        }
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
