/**
 * opportunityAdvancedSearchActivity.java
 * cn.com.antika.business
 * tim.zhang@bizapper.com
 * 2015年1月28日 上午11:53:42
 * @version V1.0
 */
package cn.com.antika.business;

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
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Calendar;
import java.util.HashMap;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OpportunityListBaseConditionInfo;
import cn.com.antika.constant.Constant;
import cn.com.antika.util.DialogUtil;
import cn.com.antika.util.SharedPreferenceUtil;

/**
 *订单筛选界面  包含美丽顾问  顾客  下单时间  订单分类  订单状态  支付状态
 *
 * @author tim.zhang@bizapper.com
 * 2015年1月28日 上午11:53:42
 */
@SuppressLint("ResourceType")
public class OpportunityAdvancedSearchActivity extends Activity implements OnClickListener{
	private ImageButton  opportunityAdvancedSearchBackButton,opportunityAdvancedSearchResetButton,opportunityAdvancedSearchMakeSureButton;
	private Spinner      opportunityAdvancedSearchProductTypeSpinner;
	private TextView     opportunityAdvancedSearchResponsiblePersonText,opportunityAdvancedSearchCustomerText,opportunityAdvancedSearchStartDateText,opportunityAdvancedSearchEndDateText;
	private int customerID=0;
	private String responsiblePersonName="",customerName="";
	private HashMap<String, Integer> startDateList,endDateList;
	private DatePickerDialog dialogStartDate,dialogEndDate;
	private StringBuffer strOrderStartDate,strOrderEndDate;
	private UserInfoApplication userinfoApplication;
	private OpportunityListBaseConditionInfo opportunityListBaseConditionInfo;
	private int  filterByDateFlag=0;
	private String responsiblePersonIDs="";
	/* (non-Javadoc)
	 * @param savedInstanceState
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_opportunity_advanced_search);
		opportunityAdvancedSearchBackButton=(ImageButton) findViewById(R.id.opportunity_advanced_search_back_btn);
		opportunityAdvancedSearchBackButton.setOnClickListener(this);
		opportunityAdvancedSearchResetButton=(ImageButton)findViewById(R.id.opportunity_advanced_search_reset_btn);
		opportunityAdvancedSearchResetButton.setOnClickListener(this);
		opportunityAdvancedSearchMakeSureButton=(ImageButton) findViewById(R.id.opportunity_advanced_search_make_sure_btn);
		opportunityAdvancedSearchMakeSureButton.setOnClickListener(this);
		opportunityAdvancedSearchProductTypeSpinner=(Spinner)findViewById(R.id.opportunity_advanced_search_order_classify_spinner);
		String[] opportunityProductTypeArray=new String[]{"全部","服务","商品"};
		ArrayAdapter<String> opportunityProductTypeAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,opportunityProductTypeArray);
		opportunityProductTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		opportunityAdvancedSearchProductTypeSpinner.setAdapter(opportunityProductTypeAdapter);
		opportunityAdvancedSearchResponsiblePersonText=(TextView) findViewById(R.id.opportunity_advanced_search_responsible_person_text);
		opportunityAdvancedSearchResponsiblePersonText.setOnClickListener(this);
		opportunityAdvancedSearchCustomerText=(TextView) findViewById(R.id.opportunity_advanced_search_customer_text);
		opportunityAdvancedSearchCustomerText.setOnClickListener(this);
		opportunityAdvancedSearchStartDateText=(TextView) findViewById(R.id.opportunity_advanced_search_order_start_date_text);
		opportunityAdvancedSearchStartDateText.setOnClickListener(this);
		opportunityAdvancedSearchEndDateText=(TextView) findViewById(R.id.opportunity_advanced_search_order_end_date_text);
		opportunityAdvancedSearchEndDateText.setOnClickListener(this);
		strOrderStartDate = new StringBuffer("");
		strOrderEndDate = new StringBuffer("");
		startDateList = new HashMap<String, Integer>();
		endDateList = new HashMap<String, Integer>();
		userinfoApplication=UserInfoApplication.getInstance();
		opportunityListBaseConditionInfo=getConditionFromSharePre();
		//设置上次选择的条件
		setLastSelectCondition();
	}
	/**
	 * 设置上次选择的条件
	 */
	private void setLastSelectCondition() {
		if (opportunityListBaseConditionInfo != null) {
			//订单分类选择的是服务或者商品
			int opportunityProductTypeSprinnerPosition=0;
			if(opportunityListBaseConditionInfo.getProductType()== Constant.SERVICE_TYPE){
				opportunityProductTypeSprinnerPosition=1;
			}
			else if(opportunityListBaseConditionInfo.getProductType()==Constant.COMMODITY_TYPE){
				opportunityProductTypeSprinnerPosition=2;
			}
			opportunityAdvancedSearchProductTypeSpinner.setSelection(opportunityProductTypeSprinnerPosition);
			responsiblePersonIDs = opportunityListBaseConditionInfo.getResponsiblePersonIDs();
			customerID = opportunityListBaseConditionInfo.getCustomerID();
			responsiblePersonName = opportunityListBaseConditionInfo.getResponsiblePersonName();
			customerName = opportunityListBaseConditionInfo.getCustomerName();
			if(responsiblePersonIDs!=null && !("").equals(responsiblePersonIDs)){
				opportunityAdvancedSearchResponsiblePersonText.setText(responsiblePersonName);
			}
			else{
				responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
				responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
				opportunityAdvancedSearchResponsiblePersonText.setText(responsiblePersonName);
			}
			if(customerID!=0){
				opportunityAdvancedSearchCustomerText.setText(customerName);
			}
			filterByDateFlag = opportunityListBaseConditionInfo.getFilterByTimeFlag();
			if(filterByDateFlag==1){
				opportunityAdvancedSearchStartDateText.setText(opportunityListBaseConditionInfo.getStartDate());
				opportunityAdvancedSearchEndDateText.setText(opportunityListBaseConditionInfo.getEndDate());
				strOrderStartDate.append(opportunityListBaseConditionInfo.getStartDate());
				strOrderEndDate.append(opportunityListBaseConditionInfo.getEndDate());
				startDateList=opportunityListBaseConditionInfo.getStartTimeList();
				endDateList=opportunityListBaseConditionInfo.getEndTimeList();
			}
		}
	}
	/* (non-Javadoc)
	 * @param v
	 * @see android.view.View.OnClickListener#onClick(android.view.View)
	 */
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		Intent intent=null;
		switch(view.getId()){
		case R.id.opportunity_advanced_search_back_btn:
			this.finish();
			break;
		case R.id.opportunity_advanced_search_make_sure_btn:
			//订单分类
			int opportunityProductTypeSprinnerPosition=opportunityAdvancedSearchProductTypeSpinner.getSelectedItemPosition();
			//订单分类选择的是服务或者商品
			int opportunityProductType=-1;
			if(opportunityProductTypeSprinnerPosition==1){
				opportunityProductType=Constant.SERVICE_TYPE;
			}
			else if(opportunityProductTypeSprinnerPosition==2){
				opportunityProductType=Constant.COMMODITY_TYPE;
			}
			opportunityListBaseConditionInfo=new OpportunityListBaseConditionInfo();
			if(responsiblePersonIDs!=null && !("").equals(responsiblePersonIDs)){
				opportunityListBaseConditionInfo.setResponsiblePersonID(responsiblePersonIDs);
				opportunityListBaseConditionInfo.setResponsiblePersonName(responsiblePersonName);
			}
			if(customerID!=0){
				opportunityListBaseConditionInfo.setCustomerID(customerID);
				opportunityListBaseConditionInfo.setCustomerName(customerName);
			}
			opportunityListBaseConditionInfo.setCreateTime("");
			opportunityListBaseConditionInfo.setPageIndex(1);
			opportunityListBaseConditionInfo.setPageSize(10);
			opportunityListBaseConditionInfo.setProductType(opportunityProductType);
			String startDate = strOrderStartDate.toString();
			String endDate = strOrderEndDate.toString();
			//控制日期选择的格式是否正确，false情况下，则不能跳转到订单列表页
			boolean isCondition=true;
			//按时间筛选,时间必须满足的条件
			if((!startDate.equals("") && endDate.equals("")) || (startDate.equals("") && !endDate.equals(""))){
				DialogUtil.createShortDialog(this, "若按时间筛选，开始时间或结束时间不能为空！");
				isCondition=false;
				}
			else if(!startDate.equals("") && !endDate.equals("")){
					if(isStartTimeBeyondEndTime()){
						DialogUtil.createShortDialog(this, "若按时间筛选，开始时间不能大于结束时间！");
						isCondition=false;
					}
					else{
						opportunityListBaseConditionInfo.setFilterByTimeFlag(1);
						opportunityListBaseConditionInfo.setStartDate(startDate);
						opportunityListBaseConditionInfo.setEndDate(endDate);
						opportunityListBaseConditionInfo.setStartTimeList(startDateList);
						opportunityListBaseConditionInfo.setEndTimeList(endDateList);
					}
				}
			if(isCondition){
				//将筛选条件写入到本地本件中
				saveConditionToSharePre(opportunityListBaseConditionInfo);
				Intent data=new Intent();
				data.putExtra("baseCondition",opportunityListBaseConditionInfo);
				setResult(1,data);
				finish();
			}
			break;
		case R.id.opportunity_advanced_search_reset_btn:
			reset();
			break;
		case R.id.opportunity_advanced_search_responsible_person_text:
			intent = new Intent(this, ChoosePersonActivity.class);
			intent.putExtra("personRole", "Doctor");
			intent.putExtra("checkModel", "Multi");
			intent.putExtra("getSubAccount",true);
			intent.putExtra("selectPersonIDs",responsiblePersonIDs);
			startActivityForResult(intent, 10);
			break;
		case R.id.opportunity_advanced_search_customer_text:
			intent = new Intent(this, ChoosePersonActivity.class);
			intent.putExtra("personRole", "Customer");
			intent.putExtra("checkModel", "Multi");
			intent.putExtra("messageType", "OrderFilter");
			JSONArray customerJsonArray=new JSONArray();
			customerJsonArray.put(customerID);
			intent.putExtra("selectPersonIDs",customerJsonArray.toString());
			startActivityForResult(intent,11);
			break;
		case R.id.opportunity_advanced_search_order_start_date_text:
			showStartDateDialog();
			break;
		case R.id.opportunity_advanced_search_order_end_date_text:
			showEndDateDialog();
			break;
		}
	}
	/* (non-Javadoc)
	 * @param requestCode
	 * @param resultCode
	 * @param data
	 * @see android.app.Activity#onActivityResult(int, int, android.content.Intent)
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// TODO Auto-generated method stub
		if(resultCode!=RESULT_OK)
			return;
		switch (requestCode) {
		case 10:
			if(data.getStringExtra("personName")==null || data.getStringExtra("personName").equals(""))
					setPersonCondition((new JSONArray().put(userinfoApplication.getAccountInfo().getAccountId())).toString(),userinfoApplication.getAccountInfo().getAccountName());
			else
				setPersonCondition(data.getStringExtra("personId"),data.getStringExtra("personName"));
			break;
		case 11:
			setCustomerCondition(data.getIntExtra("personId", 0),data.getStringExtra("personName"));
			break;
		default:
			break;
		}
		
	}
	protected void reset(){
		opportunityAdvancedSearchProductTypeSpinner.setSelection(0);
		responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
		responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
		opportunityAdvancedSearchResponsiblePersonText.setText(responsiblePersonName);
		opportunityAdvancedSearchCustomerText.setText("");
		customerID=0;
		opportunityAdvancedSearchStartDateText.setText("");
		strOrderStartDate=new StringBuffer();
		opportunityAdvancedSearchEndDateText.setText("");
		strOrderEndDate=new StringBuffer();
	}
	protected void setPersonCondition(String personID,String personName){
		responsiblePersonIDs=personID;
		responsiblePersonName=personName;
		opportunityAdvancedSearchResponsiblePersonText.setText(responsiblePersonName);
	}
	protected void setCustomerCondition(int personID,String personName){
		customerID=personID;
		customerName=personName;
		opportunityAdvancedSearchCustomerText.setText(customerName);
	}
	private Boolean isStartTimeBeyondEndTime(){
		int startYear = startDateList.get("Year");
		int endYear = endDateList.get("Year");
		int startMonth = startDateList.get("Month");
		int endMonth = endDateList.get("Month");
		int startDay = startDateList.get("Day");
		int endDay = endDateList.get("Day");
		if(startYear > endYear)
			return true;
		else if((startYear == endYear) && (startMonth > endMonth)){
			return true;
		}else if((startYear == endYear) && (startMonth == endMonth) && (startDay > endDay)){
			return true;
		}else
			return false;
		
	}
	private void showStartDateDialog() {
		Calendar calendarStart = Calendar.getInstance();
		if (dialogStartDate == null) {
			dialogStartDate = new DatePickerDialog(this,R.style.CustomerAlertDialog, new OnDateSetListener() {
						@Override
						public void onDateSet(DatePicker view, int year,int monthOfYear, int dayOfMonth) {
							strOrderStartDate.replace(0,strOrderStartDate.length(), "");
							strOrderStartDate.append(year);
							strOrderStartDate.append("年");
							strOrderStartDate.append(monthOfYear + 1);
							strOrderStartDate.append("月");
							strOrderStartDate.append(dayOfMonth);
							strOrderStartDate.append("日");

							startDateList.put("Year", year);
							startDateList.put("Month", monthOfYear+1);
							startDateList.put("Day", dayOfMonth);
							
							opportunityAdvancedSearchStartDateText.setText(strOrderStartDate.toString());
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
			dialogEndDate = new DatePickerDialog(this,
					R.style.CustomerAlertDialog, new OnDateSetListener() {

						@Override
						public void onDateSet(DatePicker view, int year,int monthOfYear, int dayOfMonth) {
							strOrderEndDate.replace(0,strOrderEndDate.length(), "");
							strOrderEndDate.append(year);
							strOrderEndDate.append("年");
							strOrderEndDate.append(monthOfYear + 1);
							strOrderEndDate.append("月");
							strOrderEndDate.append(dayOfMonth);
							strOrderEndDate.append("日");

							endDateList.put("Year", year);
							endDateList.put("Month", monthOfYear+1);
							endDateList.put("Day", dayOfMonth);
							opportunityAdvancedSearchEndDateText.setText(strOrderEndDate.toString());
						}
					}, calendarStart.get(Calendar.YEAR),
					calendarStart.get(Calendar.MONTH),
					calendarStart.get(Calendar.DAY_OF_MONTH));
		}
		dialogEndDate.show();
	}
	/**
	 * 将高级筛选条件存到SharePreference
	 * @param currentCondition
	 */
	private void saveConditionToSharePre(OpportunityListBaseConditionInfo currentCondition) {
		// TODO Auto-generated method stub
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(),userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.OpportunityFlag);
		String value = currentCondition.getStringValue();
		sharePreUtil.putAdvancedFilter(key,value);
	}
	
	private OpportunityListBaseConditionInfo getConditionFromSharePre(){
		OpportunityListBaseConditionInfo currentCondition = new OpportunityListBaseConditionInfo();
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(),userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.OpportunityFlag);
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
	/* (non-Javadoc)
	 * 
	 * @see android.app.Activity#onDestroy()
	 */
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		System.gc();
	}
}
