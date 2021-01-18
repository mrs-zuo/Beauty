package cn.com.antika.business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

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
 *第三方支付结果
 * */
public class PaymentActionThirdPartResultActivity extends BaseActivity implements OnClickListener {
    private PaymentActionThirdPartResultActivityHandler mHandler = new PaymentActionThirdPartResultActivityHandler(this);
    private static final String RESULT_USERPAYING = "USERPAYING";
    private static final String RESULT_USERNOTPAY = "NOTPAY";
    private static final String RESULT_USERPAYCLOSED = "CLOSED";
    private static final String RESULT_USERPAYREVOKED = "REVOKED";
    private static final String RESULT_USERPAYERROR = "PAYERROR";
    private static final String RESULT_SUCCESS = "SUCCESS";
    private static final String RESULT_SUCCESS_ALI = "TRADE_SUCCESS";
    private static final String RESULT_USERPAYING_ALI = "WAIT_BUYER_PAY";
    private static final String RESULT_FAIL = "FAIL";
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private ThirdPartPay thirdPartPay;
    private String netTradeNO;
    private ProgressDialog progressDialog;
    private boolean payFromOrderDetail;
    private int userRole, orderSize, paymentMode;
    private OrderInfo orderInfo;
    private int payType;
    private EcardInfo ecardInfo, customerEcardInfoPoint, customerEcardInfoCashCoupon;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_action_third_part_result);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent intent = getIntent();
        netTradeNO = intent.getStringExtra("netTradeNO");
        payType = intent.getIntExtra("payType", 0);
        paymentMode = intent.getIntExtra("paymentMode", Constant.PAYMENT_MODE_WEIXIN);
        if (payType == 1) {
            ecardInfo = (EcardInfo) intent.getSerializableExtra("ecardInfo");
            customerEcardInfoPoint = (EcardInfo) intent.getSerializableExtra("customerEcardPoint");
            customerEcardInfoCashCoupon = (EcardInfo) intent.getSerializableExtra("customerEcardCashcoupon");
        } else {
            payFromOrderDetail = intent.getBooleanExtra("payFromOrderDetail", false);
            userRole = intent.getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
            orderSize = intent.getIntExtra("orderSize", 1);
            if (orderSize == 1) {
                orderInfo = (OrderInfo) intent.getSerializableExtra("orderInfo");
            }
        }

        getPaymentActionWeiXinResult();
    }

    private void getPaymentActionWeiXinResult() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetWeChatPayRes";
                if (paymentMode == Constant.PAYMENT_MODE_ALI)
                    methodName = "GetAliPayRes";
                String endPoint = "Payment";
                JSONObject payResJson = new JSONObject();
                try {
                    payResJson.put("NetTradeNo", netTradeNO);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, payResJson.toString(), userinfoApplication);
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
                            if (paymentMode == Constant.PAYMENT_MODE_WEIXIN) {
                                if (data.has("NetTradeNo"))
                                    thirdPartPay.setNetTradeNo(data.getString("NetTradeNo"));
                                if (data.has("ProductName"))
                                    thirdPartPay.setPayProductName(data.getString("ProductName"));
                                if (data.has("CashFee"))
                                    thirdPartPay.setPayAmount(data.getDouble("CashFee"));
                                if (data.has("CreateTime"))
                                    thirdPartPay.setPayTime(data.getString("CreateTime"));
                                if (data.has("TransactionID"))
                                    thirdPartPay.setPayTradeID(data.getString("TransactionID"));
                                if (data.has("ResultCode"))
                                    thirdPartPay.setResultCode(data.getString("ResultCode"));
                                if (data.has("BankName"))
                                    thirdPartPay.setPayBankName(data.getString("BankName"));
                                if (data.has("TradeState"))
                                    thirdPartPay.setTradeState(data.getString("TradeState"));
                            } else if (paymentMode == Constant.PAYMENT_MODE_ALI) {
                                if (data.has("NetTradeNo"))
                                    thirdPartPay.setNetTradeNo(data.getString("NetTradeNo"));
                                if (data.has("ProductName"))
                                    thirdPartPay.setPayProductName(data.getString("ProductName"));
                                if (data.has("TotalAmount"))
                                    thirdPartPay.setPayAmount(data.getDouble("TotalAmount"));
                                if (data.has("TradeState"))
                                    thirdPartPay.setTradeState(data.getString("TradeState"));
                                if (data.has("CreateTime"))
                                    thirdPartPay.setPayTime(data.getString("CreateTime"));
                                if (data.has("TradeNo"))
                                    thirdPartPay.setPayTradeID(data.getString("TradeNo"));
                            }

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

    private static class PaymentActionThirdPartResultActivityHandler extends Handler {
        private final PaymentActionThirdPartResultActivity paymentActionThirdPartResultActivity;

        private PaymentActionThirdPartResultActivityHandler(PaymentActionThirdPartResultActivity activity) {
            WeakReference<PaymentActionThirdPartResultActivity> weakReference = new WeakReference<PaymentActionThirdPartResultActivity>(activity);
            paymentActionThirdPartResultActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentActionThirdPartResultActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (paymentActionThirdPartResultActivity.progressDialog != null) {
                paymentActionThirdPartResultActivity.progressDialog.dismiss();
                paymentActionThirdPartResultActivity.progressDialog = null;
            }
            if (paymentActionThirdPartResultActivity.requestWebServiceThread != null) {
                paymentActionThirdPartResultActivity.requestWebServiceThread.interrupt();
                paymentActionThirdPartResultActivity.requestWebServiceThread = null;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(paymentActionThirdPartResultActivity, "您的网络貌似不给力，请重试！");
            } else if (msg.what == 1) {
                ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_net_trade_no_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getNetTradeNo());
                ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_product_name_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayProductName());
                ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_amount)).setText(paymentActionThirdPartResultActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(paymentActionThirdPartResultActivity.thirdPartPay.getPayAmount())));
                //微信支付
                if (paymentActionThirdPartResultActivity.paymentMode == Constant.PAYMENT_MODE_WEIXIN) {
                    //支付成功
                    if (RESULT_SUCCESS.equals(paymentActionThirdPartResultActivity.thirdPartPay.getResultCode()) && RESULT_SUCCESS.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.VISIBLE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                        ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_success));
                        paymentActionThirdPartResultActivity.showView();
                        ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_time_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayTime());
                        ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_bank_name_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayBankName());
                        ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_trade_id_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayTradeID());
                    }
                    //支付未成功状态
                    else if (RESULT_SUCCESS.equals(paymentActionThirdPartResultActivity.thirdPartPay.getResultCode()) && paymentActionThirdPartResultActivity.thirdPartPay.getTradeState() != null && !("").equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                        //支付关闭
                        if (RESULT_USERPAYCLOSED.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.VISIBLE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_closed));
                            paymentActionThirdPartResultActivity.hideView(2);
                        }
                        //已撤销
                        else if (RESULT_USERPAYREVOKED.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.VISIBLE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_revoked));
                            paymentActionThirdPartResultActivity.hideView(2);
                        }
                        //支付失败
                        else if (RESULT_USERPAYERROR.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.VISIBLE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_error));
                            paymentActionThirdPartResultActivity.hideView(2);
                        }
                    }
                    //支付结果未知
                    else if ("".equals(paymentActionThirdPartResultActivity.thirdPartPay.getResultCode()) || paymentActionThirdPartResultActivity.thirdPartPay.getResultCode() == null) {
                        //用户支付中
                        if (RESULT_USERPAYING.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.VISIBLE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_waiting));
                            paymentActionThirdPartResultActivity.hideView(1);
                        }
                        //未支付
                        else if (RESULT_USERNOTPAY.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.VISIBLE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_unpay));
                            paymentActionThirdPartResultActivity.hideView(1);
                        } else {
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                            paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.VISIBLE);
                            ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_unknown));
                            paymentActionThirdPartResultActivity.hideView(1);
                        }
                    }
                    //支付失败
                    else {
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.VISIBLE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                        ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_error));
                        paymentActionThirdPartResultActivity.hideView(2);
                    }
                } else if (paymentActionThirdPartResultActivity.paymentMode == Constant.PAYMENT_MODE_ALI) {
                    //支付成功
                    if (RESULT_SUCCESS_ALI.equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState())) {
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.VISIBLE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                        ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_success));
                        paymentActionThirdPartResultActivity.showView();
                        ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_time_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayTime());
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_bank_name_divide_view).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_bank_name_relativelayout).setVisibility(View.GONE);
                        ((TextView) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_trade_id_text)).setText(paymentActionThirdPartResultActivity.thirdPartPay.getPayTradeID());
                    }
                    //用户支付中
                    else if ("".equals(paymentActionThirdPartResultActivity.thirdPartPay.getTradeState()) || paymentActionThirdPartResultActivity.thirdPartPay.getTradeState() == null) {
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.VISIBLE);
                        ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_waiting));
                        paymentActionThirdPartResultActivity.hideView(1);
                    }
                    //支付失败
                    else {
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn).setVisibility(View.VISIBLE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_success_btn).setVisibility(View.GONE);
                        paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unknown_btn).setVisibility(View.GONE);
                        ((Button) paymentActionThirdPartResultActivity.findViewById(R.id.payment_action_result_unsuccess_btn)).setText(paymentActionThirdPartResultActivity.getString(R.string.payment_action_result_status_error));
                        paymentActionThirdPartResultActivity.hideView(2);
                    }
                }
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(paymentActionThirdPartResultActivity, (String) msg.obj);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentActionThirdPartResultActivity, paymentActionThirdPartResultActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentActionThirdPartResultActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentActionThirdPartResultActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentActionThirdPartResultActivity);
                paymentActionThirdPartResultActivity.packageUpdateUtil = new PackageUpdateUtil(paymentActionThirdPartResultActivity, paymentActionThirdPartResultActivity.mHandler, fileCache, downloadFileUrl, false, paymentActionThirdPartResultActivity.userinfoApplication);
                paymentActionThirdPartResultActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentActionThirdPartResultActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = paymentActionThirdPartResultActivity.getFileStreamPath(filename);
                file.getName();
                paymentActionThirdPartResultActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
        }
    }

    protected void hideView(int hideType) {
        //hideType  1:可以重新查询支付状态   2：明知支付结果，不可查询支付结果
        findViewById(R.id.payment_action_result_time_divide_view).setVisibility(View.GONE);
        findViewById(R.id.payment_action_result_time_relativelayout).setVisibility(View.GONE);
        findViewById(R.id.payment_action_bank_name_divide_view).setVisibility(View.GONE);
        findViewById(R.id.payment_action_bank_name_relativelayout).setVisibility(View.GONE);
        findViewById(R.id.payment_action_result_trade_id_divide_view).setVisibility(View.GONE);
        findViewById(R.id.payment_action_result_trade_id_relativelayout).setVisibility(View.GONE);
        findViewById(R.id.payment_action_result_trade_id_value_divide_view).setVisibility(View.GONE);
        findViewById(R.id.payment_action_result_trade_id_value_relativelayout).setVisibility(View.GONE);
        if (hideType == 1) {
            findViewById(R.id.payment_action_weixin_next_btn).setVisibility(View.GONE);
            findViewById(R.id.payment_action_weixin_refresh_btn).setVisibility(View.VISIBLE);
            findViewById(R.id.payment_action_weixin_back_btn).setVisibility(View.VISIBLE);
        } else if (hideType == 2) {
            findViewById(R.id.payment_action_weixin_next_btn).setVisibility(View.VISIBLE);
            findViewById(R.id.payment_action_weixin_next_btn).setOnClickListener(this);
            findViewById(R.id.payment_action_weixin_refresh_btn).setVisibility(View.GONE);
            findViewById(R.id.payment_action_weixin_back_btn).setVisibility(View.GONE);
        }
        findViewById(R.id.payment_action_weixin_refresh_btn).setOnClickListener(this);
        findViewById(R.id.payment_action_weixin_back_btn).setOnClickListener(this);
    }

    protected void showView() {
        findViewById(R.id.payment_action_result_time_divide_view).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_result_time_relativelayout).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_bank_name_divide_view).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_bank_name_relativelayout).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_result_trade_id_divide_view).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_result_trade_id_relativelayout).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_result_trade_id_value_divide_view).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_result_trade_id_value_relativelayout).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_weixin_next_btn).setVisibility(View.VISIBLE);
        findViewById(R.id.payment_action_weixin_refresh_btn).setVisibility(View.GONE);
        findViewById(R.id.payment_action_weixin_back_btn).setVisibility(View.GONE);
        findViewById(R.id.payment_action_weixin_next_btn).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            case R.id.payment_action_weixin_refresh_btn:
                getPaymentActionWeiXinResult();
                break;
            case R.id.payment_action_weixin_back_btn:
                this.finish();
                break;
            case R.id.payment_action_weixin_next_btn:
                Intent destIntent = null;
                if (payType == 1) {
                    destIntent = new Intent(this, CustomerEcardActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("customerEcard", ecardInfo);
                    bundle.putSerializable("customerEcardPoint", customerEcardInfoPoint);
                    bundle.putSerializable("customerEcardCashcoupon", customerEcardInfoCashCoupon);
                    destIntent.putExtras(bundle);
                } else {
                    if (payFromOrderDetail) {
                        if (orderInfo != null) {
                            destIntent = new Intent(this, OrderDetailActivity.class);
                            Bundle bundle = new Bundle();
                            bundle.putSerializable("orderInfo", orderInfo);
                            destIntent.putExtra("userRole", userRole);
                            destIntent.putExtras(bundle);
                        }
                    } else {
                        // 从左边的结账进入页面
                        if (userRole == Constant.USER_ROLE_BUSINESS) {
                            destIntent = new Intent(this, UnpaidCustomerListActivity.class);
                        } else {
                            // 如果支付是多个订单，则转到订单列表页
                            if (orderSize > 1) {
                                destIntent = new Intent(this, OrderListTabActivity.class);
                                destIntent.putExtra("currentItem", 1);
                            }
                            // 如果是一个订单 则转到订单详细页
                            else if (orderSize == 1) {
                                if (orderInfo != null) {
                                    Bundle bundle = new Bundle();
                                    bundle.putSerializable("orderInfo", orderInfo);
                                    destIntent = new Intent(this, OrderDetailActivity.class);
                                    destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                                    destIntent.putExtras(bundle);
                                }
                            }
                        }
                    }
                }
                if (destIntent != null) {
                    destIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(destIntent);
                }
                this.finish();
                break;
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
