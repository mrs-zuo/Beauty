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

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

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
import cn.com.antika.util.ImageLoaderUtil;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 *微信/支付宝支付的展示二维码
 * */
public class PaymentActionThirdPartModeActivity extends BaseActivity implements OnClickListener {
    private PaymentActionThirdPartModeActivityHandler mHandler = new PaymentActionThirdPartModeActivityHandler(this);
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private ThirdPartPay thirdPartPay;
    private ImageLoader imageLoader;
    private DisplayImageOptions displayImageOptions;
    private PackageUpdateUtil packageUpdateUtil;
    private boolean payFromOrderDetail;
    private int userRole, orderSize, paymentMode;
    private OrderInfo orderInfo;
    int payType;
    private EcardInfo ecardInfo = new EcardInfo(), customerEcardInfoPoint, customerEcardInfoCashCoupon;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_action_third_part_mode);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        Intent intent = getIntent();
        paymentMode = intent.getIntExtra("paymentMode", Constant.PAYMENT_MODE_WEIXIN);
        userinfoApplication = UserInfoApplication.getInstance();
        if (paymentMode == Constant.PAYMENT_MODE_WEIXIN) {
            ((TextView) findViewById(R.id.payment_action_third_part_name_text)).setText("微信");
            ((TextView) findViewById(R.id.payment_action_third_part_qr_code_tip)).setText("请使用微信扫一扫，扫描二维码支付");
        } else if (paymentMode == Constant.PAYMENT_MODE_ALI) {
            ((TextView) findViewById(R.id.payment_action_third_part_name_text)).setText("支付宝");
            ((TextView) findViewById(R.id.payment_action_third_part_qr_code_tip)).setText("请打开支付宝钱包，使用扫一扫完成支付");
        }
        ((TextView) findViewById(R.id.payment_action_weixin_mode_title_text)).setText(getResources().getString(R.string.payment_action_weixin_scan_code));
        findViewById(R.id.payment_action_weixin_scan_code_tablelayout).setVisibility(View.VISIBLE);
        imageLoader = ImageLoader.getInstance();
        displayImageOptions = ImageLoaderUtil.getDisplayImageOptions(R.drawable.head_image_null);
        payType = intent.getIntExtra("payType", 0);
        String orderID = "";
        String moneyAmount = "";
        int responsibleID = 0;
        if (payType == 1) {
            ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
            customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
            customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
            moneyAmount = intent.getStringExtra("moneyAmount");
            responsibleID = intent.getIntExtra("responsibleID", 0);
        } else {
            orderID = intent.getStringExtra("orderID");
        }
        int customerID = intent.getIntExtra("customerID", 0);
        String slaveID = intent.getStringExtra("slaveID");
        String totalAmout = intent.getStringExtra("totalAmount");
        String pointAmount = intent.getStringExtra("pointAmount");
        String couponAmount = intent.getStringExtra("couponAmount");
        String remark = intent.getStringExtra("remark");
        payFromOrderDetail = intent.getBooleanExtra("payFromOrderDetail", false);
        userRole = intent.getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
        orderSize = intent.getIntExtra("orderSize", 1);
        if (orderSize == 1) {
            orderInfo = (OrderInfo) intent.getSerializableExtra("orderInfo");
        }
        getQRcodePaymentDetail(payType, customerID, orderID, ecardInfo.getUserEcardNo(), moneyAmount, responsibleID, slaveID, totalAmout, pointAmount, couponAmount, remark);
        findViewById(R.id.payment_action_weixin_next_btn).setOnClickListener(this);
    }

    private void getQRcodePaymentDetail(final int payType, final int customerID, final String orderID, final String usercardNO, final String moneyAmount, final int responsibleID, final String slaveID, final String totalAmout, final String pointAmount, final String couponAmount, final String remark) {
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetNetTradeQRCode";
                if (paymentMode == Constant.PAYMENT_MODE_ALI)
                    methodName = "GetAliPayNetTradeQRCode";
                String endPoint = "Payment";
                JSONObject getNetTradeQRCodeJson = new JSONObject();
                try {
                    getNetTradeQRCodeJson.put("CustomerID", customerID);
                    if (payType == 1) {
                        getNetTradeQRCodeJson.put("UserCardNo", usercardNO);
                        getNetTradeQRCodeJson.put("ResponsiblePersonID", responsibleID);
                        getNetTradeQRCodeJson.put("MoneyAmount", moneyAmount);
                    } else {
                        getNetTradeQRCodeJson.put("OrderID", new JSONArray(orderID));
                    }
                    if (slaveID == null || "".equals(slaveID) || ("[0]").equals(slaveID))
                        getNetTradeQRCodeJson.put("Slavers", "");
                    else
                        getNetTradeQRCodeJson.put("Slavers", new JSONArray(slaveID));
                    getNetTradeQRCodeJson.put("TotalAmount", totalAmout);
                    getNetTradeQRCodeJson.put("PointAmount", pointAmount);
                    getNetTradeQRCodeJson.put("CouponAmount", couponAmount);
                    getNetTradeQRCodeJson.put("Remark", remark);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getNetTradeQRCodeJson.toString(), userinfoApplication);
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
                            JSONObject data = resultJson.getJSONObject("Data");
                            thirdPartPay = new ThirdPartPay();
                            if (data.has("QRCodeUrl"))
                                thirdPartPay.setPayQRCodeUrl(data.getString("QRCodeUrl"));
                            if (data.has("NetTradeNo"))
                                thirdPartPay.setNetTradeNo(data.getString("NetTradeNo"));
                            if (data.has("ProductName"))
                                thirdPartPay.setPayProductName(data.getString("ProductName"));
                            thirdPartPay.setPayAmount(Double.valueOf(totalAmout));
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

    private static class PaymentActionThirdPartModeActivityHandler extends Handler {
        private final PaymentActionThirdPartModeActivity paymentActionThirdPartModeActivity;

        private PaymentActionThirdPartModeActivityHandler(PaymentActionThirdPartModeActivity activity) {
            WeakReference<PaymentActionThirdPartModeActivity> weakReference = new WeakReference<PaymentActionThirdPartModeActivity>(activity);
            paymentActionThirdPartModeActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentActionThirdPartModeActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(paymentActionThirdPartModeActivity, "您的网络貌似不给力，请重试！");
            } else if (msg.what == 1) {
                ((TextView) paymentActionThirdPartModeActivity.findViewById(R.id.payment_action_net_trade_no_text)).setText(paymentActionThirdPartModeActivity.thirdPartPay.getNetTradeNo());
                ((TextView) paymentActionThirdPartModeActivity.findViewById(R.id.payment_action_product_name_text)).setText(paymentActionThirdPartModeActivity.thirdPartPay.getPayProductName());
                ((TextView) paymentActionThirdPartModeActivity.findViewById(R.id.payment_action_total_amount_text)).setText(paymentActionThirdPartModeActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(paymentActionThirdPartModeActivity.thirdPartPay.getPayAmount())));
                ImageView qrCodeImage = (ImageView) paymentActionThirdPartModeActivity.findViewById(R.id.payment_action_third_part_qr_code_image);
                paymentActionThirdPartModeActivity.imageLoader.displayImage(paymentActionThirdPartModeActivity.thirdPartPay.getPayQRCodeUrl(), qrCodeImage, paymentActionThirdPartModeActivity.displayImageOptions);
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(paymentActionThirdPartModeActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentActionThirdPartModeActivity, paymentActionThirdPartModeActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentActionThirdPartModeActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentActionThirdPartModeActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentActionThirdPartModeActivity);
                paymentActionThirdPartModeActivity.packageUpdateUtil = new PackageUpdateUtil(paymentActionThirdPartModeActivity, paymentActionThirdPartModeActivity.mHandler, fileCache, downloadFileUrl, false, paymentActionThirdPartModeActivity.userinfoApplication);
                paymentActionThirdPartModeActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentActionThirdPartModeActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = paymentActionThirdPartModeActivity.getFileStreamPath(filename);
                file.getName();
                paymentActionThirdPartModeActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (paymentActionThirdPartModeActivity.requestWebServiceThread != null) {
                paymentActionThirdPartModeActivity.requestWebServiceThread.interrupt();
                paymentActionThirdPartModeActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        //退出
        if ((Intent.FLAG_ACTIVITY_CLEAR_TOP & intent.getFlags()) != 0) {
            finish();
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.payment_action_weixin_next_btn:
                Intent resultIntent = new Intent();
                resultIntent.setClass(this, PaymentActionThirdPartResultActivity.class);
                resultIntent.putExtra("netTradeNO", thirdPartPay.getNetTradeNo());
                if (payType == 1) {
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("ecardInfo", ecardInfo);
                    bundle.putSerializable("customerEcardPoint", customerEcardInfoPoint);
                    bundle.putSerializable("customerEcardCashcoupon", customerEcardInfoCashCoupon);
                    resultIntent.putExtras(bundle);
                } else {
                    resultIntent.putExtra("payFromOrderDetail", payFromOrderDetail);
                    resultIntent.putExtra("userRole", userRole);
                    resultIntent.putExtra("orderSize", orderSize);
                    if (orderSize == 1) {
                        Bundle bundle = new Bundle();
                        bundle.putSerializable("orderInfo", orderInfo);
                        resultIntent.putExtras(bundle);
                    }
                }
                resultIntent.putExtra("payType", payType);
                resultIntent.putExtra("paymentMode", paymentMode);
                startActivity(resultIntent);
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
