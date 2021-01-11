package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.CategoryInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ReportBasic;
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
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

@SuppressLint("ResourceType")
public class ReportByDateActivity extends BaseActivity implements OnClickListener {
    private ReportByDateActivityHandler mHandler = new ReportByDateActivityHandler(this);
    private RelativeLayout serviceProjectSalesTotalAnalyticsRelativeLayout,
            serviceCustomerConsumeNumberAnalyticsRelativeLayout,
            productSalesTotalAnalyticsRelativeLayout,
            productCustomerConsumeNumberAnalyticsRelativeLayout,
            reportByOtherRelativeLayout, customerEcardBalanceChangeAnalyticsRelativelayout, treatmentTotalRelativelayout,
            serviceTreatmentTimesAndMoneyAnalyticsRelativelayout, serviceTreatmentCustomerAnalyticsRelativelayout;
    private int reportType, cycleType, objectType, objectID, statementCategoryID = 0, extractItemType = 1;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private TextView reportByDateTitleText, reportFilterTagView, serviceTotalText,
            serviceSaleCashText, serviceSaleBankCardText,
            serviceSaleECardText, serviceOtherText,
            productTotalText, productSaleCashText, productSaleBankCardText,
            productSaleECardText, productOtherText,
            cashAndBankCardIncomeText, cashIncomeText, bankCardIncomeText,
            ecardBalanceText, ecardSalesText, ecardConsumeText, serviceOverAllText, serviceOverAllDesignedText, serviceOverAllNotDesignedText,
            serviceTreatmentTimesTotalText, serviceTreatmentTimesTotalDesignedText, serviceTreatmentTimesTotalNotDesignedText, serviceCustomerTotalText, serviceCustomerFemaleText, serviceCustomerMaleText,
            serviceTreatmentTimesDesignedRateText;
    private UserInfoApplication userinfoApplication;
    private String reportByOtherStartTime, reportByOtherEndTime;
    private TableLayout ecardBalanceTableLayout, ecardSalesIncomeTableLayout;
    private PackageUpdateUtil packageUpdateUtil;
    private List<CategoryInfo> statementCategoryList;
    private RelativeLayout filterRelativelayout;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_report_by_date);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private void initView() {
        reportByDateTitleText = (TextView) findViewById(R.id.report_by_date_title_text);
        reportFilterTagView = (TextView) findViewById(R.id.report_filter_tag_view);
        reportFilterTagView.setOnClickListener(this);
        serviceProjectSalesTotalAnalyticsRelativeLayout = (RelativeLayout) findViewById(R.id.service_project_sale_total_relativelayout);
        serviceProjectSalesTotalAnalyticsRelativeLayout.setOnClickListener(this);
        serviceCustomerConsumeNumberAnalyticsRelativeLayout = (RelativeLayout) findViewById(R.id.service_customer_consume_number_analytics_relativelayout);
        serviceCustomerConsumeNumberAnalyticsRelativeLayout.setOnClickListener(this);
        productSalesTotalAnalyticsRelativeLayout = (RelativeLayout) findViewById(R.id.product_sale_total_relativelayout);
        productSalesTotalAnalyticsRelativeLayout.setOnClickListener(this);
        productCustomerConsumeNumberAnalyticsRelativeLayout = (RelativeLayout) findViewById(R.id.product_customer_consume_number_analytics_relativelayout);
        productCustomerConsumeNumberAnalyticsRelativeLayout.setOnClickListener(this);
        customerEcardBalanceChangeAnalyticsRelativelayout = (RelativeLayout) findViewById(R.id.customer_ecard_balance_change_analytics_relativelayout);
        customerEcardBalanceChangeAnalyticsRelativelayout.setOnClickListener(this);
        serviceTotalText = (TextView) findViewById(R.id.service_total_text);
        productTotalText = (TextView) findViewById(R.id.product_total_text);
        cashAndBankCardIncomeText = (TextView) findViewById(R.id.cash_and_bank_card_total_income_text);
        cashIncomeText = (TextView) findViewById(R.id.cash_total_income_text);
        bankCardIncomeText = (TextView) findViewById(R.id.bank_card_total_income_text);
        ecardBalanceText = (TextView) findViewById(R.id.ecard_balance_total_text);
        ecardSalesText = (TextView) findViewById(R.id.ecard_sales_total_text);
        ecardConsumeText = (TextView) findViewById(R.id.ecard_consume_total_text);
        serviceOverAllText = (TextView) findViewById(R.id.service_overall_total_text);
        serviceOverAllDesignedText = (TextView) findViewById(R.id.service_designed_total_text);
        serviceOverAllNotDesignedText = (TextView) findViewById(R.id.service_not_designed_total_text);
        serviceTreatmentTimesTotalText = (TextView) findViewById(R.id.service_treatment_times_total_text);
        serviceTreatmentTimesTotalDesignedText = (TextView) findViewById(R.id.service_treatment_times_designed_total_text);
        serviceTreatmentTimesTotalNotDesignedText = (TextView) findViewById(R.id.service_treatment_times_not_designed_total_text);
        //增加指定率 2017/11/30
        serviceTreatmentTimesDesignedRateText = (TextView) findViewById(R.id.service_treatment_times_designed_rate_text);
        serviceCustomerTotalText = (TextView) findViewById(R.id.service_customer_total_text);
        serviceCustomerFemaleText = (TextView) findViewById(R.id.service_customer_total_female_text);
        serviceCustomerMaleText = (TextView) findViewById(R.id.service_customer_total_male_text);
        treatmentTotalRelativelayout = (RelativeLayout) findViewById(R.id.service_treatment_times_analytics_relativelayout);
        treatmentTotalRelativelayout.setOnClickListener(this);
        serviceTreatmentTimesAndMoneyAnalyticsRelativelayout = (RelativeLayout) findViewById(R.id.service_treatment_times_and_money_analytics_relativelayout);
        serviceTreatmentTimesAndMoneyAnalyticsRelativelayout.setOnClickListener(this);
        serviceTreatmentCustomerAnalyticsRelativelayout = (RelativeLayout) findViewById(R.id.service_treatment_customer_analytics_relativelayout);
        serviceTreatmentCustomerAnalyticsRelativelayout.setOnClickListener(this);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        Intent intent = getIntent();
        reportType = intent.getIntExtra("REPORT_TYPE", 0);
        objectID = intent.getIntExtra("OBJECT_ID", 0);
        serviceSaleCashText = (TextView) findViewById(R.id.service_sale_cash_text);
        serviceSaleBankCardText = (TextView) findViewById(R.id.service_sale_bank_card_text);
        serviceSaleECardText = (TextView) findViewById(R.id.service_sale_ecard_text);
        serviceOtherText = (TextView) findViewById(R.id.service_sale_other_text);
        productSaleCashText = (TextView) findViewById(R.id.product_sale_cash_text);
        productSaleBankCardText = (TextView) findViewById(R.id.product_sale_bank_card_text);
        productSaleECardText = (TextView) findViewById(R.id.product_sale_ecard_text);
        productOtherText = (TextView) findViewById(R.id.product_sale_other_text);
        ecardBalanceTableLayout = (TableLayout) findViewById(R.id.ecard_balance_table_layout);
        ecardSalesIncomeTableLayout = (TableLayout) findViewById(R.id.ecard_sales_table_layout);
        filterRelativelayout = (RelativeLayout) findViewById(R.id.filter_relativelayout);
        // 从前一个界面接收查询的类型
        cycleType = intent.getIntExtra("CYCLE_TYPE", 0);
        if (cycleType == 4) {
            reportByOtherStartTime = intent.getStringExtra("START_TIME");
            reportByOtherEndTime = intent.getStringExtra("END_TIME");
            if (reportByOtherRelativeLayout.getVisibility() == View.GONE)
                reportByOtherRelativeLayout.setVisibility(View.VISIBLE);
        } else {
            Calendar nowDate = Calendar.getInstance();
            int nowYear = nowDate.get(Calendar.YEAR);
            int nowMonth = nowDate.get(Calendar.MONTH) + 1;
            int nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
            reportByOtherStartTime = nowYear + "-" + nowMonth + "-" + nowDay;
            reportByOtherEndTime = nowYear + "-" + nowMonth + "-" + nowDay;
        }
        if (reportType == Constant.MY_REPORT) {
            objectType = 0;
            reportByDateTitleText.setText(R.string.my_report_text);
        }
        // 本店
        else if (reportType == Constant.MY_BRANCH_REPORT) {
            ecardBalanceTableLayout.setVisibility(View.VISIBLE);
            ecardSalesIncomeTableLayout.setVisibility(View.VISIBLE);
            objectType = 1;
            reportByDateTitleText.setText(R.string.my_branch_report_text);
        }
        // 公司
        else if (reportType == Constant.COMPANY_REPORT) {
            objectType = 2;
            reportByDateTitleText.setText(R.string.company_report_text);
        } else if (reportType == Constant.EMPLOYEE_REPORT) {
            objectType = 0;
            reportByDateTitleText.setText(R.string.employee_report_text);
        }
        // 分店
        else if (reportType == Constant.ALL_BRANCH_REPORT) {
            ecardBalanceTableLayout.setVisibility(View.VISIBLE);
            ecardSalesIncomeTableLayout.setVisibility(View.VISIBLE);
            objectType = 1;
            reportByDateTitleText.setText(R.string.all_branch_report_text);
        } else if (reportType == Constant.GROUP_REPORT) {
            objectType = 3;
            reportByDateTitleText.setText(R.string.group_report_text);
        }
        requestWebService(cycleType, objectType);
    }

    private static class ReportByDateActivityHandler extends Handler {
        private final ReportByDateActivity reportByDateActivity;

        private ReportByDateActivityHandler(ReportByDateActivity activity) {
            WeakReference<ReportByDateActivity> weakReference = new WeakReference<ReportByDateActivity>(activity);
            reportByDateActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (reportByDateActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (reportByDateActivity.progressDialog != null) {
                reportByDateActivity.progressDialog.dismiss();
                reportByDateActivity.progressDialog = null;
            }
            if (message.what == 1) {
                ReportBasic rb = (ReportBasic) message.obj;
                NumberFormat numberFormat = NumberFormat.getInstance();
                numberFormat.setMaximumFractionDigits(2);
                //服务销售
                BigDecimal serviceTotalBigDecimal = new BigDecimal(rb.getSalesServiceTotal());
                BigDecimal serviceTotalCashBigDecimal = new BigDecimal(rb.getSalesServiceTotalCash());
                BigDecimal serviceTotalBankCardBigDecimal = new BigDecimal(rb.getSalesServiceTotalBankcard());
                BigDecimal serviceTotalWeiXinBigDecimal = new BigDecimal(rb.getSalesServiceTotalWeiXin());
                BigDecimal serviceTotalAliBigDecimal = new BigDecimal(rb.getSalesServiceTotalAli());
                BigDecimal serviceTotaleCardBigDecimal = new BigDecimal(rb.getSalesServiceTotalEcard());
                BigDecimal serviceTotalPointBigDecimal = new BigDecimal(rb.getSalesServiceRevenuePoint());
                BigDecimal serviceTotalCouponBigDecimal = new BigDecimal(rb.getSalesServiceRevenueCoupon());
                BigDecimal serviceTotalOtherBigDecimal = new BigDecimal(rb.getSalesServiceTotalOther());
                BigDecimal serviceTotalLoanBigDecimal = new BigDecimal(rb.getSalesServiceTotalLoan());
                BigDecimal serviceTotalFromThirdBigDecimal = new BigDecimal(rb.getSalesServiceTotalFromThird());
                //商品销售
                BigDecimal productTotalBigDecimal = new BigDecimal(rb.getSalesProductTotal());
                BigDecimal productTotalCashBigDecimal = new BigDecimal(rb.getSalesProductTotalCash());
                BigDecimal productTotalBankCardBigDecimal = new BigDecimal(rb.getSalesProductTotalBankcard());
                BigDecimal productTotalWeiXinBigDecimal = new BigDecimal(rb.getSalesProductTotalWeiXin());
                BigDecimal productTotalAliBigDecimal = new BigDecimal(rb.getSalesProductTotalAli());
                BigDecimal productTotaleCardBigDecimal = new BigDecimal(rb.getSalesProductTotalEcard());
                BigDecimal productTotalPointBigDecimal = new BigDecimal(rb.getSalesProductRevenuePoint());
                BigDecimal productTotalCouponBigDecimal = new BigDecimal(rb.getSalesProductRevenueCoupon());
                BigDecimal productTotalOtherBigDecimal = new BigDecimal(rb.getSalesProductTotalOther());
                BigDecimal productTotalLoanBigDecimal = new BigDecimal(rb.getSalesProductTotalLoan());
                BigDecimal productTotalFromThirdBigDecimal = new BigDecimal(rb.getSalesProductTotalFromThird());

                BigDecimal cashAndBankCardIncomeBigDecimal = new BigDecimal(rb.getCashAndBankcardIncome());
                BigDecimal cashIncomeBigDecimal = new BigDecimal(rb.getCashIncome());
                BigDecimal bankCardIncomeBigDecimal = new BigDecimal(rb.getBankcardIncome());
                BigDecimal weiXinIncomeBigDecimal = new BigDecimal(rb.getWeiXinIncome());
                BigDecimal aliIncomeBigDecimal = new BigDecimal(rb.getAliIncome());
                BigDecimal loanIncomeBigDecimal = new BigDecimal(rb.getLoanIncome());
                BigDecimal fromThirdIncomeBigDecimal = new BigDecimal(rb.getFromThirdIncome());
                BigDecimal ecardSalesAllIncomeBigDecimal = new BigDecimal(rb.getEcardSalesAllIncome());
                BigDecimal ecardSalesCashIncomeBigDecimal = new BigDecimal(rb.getEcardSalesCashIncome());
                BigDecimal ecardSalesBankCardIncomeBigDecimal = new BigDecimal(rb.getEcardSalesBankCardIncome());
                BigDecimal ecardSalesWebChatIncomeBigDecimal = new BigDecimal(rb.getEcardSalesWebChatIncome());
                BigDecimal ecardSalesAliIncomeBigDecimal = new BigDecimal(rb.getEcardSalesAliIncome());
                BigDecimal ecardBalanceBigDecimal = new BigDecimal(rb.getEcardBalance());
                BigDecimal ecardSalesBigDecimal = new BigDecimal(rb.getEcardSales());
                BigDecimal ecardConsumeBigDecimal = new BigDecimal(rb.getEcardConsume());
                BigDecimal serviceOverAllBigDecimal = new BigDecimal(rb.getServiceOverAll());
                BigDecimal serviceOverAllDesignedBigDecimal = new BigDecimal(rb.getServiceOverAllDesigned());
                BigDecimal serviceOverAllNotDesignedBigDecimal = new BigDecimal(rb.getServiceOverAllNotDesigned());
                reportByDateActivity.serviceTotalText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalBigDecimal));
                reportByDateActivity.serviceSaleCashText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalCashBigDecimal));
                reportByDateActivity.serviceSaleBankCardText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalBankCardBigDecimal));
                reportByDateActivity.serviceSaleECardText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotaleCardBigDecimal));
                reportByDateActivity.serviceOtherText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalOtherBigDecimal));

                reportByDateActivity.productTotalText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalBigDecimal));
                reportByDateActivity.productSaleCashText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalCashBigDecimal));
                reportByDateActivity.productSaleBankCardText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalBankCardBigDecimal));
                reportByDateActivity.productSaleECardText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotaleCardBigDecimal));
                reportByDateActivity.productOtherText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalOtherBigDecimal));

                reportByDateActivity.cashAndBankCardIncomeText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(cashAndBankCardIncomeBigDecimal));
                reportByDateActivity.cashIncomeText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(cashIncomeBigDecimal));
                reportByDateActivity.bankCardIncomeText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(bankCardIncomeBigDecimal));
                reportByDateActivity.ecardBalanceText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardBalanceBigDecimal));
                reportByDateActivity.ecardSalesText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesBigDecimal));
                reportByDateActivity.ecardConsumeText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardConsumeBigDecimal));
                reportByDateActivity.serviceOverAllText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceOverAllBigDecimal));
                reportByDateActivity.serviceOverAllDesignedText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceOverAllDesignedBigDecimal));
                reportByDateActivity.serviceOverAllNotDesignedText.setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceOverAllNotDesignedBigDecimal));
                reportByDateActivity.serviceTreatmentTimesTotalText.setText(rb.getServiceTreatmentTimesAll() + "次");
                reportByDateActivity.serviceTreatmentTimesTotalDesignedText.setText(rb.getServiceTreatmentTimesDesigned() + "次");
                reportByDateActivity.serviceTreatmentTimesTotalNotDesignedText.setText(rb.getServiceTreatmentTimesNotDesigned() + "次");
                //增加指定率 2017/11/30
                int rate = 0;
                if (rb.getServiceTreatmentTimesAll() != 0) {
                    rate = (rb.getServiceTreatmentTimesDesigned() * 100) / rb.getServiceTreatmentTimesAll();
                }
                reportByDateActivity.serviceTreatmentTimesDesignedRateText.setText(rate + "% ");
                reportByDateActivity.serviceCustomerTotalText.setText(rb.getServiceCustomerAll() + "位");
                reportByDateActivity.serviceCustomerFemaleText.setText(rb.getServiceCustomerFemale() + "位");
                reportByDateActivity.serviceCustomerMaleText.setText(rb.getServiceCustomerMale() + "位");
                ((TextView) reportByDateActivity.findViewById(R.id.add_new_customer_text)).setText(rb.getNewAddCustomer() + "位");
                ((TextView) reportByDateActivity.findViewById(R.id.add_new_effective_customer_text)).setText(rb.getNewAddEffectCustomer() + "位");
                ((TextView) reportByDateActivity.findViewById(R.id.old_effect_cutomer_text)).setText(rb.getOldEffectCustomer() + "位");
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_point_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalPointBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_coupon_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalCouponBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_loan_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalLoanBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_from_third_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalFromThirdBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_point_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalPointBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_coupon_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalCouponBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_loan_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalLoanBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_from_third_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalFromThirdBigDecimal));
                //服务 和商品微信收入和支付宝收入 或者是微信总收入和支付宝收入
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_weixin_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalWeiXinBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.service_sale_ali_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(serviceTotalAliBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_weixin_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalWeiXinBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.product_sale_ali_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(productTotalAliBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.weixin_total_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(weiXinIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.ali_total_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(aliIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.loan_total_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(loanIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.from_third_total_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(fromThirdIncomeBigDecimal));
                //储值卡销售
                ((TextView) reportByDateActivity.findViewById(R.id.ecard_sales_all_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesAllIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.ecard_sales_cash_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesCashIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.ecard_sales_bank_card_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesBankCardIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.ecard_sales_web_chat_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesWebChatIncomeBigDecimal));
                ((TextView) reportByDateActivity.findViewById(R.id.ecard_sales_ali_income_text)).setText(reportByDateActivity.userinfoApplication.getAccountInfo().getCurrency() + numberFormat.format(ecardSalesAliIncomeBigDecimal));
                //请求业绩分类
                reportByDateActivity.requestStatementCategory();
                //根据筛选业绩的分类做相应的处理
                reportByDateActivity.showHiddenView();
            } else if (message.what == 2)
                DialogUtil.createShortDialog(reportByDateActivity, "您的网络貌似不给力，请重试");
            else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(reportByDateActivity,
                        reportByDateActivity.getString(R.string.login_error_message));
                reportByDateActivity.userinfoApplication.exitForLogin(reportByDateActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + reportByDateActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(reportByDateActivity);
                reportByDateActivity.packageUpdateUtil = new PackageUpdateUtil(reportByDateActivity, reportByDateActivity.mHandler, fileCache, downloadFileUrl, false, reportByDateActivity.userinfoApplication);
                reportByDateActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                reportByDateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = reportByDateActivity.getFileStreamPath(filename);
                file.getName();
                reportByDateActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (reportByDateActivity.requestWebServiceThread != null) {
                reportByDateActivity.requestWebServiceThread.interrupt();
                reportByDateActivity.requestWebServiceThread = null;
            }
        }
    }

    private void requestWebService(int cycleType, int objectType) {
        final int ct = cycleType;
        final int ot = objectType;
        progressDialog = new ProgressDialog(this, R.style.CustomerProgressDialog);
        progressDialog.setMessage(getString(R.string.please_wait));
        progressDialog.show();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetReportBasic_2_1";
                String endPoint = "report";
                JSONObject reportBasicJson = new JSONObject();
                try {
                    if (reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT) {
                        reportBasicJson.put("AccountID", objectID);
                    } else
                        reportBasicJson.put("AccountID", userinfoApplication
                                .getAccountInfo().getAccountId());
                    reportBasicJson.put("CycleType", ct);
                    reportBasicJson.put("ObjectType", ot);
                    reportBasicJson.put("StatementCategoryID", statementCategoryID);
                    reportBasicJson.put("ExtractItemType", extractItemType);
                    // 如果是按照日期查询
                    if (ct == 4) {
                        reportBasicJson.put("StartTime", reportByOtherStartTime);
                        reportBasicJson.put("EndTime", reportByOtherEndTime);
                    }
                } catch (JSONException e) {
                }
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportBasicJson.toString(), userinfoApplication);
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
                        JSONObject reportBasic = null;
                        try {
                            reportBasic = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {

                        }
                        if (reportBasic != null) {
                            double salesServiceTotal = 0;// 服务销售额
                            double salesServiceTotalCash = 0;//服务销售-现金
                            double salesServiceTotalBankcard = 0;//服务销售-银行卡
                            double salesServiceTotalWeiXin = 0;//服务销售-微信
                            double salesServiceTotalAli = 0;//服务销售-支付宝
                            double salesServiceTotalLoan = 0;//服务销售-消费贷款
                            double salesServiceTotalFromThird = 0;//服务销售-第三方付款
                            double salesServiceTotalEcard = 0;//服务销售-e卡
                            double salesServiceRevenuePoint = 0;//服务销售-积分抵扣
                            double salesServiceRevenueCoupon = 0;//服务销售-券抵扣
                            double salesServiceTotalOther = 0;//服务销售-其他
                            double salesProductTotal = 0;// 商品销售额
                            double salesProductTotalCash = 0;//商品销售-现金
                            double salesProductTotalBankcard = 0;//商品销售-银行卡
                            double salesProductTotalWeiXin = 0;//商品销售-微信
                            double salesProductTotalAli = 0;//商品销售-支付宝
                            double salesProductTotalEcard = 0;//商品销售-e卡
                            double salesProductTotalLoan = 0;//商品销售-消费贷款
                            double salesProductTotalFromThird = 0;//商品销售-第三方付款
                            double salesProductRevenuePoint = 0;//商品销售-积分抵扣
                            double salesProductRevenueCoupon = 0;//商品销售-券抵扣
                            double salesProductTotalOther = 0;//商品销售-其他
                            double cashAndBankcardIncome = 0;// 现金和银行卡总收入
                            double cashIncome = 0;// 现金总收入
                            double bankcardIncome = 0;// 银行卡总收入
                            double weiXinIncome = 0;// 微信总收入
                            double aliIncome = 0;// 支付宝总收入
                            double loanIncome = 0;//消费贷款总收入
                            double fromThirdIncome = 0;//第三方付款总收入
                            double ecardSalesAllIncome = 0;//储值卡销售
                            double ecardSalesCashIncome = 0;//储值卡销售-现金
                            double ecardSalesBankCardIncome = 0;//储值卡销售-银行卡
                            double ecardSalesWebChatIncome = 0;//储值卡销售-微信
                            double ecardSalesAliIncome = 0;//储值卡销售-支付宝
                            double ecardBalance = 0;// e卡余额
                            double ecardSales = 0;// e卡销售
                            double ecardConsume = 0;// e卡消耗
                            double serviceOverAll = 0;// 服务总业绩
                            double serviceOverAllDesigned = 0;// 指定业绩
                            double serviceOverAllNotDesigned = 0;// 非指定业绩
                            int serviceTreatmentTimesAll = 0;// 服务总次数
                            int serviceTreatmentTimesDesigned = 0;// 指定次数
                            int serviceTreatmentTimesNotDesigned = 0;// 非指定次数
                            int serviceCustomerAll = 0;// 服务总客数
                            int serviceCustomerFemale = 0;// 服务女性客数
                            int serviceCustomerMale = 0;// 服务男性客数
                            int newAddCustomer = 0;// 新增顾客
                            int newAddEffectCustomer = 0;// 新增有效顾客(开卡并且消费)
                            int oldEffectCustomer = 0;// 再次消费老顾客
                            try {
                                /*
                                 * 服务销售的金额，以及现金 银行卡  e卡销售和其他详细
                                 * */
                                if (reportBasic.has("ServiceRevenueAll"))
                                    salesServiceTotal = reportBasic.getDouble("ServiceRevenueAll");
                                if (reportBasic.has("ServiceRevenueCash"))
                                    salesServiceTotalCash = reportBasic.getDouble("ServiceRevenueCash");
                                if (reportBasic.has("ServiceRevenueBank"))
                                    salesServiceTotalBankcard = reportBasic.getDouble("ServiceRevenueBank");
                                if (reportBasic.has("ServiceRevenueWeChat"))
                                    salesServiceTotalWeiXin = reportBasic.getDouble("ServiceRevenueWeChat");
                                if (reportBasic.has("ServiceRevenueAlipay"))
                                    salesServiceTotalAli = reportBasic.getDouble("ServiceRevenueAlipay");
                                if (reportBasic.has("ServiceRevenueECard"))
                                    salesServiceTotalEcard = reportBasic.getDouble("ServiceRevenueECard");
                                if (reportBasic.has("ServiceRevenuePoint"))
                                    salesServiceRevenuePoint = reportBasic.getDouble("ServiceRevenuePoint");
                                if (reportBasic.has("ServiceRevenueCoupon"))
                                    salesServiceRevenueCoupon = reportBasic.getDouble("ServiceRevenueCoupon");
                                if (reportBasic.has("ServiceRevenueOther"))
                                    salesServiceTotalOther = reportBasic.getDouble("ServiceRevenueOther");
                                if (reportBasic.has("ServiceRevenueLoan"))
                                    salesServiceTotalLoan = reportBasic.getDouble("ServiceRevenueLoan");
                                if (reportBasic.has("ServiceRevenueThird"))
                                    salesServiceTotalFromThird = reportBasic.getDouble("ServiceRevenueThird");
                                /*
                                 * 商品销售的金额，以及现金 银行卡  e卡销售和其他详细
                                 * */
                                if (reportBasic.has("CommodityRevenueAll"))
                                    salesProductTotal = reportBasic.getDouble("CommodityRevenueAll");
                                if (reportBasic.has("CommodityRevenueCash"))
                                    salesProductTotalCash = reportBasic.getDouble("CommodityRevenueCash");
                                if (reportBasic.has("CommodityRevenueBank"))
                                    salesProductTotalBankcard = reportBasic.getDouble("CommodityRevenueBank");
                                if (reportBasic.has("CommodityRevenueWeChat"))
                                    salesProductTotalWeiXin = reportBasic.getDouble("CommodityRevenueWeChat");
                                if (reportBasic.has("CommodityRevenueAlipay"))
                                    salesProductTotalAli = reportBasic.getDouble("CommodityRevenueAlipay");
                                if (reportBasic.has("CommodityRevenueECard"))
                                    salesProductTotalEcard = reportBasic.getDouble("CommodityRevenueECard");
                                if (reportBasic.has("CommodityRevenuePoint"))
                                    salesProductRevenuePoint = reportBasic.getDouble("CommodityRevenuePoint");
                                if (reportBasic.has("CommodityRevenueCoupon"))
                                    salesProductRevenueCoupon = reportBasic.getDouble("CommodityRevenueCoupon");
                                if (reportBasic.has("CommodityRevenueOther"))
                                    salesProductTotalOther = reportBasic.getDouble("CommodityRevenueOther");
                                if (reportBasic.has("CommodityRevenueLoan"))
                                    salesProductTotalLoan = reportBasic.getDouble("CommodityRevenueLoan");
                                if (reportBasic.has("CommodityRevenueThird"))
                                    salesProductTotalFromThird = reportBasic.getDouble("CommodityRevenueThird");

                                if (reportBasic.has("SalesAllIncome"))
                                    cashAndBankcardIncome = reportBasic.getDouble("SalesAllIncome");
                                if (reportBasic.has("SalesCashIncome"))
                                    cashIncome = reportBasic.getDouble("SalesCashIncome");
                                if (reportBasic.has("SalesBankIncome"))
                                    bankcardIncome = reportBasic.getDouble("SalesBankIncome");
                                if (reportBasic.has("SalesWeChatIncome"))
                                    weiXinIncome = reportBasic.getDouble("SalesWeChatIncome");
                                if (reportBasic.has("SalesAlipayIncome"))
                                    aliIncome = reportBasic.getDouble("SalesAlipayIncome");
                                if (reportBasic.has("SalesRevenueLoan"))
                                    loanIncome = reportBasic.getDouble("SalesRevenueLoan");
                                if (reportBasic.has("SalesRevenueThird"))
                                    fromThirdIncome = reportBasic.getDouble("SalesRevenueThird");

                                if (reportBasic.has("EcardSalesAllIncome"))
                                    ecardSalesAllIncome = reportBasic.getDouble("EcardSalesAllIncome");
                                if (reportBasic.has("EcardSalesCashIncome"))
                                    ecardSalesCashIncome = reportBasic.getDouble("EcardSalesCashIncome");
                                if (reportBasic.has("EcardSalesBankIncome"))
                                    ecardSalesBankCardIncome = reportBasic.getDouble("EcardSalesBankIncome");
                                if (reportBasic.has("EcardWeChatIncome"))
                                    ecardSalesWebChatIncome = reportBasic.getDouble("EcardWeChatIncome");
                                if (reportBasic.has("EcardAlipayIncome"))
                                    ecardSalesAliIncome = reportBasic.getDouble("EcardAlipayIncome");
                                if (reportBasic.has("ECardBalance"))
                                    ecardBalance = reportBasic.getDouble("ECardBalance");
                                if (reportBasic.has("ECardSales"))
                                    ecardSales = reportBasic.getDouble("ECardSales");
                                if (reportBasic.has("ECardConsume"))
                                    ecardConsume = reportBasic.getDouble("ECardConsume");
                                if (reportBasic.has("ServiceAchievementAll"))
                                    serviceOverAll = reportBasic.getDouble("ServiceAchievementAll");
                                if (reportBasic.has("ServiceAchievementDesigned"))
                                    serviceOverAllDesigned = reportBasic.getDouble("ServiceAchievementDesigned");
                                if (reportBasic.has("ServiceAchievementNotDesigned"))
                                    serviceOverAllNotDesigned = reportBasic.getDouble("ServiceAchievementNotDesigned");
                                if (reportBasic.has("TreatmentTimesAll"))
                                    serviceTreatmentTimesAll = reportBasic.getInt("TreatmentTimesAll");
                                if (reportBasic.has("TreatmentTimesDesigned"))
                                    serviceTreatmentTimesDesigned = reportBasic.getInt("TreatmentTimesDesigned");
                                if (reportBasic.has("TreatmentTimesNotDesigned"))
                                    serviceTreatmentTimesNotDesigned = reportBasic.getInt("TreatmentTimesNotDesigned");
                                if (reportBasic.has("ServiceCustomerCountAll"))
                                    serviceCustomerAll = reportBasic.getInt("ServiceCustomerCountAll");
                                if (reportBasic.has("ServiceCustomerCountFemale"))
                                    serviceCustomerFemale = reportBasic.getInt("ServiceCustomerCountFemale");
                                if (reportBasic.has("ServiceCustomerCountMale"))
                                    serviceCustomerMale = reportBasic.getInt("ServiceCustomerCountMale");
                                if (reportBasic.has("NewAddCustomer"))
                                    newAddCustomer = reportBasic.getInt("NewAddCustomer");
                                if (reportBasic.has("NewAddEffectCustomer"))
                                    newAddEffectCustomer = reportBasic.getInt("NewAddEffectCustomer");
                                if (reportBasic.has("OldEffectCustomer"))
                                    oldEffectCustomer = reportBasic.getInt("OldEffectCustomer");
                            } catch (JSONException e) {
                            }
                            ReportBasic reBasic = new ReportBasic();
                            reBasic.setSalesServiceTotal(salesServiceTotal);
                            reBasic.setSalesServiceTotalBankcard(salesServiceTotalBankcard);
                            reBasic.setSalesServiceTotalWeiXin(salesServiceTotalWeiXin);
                            reBasic.setSalesServiceTotalAli(salesServiceTotalAli);
                            reBasic.setSalesServiceTotalCash(salesServiceTotalCash);
                            reBasic.setSalesServiceRevenuePoint(salesServiceRevenuePoint);
                            reBasic.setSalesServiceRevenueCoupon(salesServiceRevenueCoupon);
                            reBasic.setSalesServiceTotalEcard(salesServiceTotalEcard);
                            reBasic.setSalesServiceTotalOther(salesServiceTotalOther);
                            reBasic.setSalesServiceTotalLoan(salesServiceTotalLoan);
                            reBasic.setSalesServiceTotalFromThird(salesServiceTotalFromThird);

                            reBasic.setSalesProductTotal(salesProductTotal);
                            reBasic.setSalesProductTotalBankcard(salesProductTotalBankcard);
                            reBasic.setSalesProductTotalWeiXin(salesProductTotalWeiXin);
                            reBasic.setSalesProductTotalAli(salesProductTotalAli);
                            reBasic.setSalesProductTotalCash(salesProductTotalCash);
                            reBasic.setSalesProductTotalEcard(salesProductTotalEcard);
                            reBasic.setSalesProductRevenuePoint(salesProductRevenuePoint);
                            reBasic.setSalesProductRevenueCoupon(salesProductRevenueCoupon);
                            reBasic.setSalesProductTotalOther(salesProductTotalOther);
                            reBasic.setSalesProductTotalLoan(salesProductTotalLoan);
                            reBasic.setSalesProductTotalFromThird(salesProductTotalFromThird);

                            reBasic.setEcardSalesAllIncome(ecardSalesAllIncome);
                            reBasic.setEcardSalesCashIncome(ecardSalesCashIncome);
                            reBasic.setEcardSalesBankCardIncome(ecardSalesBankCardIncome);
                            reBasic.setEcardSalesWebChatIncome(ecardSalesWebChatIncome);
                            reBasic.setEcardSalesAliIncome(ecardSalesAliIncome);
                            reBasic.setCashAndBankcardIncome(cashAndBankcardIncome);
                            reBasic.setCashIncome(cashIncome);
                            reBasic.setBankcardIncome(bankcardIncome);
                            reBasic.setWeiXinIncome(weiXinIncome);
                            reBasic.setAliIncome(aliIncome);
                            reBasic.setLoanIncome(loanIncome);
                            reBasic.setFromThirdIncome(fromThirdIncome);

                            reBasic.setEcardBalance(ecardBalance);
                            reBasic.setEcardSales(ecardSales);
                            reBasic.setEcardConsume(ecardConsume);
                            reBasic.setServiceOverAll(serviceOverAll);
                            reBasic.setServiceOverAllDesigned(serviceOverAllDesigned);
                            reBasic.setServiceOverAllNotDesigned(serviceOverAllNotDesigned);
                            reBasic.setServiceTreatmentTimesAll(serviceTreatmentTimesAll);
                            reBasic.setServiceTreatmentTimesDesigned(serviceTreatmentTimesDesigned);
                            reBasic.setServiceTreatmentTimesNotDesigned(serviceTreatmentTimesNotDesigned);
                            reBasic.setServiceCustomerAll(serviceCustomerAll);
                            reBasic.setServiceCustomerFemale(serviceCustomerFemale);
                            reBasic.setServiceCustomerMale(serviceCustomerMale);
                            reBasic.setNewAddCustomer(newAddCustomer);
                            reBasic.setNewAddEffectCustomer(newAddEffectCustomer);
                            reBasic.setOldEffectCustomer(oldEffectCustomer);
                            Message message = new Message();
                            message.obj = reBasic;
                            message.what = 1;
                            mHandler.sendMessage(message);
                        }
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void showHiddenView() {
        //如果是服务和商品
        if (extractItemType == 1) {
            findViewById(R.id.report_basic_service).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_commodity).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_cash_and_bank_card).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_service_overall).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_service_treatment_times).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_service_treatment_analytics).setVisibility(View.VISIBLE);
            findViewById(R.id.ecard_sales_table_layout).setVisibility(View.GONE);
            findViewById(R.id.ecard_balance_table_layout).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_customer_total).setVisibility(View.GONE);
            findViewById(R.id.report_basic_statistics_customer).setVisibility(View.GONE);
        }
        //储值卡
        else if (extractItemType == 2) {
            findViewById(R.id.report_basic_service).setVisibility(View.GONE);
            findViewById(R.id.report_basic_commodity).setVisibility(View.GONE);
            findViewById(R.id.report_basic_cash_and_bank_card).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_overall).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_treatment_times).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_treatment_analytics).setVisibility(View.GONE);
            findViewById(R.id.ecard_sales_table_layout).setVisibility(View.VISIBLE);
            findViewById(R.id.ecard_balance_table_layout).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_service_customer_total).setVisibility(View.GONE);
            findViewById(R.id.report_basic_statistics_customer).setVisibility(View.GONE);
        }
        //顾客
        else if (extractItemType == 3) {
            findViewById(R.id.report_basic_service).setVisibility(View.GONE);
            findViewById(R.id.report_basic_commodity).setVisibility(View.GONE);
            findViewById(R.id.report_basic_cash_and_bank_card).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_overall).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_treatment_times).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_treatment_analytics).setVisibility(View.GONE);
            findViewById(R.id.ecard_sales_table_layout).setVisibility(View.GONE);
            findViewById(R.id.ecard_balance_table_layout).setVisibility(View.GONE);
            findViewById(R.id.report_basic_service_customer_total).setVisibility(View.VISIBLE);
            findViewById(R.id.report_basic_statistics_customer).setVisibility(View.VISIBLE);
        }

    }

    private void requestStatementCategory() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetStatementCategory";
                String endPoint = "report";
                JSONObject statementCategoryJson = new JSONObject();
                String serverResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, statementCategoryJson.toString(), userinfoApplication);
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
                        JSONArray categoryArray = null;
                        try {
                            categoryArray = resultJson.getJSONArray("Data");
                            statementCategoryList = new ArrayList<CategoryInfo>();
                            CategoryInfo defaultCategory = new CategoryInfo();
                            defaultCategory.setCategoryID("0");
                            defaultCategory.setCategoryName("全部");
                            statementCategoryList.add(defaultCategory);
                            if (categoryArray != null) {

                                for (int i = 0; i < categoryArray.length(); i++) {
                                    JSONObject categoryJson = categoryArray.getJSONObject(i);
                                    CategoryInfo categoryInfo = new CategoryInfo();
                                    if (categoryJson.has("ID") && !categoryJson.isNull("ID"))
                                        categoryInfo.setCategoryID(categoryJson.getString("ID"));
                                    if (categoryJson.has("CategoryName") && !categoryJson.isNull("CategoryName"))
                                        categoryInfo.setCategoryName(categoryJson.getString("CategoryName"));
                                    statementCategoryList.add(categoryInfo);
                                }
                            }
                        } catch (JSONException e) {
                        }
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent destIntent = null;
        switch (view.getId()) {
            //弹出可供选择筛选的视图
            case R.id.report_filter_tag_view:
                if (filterRelativelayout.getVisibility() == View.VISIBLE) {
                    filterRelativelayout.setVisibility(View.GONE);
                } else {
                    showFilterPopwindow();
                }
                break;
            case R.id.service_project_sale_total_relativelayout:
                destIntent = new Intent(this, ServiceAndProductSalesAnalyticsActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 1);
                destIntent.putExtra("PRODUCT_TYPE", 0);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 1);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            case R.id.service_customer_consume_number_analytics_relativelayout:
                destIntent = new Intent(this, ReportDetailListActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 0);
                destIntent.putExtra("PRODUCT_TYPE", 0);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 0);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            case R.id.product_sale_total_relativelayout:
                destIntent = new Intent(this, ServiceAndProductSalesAnalyticsActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 1);
                destIntent.putExtra("PRODUCT_TYPE", 1);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 1);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            case R.id.product_customer_consume_number_analytics_relativelayout:
                destIntent = new Intent(this, ReportDetailListActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 0);
                destIntent.putExtra("PRODUCT_TYPE", 1);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 0);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            case R.id.service_treatment_times_analytics_relativelayout:
                destIntent = new Intent(this, ReportDetailListActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 1);
                destIntent.putExtra("PRODUCT_TYPE", 0);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 2);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            //服务操作分析(包括服务操作次数和服务操作金额)
            case R.id.service_treatment_times_and_money_analytics_relativelayout:
                destIntent = new Intent(this, ServiceAndProductSalesAnalyticsActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 1);
                destIntent.putExtra("PRODUCT_TYPE", 0);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 4);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            //服务操作顾客消费分析
            case R.id.service_treatment_customer_analytics_relativelayout:
                destIntent = new Intent(this, ReportDetailListActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 0);
                destIntent.putExtra("PRODUCT_TYPE", 0);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 5);
                destIntent.putExtra("OBJECT_ID", objectID);
                destIntent.putExtra("CATEGORY_ID", statementCategoryID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
            //顾客余额变动分析
            case R.id.customer_ecard_balance_change_analytics_relativelayout:
                destIntent = new Intent(this, CustomerEcardBalanceChangeAnalyticsActivity.class);
                destIntent.putExtra("REPORT_TYPE", reportType);
                destIntent.putExtra("CYCLE_TYPE", cycleType);
                destIntent.putExtra("ORDER_TYPE", 0);
                destIntent.putExtra("PRODUCT_TYPE", 1);
                destIntent.putExtra("EXTRACT_ITEM_TYPE", 3);
                destIntent.putExtra("OBJECT_ID", objectID);
                if (cycleType == 4) {
                    destIntent.putExtra("START_TIME", reportByOtherStartTime);
                    destIntent.putExtra("END_TIME", reportByOtherEndTime);
                }
                startActivity(destIntent);
                break;
        }
    }

    protected void showFilterPopwindow() {
        final LinearLayout filterCategoryLinearlayout = (LinearLayout) filterRelativelayout.findViewById(R.id.filter_category_linearlayout);
        final TextView filterServiceCommodity = (TextView) filterCategoryLinearlayout.findViewById(R.id.filter_by_service_and_commodity);
        final TextView filterEcard = (TextView) filterCategoryLinearlayout.findViewById(R.id.filter_by_ecard);
        if (reportType == Constant.MY_BRANCH_REPORT) {
            filterEcard.setVisibility(View.VISIBLE);
        } else {
            filterEcard.setVisibility(View.GONE);
        }
        final TextView filterCustomer = (TextView) filterCategoryLinearlayout.findViewById(R.id.filter_by_customer);
        //final HorizontalScrollView filterCategoryItemScrollView=(HorizontalScrollView)filterRelativelayout.findViewById(R.id.filter_category_item_scroll_view);
        //final LinearLayout               filterCategoryItemLinearlayout=(LinearLayout)filterRelativelayout.findViewById(R.id.filter_category_item_linearlayout);
        filterServiceCommodity.setBackgroundDrawable(null);
        filterEcard.setBackgroundDrawable(null);
        filterCustomer.setBackgroundDrawable(null);
        if (extractItemType == 1) {
            filterServiceCommodity.setBackgroundResource(R.xml.report_shape_corner_round);
        } else if (extractItemType == 2) {
            filterEcard.setBackgroundResource(R.xml.report_shape_corner_round);
        } else if (extractItemType == 3) {
            filterCustomer.setBackgroundResource(R.xml.report_shape_corner_round);
        }
        filterServiceCommodity.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                filterServiceCommodity.setBackgroundResource(R.xml.report_shape_corner_round);
                filterEcard.setBackgroundDrawable(null);
                filterCustomer.setBackgroundDrawable(null);
                //filterCategoryItemScrollView.setVisibility(View.VISIBLE);
                //filterCategoryItemLinearlayout.removeAllViews();
                extractItemType = 1;
                LayoutInflater layoutInflater = LayoutInflater.from(ReportByDateActivity.this);
				/*if(statementCategoryList!=null && statementCategoryList.size()>0){
					for(int i=0;i<statementCategoryList.size();i++){
						View itemView=layoutInflater.inflate(R.xml.filter_category_item,null);
						CategoryInfo category=statementCategoryList.get(i);
						TextView categoryItemText=(TextView)itemView.findViewById(R.id.category_item_text);
						if(statementCategoryID==Integer.parseInt(category.getCategoryID()))
							categoryItemText.setBackgroundResource(R.xml.report_shape_corner_round);
						categoryItemText.setTag(i);
						final int pos=i;
						categoryItemText.setOnClickListener(new OnClickListener() {
							@Override
							public void onClick(View view) {
								// TODO Auto-generated method stub
								((TextView)view).setBackgroundResource(R.xml.report_shape_corner_round);;
								int childCoount=filterCategoryItemLinearlayout.getChildCount();
								for(int c=0;c<childCoount;c++){
									if(c!=pos){
										((TextView)filterCategoryItemLinearlayout.getChildAt(c).findViewById(R.id.category_item_text)).setBackgroundDrawable(null);;
									}
								}
								statementCategoryID=Integer.parseInt(statementCategoryList.get((Integer)view.getTag()).getCategoryID());
							}
						});
						categoryItemText.setText(category.getCategoryName());
						filterCategoryItemLinearlayout.addView(itemView);
					}
				}*/
            }
        });
        filterEcard.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                extractItemType = 2;
                filterServiceCommodity.setBackgroundDrawable(null);
                filterEcard.setBackgroundResource(R.xml.report_shape_corner_round);
                filterCustomer.setBackgroundDrawable(null);
                //filterCategoryItemScrollView.setVisibility(View.GONE);
            }
        });
        filterCustomer.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                extractItemType = 3;
                filterServiceCommodity.setBackgroundDrawable(null);
                filterEcard.setBackgroundDrawable(null);
                filterCustomer.setBackgroundResource(R.xml.report_shape_corner_round);
                //filterCategoryItemScrollView.setVisibility(View.GONE);
            }
        });
        //周期查询
        final LinearLayout filterPeriodLinearlayout = (LinearLayout) filterRelativelayout.findViewById(R.id.filter_period_linearlayout);
        final TextView filterByDay = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_day);
        final TextView filterByMonth = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_month);
        final TextView filterBySeason = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_season);
        final TextView filterByYear = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_year);
        final TextView filterByOther = (TextView) filterPeriodLinearlayout.findViewById(R.id.filter_by_other);
        resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
        if (cycleType == 0)
            filterByDay.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 1)
            filterByMonth.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 2)
            filterBySeason.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 3)
            filterByYear.setBackgroundResource(R.xml.report_shape_corner_round);
        else if (cycleType == 4)
            filterByOther.setBackgroundResource(R.xml.report_shape_corner_round);
        final RelativeLayout filterPeriodItemRelativeLayout = (RelativeLayout) filterRelativelayout.findViewById(R.id.filter_period_relativelayout);
        Button queryDateBtn = (Button) filterRelativelayout.findViewById(R.id.report_query_btn);
        filterByDay.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
                filterByDay.setBackgroundResource(R.xml.report_shape_corner_round);
                filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                cycleType = 0;
            }
        });
        filterByMonth.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
                filterByMonth.setBackgroundResource(R.xml.report_shape_corner_round);
                filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                cycleType = 1;
            }
        });
        filterBySeason.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
                filterBySeason.setBackgroundResource(R.xml.report_shape_corner_round);
                filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                cycleType = 2;
            }
        });
        filterByYear.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
                filterByYear.setBackgroundResource(R.xml.report_shape_corner_round);
                filterPeriodItemRelativeLayout.setVisibility(View.GONE);
                cycleType = 3;
            }
        });
        filterByOther.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                resetFilterPeroid(filterByDay, filterByMonth, filterBySeason, filterByYear, filterByOther);
                filterByOther.setBackgroundResource(R.xml.report_shape_corner_round);
                cycleType = 4;
                filterPeriodItemRelativeLayout.setVisibility(View.VISIBLE);
                Calendar nowDate = Calendar.getInstance();
                int nowYear = nowDate.get(Calendar.YEAR);
                int nowMonth = nowDate.get(Calendar.MONTH) + 1;
                int nowDay = nowDate.get(Calendar.DAY_OF_MONTH);
                reportByOtherStartTime = nowYear + "年" + nowMonth + "月" + nowDay + "日";
                reportByOtherEndTime = nowYear + "年" + nowMonth + "月" + nowDay + "日";
                ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_start_date)).setText(reportByOtherStartTime);
                ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_start_date)).setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        Calendar calendarStart = Calendar.getInstance();
                        final TextView startDateText = (TextView) view;
                        DatePickerDialog startDateDialog = new DatePickerDialog(ReportByDateActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                            @Override
                            public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                                startDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                                reportByOtherStartTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                            }
                        }, calendarStart.get(calendarStart.YEAR),
                                calendarStart.get(calendarStart.MONTH),
                                calendarStart.get(calendarStart.DAY_OF_MONTH));
                        startDateDialog.show();
                    }
                });
                ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date)).setText(reportByOtherEndTime);
                ((TextView) filterRelativelayout.findViewById(R.id.report_by_other_end_date)).setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View view) {
                        // TODO Auto-generated method stub
                        final TextView endDateText = (TextView) view;
                        Calendar calendarEnd = Calendar.getInstance();
                        DatePickerDialog endDateDialog = new DatePickerDialog(ReportByDateActivity.this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                            @Override
                            public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                                endDateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
                                reportByOtherEndTime = year + "-" + (monthOfYear + 1) + "-" + dayOfMonth;
                            }
                        }, calendarEnd.get(calendarEnd.YEAR),
                                calendarEnd.get(calendarEnd.MONTH),
                                calendarEnd.get(calendarEnd.DAY_OF_MONTH));
                        endDateDialog.show();
                    }
                });

            }
        });
        queryDateBtn.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View view) {
                // TODO Auto-generated method stub
                requestWebService(cycleType, objectType);
                filterRelativelayout.setVisibility(View.GONE);
            }
        });
        filterRelativelayout.setVisibility(View.VISIBLE);
    }

    protected void resetFilterPeroid(TextView filterByDay, TextView filterByMonth, TextView filterBySeason, TextView filterByYear, TextView filterByOther) {
        filterByDay.setBackgroundDrawable(null);
        filterByMonth.setBackgroundDrawable(null);
        filterBySeason.setBackgroundDrawable(null);
        filterByYear.setBackgroundDrawable(null);
        filterByOther.setBackgroundDrawable(null);
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
}
