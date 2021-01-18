package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
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

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

public class CustomerViewOrderActivity extends BaseActivity implements
        OnClickListener {
    private CustomerViewOrderActivityHandler mHandler = new CustomerViewOrderActivityHandler(this);
    private RelativeLayout viewOrderRelativeLayout;
    private TextView viewOderCountText;
    private RelativeLayout unCompletedServiceRelativeLayout;
    private TextView unCompletedServiceText;
    private RelativeLayout undeliveredCommodityRelativeLayout;
    private TextView undeliveredCommodityText;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private int customerOrderTotal, unCompletedService, undeliveredCommodity;
    private RelativeLayout paymentRecordRelativelayout;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class CustomerViewOrderActivityHandler extends Handler {
        private final CustomerViewOrderActivity customerViewOrderActivity;

        private CustomerViewOrderActivityHandler(CustomerViewOrderActivity activity) {
            WeakReference<CustomerViewOrderActivity> weakReference = new WeakReference<CustomerViewOrderActivity>(activity);
            customerViewOrderActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerViewOrderActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerViewOrderActivity.progressDialog != null) {
                customerViewOrderActivity.progressDialog.dismiss();
                customerViewOrderActivity.progressDialog = null;
            }
            if (customerViewOrderActivity.requestWebServiceThread != null) {
                customerViewOrderActivity.requestWebServiceThread.interrupt();
                customerViewOrderActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                customerViewOrderActivity.viewOderCountText.setText("(" + String.valueOf(customerViewOrderActivity.customerOrderTotal) + ")");
                customerViewOrderActivity.unCompletedServiceText.setText("(" + String.valueOf(customerViewOrderActivity.unCompletedService) + ")");
                customerViewOrderActivity.undeliveredCommodityText.setText("(" + String.valueOf(customerViewOrderActivity.undeliveredCommodity) + ")");
            } else if (message.what == 2)
                DialogUtil.createShortDialog(customerViewOrderActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerViewOrderActivity, customerViewOrderActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(customerViewOrderActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerViewOrderActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerViewOrderActivity);
                customerViewOrderActivity.packageUpdateUtil = new PackageUpdateUtil(customerViewOrderActivity, customerViewOrderActivity.mHandler, fileCache, downloadFileUrl, false, customerViewOrderActivity.userinfoApplication);
                customerViewOrderActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerViewOrderActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = customerViewOrderActivity.getFileStreamPath(filename);
                file.getName();
                customerViewOrderActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_view_order);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        viewOrderRelativeLayout = (RelativeLayout) findViewById(R.id.view_order_relativelayout);
        viewOrderRelativeLayout.setOnClickListener(this);
        unCompletedServiceText = (TextView) findViewById(R.id.view_active_service_order_count);
        unCompletedServiceRelativeLayout = (RelativeLayout) findViewById(R.id.active_service_order_relativelayout);
        unCompletedServiceRelativeLayout.setOnClickListener(this);
        undeliveredCommodityText = (TextView) findViewById(R.id.to_be_reach_commodity_order_count);
        undeliveredCommodityRelativeLayout = (RelativeLayout) findViewById(R.id.to_be_reach_commodity_order_relativelayout);
        undeliveredCommodityRelativeLayout.setOnClickListener(this);
        viewOderCountText = (TextView) findViewById(R.id.view_customer_order_count);
        paymentRecordRelativelayout = (RelativeLayout) findViewById(R.id.payment_record_relativelayout);
        paymentRecordRelativelayout.setOnClickListener(this);
        initView();
    }

    protected void initView() {
        if (userinfoApplication.getSelectedCustomerID() == 0)
            DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
        else {
            ((TextView) findViewById(R.id.customer_view_order_title_text)).setText(userinfoApplication.getSelectedCustomerName() + "的订单");
            progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
            progressDialog.setMessage(getString(R.string.please_wait));
            progressDialog.show();
            requestWebServiceThread = new Thread() {
                @Override
                public void run() {
                    String methodName = "getOrderCount";
                    String endPoint = "order";
                    JSONObject orderCountParamJson = new JSONObject();
                    try {
                        orderCountParamJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                        orderCountParamJson.put("IsBusiness", Constant.USER_ROLE_BUSINESS);
                    } catch (JSONException e) {
                    }
                    String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, orderCountParamJson.toString(), userinfoApplication);
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
                            JSONObject orderCountJson = null;
                            try {
                                orderCountJson = resultJson.getJSONObject("Data");
                            } catch (JSONException e) {
                                // TODO Auto-generated catch block
                            }
                            if (orderCountJson != null) {
                                try {
                                    if (orderCountJson.has("Total"))
                                        customerOrderTotal = orderCountJson.getInt("Total");
                                    if (orderCountJson.has("UncompletedService"))
                                        unCompletedService = orderCountJson.getInt("UncompletedService");
                                    if (orderCountJson.has("UndeliveredCommodity"))
                                        undeliveredCommodity = orderCountJson.getInt("UndeliveredCommodity");
                                } catch (JSONException e) {
                                    customerOrderTotal = 0;
                                    unCompletedService = 0;
                                    undeliveredCommodity = 0;
                                }
                                mHandler.sendEmptyMessage(1);
                            }
                        } else
                            mHandler.sendEmptyMessage(code);
                    }
                }
            };
            requestWebServiceThread.start();
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = null;
        switch (view.getId()) {
            case R.id.view_order_relativelayout:
                destIntent = new Intent(this, OrderListActivity.class);
                destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                destIntent.putExtra("ORDER_STATUS", -1);
                startActivity(destIntent);
                break;
            case R.id.active_service_order_relativelayout:
                destIntent = new Intent(this, OrderListActivity.class);
                destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                destIntent.putExtra("ORDER_TYPE", 0);
                destIntent.putExtra("ORDER_STATUS", 1);
                startActivity(destIntent);
                break;
            case R.id.to_be_reach_commodity_order_relativelayout:
                destIntent = new Intent(this, OrderListActivity.class);
                destIntent.putExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
                destIntent.putExtra("ORDER_TYPE", 1);
                destIntent.putExtra("ORDER_STATUS", 1);
                startActivity(destIntent);
                break;
            case R.id.payment_record_relativelayout:
                destIntent = new Intent(this, PaymentRecordListActivity.class);
                startActivity(destIntent);
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
