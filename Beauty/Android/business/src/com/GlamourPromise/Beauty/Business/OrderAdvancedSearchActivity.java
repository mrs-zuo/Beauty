package com.GlamourPromise.Beauty.Business;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition;
import com.GlamourPromise.Beauty.bean.AdvancedSearchCondition.OrderAdvancedSearchConditionBuilder;
import com.GlamourPromise.Beauty.bean.LabelInfo;
import com.GlamourPromise.Beauty.manager.NoteModel;
import com.GlamourPromise.Beauty.manager.RecordModel;
import com.GlamourPromise.Beauty.util.DialogUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil;
import com.GlamourPromise.Beauty.util.SharedPreferenceUtil.AdvancedFilterFlag;

/**
 * 笔记和咨询记录高级筛选
 * @author hongchuan.du
 *
 */
public class OrderAdvancedSearchActivity extends BaseActivity implements OnClickListener {
	public static final int ORDER_CONDITION = 1;
	public static final int RECORD_CONDITION = 2;
	public static final int NOTE_CONDITION = 3;
	
	private int conditionFlag = ORDER_CONDITION;
	
	private Button    confirmButton;
	//点击选择的输入框
	private TextView advancedResponsibleEditText;
	private TextView advancedCustomerEditText;
	private TextView advancedStartDateEditText;
	private TextView advancedEndDateEditText;
	
	private TextView mTvLabel;
	private int mBranchID;
	private int accountID;
	private boolean isByCustomer;
	
	private String  responsiblePersonIDs;//多个美丽顾问的IDs
	private int     customerID;//顾客ID
	private int     filterByDateFlag = 0;
	private String responsiblePersonName="";
	private String customerName="";
	private StringBuffer strOrderStartTime;
	private StringBuffer strOrderEndTime;
	private HashMap<String, Integer> startTimeList;
	private HashMap<String, Integer> endTimeList;
	private DatePickerDialog dialogStartDate;
	private DatePickerDialog dialogEndDate;
	
	private HashMap<Integer, LabelInfo> labelViewList;
	private AdvancedSearchCondition advancedCondition;
	
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_order_advanced_search);
		accountID = getIntent().getIntExtra("AccountID", 0);
		conditionFlag = getIntent().getIntExtra("ConditionFlag",ORDER_CONDITION);
		isByCustomer = getIntent().getBooleanExtra("IsByCustomer",false);
		//从右边菜单进入，即已经选择了客户
		UserInfoApplication userInfo = (UserInfoApplication) getApplication();
		RelativeLayout layoutCustomer = ((RelativeLayout) findViewById(R.id.layout_customer));
		View           layoutCustomerDivideView=findViewById(R.id.layout_customer_divide_view);
		if(isByCustomer){
			isByCustomer = true;
			customerID = userInfo.getSelectedCustomerID();
			layoutCustomer.setVisibility(View.GONE);
			layoutCustomerDivideView.setVisibility(View.GONE);
		}else {
			isByCustomer = false;
			layoutCustomer.setVisibility(View.VISIBLE);
			layoutCustomerDivideView.setVisibility(View.VISIBLE);
			layoutCustomer.setOnClickListener(this);
		}
		//咨询记录不可按照标签筛选
		if(conditionFlag==RECORD_CONDITION){
			findViewById(R.id.layout_label).setVisibility(View.GONE);
			findViewById(R.id.layout_label_divide_view).setVisibility(View.GONE);
		}
		mBranchID = ((UserInfoApplication)getApplication()).getAccountInfo().getBranchId();
		((ImageButton) findViewById(R.id.order_advanced_search_back_btn)).setOnClickListener(this);
		((Button) findViewById(R.id.advanced_search_reset_btn)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_responsible_person)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_label)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_start_time)).setOnClickListener(this);
		((RelativeLayout) findViewById(R.id.layout_end_time)).setOnClickListener(this);
		
		confirmButton = (Button) findViewById(R.id.advanced_search_make_sure_btn);
		confirmButton.setOnClickListener(this);
		
		mTvLabel = (TextView) findViewById(R.id.serach_label_content);	
		advancedResponsibleEditText=(TextView) findViewById(R.id.advanced_responsible_person_text);
		advancedResponsibleEditText.setInputType(InputType.TYPE_NULL);
		advancedCustomerEditText=(TextView) findViewById(R.id.advanced_customer_text);
		advancedStartDateEditText=(TextView) findViewById(R.id.advanced_order_start_date_text);
		advancedStartDateEditText.setInputType(InputType.TYPE_NULL);
		advancedEndDateEditText=(TextView) findViewById(R.id.advanced_order_end_date_text);
		advancedEndDateEditText.setInputType(InputType.TYPE_NULL);
		advancedStartDateEditText.setText(R.string.advanced_order_start_date_hint_text);
		advancedEndDateEditText.setText(R.string.advanced_order_end_date_hint_text);
		
		strOrderStartTime = new StringBuffer("");
		strOrderEndTime = new StringBuffer("");
		startTimeList = new HashMap<String, Integer>();
		endTimeList = new HashMap<String, Integer>();
		if(conditionFlag == RECORD_CONDITION){
			((TextView) findViewById(R.id.order_advanced_search_title_text)).setText("专业筛选");
		}
		else if(conditionFlag == NOTE_CONDITION){
			((TextView) findViewById(R.id.order_advanced_search_title_text)).setText("笔记筛选");
		}
		
		if(!isByCustomer){
			advancedCondition = getConditionFromSharePre();
		}
			
		//设置上次选择的条件
		setLastSelectCondition();
		
	}
	
	

	/**
	 * 设置上次选择的条件
	 */
	private void setLastSelectCondition() {
		if (advancedCondition != null) {
			responsiblePersonIDs = advancedCondition.getResponsiblePersonID();
			responsiblePersonName = advancedCondition.getResponsiblePersonName();
			if((responsiblePersonIDs==null || ("").equals(responsiblePersonIDs)) && !isByCustomer){
				responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
				responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
			}
			customerID = advancedCondition.getCustomerID();
			customerName = advancedCondition.getCustomerName();
			labelViewList = advancedCondition.getArrLabel();
			filterByDateFlag = advancedCondition.getFilterByTimeFlag();
		}
		resetActivity();
	}

	private void resetActivity() {
		advancedCustomerEditText.setText(customerName);
		advancedResponsibleEditText.setText(responsiblePersonName);
		//设置标签
		String strLabel = getLabelString();
		mTvLabel.setText(strLabel);
		//设置日期
		if(filterByDateFlag == 1){
			strOrderStartTime = new StringBuffer(advancedCondition.getStartDate());
			strOrderEndTime = new StringBuffer(advancedCondition.getEndDate());
			startTimeList = advancedCondition.getStartTimeList();
			endTimeList = advancedCondition.getEndTimeList();
			advancedStartDateEditText.setText(strOrderStartTime);
			advancedEndDateEditText.setText(strOrderEndTime);
		}else{
			advancedEndDateEditText.clearComposingText();
			advancedStartDateEditText.setText(R.string.advanced_order_start_date_hint_text);
			advancedEndDateEditText.setText(R.string.advanced_order_end_date_hint_text);
		}
	}

	@Override
	public void onClick(View view) {
		switch (view.getId()) {
		case R.id.order_advanced_search_back_btn:
			finish();
			break;
			//选择美丽顾问
		case R.id.layout_responsible_person:
			startResponsiblePersonActivity();
			break;
			//选择顾客
		case R.id.layout_customer:
			startCustomerActivity();
			break;
			//选择开始时间
		case R.id.layout_start_time:
			showStartDateDialog();
			break;
			//选择结束时间
		case R.id.layout_end_time:
			showEndDateDialog();
			break;
		case R.id.layout_label:
			startLabelListActivity();
			break;
		case R.id.advanced_search_reset_btn:
			reset();
			break;
		case R.id.advanced_search_make_sure_btn:
			String startTime = strOrderStartTime.toString();
			String endTime = strOrderEndTime.toString();
			OrderAdvancedSearchConditionBuilder advancedSearchCondition = new AdvancedSearchCondition.OrderAdvancedSearchConditionBuilder();
			//按时间筛选,时间必须满足的条件
			if(startTime.equals("") && endTime.equals("")){
				advancedSearchCondition.setFilterByTimeFlag(0);
			}else if(!startTime.equals("") && !endTime.equals("")){
				if(isStartTimeBeyondEndTime()){
					DialogUtil.createShortDialog(getApplicationContext(), "开始时间不能大于结束时间");
					return;
				}else{
					advancedSearchCondition.setFilterByTimeFlag(1);
					advancedSearchCondition.setStartDate(startTime);
					advancedSearchCondition.setEndDate(endTime);
					advancedSearchCondition.setStartTimeList(startTimeList);
					advancedSearchCondition.setEndTimeList(endTimeList);
				}
			}else{
				DialogUtil.createShortDialog(getApplicationContext(), "开始时间和结束时间不能只选择一个");
				return;
			}
			
			advancedSearchCondition.setCustomerID(customerID);
			advancedSearchCondition.setCustomerName(customerName);
			
			if(responsiblePersonName != null && !responsiblePersonName.equals("")){
				advancedSearchCondition.setResponsiblePersonID(responsiblePersonIDs);
				advancedSearchCondition.setResponsiblePersonName(responsiblePersonName);
			}
			
			advancedSearchCondition.setLabelList(labelViewList);
			AdvancedSearchCondition currentCondition = advancedSearchCondition.create();
			if(conditionFlag == RECORD_CONDITION){
				RecordModel.setAdvancedCondition(currentCondition);
				CustomerRecordTemplateActivity.setAdvancedCondition(currentCondition,isByCustomer);
			}else if(conditionFlag == NOTE_CONDITION){
				NoteModel.setAdvancedCondition(currentCondition);
			}
			if(!isByCustomer){
				saveConditionToSharePre(currentCondition);
			}
			setResult(RESULT_OK, null);
			finish();
			break;
		}
		
		
	}

	/**
	 * 将高级筛选条件存到SharePreference
	 * @param currentCondition
	 */
	private void saveConditionToSharePre(AdvancedSearchCondition currentCondition) {
		// TODO Auto-generated method stub
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = "";
		if(conditionFlag == RECORD_CONDITION){
			key = sharePreUtil.getAdvancedConditionKey(mBranchID, accountID, AdvancedFilterFlag.RecordFLag);
		}else if(conditionFlag == NOTE_CONDITION){
			key = sharePreUtil.getAdvancedConditionKey(mBranchID, accountID, AdvancedFilterFlag.NoteFlag);
		}
		String value = currentCondition.getStringValue();
		sharePreUtil.putAdvancedFilter(key, value);
	}
	
	private AdvancedSearchCondition getConditionFromSharePre(){
		AdvancedSearchCondition currentCondition = new AdvancedSearchCondition();
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = "";
		if(conditionFlag == RECORD_CONDITION){
			key = sharePreUtil.getAdvancedConditionKey(mBranchID, accountID, AdvancedFilterFlag.RecordFLag);
		}else if(conditionFlag == NOTE_CONDITION){
			key = sharePreUtil.getAdvancedConditionKey(mBranchID, accountID, AdvancedFilterFlag.NoteFlag);
		}
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

	private void reset() {
		// TODO Auto-generated method stub
		strOrderStartTime = new StringBuffer("");
		strOrderEndTime = new StringBuffer("");
		customerName = "";
		customerID=0;
		if(isByCustomer){
			responsiblePersonIDs="";
			responsiblePersonName = "";
		}
		else{
			responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
			responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
		}
		labelViewList = null;
		filterByDateFlag = 0;
		resetActivity();
	}

	private void startLabelListActivity() {
		// TODO Auto-generated method stub
		Intent intent = new Intent(this,LabelListActivity.class);
		intent.putExtra(LabelListActivity.LIMIT_NUM_FLAG, true);
		ArrayList<Integer> ids = new ArrayList<Integer>();
		if(labelViewList != null && labelViewList.size() > 0){
			for(int i = 0; i < labelViewList.size(); i++){
				ids.add(Integer.valueOf(labelViewList.get(i).getID()));
			}
		}
		intent.putExtra(LabelListActivity.SELECT_LABEL_LIST_ID, ids);
		startActivityForResult(intent, 4);
	}

	private void startCustomerActivity() {
		Intent intent;
		intent = new Intent(this, ChoosePersonActivity.class);
		intent.putExtra("personRole", "Customer");
		intent.putExtra("checkModel", "Multi");
		intent.putExtra("messageType", "OrderFilter");
		JSONArray customerJsonArray=new JSONArray();
		customerJsonArray.put(customerID);
		intent.putExtra("selectPersonIDs",customerJsonArray.toString());
		startActivityForResult(intent, 11);
	}

	private void startResponsiblePersonActivity() {
		Intent intent;
		intent = new Intent(this,ChoosePersonActivity.class);
		intent.putExtra("personRole", "Doctor");
		intent.putExtra("checkModel", "Multi");
		intent.putExtra("selectPersonIDs",responsiblePersonIDs);
		//如果是从左侧菜单进来 
		if(!isByCustomer){
			int authAllCustomerInfoWrite=((UserInfoApplication)getApplication()).getAccountInfo().getAuthAllCustomerInfoWrite();
			int authAllCustomerRecordInfoWrite=((UserInfoApplication)getApplication()).getAccountInfo().getAuthAllCustomerRecordInfoWrite();
			//如果筛选的是笔记 则有管理所有顾客信息时  则能查看所有账户的笔记
			if(conditionFlag == NOTE_CONDITION && authAllCustomerInfoWrite==0){
				intent.putExtra("getSubAccount",true);
			}
			//如果筛选的是专业 则有管理所有顾客专业信息时  则能查看所有账户的专业
			else if(conditionFlag ==RECORD_CONDITION  && authAllCustomerRecordInfoWrite==0){
				intent.putExtra("getSubAccount",true);
			}
		}
		startActivityForResult(intent, 10);
	}
	

	/**
	 * 处理选择顾客和美丽顾问
	 */
	@SuppressWarnings("unchecked")
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent id) {
		// TODO Auto-generated method stub
		if(resultCode != RESULT_OK){
			return;
		}
		switch (requestCode) {
		case 10:
			if((id.getStringExtra("personName")==null || id.getStringExtra("personName").equals("")) && !isByCustomer){
				setResponsiblePerson(new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString(),((UserInfoApplication)getApplication()).getAccountInfo().getAccountName());
			}
			else
				setResponsiblePerson(id.getStringExtra("personId"), id.getStringExtra("personName"));
			break;
		case 11:
			setCustomer(id.getIntExtra("personId", 0),id.getStringExtra("personName"));
			break;
		case 4:
			labelViewList = (HashMap<Integer, LabelInfo>) id.getSerializableExtra(LabelListActivity.LABEL_CONTENT_LIST);
			String strLabel = getLabelString();
			mTvLabel.setText(strLabel);
		break;
		default:
			break;
		}
	}

	private String getLabelString() {
		if(labelViewList != null){
			LabelInfo labelInfo;
			StringBuilder tmp = new StringBuilder();
			for(int i = 0; i < labelViewList.size(); i++){
				labelInfo = labelViewList.get(i);
				tmp.append(labelInfo.getLabelName());
				if(i != labelViewList.size() - 1)
					tmp.append("、");
			}
			return tmp.toString();
		}
		return "";
	}
	
	/**
	 * 设置选择的美丽顾问信息
	 * @param id
	 * @param name
	 */
	private void setResponsiblePerson(String id, String name){
		responsiblePersonIDs = id;
		responsiblePersonName = name;
		advancedResponsibleEditText.setText(name);
	}

	/**
	 * 设置选择的顾客信息
	 * @param id
	 * @param name
	 */
	private void setCustomer(int id, String name) {
		customerID = id;
		customerName = name;
		advancedCustomerEditText.setText(name);
	}
	
	/**
	 * 判断开始时间是否大于结束时间
	 * @return
	 */
	private Boolean isStartTimeBeyondEndTime(){
		int startYear = startTimeList.get("Year");
		int endYear = endTimeList.get("Year");
		int startMonth = startTimeList.get("Month");
		int endMonth = endTimeList.get("Month");
		int startDay = startTimeList.get("Day");
		int endDay = endTimeList.get("Day");
		if(startYear > endYear)
			return true;
		else if((startYear == endYear) && (startMonth > endMonth)){
			return true;
		}else if((startYear == endYear) && (startMonth == endMonth) && (startDay > endDay)){
			return true;
		}else
			return false;
		
	}
	
	/**
	 * 显示开始时间的选择框
	 */
	private void showStartDateDialog() {
		Calendar calendarStart = Calendar.getInstance();
		if (dialogStartDate == null) {
			dialogStartDate = new DatePickerDialog(this,
					R.style.CustomerAlertDialog, new OnDateSetListener() {

						@Override
						public void onDateSet(DatePicker view, int year,int monthOfYear, int dayOfMonth) {
							strOrderStartTime.replace(0,strOrderStartTime.length(), "");
							strOrderStartTime.append(year);
							strOrderStartTime.append("年");
							strOrderStartTime.append(monthOfYear + 1);
							strOrderStartTime.append("月");
							strOrderStartTime.append(dayOfMonth);
							strOrderStartTime.append("日");

							startTimeList.put("Year", year);
							startTimeList.put("Month", monthOfYear+1);
							startTimeList.put("Day", dayOfMonth);
							
							advancedStartDateEditText.setText(strOrderStartTime.toString());
						}
					}, calendarStart.get(Calendar.YEAR),
					calendarStart.get(Calendar.MONTH),
					calendarStart.get(Calendar.DAY_OF_MONTH));
		}
		dialogStartDate.show();
	}

	/**
	 * 显示结束日期的选择框
	 */
	private void showEndDateDialog() {
		Calendar calendarStart = Calendar.getInstance();
		if (dialogEndDate == null) {
			dialogEndDate = new DatePickerDialog(this,
					R.style.CustomerAlertDialog, new OnDateSetListener() {

						@Override
						public void onDateSet(DatePicker view, int year,int monthOfYear, int dayOfMonth) {
							strOrderEndTime.replace(0,strOrderEndTime.length(), "");
							strOrderEndTime.append(year);
							strOrderEndTime.append("年");
							strOrderEndTime.append(monthOfYear + 1);
							strOrderEndTime.append("月");
							strOrderEndTime.append(dayOfMonth);
							strOrderEndTime.append("日");

							endTimeList.put("Year", year);
							endTimeList.put("Month", monthOfYear+1);
							endTimeList.put("Day", dayOfMonth);
							advancedEndDateEditText.setText(strOrderEndTime.toString());
						}
					}, calendarStart.get(Calendar.YEAR),
					calendarStart.get(Calendar.MONTH),
					calendarStart.get(Calendar.DAY_OF_MONTH));
		}
		dialogEndDate.show();
	}

}
