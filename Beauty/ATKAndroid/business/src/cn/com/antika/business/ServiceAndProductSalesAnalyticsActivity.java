package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import cn.com.antika.adapter.ServiceAndProductSaleListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.bean.ServiceAndProductSales;
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
 * 顾客E卡余额变动分析
 * */
@SuppressLint("ResourceType")
public class ServiceAndProductSalesAnalyticsActivity extends BaseActivity implements OnClickListener {
    private ServiceAndProductSalesAnalyticsActivityHandler mHandler = new ServiceAndProductSalesAnalyticsActivityHandler(this);
    private ListView serviceAndProductSalesAnalyticsListView;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userinfoApplication;
    private ImageButton serviceAndProductSalesFilterButton;
    private Builder serviceAndProductFilterDialog;
    private List<ServiceAndProductSales> serviceAndProductSalesList;
    private String startTime, endTime;
    private int cycleType, objectType, objectID, orderType, productType,
            extractItemType, reportType, totalQuantity = 0, sortType = 1, statementCategoryID;
    private TextView serviceAndProductSalesTitleText, serviceAndProductSalesTotalQuantityText, serviceAndProductSalesTotalPriceText, reportDetailListByOtherStartTimeText, reportDetailListByOtherEndTimeText, serviceAndProductSalesTotalQuantityTitle, serviceAndProductSalesTotalPriceTitle;
    private double totalPrice = 0;
    private double allTotalProfitRatePrice = 0;
    // 其他日期查询
    private RelativeLayout reportDetailListByOtherRelativelayout;
    private PackageUpdateUtil packageUpdateUtil;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_service_and_product_analytics);
        userinfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class ServiceAndProductSalesAnalyticsActivityHandler extends Handler {
        private final ServiceAndProductSalesAnalyticsActivity serviceAndProductSalesAnalyticsActivity;

        private ServiceAndProductSalesAnalyticsActivityHandler(ServiceAndProductSalesAnalyticsActivity activity) {
            WeakReference<ServiceAndProductSalesAnalyticsActivity> weakReference = new WeakReference<ServiceAndProductSalesAnalyticsActivity>(activity);
            serviceAndProductSalesAnalyticsActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (serviceAndProductSalesAnalyticsActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (serviceAndProductSalesAnalyticsActivity.progressDialog != null) {
                serviceAndProductSalesAnalyticsActivity.progressDialog.dismiss();
                serviceAndProductSalesAnalyticsActivity.progressDialog = null;
            }
            if (msg.what == 1) {
                if (serviceAndProductSalesAnalyticsActivity.productType == Constant.SERVICE_TYPE) {
                    if (serviceAndProductSalesAnalyticsActivity.extractItemType == 4) {
                        serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalPriceText.setText(serviceAndProductSalesAnalyticsActivity.totalQuantity + "次");
                        serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalQuantityText.setText(serviceAndProductSalesAnalyticsActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(serviceAndProductSalesAnalyticsActivity.totalPrice)));
                        serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalPriceTitle.setText("总次数");
                    } else {
                        serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalQuantityText.setText(serviceAndProductSalesAnalyticsActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(serviceAndProductSalesAnalyticsActivity.allTotalProfitRatePrice)));
                        serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalPriceText.setText(serviceAndProductSalesAnalyticsActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(serviceAndProductSalesAnalyticsActivity.totalPrice)));
                    }
                } else if (serviceAndProductSalesAnalyticsActivity.productType == Constant.COMMODITY_TYPE) {
                    serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalQuantityText.setText(serviceAndProductSalesAnalyticsActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(serviceAndProductSalesAnalyticsActivity.allTotalProfitRatePrice)));
                    serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesTotalPriceText.setText(serviceAndProductSalesAnalyticsActivity.userinfoApplication.getAccountInfo().getCurrency() + NumberFormatUtil.currencyFormat(String.valueOf(serviceAndProductSalesAnalyticsActivity.totalPrice)));
                }
                serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesAnalyticsListView.setAdapter(new ServiceAndProductSaleListAdapter(serviceAndProductSalesAnalyticsActivity, serviceAndProductSalesAnalyticsActivity.serviceAndProductSalesList, serviceAndProductSalesAnalyticsActivity.productType, serviceAndProductSalesAnalyticsActivity.extractItemType));
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(serviceAndProductSalesAnalyticsActivity, "您的网络貌似不给力，请重试");
            else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(serviceAndProductSalesAnalyticsActivity, serviceAndProductSalesAnalyticsActivity.getString(R.string.login_error_message));
                serviceAndProductSalesAnalyticsActivity.userinfoApplication.exitForLogin(serviceAndProductSalesAnalyticsActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + serviceAndProductSalesAnalyticsActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(serviceAndProductSalesAnalyticsActivity);
                serviceAndProductSalesAnalyticsActivity.packageUpdateUtil = new PackageUpdateUtil(serviceAndProductSalesAnalyticsActivity, serviceAndProductSalesAnalyticsActivity.mHandler, fileCache, downloadFileUrl, false, serviceAndProductSalesAnalyticsActivity.userinfoApplication);
                serviceAndProductSalesAnalyticsActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                serviceAndProductSalesAnalyticsActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = serviceAndProductSalesAnalyticsActivity.getFileStreamPath(filename);
                file.getName();
                serviceAndProductSalesAnalyticsActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            }
            if (serviceAndProductSalesAnalyticsActivity.requestWebServiceThread != null) {
                serviceAndProductSalesAnalyticsActivity.requestWebServiceThread.interrupt();
                serviceAndProductSalesAnalyticsActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        serviceAndProductSalesFilterButton = (ImageButton) findViewById(R.id.service_and_product_sales_filter_btn);
        serviceAndProductSalesFilterButton.setOnClickListener(this);
        serviceAndProductSalesAnalyticsListView = (ListView) findViewById(R.id.service_and_product_sales_analytics_list);
        serviceAndProductSalesTitleText = (TextView) findViewById(R.id.service_and_product_sales_analytics_title_text);
        serviceAndProductSalesTotalQuantityText = (TextView) findViewById(R.id.service_and_product_sales_total_quantity_text);
        serviceAndProductSalesTotalPriceText = (TextView) findViewById(R.id.service_and_product_sales_total_price_text);
        reportDetailListByOtherRelativelayout = (RelativeLayout) findViewById(R.id.report_detail_list_by_other_relativelayout);
        reportDetailListByOtherStartTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_start_date);
        reportDetailListByOtherEndTimeText = (TextView) findViewById(R.id.report_detail_list_by_other_end_date);
        serviceAndProductSalesTotalQuantityTitle = (TextView) findViewById(R.id.service_and_product_sales_total_quantity_title);
        serviceAndProductSalesTotalPriceTitle = (TextView) findViewById(R.id.service_and_product_sales_total_price_title);
        Intent intent = getIntent();
        reportType = intent.getIntExtra("REPORT_TYPE", 0);
        cycleType = intent.getIntExtra("CYCLE_TYPE", 0);
        orderType = intent.getIntExtra("ORDER_TYPE", 0);
        productType = intent.getIntExtra("PRODUCT_TYPE", 0);
        extractItemType = intent.getIntExtra("EXTRACT_ITEM_TYPE", 0);
        statementCategoryID = intent.getIntExtra("CATEGORY_ID", 0);
        if (reportType == Constant.ALL_BRANCH_REPORT || reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT)
            objectID = intent.getIntExtra("OBJECT_ID", 0);
        if (reportType == Constant.MY_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.MY_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.COMPANY_REPORT) {
            objectType = 2;
        } else if (reportType == Constant.EMPLOYEE_REPORT) {
            objectType = 0;
        } else if (reportType == Constant.ALL_BRANCH_REPORT) {
            objectType = 1;
        } else if (reportType == Constant.GROUP_REPORT) {
            objectType = 3;
        }
        String dateTypeStr = "";
        if (cycleType == 0)
            dateTypeStr = "(日)";
        else if (cycleType == 1)
            dateTypeStr = "(月)";
        else if (cycleType == 2)
            dateTypeStr = "(季)";
        else if (cycleType == 3)
            dateTypeStr = "(年)";
        else if (cycleType == 4) {
            startTime = intent.getStringExtra("START_TIME");
            endTime = intent.getStringExtra("END_TIME");
            reportDetailListByOtherRelativelayout.setVisibility(View.VISIBLE);
            reportDetailListByOtherStartTimeText.setText(convertStringToDate(startTime));
            reportDetailListByOtherEndTimeText.setText(convertStringToDate(endTime));
        }
        if (extractItemType == 4) {
            serviceAndProductSalesTotalQuantityTitle.setText("总金额");
            serviceAndProductSalesTitleText.setText("服务操作次数/金额" + dateTypeStr);
        } else {
            /*serviceAndProductSalesTotalQuantityTitle.setText(getString(R.string.service_and_product_sales_total_quantity));*/
            if (productType == Constant.SERVICE_TYPE)
                serviceAndProductSalesTitleText.setText("服务销售量/金额" + dateTypeStr);
            else if (productType == Constant.COMMODITY_TYPE)
                serviceAndProductSalesTitleText.setText("商品销售量/金额" + dateTypeStr);
        }
        getDataFromServer();
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

    private void getDataFromServer() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "getReportDetail_1_7_2";
                String endPoint = "report";
                JSONObject reportDetailJson = new JSONObject();
                try {
                    if (reportType == Constant.ALL_BRANCH_REPORT)
                        reportDetailJson.put("BranchID", objectID);
                    else
                        reportDetailJson.put("BranchID", userinfoApplication.getAccountInfo().getBranchId());
                    if (reportType == Constant.EMPLOYEE_REPORT || reportType == Constant.GROUP_REPORT) {
                        reportDetailJson.put("AccountID", objectID);
                    } else
                        reportDetailJson.put("AccountID", userinfoApplication.getAccountInfo().getAccountId());
                    reportDetailJson.put("CycleType", cycleType);
                    reportDetailJson.put("ObjectType", objectType);
                    reportDetailJson.put("OrderType", orderType);
                    reportDetailJson.put("ProductType", productType);
                    reportDetailJson.put("ExtractItemType", extractItemType);
                    reportDetailJson.put("StartTime", startTime);
                    reportDetailJson.put("EndTime", endTime);
                    reportDetailJson.put("SortType", sortType);
                    reportDetailJson.put("StatementCategoryID", statementCategoryID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, reportDetailJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                try {
                    resultJson = new JSONObject(serverRequestResult);
                } catch (JSONException e2) {
                    // TODO Auto-generated catch block
                }
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        // TODO Auto-generated catch block
                        code = 0;
                    }
                    if (code == 1) {
                        JSONArray serviceAndProductlArray = null;
                        try {
                            JSONObject productTotalJsonObject = resultJson.getJSONObject("Data").getJSONObject("ProductDetail");
                            totalQuantity = productTotalJsonObject.getInt("AllQuantity");
                            totalPrice = productTotalJsonObject.getDouble("AllTotalPrice");
                            allTotalProfitRatePrice = productTotalJsonObject.getDouble("AllTotalProfitRatePrice");
                            serviceAndProductlArray = productTotalJsonObject.getJSONArray("ProductDetail");
                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                        }
                        serviceAndProductSalesList = new ArrayList<ServiceAndProductSales>();
                        if (serviceAndProductlArray != null) {
                            for (int i = 0; i < serviceAndProductlArray.length(); i++) {
                                ServiceAndProductSales serviceAndProductSales = new ServiceAndProductSales();
                                JSONObject salesDetailJson = null;
                                try {
                                    salesDetailJson = serviceAndProductlArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    // TODO Auto-generated catch block
                                }
                                String objectName = "";//服务或者商品名称
                                int quantity = 0;//服务或者商品数量
                                String quantityScale = "";//服务或者商品的数量百分比
                                double totalPrice = 0;//服务或者商品的价格
                                String totalPriceScale = "";//服务或者商品的价格百分比
                                double totalProfitRatePrice = 0;//业绩额
                                try {
                                    if (salesDetailJson.has("ObjectName") && !salesDetailJson.isNull("ObjectName"))
                                        objectName = salesDetailJson.getString("ObjectName");
                                    if (salesDetailJson.has("Quantity") && !salesDetailJson.isNull("Quantity"))
                                        quantity = salesDetailJson.getInt("Quantity");
                                    if (salesDetailJson.has("QuantityScale") && !salesDetailJson.isNull("QuantityScale"))
                                        quantityScale = salesDetailJson.getString("QuantityScale");
                                    if (salesDetailJson.has("TotalPrice") && !salesDetailJson.isNull("TotalPrice"))
                                        totalPrice = salesDetailJson.getDouble("TotalPrice");
                                    if (salesDetailJson.has("TotalPriceScale") && !salesDetailJson.isNull("TotalPriceScale"))
                                        totalPriceScale = salesDetailJson.getString("TotalPriceScale");
                                    if (salesDetailJson.has("TotalProfitRatePrice") && !salesDetailJson.isNull("TotalProfitRatePrice"))
                                        totalProfitRatePrice = salesDetailJson.getDouble("TotalProfitRatePrice");
                                } catch (JSONException e) {
                                }
                                serviceAndProductSales.setObjectName(objectName);
                                serviceAndProductSales.setQuantity(quantity);
                                serviceAndProductSales.setQuantityScale(quantityScale);
                                serviceAndProductSales.setTotalPrice(totalPrice);
                                serviceAndProductSales.setTotalPriceScale(totalPriceScale);
                                serviceAndProductSales.setTotalProfitRatePrice(totalProfitRatePrice);
                                serviceAndProductSalesList.add(serviceAndProductSales);
                            }
                        }
                        mHandler.sendEmptyMessage(1);
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    private String convertStringToDate(String dateSource) {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Calendar calendar = Calendar.getInstance();
        Date date = null;
        try {
            date = simpleDateFormat.parse(dateSource);
        } catch (ParseException e) {
            // TODO Auto-generated catch block
            date = null;
        }
        if (date != null) {
            calendar.setTime(date);
        }
        return calendar.get(Calendar.YEAR) + "年" + (calendar.get(Calendar.MONTH) + 1) + "月" + calendar.get(Calendar.DAY_OF_MONTH) + "日";
    }

    /* (non-Javadoc)
     * @param v
     * @see android.view.View.OnClickListener#onClick(android.view.View)
     */
    @Override
    public void onClick(View v) {
        // TODO Auto-generated method stub
        if (v.getId() == R.id.service_and_product_sales_filter_btn) {
            LayoutInflater inflater = getLayoutInflater();
            View layout = inflater.inflate(R.xml.service_and_product_sales_filter_dialog, null);
            serviceAndProductFilterDialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                    .setTitle(getString(R.string.service_and_product_sales_filter_title))
                    .setView(layout)
                    .setPositiveButton(getString(R.string.confirm),
                            new DialogInterface.OnClickListener() {

                                @Override
                                public void onClick(DialogInterface arg0,
                                                    int arg1) {
                                    getDataFromServer();
                                }

                            })
                    .setNegativeButton(getString(R.string.cancel), null);
            RadioGroup salesQuantityRadioGroup = (RadioGroup) layout.findViewById(R.id.service_and_product_sales_quantity_radiogroup);
            if (extractItemType == 4)
                ((RadioButton) layout.findViewById(R.id.service_and_product_sales_quantity)).setText("按总次数从高到低");
            else
                ((RadioButton) layout.findViewById(R.id.service_and_product_sales_quantity)).setText(getString(R.string.service_and_product_sales_share));
            if (sortType == 1)
                salesQuantityRadioGroup.check(layout.findViewById(R.id.service_and_product_sales_quantity).getId());
            else if (sortType == 2)
                salesQuantityRadioGroup.check(layout.findViewById(R.id.service_and_product_sales_price).getId());
            salesQuantityRadioGroup.setOnCheckedChangeListener(new OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(RadioGroup group, int checkedId) {
                    // TODO Auto-generated method stub
                    if (group.getCheckedRadioButtonId() == R.id.service_and_product_sales_quantity) {
                        sortType = 1;
                    } else if (group.getCheckedRadioButtonId() == R.id.service_and_product_sales_price) {
                        sortType = 2;
                    }
                }
            });
            serviceAndProductFilterDialog.show();
        }
    }
}
