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

import com.GlamourPromise.Beauty.adapter.PaymentRecordListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.PaymentRecord;
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
import java.util.ArrayList;
import java.util.List;

/*
 * 支付记录列表
 * */
public class PaymentRecordListActivity extends BaseActivity implements
        OnItemClickListener {
    private PaymentRecordListActivityHandler mHandler = new PaymentRecordListActivityHandler(this);
    private ListView paymentRecordListView;
    private List<PaymentRecord> paymentRecordList;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PaymentRecordListAdapter paymentRecordListAdapter;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_record_list);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class PaymentRecordListActivityHandler extends Handler {
        private final PaymentRecordListActivity paymentRecordListActivity;

        private PaymentRecordListActivityHandler(PaymentRecordListActivity activity) {
            WeakReference<PaymentRecordListActivity> weakReference = new WeakReference<PaymentRecordListActivity>(activity);
            paymentRecordListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentRecordListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (paymentRecordListActivity.progressDialog != null) {
                paymentRecordListActivity.progressDialog.dismiss();
                paymentRecordListActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                paymentRecordListActivity.paymentRecordListAdapter = new PaymentRecordListAdapter(paymentRecordListActivity, paymentRecordListActivity.paymentRecordList);
                paymentRecordListActivity.paymentRecordListView.setAdapter(paymentRecordListActivity.paymentRecordListAdapter);
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(paymentRecordListActivity,
                        "提示信息", "您的网络貌似不给力，请检查网络设置！");
            } else if (msg.what == 2) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(paymentRecordListActivity,
                        "提示信息", message);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentRecordListActivity, paymentRecordListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentRecordListActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentRecordListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentRecordListActivity);
                paymentRecordListActivity.packageUpdateUtil = new PackageUpdateUtil(paymentRecordListActivity, paymentRecordListActivity.mHandler, fileCache, downloadFileUrl, false, paymentRecordListActivity.userinfoApplication);
                paymentRecordListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentRecordListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = paymentRecordListActivity.getFileStreamPath(filename);
                file.getName();
                paymentRecordListActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (paymentRecordListActivity.requestWebServiceThread != null) {
                paymentRecordListActivity.requestWebServiceThread.interrupt();
                paymentRecordListActivity.requestWebServiceThread = null;
            }
        }
    }

    private void initView() {
        paymentRecordListView = (ListView) findViewById(R.id.payment_record_list);
        paymentRecordListView.setOnItemClickListener(this);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "getPaymentList";
                String endPoint = "payment";
                JSONObject paymentListParamJson = new JSONObject();
                try {
                    paymentListParamJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, paymentListParamJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
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
                        JSONArray paymentArray = null;
                        try {
                            paymentArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (paymentArray != null) {
                            paymentRecordList = new ArrayList<PaymentRecord>();
                            for (int i = 0; i < paymentArray.length(); i++) {
                                PaymentRecord paymentRecord = new PaymentRecord();
                                JSONObject paymentJson = null;
                                try {
                                    paymentJson = (JSONObject) paymentArray.get(i);
                                } catch (JSONException e1) {

                                }
                                int paymentID = 0;
                                String paymentRecordTitle = "";
                                String paymentRecordTime = "";
                                boolean paymentRecordIsRemark = false;
                                String paymentRecordModel = "";
                                double paymentAmount = 0;
                                try {
                                    if (paymentJson.has("ID")) {
                                        paymentID = paymentJson.getInt("ID");
                                    }
                                    if (paymentJson.has("Describe")) {
                                        paymentRecordTitle = paymentJson
                                                .getString("Describe");
                                    }
                                    if (paymentJson.has("PaymentTime")) {
                                        paymentRecordTime = paymentJson.getString("PaymentTime");
                                    }
                                    if (paymentJson.has("IsRemark")) {
                                        paymentRecordIsRemark = paymentJson.getBoolean("IsRemark");
                                    }
                                    if (paymentJson.has("PaymentModes")) {
                                        paymentRecordModel = paymentJson.getString("PaymentModes");
                                    }
                                    if (paymentJson.has("TotalPrice")) {
                                        paymentAmount = Double.valueOf(paymentJson.getString("TotalPrice"));
                                    }
                                } catch (JSONException e) {

                                }
                                paymentRecord.setPaymentID(paymentID);
                                paymentRecord.setPaymentRecordTitle(paymentRecordTitle);
                                paymentRecord.setPaymentRecordTime(paymentRecordTime);
                                paymentRecord.setPaymentRecordHasRemark(paymentRecordIsRemark);
                                paymentRecord.setPaymentRecordModel(paymentRecordModel);
                                paymentRecord.setPaymentRecordAmount(String.valueOf(paymentAmount));
                                paymentRecordList.add(paymentRecord);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 2;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }

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

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position,
                            long id) {
        // TODO Auto-generated method stub
        Intent destIntent = new Intent(this, OrderPaymentDetailActivity.class);
        destIntent.putExtra("paymentID", paymentRecordList.get(position).getPaymentID());
        startActivity(destIntent);
    }
}
