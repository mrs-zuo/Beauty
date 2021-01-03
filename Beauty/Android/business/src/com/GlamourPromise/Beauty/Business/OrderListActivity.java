package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.OrderListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo.OrderListConditionBuilder;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.manager.OrderManager;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.XListView;
import com.GlamourPromise.Beauty.view.XListView.IXListViewListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@SuppressLint("ResourceType")
public class OrderListActivity extends BaseActivity implements OnClickListener, OnItemClickListener, IXListViewListener {
    private OrderListActivityHandler handler = new OrderListActivityHandler(this);
    // JPush
    public static boolean isForeground = false;
    public static final String NEW_MESSAGE_BROADCAST_ACTION = "OrderListActivityNewChatMesage";
    private XListView mListView;
    private ProgressDialog progressDialog;
    private List<OrderInfo> orderInfoList;
    private ImageButton orderSearchNewButton, orderSearchBtn;// 订单筛选按钮
    private OrderListAdapter orderListAdapter;
    private int userRole;
    private int lastOrderSource = -1;
    private int lastOrderClassify = -1;
    private int lastOrderStatus = -1;
    private int lastOrderPayStatus = -1;
    private TextView orderListTitleText;
    private UserInfoApplication userinfoApplication;
    // 推送接受
    private MessageRecevice messageRecevice;
    private IntentFilter filter;
    private int pageCount = 1;// 全部订单的页数
    private int pageIndex;
    private Boolean isRefresh = false;
    private int getOrderListFlag;// 1:取最初的数据；2：取最新的数据；3：取老数据
    private OrderManager orderManager;
    private OrderListBaseConditionInfo orderBaseConditionInfo;
    private TextView orderListPageInfoText;
    private boolean isAllBranchOrder = false;
    private PackageUpdateUtil packageUpdateUtil;

    private static class OrderListActivityHandler extends Handler {
        private final OrderListActivity orderListActivity;

        private OrderListActivityHandler(OrderListActivity activity) {
            WeakReference<OrderListActivity> weakReference = new WeakReference<OrderListActivity>(activity);
            orderListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            if (orderListActivity.progressDialog != null) {
                orderListActivity.progressDialog.dismiss();
                orderListActivity.progressDialog = null;
            }
            orderListActivity.isRefresh = false;
            switch (msg.what) {
                case Constant.GET_WEB_DATA_TRUE:
                    @SuppressWarnings("unchecked")
                    ArrayList<OrderInfo> tmpList = (ArrayList<OrderInfo>) msg.obj;
                    orderListActivity.pageCount = msg.arg2;
                    // 设置选中项位置
                    int pos = -1;
                    //总页数不为0时显示
                    if (orderListActivity.pageCount != 0) {
                        orderListActivity.orderListPageInfoText.setText("(第" + orderListActivity.pageIndex + "/" + orderListActivity.pageCount + "页)");
                    }
                    //总页数为0时，则将订单页数信息置空
                    else {
                        orderListActivity.orderListPageInfoText.setText("");
                    }
                    // 有老数据时，当前页数加一
					/*if (tmpList.size() > 0) {
						//设置订单列表页数信息
						orderListActivity.pageIndex += 1;
					}*/
                    if (orderListActivity.getOrderListFlag == 1 || orderListActivity.getOrderListFlag == 2) {
                        orderListActivity.orderInfoList.clear();
                        orderListActivity.orderInfoList.addAll(tmpList);
                    } else if (orderListActivity.getOrderListFlag == 3 && tmpList != null && tmpList.size() > 0) {
                        pos = orderListActivity.mListView.getLastVisiblePosition();
                        orderListActivity.orderInfoList.addAll(orderListActivity.orderInfoList.size(), tmpList);
                    } else if (orderListActivity.getOrderListFlag == 3 && (tmpList == null || tmpList.size() == 0)) {
                        orderListActivity.mListView.hideFooterView();
                        DialogUtil.createShortDialog(orderListActivity, "没有更早的订单！");
                    }
                    orderListActivity.orderListAdapter.notifyDataSetChanged();
                    if (pos != -1) {
                        orderListActivity.mListView.setSelection(pos);
                    }
                    break;
                case Constant.GET_WEB_DATA_EXCEPTION:
                    break;
                case Constant.GET_WEB_DATA_FALSE:
                    if (orderListActivity.getOrderListFlag == 1 || orderListActivity.getOrderListFlag == 2) {
                        orderListActivity.orderInfoList.clear();
                        orderListActivity.orderListAdapter.notifyDataSetChanged();
                    }
                    String message = (String) msg.obj;
                    DialogUtil.createShortDialog(orderListActivity, message);
                    break;
                default:
                    if (orderListActivity.getOrderListFlag == 1 || orderListActivity.getOrderListFlag == 2) {
                        orderListActivity.orderInfoList.clear();
                        orderListActivity.orderListAdapter.notifyDataSetChanged();
                    }
                    DialogUtil.createShortDialog(orderListActivity, "您的网络貌似不给力，请重试");
                    break;
                case 4:
                    orderListActivity.lastOrderSource = -1;
                    orderListActivity.lastOrderClassify = -1;
                    orderListActivity.lastOrderStatus = -1;
                    orderListActivity.lastOrderPayStatus = -1;
                    orderListActivity.refreshList(1);
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(orderListActivity, orderListActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(orderListActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + orderListActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(orderListActivity);
                    orderListActivity.packageUpdateUtil = new PackageUpdateUtil(orderListActivity, orderListActivity.handler, fileCache, downloadFileUrl, false, orderListActivity.userinfoApplication);
                    orderListActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    orderListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = orderListActivity.getFileStreamPath(filename);
                    file.getName();
                    orderListActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
            }
            orderListActivity.onLoad();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_order_list);
        // 订单筛选
        orderSearchNewButton = (ImageButton) findViewById(R.id.order_search_new_btn);
        //订单搜索
        orderSearchBtn = (ImageButton) findViewById(R.id.order_search_btn);
        orderSearchNewButton.setOnClickListener(this);
        orderSearchBtn.setOnClickListener(this);
        orderListTitleText = (TextView) findViewById(R.id.order_list_title_text);
        orderListPageInfoText = (TextView) findViewById(R.id.order_page_info_text);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userRole = getIntent().getIntExtra("USER_ROLE", Constant.USER_ROLE_CUSTOMER);
        lastOrderSource = getIntent().getIntExtra("ORDER_SOURCE", -1);
        lastOrderStatus = getIntent().getIntExtra("ORDER_STATUS", -1);
        lastOrderClassify = getIntent().getIntExtra("ORDER_TYPE", -1);
        userinfoApplication = UserInfoApplication.getInstance();
        orderManager = new OrderManager();
        orderBaseConditionInfo = new OrderListBaseConditionInfo();
        orderBaseConditionInfo.setAccountID(userinfoApplication.getAccountInfo().getAccountId());
        orderBaseConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
        if (userRole == Constant.USER_ROLE_BUSINESS) {
            orderBaseConditionInfo.setCustomerID(0);
            orderBaseConditionInfo.setIsBusiness(1);
            int authAllTheBranchOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
            if (authAllTheBranchOrderRead == 1)
                isAllBranchOrder = true;
            //获得筛选条件
            getConditionFromSharePre();
            findViewById(R.id.order_list_head_layout).setVisibility(View.GONE);
        } else {
            orderBaseConditionInfo.setFilterByTimeFlag(0);
            orderBaseConditionInfo.setOrderSource(lastOrderSource);
            orderBaseConditionInfo.setProductType(lastOrderClassify);
            orderBaseConditionInfo.setStatus(lastOrderStatus);
            orderBaseConditionInfo.setPaymentStatus(lastOrderPayStatus);
            orderBaseConditionInfo.setResponsiblePersonIDs("");
            orderBaseConditionInfo.setCustomerID(userinfoApplication.getSelectedCustomerID());
            orderBaseConditionInfo.setIsBusiness(0);
            orderBaseConditionInfo.setIsAllTheBranch(false);
            findViewById(R.id.order_list_head_layout).setVisibility(View.VISIBLE);
        }
        orderInfoList = new ArrayList<OrderInfo>();

        boolean isFromJpush = getIntent().getBooleanExtra("FromJpush", false);
        if (isFromJpush) {
            if (userinfoApplication.getAccountInfo() != null
                    && userinfoApplication.getAccountInfo().getAccountId() != 0)
                initView(lastOrderStatus);
            else
                finish();
        } else
            initView(lastOrderStatus);

    }

    @SuppressWarnings("deprecation")
    private void onLoad() {
        mListView.stopRefresh();
        mListView.stopLoadMore();
        mListView.setRefreshTime(new Date().toLocaleString());
    }

    private void getConditionFromSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.OrderFlag);
        String value = sharePreUtil.getValue(key);
        JSONObject jsValue = null;
        try {
            jsValue = new JSONObject(value);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        orderBaseConditionInfo.initAsJson(jsValue);
    }

    protected void initView(final int orderStatus) {
        mListView = (XListView) findViewById(R.id.order_list_view);
        mListView.setOnItemClickListener(this);
        mListView.setXListViewListener(this);
        orderInfoList = new ArrayList<OrderInfo>();
        orderListAdapter = new OrderListAdapter(this, orderInfoList, userRole);
        mListView.setAdapter(orderListAdapter);
        mListView.setPullLoadEnable(true);
        orderInfoList.clear();
        getLayoutInflater().inflate(R.xml.up_pull_load_more, null);
        if (userRole == Constant.USER_ROLE_BUSINESS) {
            if (isAllBranchOrder)
                orderListTitleText.setText(getResources().getString(R.string.business_order_list_title_text));
            else
                orderListTitleText.setText(getResources().getString(R.string.about_business_order_list_title_text));

        } else if (userRole == Constant.USER_ROLE_CUSTOMER) {
            if (lastOrderClassify == 0)
                orderListTitleText.setText(userinfoApplication.getSelectedCustomerName() + "的订单");
            else if (lastOrderClassify == 1 && lastOrderStatus == 0)
                orderListTitleText.setText(userinfoApplication.getSelectedCustomerName() + "的订单");
            else
                orderListTitleText.setText(userinfoApplication.getSelectedCustomerName() + "的订单");

        }
        initPageIndex();
        refreshList(1);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if ((requestCode == 1 || requestCode == 2) && resultCode == 1) {
            orderBaseConditionInfo = (OrderListBaseConditionInfo) data.getSerializableExtra("baseCondition");
            initPageIndex();
            refreshList(1);
        }
    }

    private void initPageIndex() {
        pageIndex = 1;
    }

    private void refreshList(int flag) {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        // 取老数据时，已经取完数据不在调用后台
        if (flag == 3 && (pageIndex > pageCount || orderInfoList.size() < 10)) {
            DialogUtil.createShortDialog(this, "没有更早的订单！");
            onLoad();
            mListView.hideFooterView();
            return;
        } else {
            mListView.setPullLoadEnable(true);
        }
        isRefresh = true;
        getOrderListFlag = flag;
        if (flag == 1) {
            if (progressDialog == null) {
                progressDialog = ProgressDialogUtil.createProgressDialog(this);
            }
        }
        OrderListConditionBuilder orderListConditionBuilder = new OrderListBaseConditionInfo.OrderListConditionBuilder();
        int currentPageIndex = 1;
        String createTime = "";
        if (getOrderListFlag == 3) {
            currentPageIndex = pageIndex;
            // 传订单列表的第一个OrderID
            if (currentPageIndex >= 1)
                createTime = orderInfoList.get(0).getCreateTime();
        } else if (getOrderListFlag == 2) {
            initPageIndex();
        }
        if (userRole == Constant.USER_ROLE_BUSINESS) {
            orderListConditionBuilder.setAccountID(orderBaseConditionInfo.getAccountID())
                    .setBranchID(orderBaseConditionInfo.getBranchID())
                    .setCreateTime(createTime).setPageIndex(currentPageIndex).setPageSize(10)
                    .setPaymentStatus(orderBaseConditionInfo.getPaymentStatus()).setOrderSource(orderBaseConditionInfo.getOrderSource())
                    .setProductType(orderBaseConditionInfo.getProductType())
                    .setStatus(orderBaseConditionInfo.getStatus()).setResponsibleID(orderBaseConditionInfo.getResponsiblePersonID())
                    .setCustomerID(orderBaseConditionInfo.getCustomerID())
                    .setFilterByTimeFlag(orderBaseConditionInfo.getFilterByTimeFlag()).setStartDate(orderBaseConditionInfo.getStartDate()).setEndDate(orderBaseConditionInfo.getEndDate()).setIsAllBranchOrder(isAllBranchOrder).setSerchWord(orderBaseConditionInfo.getSearchWord());
            orderManager.getOrderList(handler, orderListConditionBuilder.create(), userinfoApplication);
        } else if (userRole == Constant.USER_ROLE_CUSTOMER) {
            if (userinfoApplication.getSelectedCustomerID() == 0)
                DialogUtil.createMakeSureDialog(this, "温馨提示", "您未选中顾客，不能进行操作");
            else {
                orderListConditionBuilder.setAccountID(orderBaseConditionInfo.getAccountID())
                        .setBranchID(0)
                        .setCreateTime(createTime).setPageIndex(currentPageIndex).setPageSize(10)
                        .setPaymentStatus(orderBaseConditionInfo.getPaymentStatus()).setOrderSource(orderBaseConditionInfo.getOrderSource())
                        .setProductType(orderBaseConditionInfo.getProductType())
                        .setStatus(orderBaseConditionInfo.getStatus()).setResponsibleID(orderBaseConditionInfo.getResponsiblePersonID())
                        .setCustomerID(userinfoApplication.getSelectedCustomerID())
                        .setFilterByTimeFlag(orderBaseConditionInfo.getFilterByTimeFlag()).setStartDate(orderBaseConditionInfo.getStartDate()).setEndDate(orderBaseConditionInfo.getEndDate()).setSerchWord(orderBaseConditionInfo.getSearchWord()).setIsAllBranchOrder(true);
                orderManager.getOrderList(handler, orderListConditionBuilder.create(), userinfoApplication);
            }
        }
    }

    /**
     * 取最新数据(下拉刷新)
     */
    @Override
    public void onRefresh() {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        refreshList(2);
        /*pageIndex = pageIndex - 1;
        if (pageIndex >= 1 && pageIndex <= pageCount) {
            refreshList(3);
        } else {
            pageIndex = 1;
            refreshList(2);
        }*/
    }

    /**
     * 取老数据(加载更多)
     */
    @Override
    public void onLoadMore() {
        // 上一次取数据任务还没有完成，不在调用后台
        if (isRefresh)
            return;
        pageIndex = pageIndex + 1;
        if (pageIndex > pageCount || orderInfoList.size() < 10) {
            DialogUtil.createShortDialog(this, "没有更早的订单！");
            onLoad();
            mListView.hideFooterView();
            pageIndex = pageCount;
            return;
        }
        refreshList(3);
    }

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view,
                            int position, long id) {
        // position!=0 listView的headView下拉刷新无点击事件
        if (position != 0) {
            if (orderInfoList != null && orderInfoList.size() != 0) {
                OrderInfo orderInfo = orderInfoList.get(position - 1);
                Bundle bundle = new Bundle();
                bundle.putSerializable("orderInfo", orderInfo);
                Intent destIntent = new Intent(this, OrderDetailActivity.class);
                destIntent.putExtra("userRole", userRole);
                destIntent.putExtra("FromOrderList", true);
                destIntent.putExtras(bundle);
                startActivity(destIntent);
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        switch (view.getId()) {
            // 跳转到高级搜索视图  如果是左侧菜单 点击高级筛选，则调用Parent的startActivityForResult
            case R.id.order_search_new_btn:
                Intent destIntent = new Intent(this, OrderSearchNewActivity.class);
                destIntent.putExtra("userRole", userRole);
                destIntent.putExtra("ORDER_SOURCE", lastOrderSource);
                destIntent.putExtra("ORDER_TYPE", lastOrderClassify);
                destIntent.putExtra("ORDER_STATUS", lastOrderStatus);
                if (userRole == Constant.USER_ROLE_BUSINESS)
                    getParent().startActivityForResult(destIntent, 1);
                else
                    startActivityForResult(destIntent, 1);
                break;
            case R.id.order_search_btn:
                Intent searchIntent = new Intent(this, OrderSearchActivity.class);
                if (userRole == Constant.USER_ROLE_BUSINESS)
                    getParent().startActivityForResult(searchIntent, 2);
                else
                    startActivityForResult(searchIntent, 2);
                break;
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        // TODO Auto-generated method stub
        super.onNewIntent(intent);
        String isExit = intent.getStringExtra("exit");
        if (isExit != null && isExit.equals("1")) {
            userinfoApplication.setAccountInfo(null);
            userinfoApplication.setSelectedCustomerID(0);
            userinfoApplication.setSelectedCustomerName("");
            userinfoApplication.setSelectedCustomerHeadImageURL("");
            userinfoApplication.setSelectedCustomerLoginMobile("");
            userinfoApplication.setAccountNewMessageCount(0);
            userinfoApplication.setAccountNewRemindCount(0);
            userinfoApplication.setOrderInfo(null);
            Constant.formalFlag = 0;
            finish();
        } else {
            userRole = intent.getIntExtra("USER_ROLE", 1);
            initPageIndex();
            if (userRole == Constant.USER_ROLE_BUSINESS) {
                int authAllTheBranchOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
                if (authAllTheBranchOrderRead == 1)
                    isAllBranchOrder = true;
                if (isAllBranchOrder)
                    orderListTitleText.setText(getResources().getString(R.string.business_order_list_title_text));
                else
                    orderListTitleText.setText(getResources().getString(R.string.about_business_order_list_title_text));
                //获得筛选条件
                getConditionFromSharePre();
                findViewById(R.id.order_list_head_layout).setVisibility(View.GONE);
            } else if (userRole == Constant.USER_ROLE_CUSTOMER) {
                if (lastOrderClassify == 0)
                    orderListTitleText.setText(R.string.active_service_order);
                else if (lastOrderClassify == 1 && lastOrderStatus == 0)
                    orderListTitleText.setText(R.string.to_be_reach_commodity_order);
                else
                    orderListTitleText.setText(getResources().getString(R.string.customer_order_list_title_text));
                if (orderBaseConditionInfo == null)
                    orderBaseConditionInfo = new OrderListBaseConditionInfo();
                orderBaseConditionInfo.setAccountID(userinfoApplication.getAccountInfo().getAccountId());
                orderBaseConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
                orderBaseConditionInfo.setIsBusiness(1);
                orderBaseConditionInfo.setFilterByTimeFlag(0);
                orderBaseConditionInfo.setOrderSource(lastOrderSource);
                orderBaseConditionInfo.setProductType(lastOrderClassify);
                orderBaseConditionInfo.setStatus(lastOrderStatus);
                orderBaseConditionInfo.setResponsiblePersonIDs("");
                orderBaseConditionInfo.setCustomerID(0);
                findViewById(R.id.order_list_head_layout).setVisibility(View.VISIBLE);
            }
            mListView.setPullLoadEnable(true);
            orderInfoList.clear();
            refreshList(1);
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        isForeground = true;
        if (messageRecevice == null)
            messageRecevice = new MessageRecevice(handler);

        if (filter == null) {
            filter = new IntentFilter();
            filter.addAction(NEW_MESSAGE_BROADCAST_ACTION);
        }
        this.registerReceiver(messageRecevice, filter);
    }

    @Override
    protected void onPause() {
        super.onPause();
        isForeground = false;
        unregisterReceiver(messageRecevice);
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
        if (orderInfoList != null) {
            orderInfoList.clear();
            orderInfoList = null;
        }
    }

    public class MessageRecevice extends BroadcastReceiver {
        Handler mHandler;

        public MessageRecevice(Handler handler) {
            mHandler = handler;
        }

        @Override
        public void onReceive(Context arg0, Intent arg1) {
            // TODO Auto-generated method stub
            mHandler.obtainMessage(4).sendToTarget();
        }

    }
}
