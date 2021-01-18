/**
 * DispenseCompleteOrderFragment.java
 * cn.com.antika.fragment
 * tim.zhang@bizapper.com
 * 2015年7月6日 下午1:48:56
 *
 * @version V1.0
 */
package cn.com.antika.fragment;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
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
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.business.OrderDetailActivity;
import cn.com.antika.business.R;
import cn.com.antika.constant.Constant;
import cn.com.antika.minterface.RefreshListViewWithWebservice;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.util.ProgressDialogUtil;
import cn.com.antika.view.RefreshListView;
import cn.com.antika.view.sign.HandwritingActivity;
import cn.com.antika.webservice.WebServiceUtil;

/**
 * DispenseCompleteOrderFragment 待结单的Fragment
 *
 * @author tim.zhang@bizapper.com 2015年7月6日 下午1:48:56
 */
@SuppressLint("ResourceType")
public class DispenseCompleteOrderFragment extends Fragment implements
        OnClickListener, OnItemClickListener {
    private DispenseCompleteOrderFragmentHandler mHandler = new DispenseCompleteOrderFragmentHandler(this);
    private RefreshListView dispenseCompleteOrderListView;
    private List<OrderInfo> dispenseCompleteOrderList;// 待结的订单集合
    private UserInfoApplication userinfoApplication;
    private Thread requestWebServiceThread;
    public DispenseCompleteOrderListAdapter dispenseCompleteOrderListAdapter;
    private PackageUpdateUtil packageUpdateUtil;
    private Button cancelTreatmentGroupBtn, completeTreatmentGroupBtn;
    private ProgressDialog progressDialog;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreateView(inflater, container, savedInstanceState);
        View dispenseCompleteOrderView = inflater.inflate(R.xml.dispense_complete_order_fragment_layout, container, false);
        dispenseCompleteOrderListView = (RefreshListView) dispenseCompleteOrderView.findViewById(R.id.dispense_complete_order_listview);
        dispenseCompleteOrderListView.setOnItemClickListener(this);
        dispenseCompleteOrderList = new ArrayList<OrderInfo>();
        dispenseCompleteOrderListAdapter = new DispenseCompleteOrderListAdapter(getActivity(), dispenseCompleteOrderList, 1);
        dispenseCompleteOrderListView.setAdapter(dispenseCompleteOrderListAdapter);
        dispenseCompleteOrderListView.setOnRefreshListener(new RefreshListViewWithWebservice() {

            @Override
            public Object refreshing() {
                // TODO Auto-generated method stub
                String returncode = "ok";
                if (requestWebServiceThread == null) {
                    //是否具有查看顾客的权限
                    int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
                    if (authMyOrderRead == 0) {
                        cancelTreatmentGroupBtn.setVisibility(View.GONE);
                        completeTreatmentGroupBtn.setVisibility(View.GONE);
                    } else if (authMyOrderRead == 1) {
                        // 如果选择顾客不为空时
                        if (userinfoApplication.getSelectedCustomerID() != 0) {
                            getCompleteOrderData();
                        }
                    }
                }
                return returncode;
            }

            @Override
            public void refreshed(Object obj) {
                // TODO Auto-generated method stub

            }
        });
        // 撤销按钮
        cancelTreatmentGroupBtn = (Button) dispenseCompleteOrderView.findViewById(R.id.cancel_treatment_group_btn);
        cancelTreatmentGroupBtn.setOnClickListener(this);
        // 结单按钮
        completeTreatmentGroupBtn = (Button) dispenseCompleteOrderView.findViewById(R.id.complete_treatment_group_btn);
        completeTreatmentGroupBtn.setOnClickListener(this);
        userinfoApplication = (UserInfoApplication) getActivity().getApplication();
        //是否具有查看顾客的权限
        int authMyOrderRead = userinfoApplication.getAccountInfo().getAuthMyOrderRead();
        int authMyOrderWrite = userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
        if (authMyOrderWrite == 0) {
            cancelTreatmentGroupBtn.setVisibility(View.GONE);
            completeTreatmentGroupBtn.setVisibility(View.GONE);
        }
        if (authMyOrderRead == 0) {
            cancelTreatmentGroupBtn.setVisibility(View.GONE);
            completeTreatmentGroupBtn.setVisibility(View.GONE);
        } else if (authMyOrderRead == 1) {
            // 如果选择顾客不为空时
            if (userinfoApplication.getSelectedCustomerID() != 0) {
                progressDialog = ProgressDialogUtil.createProgressDialog(getActivity());
                getCompleteOrderData();
            }

        }
        return dispenseCompleteOrderView;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onActivityCreated(savedInstanceState);
    }

    private static class DispenseCompleteOrderFragmentHandler extends Handler {
        private final DispenseCompleteOrderFragment dispenseCompleteOrderFragment;

        private DispenseCompleteOrderFragmentHandler(DispenseCompleteOrderFragment activity) {
            WeakReference<DispenseCompleteOrderFragment> weakReference = new WeakReference<DispenseCompleteOrderFragment>(activity);
            dispenseCompleteOrderFragment = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            FragmentActivity fragmentActivity = dispenseCompleteOrderFragment.getActivity();
            if (fragmentActivity == null) {
                return;
            }
            if (dispenseCompleteOrderFragment.progressDialog != null) {
                dispenseCompleteOrderFragment.progressDialog.dismiss();
                dispenseCompleteOrderFragment.progressDialog = null;
            }
            if (dispenseCompleteOrderFragment.requestWebServiceThread != null) {
                dispenseCompleteOrderFragment.requestWebServiceThread.interrupt();
                dispenseCompleteOrderFragment.requestWebServiceThread = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(fragmentActivity, (String) msg.obj);
                    break;
                case 1:
                    dispenseCompleteOrderFragment.setDispenseCompleteOrderList((List<OrderInfo>) msg.obj);
                    ((TextView) fragmentActivity.findViewById(R.id.tab_complete_order_title)).setText("待结" + "(" + dispenseCompleteOrderFragment.dispenseCompleteOrderList.size() + ")");
                    break;
                case 2:
                    DialogUtil.createShortDialog(fragmentActivity, "您的网络貌似不给力，请重试");
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(fragmentActivity, dispenseCompleteOrderFragment.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(fragmentActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + dispenseCompleteOrderFragment.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(fragmentActivity);
                    dispenseCompleteOrderFragment.packageUpdateUtil = new PackageUpdateUtil(fragmentActivity, dispenseCompleteOrderFragment.mHandler, fileCache, downloadFileUrl, false, dispenseCompleteOrderFragment.userinfoApplication);
                    dispenseCompleteOrderFragment.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    dispenseCompleteOrderFragment.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "cn.com.antika.business.apk";
                    File file = fragmentActivity.getFileStreamPath(filename);
                    file.getName();
                    dispenseCompleteOrderFragment.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                // 结单或者撤销成功
                case 6:
                    //撤销小单成功
                    if (msg.arg1 == 0)
                        DialogUtil.createShortDialog(fragmentActivity, "撤销成功！");
                        //完成小单成功
                    else if (msg.arg1 == 1)
                        DialogUtil.createShortDialog(fragmentActivity, "操作成功！");
                    //刷新下当前数据
                    dispenseCompleteOrderFragment.getCompleteOrderData();
                    break;
                case 99:
                    DialogUtil.createShortDialog(fragmentActivity, "服务器异常，请重试");
                    break;
                default:
                    break;
            }
        }
    }

    private void getCompleteOrderData() {
        clearData();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                // TODO Auto-generated method stub
                String methodName = "GetUnfinishTGList";
                String endPoint = "Order";
                JSONObject unFinishTGJsonParam = new JSONObject();
                try {
                    unFinishTGJsonParam.put("ProductType", -1);
                    unFinishTGJsonParam.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    unFinishTGJsonParam.put("IsToday", false);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, unFinishTGJsonParam.toString(), userinfoApplication);
                if (serverRequestResult == null
                        || serverRequestResult.equals(""))
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
                        List<OrderInfo> orderInfos = new ArrayList<OrderInfo>();
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
                                int isConfirmed = 0;
                                try {
                                    unfinishOrderJson = unFinishTGArray.getJSONObject(i);
                                    if (unfinishOrderJson.has("ProductName") && !unfinishOrderJson.isNull("ProductName"))
                                        productName = unfinishOrderJson.getString("ProductName");
                                    if (unfinishOrderJson.has("ProductType")
                                            && !unfinishOrderJson
                                            .isNull("ProductType"))
                                        productType = unfinishOrderJson
                                                .getInt("ProductType");
                                    if (unfinishOrderJson.has("TotalCount")
                                            && !unfinishOrderJson
                                            .isNull("TotalCount"))
                                        totalCount = unfinishOrderJson
                                                .getInt("TotalCount");
                                    if (unfinishOrderJson.has("FinishedCount")
                                            && !unfinishOrderJson
                                            .isNull("FinishedCount"))
                                        finishedCount = unfinishOrderJson
                                                .getInt("FinishedCount");
                                    if (unfinishOrderJson.has("PaymentStatus")
                                            && !unfinishOrderJson
                                            .isNull("PaymentStatus"))
                                        paymentStatus = unfinishOrderJson
                                                .getInt("PaymentStatus");
                                    if (unfinishOrderJson.has("GroupNo")
                                            && !unfinishOrderJson
                                            .isNull("GroupNo"))
                                        tgGroupNO = unfinishOrderJson
                                                .getString("GroupNo");
                                    if (unfinishOrderJson.has("TGStartTime")
                                            && !unfinishOrderJson
                                            .isNull("TGStartTime"))
                                        tgStartTime = unfinishOrderJson
                                                .getString("TGStartTime");
                                    if (unfinishOrderJson.has("AccountName")
                                            && !unfinishOrderJson
                                            .isNull("AccountName"))
                                        accountName = unfinishOrderJson
                                                .getString("AccountName");
                                    if (unfinishOrderJson.has("AccountID")
                                            && !unfinishOrderJson
                                            .isNull("AccountID"))
                                        accountID = unfinishOrderJson
                                                .getInt("AccountID");
                                    if (unfinishOrderJson.has("OrderID")
                                            && !unfinishOrderJson
                                            .isNull("OrderID"))
                                        orderID = unfinishOrderJson
                                                .getInt("OrderID");
                                    if (unfinishOrderJson.has("OrderObjectID")
                                            && !unfinishOrderJson
                                            .isNull("OrderObjectID"))
                                        orderObjectID = unfinishOrderJson
                                                .getInt("OrderObjectID");
                                    if (unfinishOrderJson.has("IsConfirmed") && !unfinishOrderJson.isNull("IsConfirmed"))
                                        isConfirmed = unfinishOrderJson.getInt("IsConfirmed");
                                } catch (JSONException e) {
                                    mHandler.sendEmptyMessage(99);
                                    return;
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
                                unfinishOrder.setIsConfirmed(isConfirmed);
                                orderInfos.add(unfinishOrder);
                            }
                        }
                        mHandler.obtainMessage(1, orderInfos).sendToTarget();
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

    // 将结单信息提交到服务器 撤销或者是结单
    private void operateTreatmentGroup(final List<OrderInfo> completeTreatmentGroupOrderList, final int operationType, final String signImage) {
        progressDialog = ProgressDialogUtil.createProgressDialog(getActivity());
        // operationType 0:撤销 1：结单
        final JSONArray tempArray = new JSONArray();
        try {
            for (OrderInfo unfinishOrder : completeTreatmentGroupOrderList) {
                JSONObject unfinishOrderJson = new JSONObject();
                unfinishOrderJson.put("OrderType", unfinishOrder.getProductType());
                unfinishOrderJson.put("OrderID", unfinishOrder.getOrderID());
                unfinishOrderJson.put("OrderObjectID", unfinishOrder.getOrderObejctID());
                unfinishOrderJson.put("GroupNo", unfinishOrder.getTgGroupNo());
                tempArray.put(unfinishOrderJson);
            }
        } catch (JSONException e) {
            mHandler.sendEmptyMessage(99);
            return;
        }
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "";
                if (operationType == 0)
                    methodName = "CancelTreatGroup";
                else if (operationType == 1)
                    methodName = "CompleteTreatGroup";
                String endPoint = "Order";

                JSONObject completeTreatGroupJson = new JSONObject();
                try {
                    if (operationType == 1 && signImage != null && !"".equals(signImage)) {
                        completeTreatGroupJson.put("SignImg", signImage);
                        completeTreatGroupJson.put("ImageFormat", ".JPEG");
                    }
                    completeTreatGroupJson.put("CustomerID", userinfoApplication.getSelectedCustomerID());
                    completeTreatGroupJson.put("TGDetailList", tempArray);
                } catch (JSONException e) {
                    mHandler.sendEmptyMessage(99);
                    return;
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
                        mHandler.sendEmptyMessage(99);
                        return;
                    }
                    if (code == 1) {
                        Message message = new Message();
                        message.what = 6;
                        message.arg1 = operationType;
                        message.obj = completeTreatmentGroupOrderList;
                        mHandler.sendMessage(message);
                    } else if (code == Constant.LOGIN_ERROR
                            || code == Constant.APP_VERSION_ERROR)
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
        // TODO Auto-generated method stub
        if (ProgressDialogUtil.isFastClick()) {
            return;
        }
        if (view.getId() == R.id.cancel_treatment_group_btn) {
            if (userinfoApplication.getSelectedCustomerID() == 0) {
                DialogUtil.createShortDialog(getActivity(), "请选择顾客！");
            } else if (dispenseCompleteOrderListAdapter != null) {
                final List<OrderInfo> completeTreatmentGroupOrderList = dispenseCompleteOrderListAdapter.getUnFinshOrderList();
                if (completeTreatmentGroupOrderList == null || completeTreatmentGroupOrderList.size() == 0) {
                    DialogUtil.createShortDialog(getActivity(), "请选择撤销的订单");
                } else {
                    Dialog dialog = new AlertDialog.Builder(getActivity(),
                            R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setMessage(R.string.delete_treatment)
                            .setPositiveButton(getString(R.string.delete_confirm),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                            operateTreatmentGroup(completeTreatmentGroupOrderList, 0, null);
                                        }
                                    })
                            .setNegativeButton(
                                    getString(R.string.delete_cancel),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                            dialog = null;
                                        }
                                    }).create();
                    dialog.show();
                    dialog.setCancelable(false);
                }
            }
        } else if (view.getId() == R.id.complete_treatment_group_btn) {
            if (userinfoApplication.getSelectedCustomerID() == 0) {
                DialogUtil.createShortDialog(getActivity(), "请选择顾客！");
            } else if (dispenseCompleteOrderListAdapter != null) {
                final List<OrderInfo> completeTreatmentGroupOrderList = dispenseCompleteOrderListAdapter.getUnFinshOrderList();
                if (completeTreatmentGroupOrderList == null || completeTreatmentGroupOrderList.size() == 0) {
                    DialogUtil.createShortDialog(getActivity(), "请选择需要结单的订单");
                } else {
                    Dialog dialog = new AlertDialog.Builder(getActivity(), R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setMessage(R.string.complete_treatment)
                            .setPositiveButton(getString(R.string.delete_confirm),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                            checkConfirmed(completeTreatmentGroupOrderList);
                                        }
                                    })
                            .setNegativeButton(
                                    getString(R.string.delete_cancel),
                                    new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(
                                                DialogInterface dialog,
                                                int which) {
                                            dialog.dismiss();
                                            dialog = null;
                                        }
                                    }).create();
                    dialog.show();
                    dialog.setCancelable(false);
                }
            }
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
            handWriteIntent.setClass(getActivity(), HandwritingActivity.class);
            startActivityForResult(handWriteIntent, 100);
        } else {
            operateTreatmentGroup(completeOrderInfoList, 1, null);
        }

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if (resultCode != -1) {
            return;
        }
        if (requestCode == 100) {
            String signPic = data.getStringExtra("signPic");
            operateTreatmentGroup(dispenseCompleteOrderListAdapter.getUnFinshOrderList(), 1, signPic);
        }
    }

    public void clearData() {
        if (dispenseCompleteOrderList != null)
            dispenseCompleteOrderList.clear();
        if (dispenseCompleteOrderListAdapter != null)
            dispenseCompleteOrderListAdapter.notifyDataSetChanged();
    }

    private void setDispenseCompleteOrderList(List<OrderInfo> orderList) {
        if (dispenseCompleteOrderList != null) {
            dispenseCompleteOrderList.clear();
            dispenseCompleteOrderList.addAll(orderList);
            dispenseCompleteOrderListAdapter.notifyDataSetChanged();
        }
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        // TODO Auto-generated method stub
        if (position != 0) {
            OrderInfo orderInfo = dispenseCompleteOrderList.get(position - 1);
            Bundle bundle = new Bundle();
            bundle.putSerializable("orderInfo", orderInfo);
            Intent destIntent = new Intent(getActivity(), OrderDetailActivity.class);
            destIntent.putExtra("FromOrderList", true);
            destIntent.putExtras(bundle);
            startActivity(destIntent);
        }
    }
}
