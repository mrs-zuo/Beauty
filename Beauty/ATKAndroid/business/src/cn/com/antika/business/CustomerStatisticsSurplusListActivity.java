package cn.com.antika.business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.CustomerStatisticsSurplusListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.CustomerStatistics;
import cn.com.antika.bean.CustomerStatisticsSurplus;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderListBaseConditionInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.manager.OrderManager;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.view.NewRefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

@SuppressLint({"ResourceType", "SetTextI18n"})
public class CustomerStatisticsSurplusListActivity extends BaseActivity implements OnClickListener {
    private CustomerStatisticsListActivityHandler mHandler = new CustomerStatisticsListActivityHandler(this);
    private UserInfoApplication userinfoApplication;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private PackageUpdateUtil packageUpdateUtil;
    private CustomerStatisticsSurplusListAdapter customerStatisticsSurplusListAdapter;
    private List<CustomerStatisticsSurplus> customerStatisticsSurplusList;
    private NewRefreshListView customerStatisticsListView;
    private Button switchServiceBtn, switchCommodityBtn;
    // 0:服务,1:商品
    private int objectType = 0;
    DecimalFormat df = new DecimalFormat("0.00");
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_customer_statistics_surplus_list);
        initView();
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        ((TextView) findViewById(R.id.customer_statistics_list_title_text)).setText("消费剩余价值统计" + "(" + userinfoApplication.getSelectedCustomerName() + ")");
        ((TextView) findViewById(R.id.customer_statistics_surplus_total_TextView)).setText(Html.fromHtml("总计:" + "<font color='#016CAD'>" + df.format(0) + "</font>"));

        customerStatisticsListView = findViewById(R.id.customer_statistics_list_listview);
        customerStatisticsSurplusList = new ArrayList<CustomerStatisticsSurplus>();
        customerStatisticsSurplusListAdapter = new CustomerStatisticsSurplusListAdapter(this, customerStatisticsSurplusList, objectType, mHandler);
        customerStatisticsListView.setAdapter(customerStatisticsSurplusListAdapter);
        customerStatisticsListView.setonRefreshListener(new NewRefreshListView.OnRefreshListener() {
            @Override
            public void onRefresh() {
                // TODO Auto-generated method stub
                int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
                if (authMyOrderRead == 1) {
                    //如果选择顾客不为空时
                    if (userinfoApplication.getSelectedCustomerID() != 0)
                        getCustomerStatisticsPieData();
                }
            }
        });
        switchServiceBtn = (Button) findViewById(R.id.switch_service_btn);
        switchServiceBtn.setOnClickListener(this);
        switchCommodityBtn = (Button) findViewById(R.id.switch_commodity_btn);
        switchCommodityBtn.setOnClickListener(this);
        objectType = 0;
        getCustomerStatisticsPieData();
    }

    public static class CustomerStatisticsListActivityHandler extends Handler {
        private final CustomerStatisticsSurplusListActivity customerStatisticsSurplusListActivity;

        private CustomerStatisticsListActivityHandler(CustomerStatisticsSurplusListActivity activity) {
            WeakReference<CustomerStatisticsSurplusListActivity> weakReference = new WeakReference<CustomerStatisticsSurplusListActivity>(activity);
            customerStatisticsSurplusListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (customerStatisticsSurplusListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (customerStatisticsSurplusListActivity.progressDialog != null) {
                customerStatisticsSurplusListActivity.progressDialog.dismiss();
                customerStatisticsSurplusListActivity.progressDialog = null;
            }
            if (customerStatisticsSurplusListActivity.requestWebServiceThread != null) {
                customerStatisticsSurplusListActivity.requestWebServiceThread.interrupt();
                customerStatisticsSurplusListActivity.requestWebServiceThread = null;
            }
            if (message.what == 1) {
                // customerStatisticsListActivity.customerStatisticsListView.setAdapter(new CustomerStatisticsSurplusListAdapter(customerStatisticsListActivity, customerStatisticsListActivity.customerStatisticsList, customerStatisticsListActivity.objectType));
                customerStatisticsSurplusListActivity.customerStatisticsSurplusList.clear();
                customerStatisticsSurplusListActivity.customerStatisticsSurplusList.addAll((List<CustomerStatisticsSurplus>) message.obj);
                customerStatisticsSurplusListActivity.customerStatisticsSurplusListAdapter.setmObjectType(customerStatisticsSurplusListActivity.objectType);
                customerStatisticsSurplusListActivity.customerStatisticsSurplusListAdapter.notifyDataSetChanged();
                double productSurplusPriceTotal = 0;
                for (CustomerStatisticsSurplus customerStatisticsSurplus : customerStatisticsSurplusListActivity.customerStatisticsSurplusList) {
                    productSurplusPriceTotal += customerStatisticsSurplus.getProductSurplusPrice();
                }
                ((TextView) customerStatisticsSurplusListActivity.findViewById(R.id.customer_statistics_surplus_total_TextView)).setText(Html.fromHtml("总计:" + "<font color='#016CAD'>" + customerStatisticsSurplusListActivity.df.format(productSurplusPriceTotal) + "</font>"));
                customerStatisticsSurplusListActivity.customerStatisticsListView.onRefreshComplete();
            } else if (message.what == 101) {
                // 订单详情
                customerStatisticsSurplusListActivity.getOrder((CustomerStatisticsSurplus) message.obj);
            } else if (message.what == 2) {
                customerStatisticsSurplusListActivity.clearData();
                DialogUtil.createShortDialog(customerStatisticsSurplusListActivity, "您的网络貌似不给力，请重试");
            } else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(customerStatisticsSurplusListActivity, customerStatisticsSurplusListActivity.getString(R.string.login_error_message));
                customerStatisticsSurplusListActivity.userinfoApplication.exitForLogin(customerStatisticsSurplusListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + customerStatisticsSurplusListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(customerStatisticsSurplusListActivity);
                customerStatisticsSurplusListActivity.packageUpdateUtil = new PackageUpdateUtil(customerStatisticsSurplusListActivity, customerStatisticsSurplusListActivity.mHandler, fileCache, downloadFileUrl, false, customerStatisticsSurplusListActivity.userinfoApplication);
                customerStatisticsSurplusListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                customerStatisticsSurplusListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "cn.com.antika.business.apk";
                File file = customerStatisticsSurplusListActivity.getFileStreamPath(filename);
                file.getName();
                customerStatisticsSurplusListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else {
                customerStatisticsSurplusListActivity.clearData();
                DialogUtil.createShortDialog(customerStatisticsSurplusListActivity, "服务器异常，请重试");
            }
        }
    }

    public static class CustomerStatisticsListActivityOrderHandler extends Handler {
        private final CustomerStatisticsSurplusListActivity customerStatisticsSurplusListActivity;

        private CustomerStatisticsListActivityOrderHandler(CustomerStatisticsSurplusListActivity activity) {
            WeakReference<CustomerStatisticsSurplusListActivity> weakReference = new WeakReference<CustomerStatisticsSurplusListActivity>(activity);
            customerStatisticsSurplusListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            if (message.what == Constant.GET_WEB_DATA_TRUE) {
                // 订单信息
                ArrayList<OrderInfo> tmpList = (ArrayList<OrderInfo>) message.obj;
                Log.v("OrderHandler", String.valueOf(tmpList.size()));
                if (tmpList.size() > 0) {
                    customerStatisticsSurplusListActivity.getOrderDetail(tmpList.get(0));
                } else {
                    customerStatisticsSurplusListActivity.mHandler.sendEmptyMessage(99);
                }
            } else {
                customerStatisticsSurplusListActivity.mHandler.sendEmptyMessage(99);
            }
        }
    }

    protected void getCustomerStatisticsPieData() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetDataStatisticsSurplusList";
                String endPoint = "Statistics";
                JSONObject getDataStatisticsJson = new JSONObject();
                getDataStatisticsJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                getDataStatisticsJson.put("ObjectType", objectType);
                getDataStatisticsJson.put("ExtractItemType", 1);

                Log.v("getDataSearch", getDataStatisticsJson.toJSONString());
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getDataStatisticsJson.toJSONString(), userinfoApplication);
                JSONObject resultJson = null;
                resultJson = JSONObject.parseObject(serverRequestResult);
                if (resultJson.isEmpty()) {
                    mHandler.sendEmptyMessage(2);
                } else {
                    int code = 0;
                    String message = "";
                    Log.v("getData", resultJson.toJSONString());
                    if (resultJson.containsKey("Code")) {
                        code = resultJson.getInteger("Code");
                    }
                    if (resultJson.containsKey("Message")) {
                        message = resultJson.getString("Message");
                    }
                    if (code == 1) {
                        JSONArray statisticsJsonArray = null;
                        statisticsJsonArray = resultJson.getJSONArray("Data");
                        List<CustomerStatisticsSurplus> customerStatisticsSurpluses = new ArrayList<CustomerStatisticsSurplus>();
                        if (!statisticsJsonArray.isEmpty()) {
                            customerStatisticsSurpluses = statisticsJsonArray.toJavaList(CustomerStatisticsSurplus.class);
                        }
                        mHandler.obtainMessage(1, customerStatisticsSurpluses).sendToTarget();
                    } else
                        mHandler.sendEmptyMessage(code);
                }
            }
        };
        requestWebServiceThread.start();
    }

    protected void switchServiceCommodity(int productType) {
        if (productType == 0 && objectType == 1) {
            switchServiceBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
            switchServiceBtn.setTextColor(getResources().getColor(R.color.white));
            switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
            switchCommodityBtn.setTextColor(getResources().getColor(R.color.title_font));
            clearData();
            objectType = 0;
            getCustomerStatisticsPieData();
        } else if (productType == 1 && objectType == 0) {
            switchServiceBtn.setBackgroundResource(R.xml.shape_btn_white_no_round);
            switchServiceBtn.setTextColor(getResources().getColor(R.color.title_font));
            switchCommodityBtn.setBackgroundResource(R.xml.shape_btn_blue_no_round);
            switchCommodityBtn.setTextColor(getResources().getColor(R.color.white));
            clearData();
            objectType = 1;
            getCustomerStatisticsPieData();
        }
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.switch_service_btn:
                ((TextView) findViewById(R.id.product_name)).setText(R.string.product_service_name);
                ((TextView) findViewById(R.id.product_surplus_num)).setText(R.string.product_service_surplus_num);
                ((TextView) findViewById(R.id.product_surplus_title_TextView)).setText(R.string.product_service_surplus_title);
                switchServiceCommodity(0);
                break;
            case R.id.switch_commodity_btn:
                ((TextView) findViewById(R.id.product_name)).setText(R.string.product_good_name);
                ((TextView) findViewById(R.id.product_surplus_num)).setText(R.string.product_good_surplus_num);
                ((TextView) findViewById(R.id.product_surplus_title_TextView)).setText(R.string.product_good_surplus_title);
                switchServiceCommodity(1);
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
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }

    private void clearData() {
        ((TextView) findViewById(R.id.customer_statistics_surplus_total_TextView)).setText(Html.fromHtml("总计:" + "<font color='#016CAD'>" + df.format(0) + "</font>"));
        if (customerStatisticsSurplusList != null) {
            customerStatisticsSurplusList.clear();
            if (customerStatisticsSurplusListAdapter != null)
                customerStatisticsSurplusListAdapter.notifyDataSetChanged();
        }
    }

    private void getOrder(CustomerStatisticsSurplus customerStatisticsSurplus) {
        if (userinfoApplication.getSelectedCustomerID() == 0) {
            DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
            return;
        }
        Log.v("getOrder", customerStatisticsSurplus.toString());
        OrderListBaseConditionInfo.OrderListConditionBuilder orderListConditionBuilder = new OrderListBaseConditionInfo.OrderListConditionBuilder();
        orderListConditionBuilder
                // .setAccountID(userinfoApplication.getAccountInfo().getAccountId())
                // .setBranchID(userinfoApplication.getAccountInfo().getBranchId())
                .setPageIndex(1).setPageSize(1)
                .setProductType(objectType)
                .setCustomerID(userinfoApplication.getSelectedCustomerID())
                // 订单编号
                .setSerchWord(customerStatisticsSurplus.getOrderNumber())
                .setIsAllBranchOrder(true);
        OrderManager orderManager = new OrderManager();
        orderManager.getOrderList(new CustomerStatisticsListActivityOrderHandler(this), orderListConditionBuilder.create(), userinfoApplication);
    }

    private void getOrderDetail(OrderInfo orderInfo) {
        if (userinfoApplication.getSelectedCustomerID() == 0) {
            DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
            return;
        }
        Bundle bundle = new Bundle();
        bundle.putSerializable("orderInfo", orderInfo);
        Intent destIntent = new Intent(this, OrderDetailActivity.class);
        destIntent.putExtra("userRole", Constant.USER_ROLE_CUSTOMER);
        destIntent.putExtra("FromOrderList", true);
        destIntent.putExtras(bundle);
        startActivity(destIntent);
    }
}
