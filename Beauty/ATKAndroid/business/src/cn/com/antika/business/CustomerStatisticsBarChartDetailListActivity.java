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
import cn.com.antika.bean.CustomerStatistics;
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
 * 顾客到店次数消费 及充值详细列表页
 * */
@SuppressLint("ResourceType")
public class CustomerStatisticsBarChartDetailListActivity extends BaseActivity implements OnClickListener {
    private CustomerStatisticsBarChartDetailListActivityHandler mHandler = new CustomerStatisticsBarChartDetailListActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private List<CustomerStatistics> customerStatisticsList;
    private LinearLayout customerStatisticsBarChartDetailListLinearlayout;
    private ImageButton customerStatisticsBarChartDetailListBtn;
    private LayoutInflater layoutInflater;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_statistics_bar_chart_detail_list);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        ((TextView) findViewById(R.id.customer_statistics_bar_chart_detail_list_title_text)).setText("消费倾向分析" + "(" + userinfoApplication.getSelectedCustomerName() + ")");
        customerStatisticsBarChartDetailListLinearlayout = (LinearLayout) findViewById(R.id.customer_statistics_bar_chart_detail_list_linearlayout);
        customerStatisticsBarChartDetailListBtn = (ImageButton) findViewById(R.id.customer_statistics_bar_chart_detail_list_btn);
        customerStatisticsBarChartDetailListBtn.setOnClickListener(this);
        layoutInflater = LayoutInflater.from(this);
        getCustomerStatisticsPieData();
    }

    private static class CustomerStatisticsBarChartDetailListActivityHandler extends Handler {
        private final CustomerStatisticsBarChartDetailListActivity customerStatisticsBarChartDetailListActivity;

        private CustomerStatisticsBarChartDetailListActivityHandler(CustomerStatisticsBarChartDetailListActivity activity) {
            WeakReference<CustomerStatisticsBarChartDetailListActivity> weakReference = new WeakReference<CustomerStatisticsBarChartDetailListActivity>(activity);
            customerStatisticsBarChartDetailListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerStatisticsBarChartDetailListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerStatisticsBarChartDetailListActivity.progressDialog != null) {
                customerStatisticsBarChartDetailListActivity.progressDialog.dismiss();
                customerStatisticsBarChartDetailListActivity.progressDialog = null;
            }
            if (customerStatisticsBarChartDetailListActivity.requestWebServiceThread != null) {
                customerStatisticsBarChartDetailListActivity.requestWebServiceThread.interrupt();
                customerStatisticsBarChartDetailListActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                if (customerStatisticsBarChartDetailListActivity.customerStatisticsList != null && customerStatisticsBarChartDetailListActivity.customerStatisticsList.size() > 0) {
                    for (CustomerStatistics cs : customerStatisticsBarChartDetailListActivity.customerStatisticsList) {
                        View view = customerStatisticsBarChartDetailListActivity.layoutInflater.inflate(R.xml.customer_statistics_bar_chart_detail_list_item, null);
                        TextView objectNameText = (TextView) view.findViewById(R.id.object_name_text);
                        TextView consumeAmountText = (TextView) view.findViewById(R.id.consume_amount_text);
                        TextView objectCountText = (TextView) view.findViewById(R.id.objet_count_text);
                        TextView rechargeAmountText = (TextView) view.findViewById(R.id.recharge_amount_text);
                        objectNameText.setText(cs.getObjectName());
                        consumeAmountText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(cs.getConsumeAmount())));
                        objectCountText.setText(cs.getObjectCount() + "次");
                        rechargeAmountText.setText(UserInfoApplication.getInstance().getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(cs.getRechargeAmount())));
                        customerStatisticsBarChartDetailListActivity.customerStatisticsBarChartDetailListLinearlayout.addView(view);
                    }
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(customerStatisticsBarChartDetailListActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerStatisticsBarChartDetailListActivity, customerStatisticsBarChartDetailListActivity.getString(R.string.login_error_message));
                customerStatisticsBarChartDetailListActivity.userinfoApplication.exitForLogin(customerStatisticsBarChartDetailListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerStatisticsBarChartDetailListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerStatisticsBarChartDetailListActivity);
                customerStatisticsBarChartDetailListActivity.packageUpdateUtil = new PackageUpdateUtil(customerStatisticsBarChartDetailListActivity, customerStatisticsBarChartDetailListActivity.mHandler, fileCache, downloadFileUrl, false, customerStatisticsBarChartDetailListActivity.userinfoApplication);
                customerStatisticsBarChartDetailListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerStatisticsBarChartDetailListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerStatisticsBarChartDetailListActivity.getFileStreamPath(filename);
                file.getName();
                customerStatisticsBarChartDetailListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
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
                    getDataStatisticsJson.put("ExtractItemType", 4);
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
                                double consumeAmount = 0;
                                double rechargeAmount = 0;
                                try {
                                    if (csJson.has("ObjectCount") && !csJson.isNull("ObjectCount")) {
                                        objectCount = csJson.getInt("ObjectCount");
                                    }
                                    if (csJson.has("ObjectName") && !csJson.isNull("ObjectName")) {
                                        objectName = csJson.getString("ObjectName");
                                    }
                                    if (csJson.has("ConsumeAmout") && !csJson.isNull("ConsumeAmout")) {
                                        consumeAmount = csJson.getDouble("ConsumeAmout");
                                    }
                                    if (csJson.has("RechargeAmout") && !csJson.isNull("RechargeAmout")) {
                                        rechargeAmount = csJson.getDouble("RechargeAmout");
                                    }
                                } catch (JSONException e) {
                                }
                                cs.setObjectCount(objectCount);
                                cs.setObjectName(objectName);
                                cs.setConsumeAmount(consumeAmount);
                                cs.setRechargeAmount(rechargeAmount);
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
            destIntent.setClass(this, CustomerStatisticsBarChartActivity.class);
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
