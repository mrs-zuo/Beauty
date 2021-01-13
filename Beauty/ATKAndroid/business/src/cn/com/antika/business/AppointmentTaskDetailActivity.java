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
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AppointmentDetailInfo;
import cn.com.antika.bean.DownloadInfo;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.ServerPackageVersion;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DateTimePickDialogUtil;
import cn.com.antika.util.DateUtil;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.FileCache;
import cn.com.antika.util.GenerateMenu;
import cn.com.antika.util.PackageUpdateUtil;
import cn.com.antika.view.BusinessLeftImageButton;
import cn.com.antika.view.BusinessRightImageButton;
import cn.com.antika.webservice.WebServiceUtil;

public class AppointmentTaskDetailActivity extends BaseActivity implements OnClickListener {
    private AppointmentTaskDetailActivityHandler handler = new AppointmentTaskDetailActivityHandler(this);
    private EditText appointmentTaskResult;
    private TextView appointmentTaskDetailCustomerText, appointmentTaskDetailOrderText, appointmentTaskDetailOrderDetailText, appointmentTaskTimeLimitText, appointmentRelatedOrderText, appointmentTaskTimeText;
    private ProgressDialog progressDialog;
    private PackageUpdateUtil packageUpdateUtil;
    private Thread requestWebServiceThread;
    long taskID;
    private UserInfoApplication userinfoApplication;
    private AppointmentDetailInfo appointmentDetailInfo;
    private Button appointmentTaskComplete, appointmentTaskSave;
    private RelativeLayout appointmentRelatedOrderRelativelayout, appointmentDetailCustomerRelativelayout;
    private ImageButton appointmentRelatedOrderIcon;
    ImageButton orderDetailSelectCustomerIcon;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentTaskDetailActivityHandler extends Handler {
        private final AppointmentTaskDetailActivity appointmentTaskDetailActivity;

        private AppointmentTaskDetailActivityHandler(AppointmentTaskDetailActivity activity) {
            WeakReference<AppointmentTaskDetailActivity> weakReference = new WeakReference<AppointmentTaskDetailActivity>(activity);
            appointmentTaskDetailActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentTaskDetailActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentTaskDetailActivity.progressDialog != null) {
                appointmentTaskDetailActivity.progressDialog.dismiss();
                appointmentTaskDetailActivity.progressDialog = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(appointmentTaskDetailActivity, (String) msg.obj);
                    break;
                case 1:
                    DialogUtil.createShortDialog(appointmentTaskDetailActivity, (String) msg.obj);
                    break;
                case 2:
                    DialogUtil.createShortDialog(appointmentTaskDetailActivity, (String) msg.obj);
                    Intent it = appointmentTaskDetailActivity.getIntent();
                    appointmentTaskDetailActivity.setResult(RESULT_OK, it);
                    appointmentTaskDetailActivity.finish();
                    break;
                case 3:
                    appointmentTaskDetailActivity.initView();
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentTaskDetailActivity, appointmentTaskDetailActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentTaskDetailActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentTaskDetailActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentTaskDetailActivity);
                    appointmentTaskDetailActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentTaskDetailActivity, appointmentTaskDetailActivity.handler, fileCache, downloadFileUrl, false, appointmentTaskDetailActivity.userinfoApplication);
                    appointmentTaskDetailActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentTaskDetailActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "cn.com.antika.business.apk";
                    File file = appointmentTaskDetailActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentTaskDetailActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    DialogUtil.createShortDialog(appointmentTaskDetailActivity, "您的网络貌似不给力，请重试");
                    break;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_task_detail);
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
        appointmentTaskDetailCustomerText = (TextView) findViewById(R.id.appointment_task_detail_customer_text);
        appointmentTaskTimeLimitText = (TextView) findViewById(R.id.appointment_task_time_limit_text);
        appointmentRelatedOrderText = (TextView) findViewById(R.id.appointment_related_order_text);
        appointmentTaskDetailOrderText = (TextView) findViewById(R.id.appointment_task_detail_order_text);
        appointmentTaskDetailOrderDetailText = (TextView) findViewById(R.id.appointment_task_detail_order_detail_text);
        appointmentTaskTimeText = (TextView) findViewById(R.id.appointment_task_time_text);
        appointmentTaskTimeText.setOnClickListener(this);
        appointmentTaskResult = (EditText) findViewById(R.id.appointment_task_result);
        if (appointmentDetailInfo.getOrderInfo() == null || appointmentDetailInfo.getOrderInfo().getOrderID() == 0) {
            findViewById(R.id.appointment_related_order_divide_view).setVisibility(View.GONE);
            findViewById(R.id.appointment_related_order_relativelayout).setVisibility(View.GONE);
        } else {
            appointmentRelatedOrderRelativelayout = (RelativeLayout) findViewById(R.id.appointment_related_order_relativelayout);
            appointmentRelatedOrderRelativelayout.setOnClickListener(this);
        }
        appointmentTaskSave = (Button) findViewById(R.id.appointment_task_save);
        appointmentTaskSave.setOnClickListener(this);
        appointmentTaskComplete = (Button) findViewById(R.id.appointment_task_complete);
        appointmentTaskComplete.setOnClickListener(this);
        appointmentRelatedOrderIcon = (ImageButton) findViewById(R.id.appointment_related_order_icon);
        appointmentDetailCustomerRelativelayout = (RelativeLayout) findViewById(R.id.appointment_detail_customer_relativelayout);
        appointmentDetailCustomerRelativelayout.setOnClickListener(this);
        orderDetailSelectCustomerIcon = (ImageButton) findViewById(R.id.order_detail_select_customer_icon);
        //填充数据
        if (appointmentDetailInfo != null) {
            if (appointmentDetailInfo.getTaskType() == 2)
                ((TextView) findViewById(R.id.appointment_task_detail_type_text)).setText("订单回访");
            else if (appointmentDetailInfo.getTaskType() == 4)
                ((TextView) findViewById(R.id.appointment_task_detail_type_text)).setText("生日回访");
            appointmentTaskTimeLimitText.setText(appointmentDetailInfo.getTaskScdlStartTime());
            appointmentTaskResult.setText(appointmentDetailInfo.getTaskResult());
            appointmentTaskDetailOrderText.setText(appointmentDetailInfo.getOrderInfo().getProductName());
            appointmentTaskDetailOrderDetailText.setText(appointmentDetailInfo.getTaskDescription());
            appointmentTaskTimeText.setText(dataTime());
            if (appointmentDetailInfo.getOrderInfo().getCustomerName() != null && !(("").equals(appointmentDetailInfo.getOrderInfo().getCustomerName()))) {
                appointmentTaskDetailCustomerText.setText(appointmentDetailInfo.getOrderInfo().getCustomerName());
                orderDetailSelectCustomerIcon.setVisibility(View.VISIBLE);
                appointmentDetailCustomerRelativelayout.setEnabled(true);
            } else {
                orderDetailSelectCustomerIcon.setVisibility(View.GONE);
                appointmentDetailCustomerRelativelayout.setEnabled(false);
            }
            if (appointmentDetailInfo.getOrderNumber() != null && !(("").equals(appointmentDetailInfo.getOrderNumber()))) {
                appointmentRelatedOrderText.setText(appointmentDetailInfo.getOrderNumber());
                appointmentRelatedOrderIcon.setVisibility(View.VISIBLE);
            } else {
                appointmentRelatedOrderIcon.setVisibility(View.GONE);
            }
            if (appointmentDetailInfo.getTaskStatus() == 3) {
                appointmentTaskTimeText.setEnabled(false);
                appointmentTaskTimeText.setTextColor(Color.BLACK);
                appointmentTaskResult.setEnabled(false);
                appointmentTaskResult.setTextColor(Color.BLACK);
                if (appointmentDetailInfo.getRemark() == null || ("").equals(appointmentDetailInfo.getRemark())) {
                    appointmentTaskResult.setHint("");
                }
                appointmentTaskSave.setVisibility(View.GONE);
                appointmentTaskComplete.setVisibility(View.GONE);
                appointmentTaskTimeText.setText(appointmentDetailInfo.getExecuteStartTime());
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
                                if (appointmentObject.has("ExecuteStartTime") && !appointmentObject.isNull("ExecuteStartTime")) {
                                    appointmentDetailInfo.setExecuteStartTime(appointmentObject.getString("ExecuteStartTime"));
                                }
                                if (appointmentObject.has("CreateTime") && !appointmentObject.isNull("CreateTime")) {
                                    appointmentDetailInfo.setCreateTime(appointmentObject.getString("CreateTime"));
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

    //修改回访
    private void editVisitTask(final int taskStatus) {
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "EditVisitTask";
                String endPoint = "Task";
                JSONObject appointmentParam = new JSONObject();
                try {
                    appointmentParam.put("ID", appointmentDetailInfo.getTaskID());
                    appointmentParam.put("ExecuteStartTime", appointmentTaskTimeText.getText().toString());
                    appointmentParam.put("TaskResult", appointmentTaskResult.getText().toString());
                    appointmentParam.put("TaskStatus", taskStatus);
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
                        message.what = 2;
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

    private String dataTime() {
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");//设置日期格式
        String dataTime = df.format(new Date());
        return dataTime;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.appointment_detail_customer_relativelayout:
                userinfoApplication.setSelectedCustomerID(appointmentDetailInfo.getOrderInfo().getCustomerID());
                Intent customerServicingIntent = new Intent(this, CustomerServicingActivity.class);
                startActivity(customerServicingIntent);
                break;
            case R.id.appointment_task_time_text:
                DateTimePickDialogUtil dateTimePicKDialog = new DateTimePickDialogUtil(AppointmentTaskDetailActivity.this, dataTime());
                dateTimePicKDialog.dateTimePicKDialog(appointmentTaskTimeText);
                break;
            //暂存回访
            case R.id.appointment_task_save:
                if (DateUtil.compareDateForAppointment(appointmentTaskTimeText.getText().toString())) {
                    DialogUtil.createShortDialog(AppointmentTaskDetailActivity.this, "回访时间不能大于当前时间！");
                } else if (!DateUtil.compareDateForAppointment(appointmentTaskTimeText.getText().toString(), appointmentDetailInfo.getCreateTime())) {
                    DialogUtil.createShortDialog(AppointmentTaskDetailActivity.this, "回访时间不能小于创建时间！");
                } else {
                    Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setMessage("确认暂存回访？")
                            .setPositiveButton(getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    editVisitTask(0);
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
                }
                break;
            //完成回访
            case R.id.appointment_task_complete:
                if (DateUtil.compareDateForAppointment(appointmentTaskTimeText.getText().toString())) {
                    DialogUtil.createShortDialog(AppointmentTaskDetailActivity.this, "回访时间不能大于当前时间！");
                } else if (!DateUtil.compareDateForAppointment(appointmentTaskTimeText.getText().toString(), appointmentDetailInfo.getCreateTime())) {
                    DialogUtil.createShortDialog(AppointmentTaskDetailActivity.this, "回访时间不能小于创建时间！");
                } else {
                    Dialog dialog = new AlertDialog.Builder(this, R.style.CustomerAlertDialog)
                            .setTitle(getString(R.string.delete_dialog_title))
                            .setMessage("确认完成回访？")
                            .setPositiveButton(getString(R.string.delete_confirm), new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    editVisitTask(3);
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
                }
                break;
            case R.id.appointment_related_order_relativelayout:
                Intent intent = new Intent(AppointmentTaskDetailActivity.this, OrderDetailActivity.class);
                Bundle bun = new Bundle();
                bun.putSerializable("orderInfo", appointmentDetailInfo.getOrderInfo());
                intent.putExtras(bun);
                intent.putExtra("FromOrderList", true);
                startActivity(intent);
                AppointmentTaskDetailActivity.this.finish();
                break;
            default:
                break;
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
