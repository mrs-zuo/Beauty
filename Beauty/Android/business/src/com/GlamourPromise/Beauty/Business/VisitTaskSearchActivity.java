package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AppointmentConditionInfo;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@SuppressLint("ResourceType")
public class VisitTaskSearchActivity extends BaseActivity implements OnClickListener {
    private ProgressDialog progressDialog;
    String fromSource;
    private TextView designatedResponsiblePersonText, visitTaskCustomerText;
    private Spinner visitTaskStatusSpinner, visitTaskTypeSpinner;
    private String executorID = "";
    private String executorNames;
    private int customerID = 0;
    private String customerName;
    private String statusItem[] = new String[]{"全部", "待回访", "已完成"};
    private String typeItem[] = new String[]{"所有回访", "订单回访", "生日回访"};
    private Button appointmentSearchNewMakeSureBtn, appointmentSearchNewResetBtn;
    private UserInfoApplication userinfoApplication;
    private AppointmentConditionInfo appointmentConditionInfo;
    private ImageButton orderSearchNewBackBtn;
    RelativeLayout appointmrntTaskSearchNewAppointmentStatusRelativelayout;
    int status[];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_visit_task_search);
        userinfoApplication = UserInfoApplication.getInstance();
        Intent it = getIntent();
        appointmentConditionInfo = (AppointmentConditionInfo) it.getSerializableExtra("appointmentConditionInfo");
        designatedResponsiblePersonText = (TextView) findViewById(R.id.designated_responsible_person_text);
        designatedResponsiblePersonText.setOnClickListener(this);
        visitTaskCustomerText = (TextView) findViewById(R.id.visit_task_search_customer_text);
        visitTaskCustomerText.setOnClickListener(this);
        appointmentSearchNewMakeSureBtn = (Button) findViewById(R.id.appointment_search_new_make_sure_btn);
        appointmentSearchNewMakeSureBtn.setOnClickListener(this);
        appointmentSearchNewResetBtn = (Button) findViewById(R.id.appointment_search_new_reset_btn);
        orderSearchNewBackBtn = (ImageButton) findViewById(R.id.order_search_new_back_btn);
        orderSearchNewBackBtn.setOnClickListener(this);
        appointmentSearchNewResetBtn.setOnClickListener(this);
        appointmrntTaskSearchNewAppointmentStatusRelativelayout = (RelativeLayout) findViewById(R.id.appointmrnt_task_search_new_appointment_status_relativelayout);
        visitTaskStatusSpinner = (Spinner) findViewById(R.id.appointmrnt_task_search_new_appointment_status_spinner);
        ArrayAdapter<String> appointmentArrayAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, statusItem);
        appointmentArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        visitTaskStatusSpinner.setAdapter(appointmentArrayAdapter);
        visitTaskStatusSpinner.setSelection(0);
        visitTaskTypeSpinner = (Spinner) findViewById(R.id.appointmrnt_task_search_new_appointment_type_spinner);
        ArrayAdapter<String> appointmentTaskArrayAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, typeItem);
        appointmentTaskArrayAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        visitTaskTypeSpinner.setAdapter(appointmentTaskArrayAdapter);
        visitTaskTypeSpinner.setSelection(0);
        executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
        designatedResponsiblePersonText.setText(userinfoApplication.getAccountInfo().getAccountName());
        getConditionFromSharePre();
    }

    @Override
    public void onClick(View v) {
        Intent intent = null;
        //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
        int authAllTaskRead = userinfoApplication.getAccountInfo().getAuthAllTaskRead();
        switch (v.getId()) {
            case R.id.order_search_new_back_btn:
                this.finish();
                break;
            case R.id.appointment_search_new_reset_btn:
                visitTaskStatusSpinner.setSelection(0, true);
                visitTaskTypeSpinner.setSelection(0, true);
                //置空所选顾客
                customerID = 0;
                visitTaskCustomerText.setText("");
                if (authAllTaskRead == 0) {
                    executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
                    designatedResponsiblePersonText.setText(userinfoApplication.getAccountInfo().getAccountName());
                } else {
                    designatedResponsiblePersonText.setText("");
                }
                break;
            case R.id.appointment_search_new_make_sure_btn:
                JSONArray typeJsonArray = new JSONArray();
                appointmentConditionInfo.setFilterByTimeFlag(0);
                if (visitTaskTypeSpinner.getSelectedItemPosition() != 0) {
                    //如果是订单回访
                    if (visitTaskTypeSpinner.getSelectedItemPosition() == 1) {
                        typeJsonArray.put(2);
                    }
                    //如果是生日回访
                    else if (visitTaskTypeSpinner.getSelectedItemPosition() == 2) {
                        typeJsonArray.put(4);
                    }

                } else {
                    typeJsonArray.put(2);
                    typeJsonArray.put(4);
                }
                appointmentConditionInfo.setTaskTypeArray(typeJsonArray.toString());
                status = new int[1];
                if (visitTaskStatusSpinner.getSelectedItemPosition() == 0) {
                    status = new int[]{2, 3};
                } else if (visitTaskStatusSpinner.getSelectedItemPosition() == 1) {
                    status[0] = 2;
                } else if (visitTaskStatusSpinner.getSelectedItemPosition() == 2) {
                    status[0] = 3;
                }
                appointmentConditionInfo.setStatus(status);
                if (!TextUtils.isEmpty(designatedResponsiblePersonText.getText().toString()))
                    appointmentConditionInfo.setResponsiblePersonIDs(executorID);
                else
                    appointmentConditionInfo.setResponsiblePersonIDs("[]");
                appointmentConditionInfo.setCustomerID(customerID);
                saveConditionToSharePre();
                Intent data = new Intent();
                data.putExtra("appointmentCondition", appointmentConditionInfo);
                setResult(RESULT_OK, data);
                finish();
                break;
            case R.id.designated_responsible_person_text:
                intent = new Intent(VisitTaskSearchActivity.this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Multi");
                if (authAllTaskRead == 0)
                    intent.putExtra("getSubAccount", true);
                intent.putExtra("selectPersonIDs", executorID);
                startActivityForResult(intent, 200);
                break;
            case R.id.visit_task_search_customer_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Customer");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("messageType", "OrderFilter");
                intent.putExtra("selectPersonIDs", String.valueOf(customerID));
                startActivityForResult(intent, 300);
                break;
            default:
                break;
        }
    }

    private void setBenefitPersonInfo(String id, String name) {
        if (name != null && !(("").equals(name))) {
            executorID = id;
            executorNames = name;
        } else {
            int authAllTaskRead = userinfoApplication.getAccountInfo().getAuthAllTaskRead();
            if (authAllTaskRead == 0) {
                executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
                executorNames = userinfoApplication.getAccountInfo().getAccountName();
            }
        }
        designatedResponsiblePersonText.setText(executorNames);
    }

    protected void setCustomerCondition(int personID, String personName) {
        customerID = personID;
        customerName = personName;
        visitTaskCustomerText.setText(customerName);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // 选择员工成功返回
        if (resultCode == RESULT_OK) {
            if (requestCode == 200) {
                setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
            } else if (requestCode == 300) {
                setCustomerCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
            }
        }
    }

    public String getStringValue() {
        JSONObject visitTaskJson = new JSONObject();
        try {
            String responsiblePersonName = designatedResponsiblePersonText.getText().toString();
            if (!TextUtils.isEmpty(responsiblePersonName)) {
                visitTaskJson.put("ResponsiblePersonNames", responsiblePersonName);
                visitTaskJson.put("ResponsiblePersonIDs", executorID);
            }
            String customerName = visitTaskCustomerText.getText().toString();
            if (!TextUtils.isEmpty(customerName)) {
                visitTaskJson.put("CustomerName", customerName);
                visitTaskJson.put("CustomerID", customerID);
            }
            JSONArray statusJsonArray = new JSONArray();
            if (visitTaskStatusSpinner.getSelectedItemPosition() == 0) {
                statusJsonArray.put(2);
                statusJsonArray.put(3);
            } else if (visitTaskStatusSpinner.getSelectedItemPosition() == 1) {
                statusJsonArray.put(2);
            } else if (visitTaskStatusSpinner.getSelectedItemPosition() == 2) {
                statusJsonArray.put(3);
            }
            visitTaskJson.put("Status", statusJsonArray);
            visitTaskJson.put("TaskType", appointmentConditionInfo.getTaskTypeArray());
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }
        return visitTaskJson.toString();
    }

    @SuppressLint("NewApi")
    public void initAsJson(JSONObject value) {
        if (value == null) {
            return;
        }
        try {
            if (value.has("ResponsiblePersonIDs"))
                executorID = value.getString("ResponsiblePersonIDs");
            if (value.has("ResponsiblePersonNames"))
                designatedResponsiblePersonText.setText(value.getString("ResponsiblePersonNames"));
            if (value.has("CustomerID"))
                customerID = value.getInt("CustomerID");
            if (value.has("CustomerName"))
                visitTaskCustomerText.setText(value.getString("CustomerName"));
            if (value.has("Status")) {
                JSONArray statusJsonArray = value.getJSONArray("Status");
                if (statusJsonArray.length() > 1) {
                    visitTaskStatusSpinner.setSelection(0);
                } else {
                    int status = statusJsonArray.getInt(0);
                    if (status == 2)
                        visitTaskStatusSpinner.setSelection(1);
                    else if (status == 3)
                        visitTaskStatusSpinner.setSelection(2);
                }
            }

            //根据筛选不同的任务类型  做默认选择
            if (value.has("TaskType")) {
                if (value.isNull("TaskType"))
                    visitTaskTypeSpinner.setSelection(0);
                else {
                    JSONArray typeArray = new JSONArray(value.getString("TaskType"));
                    if (typeArray.length() > 1) {
                        visitTaskTypeSpinner.setSelection(0);
                    } else {
                        int taskType = typeArray.getInt(0);
                        if (taskType == 2) {
                            visitTaskTypeSpinner.setSelection(1);
                        } else if (taskType == 4) {
                            visitTaskTypeSpinner.setSelection(2);
                        }
                    }
                }
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * 将高级筛选条件存到SharePreference
     */
    private void saveConditionToSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.VisitTaskFlag);
        String value = getStringValue();
        sharePreUtil.putAdvancedFilter(key, value);
    }

    private void getConditionFromSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.VisitTaskFlag);
        String value = sharePreUtil.getValue(key);
        JSONObject jsValue = null;
        try {
            jsValue = new JSONObject(value);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        initAsJson(jsValue);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        System.gc();
        if (progressDialog != null) {
            progressDialog.dismiss();
            progressDialog = null;
        }
    }
}
