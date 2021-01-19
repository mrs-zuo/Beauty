package com.GlamourPromise.Beauty.Business;

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
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.GlamourPromise.Beauty.adapter.AppointmentCompleteOrderListAdapter;
import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class AppointmentCusOldOrderActivity extends BaseActivity implements OnClickListener, OnItemClickListener {
    private AppointmentCusOldOrderActivityHandler mHandler = new AppointmentCusOldOrderActivityHandler(this);
    private PackageUpdateUtil packageUpdateUtil;
    public AppointmentCompleteOrderListAdapter appointmentCompleteOrderListAdapter;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private ListView dispenseCustomerOldOrderListView;
    private List<OrderInfo> dispenseCustomerOldOrderList;
    Button appointmentDetailOrderMakeSure;
    private int customerID;
    private String customerName;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentCusOldOrderActivityHandler extends Handler {
        private final AppointmentCusOldOrderActivity appointmentCusOldOrderActivity;

        private AppointmentCusOldOrderActivityHandler(AppointmentCusOldOrderActivity activity) {
            WeakReference<AppointmentCusOldOrderActivity> weakReference = new WeakReference<AppointmentCusOldOrderActivity>(activity);
            appointmentCusOldOrderActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentCusOldOrderActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentCusOldOrderActivity.requestWebServiceThread != null) {
                appointmentCusOldOrderActivity.requestWebServiceThread.interrupt();
                appointmentCusOldOrderActivity.requestWebServiceThread = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(appointmentCusOldOrderActivity, (String) msg.obj);
                    break;
                case 1:
                    appointmentCusOldOrderActivity.appointmentCompleteOrderListAdapter = new AppointmentCompleteOrderListAdapter(appointmentCusOldOrderActivity, appointmentCusOldOrderActivity.dispenseCustomerOldOrderList);
                    appointmentCusOldOrderActivity.dispenseCustomerOldOrderListView.setAdapter(appointmentCusOldOrderActivity.appointmentCompleteOrderListAdapter);
                    break;
                case 2:
                    DialogUtil.createShortDialog(appointmentCusOldOrderActivity, "您的网络貌似不给力，请重试");
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentCusOldOrderActivity, appointmentCusOldOrderActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentCusOldOrderActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentCusOldOrderActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentCusOldOrderActivity);
                    appointmentCusOldOrderActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentCusOldOrderActivity, appointmentCusOldOrderActivity.mHandler, fileCache, downloadFileUrl, false, appointmentCusOldOrderActivity.userinfoApplication);
                    appointmentCusOldOrderActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentCusOldOrderActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = appointmentCusOldOrderActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentCusOldOrderActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    break;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.appointment_complete_order_list);
        userinfoApplication = UserInfoApplication.getInstance();
        dispenseCustomerOldOrderListView = (ListView) findViewById(R.id.dispense_customer_old_order_listview);
        appointmentDetailOrderMakeSure = (Button) findViewById(R.id.appointment_detail_order_make_sure);
        ImageButton orderSearchNewBackBtn = (ImageButton) findViewById(R.id.order_search_new_back_btn);
        orderSearchNewBackBtn.setOnClickListener(this);
        appointmentDetailOrderMakeSure.setOnClickListener(this);
        dispenseCustomerOldOrderListView.setOnItemClickListener(this);
        TextView appointmentOldOrderText = (TextView) findViewById(R.id.appointment_old_order_text);
        Intent intent = getIntent();
        customerID = intent.getIntExtra("customerID", 0);
        customerName = intent.getStringExtra("customerName");
        appointmentOldOrderText.setText("(" + customerName + ")");
        //如果选择顾客不为空时
        if (customerID != 0)
            getCustomerOldOrderData();
    }

    private void getCustomerOldOrderData() {
        if (dispenseCustomerOldOrderList != null && dispenseCustomerOldOrderList.size() > 0)
            dispenseCustomerOldOrderList.clear();
        else
            dispenseCustomerOldOrderList = new ArrayList<OrderInfo>();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetExecutingOrderList";
                String endPoint = "Order";
                JSONObject customerOldOrderJsonParam = new JSONObject();
                try {
                    customerOldOrderJsonParam.put("CustomerID", customerID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, customerOldOrderJsonParam.toString(), userinfoApplication);
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
                                int executingCount = 0;
                                String tgGroupNO = "";
                                String orderTime = "";
                                String accountName = "";
                                int accountID = 0;
                                int orderID = 0;
                                int orderObjectID = 0;
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
                                    if (unfinishOrderJson.has("ExecutingCount") && !unfinishOrderJson.isNull("ExecutingCount"))
                                        executingCount = unfinishOrderJson.getInt("ExecutingCount");
                                    if (unfinishOrderJson.has("GroupNo") && !unfinishOrderJson.isNull("GroupNo"))
                                        tgGroupNO = unfinishOrderJson.getString("GroupNo");
                                    if (unfinishOrderJson.has("OrderTime") && !unfinishOrderJson.isNull("OrderTime"))
                                        orderTime = unfinishOrderJson.getString("OrderTime");
                                    if (unfinishOrderJson.has("AccountName") && !unfinishOrderJson.isNull("AccountName"))
                                        accountName = unfinishOrderJson.getString("AccountName");
                                    if (unfinishOrderJson.has("AccountID") && !unfinishOrderJson.isNull("AccountID"))
                                        accountID = unfinishOrderJson.getInt("AccountID");
                                    if (unfinishOrderJson.has("OrderID") && !unfinishOrderJson.isNull("OrderID"))
                                        orderID = unfinishOrderJson.getInt("OrderID");
                                    if (unfinishOrderJson.has("OrderObjectID") && !unfinishOrderJson.isNull("OrderObjectID"))
                                        orderObjectID = unfinishOrderJson.getInt("OrderObjectID");
                                } catch (JSONException e) {
                                }
                                if (productType == 0) {
                                    if (totalCount != 0) {
                                        if ((totalCount - finishedCount - executingCount) > 0) {
                                            unfinishOrder.setProductName(productName);
                                            unfinishOrder.setProductType(productType);
                                            unfinishOrder.setTotalCount(totalCount);
                                            unfinishOrder.setCompleteCount(finishedCount);
                                            unfinishOrder.setExecutingCount(executingCount);
                                            unfinishOrder.setTgGroupNo(tgGroupNO);
                                            unfinishOrder.setOrderTime(orderTime);
                                            unfinishOrder.setResponsiblePersonName(accountName);
                                            unfinishOrder.setResponsiblePersonID(accountID);
                                            unfinishOrder.setOrderID(orderID);
                                            unfinishOrder.setOrderObejctID(orderObjectID);
                                            dispenseCustomerOldOrderList.add(unfinishOrder);
                                        }
                                    } else {
                                        unfinishOrder.setProductName(productName);
                                        unfinishOrder.setProductType(productType);
                                        unfinishOrder.setTotalCount(totalCount);
                                        unfinishOrder.setCompleteCount(finishedCount);
                                        unfinishOrder.setExecutingCount(executingCount);
                                        unfinishOrder.setTgGroupNo(tgGroupNO);
                                        unfinishOrder.setOrderTime(orderTime);
                                        unfinishOrder.setResponsiblePersonName(accountName);
                                        unfinishOrder.setResponsiblePersonID(accountID);
                                        unfinishOrder.setOrderID(orderID);
                                        unfinishOrder.setOrderObejctID(orderObjectID);
                                        dispenseCustomerOldOrderList.add(unfinishOrder);
                                    }
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
    public void onClick(View v) {
        Intent intent;
        switch (v.getId()) {
            case R.id.appointment_detail_order_make_sure:
                intent = new Intent(this, ServiceListActivity.class);
                intent.putExtra("CategoryID", String.valueOf(0));
                Bundle bu = new Bundle();
                bu.putInt("FROM_SOURCE", 3);
                intent.putExtras(bu);
                startActivityForResult(intent, 10);
                break;
            case R.id.order_search_new_back_btn:
                finish();
                break;
            default:
                break;
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        OrderInfo orderInfo = dispenseCustomerOldOrderList.get(position - 1);
//		if(orderInfo.getTotalCount()!=0){
//			if(orderInfo.getSurplusCount()>0){
//				Bundle bundle = new Bundle();
//				bundle.putSerializable("orderInfo",orderInfo);
//				bundle.putInt("isOldOrder", 1);//老单
//				Intent destIntent = new Intent();
//				destIntent.putExtras(bundle);
//				setResult(RESULT_OK,destIntent);
//				finish();
//			}else
//				DialogUtil.createShortDialog(AppointmentCusOldOrderActivity.this, "服务次数为零不允许预约！");
//		}else{
        Bundle bundle = new Bundle();
        bundle.putSerializable("orderInfo", orderInfo);
        bundle.putInt("isOldOrder", 1);//老单
        Intent destIntent = new Intent();
        destIntent.putExtras(bundle);
        setResult(RESULT_OK, destIntent);
        finish();
//		}
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 10) {
                Intent it = getIntent();
                Bundle bu = new Bundle();
                bu.putInt("serviceID", data.getIntExtra("serviceID", 0));
                bu.putInt("OrderObjectID", data.getIntExtra("OrderObjectID", 0));
                bu.putLong("serviceCode", data.getLongExtra("serviceCode", 0));
                bu.putString("serviceName", data.getStringExtra("serviceName"));
                bu.putInt("isOldOrder", 2);//新单
                it.putExtras(bu);
                setResult(RESULT_OK, it);
                finish();
            }
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
        if (requestWebServiceThread != null) {
            requestWebServiceThread.interrupt();
            requestWebServiceThread = null;
        }
    }
}
