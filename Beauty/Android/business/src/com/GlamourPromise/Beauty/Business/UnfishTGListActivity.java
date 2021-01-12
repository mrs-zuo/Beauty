package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;

import com.GlamourPromise.Beauty.adapter.UnfinishTGOrderListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.SearchPersonLocal;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.GenerateMenu;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.view.BusinessLeftImageButton;
import com.GlamourPromise.Beauty.view.BusinessRightImageButton;
import com.GlamourPromise.Beauty.view.sign.HandwritingActivity;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.Serializable;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/*
 * 结单画面
 * */
public class UnfishTGListActivity extends BaseActivity implements OnClickListener, OnItemClickListener {
    private UnfishTGListActivityHandler mHandler = new UnfishTGListActivityHandler(this);
    private List<OrderInfo> unfinshTGOrderList;
    private ListView unfinishTgOrderListView;
    private Button completeUnfinishTgOrderBtn;
    private ImageView allTGOrderSelectCheckBox, unfinishTgOrderFilterBtn;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UnfinishTGOrderListAdapter unfinishTGOrderListAdapter;
    private UserInfoApplication userinfoApplication;
    public Boolean isAllItemSelect;//全选标记
    private ListItemClick listItemClick;
    private PackageUpdateUtil packageUpdateUtil;
    private List<SearchPersonLocal> customerList;//筛选的顾客列表
    private List<SearchPersonLocal> servicePICList;//筛选的服务顾问列表
    private int authAllOrderRead;//读取所有订单(预约)的权限
    // activity 销毁(onDestroy)标志
    private boolean exit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_unfinish_tg_order);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        authAllOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
        initView();
    }

    private static class UnfishTGListActivityHandler extends Handler {
        private final UnfishTGListActivity unfishTGListActivity;

        private UnfishTGListActivityHandler(UnfishTGListActivity activity) {
            WeakReference<UnfishTGListActivity> weakReference = new WeakReference<UnfishTGListActivity>(activity);
            unfishTGListActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message message) {
            // 当activity未加载完成时,用户返回的情况
            if (unfishTGListActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (unfishTGListActivity.progressDialog != null) {
                unfishTGListActivity.progressDialog.dismiss();
                unfishTGListActivity.progressDialog = null;
            }
            if (message.what == 1) {
                unfishTGListActivity.unfinishTGOrderListAdapter = new UnfinishTGOrderListAdapter(unfishTGListActivity, unfishTGListActivity.unfinshTGOrderList, unfishTGListActivity.listItemClick);
                unfishTGListActivity.unfinishTgOrderListView.setAdapter(unfishTGListActivity.unfinishTGOrderListAdapter);
                //提取当前数据的里面的顾客列表和服务顾问列表
                unfishTGListActivity.customerList = new ArrayList<SearchPersonLocal>();
                unfishTGListActivity.servicePICList = new ArrayList<SearchPersonLocal>();
                for (OrderInfo orderInfo : unfishTGListActivity.unfinshTGOrderList) {
                    SearchPersonLocal customer = new SearchPersonLocal();
                    customer.setPersonID(orderInfo.getCustomerID());
                    customer.setPersonName(orderInfo.getCustomerName());
                    SearchPersonLocal servicePIC = new SearchPersonLocal();
                    servicePIC.setPersonID(orderInfo.getResponsiblePersonID());
                    servicePIC.setPersonName(orderInfo.getResponsiblePersonName());
                    if (!unfishTGListActivity.customerList.contains(customer)) {
                        unfishTGListActivity.customerList.add(customer);
                    }
                    if (!unfishTGListActivity.servicePICList.contains(servicePIC)) {
                        unfishTGListActivity.servicePICList.add(servicePIC);
                    }
                }
            } else if (message.what == 2)
                DialogUtil.createShortDialog(unfishTGListActivity, "您的网络貌似不给力，请重试");
            else if (message.what == 3) {
                List<OrderInfo> searchOrderList = (List<OrderInfo>) message.obj;
                unfishTGListActivity.unfinishTGOrderListAdapter = new UnfinishTGOrderListAdapter(unfishTGListActivity, searchOrderList, unfishTGListActivity.listItemClick);
                unfishTGListActivity.unfinishTgOrderListView.setAdapter(unfishTGListActivity.unfinishTGOrderListAdapter);
            } else if (message.what == 0) {
                DialogUtil.createShortDialog(unfishTGListActivity, (String) message.obj);
            } else if (message.what == Constant.LOGIN_ERROR) {
                DialogUtil.createShortDialog(unfishTGListActivity, unfishTGListActivity.getString(R.string.login_error_message));
                UserInfoApplication.getInstance().exitForLogin(unfishTGListActivity);
            } else if (message.what == Constant.APP_VERSION_ERROR) {
                String downloadFileUrl = Constant.SERVER_URL + unfishTGListActivity.getString(R.string.download_apk_address);
                FileCache fileCache = new FileCache(unfishTGListActivity);
                unfishTGListActivity.packageUpdateUtil = new PackageUpdateUtil(unfishTGListActivity, unfishTGListActivity.mHandler, fileCache, downloadFileUrl, false, unfishTGListActivity.userinfoApplication);
                unfishTGListActivity.packageUpdateUtil.getPackageVersionInfo();
                ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                serverPackageVersion.setPackageVersion((String) message.obj);
                unfishTGListActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
            }
            //包进行下载安装升级
            else if (message.what == 5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
                String filename = "com.glamourpromise.beauty.business.apk";
                File file = unfishTGListActivity.getFileStreamPath(filename);
                file.getName();
                unfishTGListActivity.packageUpdateUtil.showInstallDialog();
            } else if (message.what == -5) {
                ((DownloadInfo) message.obj).getUpdateDialog().cancel();
            } else if (message.what == 7) {
                int downLoadFileSize = ((DownloadInfo) message.obj).getDownloadApkSize();
                ((DownloadInfo) message.obj).getUpdateDialog().setProgress(downLoadFileSize);
            } else if (message.what == 6) {
                //结单成功
                unfishTGListActivity.requestWebService();
                DialogUtil.createShortDialog(unfishTGListActivity, "结单成功!");
            }
            if (unfishTGListActivity.requestWebServiceThread != null) {
                unfishTGListActivity.requestWebServiceThread.interrupt();
                unfishTGListActivity.requestWebServiceThread = null;
            }
        }
    }

    protected void initView() {
        unfinishTgOrderListView = (ListView) findViewById(R.id.unfinsh_tg_order_list);
        unfinishTgOrderListView.setOnItemClickListener(this);
        completeUnfinishTgOrderBtn = (Button) findViewById(R.id.complete_unfinsh_tg_order_btn);
        allTGOrderSelectCheckBox = (ImageView) findViewById(R.id.select_all_unfinish_tg_order);
        completeUnfinishTgOrderBtn.setOnClickListener(this);
        allTGOrderSelectCheckBox.setOnClickListener(this);
        allTGOrderSelectCheckBox.setBackgroundResource(R.drawable.no_select_all_btn);
        unfinishTgOrderFilterBtn = (ImageView) findViewById(R.id.unfinish_tg_order_filter_btn);
        unfinishTgOrderFilterBtn.setOnClickListener(this);
        isAllItemSelect = false;
        listItemClick = new ListItemClick() {
            @Override
            public void onClick(View item, View widget, int position, int which) {

            }

            @Override
            public void allOrderSelectProcess(int currentSelectCount) {
                // 判断是否全选，若全部已选择则更新全选按钮的图标
                if (currentSelectCount == unfinshTGOrderList.size()) {
                    allTGOrderSelectCheckBox.setBackgroundResource(R.drawable.select_all_btn);
                    isAllItemSelect = true;
                } else {
                    allTGOrderSelectCheckBox.setBackgroundResource(R.drawable.no_select_all_btn);
                    isAllItemSelect = false;
                }
            }
        };
        requestWebService();
    }

    private void requestWebService() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        if (unfinshTGOrderList == null)
            unfinshTGOrderList = new ArrayList<OrderInfo>();
        else
            unfinshTGOrderList.clear();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetUnfinishTGList";
                String endPoint = "Order";
                JSONObject unFinishTGJsonParam = new JSONObject();
                try {
                    unFinishTGJsonParam.put("ProductType", -1);
                    unFinishTGJsonParam.put("CustomerID", 0);
                    unFinishTGJsonParam.put("IsToday", false);
                } catch (JSONException e) {

                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, unFinishTGJsonParam.toString(), userinfoApplication);
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
                    }
                    if (code == 1) {
                        try {
                            unFinishTGArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (unFinishTGArray != null) {
                            for (int i = 0; i < unFinishTGArray.length(); i++) {
                                OrderInfo unfinishOrder = new OrderInfo();
                                JSONObject unfinishOrderJson = null;
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
                                int customerID = 0;
                                String customerName = "";
                                int isConfirmed = 0;
                                try {
                                    unfinishOrderJson = unFinishTGArray.getJSONObject(i);
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
                                    if (unfinishOrderJson.has("CustomerID") && !unfinishOrderJson.isNull("CustomerID"))
                                        customerID = unfinishOrderJson.getInt("CustomerID");
                                    if (unfinishOrderJson.has("CustomerName") && !unfinishOrderJson.isNull("CustomerName"))
                                        customerName = unfinishOrderJson.getString("CustomerName");
                                    if (unfinishOrderJson.has("IsConfirmed") && !unfinishOrderJson.isNull("IsConfirmed"))
                                        isConfirmed = unfinishOrderJson.getInt("IsConfirmed");
                                } catch (JSONException e) {
                                }
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
                                unfinishOrder.setCustomerID(customerID);
                                unfinishOrder.setCustomerName(customerName);
                                unfinishOrder.setIsConfirmed(isConfirmed);
                                //如果有查看所有订单/预约的权限   如果没有 则只能显示我自己的订单
                                if (authAllOrderRead == 1)
                                    unfinshTGOrderList.add(unfinishOrder);
                                else if (authAllOrderRead == 0) {
                                    if (unfinishOrder.getResponsiblePersonID() == userinfoApplication.getAccountInfo().getAccountId())
                                        unfinshTGOrderList.add(unfinishOrder);
                                }
                            }
                        }
                        mHandler.sendEmptyMessage(1);
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

    @Override
    public void onClick(View view) {
        if (ProgressDialogUtil.isFastClick())
            return;
        switch (view.getId()) {
            case R.id.complete_unfinsh_tg_order_btn:
                List<OrderInfo> completeOrderList = unfinishTGOrderListAdapter.getUnFinishTgOrderList();
                boolean hasDiffCustomer = false;
                if (completeOrderList != null && completeOrderList.size() > 1) {
                    int firstCustomerID = completeOrderList.get(0).getCustomerID();
                    for (int i = 1; i < completeOrderList.size(); i++) {
                        if (firstCustomerID != completeOrderList.get(i).getCustomerID()) {
                            hasDiffCustomer = true;
                            break;
                        }
                    }
                }
                //选择的订单数量为0时
                if (completeOrderList.size() == 0 || completeOrderList == null)
                    DialogUtil.createShortDialog(this, "请选择订单");
                else if (hasDiffCustomer)
                    DialogUtil.createShortDialog(this, "不同顾客不能一起结单");
                else {
                    progressDialog = ProgressDialogUtil.createProgressDialog(this);
                    //completeTG(completeOrderList);
                    checkConfirmed(completeOrderList);
                }
                break;
            case R.id.select_all_unfinish_tg_order:
                //全选
                if (isAllItemSelect) {
                    view.setBackgroundResource(R.drawable.no_select_all_btn);
                    unfinishTGOrderListAdapter.setAllUnfinshTgOrderUnSelect();
                    isAllItemSelect = false;
                }
                //取消全选
                else {
                    view.setBackgroundResource(R.drawable.select_all_btn);
                    unfinishTGOrderListAdapter.setAllUnfinshTgOrderSelect();
                    isAllItemSelect = true;
                }
                unfinishTGOrderListAdapter.notifyDataSetChanged();
                break;
            //跳转到结单筛选页面
            case R.id.unfinish_tg_order_filter_btn:
                Intent destIntent2 = new Intent(this, UnFinishTGOrderAdvancedSearchActivity.class);
                Bundle bundle = new Bundle();
                bundle.putSerializable("customerList", (Serializable) customerList);
                bundle.putSerializable("servicePICList", (Serializable) servicePICList);
                destIntent2.putExtras(bundle);
                startActivityForResult(destIntent2, 200);
                break;
        }
    }

    //验证每个单子的确认方式 如果当中有一个是电子签名确认的 则需要跳转到签字页
    private void checkConfirmed(final List<OrderInfo> completeOrderInfoList) {
        boolean needSign = false;
        for (OrderInfo order : completeOrderInfoList) {
            if (order.getIsConfirmed() == 2) {
                needSign = true;
                break;
            }
        }
        if (needSign) {
            Intent handWriteIntent = new Intent();
            handWriteIntent.setClass(this, HandwritingActivity.class);
            startActivityForResult(handWriteIntent, 100);
        } else {
            completeTG(null);
        }
    }

    //将结单信息提交到服务器 撤销或者是结单
    private void completeTG(final String signPic) {
        final List<OrderInfo> completeOrderList = unfinishTGOrderListAdapter.getUnFinishTgOrderList();
        final JSONArray tempArray = new JSONArray();
        try {
            for (OrderInfo unfinishOrder : completeOrderList) {
                JSONObject unfinishOrderJson = new JSONObject();
                unfinishOrderJson.put("OrderType", unfinishOrder.getProductType());
                unfinishOrderJson.put("OrderID", unfinishOrder.getOrderID());
                unfinishOrderJson.put("OrderObjectID", unfinishOrder.getOrderObejctID());
                unfinishOrderJson.put("GroupNo", unfinishOrder.getTgGroupNo());
                tempArray.put(unfinishOrderJson);
            }
        } catch (JSONException e) {
        }
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "CompleteTreatGroup";
                String endPoint = "Order";
                JSONObject completeTreatGroupJson = new JSONObject();
                try {
                    if (signPic != null && !"".equals(signPic)) {
                        completeTreatGroupJson.put("SignImg", signPic);
                        completeTreatGroupJson.put("ImageFormat", ".JPEG");
                    }
                    completeTreatGroupJson.put("CustomerID", completeOrderList.get(0).getCustomerID());
                    completeTreatGroupJson.put("TGDetailList", tempArray);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, completeTreatGroupJson.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    mHandler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    String msg = "";
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        msg = resultJson.getString("Message");
                    } catch (JSONException e) {

                    }
                    if (code == 1) {
                        Message message = new Message();
                        message.what = 6;
                        message.obj = completeOrderList;
                        mHandler.sendMessage(message);
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

    public interface ListItemClick {
        void onClick(View item, View widget, int position, int which);

        void allOrderSelectProcess(int currentSelectCount);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode != RESULT_OK) {
            return;
        }
        if (requestCode == 100) {
            String signPic = data.getStringExtra("signPic");
            completeTG(signPic);
        } else {
            int customerID = data.getIntExtra("customerID", 0);
            int servicePICID = data.getIntExtra("servicePICID", 0);
            List<OrderInfo> searchOrderInfo = new ArrayList<OrderInfo>();
            if (customerID != 0 && servicePICID == 0) {
                for (OrderInfo orderInfo : unfinshTGOrderList) {
                    if (orderInfo.getCustomerID() == customerID) {
                        searchOrderInfo.add(orderInfo);
                    }
                }
                Message message = new Message();
                message.what = 3;
                message.obj = searchOrderInfo;
                mHandler.sendMessage(message);
            } else if (customerID == 0 && servicePICID != 0) {
                for (OrderInfo orderInfo : unfinshTGOrderList) {
                    if (orderInfo.getResponsiblePersonID() == servicePICID) {
                        searchOrderInfo.add(orderInfo);
                    }
                }
                Message message = new Message();
                message.what = 3;
                message.obj = searchOrderInfo;
                mHandler.sendMessage(message);
            } else if (customerID != 0 && servicePICID != 0) {
                for (OrderInfo orderInfo : unfinshTGOrderList) {
                    if (orderInfo.getCustomerID() == customerID && orderInfo.getResponsiblePersonID() == servicePICID) {
                        searchOrderInfo.add(orderInfo);
                    }
                }
                Message message = new Message();
                message.what = 3;
                message.obj = searchOrderInfo;
                mHandler.sendMessage(message);
            } else {
                requestWebService();
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        if (unfinishTGOrderListAdapter != null && unfinishTGOrderListAdapter.getCount() > 0) {
            OrderInfo orderInfo = unfinishTGOrderListAdapter.getOrderInfoData().get(position);
            Bundle bundle = new Bundle();
            bundle.putSerializable("orderInfo", orderInfo);
            Intent destIntent = new Intent(this, OrderDetailActivity.class);
            destIntent.putExtra("FromOrderList", true);
            destIntent.putExtras(bundle);
            startActivity(destIntent);
        }
    }
}
