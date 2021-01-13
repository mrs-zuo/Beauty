package cn.com.antika.business;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.AppointmentConditionInfo;
import cn.com.antika.util.SharedPreferenceUtil;

public class AppointmentTaskSearchActivity extends BaseActivity implements OnClickListener {
    private TextView appointmentTaskCustomerText, appointmentTaskResponsiblePerson;
    private UserInfoApplication userinfoApplication;
    private String executorID;
    private String executorNames;
    private String customerName;
    private int customerID = 0;
    private Button appointmentSearchMakeSureBtn, appointmentSearchResetBtn;
    private ImageButton appointmentTaskSearchBackBtn;
    private AppointmentConditionInfo appointmentConditionInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_appointment_task_search);
        initView();
    }

    private void initView() {
        appointmentTaskResponsiblePerson = (TextView) findViewById(R.id.appointment_task_responsible_person_text);
        appointmentTaskCustomerText = (TextView) findViewById(R.id.appointment_task_search_customer_text);
        appointmentTaskResponsiblePerson.setOnClickListener(this);
        appointmentTaskCustomerText.setOnClickListener(this);
        userinfoApplication = UserInfoApplication.getInstance();
        executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
        appointmentTaskResponsiblePerson.setText(userinfoApplication.getAccountInfo().getAccountName());
        appointmentSearchMakeSureBtn = (Button) findViewById(R.id.appointment_search_make_sure_btn);
        appointmentSearchMakeSureBtn.setOnClickListener(this);
        appointmentSearchResetBtn = (Button) findViewById(R.id.appointment_search_reset_btn);
        appointmentSearchResetBtn.setOnClickListener(this);
        appointmentTaskSearchBackBtn = (ImageButton) findViewById(R.id.appointment_task_search_back_btn);
        appointmentTaskSearchBackBtn.setOnClickListener(this);
        Intent it = getIntent();
        appointmentConditionInfo = (AppointmentConditionInfo) it.getSerializableExtra("appointmentConditionInfo");
        getConditionFromSharePre();
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        //查看所有订单或者预约的权限  如果ResponsiblePersonIDs为空  则读取本店所有的预约  如果不为空 则查看指定的ResponsiblePersonIDs的预约
        int authAllTaskRead = userinfoApplication.getAccountInfo().getAuthAllTaskRead();
        Intent intent = null;
        switch (view.getId()) {
            case R.id.appointment_task_responsible_person_text:
                intent = new Intent(AppointmentTaskSearchActivity.this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Multi");
                if (authAllTaskRead == 0)
                    intent.putExtra("getSubAccount", true);
                intent.putExtra("selectPersonIDs", executorID);
                startActivityForResult(intent, 200);
                break;
            case R.id.appointment_task_search_customer_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Customer");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("messageType", "OrderFilter");
                intent.putExtra("selectPersonIDs", String.valueOf(customerID));
                startActivityForResult(intent, 300);
                break;
            case R.id.appointment_search_reset_btn:
                //置空所选顾客
                customerID = 0;
                appointmentTaskCustomerText.setText("");
                //置空所选任务担当
                if (authAllTaskRead == 0) {
                    executorID = "[" + userinfoApplication.getAccountInfo().getAccountId() + "]";
                    executorNames = userinfoApplication.getAccountInfo().getAccountName();
                    appointmentTaskResponsiblePerson.setText(executorNames);
                } else {
                    appointmentTaskResponsiblePerson.setText("");
                }
                break;
            case R.id.appointment_search_make_sure_btn:
                appointmentConditionInfo.setCustomerID(customerID);
                appointmentConditionInfo.setResponsiblePersonIDs(executorID);
                saveConditionToSharePre();
                Intent data = new Intent();
                data.putExtra("appointmentCondition", appointmentConditionInfo);
                setResult(RESULT_OK, data);
                finish();
                break;
            case R.id.appointment_task_search_back_btn:
                this.finish();
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
        appointmentTaskResponsiblePerson.setText(executorNames);
    }

    /**
     * 将高级筛选条件存到SharePreference
     */
    private void saveConditionToSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.AppointmentTaskFlag);
        String value = getStringValue();
        sharePreUtil.putAdvancedFilter(key, value);
    }

    private void getConditionFromSharePre() {
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.AppointmentTaskFlag);
        String value = sharePreUtil.getValue(key);
        JSONObject jsValue = null;
        try {
            jsValue = new JSONObject(value);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        initAsJson(jsValue);
    }

    public String getStringValue() {
        JSONObject appointmentTaskJson = new JSONObject();
        try {
            String responsiblePersonName = appointmentTaskResponsiblePerson.getText().toString();
            if (!TextUtils.isEmpty(responsiblePersonName)) {
                appointmentTaskJson.put("ResponsiblePersonNames", responsiblePersonName);
                appointmentTaskJson.put("ResponsiblePersonIDs", executorID);
            }
            String customerName = appointmentTaskCustomerText.getText().toString();
            if (!TextUtils.isEmpty(customerName)) {
                appointmentTaskJson.put("CustomerName", customerName);
                appointmentTaskJson.put("CustomerID", customerID);
            }
        } catch (JSONException e) {
            e.printStackTrace();
            return "";
        }
        return appointmentTaskJson.toString();
    }

    public void initAsJson(JSONObject value) {
        if (value == null) {
            return;
        }
        try {
            if (value.has("ResponsiblePersonIDs"))
                executorID = value.getString("ResponsiblePersonIDs");
            if (value.has("ResponsiblePersonNames"))
                appointmentTaskResponsiblePerson.setText(value.getString("ResponsiblePersonNames"));
            if (value.has("CustomerID"))
                customerID = value.getInt("CustomerID");
            if (value.has("CustomerName"))
                appointmentTaskCustomerText.setText(value.getString("CustomerName"));
        } catch (JSONException e) {

        }
    }

    protected void setCustomerCondition(int personID, String personName) {
        customerID = personID;
        customerName = personName;
        appointmentTaskCustomerText.setText(customerName);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            if (requestCode == 200) {
                setBenefitPersonInfo(data.getStringExtra("personId"), data.getStringExtra("personName"));
            } else if (requestCode == 300) {
                setCustomerCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
            }
        }
    }
}
