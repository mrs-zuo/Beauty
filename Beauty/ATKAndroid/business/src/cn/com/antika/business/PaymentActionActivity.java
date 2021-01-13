package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.EcardInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.SalesConsultantRate;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.timer.DialogTimerTask;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.LowerCase2Uppercase;
import cn.com.antika.util.NumberFormatUtil;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

/*
 * 结账
 * */
@SuppressLint({"ClickableViewAccessibility", "ResourceType"})
public class PaymentActionActivity extends BaseActivity implements OnClickListener {
    private PaymentActionActivityHandler mHandler = new PaymentActionActivityHandler(this);
    private TextView paidOrderCountText;
    private TextView paidOrderTotalPriceText;
    private EditText shouldPayAmountEdit;
    // 现金
    private EditText thisTimePayAmountCash;
    // 银行卡
    private EditText thisTimePayAmountBank;
    // 微信支付
    private EditText thisTimePayWeiXin;
    // 支付宝支付
    private EditText thisTimePayAli;
    // 消费贷款
    private EditText thisTimePayLoan;
    // 第三方付款
    private EditText thisTimePayFromThird;

    private TextView paymentActionOrderCardSpinnerText;
    private TextView thisTimePayAmount;
    private TextView thisTimePayAmountUppercase;
    private Double orderShouldPayAmountTotal;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private Button thisTimePayAmountCashAll;
    private Button thisTimePayAmountCardAll;
    private Button thisTimePayAmountWeiXinAll;
    private Button thisTimePayAmountAliAll;
    private Button thisTimePayAmountLoanAll;
    private Button thisTimePayAmountFromThirdAll;
    private TextView thisTimepayment_benefit_share_btn;

    private boolean payFromOrderDetail;
    private OrderInfo payOrderInfo;
    RelativeLayout paymentActionOrderPresent, thisTimeGivePointRelativelayout, thisTimeGiveCashCouponRelativelayout, thisTimepayment_benefit_share_percent_layout;
    // e卡支付
    private boolean isAllowedEcardPay, isAllowedPartPay;// 是否允许e卡支付  是否允许部分付
    // 其他支付方式
    private EditText thisTimePaymentOtherAmountText;
    private Button thisPaymentOtherAll;
    private Timer dialogTimer;
    private Double orderTotalCalcPrice;
    private Double paidOrderTotalPrice;
    private int userRole, customerID;
    private String mBenefitPersonIDs;
    private String mBenefitPersonNames;
    private TextView mTvBenefitPerson;
    private PackageUpdateUtil packageUpdateUtil;
    private int cardID, cardChildIndex;
    private String productCode, cardName;
    private Button paymentActionOrderDown, paymentActionOrderReturn, paymentActionOrderUp, paymentActionOrderPayOrder;
    private LinearLayout paymentActionOrderChildLinearLayout, paymentActionOrderChildItemLinearLayout, ordersalespercentagelinearlayout, benefitpersonlinearlayout;
    private RelativeLayout thisTimePayAmountRelativeLayout, ordersalespercentagelayout, benefitsharepricelayout, benefitpersonlayout;
    private LayoutInflater layoutInflater;
    /**
     * 储值卡积分现金券
     */
    private ArrayList<EcardInfo> ecardInfoList;
    /**
     * 商品/服务
     */
    private ArrayList<OrderInfo> orderList;
    /**
     * 会员卡
     */
    private List<EcardInfo> cardDiscountList;
    /**
     * 会员卡size
     */
    private int cardDiscountListSize;
    /**
     * 商品/服务数量
     */
    private int orderListSize;
    /**
     * 储值卡size
     */
    private int ecardInfoListSize;
    private double useCardpaidOrderTotalPrice = 0;
    private double useECardpaidOrderTotalPrice = 0;
    private double useWeiXinPaidOrderTotalPrice = 0;
    private double useAliPaidOrderTotalPrice = 0;
    private double useLoanPaidOrderTotalPrice = 0;
    private double useFromThirdPaidOrderTotalPrice = 0;
    private Map<String, Boolean> selectButton = new HashMap<String, Boolean>();
    private ImageButton paymentActionOrderCashSelect;
    private ImageButton paymentActionOrderBankSelect;
    private ImageButton paymentActionOrderOtherSelect;
    private ImageButton paymentActionOrderIntegralSelect;
    private ImageButton paymentActionOrderCashCouponSelect;
    //选择微信支付方式
    private ImageButton paymentActionOrderWeiXinSelect;
    //选择支付宝支付方式
    private ImageButton paymentActionOrderAliPaySelect;
    private ImageButton paymentActionOrderLoanPaySelect;
    private ImageButton paymentActionOrderFromThirdPaySelect;

    private Button paymentActionOrderCardSurplusButton, paymentActionOrderPointAndCouponSurplusButton;
    private TextView paymentActionOrderIntegralText24;
    // 现金券
    private TextView paymentActionOrderCashCouponText24;
    private TextView paymentActionShouldPayAmountCurrencyText, paymentActionOrderCardSpinnerCurrencyText;
    private EditText paymentActionOrderIntegralEdit22, paymentActionOrderCashCouponEdit22;
    private View paymentActionOrderChildView, paymentdetailbenefitpersonlistitem, benefitpersonlistitem;
    private String integralPresentRate = "0";
    private String cashCouponPresentRate = "0";
    private String integralRate = "0";
    private String cashCouponRate = "0";
    private double useIntegralpaidOrderTotalPrice = 0;
    private double useCashCouponpaidOrderTotalPrice = 0;
    // 赠送积分
    private EditText thisTimeGivePoint;
    // 赠送现金券
    private EditText thisTimeGiveCashCoupon;
    private String updateTotalSalePriceUserCardNo;
    private int UpdateTotalSalePriceUserCardId;
    /**
     * 储值卡
     */
    private ArrayList<EcardInfo> cardList;
    private int cardListSize = 0;
    private double totalPrice = 0;
    private Spinner addCardSpinner;
    private int[] ecardIdArray;
    private String[] ecardNameArray;
    private View thisTimeGiveView, thisTimePointView, paymentActionOrderCardSpinnerView, thisTimePayAmountView;
    private RelativeLayout paymentActionOrderCardRelativelayout;
    private double promotionPrice;
    private int marketingPolicy;
    private int quantity;
    private int shareFlg = 0, namegetFlg = 0, cnt_i;
    private EditText benefitPersonPercentText;
    //业绩参与人列表  可以修改其业绩参与的比例
    private View benefitsharepriceview, ordersalespercentageview, benefitpersonview;
    private TextView benefitshareprice;
    private TableLayout paymentActionOrderTablelayout;
    private boolean isComissionCalc = true;
    private double benefitshareamount;
    //销售顾问业绩比例
    private String salesConsultantID;
    private String salesConsultantName;
    private String commissionRate = "0";
    private List<SalesConsultantRate> salesConsultantRateList;
    private double personpercen = 0;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_payment_action);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        thisTimepayment_benefit_share_btn = (TextView) findViewById(R.id.payment_benefit_share_btn);
        isComissionCalc = userinfoApplication.getAccountInfo().isComissionCalc();

        payOrderInfo = (OrderInfo) getIntent().getSerializableExtra("orderInfo");
        userRole = getIntent().getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
        customerID = getIntent().getIntExtra("CUSTOMER_ID", 0);
        orderList = (ArrayList<OrderInfo>) getIntent().getSerializableExtra("paidOrderList");
        ecardInfoList = new ArrayList<EcardInfo>();
        cardList = new ArrayList<EcardInfo>();
        cardDiscountList = new ArrayList<EcardInfo>();
        initComponent();
        // 去服务器获得支付信息 本次应该支付金额 是否允许e卡支付 是否允许分次支付
        getPaymentInfoByWebService();
    }

    private static class PaymentActionActivityHandler extends Handler {
        private final PaymentActionActivity paymentActionActivity;

        private PaymentActionActivityHandler(PaymentActionActivity activity) {
            WeakReference<PaymentActionActivity> weakReference = new WeakReference<PaymentActionActivity>(activity);
            paymentActionActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (paymentActionActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (paymentActionActivity.progressDialog != null) {
                paymentActionActivity.progressDialog.dismiss();
                paymentActionActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                AlertDialog alertDialog = DialogUtil.createShortShowDialog(paymentActionActivity, "提示信息", "支付成功！");
                alertDialog.show();
                Intent destIntent = null;
                if (paymentActionActivity.payFromOrderDetail) {
                    destIntent = new Intent(paymentActionActivity, OrderDetailActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("orderInfo", paymentActionActivity.payOrderInfo);
                    destIntent.putExtra("userRole", paymentActionActivity.userRole);
                    destIntent.putExtras(bundle);
                } else {
                    // 从左边的结账进入页面
                    if (paymentActionActivity.userRole == Constant.USER_ROLE_BUSINESS) {
                        destIntent = new Intent(paymentActionActivity, UnpaidCustomerListActivity.class);
                    } else {
                        // 商机转需求的快捷支付 跳转到左侧的订单列表
                        if (paymentActionActivity.getIntent().getStringExtra("BALANCE_STYLE_PAY_FOR") != null && paymentActionActivity.getIntent().getStringExtra("BALANCE_STYLE_PAY_FOR").equals("OPPORTUNITY")) {
                            // 如果支付是多个订单，则转到订单列表页
                            if (paymentActionActivity.orderList.size() > 1) {
                                destIntent = new Intent(paymentActionActivity, OrderListTabActivity.class);
                                destIntent.putExtra("currentItem", 1);
                            }
                            // 如果是一个订单 则转到订单详细页
                            else if (paymentActionActivity.orderList.size() == 1) {
                                Bundle bundle = new Bundle();
                                OrderInfo orderInfo = new OrderInfo();
                                orderInfo.setOrderID(paymentActionActivity.orderList.get(0).getOrderID());
                                orderInfo.setOrderObejctID(paymentActionActivity.orderList.get(0).getOrderObejctID());
                                orderInfo.setProductType(paymentActionActivity.orderList.get(0).getProductType());
                                bundle.putSerializable("orderInfo", orderInfo);
                                destIntent = new Intent(paymentActionActivity, OrderDetailActivity.class);
                                destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                                destIntent.putExtras(bundle);
                            }
                        }
                        // 普通下单的快捷支付 跳转到某个顾客下面的全部订单列表
                        else {
                            // 如果是多个订单，则转到列表页
                            if (paymentActionActivity.orderList.size() > 1) {
                                destIntent = new Intent(paymentActionActivity, OrderListTabActivity.class);
                                destIntent.putExtra("currentItem", 1);
                            }
                            // 如果是单个订单，则跳转到订单详细页
                            else if (paymentActionActivity.orderList.size() == 1) {
                                Bundle bundle = new Bundle();
                                OrderInfo orderInfo = new OrderInfo();
                                orderInfo.setOrderID(paymentActionActivity.orderList.get(0).getOrderID());
                                orderInfo.setOrderObejctID(paymentActionActivity.orderList.get(0).getOrderObejctID());
                                orderInfo.setProductType(paymentActionActivity.orderList.get(0).getProductType());
                                bundle.putSerializable("orderInfo", orderInfo);
                                destIntent = new Intent(paymentActionActivity, OrderDetailActivity.class);
                                destIntent.putExtra("userRole", Constant.USER_ROLE_CUSTOMER);
                                destIntent.putExtras(bundle);
                            }
                        }
                    }
                }
                paymentActionActivity.dialogTimer = new Timer();
                DialogTimerTask dialogTimerTask = new DialogTimerTask(alertDialog, paymentActionActivity.dialogTimer, paymentActionActivity, destIntent);
                paymentActionActivity.dialogTimer.schedule(dialogTimerTask, Constant.DIALOG_AUTO_DISMISS_TIME);
            } else if (msg.what == 2) {
                // 获得顾客e卡余额也成功之后 初始化支付界面
                paymentActionActivity.getEcardBalanceByWebService();

            } else if (msg.what == 11) {
                String paymentMessage = (String) msg.obj;
                if (msg.arg1 == 1) {
                    if (paymentActionActivity.addCardSpinner.getCount() > 0) {
                        for (int i = 0; i < paymentActionActivity.addCardSpinner.getCount(); i++) {
                            if (paymentActionActivity.cardID == paymentActionActivity.ecardIdArray[i]) {
                                paymentActionActivity.addCardSpinner.setSelection(i, true);
                                break;
                            }
                        }
                    }
                    paymentActionActivity.shouldPayAmountEdit.setText(paymentActionActivity.paymentActionOrderCardSpinnerText.getText().toString());
                }
                DialogUtil.createMakeSureDialog(paymentActionActivity, "提示信息", paymentMessage);
            } else if (msg.what == 0) {
                String paymentMessage = (String) msg.obj;
                DialogUtil.createMakeSureDialog(paymentActionActivity, "提示信息", paymentMessage);
            } else if (msg.what == 3) {
                DialogUtil.createShortDialog(paymentActionActivity, "网络异常，请重试！");
            } else if (msg.what == 4) {
                // 支付信息获取成功之后 去获得顾客的e卡余额信息
                if (paymentActionActivity.orderList.size() > 1) {
                    paymentActionActivity.getEcardBalanceByWebService();
                } else
                    paymentActionActivity.getCardDiscountList();
            } else if (msg.what == 6) {
                paymentActionActivity.initView();
                paymentActionActivity.initData();
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(paymentActionActivity, paymentActionActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(paymentActionActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + paymentActionActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(paymentActionActivity);
                paymentActionActivity.packageUpdateUtil = new PackageUpdateUtil(paymentActionActivity, paymentActionActivity.mHandler, fileCache, downloadFileUrl, false, paymentActionActivity.userinfoApplication);
                paymentActionActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                paymentActionActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = paymentActionActivity.getFileStreamPath(filename);
                file.getName();
                paymentActionActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            //手机端看到的订单应付金额和服务器的支付金额不一致
            else if (msg.what == 8) {
                DialogUtil.createShortDialog(paymentActionActivity, (String) msg.obj);
            }
            //手机端看到的订单有一个已经被完全支付掉
            else if (msg.what == 9) {
                DialogUtil.createShortDialog(paymentActionActivity, (String) msg.obj);
                Intent destIntent = null;
                if (paymentActionActivity.payFromOrderDetail) {
                    destIntent = new Intent(paymentActionActivity, OrderDetailActivity.class);
                    Bundle bundle = new Bundle();
                    bundle.putSerializable("orderInfo", paymentActionActivity.payOrderInfo);
                    destIntent.putExtra("userRole", paymentActionActivity.userRole);
                    destIntent.putExtras(bundle);
                } else {
                    // 从左边的结账进入页面
                    if (paymentActionActivity.userRole == Constant.USER_ROLE_BUSINESS) {
                        destIntent = new Intent(paymentActionActivity, UnpaidCustomerListActivity.class);
                    } else {
                        // 如果支付是多个订单，则转到订单列表页
                        if (paymentActionActivity.orderList.size() > 1) {
                            destIntent = new Intent(paymentActionActivity, OrderListTabActivity.class);
                            destIntent.putExtra("currentItem", 1);
                        }
                        // 如果是一个订单 则转到订单详细页
                        else if (paymentActionActivity.orderList.size() == 1) {
                            Bundle bundle = new Bundle();
                            OrderInfo orderInfo = new OrderInfo();
                            orderInfo.setOrderID(paymentActionActivity.orderList.get(0).getOrderID());
                            orderInfo.setProductType(paymentActionActivity.orderList.get(0).getProductType());
                            orderInfo.setOrderObejctID(paymentActionActivity.orderList.get(0).getOrderObejctID());
                            bundle.putSerializable("orderInfo", orderInfo);
                            destIntent = new Intent(paymentActionActivity, OrderDetailActivity.class);
                            destIntent.putExtra("userRole", Constant.USER_ROLE_BUSINESS);
                            destIntent.putExtras(bundle);
                        }
                    }
                }
                paymentActionActivity.startActivity(destIntent);
                paymentActionActivity.finish();
            } else if (msg.what == 10) {
                if (Double.valueOf(paymentActionActivity.shouldPayAmountEdit.getText().toString()) == 0) {
                    Intent destIntent = null;
                    if (paymentActionActivity.userRole == Constant.USER_ROLE_BUSINESS) {
                        destIntent = new Intent(paymentActionActivity, UnpaidCustomerListActivity.class);
                        paymentActionActivity.startActivity(destIntent);
                    } else {
                        paymentActionActivity.finish();
                    }
                } else {
                    paymentActionActivity.shouldPayAmountEdit.setText(paymentActionActivity.shouldPayAmountEdit.getText().toString());
                    paymentActionActivity.thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(0));
                }
            }
            if (paymentActionActivity.requestWebServiceThread != null) {
                paymentActionActivity.requestWebServiceThread.interrupt();
                paymentActionActivity.requestWebServiceThread = null;
            }
        }
    }

    private void initComponent() {
        //主
        layoutInflater = LayoutInflater.from(this);
        paidOrderCountText = (TextView) findViewById(R.id.payment_action_order_count);
        paidOrderTotalPriceText = (TextView) findViewById(R.id.payment_action_order_total_price);
        shouldPayAmountEdit = (EditText) findViewById(R.id.payment_action_should_pay_amount_edit);
        paymentActionOrderCardSpinnerText = (TextView) findViewById(R.id.payment_action_order_card_spinner_text);
        thisTimePayAmountUppercase = (TextView) findViewById(R.id.this_time_pay_amount_uppercase_text);
        paymentActionOrderReturn = (Button) findViewById(R.id.payment_action_order_return);
        paymentActionOrderDown = (Button) findViewById(R.id.payment_action_order_down);
        paymentActionOrderUp = (Button) findViewById(R.id.payment_action_order_up);
        paymentActionOrderPayOrder = (Button) findViewById(R.id.payment_action_order_pay_order);
        paymentActionOrderPayOrder.setOnClickListener(this);
        paymentActionOrderChildLinearLayout = (LinearLayout) findViewById(R.id.payment_action_order_child_linearlayout);
        ordersalespercentagelinearlayout = (LinearLayout) findViewById(R.id.order_sales_percentage_linearlayout);
        benefitpersonlinearlayout = (LinearLayout) findViewById(R.id.benefit_person_linearlayout);

        addCardSpinner = (Spinner) findViewById(R.id.payment_action_order_card_spinner);
        thisTimePayAmountRelativeLayout = (RelativeLayout) findViewById(R.id.this_time_pay_amount_relativeLayout);
        thisTimePayAmount = (TextView) findViewById(R.id.this_time_pay_amount);
        paymentActionOrderTablelayout = (TableLayout) findViewById(R.id.payment_action_order_tablelayout);
        paymentActionOrderCardRelativelayout = (RelativeLayout) findViewById(R.id.payment_action_order_card_relativelayout);
        paymentActionOrderCardSpinnerCurrencyText = (TextView) findViewById(R.id.payment_action_order_card_spinner_currency_text);
        paymentActionShouldPayAmountCurrencyText = (TextView) findViewById(R.id.payment_action_should_pay_amount_currency_text);
        paymentActionOrderCardSpinnerCurrencyText.setText(userinfoApplication.getAccountInfo().getCurrency());
        paymentActionShouldPayAmountCurrencyText.setText(userinfoApplication.getAccountInfo().getCurrency());
        thisTimePayAmountView = findViewById(R.id.this_time_pay_amount_view);
        paymentActionOrderCardSpinnerView = findViewById(R.id.payment_action_order_card_spinner_view);
        benefitshareprice = (TextView) findViewById(R.id.benefit_share_price);
        ordersalespercentagelayout = (RelativeLayout) findViewById(R.id.order_sales_percentage_layout);
        benefitsharepricelayout = (RelativeLayout) findViewById(R.id.benefit_share_price_layout);
        benefitpersonlayout = (RelativeLayout) findViewById(R.id.benefit_person_layout);
        benefitsharepriceview = findViewById(R.id.benefit_share_price_view);
        ordersalespercentageview = findViewById(R.id.order_sales_percentage_view);
        benefitpersonview = findViewById(R.id.benefit_person_view);

        //子
        paymentdetailbenefitpersonlistitem = layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
        benefitpersonlistitem = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
        paymentActionOrderChildView = layoutInflater.inflate(R.xml.payment_action_order_child, null);
        paymentActionOrderChildItemLinearLayout = (LinearLayout) paymentActionOrderChildView.findViewById(R.id.payment_action_order_child_item_linearlayout);
        paymentActionOrderCashSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_cash_select);
        paymentActionOrderBankSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_bank_select);
        paymentActionOrderOtherSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_other_select);
        paymentActionOrderIntegralSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_integral_select);
        paymentActionOrderCashCouponSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_cash_coupon_select);

        //选择微信支付
        paymentActionOrderWeiXinSelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_weixin_select);
        //选择支付宝支付
        paymentActionOrderAliPaySelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_alipay_select);
        paymentActionOrderLoanPaySelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_loan_select);
        paymentActionOrderFromThirdPaySelect = (ImageButton) paymentActionOrderChildView.findViewById(R.id.payment_action_order_from_third_select);

        paymentActionOrderCardSurplusButton = (Button) paymentActionOrderChildView.findViewById(R.id.payment_action_order_card_surplus_button);
        paymentActionOrderPointAndCouponSurplusButton = (Button) paymentActionOrderChildView.findViewById(R.id.payment_action_order_point_cashcoupon_surplus_button);
        // 积分
        paymentActionOrderIntegralText24 = (TextView) paymentActionOrderChildView.findViewById(R.id.payment_action_order_integral_text24);
        paymentActionOrderIntegralText24.setSelectAllOnFocus(true);
        //现金券
        paymentActionOrderCashCouponText24 = (TextView) paymentActionOrderChildView.findViewById(R.id.payment_action_order_cash_coupon_text24);
        paymentActionOrderCashCouponText24.setSelectAllOnFocus(true);
        // 赠送积分
        thisTimeGivePoint = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_give_point);
        thisTimeGivePoint.setSelectAllOnFocus(true);
        // 赠送现金券
        thisTimeGiveCashCoupon = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_give_cash_coupon);
        thisTimeGiveCashCoupon.setSelectAllOnFocus(true);
        // 使用积分edit
        paymentActionOrderIntegralEdit22 = (EditText) paymentActionOrderChildView.findViewById(R.id.payment_action_order_integral_edit22);
        paymentActionOrderIntegralEdit22.setSelectAllOnFocus(true);
        // 使用现金券
        paymentActionOrderCashCouponEdit22 = (EditText) paymentActionOrderChildView.findViewById(R.id.payment_action_order_cash_coupon_edit22);
        paymentActionOrderCashCouponEdit22.setSelectAllOnFocus(true);
        // 现金
        thisTimePayAmountCashAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_cash_all);
        // 银行卡
        thisTimePayAmountCardAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_bank_all);
        // 其他
        thisPaymentOtherAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_other_all);
        //全额使用微信支付的按钮
        thisTimePayAmountWeiXinAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_wexin_all);
        //全额使用支付宝的按钮
        thisTimePayAmountAliAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_alipay_all);
        // 消费贷款
        thisTimePayAmountLoanAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_loan_all);
        // 第三方付款
        thisTimePayAmountFromThirdAll = (Button) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_from_third_all);
        // 现金
        thisTimePayAmountCash = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_cash);
        thisTimePayAmountCash.setSelectAllOnFocus(true);
        // 银行卡
        thisTimePayAmountBank = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_bank);
        thisTimePayAmountBank.setSelectAllOnFocus(true);
        // 其他
        thisTimePaymentOtherAmountText = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_other);
        thisTimePaymentOtherAmountText.setSelectAllOnFocus(true);
        //微信支付输入文本框
        thisTimePayWeiXin = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_weixin);
        thisTimePayWeiXin.setSelectAllOnFocus(true);
        //支付宝支付输入文本框
        thisTimePayAli = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_alipay);
        thisTimePayAli.setSelectAllOnFocus(true);
        thisTimePayLoan = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_loan);
        thisTimePayLoan.setSelectAllOnFocus(true);
        thisTimePayFromThird = (EditText) paymentActionOrderChildView.findViewById(R.id.this_time_pay_amount_from_third);
        thisTimePayFromThird.setSelectAllOnFocus(true);

        EditText[] editText = new EditText[]{thisTimeGivePoint, thisTimeGiveCashCoupon, paymentActionOrderIntegralEdit22, paymentActionOrderCashCouponEdit22, thisTimePayAmountCash, thisTimePayAmountBank, thisTimePaymentOtherAmountText, thisTimePayWeiXin, thisTimePayAli, thisTimePayLoan, thisTimePayFromThird, shouldPayAmountEdit};
        NumberFormatUtil.setPricePointArray(editText, 2);
        paymentActionOrderPresent = (RelativeLayout) paymentActionOrderChildView.findViewById(R.id.payment_action_order_present);
        thisTimeGiveView = paymentActionOrderChildView.findViewById(R.id.this_time_give_view);
        thisTimePointView = paymentActionOrderChildView.findViewById(R.id.this_time_point_view);
        thisTimeGivePointRelativelayout = (RelativeLayout) paymentActionOrderChildView.findViewById(R.id.this_time_give_point_relativelayout);
        thisTimeGiveCashCouponRelativelayout = (RelativeLayout) paymentActionOrderChildView.findViewById(R.id.this_time_give_cash_coupon_relativelayout);
    }

    private void initView() {
        String advanced = userinfoApplication.getAccountInfo().getModuleInUse();

        if (advanced.contains("|5|") || advanced.contains("|6|")) {
            //如果没有登陆进来的公司没有微信支付功能，则隐藏微信支付功能
            if (advanced.contains("|5|"))
                paymentActionOrderChildView.findViewById(R.id.payment_action_order_weixin_relativelayout).setVisibility(View.VISIBLE);
            else
                paymentActionOrderChildView.findViewById(R.id.payment_action_order_weixin_relativelayout).setVisibility(View.GONE);
            //如果没有登陆进来的公司没有支付宝支付功能，则隐藏支付宝支付
            if (advanced.contains("|6|"))
                paymentActionOrderChildView.findViewById(R.id.payment_action_order_alipay_relativelayout).setVisibility(View.VISIBLE);
            else
                paymentActionOrderChildView.findViewById(R.id.payment_action_order_alipay_relativelayout).setVisibility(View.GONE);
        }
        //如果既没有微信 也没有支付宝支付功能 则隐藏第三方支付
        else {
            paymentActionOrderChildView.findViewById(R.id.payment_action_order_third_part_payment_tablelayout).setVisibility(View.GONE);
        }
    }

    private void initData() {
        cardDiscountListSize = cardDiscountList.size();
        orderListSize = orderList.size();
        ecardInfoListSize = ecardInfoList.size();
        paidOrderTotalPriceText.setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(orderTotalCalcPrice)));
        shouldPayAmountEdit.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderShouldPayAmountTotal)));
        // 应付款编辑权限
        if (userinfoApplication.getAccountInfo().isPayAmountWrite()) {
            shouldPayAmountEdit.setEnabled(true);
        } else {
            shouldPayAmountEdit.setEnabled(false);
        }
        paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderTotalCalcPrice)));
        paidOrderCountText.setText(String.valueOf(orderListSize));
        thisTimeGivePoint.setText(NumberFormatUtil.currencyFormat("0"));
        thisTimeGiveCashCoupon.setText(NumberFormatUtil.currencyFormat("0"));
        benefitshareprice.setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) - Double.valueOf(shouldPayAmountEdit.getText().toString()) * benefitshareamount)));
        addCardSpinner.setEnabled(false);

        if (isAllowedEcardPay) {
            paymentActionOrderChildView.findViewById(R.id.payment_action_order_child_item_ecard_tablelayout).setVisibility(View.VISIBLE);
        } else {
            paymentActionOrderChildView.findViewById(R.id.payment_action_order_child_item_ecard_tablelayout).setVisibility(View.GONE);
        }

        if (cardDiscountListSize > 0) {
            paymentActionOrderCardRelativelayout.setVisibility(View.VISIBLE);
        } else
            paymentActionOrderCardRelativelayout.setVisibility(View.GONE);
        //下一步
        paymentActionOrderDown.setOnClickListener(this);
        paymentActionOrderReturn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        //上一步
        paymentActionOrderUp.setOnClickListener(this);

        //赠送栏
        paymentActionOrderPresent.setOnClickListener(this);
        //查看储值卡余额
        if (ecardInfoListSize > 0) {
            for (int i = 0; i < ecardInfoListSize; i++) {
                EcardInfo ecardInfo = new EcardInfo();
                int ecardType = ecardInfoList.get(i).getUserEcardType();
                if (ecardType == 1) {
                    ecardInfo.setUserEcardBalance(ecardInfoList.get(i).getUserEcardBalance());
                    ecardInfo.setUserEcardNo(ecardInfoList.get(i).getUserEcardNo());
                    ecardInfo.setUserEcardName(ecardInfoList.get(i).getUserEcardName());
                    ecardInfo.setDefault(ecardInfoList.get(i).isDefault());
                    ecardInfo.setUserEcardType(ecardInfoList.get(i).getUserEcardType());
                    ecardInfo.setUserEcardRate(ecardInfoList.get(i).getUserEcardRate());
                    ecardInfo.setUserEcardID(ecardInfoList.get(i).getUserEcardID());
                    ecardInfo.setUserEcardPresentRate(ecardInfoList.get(i).getUserEcardPresentRate());
                    cardList.add(ecardInfo);
                }
            }
            //显示储值卡余额
            cardListSize = cardList.size();
            if (cardList == null || cardList.size() == 0) {
                paymentActionOrderChildView.findViewById(R.id.payment_action_order_child_item_ecard_tablelayout).setVisibility(View.GONE);
            }
            final String[] ecardArray = new String[cardListSize];
            for (int i = 0; i < cardListSize; i++) {
                ecardArray[i] = cardList.get(i).getUserEcardName() + "余额（" + cardList.get(i).getUserEcardBalance() + "）";
            }

            paymentActionOrderCardSurplusButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    Dialog dialog = new AlertDialog.Builder(PaymentActionActivity.this, R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setItems(ecardArray, new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {

                                }
                            }).create();
                    dialog.show();
                }
            });
        }
        //显示积分或者现金券余额
        List<EcardInfo> pointCouponList = new ArrayList<EcardInfo>();
        for (EcardInfo ei : ecardInfoList) {
            if (ei.getUserEcardType() == 2 || ei.getUserEcardType() == 3) {
                pointCouponList.add(ei);
            }
        }
        final String[] pointCouponArray = new String[pointCouponList.size()];
        for (int j = 0; j < pointCouponList.size(); j++) {
            pointCouponArray[j] = pointCouponList.get(j).getUserEcardName() + "余额（" + pointCouponList.get(j).getUserEcardBalance() + "）";
        }
        paymentActionOrderPointAndCouponSurplusButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                Dialog dialog = new AlertDialog.Builder(PaymentActionActivity.this, R.style.CustomerAlertDialog)
                        .setTitle(getString(R.string.delete_dialog_title))
                        .setItems(pointCouponArray, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {

                            }
                        }).create();
                dialog.show();
            }
        });
        //单多选设置
        paymentActionOrderCashSelect.setOnClickListener(this);
        paymentActionOrderBankSelect.setOnClickListener(this);
        paymentActionOrderOtherSelect.setOnClickListener(this);
        paymentActionOrderIntegralSelect.setOnClickListener(this);
        paymentActionOrderCashCouponSelect.setOnClickListener(this);
        paymentActionOrderWeiXinSelect.setOnClickListener(this);
        paymentActionOrderAliPaySelect.setOnClickListener(this);
        paymentActionOrderLoanPaySelect.setOnClickListener(this);
        paymentActionOrderFromThirdPaySelect.setOnClickListener(this);
        shouldPayAmountEdit.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
				/*if( shouldPayAmountEdit.getText().toString().length() < 1){
					shouldPayAmountEdit.setText("0");
				}*/
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (shouldPayAmountEdit.getText().toString() != null && !(("").equals(shouldPayAmountEdit.getText().toString())) && Double.valueOf(shouldPayAmountEdit.getText().toString()) > 0) {
                    thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                } else {
                    thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(0));
                }
            }
        });
        //赠送
        int integral1 = 0;
        int cashCoupon1 = 0;
        for (int i = 0; i < ecardInfoListSize; i++) {
            //积分
            if (ecardInfoList.get(i).getUserEcardType() == 2 && integral1 == 0) {
                integral1++;
                integralRate = ecardInfoList.get(i).getUserEcardRate();
                integralPresentRate = ecardInfoList.get(i).getUserEcardPresentRate();
            }
            //现金劵
            if (ecardInfoList.get(i).getUserEcardType() == 3 && cashCoupon1 == 0) {
                cashCoupon1++;
                cashCouponRate = ecardInfoList.get(i).getUserEcardRate();
                cashCouponPresentRate = ecardInfoList.get(i).getUserEcardPresentRate();
            }
        }
        //循环加载储值卡处理代码
        if (cardListSize > 0) {
            for (int i = 0; i < cardListSize; i++) {
                final int cardChildIndex1 = i;
                final View paymentActionOrderChildItemView = layoutInflater.inflate(R.xml.payment_action_order_child_item, null);
                final ImageButton selectPaymentActionOrderCardChildButton = (ImageButton) paymentActionOrderChildItemView.findViewById(R.id.select_payment_action_order_card_child_button);
                TextView paymentActionOrderCardChildText = (TextView) paymentActionOrderChildItemView.findViewById(R.id.payment_action_order_card_child_text);
                final EditText paymentActionOrderCardChildEdit = (EditText) paymentActionOrderChildItemView.findViewById(R.id.payment_action_order_card_child_edit);
                paymentActionOrderCardChildEdit.setSelectAllOnFocus(true);
                NumberFormatUtil.setPricePoint(paymentActionOrderCardChildEdit, 2);
                Button thisTimePayAmountCardChildAll = (Button) paymentActionOrderChildItemView.findViewById(R.id.this_time_pay_amount_card_child_all);
                paymentActionOrderCardChildText.setText(cardList.get(i).getUserEcardName());
                paymentActionOrderChildItemView.setTag(cardChildIndex1);
                final String cardChild = "cardChild" + i;
                //储值卡单多选
                selectPaymentActionOrderCardChildButton.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (orderListSize > 1) {
                            selectButton.clear();
                            initSelectButton();
                            if (cardListSize > 0) {
                                for (int i = 0; i < cardListSize; i++) {
                                    ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                                }
                            }
                        }
                        if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false) == true) {
                            selectPaymentActionOrderCardChildButton.setBackgroundResource(R.drawable.no_select_btn);
                            selectButton.put(cardChild, false);
                        } else {
                            selectPaymentActionOrderCardChildButton.setBackgroundResource(R.drawable.select_btn);
                            selectButton.put(cardChild, true);
                        }
                        clearThirdPartPaySelect();
                        selectTotalPrice();
                    }
                });
                //全额支付
                thisTimePayAmountCardChildAll.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        cardChildIndex = cardChildIndex1;
                        initEditText();
						/*
						thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
						*/
                        for (int j = 0; j < cardListSize; j++) {
                            final String cardChild1 = "cardChild" + j;
                            View view = paymentActionOrderChildItemLinearLayout.findViewWithTag(j);
                            selectButton.clear();
                            initSelectButton();
                            ((ImageButton) view.findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                            if (cardChildIndex != j) {
                                ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                                selectButton.put("cardChild" + cardChildIndex, true);
                            } else {
                                ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
                                ((ImageButton) view.findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.select_btn);
                                selectButton.put(cardChild1, true);
                            }
                        }
                        clearThirdPartPaySelect();
                        selectTotalPrice();
                    }
                });
                //储值卡edit
                paymentActionOrderCardChildEdit.addTextChangedListener(new TextWatcher() {
                    @Override
                    public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

                    }

                    @Override
                    public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

                    }

                    @Override
                    public void afterTextChanged(Editable arg0) {
                        selectTotalPrice();
                    }
                });

                paymentActionOrderChildItemLinearLayout.addView(paymentActionOrderChildItemView);
            }

        }
        //使用积分edit
        paymentActionOrderIntegralEdit22.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                Double point = 0.00;
                try {
                    point = Double.valueOf(s.toString());
                } catch (NumberFormatException e) {
                    point = 0.00;
                }
                paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(point * Double.valueOf(integralRate))));
                selectTotalPrice();
            }

        });
        //使用现金劵edit
        paymentActionOrderCashCouponEdit22.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Double point = 0.00;
                try {
                    point = Double.valueOf(s.toString());
                } catch (NumberFormatException e) {
                    point = 0.00;
                }
                paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(point * Double.valueOf(cashCouponRate))));

            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                selectTotalPrice();
            }
        });
        //FIXME
        mTvBenefitPerson = (TextView) findViewById(R.id.payment_benefit_person);
        findViewById(R.id.payment_benefit_person).setOnClickListener(this);
        findViewById(R.id.payment_benefit_textv).setOnClickListener(this);
        findViewById(R.id.payment_benefit_share_btn).setOnClickListener(this);
        // 现金全额支付
        thisTimePayAmountCashAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false) == true) {
                    paymentActionOrderCashSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("cash", false);
                } else {
                    paymentActionOrderCashSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("cash", true);
                }
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        // 银行卡全额支付
        thisTimePayAmountCardAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                if ((selectButton.containsKey("bank") ? selectButton.get("bank") : false) == true) {
                    paymentActionOrderBankSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("bank", false);
                } else {
                    paymentActionOrderBankSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("bank", true);
                }

                if (cardListSize > 0) {
                    View paymentActionOrderChildLinearLayoutView = paymentActionOrderChildLinearLayout.getChildAt(0);
                    LinearLayout paymentActionOrderChildItemLinearLayout1 = (LinearLayout) paymentActionOrderChildLinearLayoutView.findViewById(R.id.payment_action_order_child_item_linearlayout);
                    for (int i = 0; i < cardListSize; i++) {
                        View paymentActionOrderChildItemLinearLayout1View = paymentActionOrderChildItemLinearLayout1.getChildAt(i);
                        ((EditText) paymentActionOrderChildItemLinearLayout1View.findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        // 其他方式全额支付
        thisPaymentOtherAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }

                if ((selectButton.containsKey("other") ? selectButton.get("other") : false) == true) {
                    paymentActionOrderOtherSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("other", false);
                } else {
                    paymentActionOrderOtherSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("other", true);
                }

                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        //微信全额支付
        thisTimePayAmountWeiXinAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayWeiXin.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }

                if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
                    paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("weixin", false);
                } else {
                    paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("weixin", true);
                }
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        //支付宝全额支付
        thisTimePayAmountAliAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayAli.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayWeiXin.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                //清空微信支付
                if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
                    paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("weixin", false);
                }
                //对支付宝支付进行判断存储
                if ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true) {
                    paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("alipay", false);
                } else {
                    paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("alipay", true);
                }
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        //消费贷款全额支付
        thisTimePayAmountLoanAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayLoan.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayFromThird.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAli.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayWeiXin.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                //对消费贷款支付进行判断存储
                if ((selectButton.containsKey("loan") ? selectButton.get("loan") : false) == true) {
                    paymentActionOrderLoanPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("loan", false);
                } else {
                    paymentActionOrderLoanPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("loan", true);
                }
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        //第三方付款全额支付
        thisTimePayAmountFromThirdAll.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                initEditText();
                thisTimePayFromThird.setText(NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
				/*
				thisTimePayLoan.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAli.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayWeiXin.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
				*/
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                //对消费贷款支付进行判断存储
                if ((selectButton.containsKey("third") ? selectButton.get("third") : false) == true) {
                    paymentActionOrderFromThirdPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("loan", false);
                } else {
                    paymentActionOrderFromThirdPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("third", true);
                }
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((EditText) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.payment_action_order_card_child_edit)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                    }
                }
                //赠送积分现金劵
                thisTimeGivePoint.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(integralPresentRate)));
                thisTimeGiveCashCoupon.setText(String.valueOf(Double.valueOf(shouldPayAmountEdit.getText().toString()) * Double.valueOf(cashCouponPresentRate)));
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + shouldPayAmountEdit.getText().toString());
            }
        });
        thisTimePayAmount.setText(NumberFormatUtil.currencyFormat("0"));
        thisTimePayAmountCash.addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePayAmountBank.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {
            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePaymentOtherAmountText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePayWeiXin.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePayAli.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePayLoan.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        thisTimePayFromThird.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int arg1, int arg2, int arg3) {

            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                selectTotalPrice();
            }
        });
        payFromOrderDetail = getIntent().getBooleanExtra("payFromOrderDetail", false);
        //设置销售顾问业绩比例
        if (salesConsultantRateList != null && salesConsultantRateList.size() > 0) {
            setsalesConsultantInfo(salesConsultantRateList);

        } else {
            benefitsharepriceview.setVisibility(View.VISIBLE);
        }
        if (orderListSize > 1 || orderList.get(0).getPaymentStatus() != 1) {
            if (isComissionCalc) {
                ordersalespercentageview.setVisibility(View.VISIBLE);
                ordersalespercentagelayout.setVisibility(View.VISIBLE);
                ordersalespercentagelinearlayout.setVisibility(View.VISIBLE);
                benefitsharepricelayout.setVisibility(View.VISIBLE);
                benefitpersonview.setVisibility(View.VISIBLE);
                benefitpersonlayout.setVisibility(View.VISIBLE);
                benefitpersonlinearlayout.setVisibility(View.VISIBLE);
            }
            paymentActionOrderCardRelativelayout.setVisibility(View.GONE);
            addCardSpinner.setEnabled(false);
            paymentActionOrderUp.setVisibility(View.GONE);
            paymentActionOrderPayOrder.setVisibility(View.VISIBLE);
            paymentActionOrderDown.setVisibility(View.GONE);
            paymentActionOrderReturn.setVisibility(View.GONE);
            shouldPayAmountEdit.setEnabled(false);
            paymentActionOrderCardSpinnerView.setVisibility(View.GONE);
            thisTimePayAmountView.setVisibility(View.VISIBLE);
            shouldPayAmountEdit.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderShouldPayAmountTotal)));
            thisTimePayAmountRelativeLayout.setVisibility(View.VISIBLE);
            paymentActionOrderChildLinearLayout.addView(paymentActionOrderChildView);
            paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderTotalCalcPrice)));
            thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(0));
        } else {
            thisTimePayAmountView.setVisibility(View.GONE);
            //单一订单页的会员价spinner
            if (cardDiscountListSize > 0) {
                paymentActionOrderCardSpinnerView.setVisibility(View.VISIBLE);
                ecardIdArray = new int[cardDiscountList.size()];
                ecardNameArray = new String[cardDiscountList.size()];
                for (int i = 0; i < cardDiscountListSize; i++) {
                    ecardNameArray[i] = String.valueOf(cardDiscountList.get(i).getUserEcardNameAndDiscount());
                    ecardIdArray[i] = cardDiscountList.get(i).getUserEcardID();
                }
                ArrayAdapter<String> ecardArrayAdapter = new ArrayAdapter<String>(PaymentActionActivity.this, R.xml.spinner_checked_text, ecardNameArray);
                ecardArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                addCardSpinner.setAdapter(ecardArrayAdapter);
                int cardSize = ecardNameArray.length;
                for (int i = 0; i < cardSize; i++) {
                    if (cardID == ecardIdArray[i]) {
                        UpdateTotalSalePriceUserCardId = ecardIdArray[i];
                        addCardSpinner.setSelection(i, true);
                        break;
                    }
                }
                addCardSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> parent,
                                               View view, int position, long id) {
                        UpdateTotalSalePriceUserCardId = cardDiscountList.get(position).getUserEcardID();
                        updateTotalSalePriceUserCardNo = cardDiscountList.get(position).getUserEcardNo();
                        if (marketingPolicy == 0) {
                            paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(paidOrderTotalPrice * Double.valueOf(cardDiscountList.get(position).getUserEcardDiscount()))));
                        } else if (marketingPolicy == 1) {
                            paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(paidOrderTotalPrice * Double.valueOf(cardDiscountList.get(position).getUserEcardDiscount()))));
                        } else if (marketingPolicy == 2) {
                            if (position != 0) {
                                paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(promotionPrice * quantity * Double.valueOf(cardDiscountList.get(position).getUserEcardDiscount()))));
                            } else {
                                paymentActionOrderCardSpinnerText.setText(NumberFormatUtil.currencyFormat(String.valueOf(paidOrderTotalPrice * Double.valueOf(cardDiscountList.get(position).getUserEcardDiscount()))));
                            }
                        }
                        if (orderList.get(0).getPaymentStatus() == 1) {
                            shouldPayAmountEdit.setText(paymentActionOrderCardSpinnerText.getText().toString());
                            thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> parent) {
                    }
                });
                shouldPayAmountEdit.setText(NumberFormatUtil.currencyFormat(String.valueOf(orderShouldPayAmountTotal)));
                if (orderList.get(0).getPaymentStatus() == 1) {
                    addCardSpinner.setVisibility(View.VISIBLE);
                    addCardSpinner.setEnabled(true);
                } else {
                    addCardSpinner.setVisibility(View.VISIBLE);
                    addCardSpinner.setEnabled(false);
                }
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
            } else {
                paymentActionOrderCardRelativelayout.setVisibility(View.GONE);
                paymentActionOrderCardSpinnerView.setVisibility(View.GONE);
            }
            thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(orderShouldPayAmountTotal));
        }
    }


    private void selectTotalPrice() {
        useCardpaidOrderTotalPrice = 0;
        useIntegralpaidOrderTotalPrice = 0;
        useCashCouponpaidOrderTotalPrice = 0;
        useECardpaidOrderTotalPrice = 0;
        useWeiXinPaidOrderTotalPrice = 0;
        useAliPaidOrderTotalPrice = 0;
        useLoanPaidOrderTotalPrice = 0;
        useFromThirdPaidOrderTotalPrice = 0;
        // 现金
        String paymentAmountCash = thisTimePayAmountCash.getText().toString();
        // 银行卡
        String paymentAmountBank = thisTimePayAmountBank.getText().toString();
        // 其他支付
        String paymentAmountOther = thisTimePaymentOtherAmountText.getText().toString();
        //微信支付
        String paymentAmountWeiXin = thisTimePayWeiXin.getText().toString();
        //支付宝支付
        String paymentAmountAli = thisTimePayAli.getText().toString();
        //消费贷款支付
        String paymentAmountLoan = thisTimePayLoan.getText().toString();
        //第三方付款支付
        String paymentAmountFromThird = thisTimePayFromThird.getText().toString();
        //积分
        String paymentAmountIntegral = paymentActionOrderIntegralText24.getText().toString();
        //现金券
        String paymentAmountCashCoupon = paymentActionOrderCashCouponText24.getText().toString();

        if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false) == true) {
            if (paymentAmountCash != null && !(("").equals(paymentAmountCash)) && Double.valueOf(paymentAmountCash) != 0) {
                useCardpaidOrderTotalPrice = useCardpaidOrderTotalPrice + Double.valueOf(paymentAmountCash);
            }
        }
        if ((selectButton.containsKey("bank") ? selectButton.get("bank") : false) == true) {
            if (paymentAmountBank != null && !(("").equals(paymentAmountBank)) && Double.valueOf(paymentAmountBank) != 0) {
                useCardpaidOrderTotalPrice = useCardpaidOrderTotalPrice + Double.valueOf(paymentAmountBank);
            }
        }
        if ((selectButton.containsKey("other") ? selectButton.get("other") : false) == true) {
            if (paymentAmountOther != null && !(("").equals(paymentAmountOther)) && Double.valueOf(paymentAmountOther) != 0) {
                useCardpaidOrderTotalPrice = useCardpaidOrderTotalPrice + Double.valueOf(paymentAmountOther);
            }
        }
        if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
            if (paymentAmountWeiXin != null && !(("").equals(paymentAmountWeiXin)) && Double.valueOf(paymentAmountWeiXin) != 0) {
                useWeiXinPaidOrderTotalPrice = useWeiXinPaidOrderTotalPrice + Double.valueOf(paymentAmountWeiXin);
            }
        }
        if ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true) {
            if (paymentAmountAli != null && !(("").equals(paymentAmountAli)) && Double.valueOf(paymentAmountAli) != 0) {
                useAliPaidOrderTotalPrice = useAliPaidOrderTotalPrice + Double.valueOf(paymentAmountAli);
            }
        }
        if ((selectButton.containsKey("loan") ? selectButton.get("loan") : false) == true) {
            if (paymentAmountLoan != null && !(("").equals(paymentAmountLoan)) && Double.valueOf(paymentAmountLoan) != 0) {
                useLoanPaidOrderTotalPrice = Double.valueOf(paymentAmountLoan);
            }
        }
        if ((selectButton.containsKey("third") ? selectButton.get("third") : false) == true) {
            if (paymentAmountFromThird != null && !(("").equals(paymentAmountFromThird)) && Double.valueOf(paymentAmountFromThird) != 0) {
                useFromThirdPaidOrderTotalPrice = Double.valueOf(paymentAmountFromThird);
            }
        }
        if ((selectButton.containsKey("integral") ? selectButton.get("integral") : false) == true) {
            if (paymentAmountIntegral != null && !(("").equals(paymentAmountIntegral)) && Double.valueOf(paymentAmountIntegral) != 0) {
                useIntegralpaidOrderTotalPrice = Double.valueOf(paymentAmountIntegral);
            }
        }
        if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false) == true) {
            if (paymentAmountCashCoupon != null && !(("").equals(paymentAmountCashCoupon)) && Double.valueOf(paymentAmountCashCoupon) != 0) {
                useCashCouponpaidOrderTotalPrice = Double.valueOf(paymentAmountCashCoupon);
            }
        }
        for (int i = 0; i < cardListSize; i++) {
            final String cardChild = "cardChild" + i;
            if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false) == true) {
                View view = paymentActionOrderChildItemLinearLayout.findViewWithTag(i);
                String cardString = ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).getText().toString();
                if (cardString != null && !(("").equals(cardString)) && Double.valueOf(cardString) > 0) {
                    useECardpaidOrderTotalPrice = useECardpaidOrderTotalPrice + Double.valueOf(cardString);
                }
            }
        }
        //业绩参与分配金额
        double shouldPaysmounts = Double.valueOf(shouldPayAmountEdit.getText().toString());
        double benefitsharepriceamount = shouldPaysmounts - shouldPaysmounts * benefitshareamount;
        if (useIntegralpaidOrderTotalPrice != 0 || useCashCouponpaidOrderTotalPrice != 0) {
            benefitsharepriceamount = shouldPaysmounts - useIntegralpaidOrderTotalPrice - useCashCouponpaidOrderTotalPrice - ((shouldPaysmounts - useIntegralpaidOrderTotalPrice - useCashCouponpaidOrderTotalPrice) * benefitshareamount);
        }
        benefitshareprice.setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(benefitsharepriceamount)));
        //赠送积分现金劵
        thisTimeGivePoint.setText(NumberFormatUtil.currencyFormat(String.valueOf((useCardpaidOrderTotalPrice + useECardpaidOrderTotalPrice + useWeiXinPaidOrderTotalPrice + useAliPaidOrderTotalPrice + useLoanPaidOrderTotalPrice + useFromThirdPaidOrderTotalPrice) * Double.valueOf(integralPresentRate))));
        thisTimeGiveCashCoupon.setText(NumberFormatUtil.currencyFormat(String.valueOf((useCardpaidOrderTotalPrice + useECardpaidOrderTotalPrice + useWeiXinPaidOrderTotalPrice + useAliPaidOrderTotalPrice + useLoanPaidOrderTotalPrice + useFromThirdPaidOrderTotalPrice) * Double.valueOf(cashCouponPresentRate))));
        thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(useCardpaidOrderTotalPrice + useECardpaidOrderTotalPrice + useIntegralpaidOrderTotalPrice + useCashCouponpaidOrderTotalPrice + useWeiXinPaidOrderTotalPrice + useAliPaidOrderTotalPrice + useLoanPaidOrderTotalPrice + useFromThirdPaidOrderTotalPrice));
        thisTimePayAmount.setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(useCardpaidOrderTotalPrice + useECardpaidOrderTotalPrice + useIntegralpaidOrderTotalPrice + useCashCouponpaidOrderTotalPrice + useWeiXinPaidOrderTotalPrice + useAliPaidOrderTotalPrice + useLoanPaidOrderTotalPrice + useFromThirdPaidOrderTotalPrice)));
    }

    private void initSelectButton() {
        paymentActionOrderCashSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderBankSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderOtherSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderIntegralSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderCashCouponSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderLoanPaySelect.setBackgroundResource(R.drawable.no_select_btn);
        paymentActionOrderFromThirdPaySelect.setBackgroundResource(R.drawable.no_select_btn);
    }

    //点击e卡支付或者现金 银行卡 其他支付时，清除掉第三方支付(微信和支付宝)
    private void clearThirdPartPaySelect() {
        if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
            paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.no_select_btn);
            selectButton.put("weixin", false);
        }
        if ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true) {
            paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.no_select_btn);
            selectButton.put("alipay", false);
        }
    }

    private void getPaymentInfoByWebService() {
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetPaymentInfo";
                String endPoint = "Payment";
                JSONArray orderArray = new JSONArray();
                for (int i = 0; i < orderList.size(); i++) {
                    JSONObject orderObject = new JSONObject();
                    try {
                        orderObject.put("OrderID", orderList.get(i).getOrderID());
                        orderObject.put("OrderObjectID", orderList.get(i).getOrderObejctID());
                        orderObject.put("ProductType", orderList.get(i).getProductType());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    orderArray.put(orderObject);
                }

                JSONObject getPaymentInfoJson = new JSONObject();
                try {
                    getPaymentInfoJson.put("CustomerID", customerID);
                    getPaymentInfoJson.put("OrderList", orderArray);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getPaymentInfoJson.toString(), userinfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(3);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResult);
                    } catch (JSONException e) {
                    }
                    String code = "0";
                    String serverMessage = "";
                    try {
                        code = resultJson.getString("Code");
                        serverMessage = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = "0";
                    }
                    if (Integer.parseInt(code) == 1) {
                        try {
                            JSONObject data = resultJson.getJSONObject("Data");
                            // 获得是否允许e卡支付
                            isAllowedEcardPay = data.getBoolean("IsPay");
                            isAllowedPartPay = data.getBoolean("IsPartPay");
                            paidOrderTotalPrice = Double.valueOf(data.getString("TotalOrigPrice"));
                            orderShouldPayAmountTotal = Double.valueOf(data.getString("UnPaidPrice"));
                            orderTotalCalcPrice = Double.valueOf(data.getString("TotalCalcPrice"));
                            namegetFlg = 1;
                            if (data.has("CardID"))
                                cardID = data.getInt("CardID");
                            if (data.has("ProductCode"))
                                productCode = data.getString("ProductCode");
                            if (data.has("UserCardNo"))
                                updateTotalSalePriceUserCardNo = data.getString("UserCardNo");
                            if (data.has("PromotionPrice"))
                                promotionPrice = Double.valueOf(data.getString("PromotionPrice"));
                            if (data.has("MarketingPolicy"))
                                marketingPolicy = data.getInt("MarketingPolicy");
                            if (data.has("Quantity"))
                                quantity = data.getInt("Quantity");
                            if (data.has("CardName"))
                                cardName = data.getString("CardName");
                            //销售顾问业绩比例
                            salesConsultantRateList = new ArrayList<SalesConsultantRate>();
                            double amounts = 0;
                            if (data.has("SalesConsultantRates") && !data.isNull("SalesConsultantRates")) {
                                JSONArray salesArray = data.getJSONArray("SalesConsultantRates");
                                for (int k = 0; k < salesArray.length(); k++) {
                                    JSONObject salesConsultantJson = salesArray.getJSONObject(k);
                                    SalesConsultantRate rate = new SalesConsultantRate();
                                    rate.setSalesConsultantID(salesConsultantJson.getInt("SalesConsultantID"));
                                    rate.setSalesConsultantName(salesConsultantJson.getString("SalesConsultantName"));
                                    rate.setCommissionRate(NumberFormatUtil.currencyFormat(String.valueOf(salesConsultantJson.getDouble("commissionRate") * 100)));
                                    amounts = amounts + salesConsultantJson.getDouble("commissionRate");
                                    salesConsultantRateList.add(rate);
                                }
                                benefitshareamount = amounts;
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        mHandler.sendEmptyMessage(4);
                    } else if (Integer.parseInt(code) == Constant.APP_VERSION_ERROR || Integer.parseInt(code) == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(Integer.parseInt(code));
                    else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void getCardDiscountList() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetCardDiscountList";
                String endPoint = "ECard";
                JSONObject getProductInfoJson = new JSONObject();
                try {
                    getProductInfoJson.put("CustomerID", customerID);
                    getProductInfoJson.put("ProductCode", productCode);
                    getProductInfoJson.put("ProductType", orderList.get(0).getProductType());
                } catch (JSONException e) {

                }
                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getProductInfoJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                }

                if (serverResultResult == null || serverResultResult.equals(""))
                    mHandler.sendEmptyMessage(-1);
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

                        JSONArray productArray = null;
                        try {
                            productArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {

                        }
                        if (productArray != null) {
                            EcardInfo ecardInfo1 = new EcardInfo();
                            ecardInfo1.setUserEcardID(0);
                            ecardInfo1.setUserEcardNo("");
                            ecardInfo1.setUserEcardName("不使用e账户");
                            ecardInfo1.setUserEcardDiscount("1");
                            ecardInfo1.setUserEcardNameAndDiscount("不使用e账户");
                            cardDiscountList.add(ecardInfo1);
                            if (productArray.length() > 0) {
                                for (int i = 0; i < productArray.length(); i++) {
                                    JSONObject productjson = null;
                                    try {
                                        productjson = (JSONObject) productArray.get(i);
                                    } catch (JSONException e) {
                                    }
                                    try {
                                        EcardInfo ecardInfo = new EcardInfo();
                                        if (productjson.has("CardID")) {
                                            ecardInfo.setUserEcardID(productjson.getInt("CardID"));
                                        }
                                        if (productjson.has("UserCardNo")) {
                                            ecardInfo.setUserEcardNo(productjson.getString("UserCardNo"));
                                        }
                                        if (productjson.has("CardName")) {
                                            ecardInfo.setUserEcardName(productjson.getString("CardName"));
                                        }
                                        if (productjson.has("Discount")) {
                                            ecardInfo.setUserEcardDiscount(productjson.getString("Discount"));
                                        }
                                        if (productjson.has("CardName") && productjson.has("Discount")) {
                                            if (!(productjson.getString("Discount")).equals("1.0")) {
                                                ecardInfo.setUserEcardNameAndDiscount(productjson.getString("CardName") + "(" + productjson.getString("Discount") + ")");
                                            } else {
                                                ecardInfo.setUserEcardNameAndDiscount(productjson.getString("CardName"));
                                            }
                                        }
                                        cardDiscountList.add(ecardInfo);
                                    } catch (JSONException e) {
                                    }
                                }
                            } else {
                                EcardInfo ecardInfo2 = new EcardInfo();
                                int cardid = cardID;
                                String cardno = updateTotalSalePriceUserCardNo;
                                String cardname = cardName;
                                if (cardid != 0) {
                                    ecardInfo2.setUserEcardID(cardid);
                                    ecardInfo2.setUserEcardNo(cardno);
                                    ecardInfo2.setUserEcardName(cardname);
                                    ecardInfo2.setUserEcardDiscount("1");
                                    ecardInfo2.setUserEcardNameAndDiscount(cardname);
                                    cardDiscountList.add(ecardInfo2);
                                }
                            }
                        }
                        Message msg = new Message();
                        msg.what = 2;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = message;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }


    private void getEcardBalanceByWebService() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {

                String methodName = "GetCustomerCardList";
                String endPoint = "ECard";
                JSONObject ecardInfoJsonParam = new JSONObject();
                try {
                    ecardInfoJsonParam.put("CustomerID", customerID);
                } catch (JSONException e) {

                }

                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, ecardInfoJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(3);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                    } catch (JSONException e) {
                    }
                    int code = 0;
                    try {
                        code = resultJson.getInt("Code");
                    } catch (JSONException e) {
                    }
                    JSONArray ecardInfoArray = null;
                    if (code == 1) {
                        try {
                            ecardInfoArray = (JSONArray) resultJson.get("Data");
                        } catch (JSONException e) {
                        }
                        if (ecardInfoArray.length() > 0) {
                            JSONObject ecardInfoObject;

                            for (int i = 0; i < ecardInfoArray.length(); i++) {
                                EcardInfo ecardInfo = new EcardInfo();
                                try {
                                    ecardInfoObject = ecardInfoArray.getJSONObject(i);
                                    if (ecardInfoObject.has("Balance") && !ecardInfoObject.isNull("Balance"))
                                        ecardInfo.setUserEcardBalance(ecardInfoObject.getString("Balance"));
                                    else ecardInfo.setUserEcardBalance("0");
                                    if (ecardInfoObject.has("UserCardNo") && !ecardInfoObject.isNull("UserCardNo"))
                                        ecardInfo.setUserEcardNo(ecardInfoObject.getString("UserCardNo"));
                                    if (ecardInfoObject.has("CardName") && !ecardInfoObject.isNull("CardName"))
                                        ecardInfo.setUserEcardName(ecardInfoObject.getString("CardName"));
                                    if (ecardInfoObject.has("IsDefault") && !ecardInfoObject.isNull("IsDefault"))
                                        ecardInfo.setDefault(ecardInfoObject.getBoolean("IsDefault"));
                                    if (ecardInfoObject.has("CardTypeID") && !ecardInfoObject.isNull("CardTypeID"))
                                        ecardInfo.setUserEcardType(ecardInfoObject.getInt("CardTypeID"));
                                    if (ecardInfoObject.has("Rate") && !ecardInfoObject.isNull("Rate"))
                                        ecardInfo.setUserEcardRate(ecardInfoObject.getString("Rate"));
                                    if (ecardInfoObject.has("CardID") && !ecardInfoObject.isNull("CardID"))
                                        ecardInfo.setUserEcardID(ecardInfoObject.getInt("CardID"));
                                    if (ecardInfoObject.has("PresentRate") && !ecardInfoObject.isNull("PresentRate"))
                                        ecardInfo.setUserEcardPresentRate(ecardInfoObject.getString("PresentRate"));
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                                ecardInfoList.add(ecardInfo);
                            }
                        }
                        Message msg = new Message();
                        msg.what = 6;
                        mHandler.sendMessage(msg);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.payment_action_order_down:
                if (shouldPayAmountEdit.getText().toString().length() < 1 || "".equals(shouldPayAmountEdit.getText().toString().trim())) {
                    shouldPayAmountEdit.setText("0");
                }
                thisTimePayAmountView.setVisibility(View.VISIBLE);
                if (orderList.get(0).getPaymentStatus() == 1) {
                    if (shouldPayAmountEdit.getText().toString() != null && !(("").equals(shouldPayAmountEdit.getText().toString())) && Double.valueOf(shouldPayAmountEdit.getText().toString()) > 0) {
                        UpdateTotalSalePrice();
                        shouldPayAmountEdit.setText(shouldPayAmountEdit.getText().toString());
                        paymentActionOrderChildLinearLayout.removeView(paymentActionOrderChildView);
                        paymentActionOrderChildLinearLayout.addView(paymentActionOrderChildView);
                        addCardSpinner.setEnabled(false);
                        paymentActionOrderUp.setVisibility(View.VISIBLE);
                        paymentActionOrderPayOrder.setVisibility(View.VISIBLE);
                        if (isComissionCalc) {
                            ordersalespercentageview.setVisibility(View.VISIBLE);
                            ordersalespercentagelayout.setVisibility(View.VISIBLE);
                            ordersalespercentagelinearlayout.setVisibility(View.VISIBLE);
                            benefitsharepricelayout.setVisibility(View.VISIBLE);
                            benefitpersonview.setVisibility(View.VISIBLE);
                            benefitpersonlayout.setVisibility(View.VISIBLE);
                            benefitpersonlinearlayout.setVisibility(View.VISIBLE);
                        }
                        paymentActionOrderDown.setVisibility(View.GONE);
                        paymentActionOrderReturn.setVisibility(View.GONE);
                        shouldPayAmountEdit.setEnabled(false);
                        thisTimePayAmountRelativeLayout.setVisibility(View.VISIBLE);
                        thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(0));
                    } else {
                        UpdateTotalSalePrice();
                    }
                }
                break;
            case R.id.payment_action_order_up:
                thisTimePayAmountView.setVisibility(View.GONE);
                paymentActionOrderUp.setVisibility(View.GONE);
                paymentActionOrderPayOrder.setVisibility(View.GONE);
                ordersalespercentageview.setVisibility(View.GONE);
                ordersalespercentagelayout.setVisibility(View.GONE);
                ordersalespercentagelinearlayout.setVisibility(View.GONE);
                benefitsharepricelayout.setVisibility(View.GONE);
                benefitpersonview.setVisibility(View.GONE);
                benefitpersonlayout.setVisibility(View.GONE);
                benefitpersonlinearlayout.setVisibility(View.GONE);
                paymentActionOrderDown.setVisibility(View.VISIBLE);
                paymentActionOrderReturn.setVisibility(View.VISIBLE);
                thisTimePayAmountRelativeLayout.setVisibility(View.GONE);
                shouldPayAmountEdit.setEnabled(true);
                paymentActionOrderChildLinearLayout.removeAllViews();
                paidOrderTotalPriceText.setText(userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(paidOrderTotalPrice)));
                shouldPayAmountEdit.setText(shouldPayAmountEdit.getText().toString());
                thisTimePayAmountUppercase.setText(LowerCase2Uppercase.l2Uppercase(Double.valueOf(shouldPayAmountEdit.getText().toString())));
                paidOrderCountText.setText(String.valueOf(orderList.size()));
                if (orderList.get(0).getPaymentStatus() == 1) {
                    addCardSpinner.setEnabled(true);
                } else {
                    addCardSpinner.setEnabled(false);
                }
                break;
            case R.id.payment_action_order_present:
                if (thisTimeGivePointRelativelayout.getVisibility() == View.VISIBLE) {
                    thisTimeGivePointRelativelayout.setVisibility(View.GONE);
                    thisTimeGiveCashCouponRelativelayout.setVisibility(View.GONE);
                    thisTimeGiveView.setVisibility(View.GONE);
                    thisTimePointView.setVisibility(View.GONE);
                } else {
                    thisTimeGivePointRelativelayout.setVisibility(View.VISIBLE);
                    thisTimeGiveCashCouponRelativelayout.setVisibility(View.VISIBLE);
                    thisTimeGiveView.setVisibility(View.VISIBLE);
                    thisTimePointView.setVisibility(View.VISIBLE);
                }
                break;
            case R.id.payment_action_order_cash_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false) == true) {
                    paymentActionOrderCashSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("cash", false);
                } else {
                    paymentActionOrderCashSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("cash", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_bank_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("bank") ? selectButton.get("bank") : false) == true) {
                    paymentActionOrderBankSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("bank", false);
                } else {
                    paymentActionOrderBankSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("bank", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_other_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }

                if ((selectButton.containsKey("other") ? selectButton.get("other") : false) == true) {
                    paymentActionOrderOtherSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("other", false);
                } else {
                    paymentActionOrderOtherSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("other", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_integral_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("integral") ? selectButton.get("integral") : false) == true) {
                    paymentActionOrderIntegralSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("integral", false);
                } else {
                    paymentActionOrderIntegralSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("integral", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_cash_coupon_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false) == true) {
                    paymentActionOrderCashCouponSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("cashCoupon", false);
                } else {
                    paymentActionOrderCashCouponSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("cashCoupon", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_weixin_select:
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
                    paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("weixin", false);
                } else {
                    paymentActionOrderWeiXinSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("weixin", true);
                }
                selectTotalPrice();
                break;
            case R.id.payment_action_order_alipay_select:
                selectButton.clear();
                initSelectButton();
                if (cardListSize > 0) {
                    for (int i = 0; i < cardListSize; i++) {
                        ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                    }
                }
                if ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true) {
                    paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("alipay", false);
                } else {
                    paymentActionOrderAliPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("alipay", true);
                }
                selectTotalPrice();
                break;
            case R.id.payment_action_order_loan_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("loan") ? selectButton.get("loan") : false) == true) {
                    paymentActionOrderLoanPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("loan", false);
                } else {
                    paymentActionOrderLoanPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("loan", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            case R.id.payment_action_order_from_third_select:
                if (orderListSize > 1) {
                    selectButton.clear();
                    initSelectButton();
                    if (cardListSize > 0) {
                        for (int i = 0; i < cardListSize; i++) {
                            ((ImageButton) paymentActionOrderChildItemLinearLayout.getChildAt(i).findViewById(R.id.select_payment_action_order_card_child_button)).setBackgroundResource(R.drawable.no_select_btn);
                        }
                    }
                }
                if ((selectButton.containsKey("third") ? selectButton.get("third") : false) == true) {
                    paymentActionOrderFromThirdPaySelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("third", false);
                } else {
                    paymentActionOrderFromThirdPaySelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("third", true);
                }
                clearThirdPartPaySelect();
                selectTotalPrice();
                break;
            //将支付信息提交服务器
            case R.id.payment_action_order_pay_order:
                if (shareFlg == 1) {
                    assignPayment();
                } else {
                    boolean ischeckBenefitPersonIsNull = checkBenefitPersonIsNull();
                    if (ischeckBenefitPersonIsNull)
                        submitPaymentWhenBenefitPersonIsNull();
                    else {
                        double percenttemp = 0;
                        for (int i = 0; i < benefitpersonlinearlayout.getChildCount(); i++) {
                            EditText percentEditText = ((EditText) benefitpersonlinearlayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                            double temp = 0;
                            temp = Double.valueOf(percentEditText.getText().toString());
                            percenttemp = temp + percenttemp;
                        }
                        if (percenttemp != 100) {
                            submitPaymentWhenpersonIsoverflow();
                        } else {
                            assignPayment();
                        }
                    }
                }
                break;
            //FIXME
            case R.id.payment_benefit_person:
                Intent chooseBenefitPersonIntent2 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent2.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent2.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent2.putExtra("setBenefitPerson", true);
                chooseBenefitPersonIntent2.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent2.putExtra("customerID", customerID);
                startActivityForResult(chooseBenefitPersonIntent2, 101);
                break;
            case R.id.payment_benefit_textv:
                Intent chooseBenefitPersonIntent3 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent3.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent3.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent3.putExtra("setBenefitPerson", true);
                chooseBenefitPersonIntent3.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent3.putExtra("customerID", customerID);
                startActivityForResult(chooseBenefitPersonIntent3, 101);
                break;
            case R.id.payment_benefit_share_btn:
                if (shareFlg == 0 && !checkBenefitPersonIsNull()) {
                    shareFlg = 1;
                    setBenefitPersonInfo(mBenefitPersonIDs, mBenefitPersonNames);
                }
                break;
        }
    }

    private boolean checkBenefitPersonIsNull() {
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]") || mBenefitPersonIDs.equals("[]"))
            return true;
        else
            return false;
    }

    //确定是微信支付还是支付宝支付还是场内支付
    protected void assignPayment() {
        if (((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) || ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true)) {
            thirdPartPayment();
        } else {
            submitPayment();
        }
    }

    private void submitPaymentWhenBenefitPersonIsNull() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_payment_when_benefit_person_is_null)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                assignPayment();
                            }
                        })
                .setNegativeButton(getString(R.string.delete_cancel),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                dialog = null;
                            }
                        }).create();
        dialog.show();
        dialog.setCancelable(false);
    }

    private void submitPaymentWhenpersonIsoverflow() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_payment_when_benefit_person_is_overflow)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                assignPayment();
                            }
                        })
                .setNegativeButton(getString(R.string.delete_cancel),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                dialog = null;
                            }
                        }).create();
        dialog.show();
        dialog.setCancelable(false);
    }

    private void setsalesConsultantInfo(List<SalesConsultantRate> rateList) {
        if (rateList != null && rateList.size() > 0) {
            for (cnt_i = 0; cnt_i < rateList.size(); cnt_i++) {
                SalesConsultantRate bp = rateList.get(cnt_i);
                View salesConsultantItemView = layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                TextView salesConsultantNameText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_name);
                salesConsultantNameText.setText(bp.getSalesConsultantName());
                TextView salesConsultantPercentText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_percent);
                salesConsultantPercentText.setText(bp.getCommissionRate());
                ordersalespercentagelinearlayout.addView(salesConsultantItemView, cnt_i);
            }
        }
    }

    //FIXME
    private void setBenefitPersonInfo(String id, String name) {
        if (namegetFlg == 1) {
            mBenefitPersonIDs = id;
            mBenefitPersonNames = name;
            namegetFlg = 0;
        }
        if (shareFlg == 1) {
            if (!mBenefitPersonNames.equals(null) && !mBenefitPersonIDs.equals(null) && !mBenefitPersonNames.equals("") && !mBenefitPersonIDs.equals("")) {
                benefitpersonlinearlayout.removeAllViews();
                String[] nameArray = mBenefitPersonNames.split("、");
                for (cnt_i = 0; cnt_i < nameArray.length; cnt_i++) {
                    View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                    benefitPersonNameText.setText(nameArray[cnt_i]);
                    benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                    benefitPersonPercentText.setOnTouchListener(new View.OnTouchListener() {
                        int touch_flag = 0;

                        @Override
                        public boolean onTouch(View v, MotionEvent event) {
                            touch_flag++;
                            if (touch_flag == 2) {
                                touch_flag = 0;
                                if (shareFlg == 1) {
                                    String[] nameArray = mBenefitPersonNames.split("、");
                                    benefitpersonlinearlayout.removeAllViews();
                                    for (int j = 0; j < nameArray.length; j++) {
                                        View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                                        TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                        benefitPersonNameText.setText(nameArray[j]);
                                        EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                        TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                                        EditText[] editText = new EditText[]{benefitPersonPercentText};
                                        NumberFormatUtil.setPricePointArray(editText, 2);
                                        benefitPersonPercentText.setText(String.valueOf(0));
                                        benefitpersonlinearlayout.addView(benefitPersonItemView, j);
                                    }
                                    shareFlg = 0;
                                    return true;
                                }
                            }
                            return false;
                        }
                    });
                    TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                    EditText[] editText = new EditText[]{benefitPersonPercentText};
                    NumberFormatUtil.setPricePointArray(editText, 2);
                    benefitPersonPercentText.setText("均分");
                    benefitpersonlinearlayout.addView(benefitPersonItemView, cnt_i);
                }
            } else {
                benefitpersonlinearlayout.removeAllViews();
                shareFlg = 0;
            }
        } else {
            benefitpersonlinearlayout.removeAllViews();
            JSONArray idArray = null;
            try {
                idArray = new JSONArray(id);
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            if (idArray != null && idArray.length() > 0) {
                String[] nameArray = mBenefitPersonNames.split("、");
                for (cnt_i = 0; cnt_i < nameArray.length; cnt_i++) {
                    View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                    benefitPersonNameText.setText(nameArray[cnt_i]);
                    EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                    benefitPersonPercentText.setOnTouchListener(new View.OnTouchListener() {
                        int touch_flag = 0;

                        @Override
                        public boolean onTouch(View v, MotionEvent event) {
                            touch_flag++;
                            if (touch_flag == 2) {
                                touch_flag = 0;
                                if (shareFlg == 1) {
                                    String[] nameArray = mBenefitPersonNames.split("、");
                                    benefitpersonlinearlayout.removeAllViews();
                                    for (int j = 0; j < nameArray.length; j++) {
                                        View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                                        TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                        benefitPersonNameText.setText(nameArray[j]);
                                        EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                        TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                                        EditText[] editText = new EditText[]{benefitPersonPercentText};
                                        NumberFormatUtil.setPricePointArray(editText, 2);
                                        benefitPersonPercentText.setText(String.valueOf(0));
                                        benefitpersonlinearlayout.addView(benefitPersonItemView, j);
                                    }
                                    shareFlg = 0;
                                    return true;
                                }
                            }
                            return false;
                        }
                    });
                    TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                    EditText[] editText = new EditText[]{benefitPersonPercentText};
                    NumberFormatUtil.setPricePointArray(editText, 2);
                    benefitPersonPercentText.setText(String.valueOf("均分"));
                    benefitpersonlinearlayout.addView(benefitPersonItemView, cnt_i);
                }
                shareFlg = 1;
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK) {
            return;
        }
        if (requestCode == 101) {
            //FIXME
            namegetFlg = 1;
            setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
        }
    }

    protected void UpdateTotalSalePrice() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "UpdateTotalSalePrice";
                String endPoint = "Order";
                JSONObject updateTotalSalePriceJson = new JSONObject();
                try {
                    updateTotalSalePriceJson.put("OrderID", orderList.get(0).getOrderID());
                    updateTotalSalePriceJson.put("totalSalePrice", NumberFormatUtil.currencyFormat(shouldPayAmountEdit.getText().toString()));
                    updateTotalSalePriceJson.put("OrderObjectID", orderList.get(0).getOrderObejctID());
                    updateTotalSalePriceJson.put("UserCardNo", updateTotalSalePriceUserCardNo);
                    updateTotalSalePriceJson.put("ProductType", orderList.get(0).getProductType());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, updateTotalSalePriceJson.toString(), userinfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(3);
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
                    if (code != 1) {
                        Message msg = new Message();
                        msg.what = 11;
                        msg.arg1 = 1;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                    if (code == 1) {
                        Message msg = new Message();
                        msg.what = 10;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void thirdPartPayment() {
        int paymentMode = Constant.PAYMENT_MODE_WEIXIN;
        if ((selectButton.containsKey("weixin") ? selectButton.get("weixin") : false) == true) {
            if (thisTimePayWeiXin.getText().toString() != null && !("".equals(thisTimePayWeiXin.getText().toString())))
                totalPrice = Double.valueOf(thisTimePayWeiXin.getText().toString());
        } else if ((selectButton.containsKey("alipay") ? selectButton.get("alipay") : false) == true) {
            if (thisTimePayAli.getText().toString() != null && !("".equals(thisTimePayAli.getText().toString())))
                totalPrice = Double.valueOf(thisTimePayAli.getText().toString());
            paymentMode = Constant.PAYMENT_MODE_ALI;
        }
        //支付金额为0的不能进行支付
        if (totalPrice == 0) {
            DialogUtil.createShortDialog(PaymentActionActivity.this, "请输入支付金额!");
        }
        //支付金额大于订单应付金额
        else if (totalPrice > Double.valueOf(NumberFormatUtil.currencyFormat(String.valueOf(shouldPayAmountEdit.getText().toString())))) {
            DialogUtil.createShortDialog(PaymentActionActivity.this, "付款金额小于应付款金额!");
        } else {
            //多订单或者不能部分付的 单笔订单使用微信或者支付宝支付只能一次性付完
            if ((orderList.size() >= 1 || !isAllowedPartPay) && totalPrice != Double.valueOf(NumberFormatUtil.currencyFormat(String.valueOf(shouldPayAmountEdit.getText().toString())))) {
                DialogUtil.createShortDialog(PaymentActionActivity.this, "付款金额小于应付款金额!");
            } else {
                progressDialog = ProgressDialogUtil.createProgressDialog(this);
                JSONArray paidOrderIDsArray = new JSONArray();
                for (int i = 0; i < orderListSize; i++) {
                    paidOrderIDsArray.put(orderList.get(i).getOrderID());
                }
                Intent thirdPartPayIntent = new Intent(this, PaymentActionThirdPartActivity.class);
                thirdPartPayIntent.putExtra("customerID", customerID);
                thirdPartPayIntent.putExtra("orderID", paidOrderIDsArray.toString());
                //组装业绩参与人的JSON数组
                final JSONArray benefitDetailJsonArray = new JSONArray();
                if ((mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]")))
                    ;
                else {
                    try {
                        JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                        //FIXME
                        for (int i = 0; i < benefitpersonlinearlayout.getChildCount(); i++) {
                            EditText percentEditText = ((EditText) benefitpersonlinearlayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                            double percent = 0;
                            if (percentEditText.getText() != null && shareFlg == 0)
                                percent = Double.valueOf(percentEditText.getText().toString()) / 100;
                            JSONObject benefitJson = new JSONObject();
                            benefitJson.put("SlaveID", tmp.get(i));
                            benefitJson.put("ProfitPct", percent);
                            benefitDetailJsonArray.put(benefitJson);
                            personpercen = percent + personpercen;
                        }
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                }

                thirdPartPayIntent.putExtra("slaveID", benefitDetailJsonArray.toString());
                thirdPartPayIntent.putExtra("totalAmount", NumberFormatUtil.currencyFormat(String.valueOf(totalPrice)));
                thirdPartPayIntent.putExtra("pointAmount", NumberFormatUtil.currencyFormat(thisTimeGivePoint.getText().toString()));
                thirdPartPayIntent.putExtra("couponAmount", NumberFormatUtil.currencyFormat(thisTimeGiveCashCoupon.getText().toString()));
                thirdPartPayIntent.putExtra("remark", ((EditText) findViewById(R.id.payment_action_remark)).getText().toString());
                thirdPartPayIntent.putExtra("payFromOrderDetail", payFromOrderDetail);
                thirdPartPayIntent.putExtra("userRole", userRole);
                thirdPartPayIntent.putExtra("orderSize", orderList.size());
                thirdPartPayIntent.putExtra("paymentMode", paymentMode);
                thirdPartPayIntent.putExtra("AverageFlag", shareFlg);
                if (orderList.size() == 1) {
                    Bundle bundle = new Bundle();
                    OrderInfo orderInfo = new OrderInfo();
                    orderInfo.setOrderID(orderList.get(0).getOrderID());
                    orderInfo.setProductType(orderList.get(0).getProductType());
                    orderInfo.setOrderObejctID(orderList.get(0).getOrderObejctID());
                    bundle.putSerializable("orderInfo", orderInfo);
                    thirdPartPayIntent.putExtras(bundle);
                }
                startActivity(thirdPartPayIntent);
            }

        }
    }

    // 提交支付信息到服务器
    protected void submitPayment() {
        //支付总金额
        totalPrice = 0;
        final JSONArray paymentDetailJsonArray = new JSONArray();
        final JSONArray giveDetailJsonArray = new JSONArray();
        //多个订单合并支付
        if (orderListSize > 1) {
            for (int i = 0; i < orderListSize; i++) {
                final JSONArray thispaymentDetailJsonArray = new JSONArray();
                String thisorderpayment = orderList.get(i).getTotalPrice();
                // 获取现金支付信息
                if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false) == true) {
                    JSONObject cashPaymentJson = new JSONObject();
                    try {
                        cashPaymentJson.put("PaymentMode", 0);
                        cashPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                    } catch (JSONException e) {
                    }
                    thispaymentDetailJsonArray.put(cashPaymentJson);
                    totalPrice = Double.valueOf(thisTimePayAmountCash.getText().toString());
                }
                //获取银行卡支付信息
                if ((selectButton.containsKey("bank") ? selectButton.get("bank") : false) == true) {
                    JSONObject bankPaymentJson = new JSONObject();
                    try {

                        bankPaymentJson.put("PaymentMode", 2);
                        bankPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                    } catch (JSONException e) {
                    }
                    thispaymentDetailJsonArray.put(bankPaymentJson);
                    totalPrice = Double.valueOf(thisTimePayAmountBank.getText().toString());
                }
                //获取其他支付信息
                if ((selectButton.containsKey("other") ? selectButton.get("other") : false) == true) {
                    JSONObject otherPaymentJson = new JSONObject();
                    try {
                        otherPaymentJson.put("PaymentMode", 3);
                        otherPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                    } catch (JSONException e) {
                    }
                    thispaymentDetailJsonArray.put(otherPaymentJson);
                    totalPrice = Double.valueOf(thisTimePaymentOtherAmountText.getText().toString());
                }
                //获取消费贷款支付信息
                if ((selectButton.containsKey("loan") ? selectButton.get("loan") : false) == true) {
                    JSONObject loanPaymentJson = new JSONObject();
                    try {
                        loanPaymentJson.put("PaymentMode", 100);
                        loanPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                    } catch (JSONException e) {
                    }
                    thispaymentDetailJsonArray.put(loanPaymentJson);
                    totalPrice = Double.valueOf(thisTimePayLoan.getText().toString());
                }
                //获取第三方付款支付信息
                if ((selectButton.containsKey("third") ? selectButton.get("third") : false) == true) {
                    JSONObject thirdPaymentJson = new JSONObject();
                    try {
                        thirdPaymentJson.put("PaymentMode", 101);
                        thirdPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                    } catch (JSONException e) {
                    }
                    thispaymentDetailJsonArray.put(thirdPaymentJson);
                    totalPrice = Double.valueOf(thisTimePayFromThird.getText().toString());
                }
                //获取积分支付信息和赠送积分信息
                int integral = 0;
                int cashCoupon = 0;
                final JSONArray thisgiveDetailJsonArray = new JSONArray();
                for (int j = 0; j < ecardInfoListSize; j++) {
                    if (ecardInfoList.get(j).getUserEcardType() == 2 && integral == 0) {
                        integral++;
                        //积分兑换
                        if ((selectButton.containsKey("integral") ? selectButton.get("integral") : false) == true) {
                            if (useIntegralpaidOrderTotalPrice > 0) {
                                JSONObject integralPaymentJson = new JSONObject();
                                try {
                                    integralPaymentJson.put("UserCardNo", ecardInfoList.get(j).getUserEcardNo());
                                    integralPaymentJson.put("CardType", 2);
                                    integralPaymentJson.put("PaymentMode", 6);
                                    integralPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                                } catch (JSONException e) {
                                }
                                thispaymentDetailJsonArray.put(integralPaymentJson);
                                totalPrice = Double.valueOf(paymentActionOrderIntegralEdit22.getText().toString());
                            }
                        }

                        //赠送积分
                        if (thisTimeGivePoint.getText().toString() != null && !(("").equals(thisTimeGivePoint.getText().toString())) && Double.valueOf(thisTimeGivePoint.getText().toString()) != 0) {
                            JSONObject giveIntegralPaymentJson = new JSONObject();
                            try {
                                giveIntegralPaymentJson.put("UserCardNo", ecardInfoList.get(j).getUserEcardNo());
                                giveIntegralPaymentJson.put("CardType", 2);
                                giveIntegralPaymentJson.put("PaymentMode", 6);
                                giveIntegralPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(thisorderpayment) * Double.valueOf(integralPresentRate))));
                            } catch (JSONException e) {
                            }
                            thisgiveDetailJsonArray.put(giveIntegralPaymentJson);
                        }
                    }
                    if (ecardInfoList.get(j).getUserEcardType() == 3 && cashCoupon == 0) {
                        cashCoupon++;
                        //现金券兑换
                        if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false) == true) {
                            if (useCashCouponpaidOrderTotalPrice > 0) {
                                JSONObject cashCouponPaymentJson = new JSONObject();
                                try {
                                    cashCouponPaymentJson.put("UserCardNo", ecardInfoList.get(j).getUserEcardNo());
                                    cashCouponPaymentJson.put("CardType", 3);
                                    cashCouponPaymentJson.put("PaymentMode", 7);
                                    cashCouponPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                                } catch (JSONException e) {
                                }
                                thispaymentDetailJsonArray.put(cashCouponPaymentJson);
                                totalPrice = Double.valueOf(paymentActionOrderCashCouponEdit22.getText().toString());
                            }
                        }

                        //赠送现金券
                        if (thisTimeGiveCashCoupon.getText().toString() != null && !(("").equals(thisTimeGiveCashCoupon.getText().toString())) && Double.valueOf(thisTimeGiveCashCoupon.getText().toString()) != 0) {
                            JSONObject giveCashCouponPaymentJson = new JSONObject();
                            try {
                                giveCashCouponPaymentJson.put("UserCardNo", ecardInfoList.get(j).getUserEcardNo());
                                giveCashCouponPaymentJson.put("CardType", 3);
                                giveCashCouponPaymentJson.put("PaymentMode", 7);
                                giveCashCouponPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(String.valueOf(Double.valueOf(thisorderpayment) * Double.valueOf(integralPresentRate))));
                            } catch (JSONException e) {
                            }
                            thisgiveDetailJsonArray.put(giveCashCouponPaymentJson);
                        }
                    }
                }
                giveDetailJsonArray.put(thisgiveDetailJsonArray);
                //储值卡
                for (int j = 0; j < cardListSize; j++) {
                    final String cardChild = "cardChild" + j;
                    if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false) == true) {
                        View view = paymentActionOrderChildItemLinearLayout.findViewWithTag(j);
                        String cardString = ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).getText().toString();
                        JSONObject cardPaymentJson = new JSONObject();
                        if (cardString != null && !(("").equals(cardString)) && Double.parseDouble(cardString) > 0) {
                            try {
                                cardPaymentJson.put("UserCardNo", cardList.get(j).getUserEcardNo());
                                cardPaymentJson.put("CardType", 1);
                                cardPaymentJson.put("PaymentMode", 1);
                                cardPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisorderpayment));
                            } catch (JSONException e) {
                            }
                            thispaymentDetailJsonArray.put(cardPaymentJson);
                            totalPrice = Double.valueOf(cardString);
                        }
                    }
                }
                paymentDetailJsonArray.put(thispaymentDetailJsonArray);
            }
        } else {
            // 现金
            String paymentAmountCash = thisTimePayAmountCash.getText().toString();
            // 银行卡
            String paymentAmountBank = thisTimePayAmountBank.getText().toString();
            // 其他支付
            String paymentAmountOther = thisTimePaymentOtherAmountText.getText().toString();
            //消费贷款支付
            String paymentAmountLoan = thisTimePayLoan.getText().toString();
            //第三方付款支付
            String paymentAmountFromThird = thisTimePayFromThird.getText().toString();
            //获取现金支付信息
            if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false) == true) {
                if (paymentAmountCash != null && !(("").equals(paymentAmountCash)) && Double.valueOf(paymentAmountCash) != 0) {
                    JSONObject cashPaymentJson = new JSONObject();
                    try {

                        cashPaymentJson.put("PaymentMode", 0);
                        cashPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentAmountCash));
                    } catch (JSONException e) {
                    }
                    paymentDetailJsonArray.put(cashPaymentJson);
                    totalPrice = totalPrice + Double.valueOf(paymentAmountCash);
                }
            }
            //获取银行卡支付信息
            if ((selectButton.containsKey("bank") ? selectButton.get("bank") : false) == true) {
                if (paymentAmountBank != null && !(("").equals(paymentAmountBank)) && Double.valueOf(paymentAmountBank) != 0) {
                    JSONObject bankPaymentJson = new JSONObject();
                    try {

                        bankPaymentJson.put("PaymentMode", 2);
                        bankPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentAmountBank));
                    } catch (JSONException e) {
                    }
                    paymentDetailJsonArray.put(bankPaymentJson);
                    totalPrice = totalPrice + Double.valueOf(paymentAmountBank);
                }
            }
            //获取其他支付信息
            if ((selectButton.containsKey("other") ? selectButton.get("other") : false) == true) {
                if (paymentAmountOther != null && !(("").equals(paymentAmountOther)) && Double.valueOf(paymentAmountOther) != 0) {
                    JSONObject otherPaymentJson = new JSONObject();
                    try {

                        otherPaymentJson.put("PaymentMode", 3);
                        otherPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentAmountOther));
                    } catch (JSONException e) {
                    }
                    paymentDetailJsonArray.put(otherPaymentJson);
                    totalPrice = totalPrice + Double.valueOf(paymentAmountOther);
                }
            }
            //获取消费贷款支付信息
            if ((selectButton.containsKey("loan") ? selectButton.get("loan") : false) == true) {
                if (paymentAmountLoan != null && !(("").equals(paymentAmountLoan)) && Double.valueOf(paymentAmountLoan) != 0) {
                    JSONObject loanPaymentJson = new JSONObject();
                    try {
                        loanPaymentJson.put("PaymentMode", 100);
                        loanPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentAmountLoan));
                    } catch (JSONException e) {
                    }
                    paymentDetailJsonArray.put(loanPaymentJson);
                    totalPrice = totalPrice + Double.valueOf(paymentAmountLoan);
                }
            }
            //获取第三方付款支付信息
            if ((selectButton.containsKey("third") ? selectButton.get("third") : false) == true) {
                if (paymentAmountFromThird != null && !(("").equals(paymentAmountFromThird)) && Double.valueOf(paymentAmountFromThird) != 0) {
                    JSONObject thirdPaymentJson = new JSONObject();
                    try {
                        thirdPaymentJson.put("PaymentMode", 101);
                        thirdPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentAmountFromThird));
                    } catch (JSONException e) {
                    }
                    paymentDetailJsonArray.put(thirdPaymentJson);
                    totalPrice = totalPrice + Double.valueOf(paymentAmountFromThird);
                }
            }

            int integral = 0;
            int cashCoupon = 0;
            for (int i = 0; i < ecardInfoListSize; i++) {
                if (ecardInfoList.get(i).getUserEcardType() == 2 && integral == 0) {
                    integral++;
                    //积分兑换
                    if ((selectButton.containsKey("integral") ? selectButton.get("integral") : false) == true) {
                        if (useIntegralpaidOrderTotalPrice > 0) {
                            JSONObject integralPaymentJson = new JSONObject();
                            try {
                                integralPaymentJson.put("UserCardNo", ecardInfoList.get(i).getUserEcardNo());
                                integralPaymentJson.put("CardType", 2);
                                integralPaymentJson.put("PaymentMode", 6);
                                integralPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentActionOrderIntegralEdit22.getText().toString()));
                            } catch (JSONException e) {
                            }
                            paymentDetailJsonArray.put(integralPaymentJson);
                            totalPrice = totalPrice + useIntegralpaidOrderTotalPrice;
                        }
                    }
                    //赠送积分
                    if (thisTimeGivePoint.getText().toString() != null && !(("").equals(thisTimeGivePoint.getText().toString())) && Double.valueOf(thisTimeGivePoint.getText().toString()) != 0) {
                        JSONObject giveIntegralPaymentJson = new JSONObject();
                        try {
                            giveIntegralPaymentJson.put("UserCardNo", ecardInfoList.get(i).getUserEcardNo());
                            giveIntegralPaymentJson.put("CardType", 2);
                            giveIntegralPaymentJson.put("PaymentMode", 6);
                            giveIntegralPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisTimeGivePoint.getText().toString()));
                        } catch (JSONException e) {
                        }
                        giveDetailJsonArray.put(giveIntegralPaymentJson);
                    }
                }

                if (ecardInfoList.get(i).getUserEcardType() == 3 && cashCoupon == 0) {
                    cashCoupon++;
                    //现金券兑换
                    if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false) == true) {
                        if (useCashCouponpaidOrderTotalPrice > 0) {
                            JSONObject cashCouponPaymentJson = new JSONObject();
                            try {
                                cashCouponPaymentJson.put("UserCardNo", ecardInfoList.get(i).getUserEcardNo());
                                cashCouponPaymentJson.put("CardType", 3);
                                cashCouponPaymentJson.put("PaymentMode", 7);
                                cashCouponPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(paymentActionOrderCashCouponEdit22.getText().toString()));
                            } catch (JSONException e) {
                            }
                            paymentDetailJsonArray.put(cashCouponPaymentJson);
                            totalPrice = totalPrice + useCashCouponpaidOrderTotalPrice;
                        }
                    }

                    //赠送现金券
                    if (thisTimeGiveCashCoupon.getText().toString() != null && !(("").equals(thisTimeGiveCashCoupon.getText().toString())) && Double.valueOf(thisTimeGiveCashCoupon.getText().toString()) != 0) {
                        JSONObject giveCashCouponPaymentJson = new JSONObject();
                        try {
                            giveCashCouponPaymentJson.put("UserCardNo", ecardInfoList.get(i).getUserEcardNo());
                            giveCashCouponPaymentJson.put("CardType", 3);
                            giveCashCouponPaymentJson.put("PaymentMode", 7);
                            giveCashCouponPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(thisTimeGiveCashCoupon.getText().toString()));
                        } catch (JSONException e) {
                        }
                        giveDetailJsonArray.put(giveCashCouponPaymentJson);
                    }
                }
            }
            for (int i = 0; i < cardListSize; i++) {
                final String cardChild = "cardChild" + i;
                if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false) == true) {
                    View view = paymentActionOrderChildItemLinearLayout.findViewWithTag(i);
                    String cardString = ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).getText().toString();
                    JSONObject cardPaymentJson = new JSONObject();
                    if (cardString != null && !(("").equals(cardString)) && Double.parseDouble(cardString) > 0) {
                        try {
                            cardPaymentJson.put("UserCardNo", cardList.get(i).getUserEcardNo());
                            cardPaymentJson.put("CardType", 1);
                            cardPaymentJson.put("PaymentMode", 1);
                            cardPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(cardString));
                        } catch (JSONException e) {
                        }
                        paymentDetailJsonArray.put(cardPaymentJson);
                        totalPrice = totalPrice + Double.valueOf(cardString);
                    }
                }
            }
        }
        final JSONArray paidOrderIDsArray = new JSONArray();
        if (orderListSize > 1) {
            for (int i = 0; i < orderListSize; i++) {
                final JSONArray thispaidOrderIDsArray = new JSONArray();
                thispaidOrderIDsArray.put(orderList.get(i).getOrderID());
                paidOrderIDsArray.put(thispaidOrderIDsArray);
            }
        } else {
            for (int i = 0; i < orderListSize; i++) {
                paidOrderIDsArray.put(orderList.get(i).getOrderID());
            }
        }
        // 支付备注
        final String paymentRemark = ((EditText) findViewById(R.id.payment_action_remark))
                .getText().toString();

        if (totalPrice == 0) {
            DialogUtil.createShortDialog(PaymentActionActivity.this, "请输入支付金额!");
        } else {
            if (Integer.parseInt(paidOrderCountText.getText().toString()) < 2 || isAllowedPartPay) {
                submitStrParam(paidOrderIDsArray, paymentRemark, paymentDetailJsonArray, giveDetailJsonArray);
            } else {
                if (totalPrice != Double.valueOf(NumberFormatUtil.currencyFormat(String.valueOf(shouldPayAmountEdit.getText().toString())))) {
                    DialogUtil.createShortDialog(PaymentActionActivity.this, "付款金额小于应付款金额!");
                } else {
                    submitStrParam(paidOrderIDsArray, paymentRemark, paymentDetailJsonArray, giveDetailJsonArray);
                }
            }
        }
    }

    private void submitStrParam(final JSONArray paidOrderIDsArray, final String paymentRemark, final JSONArray paymentDetailJsonArray, final JSONArray giveDetailJsonArray) {
        //组装业绩参与人的JSON数组
        final JSONArray benefitDetailJsonArray = new JSONArray();
        if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]"))
            ;
        else {
            try {
                JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                //FIXME
                for (int i = 0; i < benefitpersonlinearlayout.getChildCount(); i++) {
                    EditText percentEditText = ((EditText) benefitpersonlinearlayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                    double percent = 0;
                    if (percentEditText.getText() != null && shareFlg == 0)
                        percent = Double.valueOf(percentEditText.getText().toString()) / 100;
                    JSONObject benefitJson = new JSONObject();
                    benefitJson.put("SlaveID", tmp.get(i));
                    benefitJson.put("ProfitPct", percent);
                    benefitDetailJsonArray.put(benefitJson);
                    personpercen = percent + personpercen;
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "AddPayment";
                String endPoint = "Payment";
                JSONArray addPaymentJsonarray = new JSONArray();
                JSONObject addPaymentJson = new JSONObject();
                if (orderListSize > 1) {
                    for (int i = 0; i < orderListSize; i++) {
                        JSONObject addPaymentJsonObject = new JSONObject();
                        try {
                            addPaymentJsonObject.put("CustomerID", customerID);
                            addPaymentJsonObject.put("OrderIDList", paidOrderIDsArray.get(i));
                            addPaymentJsonObject.put("OrderCount", 1);
                            addPaymentJsonObject.put("TotalPrice", NumberFormatUtil.currencyFormat(String.valueOf(orderList.get(i).getTotalPrice())));
                            addPaymentJsonObject.put("Remark", paymentRemark);
                            addPaymentJsonObject.put("PaymentDetailList", paymentDetailJsonArray.get(i));
                            addPaymentJsonObject.put("GiveDetailList", giveDetailJsonArray.get(i));
                            addPaymentJsonObject.put("Slavers", benefitDetailJsonArray);
                            addPaymentJsonObject.put("AverageFlag", shareFlg);
                            addPaymentJsonarray.put(addPaymentJsonObject);
                        } catch (JSONException e) {
                        }
                    }
                } else {
                    JSONObject addPaymentJsonObject = new JSONObject();
                    try {
                        addPaymentJsonObject.put("CustomerID", customerID);
                        addPaymentJsonObject.put("OrderIDList", paidOrderIDsArray);
                        addPaymentJsonObject.put("OrderCount", Integer.parseInt(paidOrderCountText.getText().toString()));
                        addPaymentJsonObject.put("TotalPrice", NumberFormatUtil.currencyFormat(String.valueOf(totalPrice)));
                        addPaymentJsonObject.put("Remark", paymentRemark);
                        addPaymentJsonObject.put("PaymentDetailList", paymentDetailJsonArray);
                        addPaymentJsonObject.put("GiveDetailList", giveDetailJsonArray);
                        addPaymentJsonObject.put("Slavers", benefitDetailJsonArray);
                        addPaymentJsonObject.put("AverageFlag", shareFlg);
                        addPaymentJsonarray.put(addPaymentJsonObject);
                    } catch (JSONException e) {
                    }
                }
                try {
                    addPaymentJson.put("PaymentAddOperationList", addPaymentJsonarray);
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addPaymentJson.toString(), userinfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(3);
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
                        mHandler.sendEmptyMessage(1);
                    }
                    //如果得到服务器返回时订单金融和已支付金额不一致，
                    else if (code == 5) {
                        Message msg = new Message();
                        msg.what = 8;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                    //有部分订单已被完全支付掉了 则跳转到相应的订单页面
                    else if (code == 2) {
                        Message msg = new Message();
                        msg.what = 9;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message msg = new Message();
                        msg.what = 0;
                        msg.obj = serverMessage;
                        mHandler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        //退出
        if ((Intent.FLAG_ACTIVITY_CLEAR_TOP & intent.getFlags()) != 0) {
            finish();
        }
    }

    @Override
    protected void onDestroy() {
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

    private void initEditText() {
        // 消费贷款
        thisTimePayLoan.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 第三方付款
        thisTimePayFromThird.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 支付宝支付
        thisTimePayAli.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 微信支付
        thisTimePayWeiXin.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 其他支付
        thisTimePaymentOtherAmountText.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 现金
        thisTimePayAmountCash.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 银行卡
        thisTimePayAmountBank.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 积分
        paymentActionOrderIntegralText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 现金券
        paymentActionOrderCashCouponText24.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 使用现金券
        paymentActionOrderCashCouponEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
        // 使用积分edit
        paymentActionOrderIntegralEdit22.setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
    }
}
