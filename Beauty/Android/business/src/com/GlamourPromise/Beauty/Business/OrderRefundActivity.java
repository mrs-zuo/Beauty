package com.GlamourPromise.Beauty.Business;

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
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BenefitPerson;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.EcardInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.PaymentDetailIssues;
import com.GlamourPromise.Beauty.bean.PaymentRecordDetail;
import com.GlamourPromise.Beauty.bean.RefundInfo;
import com.GlamourPromise.Beauty.bean.SalesConsultantRate;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SuppressLint({"ResourceType", "ClickableViewAccessibility"})
public class OrderRefundActivity extends BaseActivity implements OnClickListener {
    private OrderRefundActivityHandler mHandler = new OrderRefundActivityHandler(this);
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userInfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private int orderID, customerID;
    private RefundInfo refundInfo;
    private LinearLayout orderPaymentDetailLinearlayout, refundSalesPercentageLinearlayout;
    private LayoutInflater layoutInflater;
    private LinearLayout refundEcardLinearLayout;
    private Button pointAndCouponBalanceButton;
    private ImageButton refundActionCashSelect;
    private EditText refundActionCashEditText;
    private ImageButton refundActionOtherSelect;
    private EditText refundActionOtherEditText;
    private ImageButton refundActionPointSelect;
    private EditText refundActionPointEditText;
    private ImageButton refundActionCashCouponSelect;
    private EditText refundActionCashCouponEditText;
    private ImageButton refundActionPointPresentSelect;
    private ImageButton refundActionCashCouponPresentSelect;
    Map<String, Boolean> selectButton = new HashMap<String, Boolean>();
    private double refundTotalPrice = 0, refundCashTotalPrice = 0, refundOtherTotalPrice = 0, refundPointTotalPrice = 0, refundCashCouponTotalPrice = 0, refundECardpaidOrderTotalPrice = 0;
    private String mBenefitPersonIDs;
    private String mBenefitPersonNames;
    private TextView mTvBenefitPerson, refundBenefitSharePrice;
    private Button refundActionOKBtn;
    private String pointRate = "0", givePointRate = "0";
    private String cashCouponRate = "0", giveCashCouponRate = "0";
    private TextView pointValueText, cashCouponValueText, thisTimepayment_benefit_share_btn;
    private int productType;
    private TableLayout orderRefundSlaverTablelayout;
    // 业绩参与人数
    private Integer benefitPersonItemCnt = 0;
    // 业绩参与者view起始位置
    private int benefitPersonStartPos;
    private int shareFlg = 0, namegetFlg = 0, cnt_i, changeFlg = 0;
    private boolean isComissionCalc = true;
    private double consultantrateamount, refundrate, refundActionShouldRefundAmount, refundActionGiveRefundAmount;
    private List<BenefitPerson> benefitPersonList;
    private List<SalesConsultantRate> salesConsultantRateList;
    private int totalcnt;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class OrderRefundActivityHandler extends Handler {
        private final OrderRefundActivity orderRefundActivity;

        private OrderRefundActivityHandler(OrderRefundActivity activity) {
            WeakReference<OrderRefundActivity> weakReference = new WeakReference<OrderRefundActivity>(activity);
            orderRefundActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (orderRefundActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (orderRefundActivity.progressDialog != null) {
                orderRefundActivity.progressDialog.dismiss();
                orderRefundActivity.progressDialog = null;
            }
            if (orderRefundActivity.requestWebServiceThread != null) {
                orderRefundActivity.requestWebServiceThread.interrupt();
                orderRefundActivity.requestWebServiceThread = null;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(orderRefundActivity, "您的网络貌似不给力，请重试");
            } else if (msg.what == 2) {
                DialogUtil.createShortDialog(orderRefundActivity, (String) msg.obj);
            } else if (msg.what == 1) {
                String currency = orderRefundActivity.userInfoApplication.getAccountInfo().getCurrency();
                ((TextView) orderRefundActivity.findViewById(R.id.refund_action_should_refund_amount)).setText(currency + NumberFormatUtil.currencyFormat(String.valueOf(orderRefundActivity.refundInfo.getRefundAmount())));
                ((TextView) orderRefundActivity.findViewById(R.id.refund_action_give_point_value)).setText(NumberFormatUtil.currencyFormat(String.valueOf(0)));
                ((TextView) orderRefundActivity.findViewById(R.id.refund_action_give_cash_value)).setText(currency + NumberFormatUtil.currencyFormat(String.valueOf(0)));
                orderRefundActivity.refundBenefitSharePrice = (TextView) orderRefundActivity.findViewById(R.id.refund_benefit_share_price);
                orderRefundActivity.refundBenefitSharePrice.setText(orderRefundActivity.userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(0)));
                List<PaymentRecordDetail> paymentRecordDetailList = orderRefundActivity.refundInfo.getPaymentRecordDetailList();
                orderRefundActivity.orderPaymentDetailLinearlayout = (LinearLayout) orderRefundActivity.findViewById(R.id.order_payment_detail_linearlayout);
                orderRefundActivity.layoutInflater = LayoutInflater.from(orderRefundActivity);
                //销售顾问
                orderRefundActivity.refundSalesPercentageLinearlayout = (LinearLayout) orderRefundActivity.findViewById(R.id.refund_sales_percentage_linearlayout);
                if (orderRefundActivity.salesConsultantRateList != null && orderRefundActivity.salesConsultantRateList.size() > 0) {
                    orderRefundActivity.setsalesConsultantInfo(orderRefundActivity.salesConsultantRateList);
                }
                TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
                lp.topMargin = 20;
                lp.leftMargin = 10;
                lp.rightMargin = 10;
                //显示该订单的已经支付的信息
                if (paymentRecordDetailList != null && paymentRecordDetailList.size() > 0) {
                    for (int i = 0; i < paymentRecordDetailList.size(); i++) {
                        final PaymentRecordDetail paymentRecordDetail = paymentRecordDetailList.get(i);
                        final View orderPaymentDetailItem = orderRefundActivity.layoutInflater.inflate(R.xml.order_payment_detail_item, null);
                        orderPaymentDetailItem.setLayoutParams(lp);
                        final TableLayout orderPaymentDetailTableLayout = (TableLayout) orderPaymentDetailItem.findViewById(R.id.order_payment_detail_tablelayout);
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_code_text)).setText(paymentRecordDetail.getPaymentRecordDetailCode());
                        final ImageView orderPaymentDetailUpDownIcon = (ImageView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_up_down_icon);
                        orderPaymentDetailUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);

                        orderPaymentDetailItem.findViewById(R.id.payment_record_detail_code_text).setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                if ((Boolean) orderPaymentDetailTableLayout.getTag()) {
                                    for (int j = 0; j < orderPaymentDetailTableLayout.getChildCount(); j++) {
                                        if (j != 0)
                                            orderPaymentDetailTableLayout.getChildAt(j).setVisibility(View.GONE);
                                        orderPaymentDetailTableLayout.setTag(false);
                                        orderPaymentDetailUpDownIcon.setBackgroundResource(R.drawable.report_main_down_icon);
                                    }
                                } else {
                                    for (int j = 0; j < orderPaymentDetailTableLayout.getChildCount(); j++) {
                                        if (j != 0)
                                            orderPaymentDetailTableLayout.getChildAt(j).setVisibility(View.VISIBLE);
                                        orderPaymentDetailTableLayout.setTag(true);
                                        orderPaymentDetailUpDownIcon.setBackgroundResource(R.drawable.report_main_up_icon);
                                        String paymentRecordDetailRemark = paymentRecordDetail.getPaymentRecordDetailRemark();
                                        if (paymentRecordDetailRemark == null || ("").equals(paymentRecordDetailRemark)) {
                                            orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_divide_view).setVisibility(View.GONE);
                                            orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_relativelayout).setVisibility(View.GONE);
                                        } else {
                                            ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_text)).setText(paymentRecordDetailRemark);
                                        }
                                    }
                                }
                            }
                        });
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_date_text)).setText(paymentRecordDetail.getPaymentRecordDetailDate());
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_branch_name_text)).setText(paymentRecordDetail.getPaymentRecordDetailBranchName());
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_type_name_text)).setText(paymentRecordDetail.getPaymentRecordDetailTypeName());
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_operator_text)).setText(paymentRecordDetail.getPaymentRecordDetailOperator());
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_amount_text)).setText(currency + NumberFormatUtil.currencyFormat(paymentRecordDetail.getPaymentRecordDetailAmount()));
                        LinearLayout paymentDetailIssuesLinearlayout = (LinearLayout) orderPaymentDetailItem.findViewById(R.id.payment_detail_issues_linearlayout);

                        double orderrefundprice = Double.parseDouble(paymentRecordDetail.getPaymentRecordDetailAmount());
                        if (paymentRecordDetail.getPdiList() != null && paymentRecordDetail.getPdiList().size() > 0) {
                            for (int j = 0; j < paymentRecordDetail.getPdiList().size(); j++) {
                                PaymentDetailIssues pdi = paymentRecordDetail.getPdiList().get(j);
                                View paymentDetailIssuesView = orderRefundActivity.layoutInflater.inflate(R.xml.payment_detail_issues, null);
                                TextView cardNameText = (TextView) paymentDetailIssuesView.findViewById(R.id.payment_detail_issues_card_name);
                                TextView cardPaymentAmountText = (TextView) paymentDetailIssuesView.findViewById(R.id.payment_detail_issues_card_paid_amount);
                                View cardPaymentDivideView = paymentDetailIssuesView.findViewById(R.id.payment_detail_issues_divide_view);
                                if (j == paymentRecordDetail.getPdiList().size() - 1)
                                    cardPaymentDivideView.setVisibility(View.GONE);
                                cardNameText.setText(pdi.getCardName());
                                //除电子会员卡以外
                                if (pdi.getCardType() == 0)
                                    cardPaymentAmountText.setText(currency + NumberFormatUtil.currencyFormat(pdi.getPaymentAmount()));
                                    //储值卡
                                else if (pdi.getCardType() == 1)
                                    cardPaymentAmountText.setText(currency + NumberFormatUtil.currencyFormat(pdi.getPaymentAmount()));
                                    //积分卡
                                else if (pdi.getCardType() == 2) {
                                    cardPaymentAmountText.setText(NumberFormatUtil.currencyFormat(pdi.getCardPaidAmount()) + "抵" + currency + NumberFormatUtil.currencyFormat(pdi.getPaymentAmount()));
                                    orderrefundprice = orderrefundprice - Double.valueOf(pdi.getCardPaidAmount());
                                }
                                //现金券
                                else if (pdi.getCardType() == 3) {
                                    cardPaymentAmountText.setText(currency + NumberFormatUtil.currencyFormat(pdi.getCardPaidAmount()) + "抵" + currency + NumberFormatUtil.currencyFormat(pdi.getPaymentAmount()));
                                    orderrefundprice = orderrefundprice - Double.valueOf(pdi.getCardPaidAmount());
                                }
                                paymentDetailIssuesLinearlayout.addView(paymentDetailIssuesView);
                            }
                        }
                        List<SalesConsultantRate> rateList = paymentRecordDetail.getConsultantList();
                        List<BenefitPerson> profitList = paymentRecordDetail.getProfitList();
                        if (!orderRefundActivity.isComissionCalc) {
                            ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_relativelayout)).setVisibility(View.GONE);
                            ((View) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_view)).setVisibility(View.GONE);
                            ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_relativelayout)).setVisibility(View.GONE);
                            ((View) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_view)).setVisibility(View.GONE);
                            ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_relativelayout)).setVisibility(View.GONE);
                            ((View) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_view)).setVisibility(View.GONE);
                        } else {

                            //业绩参与金额
                            double thistimerefundprice = orderrefundprice - orderrefundprice * orderRefundActivity.consultantrateamount;
                            ((TextView) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_text)).setText(currency + NumberFormatUtil.currencyFormat(String.valueOf(thistimerefundprice)));

                            //业绩参与人业绩比例
                            orderRefundActivity.totalcnt = 5;
                            if (profitList == null || profitList.size() == 0) {
                                ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_text)).setText("无");
                            } else {
                                for (int j = 0; j < profitList.size(); j++) {
                                    BenefitPerson bp = profitList.get(j);
                                    View benefitPersonItemView = orderRefundActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                                    benefitPersonItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
                                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                    benefitPersonNameText.setText(bp.getAccountName());
                                    TextView benefitPersonPercentText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                    benefitPersonPercentText.setText(bp.getProfitPct());
                                    orderPaymentDetailTableLayout.addView(benefitPersonItemView, orderPaymentDetailTableLayout.getChildCount() - 3);
                                    orderRefundActivity.totalcnt++;
                                }
                            }

                            //销售顾问业绩比例
                            if (rateList == null || rateList.size() == 0)
                                ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_text)).setText("无");
                            else {
                                for (int j = 0; j < rateList.size(); j++) {
                                    SalesConsultantRate bp = rateList.get(j);
                                    View salesConsultantItemView = orderRefundActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                                    salesConsultantItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
                                    TextView salesConsultantNameText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_name);
                                    salesConsultantNameText.setText(bp.getSalesConsultantName());
                                    TextView salesConsultantPercentText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_percent);
                                    salesConsultantPercentText.setText(bp.getCommissionRate());
                                    orderPaymentDetailTableLayout.addView(salesConsultantItemView, orderPaymentDetailTableLayout.getChildCount() - (orderRefundActivity.totalcnt + 2));
                                }
                            }
                        }

                        for (int j = 0; j < orderPaymentDetailTableLayout.getChildCount(); j++) {
                            if (j != 0)
                                orderPaymentDetailTableLayout.getChildAt(j).setVisibility(View.GONE);
                            orderPaymentDetailTableLayout.setTag(false);
                        }
                        orderRefundActivity.orderPaymentDetailLinearlayout.addView(orderPaymentDetailItem);
                    }
                }
                List<EcardInfo> userEcardInfoList = new ArrayList<EcardInfo>();

                for (EcardInfo ecardInfo : orderRefundActivity.refundInfo.getEcardInfoList()) {
                    //除了积分和现金券之外的储值会员卡
                    if (ecardInfo.getUserEcardType() == 1)
                        userEcardInfoList.add(ecardInfo);
                }
                //展示该订单顾客的电子会员卡
                int userEcardInfoSize = userEcardInfoList.size();
                if (userEcardInfoSize > 0) {
                    for (int i = 0; i < userEcardInfoSize; i++) {
                        final int cardChildIndex = i;
                        final View refundActionOrderChildItemView = orderRefundActivity.layoutInflater.inflate(R.xml.payment_action_order_child_item, null);
                        final ImageButton selectRefundActionOrderCardChildButton = (ImageButton) refundActionOrderChildItemView.findViewById(R.id.select_payment_action_order_card_child_button);
                        EditText ecardChildAmountEditText = (EditText) refundActionOrderChildItemView.findViewById(R.id.payment_action_order_card_child_edit);
                        ecardChildAmountEditText.setHint("请输入退款金额");
                        final String cardChild = "cardChild" + i;
                        selectRefundActionOrderCardChildButton.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                // TODO Auto-generated method stub
                                if ((orderRefundActivity.selectButton.containsKey(cardChild) ? orderRefundActivity.selectButton.get(cardChild) : false)) {
                                    selectRefundActionOrderCardChildButton.setBackgroundResource(R.drawable.no_select_btn);
                                    orderRefundActivity.selectButton.put(cardChild, false);
                                } else {
                                    selectRefundActionOrderCardChildButton.setBackgroundResource(R.drawable.select_btn);
                                    orderRefundActivity.selectButton.put(cardChild, true);
                                }
                                orderRefundActivity.selectTotalPrice();
                            }
                        });
                        ecardChildAmountEditText.addTextChangedListener(new TextWatcher() {

                            @Override
                            public void onTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) {
                                // TODO Auto-generated method stub

                            }

                            @Override
                            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
                                                          int arg3) {
                                // TODO Auto-generated method stub

                            }

                            @Override
                            public void afterTextChanged(Editable arg0) {
                                // TODO Auto-generated method stub
                                orderRefundActivity.selectTotalPrice();
                            }
                        });
                        TextView paymentActionOrderCardChildText = (TextView) refundActionOrderChildItemView.findViewById(R.id.payment_action_order_card_child_text);
                        final EditText paymentActionOrderCardChildEdit = (EditText) refundActionOrderChildItemView.findViewById(R.id.payment_action_order_card_child_edit);
                        NumberFormatUtil.setPricePoint(paymentActionOrderCardChildEdit, 2);
                        Button thisTimePayAmountCardChildAll = (Button) refundActionOrderChildItemView.findViewById(R.id.this_time_pay_amount_card_child_all);
                        thisTimePayAmountCardChildAll.setVisibility(View.GONE);
                        paymentActionOrderCardChildText.setText(userEcardInfoList.get(i).getUserEcardName());
                        refundActionOrderChildItemView.setTag(cardChildIndex);
                        orderRefundActivity.refundEcardLinearLayout.addView(refundActionOrderChildItemView);
                    }
                }
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(orderRefundActivity, orderRefundActivity.getString(R.string.login_error_message));
                orderRefundActivity.userInfoApplication.exitForLogin(orderRefundActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + orderRefundActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(orderRefundActivity);
                orderRefundActivity.packageUpdateUtil = new PackageUpdateUtil(orderRefundActivity, orderRefundActivity.mHandler, fileCache, downloadFileUrl, false, orderRefundActivity.userInfoApplication);
                orderRefundActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                orderRefundActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = orderRefundActivity.getFileStreamPath(filename);
                file.getName();
                orderRefundActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            //退款成功
            else if (msg.what == 6) {
                DialogUtil.createShortDialog(orderRefundActivity, "退款成功!");
                orderRefundActivity.finish();
            } else {
                DialogUtil.createShortDialog(orderRefundActivity, "服务器异常，请重试");
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_order_refund_action);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        refundEcardLinearLayout = (LinearLayout) findViewById(R.id.refund_action_order_child_item_linearlayout);
        pointAndCouponBalanceButton = (Button) findViewById(R.id.point_and_cash_coupon_balance_btn);
        pointAndCouponBalanceButton.setOnClickListener(this);
        orderRefundSlaverTablelayout = (TableLayout) findViewById(R.id.order_refund_slaver_tablelayout);
        benefitPersonStartPos = orderRefundSlaverTablelayout.indexOfChild(findViewById(R.id.refund_benefit_person_layout)) + 1;

        //退款到哪些账户的选择按钮
        refundActionCashSelect = (ImageButton) findViewById(R.id.refund_action_order_cash_select);
        refundActionCashEditText = (EditText) findViewById(R.id.this_time_refund_amount_cash);
        refundActionCashEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                selectTotalPrice();
            }
        });
        refundActionCashSelect.setOnClickListener(this);
        refundActionOtherSelect = (ImageButton) findViewById(R.id.refund_action_order_other_select);
        refundActionOtherEditText = (EditText) findViewById(R.id.this_time_refund_amount_other);
        refundActionOtherEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                selectTotalPrice();
            }
        });
        refundActionOtherSelect.setOnClickListener(this);
        refundActionPointSelect = (ImageButton) findViewById(R.id.refund_action_order_point_select);
        refundActionPointEditText = (EditText) findViewById(R.id.refund_action_order_point_edit);
        refundActionPointEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                selectTotalPrice();
            }
        });
        refundActionPointSelect.setOnClickListener(this);
        refundActionCashCouponSelect = (ImageButton) findViewById(R.id.refund_action_order_cash_coupon_select);
        refundActionCashCouponEditText = (EditText) findViewById(R.id.refund_action_order_cash_coupon_edit);
        refundActionCashCouponEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                selectTotalPrice();
            }
        });
        refundActionCashCouponSelect.setOnClickListener(this);
        //业绩参与人
        mTvBenefitPerson = (TextView) findViewById(R.id.refund_benefit_person);
        /*		findViewById(R.id.refund_benefit_person_layout).setOnClickListener(this);*/
        findViewById(R.id.refund_benefit_person).setOnClickListener(this);
        findViewById(R.id.payment_benefit_textv_r).setOnClickListener(this);
        refundActionOKBtn = (Button) findViewById(R.id.refund_action_ok_btn);
        refundActionOKBtn.setOnClickListener(this);
        pointValueText = (TextView) findViewById(R.id.refund_action_order_point_value_text);
        ((EditText) findViewById(R.id.refund_action_order_point_edit)).addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence cs, int arg1, int arg2, int arg3) {
                // TODO Auto-generated method stub
                if (cs.toString() != null && !"".equals(cs.toString()))
                    pointValueText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.parseDouble(cs.toString()) * Double.parseDouble(pointRate))));
                else
                    pointValueText.setText("0");
            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
                                          int arg3) {
                // TODO Auto-generated method stub

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                // TODO Auto-generated method stub
                selectTotalPrice();
            }
        });
        cashCouponValueText = (TextView) findViewById(R.id.refund_action_order_cash_coupon_value);
        ((EditText) findViewById(R.id.refund_action_order_cash_coupon_edit)).addTextChangedListener(new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence cs, int arg1, int arg2, int arg3) {
                // TODO Auto-generated method stub
                if (cs.toString() != null && !"".equals(cs.toString()))
                    cashCouponValueText.setText(NumberFormatUtil.currencyFormat(String.valueOf(Double.parseDouble(cs.toString()) * Double.parseDouble(cashCouponRate))));
                else
                    cashCouponValueText.setText("0");
            }

            @Override
            public void beforeTextChanged(CharSequence arg0, int arg1, int arg2,
                                          int arg3) {
                // TODO Auto-generated method stub

            }

            @Override
            public void afterTextChanged(Editable arg0) {
                // TODO Auto-generated method stub
                selectTotalPrice();
            }
        });
        mBenefitPersonIDs = "[0]";
        Intent intent = getIntent();
        orderID = intent.getIntExtra("orderID", 0);
        customerID = intent.getIntExtra("customerID", 0);
        productType = intent.getIntExtra("productType", 0);
        userInfoApplication = UserInfoApplication.getInstance();
        isComissionCalc = userInfoApplication.getAccountInfo().isComissionCalc();
        thisTimepayment_benefit_share_btn = (TextView) findViewById(R.id.payment_benefit_share_btn_r);
        findViewById(R.id.payment_benefit_share_btn_r).setOnClickListener(this);
        if (!isComissionCalc) {
            thisTimepayment_benefit_share_btn.setVisibility(View.GONE);
            ((TableLayout) findViewById(R.id.refund_sales_percentage_tablelayout)).setVisibility(View.GONE);
            ((TableLayout) findViewById(R.id.refund_benefit_share_price_tablelayout)).setVisibility(View.GONE);
            ((TableLayout) findViewById(R.id.order_refund_slaver_tablelayout)).setVisibility(View.GONE);
        }
        refundActionPointPresentSelect = (ImageButton) findViewById(R.id.refund_action_give_point_select);
        refundActionPointPresentSelect.setOnClickListener(this);
        refundActionCashCouponPresentSelect = (ImageButton) findViewById(R.id.refund_action_giva_cash_coupon_select);
        refundActionCashCouponPresentSelect.setOnClickListener(this);
        getRefundInfo();
    }

    protected void getRefundInfo() {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "GetRefundOrderInfo";
                String endPoint = "payment";
                JSONObject refundDetailParamJson = new JSONObject();
                try {
                    refundDetailParamJson.put("OrderID", orderID);
                    refundDetailParamJson.put("CustomerID", customerID);
                    refundDetailParamJson.put("ProductType", productType);
                } catch (JSONException e) {
                    e.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, refundDetailParamJson.toString(), userInfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
                    e.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(0);
                else {
                    int code = 0;
                    String message = "";
                    List<PaymentRecordDetail> paymentRecordDetailList = null;
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                        e.printStackTrace();
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        refundInfo = new RefundInfo();
                        JSONObject refundDetailJson = null;
                        JSONArray paymentDetailJsonArray = null;
                        JSONArray ecardInfoJsonArray = null;
                        try {
                            refundDetailJson = resultJson.getJSONObject("Data");
                            paymentDetailJsonArray = refundDetailJson.getJSONArray("PaymentList");
                            ecardInfoJsonArray = refundDetailJson.getJSONArray("CardList");
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (refundDetailJson != null) {
                            try {
                                refundInfo.setRefundAmount(refundDetailJson.getDouble("RefundAmount"));
                                refundInfo.setGivePointAmount(refundDetailJson.getDouble("GivePointAmount"));
                                refundInfo.setGiveCashCouponAmount(refundDetailJson.getDouble("GiveCouponAmount"));
                                refundInfo.setRate(refundDetailJson.getDouble("Rate"));
                                refundInfo.setProductType(productType);
                            } catch (JSONException e) {
                                refundInfo.setRefundAmount(0);
                                e.printStackTrace();
                                mHandler.sendEmptyMessage(99);
                                return;
                            }
                        }
                        if (paymentDetailJsonArray != null) {
                            try {
                                paymentRecordDetailList = new ArrayList<PaymentRecordDetail>();
                                for (int i = 0; i < paymentDetailJsonArray.length(); i++) {
                                    JSONObject paymentDetailJson = paymentDetailJsonArray.getJSONObject(i);
                                    PaymentRecordDetail paymentRecordDetail = new PaymentRecordDetail();
                                    String paymentRecordDetailCode = "";
                                    String paymentRecordDetailDate = "";
                                    String paymentRecordDetailTypeName = "";
                                    String paymentRecordDetailBranchName = "";
                                    String paymentRecordDetailOperator = "";
                                    String paymentRecordDetailAmount = "";
                                    String paymentRecordDetailRemark = "";
                                    int orderCount = 1;
                                    List<OrderInfo> paymentOrderList = null;
                                    if (paymentDetailJson.has("PaymentCode"))
                                        paymentRecordDetailCode = paymentDetailJson.getString("PaymentCode");
                                    if (paymentDetailJson.has("TypeName"))
                                        paymentRecordDetailTypeName = paymentDetailJson.getString("TypeName");
                                    if (paymentDetailJson.has("BranchName"))
                                        paymentRecordDetailBranchName = paymentDetailJson.getString("BranchName");
                                    if (paymentDetailJson.has("PaymentTime"))
                                        paymentRecordDetailDate = paymentDetailJson.getString("PaymentTime");
                                    if (paymentDetailJson.has("Operator"))
                                        paymentRecordDetailOperator = paymentDetailJson.getString("Operator");
                                    if (paymentDetailJson.has("TotalPrice"))
                                        paymentRecordDetailAmount = String.valueOf(Double.valueOf(paymentDetailJson.getString("TotalPrice")));
                                    if (paymentDetailJson.has("Remark"))
                                        paymentRecordDetailRemark = paymentDetailJson.getString("Remark");
                                    if (paymentDetailJson.has("OrderNumber"))
                                        orderCount = paymentDetailJson.getInt("OrderNumber");
                                    if (paymentDetailJson.has("PaymentDetailList") && !paymentDetailJson.isNull("PaymentDetailList")) {
                                        List<PaymentDetailIssues> pdiList = new ArrayList<PaymentDetailIssues>();
                                        JSONArray paymentDetailArray = paymentDetailJson.getJSONArray("PaymentDetailList");
                                        for (int j = 0; j < paymentDetailArray.length(); j++) {
                                            JSONObject paymentDetailIssuesJson = paymentDetailArray.getJSONObject(j);
                                            PaymentDetailIssues pdi = new PaymentDetailIssues();
                                            int paymentMode = 0;
                                            String paymentAmount = "0";
                                            String cardPaymentAmount = "0";
                                            String cardName = "";
                                            int cardType = 0;
                                            if (paymentDetailIssuesJson.has("PaymentMode"))
                                                paymentMode = paymentDetailIssuesJson.getInt("PaymentMode");
                                            if (paymentDetailIssuesJson.has("PaymentAmount"))
                                                paymentAmount = paymentDetailIssuesJson.getString("PaymentAmount");
                                            if (paymentDetailIssuesJson.has("CardPaidAmount"))
                                                cardPaymentAmount = paymentDetailIssuesJson.getString("CardPaidAmount");
                                            if (paymentDetailIssuesJson.has("CardName"))
                                                cardName = paymentDetailIssuesJson.getString("CardName");
                                            if (paymentDetailIssuesJson.has("CardType"))
                                                cardType = paymentDetailIssuesJson.getInt("CardType");
                                            pdi.setPaymentMode(paymentMode);
                                            pdi.setPaymentAmount(paymentAmount);
                                            pdi.setCardPaidAmount(cardPaymentAmount);
                                            pdi.setCardName(cardName);
                                            pdi.setCardType(cardType);
                                            pdiList.add(pdi);
                                        }
                                        paymentRecordDetail.setPdiList(pdiList);
                                    }
                                    //获取本次交易的销售顾问
                                    double amounts = 0;
                                    salesConsultantRateList = new ArrayList<SalesConsultantRate>();
                                    if (paymentDetailJson.has("SalesConsultantRates") && !paymentDetailJson.isNull("SalesConsultantRates")) {
                                        JSONArray salesArray = paymentDetailJson.getJSONArray("SalesConsultantRates");
                                        for (int k = 0; k < salesArray.length(); k++) {
                                            JSONObject salesConsultantJson = salesArray.getJSONObject(k);
                                            SalesConsultantRate rate = new SalesConsultantRate();
                                            rate.setSalesConsultantID(salesConsultantJson.getInt("SalesConsultantID"));
                                            rate.setSalesConsultantName(salesConsultantJson.getString("SalesConsultantName"));
                                            rate.setCommissionRate(NumberFormatUtil.currencyFormat(String.valueOf(salesConsultantJson.getDouble("commissionRate") * 100)));
                                            amounts = amounts + salesConsultantJson.getDouble("commissionRate");
                                            salesConsultantRateList.add(rate);
                                        }
                                        consultantrateamount = amounts;
                                    }

                                    //获取本次交易的业绩参与人
                                    benefitPersonList = new ArrayList<BenefitPerson>();
                                    if (paymentDetailJson.has("ProfitList") && !paymentDetailJson.isNull("ProfitList")) {
                                        JSONArray profitArray = paymentDetailJson.getJSONArray("ProfitList");
                                        for (int j = 0; j < profitArray.length(); j++) {
                                            JSONObject benefitPersonJson = profitArray.getJSONObject(j);
                                            BenefitPerson bp = new BenefitPerson();
                                            bp.setAccountID(benefitPersonJson.getInt("AccountID"));
                                            bp.setAccountName(benefitPersonJson.getString("AccountName"));
                                            bp.setProfitPct(NumberFormatUtil.currencyFormat(String.valueOf(benefitPersonJson.getDouble("ProfitPct") * 100)));
                                            benefitPersonList.add(bp);
                                        }

                                    }
                                    paymentRecordDetail.setPaymentRecordDetailCode(paymentRecordDetailCode);
                                    paymentRecordDetail.setPaymentRecordDetailTypeName(paymentRecordDetailTypeName);
                                    paymentRecordDetail.setPaymentRecordDetailDate(paymentRecordDetailDate);
                                    paymentRecordDetail.setPaymentRecordDetailBranchName(paymentRecordDetailBranchName);
                                    paymentRecordDetail.setPaymentRecordDetailOperator(paymentRecordDetailOperator);
                                    paymentRecordDetail.setPaymentRecordDetailAmount(paymentRecordDetailAmount);
                                    paymentRecordDetail.setPaymentRecordDetailRemark(paymentRecordDetailRemark);
                                    paymentRecordDetail.setOrderNumber(orderCount);
                                    paymentRecordDetail.setProfitList(benefitPersonList);
                                    paymentRecordDetail.setConsultantList(salesConsultantRateList);
                                    paymentRecordDetail.setPaymentOrderList(paymentOrderList);
                                    paymentRecordDetailList.add(paymentRecordDetail);
                                    refundInfo.setPaymentRecordDetailList(paymentRecordDetailList);
                                }
                                JSONObject ecardInfoObject;
                                if (ecardInfoJsonArray != null) {
                                    List<EcardInfo> ecardInfoList = new ArrayList<EcardInfo>();
                                    for (int i = 0; i < ecardInfoJsonArray.length(); i++) {
                                        EcardInfo ecardInfo = new EcardInfo();
                                        try {
                                            ecardInfoObject = ecardInfoJsonArray.getJSONObject(i);
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
                                            if (ecardInfo.getUserEcardType() == 2) {
                                                pointRate = ecardInfo.getUserEcardRate();
                                                givePointRate = ecardInfo.getUserEcardPresentRate();
                                            } else if (ecardInfo.getUserEcardType() == 3) {
                                                cashCouponRate = ecardInfo.getUserEcardRate();
                                                giveCashCouponRate = ecardInfo.getUserEcardPresentRate();
                                            }
                                        } catch (JSONException e) {
                                            e.printStackTrace();
                                            mHandler.sendEmptyMessage(99);
                                            return;
                                        }
                                        ecardInfoList.add(ecardInfo);
                                    }
                                    refundInfo.setEcardInfoList(ecardInfoList);
                                }
                            } catch (NumberFormatException | JSONException e) {
                                e.printStackTrace();
                                mHandler.sendEmptyMessage(99);
                                return;
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

    private void selectTotalPrice() {
        refundTotalPrice = 0;
        refundCashTotalPrice = 0;
        refundOtherTotalPrice = 0;
        refundPointTotalPrice = 0;
        refundCashCouponTotalPrice = 0;
        refundECardpaidOrderTotalPrice = 0;
        // 现金
        String refundAmountCash = refundActionCashEditText.getText().toString();
        // 其他
        String refundAmountOther = refundActionOtherEditText.getText().toString();
        //积分
        String refundAmountPoint = pointValueText.getText().toString();
        //现金券
        String refundAmountCashCoupon = cashCouponValueText.getText().toString();

        if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false)) {
            if (refundAmountCash != null && !(("").equals(refundAmountCash)) && Double.parseDouble(refundAmountCash) != 0) {
                refundCashTotalPrice += Double.parseDouble(refundAmountCash);
            }
        }

        if ((selectButton.containsKey("other") ? selectButton.get("other") : false)) {
            if (refundAmountOther != null && !(("").equals(refundAmountOther)) && Double.parseDouble(refundAmountOther) != 0) {
                refundOtherTotalPrice += Double.parseDouble(refundAmountOther);
            }
        }
        if ((selectButton.containsKey("point") ? selectButton.get("point") : false)) {
            if (refundAmountPoint != null && !(("").equals(refundAmountPoint)) && Double.parseDouble(refundAmountPoint) != 0) {
                refundPointTotalPrice += Double.parseDouble(refundAmountPoint);
            }
        }
        if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false)) {
            if (refundAmountCashCoupon != null && !(("").equals(refundAmountCashCoupon)) && Double.parseDouble(refundAmountCashCoupon) != 0) {
                refundCashCouponTotalPrice += Double.parseDouble(refundAmountCashCoupon);
            }
        }
        for (int i = 0; i < refundInfo.getEcardInfoList().size(); i++) {
            EcardInfo ecardInfo = refundInfo.getEcardInfoList().get(i);
            if (ecardInfo.getUserEcardType() == 1) {
                final String cardChild = "cardChild" + i;
                if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false)) {
                    View view = refundEcardLinearLayout.findViewWithTag(i);
                    String cardString = ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).getText().toString();
                    if (cardString != null && !(("").equals(cardString)) && Double.parseDouble(cardString) > 0) {
                        refundECardpaidOrderTotalPrice += Double.parseDouble(cardString);
                    }
                }
            }
        }
        String currency = userInfoApplication.getAccountInfo().getCurrency();
        refundActionShouldRefundAmount = refundCashTotalPrice + refundOtherTotalPrice + refundPointTotalPrice + refundCashCouponTotalPrice + refundECardpaidOrderTotalPrice;
        refundActionGiveRefundAmount = refundCashTotalPrice + refundOtherTotalPrice + refundECardpaidOrderTotalPrice;
        //((TextView)findViewById(R.id.refund_action_should_refund_amount)).setText(currency+NumberFormatUtil.currencyFormat(String.valueOf(refundActionShouldRefundAmount)));
        ((TextView) findViewById(R.id.refund_action_give_point_value)).setText(NumberFormatUtil.currencyFormat(String.valueOf(refundActionGiveRefundAmount * Double.parseDouble(givePointRate))));
        ((TextView) findViewById(R.id.refund_action_give_cash_value)).setText(currency + NumberFormatUtil.currencyFormat(String.valueOf(refundActionGiveRefundAmount * Double.valueOf(giveCashCouponRate))));
        refundBenefitSharePrice.setText(userInfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(refundActionShouldRefundAmount - refundActionShouldRefundAmount * consultantrateamount)));
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
                refundSalesPercentageLinearlayout.addView(salesConsultantItemView, cnt_i);
                salesConsultantItemView.findViewById(R.id.benefit_person_after_divide_view).setVisibility(View.GONE);
            }
        }
    }

    private void setBenefitPersonInfo(String id, String name) {
        if (namegetFlg == 1) {
            mBenefitPersonIDs = id;
            mBenefitPersonNames = name;
            namegetFlg = 0;
        }
        removeBenefitPerson();
        JSONArray idArray = null;
        try {
            idArray = new JSONArray(id);
        } catch (JSONException e) {
            e.printStackTrace();
            mHandler.sendEmptyMessage(99);
            return;
        }
        if (idArray != null && idArray.length() > 0) {
            String[] nameArray = name.split("、");
            String displayPercent = new DecimalFormat("0.00").format(0);
            if (shareFlg == 1) {
                displayPercent = "均分";
                if (nameArray.length == 1) {
                    displayPercent = "100";
                }
            }
            for (int i = 0; i < nameArray.length; i++) {
                View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                benefitPersonNameText.setText(nameArray[i]);
                EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                /*benefitPersonPercentText.setOnTouchListener(new View.OnTouchListener() {
                    int touch_flag = 0;

                    @Override
                    public boolean onTouch(View v, MotionEvent event) {
                        touch_flag++;
                        if (touch_flag == 2) {
                            touch_flag = 0;
                            if (shareFlg == 1) {
                                String[] nameArray = mBenefitPersonNames.split("、");
                                orderRefundSlaverTablelayout.removeViews(ecardSlaverStartPos, orderRefundSlaverTablelayout.getChildCount() - 1);
                                for (int j = 0; j < nameArray.length; j++) {
                                    View benefitPersonItemView = layoutInflater.inflate(R.xml.benefit_person_list_item, null);
                                    TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                    benefitPersonNameText.setText(nameArray[j]);
                                    EditText benefitPersonPercentText = (EditText) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
                                    TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                                    EditText[] editText = new EditText[]{benefitPersonPercentText};
                                    NumberFormatUtil.setPricePointArray(editText, 2);
                                    benefitPersonPercentText.setText(String.valueOf(0));
                                    orderRefundSlaverTablelayout.addView(benefitPersonItemView, ecardSlaverStartPos + j);
                                }
                                shareFlg = 0;
                                return true;
                            }
                        }
                        return false;
                    }
                });*/
                TextView benefitPersonPercentMark = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark);
                EditText[] editText = new EditText[]{benefitPersonPercentText};
                NumberFormatUtil.setPricePointArray(editText, 2);
                benefitPersonPercentText.setText(displayPercent);
                if (shareFlg == 1) {
                    benefitPersonPercentText.setEnabled(false);
                } else {
                    benefitPersonPercentText.setEnabled(true);
                }
                orderRefundSlaverTablelayout.addView(benefitPersonItemView, benefitPersonStartPos + i);
            }
            benefitPersonItemCnt = nameArray.length;
        } else {
            shareFlg = 0;
            benefitPersonItemCnt = 0;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode != RESULT_OK) {
            return;
        }
        if (requestCode == 101) {
            shareFlg = 1;
            namegetFlg = 1;
            setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
        }
    }

    private void submitRefundWhenBenefitPersonIsNull() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_refund_when_benefit_person_is_null)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                assignRefund();
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

    private void submitRefundWhenpersonIsoverflow() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_payment_when_benefit_person_is_overflow)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                assignRefund();
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

    //应退金额
    private void assignRefund() {
        double refundAmount = refundInfo.getRefundAmount();
        if (refundActionShouldRefundAmount != refundAmount)
            submitRefundWhenRefundAmountIsoverflow();
        else
            CheckRefundGivePoint();
    }

    //赠送积分
    private void CheckRefundGivePoint() {
        double refundGivePoint = refundActionGiveRefundAmount * Double.parseDouble(givePointRate);
        String inputGivePoint = ((EditText) findViewById(R.id.refund_action_give_point_edit)).getText().toString();
        double tempGivePoint = 0;

        if ("".equals(inputGivePoint)) {
            submitGiveWhenRefundGivePoint();
        } else {
            tempGivePoint = Double.parseDouble(inputGivePoint);

            if (refundGivePoint != tempGivePoint || tempGivePoint == 0)
                submitGiveWhenRefundGivePoint();
            else
                CheckRefundGiveCashCoupon();
        }
    }

    //赠送现金券
    private void CheckRefundGiveCashCoupon() {
        double refundGiveCashCoupon = refundActionGiveRefundAmount * Double.parseDouble(giveCashCouponRate);
        String inputGiveCashCoupon = ((EditText) findViewById(R.id.refund_action_give_cash_edit)).getText().toString();
        double tempGiveCashCoupon = 0;

        if ("".equals(inputGiveCashCoupon)) {
            submitGiveWhenRefundGiveCashCoupon();
        } else {
            tempGiveCashCoupon = Double.parseDouble(inputGiveCashCoupon);

            if (refundGiveCashCoupon != tempGiveCashCoupon || tempGiveCashCoupon == 0)
                submitGiveWhenRefundGiveCashCoupon();
            else
                submitRefund();
        }
    }

    private void submitRefundWhenRefundAmountIsoverflow() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_Refund_when_price_is_overflow)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                CheckRefundGivePoint();
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

    private void submitGiveWhenRefundGivePoint() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_Give_when_Refund_Give_Point)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                CheckRefundGiveCashCoupon();
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

    private void submitGiveWhenRefundGiveCashCoupon() {
        Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                .setTitle(getString(R.string.delete_dialog_title))
                .setMessage(R.string.submit_Give_when_refund_Give_CashCoupon)
                .setPositiveButton(getString(R.string.delete_confirm),
                        new DialogInterface.OnClickListener() {

                            @Override
                            public void onClick(DialogInterface dialog,
                                                int which) {
                                dialog.dismiss();
                                submitRefund();
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

    // 提交退款信息到服务器
    protected void submitRefund() {
        refundTotalPrice = 0;
        // 现金
        String refundAmountCash = refundActionCashEditText.getText().toString();
        // 其他
        String refundAmountOther = refundActionOtherEditText.getText().toString();
        //积分
        String refundAmountPoint = refundActionPointEditText.getText().toString();
        //现金券
        String refundAmountCashCoupon = refundActionCashCouponEditText.getText().toString();
        //赠送积分
        String refundAmountGivePoint = ((EditText) findViewById(R.id.refund_action_give_point_edit)).getText().toString();
        //赠送现金券
        String refundAmountGiveCashCoupon = ((EditText) findViewById(R.id.refund_action_give_cash_edit)).getText().toString();
        final JSONArray paymentDetailJsonArray = new JSONArray();
        final JSONArray giveDetailJsonArray = new JSONArray();
        //现金
        if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false)) {
            if (refundAmountCash != null && !(("").equals(refundAmountCash)) && Double.parseDouble(refundAmountCash) != 0) {
                JSONObject cashPaymentJson = new JSONObject();
                try {

                    cashPaymentJson.put("PaymentMode", 0);
                    cashPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountCash));
                } catch (JSONException e) {
                    e.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                paymentDetailJsonArray.put(cashPaymentJson);
                refundTotalPrice += Double.parseDouble(refundAmountCash);
            }
        }
        //其他
        if ((selectButton.containsKey("other") ? selectButton.get("other") : false)) {
            if (refundAmountOther != null && !(("").equals(refundAmountOther)) && Double.parseDouble(refundAmountOther) != 0) {
                JSONObject otherPaymentJson = new JSONObject();
                try {
                    otherPaymentJson.put("PaymentMode", 3);
                    otherPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountOther));
                } catch (JSONException e) {
                    e.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                paymentDetailJsonArray.put(otherPaymentJson);
                refundTotalPrice += Double.parseDouble(refundAmountOther);
            }
        }
        //积分
        if ((selectButton.containsKey("point") ? selectButton.get("point") : false)) {
            for (EcardInfo ecardInfo : refundInfo.getEcardInfoList()) {
                if (ecardInfo.getUserEcardType() == 2) {
                    if (refundAmountPoint != null && !(("").equals(refundAmountPoint)) && Double.parseDouble(refundAmountPoint) != 0) {
                        JSONObject integralPaymentJson = new JSONObject();
                        try {
                            integralPaymentJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                            integralPaymentJson.put("CardType", 2);
                            integralPaymentJson.put("PaymentMode", 6);
                            integralPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountPoint));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        paymentDetailJsonArray.put(integralPaymentJson);
                        refundTotalPrice += refundPointTotalPrice;
                    }
                }

            }
        }
        //现金券
        if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false)) {
            for (EcardInfo ecardInfo : refundInfo.getEcardInfoList()) {
                if (ecardInfo.getUserEcardType() == 3) {
                    if (refundAmountCashCoupon != null && !(("").equals(refundAmountCashCoupon)) && Double.valueOf(refundAmountCashCoupon) != 0) {
                        JSONObject cashCouponPaymentJson = new JSONObject();
                        try {
                            cashCouponPaymentJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                            cashCouponPaymentJson.put("CardType", 3);
                            cashCouponPaymentJson.put("PaymentMode", 7);
                            cashCouponPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountCashCoupon));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        paymentDetailJsonArray.put(cashCouponPaymentJson);
                        refundTotalPrice += refundCashCouponTotalPrice;
                    }
                }
            }
        }
        //储值卡
        for (int i = 0; i < refundInfo.getEcardInfoList().size(); i++) {
            EcardInfo ecardInfo = refundInfo.getEcardInfoList().get(i);
            if (ecardInfo.getUserEcardType() == 1) {
                final String cardChild = "cardChild" + i;
                if ((selectButton.containsKey(cardChild) ? selectButton.get(cardChild) : false)) {
                    View view = refundEcardLinearLayout.findViewWithTag(i);
                    String cardString = ((EditText) view.findViewById(R.id.payment_action_order_card_child_edit)).getText().toString();
                    JSONObject cardPaymentJson = new JSONObject();
                    if (cardString != null && !(("").equals(cardString)) && Double.parseDouble(cardString) > 0) {
                        try {
                            cardPaymentJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                            cardPaymentJson.put("CardType", 1);
                            cardPaymentJson.put("PaymentMode", 1);
                            cardPaymentJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(cardString));

                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        paymentDetailJsonArray.put(cardPaymentJson);
                        refundTotalPrice += Double.parseDouble(cardString);
                    }
                }
            }
        }
        //赠送积分
        if ((selectButton.containsKey("givePoint") ? selectButton.get("givePoint") : false)) {
            for (EcardInfo ecardInfo : refundInfo.getEcardInfoList()) {
                if (ecardInfo.getUserEcardType() == 2) {
                    if (refundAmountGivePoint != null && !(("").equals(refundAmountGivePoint)) && Double.parseDouble(refundAmountGivePoint) != 0) {
                        JSONObject pointGiveJson = new JSONObject();
                        try {
                            pointGiveJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                            pointGiveJson.put("CardType", 2);
                            pointGiveJson.put("PaymentMode", 6);
                            pointGiveJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountGivePoint));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        giveDetailJsonArray.put(pointGiveJson);
                    }
                }
            }
        }
        //赠送现金券
        if ((selectButton.containsKey("giveCashCoupon") ? selectButton.get("giveCashCoupon") : false)) {
            for (EcardInfo ecardInfo : refundInfo.getEcardInfoList()) {
                if (ecardInfo.getUserEcardType() == 3) {
                    if (refundAmountGiveCashCoupon != null && !(("").equals(refundAmountGiveCashCoupon)) && Double.parseDouble(refundAmountGiveCashCoupon) != 0) {
                        JSONObject cashCouponGiveJson = new JSONObject();
                        try {
                            cashCouponGiveJson.put("UserCardNo", ecardInfo.getUserEcardNo());
                            cashCouponGiveJson.put("CardType", 3);
                            cashCouponGiveJson.put("PaymentMode", 7);
                            cashCouponGiveJson.put("PaymentAmount", NumberFormatUtil.currencyFormat(refundAmountGiveCashCoupon));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        giveDetailJsonArray.put(cashCouponGiveJson);
                    }
                }
            }
        }
        // 支付备注
        final String refundRemark = ((EditText) findViewById(R.id.refund_action_remark)).getText().toString();
        submitStrParam(refundRemark, paymentDetailJsonArray, giveDetailJsonArray);
    }

    private void submitStrParam(final String paymentRemark, final JSONArray paymentDetailJsonArray, final JSONArray giveDetailJsonArray) {
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "RefundPay";
                String endPoint = "Payment";
                JSONObject addRefundJson = new JSONObject();
                try {
                    addRefundJson.put("TotalPrice", NumberFormatUtil.currencyFormat(String.valueOf(refundTotalPrice)));
                    addRefundJson.put("CustomerID", customerID);
                    addRefundJson.put("OrderID", orderID);
                    addRefundJson.put("Remark", paymentRemark);
                    addRefundJson.put("PaymentDetailList", paymentDetailJsonArray);
                    addRefundJson.put("GiveDetailList", giveDetailJsonArray);
                    addRefundJson.put("AverageFlag", shareFlg);
                    JSONArray benefitDetailJsonArray = new JSONArray();
                    if (mBenefitPersonIDs == null || mBenefitPersonIDs.equals("") || mBenefitPersonIDs.equals("[0]"))
                        ;
                    else {
                        try {
                            JSONArray tmp = new JSONArray(mBenefitPersonIDs);
                            for (int i = 1; i < orderRefundSlaverTablelayout.getChildCount(); i++) {
                                EditText percentEditText = ((EditText) orderRefundSlaverTablelayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                                double percent = 0;
                                if (percentEditText.getText() != null && shareFlg == 0)
                                    percent = Double.parseDouble(percentEditText.getText().toString()) / 100;
                                JSONObject benefitJson = new JSONObject();
                                benefitJson.put("SlaveID", tmp.get(i - 1));
                                benefitJson.put("ProfitPct", percent);
                                benefitDetailJsonArray.put(benefitJson);
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                    }
                    addRefundJson.put("Slavers", benefitDetailJsonArray);
                } catch (JSONException e) {
                    e.printStackTrace();
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, addRefundJson.toString(), userInfoApplication);
                if (serverResult == null || ("").equals(serverResult))
                    mHandler.sendEmptyMessage(0);
                else {
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverResult);
                    } catch (JSONException e) {
                        e.printStackTrace();
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    int code = 0;
                    String serverMessage = "";
                    try {
                        code = resultJson.getInt("Code");
                        serverMessage = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                        e.printStackTrace();
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        mHandler.sendEmptyMessage(6);
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

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        //显示积分或者现金券余额
        switch (view.getId()) {
            case R.id.refund_action_order_cash_select:
                if ((selectButton.containsKey("cash") ? selectButton.get("cash") : false)) {
                    refundActionCashSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("cash", false);
                } else {
                    refundActionCashSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("cash", true);
                }
                selectTotalPrice();
                break;
            case R.id.refund_action_order_other_select:
                if ((selectButton.containsKey("other") ? selectButton.get("other") : false)) {
                    refundActionOtherSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("other", false);
                } else {
                    refundActionOtherSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("other", true);
                }
                selectTotalPrice();
                break;
            case R.id.refund_action_order_point_select:
                if ((selectButton.containsKey("point") ? selectButton.get("point") : false)) {
                    refundActionPointSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("point", false);
                } else {
                    refundActionPointSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("point", true);
                }
                selectTotalPrice();
                break;
            case R.id.refund_action_order_cash_coupon_select:
                if ((selectButton.containsKey("cashCoupon") ? selectButton.get("cashCoupon") : false)) {
                    refundActionCashCouponSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("cashCoupon", false);
                } else {
                    refundActionCashCouponSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("cashCoupon", true);
                }
                selectTotalPrice();
                break;
            case R.id.refund_action_give_point_select:
                if ((selectButton.containsKey("givePoint") ? selectButton.get("givePoint") : false)) {
                    refundActionPointPresentSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("givePoint", false);
                } else {
                    refundActionPointPresentSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("givePoint", true);
                }
                break;
            case R.id.refund_action_giva_cash_coupon_select:
                if ((selectButton.containsKey("giveCashCoupon") ? selectButton.get("giveCashCoupon") : false)) {
                    refundActionCashCouponPresentSelect.setBackgroundResource(R.drawable.no_select_btn);
                    selectButton.put("giveCashCoupon", false);
                } else {
                    refundActionCashCouponPresentSelect.setBackgroundResource(R.drawable.select_btn);
                    selectButton.put("giveCashCoupon", true);
                }
                break;
            case R.id.point_and_cash_coupon_balance_btn:
                List<EcardInfo> pointCouponList = new ArrayList<EcardInfo>();
                for (EcardInfo ei : refundInfo.getEcardInfoList()) {
                    if (ei.getUserEcardType() == 2 || ei.getUserEcardType() == 3) {
                        pointCouponList.add(ei);
                    }
                }
                final String[] pointCouponArray = new String[pointCouponList.size()];
                for (int j = 0; j < pointCouponList.size(); j++) {
                    pointCouponArray[j] = pointCouponList.get(j).getUserEcardName() + "余额（" + pointCouponList.get(j).getUserEcardBalance() + "）";
                }
                Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog).setTitle(getString(R.string.delete_dialog_title))
                        .setItems(pointCouponArray, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {

                            }
                        }).create();
                dialog.show();
                break;
/*		case R.id.refund_benefit_person_layout:
			Intent chooseBenefitPersonIntent = new Intent(this,ChoosePersonActivity.class);
			chooseBenefitPersonIntent.putExtra("personRole", "Doctor");
			chooseBenefitPersonIntent.putExtra("checkModel", "Multi");
			chooseBenefitPersonIntent.putExtra("setBenefitPerson",true);
			chooseBenefitPersonIntent.putExtra("selectPersonIDs",mBenefitPersonIDs);
			chooseBenefitPersonIntent.putExtra("customerID",customerID);
			startActivityForResult(chooseBenefitPersonIntent, 101);
			break;*/
            case R.id.payment_benefit_textv_r:
            case R.id.refund_benefit_person:
                Intent chooseBenefitPersonIntent2 = new Intent(this, ChoosePersonActivity.class);
                chooseBenefitPersonIntent2.putExtra("personRole", "Doctor");
                chooseBenefitPersonIntent2.putExtra("checkModel", "Multi");
                chooseBenefitPersonIntent2.putExtra("setBenefitPerson", true);
                chooseBenefitPersonIntent2.putExtra("selectPersonIDs", mBenefitPersonIDs);
                chooseBenefitPersonIntent2.putExtra("customerID", customerID);
                startActivityForResult(chooseBenefitPersonIntent2, 101);
                break;
            case R.id.payment_benefit_share_btn_r:
                if (!checkBenefitPersonIsNull() && isComissionCalc) {
                    if (shareFlg == 1) {
                        shareFlg = 0;
                    } else {
                        shareFlg = 1;
                    }
                    setBenefitPersonInfo(mBenefitPersonIDs, mBenefitPersonNames);
                }
                break;
            case R.id.refund_action_ok_btn:
                if (shareFlg == 1) {
                    assignRefund();
                } else {
                    boolean ischeckBenefitPersonIsNull = checkBenefitPersonIsNull();
                    if (ischeckBenefitPersonIsNull)
                        submitRefundWhenBenefitPersonIsNull();
                    else {
                        double percenttemp = 0;
                        for (int i = 1; i < orderRefundSlaverTablelayout.getChildCount(); i++) {
                            EditText percentEditText = ((EditText) orderRefundSlaverTablelayout.getChildAt(i).findViewById(R.id.benefit_person_percent));
                            double temp = 0;
                            temp = Double.parseDouble(percentEditText.getText().toString());
                            percenttemp = temp + percenttemp;
                        }
                        if (percenttemp != 100) {
                            submitRefundWhenpersonIsoverflow();
                        } else {
                            assignRefund();
                        }
                    }
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

    /**
     * 清除业绩参与者
     */
    private void removeBenefitPerson() {
        if (benefitPersonItemCnt > 0) {
            orderRefundSlaverTablelayout.removeViews(benefitPersonStartPos, benefitPersonItemCnt);
            benefitPersonItemCnt = 0;
        }
    }

}
