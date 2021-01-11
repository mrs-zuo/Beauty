package com.GlamourPromise.Beauty.Business;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Calendar;
import java.util.HashMap;

/**
 * 今日服务筛选界面  包含
 * 业务分类							服务/商品
 * 业务状态							TG状态，交付状态
 * 顾问							         服务顾问
 * 顾客								订单所属顾客
 * 开始日期							TG开始时间
 * 结束日期							TG开始时间
 */
@SuppressLint("ResourceType")
public class TodayServiceSearchActivity extends Activity implements OnClickListener {
    private ImageButton todayServiceSearchBackButton;
    private Spinner todayServiceClassifySpinner, todayServiceStatusSpinner;
    private TextView todayServiceResponsiblePersonText, todayServiceCustomerText, todayServiceStartDateText, todayServiceEndDateText;
    private int customerID = 0;
    private String responsiblePersonName = "", customerName = "";
    private HashMap<String, Integer> startDateList, endDateList;
    private DatePickerDialog dialogStartDate, dialogEndDate;
    private StringBuffer strTodayServiceStartDate, strTodayServiceEndDate;
    private UserInfoApplication userinfoApplication;
    private OrderListBaseConditionInfo orderListBaseConditionInfo;
    private int filterByDateFlag = 0;
    private int accountID = 0;
    private Button orderSearchNewResetButton, orderSearchNewMakeSureButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_today_service_search);
        //返回按钮
        todayServiceSearchBackButton = (ImageButton) findViewById(R.id.today_service_search_back_btn);
        todayServiceSearchBackButton.setOnClickListener(this);
        orderSearchNewResetButton = (Button) findViewById(R.id.today_service_search_reset_btn);
        orderSearchNewResetButton.setOnClickListener(this);
        orderSearchNewMakeSureButton = (Button) findViewById(R.id.today_service_search_make_sure_btn);
        orderSearchNewMakeSureButton.setOnClickListener(this);
        todayServiceClassifySpinner = (Spinner) findViewById(R.id.today_service_classify_spinner);
        todayServiceStatusSpinner = (Spinner) findViewById(R.id.today_service_status_spinner);
        String[] todayServiceClassifyArray = new String[]{"全部", "服务", "商品"};
        ArrayAdapter<String> todayServiceClassifyAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, todayServiceClassifyArray);
        todayServiceClassifyAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        todayServiceClassifySpinner.setAdapter(todayServiceClassifyAdapter);
        String[] toayServiceStatusArray = new String[]{"全部", "未完成", "待确认", "已完成"};
        ArrayAdapter<String> todayServiceStatusAdapter = new ArrayAdapter<String>(this, R.xml.spinner_checked_text, toayServiceStatusArray);
        todayServiceStatusAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        todayServiceStatusSpinner.setAdapter(todayServiceStatusAdapter);
        todayServiceResponsiblePersonText = (TextView) findViewById(R.id.today_service_responsible_person_text);
        todayServiceResponsiblePersonText.setOnClickListener(this);
        todayServiceCustomerText = (TextView) findViewById(R.id.today_service_customer_text);
        todayServiceCustomerText.setOnClickListener(this);
        todayServiceStartDateText = (TextView) findViewById(R.id.today_service_start_date_text);
        todayServiceStartDateText.setOnClickListener(this);
        todayServiceEndDateText = (TextView) findViewById(R.id.today_service_end_date_text);
        todayServiceEndDateText.setOnClickListener(this);
        strTodayServiceStartDate = new StringBuffer("");
        strTodayServiceEndDate = new StringBuffer("");
        startDateList = new HashMap<String, Integer>();
        endDateList = new HashMap<String, Integer>();
        userinfoApplication = UserInfoApplication.getInstance();
        orderListBaseConditionInfo = getConditionFromSharePre();
        //初始化上次选择的筛选条件
        setLastSelectCondition();
    }

    /**
     * 设置上次选择的条件
     */
    private void setLastSelectCondition() {
        if (orderListBaseConditionInfo != null) {
            int todayServiceClassifySprinnerPosition = 0;
            int todayServiceStatusSpinnerPosition = 0;
            //业务类型的默认选择
            if (orderListBaseConditionInfo.getProductType() == Constant.SERVICE_TYPE) {
                todayServiceClassifySprinnerPosition = 1;
            } else if (orderListBaseConditionInfo.getProductType() == Constant.COMMODITY_TYPE) {
                todayServiceClassifySprinnerPosition = 2;
            }
            //业务状态的默认选择 未完成
            if (orderListBaseConditionInfo.getStatus() == Constant.ORDER_TG_STATUS_PROCESSED) {
                todayServiceStatusSpinnerPosition = 1;
            }
            //待确认
            else if (orderListBaseConditionInfo.getStatus() == Constant.ORDER_TG_STATUS_CONFIRM) {
                todayServiceStatusSpinnerPosition = 2;
            }
            //已完成
            else if (orderListBaseConditionInfo.getStatus() == Constant.ORDER_TG_STATUS_COMPLETE) {
                todayServiceStatusSpinnerPosition = 3;
            }
            todayServiceClassifySpinner.setSelection(todayServiceClassifySprinnerPosition);
            todayServiceStatusSpinner.setSelection(todayServiceStatusSpinnerPosition);
            accountID = orderListBaseConditionInfo.getAccountID();
            customerID = orderListBaseConditionInfo.getCustomerID();
            responsiblePersonName = orderListBaseConditionInfo.getResponsiblePersonName();
            customerName = orderListBaseConditionInfo.getCustomerName();
            if (accountID != 0) {
                todayServiceResponsiblePersonText.setText(responsiblePersonName);
            } else {
                accountID = userinfoApplication.getAccountInfo().getAccountId();
                responsiblePersonName = ((UserInfoApplication) getApplication()).getAccountInfo().getAccountName();
                todayServiceResponsiblePersonText.setText(responsiblePersonName);
            }
            if (customerID != 0) {
                todayServiceCustomerText.setText(customerName);
            }
            filterByDateFlag = orderListBaseConditionInfo.getFilterByTimeFlag();
            if (filterByDateFlag == 1) {
                todayServiceStartDateText.setText(orderListBaseConditionInfo.getStartDate());
                todayServiceEndDateText.setText(orderListBaseConditionInfo.getEndDate());
                strTodayServiceStartDate.append(orderListBaseConditionInfo.getStartDate());
                strTodayServiceEndDate.append(orderListBaseConditionInfo.getEndDate());
                startDateList = orderListBaseConditionInfo.getStartTimeList();
                endDateList = orderListBaseConditionInfo.getEndTimeList();
            }
        }
    }

    @Override
    public void onClick(View view) {
        // TODO Auto-generated method stub
        Intent intent = null;
        switch (view.getId()) {
            case R.id.today_service_search_back_btn:
                this.finish();
                break;
            case R.id.today_service_search_make_sure_btn:
                int todayServiceClassifySprinnerPosition = todayServiceClassifySpinner.getSelectedItemPosition();
                int todayServiceStatusSpinnerPosition = todayServiceStatusSpinner.getSelectedItemPosition();
                int todayServiceClassify = -1;
                int todayserviceStatus = -1;
                //业务类型选择的是服务还是商品
                if (todayServiceClassifySprinnerPosition == 1) {
                    todayServiceClassify = Constant.SERVICE_TYPE;
                } else if (todayServiceClassifySprinnerPosition == 2) {
                    todayServiceClassify = Constant.COMMODITY_TYPE;
                }
                //业务状态
                if (todayServiceStatusSpinnerPosition == 1) {
                    todayserviceStatus = Constant.ORDER_TG_STATUS_PROCESSED;
                } else if (todayServiceStatusSpinnerPosition == 2) {
                    todayserviceStatus = Constant.ORDER_TG_STATUS_CONFIRM;
                } else if (todayServiceStatusSpinnerPosition == 3) {
                    todayserviceStatus = Constant.ORDER_TG_STATUS_COMPLETE;
                }
                orderListBaseConditionInfo = new OrderListBaseConditionInfo();
                orderListBaseConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
                if (accountID != 0) {
                    orderListBaseConditionInfo.setAccountID(accountID);
                    orderListBaseConditionInfo.setResponsiblePersonName(responsiblePersonName);
                }
                if (customerID != 0) {
                    orderListBaseConditionInfo.setCustomerID(customerID);
                    orderListBaseConditionInfo.setCustomerName(customerName);
                }
                orderListBaseConditionInfo.setCreateTime("");
                orderListBaseConditionInfo.setPageIndex(1);
                orderListBaseConditionInfo.setPageSize(10);
                orderListBaseConditionInfo.setProductType(todayServiceClassify);
                orderListBaseConditionInfo.setStatus(todayserviceStatus);
                String startDate = strTodayServiceStartDate.toString();
                String endDate = strTodayServiceEndDate.toString();
                boolean isCondition = true;
                //按时间筛选,时间必须满足的条件
                if ((!startDate.equals("") && endDate.equals("")) || (startDate.equals("") && !endDate.equals(""))) {
                    DialogUtil.createShortDialog(this, "若按时间筛选，开始时间或结束时间不能为空！");
                    isCondition = false;
                } else if (!startDate.equals("") && !endDate.equals("")) {
                    if (isStartTimeBeyondEndTime()) {
                        DialogUtil.createShortDialog(this, "若按时间筛选，开始时间不能大于结束时间！");
                        isCondition = false;
                    } else {
                        orderListBaseConditionInfo.setFilterByTimeFlag(1);
                        orderListBaseConditionInfo.setStartDate(startDate);
                        orderListBaseConditionInfo.setEndDate(endDate);
                        orderListBaseConditionInfo.setStartTimeList(startDateList);
                        orderListBaseConditionInfo.setEndTimeList(endDateList);
                    }
                }
                if (isCondition) {
                    //将筛选条件写入到本地本件中
                    saveConditionToSharePre(orderListBaseConditionInfo);
                    Intent data = new Intent();
                    data.putExtra("baseCondition", orderListBaseConditionInfo);
                    setResult(1, data);
                    finish();
                }
                break;
            case R.id.today_service_search_reset_btn:
                reset();
                break;
            case R.id.today_service_responsible_person_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Doctor");
                intent.putExtra("checkModel", "Single");
                //如果当前账户没有查看本店订单的权限 只需要列出当前账号下的下级账号列表
                if (userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead() == 0)
                    intent.putExtra("getSubAccount", true);
                intent.putExtra("selectPersonIDs", new JSONArray().put(accountID).toString());
                startActivityForResult(intent, 10);
                break;
            case R.id.today_service_customer_text:
                intent = new Intent(this, ChoosePersonActivity.class);
                intent.putExtra("personRole", "Customer");
                intent.putExtra("checkModel", "Multi");
                intent.putExtra("messageType", "OrderFilter");
                JSONArray customerJsonArray = new JSONArray();
                customerJsonArray.put(customerID);
                intent.putExtra("selectPersonIDs", customerJsonArray.toString());
                startActivityForResult(intent, 11);
                break;
            case R.id.today_service_start_date_text:
                showStartDateDialog();
                break;
            case R.id.today_service_end_date_text:
                showEndDateDialog();
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // TODO Auto-generated method stub
        if (resultCode != RESULT_OK)
            return;
        switch (requestCode) {
            case 10:
                if ((data.getStringExtra("personName") == null || data.getStringExtra("personName").equals(""))) {
                    setPersonCondition(userinfoApplication.getAccountInfo().getAccountId(), ((UserInfoApplication) getApplication()).getAccountInfo().getAccountName());
                } else
                    setPersonCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
                break;
            case 11:
                setCustomerCondition(data.getIntExtra("personId", 0), data.getStringExtra("personName"));
                break;
            default:
                break;
        }

    }

    protected void reset() {
        todayServiceClassifySpinner.setSelection(0);
        todayServiceStatusSpinner.setSelection(0);
        todayServiceCustomerText.setText("");
        customerID = 0;
        accountID = userinfoApplication.getAccountInfo().getAccountId();
        responsiblePersonName = ((UserInfoApplication) getApplication()).getAccountInfo().getAccountName();
        todayServiceResponsiblePersonText.setText(responsiblePersonName);
        todayServiceStartDateText.setText("");
        strTodayServiceStartDate = new StringBuffer();
        todayServiceEndDateText.setText("");
        strTodayServiceEndDate = new StringBuffer();
    }

    protected void setPersonCondition(int personID, String personName) {
        accountID = personID;
        responsiblePersonName = personName;
        todayServiceResponsiblePersonText.setText(responsiblePersonName);
    }

    protected void setCustomerCondition(int personID, String personName) {
        customerID = personID;
        customerName = personName;
        todayServiceCustomerText.setText(customerName);
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

    private void showStartDateDialog() {
        Calendar calendarStart = Calendar.getInstance();
        if (dialogStartDate == null) {
            dialogStartDate = new DatePickerDialog(this, R.style.CustomerAlertDialog, new OnDateSetListener() {
                @Override
                public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                    strTodayServiceStartDate.replace(0, strTodayServiceStartDate.length(), "");
                    strTodayServiceStartDate.append(year);
                    strTodayServiceStartDate.append("年");
                    strTodayServiceStartDate.append(monthOfYear + 1);
                    strTodayServiceStartDate.append("月");
                    strTodayServiceStartDate.append(dayOfMonth);
                    strTodayServiceStartDate.append("日");
                    startDateList.put("Year", year);
                    startDateList.put("Month", monthOfYear + 1);
                    startDateList.put("Day", dayOfMonth);
                    todayServiceStartDateText.setText(strTodayServiceStartDate.toString());
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
                    strTodayServiceEndDate.replace(0, strTodayServiceEndDate.length(), "");
                    strTodayServiceEndDate.append(year);
                    strTodayServiceEndDate.append("年");
                    strTodayServiceEndDate.append(monthOfYear + 1);
                    strTodayServiceEndDate.append("月");
                    strTodayServiceEndDate.append(dayOfMonth);
                    strTodayServiceEndDate.append("日");

                    endDateList.put("Year", year);
                    endDateList.put("Month", monthOfYear + 1);
                    endDateList.put("Day", dayOfMonth);
                    todayServiceEndDateText.setText(strTodayServiceEndDate.toString());
                }
            }, calendarStart.get(Calendar.YEAR),
                    calendarStart.get(Calendar.MONTH),
                    calendarStart.get(Calendar.DAY_OF_MONTH));
        }
        dialogEndDate.show();
    }

    private void saveConditionToSharePre(OrderListBaseConditionInfo currentCondition) {
        // TODO Auto-generated method stub
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.TodayServiceFlag);
        String value = currentCondition.getStringValue();
        sharePreUtil.putAdvancedFilter(key, value);
    }

    private OrderListBaseConditionInfo getConditionFromSharePre() {
        OrderListBaseConditionInfo currentCondition = new OrderListBaseConditionInfo();
        SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
        String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(), userinfoApplication.getAccountInfo().getBranchId(), AdvancedFilterFlag.TodayServiceFlag);
        String value = sharePreUtil.getValue(key);
        JSONObject jsValue = null;
        try {
            jsValue = new JSONObject(value);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        currentCondition.initAsJson(jsValue);
        return currentCondition;
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        System.gc();
    }
}
