package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.Jpush.RandomUUID;
import com.GlamourPromise.Beauty.Thread.UpdateLoginInfoForAccountThread;
import com.GlamourPromise.Beauty.adapter.ServicingInfoListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AccountInfo;
import com.GlamourPromise.Beauty.bean.Customer;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderProduct;
import com.GlamourPromise.Beauty.bean.SearchPersonLocal;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.bean.Treatment;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.NewRefreshListView;
import com.GlamourPromise.Beauty.view.NewRefreshListView.OnRefreshListener;
import com.GlamourPromise.Beauty.view.menu.BusinessRightMenu;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.jpush.android.api.JPushInterface;

/*
 * 首页
 * */
@SuppressLint("ResourceType")
public class HomePageActivity extends BaseActivity implements OnClickListener, OnItemClickListener, OnItemLongClickListener {
    private HomePageActivityHandler mHandler = new HomePageActivityHandler(this);
    private final static String CUSTOMER_CODE = "000", COMMODITY_CODE = "001", SERVICE_CODE = "002";
    private AccountInfo accountInfo;
    private Thread requestWebServiceThread;
    private ProgressDialog progressDialog;
    private UserInfoApplication userInfoApplication;
    private long firstTime = 0;
    private String customerQRCode, uuidRaw;
    private SharedPreferences sharedPreferences;
    private PackageUpdateUtil packageUpdateUtil;
    private NewRefreshListView servicingInfoListView;
    private ServicingInfoListAdapter serviceInfoListAdapter;
    private List<OrderInfo> servicingInfoList;
    private OnRefreshListener refreshListViewWithWebService;
    private List<SearchPersonLocal> servicePICList;//筛选的服务顾问列表
    private int searchTGStatus;//-1:全部  1：未完成   2：已完成
    private int screenWidth;
    private int servicePICID = 0;
    private ImageView branchTotalReport;
    private TextView sortByOrderServicePerson, sortByTgStatusServicing, sortByTgStatusCompleted, sortByTgStatusAll;
    private LayoutInflater layoutInflater;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_home_page);
        userInfoApplication = UserInfoApplication.getInstance();
        initView();
    }

    private static class HomePageActivityHandler extends Handler {
        private final HomePageActivity homePageActivity;

        private HomePageActivityHandler(HomePageActivity activity) {
            WeakReference<HomePageActivity> weakReference = new WeakReference<HomePageActivity>(activity);
            homePageActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (homePageActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (homePageActivity.progressDialog != null) {
                homePageActivity.progressDialog.dismiss();
                homePageActivity.progressDialog = null;
            }
            if (msg.what == 0) {
                DialogUtil.createShortDialog(homePageActivity, (String) msg.obj);
            } else if (msg.what == 2)
                DialogUtil.createShortDialog(homePageActivity, "您的网络貌似不给力，请重试！");
            else if (msg.what == Constant.GET_DATA_NULL || msg.what == Constant.PARSING_ERROR) {
                DialogUtil.createShortDialog(homePageActivity, "更新登陆数据失败！");
            } else if (msg.what == Constant.GET_WEB_DATA_EXCEPTION) {
                DialogUtil.createShortDialog(homePageActivity, (String) msg.obj);
            } else if (msg.what == 6) {
                //更新登陆数据
                homePageActivity.accountInfo.setPermissionInfoByJson((JSONObject) msg.obj);
                homePageActivity.userInfoApplication.setPermissionInfo((JSONObject) msg.obj);
                homePageActivity.userInfoApplication.setAccountInfo(homePageActivity.accountInfo);
                homePageActivity.userInfoApplication.setNeedUpdateLoginInfo(false);
                BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) homePageActivity.findViewById(R.id.btn_main_left_business_menu);
                GenerateMenu.generateLeftMenu(homePageActivity, bussinessLeftMenuBtn);
                BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) homePageActivity.findViewById(R.id.btn_main_right_menu);
                GenerateMenu.generateRightMenu(homePageActivity, bussinessRightMenuBtn);
                //注册推送服务
                //if(JPushInterface.isPushStopped(getApplicationContext())){
                JPushInterface.resumePush(homePageActivity.getApplicationContext());
                String uuid = com.GlamourPromise.Beauty.Jpush.RandomUUID.getRandomUUID(homePageActivity, homePageActivity.sharedPreferences.getString("lastLoginAccount", ""));
                JPushInterface.init(homePageActivity.getApplicationContext());
                JPushInterface.setAlias(homePageActivity.getApplicationContext(), uuid, null);
                //}
                //读取首页动态权限
                int authReadHomePageServicingList = homePageActivity.userInfoApplication.getAccountInfo().getAuthReadHomePageServicingList();
                int authBusinessReportRead = homePageActivity.userInfoApplication.getAccountInfo().getAuthBusinessReportRead();
                if (authBusinessReportRead == 0)
                    homePageActivity.branchTotalReport.setVisibility(View.GONE);
                else if (authBusinessReportRead == 1) {
                    homePageActivity.branchTotalReport.setVisibility(View.VISIBLE);
                    homePageActivity.branchTotalReport.setOnClickListener(homePageActivity);
                }
                if (authReadHomePageServicingList == 1) {
                    //获取当前正在店里做服务的信息列表
                    homePageActivity.getServicingList();
                    homePageActivity.findViewById(R.id.home_page_title_relativelayout).setVisibility(View.VISIBLE);
                    homePageActivity.findViewById(R.id.servicing_info_sort_linearlayout).setVisibility(View.VISIBLE);
                    homePageActivity.findViewById(R.id.default_home_page_relativelayout).setVisibility(View.GONE);
                    homePageActivity.servicingInfoListView.setVisibility(View.VISIBLE);
                } else if (authReadHomePageServicingList == 0) {
                    homePageActivity.findViewById(R.id.servicing_info_sort_linearlayout).setVisibility(View.GONE);
                    homePageActivity.servicingInfoListView.setVisibility(View.GONE);
                    homePageActivity.findViewById(R.id.home_page_title_relativelayout).setVisibility(View.GONE);
                    homePageActivity.findViewById(R.id.default_home_page_relativelayout).setVisibility(View.VISIBLE);
                }

            } else if (msg.what == 3) {
                Customer customer = (Customer) msg.obj;
                homePageActivity.userInfoApplication.setSelectedCustomerID(customer.getCustomerId());
                homePageActivity.userInfoApplication.setSelectedCustomerName(customer.getCustomerName());
                homePageActivity.userInfoApplication.setSelectedCustomerHeadImageURL(customer.getHeadImageUrl());
                homePageActivity.userInfoApplication.setSelectedCustomerLoginMobile(customer.getLoginMobile());
                homePageActivity.userInfoApplication.setSelectedIsMyCustomer(customer.getIsMyCustomer());
                Intent destIntent = new Intent();
                destIntent.setClass(homePageActivity, CustomerServicingActivity.class);
                homePageActivity.startActivity(destIntent);
            } else if (msg.what == 4) {
                OrderProduct orderProduct = (OrderProduct) msg.obj;
                // branchID为0时，跳转到详细页
                if (homePageActivity.userInfoApplication.getAccountInfo().getBranchId() == 0) {
                    Intent destIntent = null;
                    // 服务
                    if (orderProduct.getProductType() == 0) {
                        destIntent = new Intent(homePageActivity, ServiceDetailActivity.class);
                        destIntent.putExtra("serviceCode", orderProduct.getProductCode());
                        destIntent.putExtra("CategoryID", "0");
                        destIntent.putExtra("CategoryName", "");
                    } else if (orderProduct.getProductType() == 1) {
                        destIntent = new Intent(homePageActivity, CommodityDetailActivity.class);
                        destIntent.putExtra("commodityCode", orderProduct.getProductCode());
                        destIntent.putExtra("CategoryID", "0");
                        destIntent.putExtra("CategoryName", "");
                    }
                    destIntent.putExtra("resAcvitityname", "HomePageActivity");
                    homePageActivity.startActivity(destIntent);
                } else {
                    //判断是否有编辑权限
                    if (homePageActivity.userInfoApplication.getAccountInfo().getAuthMyOrderWrite() == 0) {
                        DialogUtil.createShortDialog(homePageActivity, "扫描成功，但您无订单编辑权限！");
                    } else {
                        OrderInfo orderInfo = homePageActivity.userInfoApplication.getOrderInfo();
                        if (orderInfo == null)
                            orderInfo = new OrderInfo();
                        List<OrderProduct> orderProductList = orderInfo
                                .getOrderProductList();
                        if (orderProductList == null)
                            orderProductList = new ArrayList<OrderProduct>();
                        homePageActivity.userInfoApplication.setOrderInfo(orderInfo);
                        homePageActivity.userInfoApplication.getOrderInfo().setOrderProductList(orderProductList);
                        // 判断是否已添加
                        for (OrderProduct op : orderProductList) {
                            if (op.getProductID() == orderProduct
                                    .getProductID()) {
                                return;
                            }

                        }
                        orderProductList.add(orderProduct);
                        BusinessRightMenu.createMenuContent();
                        BusinessRightMenu.rightMenuAdapter.notifyDataSetChanged();
                    }
                }
            } else if (msg.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(homePageActivity, homePageActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(homePageActivity);
            } else if (msg.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + homePageActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(homePageActivity);
                homePageActivity.packageUpdateUtil = new PackageUpdateUtil(homePageActivity, homePageActivity.mHandler, fileCache, downloadFileUrl, false, homePageActivity.userInfoApplication);
                homePageActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) msg.obj);
                homePageActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (msg.what == 5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = homePageActivity.getFileStreamPath(filename);
                file.getName();
                homePageActivity.packageUpdateUtil.showInstallDialog();
            } else if (msg.what == -5) {
                ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
            } else if (msg.what == 7) {
                int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (msg.what == 8) {
                List<OrderInfo> showOrderInfoList = new ArrayList<OrderInfo>();
                for (OrderInfo servicingOrder : homePageActivity.servicingInfoList) {
                    if (servicingOrder.getUnfinshTgStatus() == 1)
                        showOrderInfoList.add(servicingOrder);
                }
                homePageActivity.searchTGStatus = 1;
                homePageActivity.sortByTgStatusServicing.setTextColor(homePageActivity.getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                homePageActivity.sortByTgStatusCompleted.setTextColor(homePageActivity.getResources().getColor(R.color.white));
                homePageActivity.sortByTgStatusAll.setTextColor(homePageActivity.getResources().getColor(R.color.white));
                homePageActivity.servicePICID = 0;
                homePageActivity.serviceInfoListAdapter = new ServicingInfoListAdapter(homePageActivity, showOrderInfoList, homePageActivity.userInfoApplication);
                homePageActivity.servicingInfoListView.setAdapter(homePageActivity.serviceInfoListAdapter);
                //找出当前的服务顾问
                homePageActivity.servicePICList = new ArrayList<SearchPersonLocal>();
                for (OrderInfo orderInfo : homePageActivity.servicingInfoList) {
                    SearchPersonLocal servicePIC = new SearchPersonLocal();
                    servicePIC.setPersonID(orderInfo.getResponsiblePersonID());
                    servicePIC.setPersonName(orderInfo.getResponsiblePersonName());
                    if (!homePageActivity.servicePICList.contains(servicePIC)) {
                        homePageActivity.servicePICList.add(servicePIC);
                    }
                }
                homePageActivity.servicingInfoListView.onRefreshComplete();
            } else if (msg.what == 9) {
                List<OrderInfo> searchResult = new ArrayList<OrderInfo>();
                searchResult.addAll((List<OrderInfo>) msg.obj);
                homePageActivity.serviceInfoListAdapter = new ServicingInfoListAdapter(homePageActivity, searchResult, homePageActivity.userInfoApplication);
                homePageActivity.servicingInfoListView.setAdapter(homePageActivity.serviceInfoListAdapter);
            } else if (msg.what == 10) {
                List<Treatment> treatmentList = (List<Treatment>) msg.obj;
                View treatmentDialogLayout = homePageActivity.layoutInflater.inflate(R.xml.servicing_treatment_dialog_layout, null);
                for (int i = 0; i < treatmentList.size(); i++) {
                    Treatment treatment = treatmentList.get(i);
                    View treatmentLayout = homePageActivity.layoutInflater.inflate(R.xml.servicing_treatment_layout, null);
                    TextView subServiceNameText = (TextView) treatmentLayout.findViewById(R.id.treatment_subservice_text);
                    TextView executorNameText = (TextView) treatmentLayout.findViewById(R.id.textview_executor_name);
                    if (treatment.getSubServiceName() == null || treatment.getSubServiceName().equals(""))
                        subServiceNameText.setText("服务操作");
                    else
                        subServiceNameText.setText(String.valueOf(treatment.getSubServiceName()));
                    if (treatment.isDesignated())
                        executorNameText.setText("指定:" + treatment.getExecutorName());
                    else
                        executorNameText.setText(treatment.getExecutorName());
                    ((LinearLayout) treatmentDialogLayout.findViewById(R.id.treatment_list_linearlayout)).addView(treatmentLayout);
                }
                new AlertDialog.Builder(homePageActivity, R.style.CustomerAlertDialog).setView(treatmentDialogLayout).show();
            } else if (msg.what == 99) {
                DialogUtil.createShortDialog(homePageActivity, "服务器异常，请重试");
            }
            if (homePageActivity.requestWebServiceThread != null) {
                homePageActivity.requestWebServiceThread.interrupt();
                homePageActivity.requestWebServiceThread = null;
            }
        }
    }

    private void initView() {
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        sortByOrderServicePerson = (TextView) findViewById(R.id.sort_by_tg_service_person);
        sortByOrderServicePerson.setOnClickListener(this);
        sortByTgStatusServicing = (TextView) findViewById(R.id.sort_by_tg_status_servicing);
        sortByTgStatusServicing.setOnClickListener(this);
        sortByTgStatusCompleted = (TextView) findViewById(R.id.sort_by_tg_status_completed);
        sortByTgStatusCompleted.setOnClickListener(this);
        sortByTgStatusAll = (TextView) findViewById(R.id.sort_by_tg_status_all);
        sortByTgStatusAll.setOnClickListener(this);
        branchTotalReport = (ImageView) findViewById(R.id.branch_total_report);
        layoutInflater = LayoutInflater.from(this);
        int authBusinessReportRead = userInfoApplication.getAccountInfo().getAuthBusinessReportRead();
        if (authBusinessReportRead == 0)
            branchTotalReport.setVisibility(View.GONE);
        else if (authBusinessReportRead == 1) {
            branchTotalReport.setVisibility(View.VISIBLE);
            branchTotalReport.setOnClickListener(HomePageActivity.this);
        }
        servicingInfoListView = (NewRefreshListView) findViewById(R.id.servicing_info_list_view);
        refreshListViewWithWebService = new OnRefreshListener() {

            @Override
            public void onRefresh() {
                // TODO Auto-generated method stub
                getServicingList();
            }
        };
        servicingInfoListView.setonRefreshListener(refreshListViewWithWebService);
        servicingInfoListView.setOnItemClickListener(this);
        servicingInfoListView.setOnItemLongClickListener(this);
        sharedPreferences = getSharedPreferences("AccountInfo", Context.MODE_PRIVATE);
        Intent intent = getIntent();
        //登陆时更新登陆信息
        accountInfo = (AccountInfo) intent.getSerializableExtra("AccountInfo");
        userInfoApplication.setAccountInfo(accountInfo);
        if (accountInfo != null && userInfoApplication.isNeedUpdateLoginInfo()) {
            updateLoginInfoByWebService();
        }
        //读取首页动态权限
        int authReadHomePageServicingList = userInfoApplication.getAccountInfo().getAuthReadHomePageServicingList();
        if (authReadHomePageServicingList == 1) {
            //获取当前正在店里做服务的信息列表
            getServicingList();
            findViewById(R.id.home_page_title_relativelayout).setVisibility(View.VISIBLE);
            findViewById(R.id.servicing_info_sort_linearlayout).setVisibility(View.VISIBLE);
            servicingInfoListView.setVisibility(View.VISIBLE);
            findViewById(R.id.default_home_page_relativelayout).setVisibility(View.GONE);
        } else if (authReadHomePageServicingList == 0) {
            findViewById(R.id.home_page_title_relativelayout).setVisibility(View.GONE);
            findViewById(R.id.servicing_info_sort_linearlayout).setVisibility(View.GONE);
            servicingInfoListView.setVisibility(View.GONE);
            findViewById(R.id.default_home_page_relativelayout).setVisibility(View.VISIBLE);
        }
        customerQRCode = intent.getStringExtra("code");
        if (customerQRCode != null && !("").equals(customerQRCode)) {
            String[] customerQRCodeArray = customerQRCode.split("id=");
            if (customerQRCodeArray != null && customerQRCodeArray.length == 2) {
                String[] qrCodeArray = customerQRCodeArray[1].split("\\^");
                if (qrCodeArray.length != 3)
                    DialogUtil.createShortDialog(this, "二维码内容错误！");
                else {
                    if (!qrCodeArray[0].equals(userInfoApplication.getAccountInfo().getCompanyCode()))
                        DialogUtil.createShortDialog(this, "商家信息错误！");
                    else {
                        if (qrCodeArray[1].equals(CUSTOMER_CODE)) {
                            int authMyCutomserInfoRead = userInfoApplication.getAccountInfo().getAuthMyCustomerRead();
                            if (authMyCutomserInfoRead == 0) {
                                DialogUtil.createShortDialog(this, "扫描成功，但您无权限查看顾客信息！");
                            } else if (authMyCutomserInfoRead == 1) {
                                DialogUtil.createShortDialog(this, "客户信息扫描成功！");
                                getCustomerInfoByWebService(requestWebServiceThread, mHandler, customerQRCodeArray[1], String.valueOf(userInfoApplication.getAccountInfo().getAccountId()));
                            }

                        } else if (qrCodeArray[1].equals(SERVICE_CODE)) {
                            int authServiceRead = userInfoApplication.getAccountInfo().getAuthServiceRead();
                            if (authServiceRead == 0) {
                                DialogUtil.createShortDialog(this, "扫描成功，但您无权限查看服务信息！");
                            } else {

                                DialogUtil.createShortDialog(this, "服务信息扫描成功！");
                                getProductInfoByWebService(requestWebServiceThread, mHandler, customerQRCodeArray[1],
                                        String.valueOf(userInfoApplication.getAccountInfo().getAccountId()), 0);
                            }
                        } else if (qrCodeArray[1].equals(COMMODITY_CODE)) {
                            int authCommodityRead = userInfoApplication.getAccountInfo().getAuthCommodityRead();
                            if (authCommodityRead == 0) {
                                DialogUtil.createShortDialog(this, "扫描成功，但您无权限查看商品信息！");
                            } else {
                                DialogUtil.createShortDialog(this, "商品信息扫描成功！");
                                getProductInfoByWebService(requestWebServiceThread, mHandler, customerQRCodeArray[1], String.valueOf(userInfoApplication.getAccountInfo().getAccountId()), 1);
                            }
                        }

                    }
                }
            } else
                DialogUtil.createShortDialog(this, "二维码内容错误！");

        }
    }

    private void updateLoginInfoByWebService() {
		/*if(sharedPreferences.getString("lastLoginAccount", "").equals(accountInfo.getLoginMobile())&& !sharedPreferences.getString("pushUUID", "").equals(""))
			uuidRaw = sharedPreferences.getString("pushUUID", "");
		else*/
        uuidRaw = RandomUUID.createRandomUUID(this, String.valueOf(accountInfo.getAccountId()));
        requestWebServiceThread = new UpdateLoginInfoForAccountThread(mHandler, uuidRaw, userInfoApplication);
        requestWebServiceThread.start();
    }

    private void getServicingList() {
        screenWidth = userInfoApplication.getScreenWidth();
        if (servicingInfoList != null && servicingInfoList.size() > 0)
            servicingInfoList.clear();
        else
            servicingInfoList = new ArrayList<OrderInfo>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetUnfinishTGList";
                String endPoint = "Order";
                JSONObject unFinishTGJsonParam = new JSONObject();
                try {
                    unFinishTGJsonParam.put("ProductType", Constant.SERVICE_TYPE);
                    unFinishTGJsonParam.put("CustomerID", 0);
                    unFinishTGJsonParam.put("IsToday", true);
                    if (screenWidth == 720) {
                        unFinishTGJsonParam.put("ImageWidth", "100");
                        unFinishTGJsonParam.put("ImageHeight", "100");
                    } else if (screenWidth == 480 || screenWidth == 540) {
                        unFinishTGJsonParam.put("ImageWidth", "60");
                        unFinishTGJsonParam.put("ImageHeight", "60");
                    } else if (screenWidth == 1536) {
                        unFinishTGJsonParam.put("ImageWidth", "180");
                        unFinishTGJsonParam.put("ImageHeight", "180");
                    }
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, unFinishTGJsonParam.toString(), userInfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    String msg = "";
                    JSONArray unFinishTGArray = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        msg = resultJson.getString("Message");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        try {
                            unFinishTGArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (unFinishTGArray != null) {
                            for (int i = 0; i < unFinishTGArray.length(); i++) {
                                OrderInfo unfinishOrder = new OrderInfo();
                                JSONObject unfinishOrderJson = null;
                                int customerID = 0;
                                String customerName = "";
                                String customerHeadImageUrl = "";
                                String productName = "";
                                int productType = -1;
                                int totalCount = 0;
                                int finishedCount = 0;
                                int paymentStatus = 0;
                                String tgGroupNO = "";
                                String tgStartTime = "";
                                String accountName = "";
                                int accountID = 0;
                                int orderID = 0;
                                int orderObjectID = 0;
                                int unFinishTgStatus = 1;
                                boolean isDesignated = false;
                                try {
                                    unfinishOrderJson = unFinishTGArray.getJSONObject(i);
                                    if (unfinishOrderJson.has("CustomerName") && !unfinishOrderJson.isNull("CustomerName"))
                                        customerName = unfinishOrderJson.getString("CustomerName");
                                    if (unfinishOrderJson.has("HeadImageURL") && !unfinishOrderJson.isNull("HeadImageURL"))
                                        customerHeadImageUrl = unfinishOrderJson.getString("HeadImageURL");
                                    if (unfinishOrderJson.has("ProductName") && !unfinishOrderJson.isNull("ProductName"))
                                        productName = unfinishOrderJson.getString("ProductName");
                                    if (unfinishOrderJson.has("ProductType") && !unfinishOrderJson.isNull("ProductType"))
                                        productType = unfinishOrderJson.getInt("ProductType");
                                    if (unfinishOrderJson.has("TotalCount") && !unfinishOrderJson.isNull("TotalCount"))
                                        totalCount = unfinishOrderJson.getInt("TotalCount");
                                    if (unfinishOrderJson.has("FinishedCount") && !unfinishOrderJson.isNull("FinishedCount"))
                                        finishedCount = unfinishOrderJson.getInt("FinishedCount");
                                    if (unfinishOrderJson.has("PaymentStatus") && !unfinishOrderJson.isNull("PaymentStatus"))
                                        paymentStatus = unfinishOrderJson.getInt("PaymentStatus");
                                    if (unfinishOrderJson.has("GroupNo") && !unfinishOrderJson.isNull("GroupNo"))
                                        tgGroupNO = unfinishOrderJson.getString("GroupNo");
                                    if (unfinishOrderJson.has("TGStartTime") && !unfinishOrderJson.isNull("TGStartTime"))
                                        tgStartTime = unfinishOrderJson.getString("TGStartTime");
                                    if (unfinishOrderJson.has("AccountName") && !unfinishOrderJson.isNull("AccountName"))
                                        accountName = unfinishOrderJson.getString("AccountName");
                                    if (unfinishOrderJson.has("AccountID") && !unfinishOrderJson.isNull("AccountID"))
                                        accountID = unfinishOrderJson.getInt("AccountID");
                                    if (unfinishOrderJson.has("OrderID") && !unfinishOrderJson.isNull("OrderID"))
                                        orderID = unfinishOrderJson.getInt("OrderID");
                                    if (unfinishOrderJson.has("OrderObjectID") && !unfinishOrderJson.isNull("OrderObjectID"))
                                        orderObjectID = unfinishOrderJson.getInt("OrderObjectID");
                                    if (unfinishOrderJson.has("Status") && !unfinishOrderJson.isNull("Status"))
                                        unFinishTgStatus = unfinishOrderJson.getInt("Status");
                                    if (unfinishOrderJson.has("CustomerID") && !unfinishOrderJson.isNull("CustomerID"))
                                        customerID = unfinishOrderJson.getInt("CustomerID");
                                    if (unfinishOrderJson.has("IsDesignated") && !unfinishOrderJson.isNull("IsDesignated"))
                                        isDesignated = unfinishOrderJson.getBoolean("IsDesignated");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                unfinishOrder.setCustomerName(customerName);
                                unfinishOrder.setCustomerHeadImageUrl(customerHeadImageUrl);
                                unfinishOrder.setProductName(productName);
                                unfinishOrder.setProductType(productType);
                                unfinishOrder.setTotalCount(totalCount);
                                unfinishOrder.setCompleteCount(finishedCount);
                                unfinishOrder.setPaymentStatus(paymentStatus);
                                unfinishOrder.setTgGroupNo(tgGroupNO);
                                unfinishOrder.setOrderTime(tgStartTime);
                                unfinishOrder.setResponsiblePersonName(accountName);
                                unfinishOrder.setResponsiblePersonID(accountID);
                                unfinishOrder.setOrderID(orderID);
                                unfinishOrder.setOrderObejctID(orderObjectID);
                                unfinishOrder.setUnfinshTgStatus(unFinishTgStatus);
                                unfinishOrder.setCustomerID(customerID);
                                unfinishOrder.setDesignated(isDesignated);
                                servicingInfoList.add(unfinishOrder);
                            }
                        }
                        mHandler.sendEmptyMessage(8);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        mHandler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 0;
                        message.obj = msg;
                        mHandler.sendMessage(message);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    private void getCustomerInfoByWebService(Thread thread, Handler handler,
                                             String qrCode, String accountID) {
        final String finalQRCode = qrCode;
        final Handler finalHadnler = handler;
        thread = new Thread() {
            @Override
            public void run() {
                String methodName = "getInfoByQRcode";
                String endPoint = "WebUtility";
                JSONObject orderRemarkJson = new JSONObject();
                try {
                    orderRemarkJson.put("QRCode", finalQRCode);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, orderRemarkJson.toString(), userInfoApplication);
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    finalHadnler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");

                        if (code == 1) {
                            JSONObject dataJson = resultJson.getJSONObject("Data");
                            Message msg = finalHadnler.obtainMessage();
                            Customer customer = new Customer();
                            customer.setCustomerId(dataJson.getInt("CustomerID"));
                            customer.setIsMyCustomer(dataJson.getBoolean("IsMyCustomer"));
                            customer.setCustomerName(dataJson.getString("CustomerName"));
                            customer.setDiscount(dataJson.getString("Discount"));
                            customer.setHeadImageUrl(dataJson.getString("HeadImageURL"));
                            msg.what = 3;
                            msg.obj = customer;
                            msg.sendToTarget();
                            return;
                        } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR) {
                            mHandler.sendEmptyMessage(code);
                            return;
                        }
                    } catch (JSONException e) {
                        code = 0;
                        if (message.equals(""))
                            message = "获取数据失败,请重试!";
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    Message msg = finalHadnler.obtainMessage();
                    msg.what = 0;
                    msg.obj = message;
                    msg.sendToTarget();
                }
            }
        };
        thread.start();
    }

    private void getProductInfoByWebService(Thread thread, Handler handler,
                                            String qrCode, String accountID, int productType) {
        final String finalQRCode = qrCode;
        final Handler finalHadnler = handler;
        final int finalProductType = productType;
        thread = new Thread() {
            @Override
            public void run() {
                String methodName = "getInfoByQRcode";
                String endPoint = "WebUtility";
                JSONObject orderRemarkJson = new JSONObject();
                try {
                    orderRemarkJson.put("QRCode", finalQRCode);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }

                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, orderRemarkJson.toString(), userInfoApplication);
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
                    finalHadnler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    String message = "";
                    JSONObject resultJson = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                        if (code == 1) {
                            JSONObject dataJson = resultJson.getJSONObject("Data");
                            Message msg = finalHadnler.obtainMessage();
                            OrderProduct orderProduct = new OrderProduct();
                            orderProduct.setProductID(dataJson.getInt("ID"));
                            orderProduct.setProductCode(dataJson.getLong("Code"));
                            orderProduct.setProductName(dataJson.getString("Name"));
                            orderProduct.setProductType(finalProductType);
                            orderProduct.setQuantity(1);
                            orderProduct.setUnitPrice(dataJson.getString("UnitPrice"));
                            orderProduct.setTotalPrice(String.valueOf(Double.valueOf(orderProduct.getUnitPrice()) * orderProduct.getQuantity()));
                            orderProduct.setPromotionPrice(dataJson.getString("PromotionPrice"));
                            orderProduct.setMarketingPolicy(dataJson.getInt("MarketingPolicy"));
                            if (dataJson.has("ExpirationTime"))
                                orderProduct.setServiceOrderExpirationDate(dataJson.getString("ExpirationTime"));
                            orderProduct.setResponsiblePersonID(userInfoApplication.getAccountInfo().getAccountId());
                            orderProduct.setResponsiblePersonName(userInfoApplication.getAccountInfo().getAccountName());
                            msg.what = 4;
                            msg.obj = orderProduct;
                            msg.sendToTarget();
                            return;
                        } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR) {
                            mHandler.sendEmptyMessage(code);
                            return;
                        }
                    } catch (JSONException e) {
                        code = 0;
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (message.equals(""))
                        message = "获取数据失败,请重试!";
                    Message msg = finalHadnler.obtainMessage();
                    msg.what = 0;
                    msg.obj = message;
                    msg.sendToTarget();
                }
            }
        };
        thread.start();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        // TODO Auto-generated method stub
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            long secondTime = System.currentTimeMillis();
            // 如果两次按键时间间隔大于2000毫秒，则不退出
            if (secondTime - firstTime > 2000) {
                DialogUtil.createShortDialog(this, "再按一次退出程序...");
                firstTime = secondTime;
                return false;
            } else {
                userInfoApplication.exit(this);
            }
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String isExit = intent.getStringExtra("exit");
        if (isExit != null && isExit.equals("1")) {
            userInfoApplication.setAccountInfo(null);
            userInfoApplication.setSelectedCustomerID(0);
            userInfoApplication.setSelectedCustomerName("");
            userInfoApplication.setSelectedCustomerHeadImageURL("");
            userInfoApplication.setSelectedCustomerLoginMobile("");
            userInfoApplication.setAccountNewMessageCount(0);
            userInfoApplication.setAccountNewRemindCount(0);
            userInfoApplication.setOrderInfo(null);
            Constant.formalFlag = 0;
            finish();
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
        System.gc();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK)
            return;
        else {
            servicePICID = data.getIntExtra("personId", 0);
            List<OrderInfo> searchOrderInfo = new ArrayList<OrderInfo>();
            if (servicePICID != 0) {
                for (OrderInfo orderInfo : servicingInfoList) {
                    if (orderInfo.getResponsiblePersonID() == servicePICID) {
                        if (searchTGStatus == -1)
                            searchOrderInfo.add(orderInfo);
                        else {
                            if (orderInfo.getUnfinshTgStatus() == searchTGStatus)
                                searchOrderInfo.add(orderInfo);
                        }
                    }
                }
                Message message = new Message();
                message.what = 9;
                message.obj = searchOrderInfo;
                mHandler.sendMessage(message);
            } else {
                servicePICID = 0;
            }

        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.sort_by_tg_service_person:
                Intent destIntent = new Intent(this, ChoosePersonLocalActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("servicePICList", (Serializable) servicePICList);
                destIntent.putExtras(bundle);
                destIntent.putExtra("searchMode", 1);
                startActivityForResult(destIntent, 200);
                break;
            case R.id.sort_by_tg_status_servicing:
                sortByTgStatusAll.setTextColor(getResources().getColor(R.color.white));
                sortByTgStatusServicing.setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                sortByTgStatusCompleted.setTextColor(getResources().getColor(R.color.white));
                List<OrderInfo> searchResult = new ArrayList<OrderInfo>();
                searchTGStatus = 1;
                for (OrderInfo oi : servicingInfoList) {
                    if (servicePICID == 0) {
                        if (oi.getUnfinshTgStatus() == 1)
                            searchResult.add(oi);
                    } else {
                        if (oi.getUnfinshTgStatus() == 1 && oi.getResponsiblePersonID() == servicePICID)
                            searchResult.add(oi);
                    }

                }
                Message message = new Message();
                message.what = 9;
                message.obj = searchResult;
                mHandler.sendMessage(message);
                break;
            case R.id.sort_by_tg_status_completed:
                List<OrderInfo> searchResultCompleted = new ArrayList<OrderInfo>();
                searchTGStatus = 2;
                sortByTgStatusAll.setTextColor(getResources().getColor(R.color.white));
                sortByTgStatusServicing.setTextColor(getResources().getColor(R.color.white));
                sortByTgStatusCompleted.setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                for (OrderInfo oi : servicingInfoList) {
                    if (servicePICID == 0) {
                        if (oi.getUnfinshTgStatus() == 2 || oi.getUnfinshTgStatus() == 5)
                            searchResultCompleted.add(oi);
                    } else {
                        if ((oi.getUnfinshTgStatus() == 2 || oi.getUnfinshTgStatus() == 5) && oi.getResponsiblePersonID() == servicePICID)
                            searchResultCompleted.add(oi);
                    }

                }
                Message messageCompleted = new Message();
                messageCompleted.what = 9;
                messageCompleted.obj = searchResultCompleted;
                mHandler.sendMessage(messageCompleted);
                break;
            case R.id.sort_by_tg_status_all:
                List<OrderInfo> searchResultAll = new ArrayList<OrderInfo>();
                searchTGStatus = -1;
                for (OrderInfo oi : servicingInfoList) {
                    if (servicePICID == 0)
                        searchResultAll.add(oi);
                    else {
                        if (oi.getResponsiblePersonID() == servicePICID)
                            searchResultAll.add(oi);
                    }
                }
                sortByTgStatusAll.setTextColor(getResources().getColor(R.color.home_page_sort_tg_status_text_color));
                sortByTgStatusServicing.setTextColor(getResources().getColor(R.color.white));
                sortByTgStatusCompleted.setTextColor(getResources().getColor(R.color.white));
                Message messageAll = new Message();
                messageAll.what = 9;
                messageAll.obj = searchResultAll;
                mHandler.sendMessage(messageAll);
                break;
            case R.id.branch_total_report:
                Intent branchTotalIntent = new Intent(this, BranchTotalReportActivity.class);
                startActivity(branchTotalIntent);
                break;
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        if (position != 0) {
            Intent destIntent = new Intent(this, CustomerServicingActivity.class);
            userInfoApplication.setSelectedCustomerID(serviceInfoListAdapter.getServicingList().get(position - 1).getCustomerID());
            userInfoApplication.setSelectedCustomerName(serviceInfoListAdapter.getServicingList().get(position - 1).getCustomerName());
            startActivity(destIntent);
        }
    }

    @Override
    public boolean onItemLongClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        if (serviceInfoListAdapter.getServicingList().get(position - 1).isDesignated())
            getDesignatedTreatmentList(serviceInfoListAdapter.getServicingList().get(position - 1).getTgGroupNo());
        return false;
    }

    protected void getDesignatedTreatmentList(final String groupNO) {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {

                // TODO Auto-generated method stub
                String methodName = "GetTMListByGroupNo";
                String endPoint = "order";
                JSONObject getTreatmentListJsonParam = new JSONObject();
                try {
                    getTreatmentListJsonParam.put("GroupNo", groupNO);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, getTreatmentListJsonParam.toString(), userInfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    int code = 0;
                    JSONObject treatmentListJson = null;
                    try {
                        treatmentListJson = new JSONObject(serverRequestResult);
                        code = treatmentListJson.getInt("Code");
                    } catch (JSONException e) {
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    String returnMessage = "";
                    if (code == 1) {
                        JSONArray treatmentArray = null;
                        List<Treatment> treatmentList = new ArrayList<Treatment>();
                        try {
                            treatmentArray = treatmentListJson.getJSONArray("Data");
                        } catch (JSONException e) {
                            mHandler.sendEmptyMessage(99);
                            return;
                        }
                        if (treatmentArray != null) {

                            for (int i = 0; i < treatmentArray.length(); i++) {
                                Treatment treatment = new Treatment();
                                JSONObject treatmentJson = null;
                                try {
                                    treatmentJson = treatmentArray.getJSONObject(i);
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                try {
                                    treatment.setSubServiceName(treatmentJson.getString("SubServiceName"));
                                    treatment.setDesignated(treatmentJson.getBoolean("IsDesignated"));
                                    treatment.setExecutorName(treatmentJson.getString("ExecutorName"));
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
                                treatmentList.add(treatment);
                            }
                        }
                        mHandler.obtainMessage(10, treatmentList).sendToTarget();
                    } else {
                        mHandler.obtainMessage(0, returnMessage).sendToTarget();
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }
}