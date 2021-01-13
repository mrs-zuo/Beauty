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
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.PaymentRecordDetail;
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
 * 支付记录详情
 * */
@SuppressLint("ResourceType")
public class PaymentRecordDetailActivity extends BaseActivity {
    private PaymentRecordDetailActivityHandler mHandler = new PaymentRecordDetailActivityHandler(this);
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private LinearLayout paymentRecordDetailOrderListLinearlayout;
    private LayoutInflater layoutInflater;
    private UserInfoApplication userinfoApplication;
    private int rechargeMode;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_record_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        initView();
    }

    private static class PaymentRecordDetailActivityHandler extends Handler {
        private final PaymentRecordDetailActivity paymentRecordDetailActivity;

        private PaymentRecordDetailActivityHandler(PaymentRecordDetailActivity activity) {
            WeakReference<PaymentRecordDetailActivity> weakReference = new WeakReference<PaymentRecordDetailActivity>(activity);
            paymentRecordDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentRecordDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (paymentRecordDetailActivity.progressDialog != null) {
                paymentRecordDetailActivity.progressDialog.dismiss();
                paymentRecordDetailActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                PaymentRecordDetail paymentRecordDetail = (PaymentRecordDetail) msg.obj;
                ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_code_text)).setText(paymentRecordDetail.getPaymentRecordDetailCode());
                ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_date_text)).setText(paymentRecordDetail.getPaymentRecordDetailDate());
                ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_operator_text))
                        .setText(paymentRecordDetail
                                .getPaymentRecordDetailOperator());
                String currency = paymentRecordDetailActivity.userinfoApplication.getAccountInfo()
                        .getCurrency();
                ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_amount_text))
                        .setText(currency
                                + NumberFormatUtil.currencyFormat(paymentRecordDetail
                                .getPaymentRecordDetailAmount()));
                if (paymentRecordDetailActivity.rechargeMode == 4) {
                    paymentRecordDetailActivity.findViewById(R.id.payment_detail_before_balance_divide_view).setVisibility(View.VISIBLE);
                    paymentRecordDetailActivity.findViewById(R.id.payment_detail_balance_relativelayout).setVisibility(View.VISIBLE);
                    ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_balance_text)).setText(currency + NumberFormatUtil.currencyFormat(paymentRecordDetailActivity.getIntent().getStringExtra("balance")));
                }
				/*String profitList=paymentRecordDetail.getProfitList();
				if(profitList==null || profitList.equals(""))
					((TextView)findViewById(R.id.payment_record_detail_benefit_person_text)).setText("无");
				else
				   ((TextView)findViewById(R.id.payment_record_detail_benefit_person_text)).setText(profitList);*/
                String paymentRecordDetailRemark = paymentRecordDetail.getPaymentRecordDetailRemark();
                if (paymentRecordDetailRemark == null || ("").equals(paymentRecordDetailRemark)) {
                    paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_remark_title_divide_view).setVisibility(View.GONE);
                    paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_remark_title_relativelayout).setVisibility(View.GONE);
                    paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_remark_divide_view).setVisibility(View.GONE);
                    ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_remark_text)).setVisibility(View.GONE);
                } else {
                    ((TextView) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_remark_text)).setText(paymentRecordDetailRemark);
                }
                paymentRecordDetailActivity.paymentRecordDetailOrderListLinearlayout = (LinearLayout) paymentRecordDetailActivity.findViewById(R.id.payment_record_detail_order_list_linearlayout);
                paymentRecordDetailActivity.layoutInflater = LayoutInflater.from(paymentRecordDetailActivity);
                TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
                lp.topMargin = 20;
                lp.leftMargin = 10;
                lp.rightMargin = 10;
                List<OrderInfo> orderList = paymentRecordDetail.getPaymentRecordOrderList();
                for (int i = 0; i < orderList.size(); i++) {
                    final OrderInfo oi = orderList.get(i);
                    View paymentRecordDetailOrderView = paymentRecordDetailActivity.layoutInflater.inflate(R.xml.payment_record_detail_order_item_layout, null);
                    paymentRecordDetailOrderView.setLayoutParams(lp);
                    RelativeLayout paymentDetailOrderJoin = (RelativeLayout) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_join);
                    paymentDetailOrderJoin.setOnClickListener(new OnClickListener() {

                        @Override
                        public void onClick(View v) {
                            // TODO Auto-generated method stub
                            Intent destIntent = new Intent(paymentRecordDetailActivity, OrderDetailActivity.class);
                            destIntent.putExtra("orderInfo", oi);
                            paymentRecordDetailActivity.startActivity(destIntent);
                        }
                    });
                    TextView paymentRecordDetailOrderNumber = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_serial_number);
                    paymentRecordDetailOrderNumber.setText(orderList.get(i).getOrderSerialNumber());
                    TextView paymentRecordDetailOrderProductName = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_product_name);
                    paymentRecordDetailOrderProductName.setText(orderList.get(i).getProductName());
                    TextView paymentRecordDetailOrderPrice = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_total_price);
                    paymentRecordDetailOrderPrice.setText(currency + NumberFormatUtil.currencyFormat(orderList.get(i).getTotalSalePrice()));
                    paymentRecordDetailActivity.paymentRecordDetailOrderListLinearlayout.addView(paymentRecordDetailOrderView);
                }
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(paymentRecordDetailActivity,
                        "提示信息", "您的网络貌似不给力，请检查网络设置！");
            } else if (msg.what == 2) {
                String message = (String) msg.obj;
                DialogUtil.createMakeSureDialog(paymentRecordDetailActivity,
                        "提示信息", message);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentRecordDetailActivity, paymentRecordDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentRecordDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentRecordDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentRecordDetailActivity);
                paymentRecordDetailActivity.packageUpdateUtil = new PackageUpdateUtil(paymentRecordDetailActivity, paymentRecordDetailActivity.mHandler, fileCache, downloadFileUrl, false, paymentRecordDetailActivity.userinfoApplication);
                paymentRecordDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentRecordDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = paymentRecordDetailActivity.getFileStreamPath(filename);
                file.getName();
                paymentRecordDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (paymentRecordDetailActivity.requestWebServiceThread != null) {
                paymentRecordDetailActivity.requestWebServiceThread.interrupt();
                paymentRecordDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    private void initView() {
        userinfoApplication = UserInfoApplication.getInstance();
        //4:e卡消费  显示e卡余额
        rechargeMode = getIntent().getIntExtra("rechargeMode", 0);
        if (rechargeMode == 4) {
            ((TextView) findViewById(R.id.payment_record_detail_title_text)).setText("e卡支付详情");
        }
        final int paymentID = getIntent().getIntExtra("paymentID", 0);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "getPaymentDetail";
                String endPoint = "payment";
                JSONObject paymentRecordDetailParamJson = new JSONObject();
                try {
                    paymentRecordDetailParamJson.put("PaymentID", paymentID);
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, paymentRecordDetailParamJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
                else {
                    String code = "0";
                    String message = "";
                    PaymentRecordDetail paymentRecordDetail = null;
                    try {
                        code = resultJson.getString("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = "0";
                    }
                    if (Integer.parseInt(code) == 1) {
                        JSONObject paymentDetailJson = null;
                        try {
                            paymentDetailJson = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                        }
                        if (paymentDetailJson != null) {
                            try {
                                paymentRecordDetail = new PaymentRecordDetail();
                                String paymentRecordDetailCode = "";
                                String paymentRecordDetailDate = "";
                                String paymentRecordDetailOperator = "";
                                String paymentRecordDetailAmount = "";
                                String paymentRecordDetailRemark = "";
                                if (paymentDetailJson.has("PaymentCode"))
                                    paymentRecordDetailCode = paymentDetailJson.getString("PaymentCode");
                                if (paymentDetailJson.has("PaymentTime"))
                                    paymentRecordDetailDate = paymentDetailJson.getString("PaymentTime");
                                if (paymentDetailJson.has("Operator"))
                                    paymentRecordDetailOperator = paymentDetailJson
                                            .getString("Operator");
                                if (paymentDetailJson.has("TotalPrice"))
                                    paymentRecordDetailAmount = String
                                            .valueOf(Double.valueOf(paymentDetailJson
                                                    .getString("TotalPrice")));
                                if (paymentDetailJson.has("Remark"))
                                    paymentRecordDetailRemark = paymentDetailJson
                                            .getString("Remark");
                                StringBuffer profitString = new StringBuffer();
                                if (paymentDetailJson.has("ProfitList") && !paymentDetailJson.isNull("ProfitList")) {
                                    JSONArray profitArray = paymentDetailJson.getJSONArray("ProfitList");
                                    for (int j = 0; j < profitArray.length(); j++) {
                                        if (j != profitArray.length() - 1)
                                            profitString.append(profitArray.getJSONObject(j).getString("AccountName") + ",");
                                        else
                                            profitString.append(profitArray.getJSONObject(j).getString("AccountName"));
                                    }
                                }
                                if (paymentDetailJson.has("OrderList")) {
                                    JSONArray paymentDetailOrderJson = paymentDetailJson
                                            .getJSONArray("OrderList");
                                    List<OrderInfo> orderInfoList = new ArrayList<OrderInfo>();
                                    for (int i = 0; i < paymentDetailOrderJson
                                            .length(); i++) {
                                        OrderInfo orderInfo = new OrderInfo();
                                        JSONObject orderJson = null;
                                        try {
                                            orderJson = (JSONObject) paymentDetailOrderJson
                                                    .get(i);
                                        } catch (JSONException e1) {

                                        }
                                        int orderID = 0;
                                        int productType = 0;
                                        String productName = "";
                                        String orderPrice = "";
                                        String orderNumber = "";
                                        try {
                                            if (orderJson.has("ID")) {
                                                orderID = orderJson.getInt("ID");
                                            }
                                            if (orderJson.has("ProductName")) {
                                                productName = orderJson.getString("ProductName");
                                            }
                                            if (orderJson.has("OrderPrice")) {
                                                orderPrice = String.valueOf(Double.valueOf(orderJson.getString("OrderPrice")));
                                            }
                                            if (orderJson.has("OrderNumber")) {
                                                orderNumber = orderJson.getString("OrderNumber");
                                            }
                                            if (orderJson.has("ProductType")) {
                                                productType = orderJson.getInt("ProductType");
                                            }
                                        } catch (JSONException e) {
                                        }
                                        orderInfo.setOrderID(orderID);
                                        orderInfo.setProductType(productType);
                                        orderInfo.setOrderSerialNumber(orderNumber);
                                        orderInfo.setTotalSalePrice(orderPrice);
                                        orderInfo.setProductName(productName);
                                        orderInfoList.add(orderInfo);
                                    }
                                    paymentRecordDetail.setPaymentRecordOrderList(orderInfoList);
                                }
                                paymentRecordDetail.setPaymentRecordDetailCode(paymentRecordDetailCode);
                                paymentRecordDetail.setPaymentRecordDetailDate(paymentRecordDetailDate);
                                paymentRecordDetail.setPaymentRecordDetailOperator(paymentRecordDetailOperator);
                                paymentRecordDetail.setPaymentRecordDetailAmount(paymentRecordDetailAmount);
                                paymentRecordDetail.setPaymentRecordDetailRemark(paymentRecordDetailRemark);
                                //paymentRecordDetail.setProfitList(profitString.toString());
                            } catch (NumberFormatException e) {
                            } catch (JSONException e) {
                            }
                        }
                        Message msg = new Message();
                        msg.what = 1;
                        msg.obj = paymentRecordDetail;
                        mHandler.sendMessage(msg);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
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
