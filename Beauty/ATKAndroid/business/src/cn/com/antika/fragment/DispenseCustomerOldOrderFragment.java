/**
 * DispenseCustomerOldOrderFragment.java
 * cn.com.antika.fragment
 * tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 *
 * @version V1.0
 */
package cn.com.antika.fragment;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

import cn.com.antika.adapter.DispenseCompleteOrderListAdapter;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderProduct;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.OrderDetailActivity;
import cn.com.antika.business.ProductAndOldOrderListActivity;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.webservice.WebServiceUtil;

/**
 * DispenseCustomerOldOrderFragment
 * 顾客存单的Fragment
 *
 * @author tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 */
@SuppressLint("ResourceType")
public class DispenseCustomerOldOrderFragment extends Fragment implements OnClickListener, OnItemClickListener {
    private DispenseCustomerOldOrderFragmentHandler mHandler = new DispenseCustomerOldOrderFragmentHandler(this);
    private RefreshListView dispenseCustomerOldOrderListView;
    private List<OrderInfo> dispenseCustomerOldOrderList;
    private UserInfoApplication userinfoApplication;
    private Thread requestWebServiceThread;
    public DispenseCompleteOrderListAdapter dispenseCompleteOrderListAdapter;
    private PackageUpdateUtil packageUpdateUtil;
    private Button addOrderProductListBtn, addOrderBtn;
    private List<OrderProduct> orderProductList;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreateView(inflater, container, savedInstanceState);
        if (mHandler == null)
            mHandler = new DispenseCustomerOldOrderFragmentHandler(this);
        View dispenseCustomerOldOrderView = inflater.inflate(R.xml.dispense_customer_old_order_fragment_layout, container, false);
        dispenseCustomerOldOrderListView = (RefreshListView) dispenseCustomerOldOrderView.findViewById(R.id.dispense_customer_old_order_listview);
        dispenseCustomerOldOrderList = new ArrayList<OrderInfo>();
        dispenseCompleteOrderListAdapter = new DispenseCompleteOrderListAdapter(getActivity(), dispenseCustomerOldOrderList, 2);
        dispenseCustomerOldOrderListView.setAdapter(dispenseCompleteOrderListAdapter);
        dispenseCustomerOldOrderListView.setOnItemClickListener(this);
        dispenseCustomerOldOrderListView.setOnRefreshListener(new RefreshListViewWithWebservice() {
            @Override
            public Object refreshing() {
                int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
                if (authMyOrderRead == 0) {
                    addOrderBtn.setVisibility(View.GONE);
                    addOrderProductListBtn.setVisibility(View.GONE);
                } else if (authMyOrderRead == 1) {
                    //如果选择顾客不为空时
                    if (userinfoApplication.getSelectedCustomerID() != 0)
                        getCustomerOldOrderData();
                }
                return "ok";
            }

            @Override
            public void refreshed(Object obj) {
                // TODO Auto-generated method stub

            }
        });
        userinfoApplication = (UserInfoApplication) getActivity().getApplication();
        addOrderProductListBtn = (Button) dispenseCustomerOldOrderView.findViewById(R.id.cusutomer_old_order_add_order_product_btn);
        addOrderBtn = (Button) dispenseCustomerOldOrderView.findViewById(R.id.cusutomer_old_order_add_order_btn);
        addOrderProductListBtn.setOnClickListener(this);
        addOrderBtn.setOnClickListener(this);
        OrderInfo orderInfo = userinfoApplication.getOrderInfo();
        if (orderInfo == null)
            orderInfo = new OrderInfo();
        orderProductList = orderInfo.getOrderProductList();
        if (orderProductList == null)
            orderProductList = new ArrayList<OrderProduct>();
        userinfoApplication.setOrderInfo(orderInfo);
        userinfoApplication.getOrderInfo().setOrderProductList(orderProductList);
        int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
        int authMyOrderWrite = userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
        if (authMyOrderWrite == 0) {
            addOrderBtn.setVisibility(View.GONE);
            addOrderProductListBtn.setVisibility(View.GONE);
        }
        if (authMyOrderRead == 0) {
            addOrderBtn.setVisibility(View.GONE);
            addOrderProductListBtn.setVisibility(View.GONE);
        } else if (authMyOrderRead == 1) {
            //如果选择顾客不为空时
            if (userinfoApplication.getSelectedCustomerID() != 0)
                getCustomerOldOrderData();
        }
        return dispenseCustomerOldOrderView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);

    }

    private static class DispenseCustomerOldOrderFragmentHandler extends Handler {
        private final DispenseCustomerOldOrderFragment dispenseCustomerOldOrderFragment;

        private DispenseCustomerOldOrderFragmentHandler(DispenseCustomerOldOrderFragment activity) {
            WeakReference<DispenseCustomerOldOrderFragment> weakReference = new WeakReference<DispenseCustomerOldOrderFragment>(activity);
            dispenseCustomerOldOrderFragment = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            FragmentActivity fragmentActivity = dispenseCustomerOldOrderFragment.getActivity();
            if (fragmentActivity == null) {
                return;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(fragmentActivity, (String) msg.obj);
                    break;
                case 1:
                    dispenseCustomerOldOrderFragment.setDispenseCustomerOldOrderList((List<OrderInfo>) msg.obj);
                    ((TextView) fragmentActivity.findViewById(R.id.tab_customer_old_order_title)).setText("存单" + "(" + dispenseCustomerOldOrderFragment.dispenseCustomerOldOrderList.size() + ")");
                    break;
                case 2:
                    DialogUtil.createShortDialog(fragmentActivity, "您的网络貌似不给力，请重试");
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(fragmentActivity, dispenseCustomerOldOrderFragment.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(fragmentActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + dispenseCustomerOldOrderFragment.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(fragmentActivity);
                    dispenseCustomerOldOrderFragment.packageUpdateUtil = new PackageUpdateUtil(fragmentActivity, dispenseCustomerOldOrderFragment.mHandler, fileCache, downloadFileUrl, false, dispenseCustomerOldOrderFragment.userinfoApplication);
                    dispenseCustomerOldOrderFragment.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    dispenseCustomerOldOrderFragment.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "cn.com.antika.business.apk";
                    File file = fragmentActivity.getFileStreamPath(filename);
                    file.getName();
                    dispenseCustomerOldOrderFragment.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                case 99:
                    DialogUtil.createShortDialog(fragmentActivity, "服务器异常，请重试");
                    break;
                default:
                    break;
            }
            if (dispenseCustomerOldOrderFragment.requestWebServiceThread != null) {
                dispenseCustomerOldOrderFragment.requestWebServiceThread.interrupt();
                dispenseCustomerOldOrderFragment.requestWebServiceThread = null;
            }
        }
    }

    private void getCustomerOldOrderData() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetExecutingOrderList";
                String endPoint = "Order";
                JSONObject customerOldOrderJsonParam = new JSONObject();
                try {
                    customerOldOrderJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
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
                        List<OrderInfo> orderInfoList = new ArrayList<OrderInfo>();
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
                                    mHandler.sendEmptyMessage(99);
                                    return;
                                }
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
                                if (totalCount == 0 || (executingCount + finishedCount) < totalCount) {
                                    orderInfoList.add(unfinishOrder);
                                }

                            }
                        }
                        mHandler.obtainMessage(1, orderInfoList).sendToTarget();
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

    public void clearData() {
        if (dispenseCustomerOldOrderList != null)
            dispenseCustomerOldOrderList.clear();
        if (dispenseCompleteOrderListAdapter != null)
            dispenseCompleteOrderListAdapter.notifyDataSetChanged();
    }

    private void setDispenseCustomerOldOrderList(List<OrderInfo> orderList) {
        if (dispenseCustomerOldOrderList != null) {
            dispenseCustomerOldOrderList.clear();
            dispenseCustomerOldOrderList.addAll(orderList);
            if (dispenseCompleteOrderListAdapter != null)
                dispenseCompleteOrderListAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        List<OrderInfo> orderInfoList = null;
        if (dispenseCompleteOrderListAdapter != null)
            orderInfoList = dispenseCompleteOrderListAdapter.getUnFinshOrderList();
        //加入开单列表
        if (view.getId() == R.id.cusutomer_old_order_add_order_product_btn) {
            if (orderInfoList == null || orderInfoList.size() == 0)
                DialogUtil.createShortDialog(getActivity(), "请选择商品或服务!");
            else {
                for (OrderInfo oi : orderInfoList) {
                    OrderProduct orderProduct = new OrderProduct();
                    orderProduct.setOldOrder(true);
                    orderProduct.setOldOrderID(oi.getOrderID());
                    orderProduct.setProductName(oi.getProductName());
                    orderProduct.setResponsiblePersonName(oi.getResponsiblePersonName());
                    orderProduct.setCompleteCount(oi.getCompleteCount());
                    orderProduct.setTotalCount(oi.getTotalCount());
                    orderProductList.add(orderProduct);
                }
                DialogUtil.createShortDialog(getActivity(), "加入开单列表成功！");
                ((ViewPager) getActivity().findViewById(R.id.customer_servicing_order_view_pager)).setCurrentItem(0);
            }
        }
        //立即开单  跳转到开小单界面
        else if (view.getId() == R.id.cusutomer_old_order_add_order_btn) {
            if (userinfoApplication.getSelectedCustomerID() == 0)
                DialogUtil.createShortDialog(getActivity(), "请先选择顾客!");
            else if (orderInfoList == null || orderInfoList.size() == 0)
                DialogUtil.createShortDialog(getActivity(), "请选择商品或服务!");
            else {
                Intent destIntent = new Intent(getActivity(), ProductAndOldOrderListActivity.class);
                Bundle bundle = new Bundle();
                ArrayList<String> orderIDsList = new ArrayList<String>();
                for (OrderInfo oi : orderInfoList)
                    orderIDsList.add(String.valueOf(oi.getOrderID()));
                bundle.putStringArrayList("orderIdList", orderIDsList);
                destIntent.putExtras(bundle);
                startActivity(destIntent);
            }
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        if (position != 0) {
            OrderInfo orderInfo = dispenseCustomerOldOrderList.get(position - 1);
            Bundle bundle = new Bundle();
            bundle.putSerializable("orderInfo", orderInfo);
            Intent destIntent = new Intent(getActivity(), OrderDetailActivity.class);
            destIntent.putExtra("FromOrderList", true);
            destIntent.putExtras(bundle);
            startActivity(destIntent);
        }
    }
}
