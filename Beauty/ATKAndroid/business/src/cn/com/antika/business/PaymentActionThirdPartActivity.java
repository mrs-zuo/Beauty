package cn.com.antika.business;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.ThirdPartPay;
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
 *微信支付/支付宝支付  选择扫码支付还是刷卡支付
 * */
public class PaymentActionThirdPartActivity extends BaseActivity implements OnClickListener {
    private PaymentActionThirdPartActivityHandler mHandler = new PaymentActionThirdPartActivityHandler(this);
    private int customerID, payType, responsibleID;//payType 0:订单支付  1：储值卡充值
    private String orderID, slaveID, totalAmout, pointAmount, couponAmount, remark, moneyAmount;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private ThirdPartPay thirdPartPay;
    private PackageUpdateUtil packageUpdateUtil;
    private boolean payFromOrderDetail;
    private int userRole, orderSize, paymentMode;
    private OrderInfo orderInfo;
    private EcardInfo ecardInfo, customerEcardInfoPoint, customerEcardInfoCashCoupon;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_action_third_part);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        findViewById(R.id.payment_action_third_part_scan_code).setOnClickListener(this);
        findViewById(R.id.payment_action_third_part_swipe_card).setOnClickListener(this);
        findViewById(R.id.payment_action_third_part_back_btn).setOnClickListener(this);
        findViewById(R.id.payment_action_third_part_help_btn).setOnClickListener(this);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent intent = getIntent();
        payType = intent.getIntExtra("payType", 0);
        paymentMode = intent.getIntExtra("paymentMode", Constant.PAYMENT_MODE_WEIXIN);
        //payType交易类型  1：储值卡充值  2：订单支付
        if (payType == 1) {
            ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
            customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
            customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
            moneyAmount = intent.getStringExtra("moneyAmount");
            responsibleID = intent.getIntExtra("responsibleID", 0);
        } else {
            orderID = intent.getStringExtra("orderID");
        }
        customerID = intent.getIntExtra("customerID", 0);
        slaveID = intent.getStringExtra("slaveID");
        totalAmout = intent.getStringExtra("totalAmount");
        pointAmount = intent.getStringExtra("pointAmount");
        couponAmount = intent.getStringExtra("couponAmount");
        remark = intent.getStringExtra("remark");
        payFromOrderDetail = intent.getBooleanExtra("payFromOrderDetail", false);
        userRole = intent.getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
        orderSize = intent.getIntExtra("orderSize", 1);
        if (orderSize == 1) {
            orderInfo = (OrderInfo) intent.getSerializableExtra("orderInfo");
        }
        ((TextView) findViewById(R.id.payment_action_third_part_order_total_price_text)).setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(totalAmout));
        if (paymentMode == Constant.PAYMENT_MODE_WEIXIN) {
            ((TextView) findViewById(R.id.payment_action_third_part_title_text)).setText("微信第三方支付");
            ((ImageView) findViewById(R.id.payment_action_third_part_scan_code)).setBackgroundResource(R.drawable.payment_action_weixin_scan_code_icon);
            ((ImageView) findViewById(R.id.payment_action_third_part_swipe_card)).setBackgroundResource(R.drawable.payment_action_weixin_swipe_card_icon);
        } else if (paymentMode == Constant.PAYMENT_MODE_ALI) {
            ((TextView) findViewById(R.id.payment_action_third_part_title_text)).setText("支付宝第三方支付");
            ((ImageView) findViewById(R.id.payment_action_third_part_scan_code)).setBackgroundResource(R.drawable.payment_action_ali_scan_code_icon);
            ((ImageView) findViewById(R.id.payment_action_third_part_swipe_card)).setBackgroundResource(R.drawable.payment_action_ali_swipe_card_icon);
        }

    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String qrCode = intent.getStringExtra("code");
        if (qrCode != null && !"".equals(qrCode)) {
            String qrCodeHead = qrCode.substring(0, 2);
            if ((paymentMode == Constant.PAYMENT_MODE_WEIXIN && qrCode.length() == 18 && (qrCodeHead.equals("11") || qrCodeHead.equals("12") || qrCodeHead.equals("13") || qrCodeHead.equals("14") || qrCodeHead.equals("15")))
                    || (paymentMode == Constant.PAYMENT_MODE_ALI && qrCode.length() == 18 && qrCodeHead.equals("28")))
                getSwipeCardPaymentDetail(qrCode);
            else
                DialogUtil.createShortDialog(this, "条形码或者二维码格式错误!");
        } else if ((Intent.FLAG_ACTIVITY_CLEAR_TOP & intent.getFlags()) != 0) {
            finish();
        } else {
            payType = intent.getIntExtra("payType", 0);
            if (payType == 1) {
                ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
                customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
                customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
                moneyAmount = intent.getStringExtra("moneyAmount");
                responsibleID = intent.getIntExtra("responsibleID", 0);
            } else {
                orderID = intent.getStringExtra("orderID");
            }
            customerID = intent.getIntExtra("customerID", 0);
            slaveID = intent.getStringExtra("slaveID");
            totalAmout = intent.getStringExtra("totalAmount");
            pointAmount = intent.getStringExtra("pointAmount");
            couponAmount = intent.getStringExtra("couponAmount");
            remark = intent.getStringExtra("remark");
            payFromOrderDetail = intent.getBooleanExtra("payFromOrderDetail", false);
            userRole = intent.getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
            orderSize = intent.getIntExtra("orderSize", 1);
            if (orderSize == 1) {
                orderInfo = (OrderInfo) intent.getSerializableExtra("orderInfo");
            }
            ((TextView) findViewById(R.id.payment_action_third_part_order_total_price_text)).setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(totalAmout));
        }
    }

    //刷卡支付提交服务器
    private void getSwipeCardPaymentDetail(final String qrcode) {
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "WeChatPayByCustomer";
                if (paymentMode == Constant.PAYMENT_MODE_ALI)
                    methodName = "AliPayByAuthCode";
                String endPoint = "Payment";
                JSONObject weChatPayByCustomerJson = new JSONObject();
                try {
                    if (payType == 1) {
                        weChatPayByCustomerJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                        weChatPayByCustomerJson.put("ResponsiblePersonID", responsibleID);
                        weChatPayByCustomerJson.put("MoneyAmount", moneyAmount);
                    } else {
                        weChatPayByCustomerJson.put("OrderID", new JSONArray(orderID));
                    }
                    weChatPayByCustomerJson.put("CustomerID", customerID);
                    if (slaveID == null || "".equals(slaveID) || ("[0]").equals(slaveID))
                        weChatPayByCustomerJson.put("Slavers", "");
                    else
                        weChatPayByCustomerJson.put("Slavers", new JSONArray(slaveID));
                    weChatPayByCustomerJson.put("TotalAmount", totalAmout);
                    weChatPayByCustomerJson.put("PointAmount", pointAmount);
                    weChatPayByCustomerJson.put("CouponAmount", couponAmount);
                    weChatPayByCustomerJson.put("Remark", remark);
                    weChatPayByCustomerJson.put("UserCode", qrcode);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, weChatPayByCustomerJson.toString(), userinfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(0);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResult);
                    } catch (JSONException e) {
                    }
                    int code = 0;
                    String serverMessage = "";
                    try {
                        code = resultJson.getInt("Code");
                        serverMessage = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        try {
                            thirdPartPay = new ThirdPartPay();
                            JSONObject data = resultJson.getJSONObject("Data");
                            if (data.has("NetTradeNo"))
                                thirdPartPay.setNetTradeNo(data.getString("NetTradeNo"));
                        } catch (JSONException e) {
                        }
                        mHandler.sendEmptyMessage(1);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 2;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private static class PaymentActionThirdPartActivityHandler extends Handler {
        private final PaymentActionThirdPartActivity paymentActionThirdPartActivity;

        private PaymentActionThirdPartActivityHandler(PaymentActionThirdPartActivity activity) {
            WeakReference<PaymentActionThirdPartActivity> weakReference = new WeakReference<PaymentActionThirdPartActivity>(activity);
            paymentActionThirdPartActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentActionThirdPartActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (paymentActionThirdPartActivity.requestWebServiceThread != null) {
                paymentActionThirdPartActivity.requestWebServiceThread.interrupt();
                paymentActionThirdPartActivity.requestWebServiceThread = null;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(paymentActionThirdPartActivity, "您的网络貌似不给力，请重试！");
            } else if (msg.what == 1) {
                Intent resIntent = new Intent();
                resIntent.putExtra("netTradeNO", paymentActionThirdPartActivity.thirdPartPay.getNetTradeNo());
                if (paymentActionThirdPartActivity.payType == 1) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("ecardInfo", paymentActionThirdPartActivity.ecardInfo);
                    bundle.putSerializable("customerEcardPoint", paymentActionThirdPartActivity.customerEcardInfoPoint);
                    bundle.putSerializable("customerEcardCashcoupon", paymentActionThirdPartActivity.customerEcardInfoCashCoupon);
                    resIntent.putExtras(bundle);
                } else {
                    resIntent.putExtra("payFromOrderDetail", paymentActionThirdPartActivity.payFromOrderDetail);
                    resIntent.putExtra("userRole", paymentActionThirdPartActivity.userRole);
                    resIntent.putExtra("orderSize", paymentActionThirdPartActivity.orderSize);
                    if (paymentActionThirdPartActivity.orderSize == 1) {
                        Bundle bundle = new Bundle();
                        bundle.putSerializable("orderInfo", paymentActionThirdPartActivity.orderInfo);
                        resIntent.putExtras(bundle);
                    }
                }
                resIntent.putExtra("payType", paymentActionThirdPartActivity.payType);
                resIntent.putExtra("paymentMode", paymentActionThirdPartActivity.paymentMode);
                resIntent.setClass(paymentActionThirdPartActivity, PaymentActionThirdPartResultActivity.class);
                paymentActionThirdPartActivity.startActivity(resIntent);
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(paymentActionThirdPartActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentActionThirdPartActivity, paymentActionThirdPartActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentActionThirdPartActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentActionThirdPartActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentActionThirdPartActivity);
                paymentActionThirdPartActivity.packageUpdateUtil = new PackageUpdateUtil(paymentActionThirdPartActivity, paymentActionThirdPartActivity.mHandler, fileCache, downloadFileUrl, false, paymentActionThirdPartActivity.userinfoApplication);
                paymentActionThirdPartActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentActionThirdPartActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = paymentActionThirdPartActivity.getFileStreamPath(filename);
                file.getName();
                paymentActionThirdPartActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        switch (v.getId()) {
            //扫码支付
            case R.id.payment_action_third_part_scan_code:
                Intent scanCodeIntent = new Intent();
                scanCodeIntent.setClass(this, PaymentActionThirdPartModeActivity.class);
                scanCodeIntent.putExtra("Mode", 1);
                scanCodeIntent.putExtra("customerID", customerID);
                if (payType == 1) {
                    scanCodeIntent.putExtra("payType", payType);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("ecardInfo", ecardInfo);
                    bundle.putSerializable("customerEcardPoint", customerEcardInfoPoint);
                    bundle.putSerializable("customerEcardCashcoupon", customerEcardInfoCashCoupon);
                    scanCodeIntent.putExtras(bundle);
                    scanCodeIntent.putExtra("moneyAmount", moneyAmount);
                    scanCodeIntent.putExtra("responsibleID", responsibleID);
                } else {
                    scanCodeIntent.putExtra("orderID", orderID);
                }
                scanCodeIntent.putExtra("slaveID", slaveID);
                scanCodeIntent.putExtra("totalAmount", totalAmout);
                scanCodeIntent.putExtra("pointAmount", pointAmount);
                scanCodeIntent.putExtra("couponAmount", couponAmount);
                scanCodeIntent.putExtra("remark", remark);
                scanCodeIntent.putExtra("payFromOrderDetail", payFromOrderDetail);
                scanCodeIntent.putExtra("userRole", userRole);
                scanCodeIntent.putExtra("orderSize", orderSize);
                scanCodeIntent.putExtra("payType", payType);
                scanCodeIntent.putExtra("paymentMode", paymentMode);
                if (orderSize == 1) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("orderInfo", orderInfo);
                    scanCodeIntent.putExtras(bundle);
                }
                startActivity(scanCodeIntent);
                break;
            //刷卡支付
            case R.id.payment_action_third_part_swipe_card:
                Intent swipeCardIntent = new Intent();
                swipeCardIntent.setClass(this, DecodeQRCodeActivity.class);
                swipeCardIntent.putExtra("sourceType", 2);
                startActivity(swipeCardIntent);
                break;
            //微信/支付宝支付限额说明网页
            case R.id.payment_action_third_part_help_btn:
                Intent helpIntent = new Intent(this, ThirdPartPayHelpActivity.class);
                helpIntent.putExtra("paymentMode", paymentMode);
                startActivity(helpIntent);
                break;
            //返回按钮
            case R.id.payment_action_third_part_back_btn:
                this.finish();
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
