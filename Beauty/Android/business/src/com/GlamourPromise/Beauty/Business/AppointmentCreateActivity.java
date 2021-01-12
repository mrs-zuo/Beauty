package com.GlamourPromise.Beauty.Business;

import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentConditionInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.ProgressDialogUtil;
import com.GlamourPromise.Beauty.webservice.WebServiceUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Date;

public class AppointmentCreateActivity extends BaseActivity implements OnClickListener {
    private AppointmentCreateActivityHandler handler = new AppointmentCreateActivityHandler(this);
    ImageButton appointmentCreateBackBtn;
    private ProgressDialog progressDialog;
    private Thread requestWebServiceThread;
    private UserInfoApplication userinfoApplication;
    private PackageUpdateUtil packageUpdateUtil;
    private int fromSource = 0;
    /**
     * 顾客服务页
     */
    private static final int CUSTOMER_SERVICE = 1;
    /**
     * 订单详细页
     */
    private static final int ORDER_DETAIL = 2;
    /**
     * 预约
     */
    private static final int APPOINTMENT = 0;
    private static final int APPOINTMENT_TO_SERVICE = 3;
    private TextView appointmentCreateCustomerText, appointmentCreateAppointmentDateText, appointmentServiceText, designatedResponsiblePersonText;
    private TextView isdesignatAppointmentResponsiblePersonSpinner;
    private int executorID;
    private String executorNames;
    private String customerName;
    private int customerID = 0;
    private String serviceName;
    private long serviceCode;
    private int serviceID, objectID;
    private EditText appointmentRemark;
    private Button orderSearchNewMakeSureBtn, appointmentCreateReset;
    RelativeLayout designatedResponsiblePersonRelativelayout;
    boolean isOldOrder = false;
    private AppointmentConditionInfo appointmentConditionInfo;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentCreateActivityHandler extends Handler {
        private final AppointmentCreateActivity appointmentCreateActivity;

        private AppointmentCreateActivityHandler(AppointmentCreateActivity activity) {
            WeakReference<AppointmentCreateActivity> weakReference = new WeakReference<AppointmentCreateActivity>(activity);
            appointmentCreateActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentCreateActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentCreateActivity.progressDialog != null) {
                appointmentCreateActivity.progressDialog.dismiss();
                appointmentCreateActivity.progressDialog = null;
            }
            if (appointmentCreateActivity.requestWebServiceThread != null) {
                appointmentCreateActivity.requestWebServiceThread.interrupt();
                appointmentCreateActivity.requestWebServiceThread = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(appointmentCreateActivity, (String) msg.obj);
                    break;
                case 2:
                    Intent intent;
                    if (appointmentCreateActivity.isOldOrder) {
                        intent = new Intent(appointmentCreateActivity, AppointmentCusOldOrderActivity.class);
                        Bundle bu = new Bundle();
                        bu.putInt("customerID", appointmentCreateActivity.customerID);
                        bu.putString("customerName", appointmentCreateActivity.customerName);
                        intent.putExtras(bu);
                        appointmentCreateActivity.startActivityForResult(intent, 12);
                    } else {
                        intent = new Intent(appointmentCreateActivity, ServiceListActivity.class);
                        intent.putExtra("CategoryID", String.valueOf(0));
                        intent.putExtra("FROM_SOURCE", APPOINTMENT_TO_SERVICE);
                        appointmentCreateActivity.startActivityForResult(intent, 10);
                    }
                    break;
                case 1:
                    DialogUtil.createShortDialog(appointmentCreateActivity, (String) msg.obj);
                    if (appointmentCreateActivity.fromSource == ORDER_DETAIL) {
                        appointmentCreateActivity.appointmentConditionInfo = new AppointmentConditionInfo();
                        appointmentCreateActivity.appointmentConditionInfo.setBranchID(appointmentCreateActivity.userinfoApplication.getAccountInfo().getBranchId());
                        appointmentCreateActivity.appointmentConditionInfo.setPageSize(10);
                        int status[] = new int[]{1, 2};
                        appointmentCreateActivity.appointmentConditionInfo.setStatus(status);
                        appointmentCreateActivity.appointmentConditionInfo.setTaskType(1);
                    }
                    //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
                    int authAllOrderRead = appointmentCreateActivity.userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
                    if (authAllOrderRead == 1)
                        appointmentCreateActivity.appointmentConditionInfo.setResponsiblePersonIDs("[]");
                    else
                        appointmentCreateActivity.appointmentConditionInfo.setResponsiblePersonIDs("[" + appointmentCreateActivity.userinfoApplication.getAccountInfo().getAccountId() + "]");
                    appointmentCreateActivity.appointmentConditionInfo.setCustomerID(appointmentCreateActivity.customerID);
                    Intent data = new Intent();
                    data.putExtra("appointmentConditionInfo", appointmentCreateActivity.appointmentConditionInfo);
                    appointmentCreateActivity.setResult(RESULT_OK, data);
                    appointmentCreateActivity.finish();
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentCreateActivity, appointmentCreateActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentCreateActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentCreateActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentCreateActivity);
                    appointmentCreateActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentCreateActivity, appointmentCreateActivity.handler, fileCache, downloadFileUrl, false, appointmentCreateActivity.userinfoApplication);
                    appointmentCreateActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentCreateActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = appointmentCreateActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentCreateActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    DialogUtil.createShortDialog(appointmentCreateActivity, "您的网络貌似不给力，请重试");
                    break;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_create);
        appointmentCreateCustomerText = (TextView) findViewById(R.id.appointment_create_customer_text);
        appointmentCreateCustomerText.setOnClickListener(this);
        appointmentCreateAppointmentDateText = (TextView) findViewById(R.id.appointment_create_appointment_date_text);
        appointmentCreateAppointmentDateText.setOnClickListener(this);
        isdesignatAppointmentResponsiblePersonSpinner = (TextView) findViewById(R.id.isdesignat_appointment_responsible_person_text);
        designatedResponsiblePersonText = (TextView) findViewById(R.id.designated_responsible_person_text);
        appointmentServiceText = (TextView) findViewById(R.id.appointment_service_text);
        appointmentServiceText.setOnClickListener(this);
        appointmentCreateBackBtn = (ImageButton) findViewById(R.id.appointment_create_back_btn);
        appointmentCreateBackBtn.setOnClickListener(this);
        orderSearchNewMakeSureBtn = (Button) findViewById(R.id.order_search_new_make_sure_btn);
        orderSearchNewMakeSureBtn.setOnClickListener(this);
        appointmentCreateReset = (Button) findViewById(R.id.appointment_create_reset);
        appointmentCreateReset.setOnClickListener(this);
        appointmentRemark = (EditText) findViewById(R.id.appointment_remark);
        designatedResponsiblePersonRelativelayout = (RelativeLayout) findViewById(R.id.designated_responsible_person_relativelayout);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent it = getIntent();
        fromSource = it.getIntExtra("FROM_SOURCE", 0);
        appointmentConditionInfo = (AppointmentConditionInfo) it.getSerializableExtra("appointmentConditionInfo");
        isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.appointment_to_the_branch_designat_text));
        if (fromSource == CUSTOMER_SERVICE) {
            setCustomerCondition(it.getIntExtra("customerID", 0), it.getStringExtra("customerName"));
            appointmentCreateCustomerText.setEnabled(false);
            appointmentCreateCustomerText.setTextColor(Color.BLACK);
        } else if (fromSource == ORDER_DETAIL) {
            OrderInfo orderInfo = (OrderInfo) it.getSerializableExtra("orderInfo");
            setCustomerCondition(orderInfo.getCustomerID(), orderInfo.getCustomerName());
            setServiceInfo(orderInfo.getOrderID(), orderInfo.getProductName(), 0, orderInfo.getOrderObejctID());
            appointmentServiceText.setEnabled(false);
            appointmentServiceText.setTextColor(Color.BLACK);
            appointmentCreateCustomerText.setEnabled(false);
            appointmentCreateCustomerText.setTextColor(Color.BLACK);
            isOldOrder = true;
        }
    }

    @Override
    public void onClick(View v) {
        if (ProgressDialogUtil.isFastClick())
            return;
        Intent intent = null;
        switch (v.getId()) {
            case R.id.appointment_service_text:
                if (TextUtils.isEmpty(appointmentCreateCustomerText.getText().toString())) {
                    intent = new Intent(this, ServiceListActivity.class);
                    intent.putExtra("CategoryID", String.valueOf(0));
                    Bundle bu = new Bundle();
                    bu.putInt("FROM_SOURCE", APPOINTMENT_TO_SERVICE);
                    intent.putExtras(bu);
                    startActivityForResult(intent, 10);
                } else {
                    getCustomerOldOrderData();
                }
                break;
            case R.id.appointment_create_back_btn:
                this.finish();
                break;
            case R.id.appointment_create_reset:
                if (fromSource == APPOINTMENT) {
                    appointmentCreateCustomerText.setText("");
                    appointmentServiceText.setText("");
                } else if (fromSource == CUSTOMER_SERVICE) {
                    appointmentServiceText.setText("");
                }
                designatedResponsiblePersonRelativelayout.setVisibility(View.GONE);
                isdesignatAppointmentResponsiblePersonSpinner.setText(getString(R.string.appointment_to_the_branch_designat_text));
                designatedResponsiblePersonRelativelayout.setVisibility(View.GONE);
                appointmentRemark.setText("");
                appointmentCreateAppointmentDateText.setText("");
                designatedResponsiblePersonText.setText("");
                break;
            case R.id.appointment_create_customer_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Customer");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("messageType", "OrderFilter");
                JSONArray customerJsonArray = new JSONArray();
                customerJsonArray.put(customerID);
                intent.putExtra("selectPersonIDs", customerJsonArray.toString());
                startActivityForResult(intent, 11);
                break;
            case R.id.appointment_create_appointment_date_text:
                intent = new Intent(AppointmentCreateActivity.this, ChooseServicePeopleActivity.class);
                intent.putExtra("ExecutorID", executorID);
                intent.putExtra("ExecutorName", executorNames);
                intent.putExtra("FROM_SOURCE", CUSTOMER_SERVICE);
                startActivityForResult(intent, 100);
                designatedResponsiblePersonText.setText("");
                break;
            case R.id.order_search_new_make_sure_btn:
                String customerText = appointmentCreateCustomerText.getText().toString();
                final String remark = appointmentRemark.getText().toString();
                String dateText = appointmentCreateAppointmentDateText.getText().toString();
                String responsiblePersonText = designatedResponsiblePersonText.getText().toString();
                String serviceText = appointmentServiceText.getText().toString();
                if (TextUtils.isEmpty(customerText)) {
                    DialogUtil.createShortDialog(AppointmentCreateActivity.this, getString(R.string.appointment_toast_customertext));
                    return;
                }
                if (TextUtils.isEmpty(dateText)) {
                    DialogUtil.createShortDialog(AppointmentCreateActivity.this, getString(R.string.appointment_toast_datetext));
                    return;
                }
                if (isdesignatAppointmentResponsiblePersonSpinner.getText().toString().equals(getString(R.string.treatment_designat))) {
                    if (TextUtils.isEmpty(responsiblePersonText)) {
                        DialogUtil.createShortDialog(AppointmentCreateActivity.this, getString(R.string.appointment_toast_responsiblepersontext));
                        return;
                    }
                }
                if (TextUtils.isEmpty(serviceText)) {
                    DialogUtil.createShortDialog(AppointmentCreateActivity.this, getString(R.string.appointment_toast_servicetext));
                    return;
                }
                addScheduleList();
                break;
            default:
                break;
        }
    }

    private String dataTime() {
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");//设置日期格式
        System.out.println();// new Date()为获取当前系统时间
        String dataTime = df.format(new Date());
        return dataTime;
    }

    private void setBenefitPersonInfo(int id, String name) {
        executorID = id;
        executorNames = name;
        designatedResponsiblePersonText.setText(executorNames);
    }

    protected void setCustomerCondition(int personID, String personName) {
        customerID = personID;
        customerName = personName;
        appointmentCreateCustomerText.setText(customerName);
    }

    protected void setServiceInfo(int serID, String serName, long serCode, int orderObjectID) {
        this.serviceID = serID;
        this.serviceName = serName;
        this.serviceCode = serCode;
        this.objectID = orderObjectID;
        appointmentServiceText.setText(serviceName);
    }

    private void getCustomerOldOrderData() {
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
                    handler.sendEmptyMessage(2);
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
                        Message message = new Message();
                        try {
                            unFinishTGArray = resultJson.getJSONArray("Data");
                        } catch (JSONException e) {
                        }
                        if (unFinishTGArray != null && unFinishTGArray.length() > 0) {
                            isOldOrder = true;//存单
                        } else
                            isOldOrder = false;//新服务
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

    protected void addScheduleList() {
        progressDialog = ProgressDialogUtil.createProgressDialog(this);
        final String remark = appointmentRemark.getText().toString();
        requestWebServiceThread = new Thread() {
            @Override
            public void run() {
                String methodName = "AddSchedule";
                String endPoint = "Task";
                JSONObject appointmentJson = new JSONObject();

                try {
                    if (isdesignatAppointmentResponsiblePersonSpinner.getText().toString().equals(getString(R.string.treatment_designat))) {
                        appointmentJson.put("ExecutorID", executorID);
                    }
                    appointmentJson.put("TaskType", 1);
                    if (remark != null && !(("").equals(remark)))
                        appointmentJson.put("Remark", remark);
                    else
                        appointmentJson.put("Remark", "");
                    appointmentJson.put("TaskScdlStartTime", appointmentCreateAppointmentDateText.getText().toString());
                    appointmentJson.put("ReservedServiceCode", serviceCode);
                    appointmentJson.put("TaskOwnerID", customerID);
                    if (isOldOrder) {
                        appointmentJson.put("ReservedOrderID", serviceID);
                        appointmentJson.put("ReservedOrderServiceID", objectID);
                        appointmentJson.put("ReservedOrderType", 1);
                    } else {
                        appointmentJson.put("ReservedOrderType", 2);
                        appointmentJson.put("ReservedServiceCode", serviceCode);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                String serverResultResult = WebServiceUtil.requestWebServiceWithSSLUseJson(endPoint, methodName, appointmentJson.toString(), userinfoApplication);
                JSONObject resultJson = null;
                Message msg = handler.obtainMessage();
                try {
                    resultJson = new JSONObject(serverResultResult);
                } catch (JSONException e) {
                }

                if (serverResultResult == null || serverResultResult.equals(""))
                    handler.sendEmptyMessage(-1);
                else {
                    int code = 0;
                    String message = "";
                    try {
                        code = resultJson.getInt("Code");
                        message = resultJson.getString("Message");
                    } catch (JSONException e) {
                        code = 0;
                    }
                    if (code == 1) {
                        msg.obj = message;
                        msg.what = 1;
                        handler.sendMessage(msg);
                    } else if (code == Constant.APP_VERSION_ERROR || code == Constant.LOGIN_ERROR)
                        handler.sendEmptyMessage(code);
                    else {
                        msg.what = 0;
                        msg.obj = message;
                        handler.sendMessage(msg);
                    }
                }
            }
        };
        requestWebServiceThread.start();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 200) {
                setBenefitPersonInfo(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
            }
            if (requestCode == 11) {
                setCustomerCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
                appointmentServiceText.setText("");
            }
            if (requestCode == 10) {
                setServiceInfo(data.getIntExtra("serviceID", 0), data.getStringExtra("serviceName"), data.getLongExtra("serviceCode", 0), data.getIntExtra("OrderObjectID", 0));
            }
            if (requestCode == 12) {
                int isOldOrderInt = data.getIntExtra("isOldOrder", 0);
                if (isOldOrderInt == 1) {
                    OrderInfo orderInfo = (OrderInfo) data.getSerializableExtra("orderInfo");
                    isOldOrder = true;
                    setServiceInfo(orderInfo.getOrderID(), orderInfo.getProductName(), 0, orderInfo.getOrderObejctID());
                } else if (isOldOrderInt == 2) {
                    isOldOrder = false;
                    setServiceInfo(data.getIntExtra("serviceID", 0), data.getStringExtra("serviceName"), data.getLongExtra("serviceCode", 0), data.getIntExtra("OrderObjectID", 0));
                }
            }
            if (requestCode == 100) {
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
                appointmentCreateAppointmentDateText.setText(data.getStringExtra("TaskScdlStartTime"));
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        exit = true;
        if (handler != null) {
            handler.removeCallbacksAndMessages(null);
            // handler = null;
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

}
