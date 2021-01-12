package com.GlamourPromise.Beauty.Business;

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
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.BenefitPerson;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.PaymentDetailIssues;
import com.GlamourPromise.Beauty.bean.PaymentRecordDetail;
import com.GlamourPromise.Beauty.bean.SalesConsultantRate;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.NumberFormatUtil;
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
 * 支付记录详情
 * */
@SuppressLint("ResourceType")
public class OrderPaymentDetailActivity extends BaseActivity {
    private OrderPaymentDetailActivityHandler mHandler = new OrderPaymentDetailActivityHandler(this);
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private LinearLayout orderPaymentDetailLinearlayout, paymentDetailOrderListLinearlayout;
    private LayoutInflater layoutInflater;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private int totalcnt;
    private double consultantrateamount;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_order_payment_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        initView();
    }

    private static class OrderPaymentDetailActivityHandler extends Handler {
        private final OrderPaymentDetailActivity orderPaymentDetailActivity;

        private OrderPaymentDetailActivityHandler(OrderPaymentDetailActivity activity) {
            WeakReference<OrderPaymentDetailActivity> weakReference = new WeakReference<OrderPaymentDetailActivity>(activity);
            orderPaymentDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (orderPaymentDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (orderPaymentDetailActivity.progressDialog != null) {
                orderPaymentDetailActivity.progressDialog.dismiss();
                orderPaymentDetailActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                List<PaymentRecordDetail> paymentRecordDetailList = (List<PaymentRecordDetail>) msg.obj;
                orderPaymentDetailActivity.orderPaymentDetailLinearlayout = (LinearLayout) orderPaymentDetailActivity.findViewById(R.id.order_payment_detail_linearlayout);
                orderPaymentDetailActivity.layoutInflater = LayoutInflater.from(orderPaymentDetailActivity);
                TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
                lp.topMargin = 20;
                lp.leftMargin = 10;
                lp.rightMargin = 10;
                for (int i = 0; i < paymentRecordDetailList.size(); i++) {
                    PaymentRecordDetail paymentRecordDetail = paymentRecordDetailList.get(i);
                    View orderPaymentDetailItem = orderPaymentDetailActivity.layoutInflater.inflate(R.xml.order_payment_detail_item, null);
                    TableLayout orderPaymentDetailTablelayout = (TableLayout) orderPaymentDetailItem.findViewById(R.id.order_payment_detail_tablelayout);
                    orderPaymentDetailItem.setLayoutParams(lp);
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_code_text)).setText(paymentRecordDetail.getPaymentRecordDetailCode());
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_date_text)).setText(paymentRecordDetail.getPaymentRecordDetailDate());
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_branch_name_text)).setText(paymentRecordDetail.getPaymentRecordDetailBranchName());
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_type_name_text)).setText(paymentRecordDetail.getPaymentRecordDetailTypeName());
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_operator_text)).setText(paymentRecordDetail.getPaymentRecordDetailOperator());
                    ImageView orderPaymentDetailUpDownIcon = (ImageView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_up_down_icon);
                    orderPaymentDetailUpDownIcon.setVisibility(View.GONE);
                    String currency = orderPaymentDetailActivity.userinfoApplication.getAccountInfo().getCurrency();
                    ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_amount_text)).setText(currency + NumberFormatUtil.currencyFormat(paymentRecordDetail.getPaymentRecordDetailAmount()));
                    LinearLayout paymentDetailIssuesLinearlayout = (LinearLayout) orderPaymentDetailItem.findViewById(R.id.payment_detail_issues_linearlayout);
                    double pointamount = 0;
                    double cashcouponamount = 0;
                    if (paymentRecordDetail.getPdiList() != null && paymentRecordDetail.getPdiList().size() > 0) {
                        for (int j = 0; j < paymentRecordDetail.getPdiList().size(); j++) {
                            PaymentDetailIssues pdi = paymentRecordDetail.getPdiList().get(j);
                            View paymentDetailIssuesView = orderPaymentDetailActivity.layoutInflater.inflate(R.xml.payment_detail_issues, null);
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
                                pointamount = Double.valueOf(pdi.getCardPaidAmount());
                            }
                            //现金券
                            else if (pdi.getCardType() == 3) {
                                cardPaymentAmountText.setText(currency + NumberFormatUtil.currencyFormat(pdi.getCardPaidAmount()) + "抵" + currency + NumberFormatUtil.currencyFormat(pdi.getPaymentAmount()));
                                cashcouponamount = Double.valueOf(pdi.getCardPaidAmount());
                            }
                            paymentDetailIssuesLinearlayout.addView(paymentDetailIssuesView);
                        }
                    }
                    List<SalesConsultantRate> rateList = paymentRecordDetail.getConsultantList();
                    List<BenefitPerson> profitList = paymentRecordDetail.getProfitList();
                    boolean isComissionCalc = orderPaymentDetailActivity.userinfoApplication.getAccountInfo().isComissionCalc();
                    if (!isComissionCalc) {
                        ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_relativelayout)).setVisibility(View.GONE);
                        ((View) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_view)).setVisibility(View.GONE);
                        ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_relativelayout)).setVisibility(View.GONE);
                        ((View) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_view)).setVisibility(View.GONE);
                        ((RelativeLayout) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_relativelayout)).setVisibility(View.GONE);
                        ((View) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_view)).setVisibility(View.GONE);
                    } else {
                        //消费退款的订单隐藏业绩比例
						/*String tmptype=paymentRecordDetail.getPaymentRecordDetailType();
						if(tmptype.equals("2")) {
							((RelativeLayout)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_relativelayout)).setVisibility(View.GONE);
							((View)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_view)).setVisibility(View.GONE);
							((RelativeLayout)orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_relativelayout)).setVisibility(View.GONE);
							((View)orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_view)).setVisibility(View.GONE);
							((RelativeLayout)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_relativelayout)).setVisibility(View.GONE);
							((View)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_view)).setVisibility(View.GONE);
						}else {*/
                        //业绩参与人业绩比例
                        orderPaymentDetailActivity.totalcnt = 5;
                        if (profitList == null || profitList.size() == 0) {
                            ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_text)).setText("无");
                        } else {
                            for (int j = 0; j < profitList.size(); j++) {
                                BenefitPerson bp = profitList.get(j);
                                View benefitPersonItemView = orderPaymentDetailActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                                benefitPersonItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
                                TextView benefitPersonNameText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_name);
                                benefitPersonNameText.setText(bp.getAccountName());
                                TextView benefitPersonPercentText = (TextView) benefitPersonItemView.findViewById(R.id.benefit_person_percent);
								/*if(!isComissionCalc){
									((TextView)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person)).setVisibility(View.GONE);
									((TextView)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_benefit_person_text)).setVisibility(View.GONE);
									benefitPersonNameText.setVisibility(View.GONE);
									benefitPersonPercentText.setVisibility(View.GONE);
									benefitPersonItemView.findViewById(R.id.benefit_person_percent_mark).setVisibility(View.GONE);
								}
								else*/
                                benefitPersonPercentText.setText(bp.getProfitPct());
                                orderPaymentDetailTablelayout.addView(benefitPersonItemView, orderPaymentDetailTablelayout.getChildCount() - 3);
                                orderPaymentDetailActivity.totalcnt++;
                            }
                        }

                        //销售顾问业绩比例
                        if (rateList == null || rateList.size() == 0)
                            ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_text)).setText("无");
                        else {
                            for (int j = 0; j < rateList.size(); j++) {
                                SalesConsultantRate bp = rateList.get(j);
                                View salesConsultantItemView = orderPaymentDetailActivity.layoutInflater.inflate(R.xml.payment_detail_benefit_person_list_item, null);
                                salesConsultantItemView.findViewById(R.id.benefit_person_before_divide_view).setVisibility(View.GONE);
                                TextView salesConsultantNameText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_name);
                                salesConsultantNameText.setText(bp.getSalesConsultantName());
                                TextView salesConsultantPercentText = (TextView) salesConsultantItemView.findViewById(R.id.benefit_person_percent);
								/*if(!isComissionCalc){
									((TextView)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales)).setVisibility(View.GONE);
									((TextView)orderPaymentDetailItem.findViewById(R.id.payment_record_detail_order_sales_text)).setVisibility(View.GONE);
									salesConsultantNameText.setVisibility(View.GONE);
									salesConsultantPercentText.setVisibility(View.GONE);
									salesConsultantItemView.findViewById(R.id.benefit_person_percent_mark).setVisibility(View.GONE);
								}
								else*/
                                salesConsultantPercentText.setText(bp.getCommissionRate());
                                orderPaymentDetailTablelayout.addView(salesConsultantItemView, orderPaymentDetailTablelayout.getChildCount() - (orderPaymentDetailActivity.totalcnt + 2));
                            }
                        }
                        //业绩参与分配金额
                        //double shouldPaysmounts=Double.valueOf(paymentRecordDetail.getPaymentRecordDetailAmount())-pointamount-cashcouponamount;
                        double shouldPaysmounts = Double.valueOf(paymentRecordDetail.getPaymentRecordDetailAmount());
                        double benefitsharepriceamount = shouldPaysmounts - shouldPaysmounts * orderPaymentDetailActivity.consultantrateamount;
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.service_and_product_benefit_share_text)).setText(currency + NumberFormatUtil.currencyFormat(String.valueOf(benefitsharepriceamount)));
                        //}
                    }

                    String paymentRecordDetailRemark = paymentRecordDetail.getPaymentRecordDetailRemark();
                    if (paymentRecordDetailRemark == null || ("").equals(paymentRecordDetailRemark)) {
                        //orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_title_divide_view).setVisibility(View.GONE);
                        //orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_title_relativelayout).setVisibility(View.GONE);
                        orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_divide_view).setVisibility(View.GONE);
                        orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_relativelayout).setVisibility(View.GONE);
                    } else {
                        ((TextView) orderPaymentDetailItem.findViewById(R.id.payment_record_detail_remark_text)).setText(paymentRecordDetailRemark);
                    }
                    orderPaymentDetailActivity.orderPaymentDetailLinearlayout.addView(orderPaymentDetailItem);
                    //支付详情的订单列表
                    orderPaymentDetailActivity.paymentDetailOrderListLinearlayout = (LinearLayout) orderPaymentDetailActivity.findViewById(R.id.payment_record_detail_order_list_linearlayout);
                    List<OrderInfo> orderList = paymentRecordDetail.getPaymentOrderList();
                    if (orderList != null && orderList.size() > 0) {
                        for (int j = 0; j < orderList.size(); j++) {
                            final OrderInfo oi = orderList.get(j);
                            View paymentRecordDetailOrderView = orderPaymentDetailActivity.layoutInflater.inflate(R.xml.payment_record_detail_order_item_layout, null);
                            paymentRecordDetailOrderView.setLayoutParams(lp);
                            RelativeLayout paymentDetailOrderJoin = (RelativeLayout) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_join);
                            paymentDetailOrderJoin.setOnClickListener(new OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    // TODO Auto-generated method stub
                                    Intent destIntent = new Intent(orderPaymentDetailActivity, OrderDetailActivity.class);
                                    destIntent.putExtra("orderInfo", oi);
                                    destIntent.putExtra("FromOrderList", true);
                                    orderPaymentDetailActivity.startActivity(destIntent);
                                }
                            });
                            TextView paymentRecordDetailOrderNumber = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_serial_number);
                            paymentRecordDetailOrderNumber.setText(orderList.get(j).getOrderSerialNumber());
                            TextView paymentRecordDetailOrderProductName = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_product_name);
                            paymentRecordDetailOrderProductName.setText(orderList.get(j).getProductName());
                            TextView paymentRecordDetailOrderPrice = (TextView) paymentRecordDetailOrderView.findViewById(R.id.payment_record_detail_order_total_price);
                            paymentRecordDetailOrderPrice.setText(currency + NumberFormatUtil.currencyFormat(orderList.get(j).getTotalSalePrice()));
                            orderPaymentDetailActivity.paymentDetailOrderListLinearlayout.addView(paymentRecordDetailOrderView);
                        }
                    }
                }
            } else if (msg.what == 0) {
                DialogUtil.createMakeSureDialog(orderPaymentDetailActivity, "提示信息", "您的网络貌似不给力，请检查网络设置！");
            } else if (msg.what == 2) {
                String message = (String) msg.obj;
                DialogUtil.createShortDialog(orderPaymentDetailActivity, message);
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(orderPaymentDetailActivity, orderPaymentDetailActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(orderPaymentDetailActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + orderPaymentDetailActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(orderPaymentDetailActivity);
                orderPaymentDetailActivity.packageUpdateUtil = new PackageUpdateUtil(orderPaymentDetailActivity, orderPaymentDetailActivity.mHandler, fileCache, downloadFileUrl, false, orderPaymentDetailActivity.userinfoApplication);
                orderPaymentDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                orderPaymentDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = orderPaymentDetailActivity.getFileStreamPath(filename);
                file.getName();
                orderPaymentDetailActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (orderPaymentDetailActivity.requestWebServiceThread != null) {
                orderPaymentDetailActivity.requestWebServiceThread.interrupt();
                orderPaymentDetailActivity.requestWebServiceThread = null;
            }
        }
    }

    private void initView() {
        userinfoApplication = UserInfoApplication.getInstance();
        final int orderID = getIntent().getIntExtra("OrderID", 0);
        final int paymentID = getIntent().getIntExtra("paymentID", 0);
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            public void run() {
                String methodName = "getPaymentDetailByOrderID";
                String endPoint = "payment";
                JSONObject paymentRecordDetailParamJson = new JSONObject();
                try {
                    if (orderID != 0)
                        paymentRecordDetailParamJson.put("OrderID", orderID);
                    else
                        paymentRecordDetailParamJson.put("PaymentID", paymentID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, paymentRecordDetailParamJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e) {
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
                    }
                    if (code == 1) {
                        JSONArray paymentDetailJsonArray = null;
                        try {
                            paymentDetailJsonArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (paymentDetailJsonArray != null) {
                            try {
                                paymentRecordDetailList = new ArrayList<PaymentRecordDetail>();
                                for (int i = 0; i < paymentDetailJsonArray.length(); i++) {
                                    JSONObject paymentDetailJson = paymentDetailJsonArray.getJSONObject(i);
                                    PaymentRecordDetail paymentRecordDetail = new PaymentRecordDetail();
                                    String paymentRecordDetailCode = "";
                                    String paymentRecordDetailDate = "";
                                    String paymentRecordDetailBranchName = "";
                                    String paymentRecordDetailOperator = "";
                                    String paymentRecordDetailAmount = "";
                                    String paymentRecordDetailRemark = "";
                                    String paymentRecordDetailTypeName = "";
                                    String paymentRecordDetailType = "";
                                    int orderCount = 1;
                                    List<OrderInfo> paymentOrderList = null;
                                    if (paymentDetailJson.has("PaymentCode"))
                                        paymentRecordDetailCode = paymentDetailJson.getString("PaymentCode");
                                    if (paymentDetailJson.has("BranchName"))
                                        paymentRecordDetailBranchName = paymentDetailJson.getString("BranchName");
                                    if (paymentDetailJson.has("PaymentTime"))
                                        paymentRecordDetailDate = paymentDetailJson.getString("PaymentTime");
                                    if (paymentDetailJson.has("Operator"))
                                        paymentRecordDetailOperator = paymentDetailJson.getString("Operator");
                                    if (paymentDetailJson.has("TotalPrice"))
                                        paymentRecordDetailAmount = String.valueOf(Double.valueOf(paymentDetailJson.getString("TotalPrice")));
                                    if (paymentDetailJson.has("TypeName"))
                                        paymentRecordDetailTypeName = paymentDetailJson.getString("TypeName");
                                    if (paymentDetailJson.has("Remark"))
                                        paymentRecordDetailRemark = paymentDetailJson.getString("Remark");
                                    if (paymentDetailJson.has("OrderNumber"))
                                        orderCount = paymentDetailJson.getInt("OrderNumber");
                                    if (paymentDetailJson.has("Type"))
                                        paymentRecordDetailType = paymentDetailJson.getString("Type");
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
                                    List<SalesConsultantRate> salesConsultantRateList = new ArrayList<SalesConsultantRate>();
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
                                    List<BenefitPerson> benefitPersonList = new ArrayList<BenefitPerson>();
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
                                    //订单列表信息
                                    if (paymentDetailJson.has("PaymentOrderList") && !paymentDetailJson.isNull("PaymentOrderList")) {
                                        paymentOrderList = new ArrayList<OrderInfo>();
                                        JSONArray orderJsonArray = paymentDetailJson.getJSONArray("PaymentOrderList");
                                        for (int j = 0; j < orderJsonArray.length(); j++) {
                                            JSONObject orderInfoJson = orderJsonArray.getJSONObject(j);
                                            OrderInfo orderInfo = new OrderInfo();
                                            int orderID = 0;
                                            int orderObjectID = 0;
                                            String orderNumber = "";
                                            String productName = "";
                                            int productType = 0;
                                            String totalSalePrice = "";
                                            if (orderInfoJson.has("OrderID") && !orderInfoJson.isNull("OrderID"))
                                                orderID = orderInfoJson.getInt("OrderID");
                                            if (orderInfoJson.has("OrderObjectID") && !orderInfoJson.isNull("OrderObjectID"))
                                                orderObjectID = orderInfoJson.getInt("OrderObjectID");
                                            if (orderInfoJson.has("OrderNumber") && !orderInfoJson.isNull("OrderNumber"))
                                                orderNumber = orderInfoJson.getString("OrderNumber");
                                            if (orderInfoJson.has("ProductName") && !orderInfoJson.isNull("ProductName"))
                                                productName = orderInfoJson.getString("ProductName");
                                            if (orderInfoJson.has("ProductType") && !orderInfoJson.isNull("ProductType"))
                                                productType = orderInfoJson.getInt("ProductType");
                                            if (orderInfoJson.has("TotalSalePrice") && !orderInfoJson.isNull("TotalSalePrice"))
                                                totalSalePrice = orderInfoJson.getString("TotalSalePrice");
                                            orderInfo.setOrderID(orderID);
                                            orderInfo.setOrderObejctID(orderObjectID);
                                            orderInfo.setOrderSerialNumber(orderNumber);
                                            orderInfo.setProductName(productName);
                                            orderInfo.setProductType(productType);
                                            orderInfo.setTotalSalePrice(totalSalePrice);
                                            paymentOrderList.add(orderInfo);
                                        }
                                    }
                                    paymentRecordDetail.setPaymentRecordDetailCode(paymentRecordDetailCode);
                                    paymentRecordDetail.setPaymentRecordDetailDate(paymentRecordDetailDate);
                                    paymentRecordDetail.setPaymentRecordDetailBranchName(paymentRecordDetailBranchName);
                                    paymentRecordDetail.setPaymentRecordDetailOperator(paymentRecordDetailOperator);
                                    paymentRecordDetail.setPaymentRecordDetailAmount(paymentRecordDetailAmount);
                                    paymentRecordDetail.setPaymentRecordDetailRemark(paymentRecordDetailRemark);
                                    paymentRecordDetail.setPaymentRecordDetailTypeName(paymentRecordDetailTypeName);
                                    paymentRecordDetail.setPaymentRecordDetailType(paymentRecordDetailType);
                                    paymentRecordDetail.setOrderNumber(orderCount);
                                    paymentRecordDetail.setConsultantList(salesConsultantRateList);
                                    paymentRecordDetail.setProfitList(benefitPersonList);
                                    paymentRecordDetail.setPaymentOrderList(paymentOrderList);
                                    paymentRecordDetailList.add(paymentRecordDetail);
                                }

                            } catch (NumberFormatException e) {
                                e.printStackTrace();
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        Message msg = new Message();
                        msg.what = 1;
                        msg.obj = paymentRecordDetailList;
                        mHandler.sendMessage(msg);
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
}
