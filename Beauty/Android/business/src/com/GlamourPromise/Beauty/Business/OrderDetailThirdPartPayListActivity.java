package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.GlamourPromise.Beauty.adapter.ThirdPartPayItemAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.ThirdPartPay;
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
import java.util.ArrayList;
import java.util.List;

public class OrderDetailThirdPartPayListActivity extends BaseActivity implements OnItemClickListener {
    private OrderDetailThirdPartPayListActivityHandler mHandler = new OrderDetailThirdPartPayListActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private ListView thirdPartPayInfoListView;
    private List<ThirdPartPay> thirdPartPayInfoList;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private int orderID, customerID, thirdPartPayType;//0:订单第三方支付   1：顾客第三方充值   2：顾客的某一张储值卡第三方充值
    private String userCardNO;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_order_detail_third_part_pay_list);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class OrderDetailThirdPartPayListActivityHandler extends Handler {
        private final OrderDetailThirdPartPayListActivity orderDetailThirdPartPayListActivity;

        private OrderDetailThirdPartPayListActivityHandler(OrderDetailThirdPartPayListActivity activity) {
            WeakReference<OrderDetailThirdPartPayListActivity> weakReference = new WeakReference<OrderDetailThirdPartPayListActivity>(activity);
            orderDetailThirdPartPayListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (orderDetailThirdPartPayListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (orderDetailThirdPartPayListActivity.progressDialog != null) {
                orderDetailThirdPartPayListActivity.progressDialog.dismiss();
                orderDetailThirdPartPayListActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                ThirdPartPayItemAdapter thirdPartPayItemAdapter = new ThirdPartPayItemAdapter(orderDetailThirdPartPayListActivity, orderDetailThirdPartPayListActivity.thirdPartPayInfoList);
                orderDetailThirdPartPayListActivity.thirdPartPayInfoListView.setAdapter(thirdPartPayItemAdapter);
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(orderDetailThirdPartPayListActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(orderDetailThirdPartPayListActivity, orderDetailThirdPartPayListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(orderDetailThirdPartPayListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + orderDetailThirdPartPayListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(orderDetailThirdPartPayListActivity);
                orderDetailThirdPartPayListActivity.packageUpdateUtil = new PackageUpdateUtil(orderDetailThirdPartPayListActivity, orderDetailThirdPartPayListActivity.mHandler, fileCache, downloadFileUrl, false, orderDetailThirdPartPayListActivity.userinfoApplication);
                orderDetailThirdPartPayListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                orderDetailThirdPartPayListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = orderDetailThirdPartPayListActivity.getFileStreamPath(filename);
                file.getName();
                orderDetailThirdPartPayListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (orderDetailThirdPartPayListActivity.requestWebServiceThread != null) {
                orderDetailThirdPartPayListActivity.requestWebServiceThread.interrupt();
                orderDetailThirdPartPayListActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        thirdPartPayInfoListView = (ListView) findViewById(R.id.order_detail_third_part_pay_list_view);
        thirdPartPayInfoListView.setOnItemClickListener(this);
        Intent intent = getIntent();
        thirdPartPayType = intent.getIntExtra("thirdPartPayType", 0);
        if (thirdPartPayType == 0)
            orderID = intent.getIntExtra("orderID", 0);
        else if (thirdPartPayType == 1)
            customerID = intent.getIntExtra("customerID", 0);
        else if (thirdPartPayType == 2)
            userCardNO = intent.getStringExtra("userCardNo");
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebService();
    }

    private void requestWebService() {
        thirdPartPayInfoList = new ArrayList<ThirdPartPay>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetWeChatPayResaultByID";
                String endPoint = "Payment";
                JSONObject getWeChatPayResultJsonParam = new JSONObject();
                try {
                    if (thirdPartPayType == 0)
                        getWeChatPayResultJsonParam.put("OrderID", orderID);
                    else if (thirdPartPayType == 1)
                        getWeChatPayResultJsonParam.put("CustomerID", customerID);
                    else if (thirdPartPayType == 2)
                        getWeChatPayResultJsonParam.put("UserCardNo", userCardNO);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getWeChatPayResultJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    JSONArray weChatPayResultJsonArray = null;
                    int code = 0;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        try {
                            weChatPayResultJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        for (int i = 0; i < weChatPayResultJsonArray.length(); i++) {
                            JSONObject weChatPayResultJson = null;
                            try {
                                weChatPayResultJson = weChatPayResultJsonArray.getJSONObject(i);
                            } catch (JSONException e) {
                            }
                            ThirdPartPay thirdPartPay = new ThirdPartPay();
                            try {
                                if (weChatPayResultJson.has("NetTradeNo"))
                                    thirdPartPay.setNetTradeNo(weChatPayResultJson.getString("NetTradeNo"));
                                if (weChatPayResultJson.has("CashFee"))
                                    thirdPartPay.setPayAmount(weChatPayResultJson.getDouble("CashFee"));
                                if (weChatPayResultJson.has("CreateTime"))
                                    thirdPartPay.setPayTime(weChatPayResultJson.getString("CreateTime"));
                                if (weChatPayResultJson.has("ResultCode"))
                                    thirdPartPay.setResultCode(weChatPayResultJson.getString("ResultCode"));
                                if (weChatPayResultJson.has("TradeState"))
                                    thirdPartPay.setTradeState(weChatPayResultJson.getString("TradeState"));
                                if (weChatPayResultJson.has("ChangeTypeName"))
                                    thirdPartPay.setChangeTypeName(weChatPayResultJson.getString("ChangeTypeName"));
                                if (weChatPayResultJson.has("NetTradeVendor"))
                                    thirdPartPay.setNetTradeVendor(weChatPayResultJson.getInt("NetTradeVendor"));
                            } catch (JSONException e) {

                            }
                            thirdPartPayInfoList.add(thirdPartPay);
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

    //点击一行，查看第三方支付的详情
    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        Intent destIntent = new Intent();
        destIntent.setClass(this, PaymentActionThirdPartResultActivity.class);
        destIntent.putExtra("netTradeNO", thirdPartPayInfoList.get(position).getNetTradeNo());
        destIntent.putExtra("paymentMode", thirdPartPayInfoList.get(position).getNetTradeVendor());
        startActivity(destIntent);
    }

    @Override
    protected void onRestart() {
        // TODO Auto-generated method stub
        super.onRestart();
        requestWebService();
    }
}
