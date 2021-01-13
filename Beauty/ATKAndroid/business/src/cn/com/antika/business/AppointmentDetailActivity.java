package cn.com.antika.business;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AppointmentDetailInfo;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class AppointmentDetailActivity extends BaseActivity implements OnClickListener {
    private AppointmentDetailActivityHandler handler = new AppointmentDetailActivityHandler(this);
    private TextView apponitmentDetailNum, appointmentDetailCustomerText, appointmentDetailBranchText, appointmentDetailDateText, appointmentDetailServiceText, designatedResponsiblePersonText;
    private String item[] = new String[]{"待确认", "已确认", "已执行", "已取消"};
    private TextView appointmentDetailAppointmentStatusText, appointmentDetailOrderPriceCurrencyText, appointmentDetailOrderNumText, appointmentDetailOrderProductNameText, appointmentDetailOrderPriceText;
    private TextView isdesignatAppointmentResponsiblePersonSpinner;
    private EditText appointmentRemark;
    private ProgressDialog progressDialog;
    private PackageUpdateUtil packageUpdateUtil;
    private Thread requestWebServiceThread;
    long taskID;
    private UserInfoApplication userinfoApplication;
    private AppointmentDetailInfo appointmentDetailInfo;
    private RelativeLayout designatedResponsiblePersonRelativelayout, appointmentDetailCustomerRelativelayout, appointmentDetailOrderRelativelayout;
    TableLayout orderTablelayout;
    ImageButton orderDetailSelectCustomerIcon, appointmentDetailOrderIcon;
    private String isdesignatItem[] = new String[]{"到店指定", "指定"};
    private int executorID;
    private String executorNames;
    private Button appointmentDetailCancel, appointmentDetailConfirm, appointmentDetailOrderMakeSure;
    LayoutInflater layoutInflater;
    /**
     * 预约
     */
    private static final int APPOINTMENT = 1;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentDetailActivityHandler extends Handler {
        private final AppointmentDetailActivity appointmentDetailActivity;

        private AppointmentDetailActivityHandler(AppointmentDetailActivity activity) {
            WeakReference<AppointmentDetailActivity> weakReference = new WeakReference<AppointmentDetailActivity>(activity);
            appointmentDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentDetailActivity.progressDialog != null) {
                appointmentDetailActivity.progressDialog.dismiss();
                appointmentDetailActivity.progressDialog = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(appointmentDetailActivity, (String) msg.obj);
                    break;
                case 1:
                    DialogUtil.createShortDialog(appointmentDetailActivity, (String) msg.obj);
                    appointmentDetailActivity.appointmentDetailInfo.setTaskStatus(4);
                    appointmentDetailActivity.appointmentDetailAppointmentStatusText.setText(appointmentDetailActivity.getTaskStatus(appointmentDetailActivity.appointmentDetailInfo.getTaskStatus()));
                    appointmentDetailActivity.appointmentDetailConfirm.setVisibility(View.GONE);
                    appointmentDetailActivity.appointmentDetailCancel.setVisibility(View.GONE);
                    appointmentDetailActivity.appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                    appointmentDetailActivity.appointmentRemark.setEnabled(false);
                    appointmentDetailActivity.appointmentDetailDateText.setTextColor(Color.BLACK);
                    appointmentDetailActivity.designatedResponsiblePersonText.setTextColor(Color.BLACK);
                    appointmentDetailActivity.appointmentRemark.setTextColor(Color.BLACK);
                    appointmentDetailActivity.designatedResponsiblePersonText.setEnabled(false);
                    appointmentDetailActivity.isdesignatAppointmentResponsiblePersonSpinner.setEnabled(false);
                    break;
                case 6:
                    appointmentDetailActivity.appointmentDetailInfo.setTaskStatus(2);
                    appointmentDetailActivity.appointmentDetailAppointmentStatusText.setText(appointmentDetailActivity.getTaskStatus(appointmentDetailActivity.appointmentDetailInfo.getTaskStatus()));
                    appointmentDetailActivity.appointmentDetailInfo.setTaskScdlStartTime(appointmentDetailActivity.appointmentDetailDateText.getText().toString());
                    appointmentDetailActivity.appointmentDetailInfo.getOrderInfo().setResponsiblePersonID(appointmentDetailActivity.executorID);
                    appointmentDetailActivity.appointmentDetailInfo.getOrderInfo().setResponsiblePersonName(appointmentDetailActivity.executorNames);
                    ;
                    appointmentDetailActivity.appointmentDetailConfirm.setVisibility(View.GONE);
                    appointmentDetailActivity.appointmentDetailCancel.setVisibility(View.VISIBLE);
                    appointmentDetailActivity.appointmentDetailOrderMakeSure.setVisibility(View.VISIBLE);
                    appointmentDetailActivity.appointmentRemark.setEnabled(false);
                    appointmentDetailActivity.appointmentRemark.setTextColor(Color.BLACK);
                    appointmentDetailActivity.appointmentDetailDateText.setTextColor(Color.BLACK);
                    appointmentDetailActivity.isdesignatAppointmentResponsiblePersonSpinner.setEnabled(false);
                    appointmentDetailActivity.designatedResponsiblePersonText.setEnabled(false);
                    appointmentDetailActivity.designatedResponsiblePersonText.setTextColor(Color.BLACK);
                    DialogUtil.createShortDialog(appointmentDetailActivity, (String) msg.obj);
                    break;
                case 3:
                    appointmentDetailActivity.initView();
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentDetailActivity, appointmentDetailActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentDetailActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentDetailActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentDetailActivity);
                    appointmentDetailActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentDetailActivity, appointmentDetailActivity.handler, fileCache, downloadFileUrl, false, appointmentDetailActivity.userinfoApplication);
                    appointmentDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "cn.com.antika.business.apk";
                    File file = appointmentDetailActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentDetailActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    DialogUtil.createShortDialog(appointmentDetailActivity, "您的网络貌似不给力，请重试");
                    break;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_detail);
        BusinessLeftImageButton bussinessLeftMenuBtn = (BusinessLeftImageButton) findViewById(R.id.btn_main_left_business_menu);
        GenerateMenu.generateLeftMenu(this, bussinessLeftMenuBtn);
        BusinessRightImageButton bussinessRightMenuBtn = (BusinessRightImageButton) findViewById(R.id.btn_main_right_menu);
        GenerateMenu.generateRightMenu(this, bussinessRightMenuBtn);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent it = getIntent();
        taskID = it.getLongExtra("taskID", 0);
        getappointmentDetailInfoData();

    }

    private void initView() {
        apponitmentDetailNum = (TextView) findViewById(R.id.apponitment_detail_num);
        appointmentDetailCustomerText = (TextView) findViewById(R.id.appointment_detail_customer_text);
        appointmentDetailCustomerText.setOnClickListener(this);
        appointmentDetailBranchText = (TextView) findViewById(R.id.appointment_detail_branch_text);
        appointmentDetailDateText = (TextView) findViewById(R.id.appointment_detail_date_text);
        appointmentDetailDateText.setOnClickListener(this);
        appointmentDetailServiceText = (TextView) findViewById(R.id.appointment_detail_service_text);
        appointmentRemark = (EditText) findViewById(R.id.appointment_remark);
        appointmentDetailCancel = (Button) findViewById(R.id.appointment_detail_cancel);
        appointmentDetailCancel.setOnClickListener(this);
        appointmentDetailConfirm = (Button) findViewById(R.id.appointment_detail_confirm);
        appointmentDetailConfirm.setOnClickListener(this);
        int authMyOrderWrite = userinfoApplication.getAccountInfo().getAuthMyOrderWrite();
        int authAllOrderWrite = userinfoApplication.getAccountInfo().getAuthAllOrderWrite();

        appointmentDetailOrderMakeSure = (Button) findViewById(R.id.appointment_detail_order_make_sure);
        appointmentDetailOrderMakeSure.setOnClickListener(this);
        appointmentDetailAppointmentStatusText = (TextView) findViewById(R.id.appointment_detail_status_text);
        appointmentDetailOrderNumText = (TextView) findViewById(R.id.appointment_detail_order_num_text);
        appointmentDetailOrderProductNameText = (TextView) findViewById(R.id.appointment_detail_order_product_name_text);
        appointmentDetailOrderPriceText = (TextView) findViewById(R.id.appointment_detail_order_price_text);
        appointmentDetailOrderPriceCurrencyText = (TextView) findViewById(R.id.appointment_detail_order_price_currency_text);
        isdesignatAppointmentResponsiblePersonSpinner = (TextView) findViewById(R.id.isdesignat_appointment_responsible_person_text);
        designatedResponsiblePersonText = (TextView) findViewById(R.id.designated_responsible_person_text);
        designatedResponsiblePersonRelativelayout = (RelativeLayout) findViewById(R.id.designated_responsible_person_relativelayout);
        appointmentDetailCustomerRelativelayout = (RelativeLayout) findViewById(R.id.appointment_detail_customer_relativelayout);
        appointmentDetailCustomerRelativelayout.setOnClickListener(this);
        orderTablelayout = (TableLayout) findViewById(R.id.order_tablelayout);
        orderDetailSelectCustomerIcon = (ImageButton) findViewById(R.id.order_detail_select_customer_icon);
        appointmentDetailOrderIcon = (ImageButton) findViewById(R.id.appointment_detail_order_icon);
        appointmentDetailOrderRelativelayout = (RelativeLayout) findViewById(R.id.appointment_detail_order_relativelayout);
        appointmentDetailOrderRelativelayout.setOnClickListener(this);
        TableLayout appointmentRemarkTableLayout = (TableLayout) findViewById(R.id.appointment_remark_tablelayout);
        //填充数据
        if (appointmentDetailInfo != null) {
            if (appointmentDetailInfo.getOrderInfo().getOrderObejctID() > 0)
                orderTablelayout.setVisibility(View.VISIBLE);
            else
                orderTablelayout.setVisibility(View.GONE);
            if (appointmentDetailInfo.getOrderNumber() != null && !(("").equals(appointmentDetailInfo.getOrderNumber()))) {
                appointmentDetailOrderNumText.setText(appointmentDetailInfo.getOrderNumber());
                appointmentDetailOrderIcon.setVisibility(View.VISIBLE);
            } else
                appointmentDetailOrderIcon.setVisibility(View.GONE);
            appointmentDetailOrderProductNameText.setText(appointmentDetailInfo.getOrderInfo().getProductName());
            appointmentDetailOrderPriceText.setText(appointmentDetailInfo.getOrderInfo().getTotalSalePrice());
            appointmentDetailOrderPriceCurrencyText.setText(userinfoApplication.getAccountInfo().getCurrency());
            appointmentDetailAppointmentStatusText.setText(getTaskStatus(appointmentDetailInfo.getTaskStatus()));
            apponitmentDetailNum.setText(String.valueOf(appointmentDetailInfo.getTaskID()));
            if (appointmentDetailInfo.getOrderInfo().getCustomerName() != null && !appointmentDetailInfo.getOrderInfo().getCustomerName().equals("")) {
                appointmentDetailCustomerText.setText(appointmentDetailInfo.getOrderInfo().getCustomerName());
                orderDetailSelectCustomerIcon.setVisibility(View.VISIBLE);
                appointmentDetailCustomerRelativelayout.setEnabled(true);
            } else {
                orderDetailSelectCustomerIcon.setVisibility(View.GONE);
                appointmentDetailCustomerRelativelayout.setEnabled(false);
            }
            appointmentDetailBranchText.setText(appointmentDetailInfo.getOrderInfo().getBranchName());
            appointmentDetailDateText.setText(appointmentDetailInfo.getTaskScdlStartTime());
            appointmentDetailServiceText.setText(appointmentDetailInfo.getOrderInfo().getProductName());
            designatedResponsiblePersonText.setText(appointmentDetailInfo.getOrderInfo().getResponsiblePersonName());
            appointmentRemark.setText(appointmentDetailInfo.getRemark());

            //预约状态控制权限
            if (appointmentDetailInfo.getTaskStatus() == 1) {
                appointmentDetailDateText.setEnabled(true);
                appointmentDetailDateText.setTextColor(Color.GRAY);
                appointmentDetailConfirm.setVisibility(View.VISIBLE);
                appointmentDetailCancel.setVisibility(View.VISIBLE);
                appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                appointmentRemark.setEnabled(true);
            }
            if (appointmentDetailInfo.getTaskStatus() == 2) {
                appointmentDetailConfirm.setVisibility(View.GONE);
                appointmentDetailDateText.setEnabled(true);
                appointmentDetailDateText.setTextColor(Color.BLACK);
                appointmentDetailCancel.setVisibility(View.VISIBLE);
                appointmentDetailOrderMakeSure.setVisibility(View.VISIBLE);
                appointmentRemarkTableLayout.setVisibility(View.GONE);
                //appointmentRemark.setEnabled(false);
                //appointmentRemark.setTextColor(Color.BLACK);
            }
            if (appointmentDetailInfo.getTaskStatus() == 3) {
                appointmentDetailConfirm.setVisibility(View.GONE);
                appointmentDetailDateText.setEnabled(false);
                appointmentDetailDateText.setTextColor(Color.BLACK);
                appointmentDetailCancel.setVisibility(View.GONE);
                appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                appointmentRemarkTableLayout.setVisibility(View.GONE);
                //appointmentRemark.setEnabled(false);
                //appointmentRemark.setTextColor(Color.BLACK);
            }
            if (appointmentDetailInfo.getTaskStatus() == 4) {
                appointmentDetailConfirm.setVisibility(View.GONE);
                appointmentDetailDateText.setEnabled(false);
                appointmentDetailDateText.setTextColor(Color.BLACK);
                appointmentDetailCancel.setVisibility(View.GONE);
                appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                appointmentRemarkTableLayout.setVisibility(View.GONE);
                //appointmentRemark.setEnabled(false);
                //appointmentRemark.setTextColor(Color.BLACK);
            }
            if (appointmentDetailInfo.getOrderInfo().getResponsiblePersonID() > 0) {
                isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.treatment_designat));
                designatedResponsiblePersonRelativelayout.setVisibility(View.VISIBLE);
            } else {
                isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.appointment_to_the_branch_designat_text));
                designatedResponsiblePersonRelativelayout.setVisibility(View.GONE);
            }
            //如果没有编辑所有订单的权限 并且当前账号不是本预约的指定顾问  则不能编辑该预约
            if (authAllOrderWrite == 0) {
                if (authMyOrderWrite == 1) {
                    if (appointmentDetailInfo.getOrderInfo().getResponsiblePersonID() != userinfoApplication.getAccountInfo().getAccountId()) {
                        appointmentDetailCancel.setVisibility(View.GONE);
                        appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                        appointmentDetailConfirm.setVisibility(View.GONE);
                    }
                } else {
                    appointmentDetailCancel.setVisibility(View.GONE);
                    appointmentDetailOrderMakeSure.setVisibility(View.GONE);
                    appointmentDetailConfirm.setVisibility(View.GONE);
                }
            }
        }

    }

    private void getappointmentDetailInfoData() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "GetScheduleDetail";
                String endPoint = "Task";
                JSONObject appointmentParam = new JSONObject();
                try {
                    appointmentParam.put("LongID", taskID);
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, appointmentParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    handler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    String msg = "";
                    JSONObject appointmentObject = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        msg = resultJson.getString("Message");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        Message message = new Message();
                        try {
                            appointmentObject = resultJson.getJSONObject("Data");
                        } catch (JSONException e) {
                        }
                        if (appointmentObject != null) {
                            appointmentDetailInfo = new AppointmentDetailInfo();
                            OrderInfo orderInfo = new OrderInfo();
                            try {
                                if (appointmentObject.has("TaskID") && !appointmentObject.isNull("TaskID")) {
                                    appointmentDetailInfo.setTaskID(appointmentObject.getLong("TaskID"));
                                }
                                if (appointmentObject.has("TaskOwnerID") && !appointmentObject.isNull("TaskOwnerID")) {
                                    orderInfo.setCustomerID(appointmentObject.getInt("TaskOwnerID"));
                                }
                                if (appointmentObject.has("TaskOwnerName") && !appointmentObject.isNull("TaskOwnerName")) {
                                    orderInfo.setCustomerName(appointmentObject.getString("TaskOwnerName"));
                                }
                                if (appointmentObject.has("BranchName") && !appointmentObject.isNull("BranchName")) {
                                    orderInfo.setBranchName(appointmentObject.getString("BranchName"));
                                }
                                if (appointmentObject.has("TaskScdlStartTime") && !appointmentObject.isNull("TaskScdlStartTime")) {
                                    appointmentDetailInfo.setTaskScdlStartTime(appointmentObject.getString("TaskScdlStartTime"));
                                }
                                if (appointmentObject.has("ProductCode") && !appointmentObject.isNull("ProductCode")) {
                                    appointmentDetailInfo.setProductCode(appointmentObject.getLong("ProductCode"));
                                }
                                if (appointmentObject.has("ProductName") && !appointmentObject.isNull("ProductName")) {
                                    orderInfo.setProductName(appointmentObject.getString("ProductName"));
                                }
                                if (appointmentObject.has("AccountID") && !appointmentObject.isNull("AccountID")) {
                                    orderInfo.setResponsiblePersonID(appointmentObject.getInt("AccountID"));
                                }
                                if (appointmentObject.has("AccountName") && !appointmentObject.isNull("AccountName")) {
                                    orderInfo.setResponsiblePersonName(appointmentObject.getString("AccountName"));
                                }
                                if (appointmentObject.has("Remark") && !appointmentObject.isNull("Remark")) {
                                    appointmentDetailInfo.setRemark(appointmentObject.getString("Remark"));
                                }
                                if (appointmentObject.has("TaskType") && !appointmentObject.isNull("TaskType")) {
                                    appointmentDetailInfo.setTaskType(appointmentObject.getInt("TaskType"));
                                }
                                if (appointmentObject.has("OrderID") && !appointmentObject.isNull("OrderID")) {
                                    orderInfo.setOrderID(appointmentObject.getInt("OrderID"));
                                }
                                if (appointmentObject.has("OrderObjectID") && !appointmentObject.isNull("OrderObjectID")) {
                                    orderInfo.setOrderObejctID(appointmentObject.getInt("OrderObjectID"));
                                }
                                if (appointmentObject.has("OrderNumber") && !appointmentObject.isNull("OrderNumber")) {
                                    appointmentDetailInfo.setOrderNumber(appointmentObject.getString("OrderNumber"));
                                }
                                if (appointmentObject.has("TotalSalePrice") && !appointmentObject.isNull("TotalSalePrice")) {
                                    orderInfo.setTotalSalePrice(appointmentObject.getString("TotalSalePrice"));
                                }
                                if (appointmentObject.has("TaskDescription") && !appointmentObject.isNull("TaskDescription")) {
                                    appointmentDetailInfo.setTaskDescription(appointmentObject.getString("TaskDescription"));
                                }
                                if (appointmentObject.has("TaskResult") && !appointmentObject.isNull("TaskResult")) {
                                    appointmentDetailInfo.setTaskResult(appointmentObject.getString("TaskResult"));
                                }
                                if (appointmentObject.has("OrderCreateTime") && !appointmentObject.isNull("OrderCreateTime")) {
                                    orderInfo.setOrderTime(appointmentObject.getString("OrderCreateTime"));
                                }
                                if (appointmentObject.has("TaskStatus") && !appointmentObject.isNull("TaskStatus")) {
                                    appointmentDetailInfo.setTaskStatus(appointmentObject.getInt("TaskStatus"));
                                }
                            } catch (JSONException e) {

                            }
                            appointmentDetailInfo.setOrderInfo(orderInfo);
                        }
                        message.what = 3;
                        message.obj = msg;
                        handler.sendMessage(message);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        handler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 0;
                        message.obj = msg;
                        handler.sendMessage(message);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    //  取消
    private void cancelSchedule() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "CancelSchedule";
                String endPoint = "Task";
                JSONObject appointmentParam = new JSONObject();
                try {
                    appointmentParam.put("LongID", appointmentDetailInfo.getTaskID());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, appointmentParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    handler.sendEmptyMessage(2);
                else {
                    JSONObject resultJson = null;
                    int code = 0;
                    String msg = "";
                    JSONObject appointmentObject = null;
                    try {
                        resultJson = new JSONObject(serverRequestResult);
                        code = resultJson.getInt("Code");
                        msg = resultJson.getString("Message");
                    } catch (JSONException e) {
                    }
                    if (code == 1) {
                        Message message = new Message();
                        message.what = 1;
                        message.obj = msg;
                        handler.sendMessage(message);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        handler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 0;
                        message.obj = msg;
                        handler.sendMessage(message);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    //	确认
    private void confirmSchedule() {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "ConfirmSchedule";
                String endPoint = "Task";
                JSONObject appointmentParam = new JSONObject();
                try {
                    appointmentParam.put("ID", appointmentDetailInfo.getTaskID());
                    if (isdesignatAppointmentResponsiblePersonSpinner.getText().toString().equals(getString(R.string.treatment_designat))) {
                        appointmentParam.put("ExecutorID", appointmentDetailInfo.getOrderInfo().getResponsiblePersonID());
                    }
                    appointmentParam.put("TaskScdlStartTime", appointmentDetailDateText.getText().toString());
                    appointmentParam.put("Remark", appointmentRemark.getText().toString());
                    appointmentParam.put("TaskOwnerID", appointmentDetailInfo.getOrderInfo().getCustomerID());
                } catch (JSONException e) {
                }
                String serverRequestResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, appointmentParam.toString(), userinfoApplication);
                if (serverRequestResult == null || serverRequestResult.equals(""))
                    handler.sendEmptyMessage(2);
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
                        message.obj = msg;
                        handler.sendMessage(message);
                    } else if (code == Constant.LOGIN_ERROR || code == Constant.APP_VERSION_ERROR)
                        handler.sendEmptyMessage(code);
                    else {
                        Message message = new Message();
                        message.what = 0;
                        message.obj = msg;
                        handler.sendMessage(message);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    public String getTaskStatus(int taskStatus) {
        String taskStatusString = "未知状态";
        switch (taskStatus) {
            case 1:
                taskStatusString = "待确认";
                break;
            case 2:
                taskStatusString = "已确认";
                break;
            case 3:
                taskStatusString = "已执行";
                break;
            case 4:
                taskStatusString = "已取消";
                break;
        }
        return taskStatusString;
    }

    @Override
    public void onClick(View v) {
        Intent intent;
        Dialog dialog;
        switch (v.getId()) {
            case R.id.appointment_detail_order_relativelayout:
                intent = new Intent(AppointmentDetailActivity.this, OrderDetailActivity.class);
                Bundle bun = new Bundle();
                bun.putSerializable("orderInfo", appointmentDetailInfo.getOrderInfo());
                intent.putExtra("FromOrderList", true);
                intent.putExtras(bun);
                startActivity(intent);
                break;
            case R.id.appointment_detail_date_text:
                intent = new Intent(AppointmentDetailActivity.this, ChooseServicePeopleActivity.class);
                intent.putExtra("ExecutorID", executorID);
                intent.putExtra("ExecutorName", executorNames);
                intent.putExtra("FROM_SOURCE", APPOINTMENT);
                startActivityForResult(intent, 11);
                break;
            case R.id.appointment_detail_customer_relativelayout:
                userinfoApplication.setSelectedCustomerID(appointmentDetailInfo.getOrderInfo().getCustomerID());
                Intent customerServicingIntent = new Intent(this, CustomerServicingActivity.class);
                startActivity(customerServicingIntent);
                break;
            case R.id.appointment_detail_cancel:
                dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                        .setTitle(getString(R.string.delete_dialog_title))
                        .setMessage("确认取消该预约？")
                        .setPositiveButton(getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                cancelSchedule();
                            }
                        })
                        .setNegativeButton(getString(R.string.delete_cancel), new DialogInterface.OnClickListener() {
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
                break;
            case R.id.appointment_detail_confirm:
                dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                        .setTitle(getString(R.string.delete_dialog_title))
                        .setMessage("确认预约？")
                        .setPositiveButton(getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                confirmSchedule();
                            }
                        })
                        .setNegativeButton(getString(R.string.delete_cancel), new DialogInterface.OnClickListener() {
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

                break;
            case R.id.appointment_detail_order_make_sure:
                if (appointmentDetailInfo.getOrderInfo().getOrderObejctID() > 0) {//存单
                    Intent destIntent = new Intent(AppointmentDetailActivity.this, ProductAndOldOrderListActivity.class);
                    Bundle bundle = new Bundle();
                    ArrayList<String> orderIDsList = new ArrayList<String>();
                    orderIDsList.add(String.valueOf(appointmentDetailInfo.getOrderInfo().getOrderID()));
                    bundle.putStringArrayList("orderIdList", orderIDsList);
                    bundle.putLong("TaskID", appointmentDetailInfo.getTaskID());
                    bundle.putSerializable("appointmentDetailInfo", appointmentDetailInfo);
                    destIntent.putExtras(bundle);
                    startActivity(destIntent);
                } else {//新单
                    intent = new Intent(this, PrepareOrderActivity.class);
                    intent.putExtra("FROM_SOURCE", "Appointment");
                    Bundle bu = new Bundle();
                    bu.putInt("ProductType", 0);
                    bu.putLong("TaskID", appointmentDetailInfo.getTaskID());
                    bu.putSerializable("appointmentDetailInfo", appointmentDetailInfo);
                    intent.putExtras(bu);
                    startActivity(intent);
                }
                break;
            default:
                break;
        }

    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Intent it = getIntent();
            setResult(RESULT_OK, it);
            this.finish();
        }
        return super.onKeyUp(keyCode, event);
    }

    private void setBenefitPersonInfo(int id, String name) {
        executorID = id;
        executorNames = name;
        appointmentDetailInfo.getOrderInfo().setResponsiblePersonID(executorID);
        appointmentDetailInfo.getOrderInfo().setResponsiblePersonName(executorNames);
        designatedResponsiblePersonText.setText(executorNames);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 10) {
                setBenefitPersonInfo(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
            }
            if (requestCode == 11) {
                if (data.getIntExtra("ExecutorID", 0) != 0) {
                    isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.treatment_designat));
                    designatedResponsiblePersonRelativelayout.setVisibility(View.VISIBLE);
                    setBenefitPersonInfo(data.getIntExtra("ExecutorID", 0), data.getStringExtra("ExecutorName"));
                } else {
                    isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.appointment_to_the_branch_designat_text));
                    designatedResponsiblePersonRelativelayout.setVisibility(View.GONE);
                    designatedResponsiblePersonText.setText("");
                    executorID = 0;
                    executorNames = "";
                }
                appointmentDetailDateText.setText(data.getStringExtra("TaskScdlStartTime"));
            }
        }
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
        if (handler != null) {
            handler.removeCallbacksAndMessages(null);
            // handler = null;
        }
    }


}
