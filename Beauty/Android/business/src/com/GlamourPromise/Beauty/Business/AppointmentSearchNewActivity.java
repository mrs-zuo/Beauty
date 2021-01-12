package com.GlamourPromise.Beauty.Business;

import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentConditionInfo;
import com.GlamourPromise.Beauty.bean.DownloadInfo;
import com.GlamourPromise.Beauty.bean.ServerPackageVersion;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.FileCache;
import com.GlamourPromise.Beauty.util.PackageUpdateUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Calendar;
import java.util.HashMap;

public class AppointmentSearchNewActivity extends BaseActivity implements OnClickListener {
    private AppointmentSearchNewActivityHandler handler = new AppointmentSearchNewActivityHandler(this);
    private ProgressDialog progressDialog;
    private PackageUpdateUtil packageUpdateUtil;
    String fromSource;
    private TextView appointmentSearchNewCustomerText, appointmentSearchNewAppointmentStartDateText, appointmentSearchNewAppointmentEndDateText, designatedResponsiblePersonText;
    private String executorID = "[]";
    private String executorNames;
    private String customerName;
    private int customerID = 0;
    private String item[] = new String[]{"全部", "待确认", "已确认", "已开单", "已取消"};
    private DatePickerDialog dialogStartDate, dialogEndDate;
    private StringBuffer strAppointmentStartDate, strAppointmentEndDate;
    private HashMap<String, Integer> startDateList, endDateList;
    private Button appointmentSearchNewMakeSureBtn, appointmentSearchNewResetBtn;
    private UserInfoApplication userinfoApplication;
    private AppointmentConditionInfo appointmentConditionInfo;
    private ImageButton orderSearchNewBackBtn;
    int status[];
    int statusInt;
    boolean isClickSpinner = false;
    TextView appointmentSearchNewAppointmentStatusSpinnerText;
    int itemPosition;
    // activity 销毁(onDestroy)标志
    private boolean exit;

    private static class AppointmentSearchNewActivityHandler extends Handler {
        private final AppointmentSearchNewActivity appointmentSearchNewActivity;

        private AppointmentSearchNewActivityHandler(AppointmentSearchNewActivity activity) {
            WeakReference<AppointmentSearchNewActivity> weakReference = new WeakReference<AppointmentSearchNewActivity>(activity);
            appointmentSearchNewActivity = weakReference.get();
        }

        @Override
        public void handleMessage(Message msg) {
            // 当activity未加载完成时,用户返回的情况
            if (appointmentSearchNewActivity.exit) {
                // 用户返回不做任何处理
                return;
            }
            if (appointmentSearchNewActivity.progressDialog != null) {
                appointmentSearchNewActivity.progressDialog.dismiss();
                appointmentSearchNewActivity.progressDialog = null;
            }
            switch (msg.what) {
                case 0:
                    DialogUtil.createShortDialog(appointmentSearchNewActivity, (String) msg.obj);
                    break;
                case 1:
                    DialogUtil.createShortDialog(appointmentSearchNewActivity, (String) msg.obj);
                    appointmentSearchNewActivity.finish();
                    break;
                case Constant.LOGIN_ERROR:
                    DialogUtil.createShortDialog(appointmentSearchNewActivity, appointmentSearchNewActivity.getString(R.string.login_error_message));
                    UserInfoApplication.getInstance().exitForLogin(appointmentSearchNewActivity);
                    break;
                case Constant.APP_VERSION_ERROR:
                    String downloadFileUrl = Constant.SERVER_URL + appointmentSearchNewActivity.getString(R.string.download_apk_address);
                    FileCache fileCache = new FileCache(appointmentSearchNewActivity);
                    appointmentSearchNewActivity.packageUpdateUtil = new PackageUpdateUtil(appointmentSearchNewActivity, appointmentSearchNewActivity.handler, fileCache, downloadFileUrl, false, appointmentSearchNewActivity.userinfoApplication);
                    appointmentSearchNewActivity.packageUpdateUtil.getPackageVersionInfo();
                    ServerPackageVersion serverPackageVersion = new ServerPackageVersion();
                    serverPackageVersion.setPackageVersion((String) msg.obj);
                    appointmentSearchNewActivity.packageUpdateUtil.mustUpdate(serverPackageVersion);
                    break;
                case 5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    String filename = "com.glamourpromise.beauty.business.apk";
                    File file = appointmentSearchNewActivity.getFileStreamPath(filename);
                    file.getName();
                    appointmentSearchNewActivity.packageUpdateUtil.showInstallDialog();
                    break;
                case -5:
                    ((DownloadInfo) msg.obj).getUpdateDialog().cancel();
                    break;
                case 7:
                    int downLoadFileSize = ((DownloadInfo) msg.obj).getDownloadApkSize();
                    ((DownloadInfo) msg.obj).getUpdateDialog().setProgress(downLoadFileSize);
                    break;
                default:
                    DialogUtil.createShortDialog(appointmentSearchNewActivity, "您的网络貌似不给力，请重试");
                    break;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        exit = false;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_search_new);
        appointmentSearchNewCustomerText = (TextView) findViewById(R.id.appointment_search_new_customer_text);
        appointmentSearchNewCustomerText.setOnClickListener(this);
        designatedResponsiblePersonText = (TextView) findViewById(R.id.designated_responsible_person_text);
        designatedResponsiblePersonText.setOnClickListener(this);
        appointmentSearchNewAppointmentStartDateText = (TextView) findViewById(R.id.appointment_search_new_appointment_start_date_text);
        appointmentSearchNewAppointmentStartDateText.setOnClickListener(this);
        appointmentSearchNewAppointmentEndDateText = (TextView) findViewById(R.id.appointment_search_new_appointment_end_date_text);
        appointmentSearchNewAppointmentEndDateText.setOnClickListener(this);
        appointmentSearchNewAppointmentStatusSpinnerText = (TextView) findViewById(R.id.appointmrnt_search_new_appointment_status_spinner_text);
        appointmentSearchNewMakeSureBtn = (Button) findViewById(R.id.appointment_search_new_make_sure_btn);
        appointmentSearchNewMakeSureBtn.setOnClickListener(this);
        appointmentSearchNewResetBtn = (Button) findViewById(R.id.appointment_search_new_reset_btn);
        orderSearchNewBackBtn = (ImageButton) findViewById(R.id.order_search_new_back_btn);
        orderSearchNewBackBtn.setOnClickListener(this);
        appointmentSearchNewResetBtn.setOnClickListener(this);
        userinfoApplication = UserInfoApplication.getInstance();
        strAppointmentStartDate = new StringBuffer("");
        strAppointmentEndDate = new StringBuffer("");
        startDateList = new HashMap<String, Integer>();
        endDateList = new HashMap<String, Integer>();
        Intent it = getIntent();
        appointmentConditionInfo = (AppointmentConditionInfo) it.getSerializableExtra("appointmentConditionInfo");
        appointmentSearchNewAppointmentStatusSpinnerText.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Dialog dialog = new AlertDialog.Builder(AppointmentSearchNewActivity.this, R.style.CustomerAlertDialog)
                        .setItems(item, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int position) {
                                itemPosition = position;
                                appointmentStatus(itemPosition);
                            }
                        }).create();
                dialog.show();
                dialog.setCancelable(true);
            }
        });
        executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
        designatedResponsiblePersonText.setText(userinfoApplication.getAccountInfo().getAccountName());
        getConditionFromSharePre();
    }

    private int[] appointmentStatus(int position) {
        status = new int[1];
        if (position == -1) {
            status = new int[]{1, 2};
            appointmentSearchNewAppointmentStatusSpinnerText.setText("");
        }
        if (position == 0) {
            status = new int[]{1, 2, 3, 4};
            appointmentSearchNewAppointmentStatusSpinnerText.setText("全部");
        }
        if (position == 1) {
            status[0] = 1;
            appointmentSearchNewAppointmentStatusSpinnerText.setText("待确认");
        }
        if (position == 2) {
            status[0] = 2;
            appointmentSearchNewAppointmentStatusSpinnerText.setText("已确认");
        }
        if (position == 3) {
            status[0] = 3;
            appointmentSearchNewAppointmentStatusSpinnerText.setText("已开单");
        }
        if (position == 4) {
            status[0] = 4;
            appointmentSearchNewAppointmentStatusSpinnerText.setText("已取消");
        }
        appointmentConditionInfo.setStatus(status);
        return status;
    }

    private Boolean isStartTimeBeyondEndTime() {
        int startYear = startDateList.get("Year");
        int endYear = endDateList.get("Year");
        int startMonth = startDateList.get("Month");
        int endMonth = endDateList.get("Month");
        int startDay = startDateList.get("Day");
        int endDay = endDateList.get("Day");
        if (startYear > endYear)
            return true;
        else if ((startYear == endYear) && (startMonth > endMonth)) {
            return true;
        } else if ((startYear == endYear) && (startMonth == endMonth) && (startDay > endDay)) {
            return true;
        } else
            return false;

    }


    @Override
    public void onClick(View v) {
        Intent intent = null;
        //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
        int authAllOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
        switch (v.getId()) {
            case R.id.order_search_new_back_btn:
                this.finish();
                break;
            case R.id.appointment_search_new_reset_btn:
                appointmentSearchNewAppointmentStatusSpinnerText.setText("");
                ;
                appointmentSearchNewCustomerText.setText("");
                appointmentSearchNewAppointmentStartDateText.setText("");
                appointmentSearchNewAppointmentEndDateText.setText("");
                //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
                if (authAllOrderRead == 0) {
                    executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
                    executorNames = userinfoApplication.getAccountInfo().getAccountName();
                    designatedResponsiblePersonText.setText(executorNames);
                } else {
                    designatedResponsiblePersonText.setText("");
                }
                appointmentStatus(-1);
                strAppointmentStartDate = new StringBuffer();
                strAppointmentEndDate = new StringBuffer();
                break;
            case R.id.appointment_search_new_customer_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Customer");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("messageType", "OrderFilter");
                intent.putExtra("selectPersonIDs", String.valueOf(customerID));
                startActivityForResult(intent, 11);
                break;
            case R.id.appointment_search_new_appointment_start_date_text:
                showStartDateDialog();
                break;
            case R.id.appointment_search_new_appointment_end_date_text:
                showEndDateDialog();
                break;
            case R.id.appointment_search_new_make_sure_btn:
//        	appointmentConditionInfo=new AppointmentConditionInfo();
                boolean isDataCondition = true;
                if ((!TextUtils.isEmpty(strAppointmentStartDate.toString()) && TextUtils.isEmpty(strAppointmentEndDate.toString())) || (TextUtils.isEmpty(strAppointmentStartDate.toString()) && !TextUtils.isEmpty(strAppointmentEndDate.toString()))) {
                    DialogUtil.createShortDialog(this, "若按时间筛选，开始时间或结束时间不能为空！");
                    isDataCondition = false;
                } else if (!TextUtils.isEmpty(strAppointmentStartDate.toString()) && !TextUtils.isEmpty(strAppointmentEndDate.toString())) {
                    if (isStartTimeBeyondEndTime()) {
                        DialogUtil.createShortDialog(this, "若按时间筛选，开始时间不能大于结束时间！");
                        isDataCondition = false;
                    } else {
                        appointmentConditionInfo.setFilterByTimeFlag(1);
                        appointmentConditionInfo.setStartTime(strAppointmentStartDate.toString());
                        appointmentConditionInfo.setEndTime(strAppointmentEndDate.toString());
                    }
                } else {
                    appointmentConditionInfo.setFilterByTimeFlag(0);
                }

                if (isDataCondition) {

                    if (!TextUtils.isEmpty(appointmentSearchNewCustomerText.getText().toString()))
                        appointmentConditionInfo.setCustomerID(customerID);
                    else
                        appointmentConditionInfo.setCustomerID(0);
                    if (!TextUtils.isEmpty(designatedResponsiblePersonText.getText().toString()))
                        appointmentConditionInfo.setResponsiblePersonIDs(executorID);
                    else
                        appointmentConditionInfo.setResponsiblePersonIDs("[]");
                    saveConditionToSharePre(appointmentConditionInfo.getFilterByTimeFlag());
                    Intent data = new Intent();
                    data.putExtra("appointmentConditionInfo", appointmentConditionInfo);
                    setResult(RESULT_OK, data);
                    finish();
                }
                break;
            case R.id.designated_responsible_person_text:
                intent = new Intent(AppointmentSearchNewActivity.this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Multi");

                if (authAllOrderRead == 0)
                    intent.putExtra("getSubAccount", true);
                intent.putExtra("selectPersonIDs", executorID);
                startActivityForResult(intent, 200);
                break;
            default:
                break;
        }
    }

    private void showStartDateDialog() {
        Calendar calendarStart = Calendar.getInstance();
        if (dialogStartDate == null) {
            dialogStartDate = new DatePickerDialog(this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                @Override
                public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                    strAppointmentStartDate.replace(0, strAppointmentStartDate.length(), "");
                    strAppointmentStartDate.append(year);
                    strAppointmentStartDate.append("-");
                    strAppointmentStartDate.append(monthOfYear + 1);
                    strAppointmentStartDate.append("-");
                    strAppointmentStartDate.append(dayOfMonth);

                    startDateList.put("Year", year);
                    startDateList.put("Month", monthOfYear + 1);
                    startDateList.put("Day", dayOfMonth);

                    appointmentSearchNewAppointmentStartDateText.setText(strAppointmentStartDate.toString());
                }
            }, calendarStart.get(Calendar.YEAR),
                    calendarStart.get(Calendar.MONTH),
                    calendarStart.get(Calendar.DAY_OF_MONTH));
        }
        dialogStartDate.show();
    }

    private void showEndDateDialog() {
        Calendar calendarStart = Calendar.getInstance();
        if (dialogEndDate == null) {
            dialogEndDate = new DatePickerDialog(this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                @Override
                public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                    strAppointmentEndDate.replace(0, strAppointmentEndDate.length(), "");
                    strAppointmentEndDate.append(year);
                    strAppointmentEndDate.append("-");
                    strAppointmentEndDate.append(monthOfYear + 1);
                    strAppointmentEndDate.append("-");
                    strAppointmentEndDate.append(dayOfMonth);

                    endDateList.put("Year", year);
                    endDateList.put("Month", monthOfYear + 1);
                    endDateList.put("Day", dayOfMonth);

                    appointmentSearchNewAppointmentEndDateText.setText(strAppointmentEndDate.toString());
                }
            }, calendarStart.get(Calendar.YEAR),
                    calendarStart.get(Calendar.MONTH),
                    calendarStart.get(Calendar.DAY_OF_MONTH));
        }
        dialogEndDate.show();
    }

    private void setBenefitPersonInfo(String id, String name) {
        if (name != null && !(("").equals(name))) {
            executorID = id;
            executorNames = name;
        } else {
            int authAllOrderRead = userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead();
            if (authAllOrderRead == 0) {
                executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
                executorNames = userinfoApplication.getAccountInfo().getAccountName();
            }
        }
        designatedResponsiblePersonText.setText(executorNames);
    }

    protected void setCustomerCondition(int personID, String personName) {
        customerID = personID;
        customerName = personName;
        appointmentSearchNewCustomerText.setText(customerName);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 200) {
                setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
            }
            if (requestCode == 11) {
                setCustomerCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
            }
        }
    }

    /**
     * 将高级筛选条件存到SharePreference
     *
     * @param filterByTimeFlag
     */
    private void saveConditionToSharePre(int filterByTimeFlag) {
        // TODO Auto-generated method stub
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), 1, AdvancedFilterFlag.OrderFlag);
        String value = getStringValue(filterByTimeFlag);
        sharePreUtil.putAdvancedFilter(key, value);
    }

    private void getConditionFromSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), 1, AdvancedFilterFlag.OrderFlag);
        String value = sharePreUtil.getValue(key);
        JSONObject jsValue = null;
        try {
            jsValue = new JSONObject(value);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        initAsJson(jsValue);
    }

    /* (non-Javadoc)
     *
     * @see android.app.Activity#onDestroy()
     */
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
        System.gc();
    }

    public String getStringValue(int filterByTimeFlag) {
        JSONArray statusArray = new JSONArray();
        JSONObject appointmentJson = new JSONObject();
        try {
            String cusName = appointmentSearchNewCustomerText.getText().toString();
            if (!TextUtils.isEmpty(cusName)) {
                appointmentJson.put("CustomerName", appointmentSearchNewCustomerText.getText().toString());
                appointmentJson.put("CustomerID", customerID);
            }
            String responsiblePersonName = designatedResponsiblePersonText.getText().toString();
            if (!TextUtils.isEmpty(responsiblePersonName)) {
                appointmentJson.put("ResponsiblePersonNames", responsiblePersonName);
                appointmentJson.put("ResponsiblePersonIDs", executorID);
            }
            if (TextUtils.isEmpty(appointmentSearchNewAppointmentStatusSpinnerText.getText().toString())) {
                appointmentJson.put("Status", -1);
            } else {
                appointmentJson.put("Status", itemPosition);
            }
            if (filterByTimeFlag != 0) {
                appointmentJson.put("StartTime", appointmentSearchNewAppointmentStartDateText.getText().toString());
                appointmentJson.put("EndTime", appointmentSearchNewAppointmentEndDateText.getText().toString());
                if (startDateList != null) {
                    JSONObject startTime = new JSONObject();
                    startTime.put("Year", startDateList.get("Year"));
                    startTime.put("Month", startDateList.get("Month"));
                    startTime.put("Day", startDateList.get("Day"));
                    appointmentJson.put("startDateList", startTime);
                }

                if (endDateList != null) {
                    JSONObject endTime = new JSONObject();
                    endTime.put("Year", endDateList.get("Year"));
                    endTime.put("Month", endDateList.get("Month"));
                    endTime.put("Day", endDateList.get("Day"));
                    appointmentJson.put("endDateList", endTime);
                }
            }
            appointmentJson.put("FilterByTimeFlag", appointmentConditionInfo.getFilterByTimeFlag());
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }
        return appointmentJson.toString();
    }

    public void initAsJson(JSONObject value) {
        if (value == null) {
            return;
        }
        try {
            if (value.has("CustomerName") && value.has("CustomerID"))
                setCustomerCondition(value.getInt("CustomerID"), value.getString("CustomerName"));
            if (value.has("ResponsiblePersonIDs"))
                executorID = value.getString("ResponsiblePersonIDs");
            if (value.has("ResponsiblePersonNames"))
                designatedResponsiblePersonText.setText(value.getString("ResponsiblePersonNames"));
            if (value.has("Status"))
                statusInt = value.getInt("Status");
            appointmentStatus(statusInt);
            if (value.has("FilterByTimeFlag")) {
                if (value.getInt("FilterByTimeFlag") != 0) {
                    appointmentSearchNewAppointmentStartDateText.setText(value.getString("StartTime"));
                    appointmentSearchNewAppointmentEndDateText.setText(value.getString("EndTime"));
                    strAppointmentStartDate.append(appointmentSearchNewAppointmentStartDateText.getText().toString());
                    strAppointmentEndDate.append(appointmentSearchNewAppointmentEndDateText.getText().toString());
                    if (value.has("startDateList")) {
                        JSONObject tmp = value.getJSONObject("startDateList");
                        startDateList.put("Year", (Integer) tmp.get("Year"));
                        startDateList.put("Month", (Integer) tmp.get("Month"));
                        startDateList.put("Day", (Integer) tmp.get("Day"));
                    }

                    if (value.has("endDateList")) {
                        JSONObject tmp = value.getJSONObject("endDateList");
                        endDateList.put("Year", (Integer) tmp.get("Year"));
                        endDateList.put("Month", (Integer) tmp.get("Month"));
                        endDateList.put("Day", (Integer) tmp.get("Day"));
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
