/**
 * OrderSearchNewActivity.java
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
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Calendar;
import java.util.HashMap;

import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderListBaseConditionInfo;
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
public class OrderSearchNewActivity extends Activity implements OnClickListener{
	private ImageButton  orderSearchNewBackButton;
	private Spinner      orderSearchNewOrderSourceSpinner,orderSearchNewOrderClassifySpinner,orderSearchNewOrderStatusSpinner,orderSearchNewOrderPayStatusSpinner;
	private TextView     orderSearchNewResponsiblePersonText,orderSearchNewCustomerText,orderSearchNewStartDateText,orderSearchNewEndDateText;
	private int  customerID=0,lastOrderSource=-1,lastOrderClassify=-1,lastOrderStatus=-1,lastOrderPayStatus=-1;
	private String responsiblePersonName="",customerName="";
	private HashMap<String, Integer> startDateList,endDateList;
	private DatePickerDialog dialogStartDate,dialogEndDate;
	private StringBuffer strOrderStartDate,strOrderEndDate;
	private UserInfoApplication userinfoApplication;
	private OrderListBaseConditionInfo orderListBaseConditionInfo;
	private int  filterByDateFlag=0,userRole;
	private View orderSearchNewCustomerDivideView;
	private String responsiblePersonIDs="";
	private RelativeLayout orderSearchNewCustomerRelativelayout;
	private Button  orderSearchNewResetButton,orderSearchNewMakeSureButton;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_order_search_new);
		orderSearchNewBackButton=(ImageButton) findViewById(R.id.order_search_new_back_btn);
		orderSearchNewBackButton.setOnClickListener(this);
		orderSearchNewResetButton=(Button)findViewById(R.id.order_search_new_reset_btn);
		orderSearchNewResetButton.setOnClickListener(this);
		orderSearchNewMakeSureButton=(Button)findViewById(R.id.order_search_new_make_sure_btn);
		orderSearchNewMakeSureButton.setOnClickListener(this);
		orderSearchNewOrderSourceSpinner=(Spinner)findViewById(R.id.order_search_new_order_source_spinner);
		orderSearchNewOrderClassifySpinner=(Spinner)findViewById(R.id.order_search_new_order_classify_spinner);
		orderSearchNewOrderStatusSpinner=(Spinner) findViewById(R.id.order_search_new_order_status_spinner);
		orderSearchNewOrderPayStatusSpinner=(Spinner) findViewById(R.id.order_search_new_order_pay_status_spinner);
		String[] orderSourceArray=new String[]{"全部","商家","顾客","预约","抢购","导入"};
		ArrayAdapter<String> orderSourceAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,orderSourceArray);
		orderSourceAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		orderSearchNewOrderSourceSpinner.setAdapter(orderSourceAdapter);
		String[] orderClassifyArray=new String[]{"全部","服务","商品"};
		ArrayAdapter<String> orderClassifyAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,orderClassifyArray);
		orderClassifyAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		orderSearchNewOrderClassifySpinner.setAdapter(orderClassifyAdapter);
		String[] orderStatusArray=new String[]{"全部","未完成","已完成","已终止","已取消"};
		ArrayAdapter<String> orderStatusAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,orderStatusArray);
		orderStatusAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		orderSearchNewOrderStatusSpinner.setAdapter(orderStatusAdapter);
		String[] orderPayStatusArray=new String[]{"全部","未支付","部分付","已支付","已退款","免支付"};
		ArrayAdapter<String> orderPayStatusAdapter=new ArrayAdapter<String>(this,R.xml.spinner_checked_text,orderPayStatusArray);
		orderPayStatusAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		orderSearchNewOrderPayStatusSpinner.setAdapter(orderPayStatusAdapter);
		orderSearchNewResponsiblePersonText=(TextView) findViewById(R.id.order_search_new_responsible_person_text);
		orderSearchNewResponsiblePersonText.setOnClickListener(this);
		orderSearchNewCustomerText=(TextView) findViewById(R.id.order_search_new_customer_text);
		orderSearchNewCustomerText.setOnClickListener(this);
		orderSearchNewStartDateText=(TextView) findViewById(R.id.order_search_new_order_start_date_text);
		orderSearchNewStartDateText.setOnClickListener(this);
		orderSearchNewEndDateText=(TextView) findViewById(R.id.order_search_new_order_end_date_text);
		orderSearchNewEndDateText.setOnClickListener(this);
		strOrderStartDate = new StringBuffer("");
		strOrderEndDate = new StringBuffer("");
		startDateList = new HashMap<String, Integer>();
		endDateList = new HashMap<String, Integer>();
		orderSearchNewCustomerDivideView=findViewById(R.id.order_search_new_customer_divide_view);
		orderSearchNewCustomerRelativelayout=(RelativeLayout) findViewById(R.id.order_search_new_customer_relativelayout);
		userinfoApplication=UserInfoApplication.getInstance();
		userRole=getIntent().getIntExtra("userRole", Constant.USER_ROLE_CUSTOMER);
		if(userRole==Constant.USER_ROLE_BUSINESS){
			orderListBaseConditionInfo = getConditionFromSharePre();
			//设置上次选择的条件
			setLastSelectCondition();
		}
		//界面隐藏顾客选择
		else if(userRole==Constant.USER_ROLE_CUSTOMER){
			Intent intent=getIntent();
			lastOrderSource=intent.getIntExtra("ORDER_SOURCE",-1);
			lastOrderClassify=intent.getIntExtra("ORDER_TYPE", -1);
			lastOrderStatus=intent.getIntExtra("ORDER_STATUS",-1);
			int orderSourceSprinnerPosition=0;
			int orderClassifySprinnerPosition=0;
			int orderStatusSpinnerPosition=0;
			if(lastOrderSource==Constant.ORDER_SOURCE_COMPANY){
				orderSourceSprinnerPosition=1;
			}
			else if(lastOrderSource==Constant.ORDER_SOURCE_CUSTOMER){
				orderSourceSprinnerPosition=2;
			}
			else if(lastOrderSource==Constant.ORDER_SOURCE_APPOINTMENT){
				orderSourceSprinnerPosition=3;
			}
			else if(lastOrderSource==Constant.ORDER_SOURCE_PROMOTION){
				orderSourceSprinnerPosition=4;
			}
			else if(lastOrderSource==Constant.ORDER_SOURCE_IMPORT){
				orderSourceSprinnerPosition=5;
			}
			if(lastOrderClassify==Constant.SERVICE_TYPE){
				orderClassifySprinnerPosition=1;
			}
			else if(lastOrderClassify==Constant.COMMODITY_TYPE){
				orderClassifySprinnerPosition=2;
			}
			//订单状态选择的
			if(lastOrderStatus==Constant.ORDER_STATUS_PROCEED){
				//未完成
				orderStatusSpinnerPosition=1;
			}
			else if(lastOrderStatus==Constant.ORDER_STATUS_COMPLETE){
				//已完成
				orderStatusSpinnerPosition=2;
			}
			else if(lastOrderStatus==Constant.ORDER_STATUS_CANCEL){
				//已取消
				orderStatusSpinnerPosition=3;
			}
			else if(lastOrderStatus==Constant.ORDER_STATUS_STOP){
				//已终止
				orderStatusSpinnerPosition=4;
			}
			orderSearchNewOrderSourceSpinner.setSelection(orderSourceSprinnerPosition);
			orderSearchNewOrderClassifySpinner.setSelection(orderClassifySprinnerPosition);
			orderSearchNewOrderStatusSpinner.setSelection(orderStatusSpinnerPosition);
			orderSearchNewCustomerDivideView.setVisibility(View.GONE);
			orderSearchNewCustomerRelativelayout.setVisibility(View.GONE);
			customerID=userinfoApplication.getSelectedCustomerID();
		}
		
	}
	/**
	 * 设置上次选择的条件
	 */
	private void setLastSelectCondition() {
		if (orderListBaseConditionInfo != null) {
			int orderSourceSprinnerPosition=0;
			//订单分类选择的是服务或者商品
			int orderClassifySprinnerPosition=0;
			int orderStatusSpinnerPosition=0;
			int orderPayStatusSpinnerPosition=0;
			if(orderListBaseConditionInfo.getOrderSource()==Constant.ORDER_SOURCE_COMPANY){
				orderSourceSprinnerPosition=1;
			}
			else if(orderListBaseConditionInfo.getOrderSource()==Constant.ORDER_SOURCE_CUSTOMER){
				orderSourceSprinnerPosition=2;
			}
			else if(orderListBaseConditionInfo.getOrderSource()==Constant.ORDER_SOURCE_APPOINTMENT){
				orderSourceSprinnerPosition=3;
			}
			else if(orderListBaseConditionInfo.getOrderSource()==Constant.ORDER_SOURCE_PROMOTION){
				orderSourceSprinnerPosition=4;
			}
			else if(orderListBaseConditionInfo.getOrderSource()==Constant.ORDER_SOURCE_IMPORT){
				orderSourceSprinnerPosition=5;
			}
			
			if(orderListBaseConditionInfo.getProductType()==Constant.SERVICE_TYPE){
				orderClassifySprinnerPosition=1;
			}
			else if(orderListBaseConditionInfo.getProductType()==Constant.COMMODITY_TYPE){
				orderClassifySprinnerPosition=2;
			}
			//订单状态选择的
			if(orderListBaseConditionInfo.getStatus()==Constant.ORDER_STATUS_PROCEED){
				//未完成
				orderStatusSpinnerPosition=1;
			}
			else if(orderListBaseConditionInfo.getStatus()==Constant.ORDER_STATUS_STOP){
				//已终止
				orderStatusSpinnerPosition=3;
			}
			else if(orderListBaseConditionInfo.getStatus()==Constant.ORDER_STATUS_COMPLETE){
				//已完成
				orderStatusSpinnerPosition=2;
			}
			else if(orderListBaseConditionInfo.getStatus()==Constant.ORDER_STATUS_CANCEL){
				//已取消
				orderStatusSpinnerPosition=4;
			}
			//订单支付状态
			if(orderListBaseConditionInfo.getPaymentStatus()==Constant.ORDER_PAY_STATUS_NO_PAIED){
				//未支付
				orderPayStatusSpinnerPosition=1;
			}
			else if(orderListBaseConditionInfo.getPaymentStatus()==Constant.ORDER_PAY_STATUS_PART_PAIED){
				//部分付
				orderPayStatusSpinnerPosition=2;
			}
			else if(orderListBaseConditionInfo.getPaymentStatus()==Constant.ORDER_PAY_STATUS_ALL_PAIED){
				//已支付
				orderPayStatusSpinnerPosition=3;
			}
			else if(orderListBaseConditionInfo.getPaymentStatus()==Constant.ORDER_PAY_STATUS_REFUND){
				//已退款
				orderPayStatusSpinnerPosition=4;
			}
			else if(orderListBaseConditionInfo.getPaymentStatus()==Constant.ORDER_PAY_STATUS_NO_NEED_PAIED){
				//免支付
				orderPayStatusSpinnerPosition=5;
			}
			orderSearchNewOrderSourceSpinner.setSelection(orderSourceSprinnerPosition);
			orderSearchNewOrderClassifySpinner.setSelection(orderClassifySprinnerPosition);
			orderSearchNewOrderStatusSpinner.setSelection(orderStatusSpinnerPosition);
			orderSearchNewOrderPayStatusSpinner.setSelection(orderPayStatusSpinnerPosition);
			responsiblePersonIDs = orderListBaseConditionInfo.getResponsiblePersonID();
			customerID = orderListBaseConditionInfo.getCustomerID();
			responsiblePersonName = orderListBaseConditionInfo.getResponsiblePersonName();
			customerName = orderListBaseConditionInfo.getCustomerName();
			if(responsiblePersonIDs!=null && !("").equals(responsiblePersonIDs)){
				orderSearchNewResponsiblePersonText.setText(responsiblePersonName);
			}
			else{
				responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
				responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
				orderSearchNewResponsiblePersonText.setText(responsiblePersonName);
			}
			if(customerID!=0){
				orderSearchNewCustomerText.setText(customerName);
			}
			filterByDateFlag = orderListBaseConditionInfo.getFilterByTimeFlag();
			if(filterByDateFlag==1){
				orderSearchNewStartDateText.setText(orderListBaseConditionInfo.getStartDate());
				orderSearchNewEndDateText.setText(orderListBaseConditionInfo.getEndDate());
				strOrderStartDate.append(orderListBaseConditionInfo.getStartDate());
				strOrderEndDate.append(orderListBaseConditionInfo.getEndDate());
				startDateList=orderListBaseConditionInfo.getStartTimeList();
				endDateList=orderListBaseConditionInfo.getEndTimeList();
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
		case R.id.order_search_new_back_btn:
			this.finish();
			break;
		case R.id.order_search_new_make_sure_btn:
			int orderSourceSprinnerPosition=orderSearchNewOrderSourceSpinner.getSelectedItemPosition();
			//订单分类
			int orderClassifySprinnerPosition=orderSearchNewOrderClassifySpinner.getSelectedItemPosition();
			int orderStatusSpinnerPosition=orderSearchNewOrderStatusSpinner.getSelectedItemPosition();
			int orderPayStatusSpinnerPosition=orderSearchNewOrderPayStatusSpinner.getSelectedItemPosition();
			
			if(orderSourceSprinnerPosition==1){
				lastOrderSource=Constant.ORDER_SOURCE_COMPANY;
			}
			else if(orderSourceSprinnerPosition==2){
				lastOrderSource=Constant.ORDER_SOURCE_CUSTOMER;
			}
			else if(orderSourceSprinnerPosition==3){
				lastOrderSource=Constant.ORDER_SOURCE_APPOINTMENT;
			}
			else if(orderSourceSprinnerPosition==4){
				lastOrderSource=Constant.ORDER_SOURCE_PROMOTION;
			}
			else if(orderSourceSprinnerPosition==5){
				lastOrderSource=Constant.ORDER_SOURCE_IMPORT;
			}
			//订单分类选择的是服务或者商品
			if(orderClassifySprinnerPosition==1){
				lastOrderClassify=Constant.SERVICE_TYPE;
			}
			else if(orderClassifySprinnerPosition==2){
				lastOrderClassify=Constant.COMMODITY_TYPE;
			}
			//订单状态选择的
			if(orderStatusSpinnerPosition==1){
				//未完成
				lastOrderStatus=Constant.ORDER_STATUS_PROCEED;
			}
			else if(orderStatusSpinnerPosition==2){
				//已完成
				lastOrderStatus=Constant.ORDER_STATUS_COMPLETE;
			}
			else if(orderStatusSpinnerPosition==3){
				//已终止
				lastOrderStatus=Constant.ORDER_STATUS_STOP;
			}
			else if(orderStatusSpinnerPosition==4){
				//已取消
				lastOrderStatus=Constant.ORDER_STATUS_CANCEL;
			}
			//订单支付状态
			if(orderPayStatusSpinnerPosition==1){
				//未支付
				lastOrderPayStatus=Constant.ORDER_PAY_STATUS_NO_PAIED;
			}
			else if(orderPayStatusSpinnerPosition==2){
				//部分付
				lastOrderPayStatus=Constant.ORDER_PAY_STATUS_PART_PAIED;
			}
			else if(orderPayStatusSpinnerPosition==3){
				//已支付
				lastOrderPayStatus=Constant.ORDER_PAY_STATUS_ALL_PAIED;
			}
			else if(orderPayStatusSpinnerPosition==4){
				//已退款
				lastOrderPayStatus=Constant.ORDER_PAY_STATUS_REFUND;
			}
			else if(orderPayStatusSpinnerPosition==5){
				//免支付
				lastOrderPayStatus=Constant.ORDER_PAY_STATUS_NO_NEED_PAIED;
			}
			orderListBaseConditionInfo=new OrderListBaseConditionInfo();
			orderListBaseConditionInfo.setAccountID(userinfoApplication.getAccountInfo().getAccountId());
			orderListBaseConditionInfo.setBranchID(userinfoApplication.getAccountInfo().getBranchId());
			if(responsiblePersonIDs!=null && !("").equals(responsiblePersonIDs)){
				orderListBaseConditionInfo.setResponsiblePersonIDs(responsiblePersonIDs);
				orderListBaseConditionInfo.setResponsiblePersonName(responsiblePersonName);
			}
			if(customerID!=0){
				orderListBaseConditionInfo.setCustomerID(customerID);
				orderListBaseConditionInfo.setCustomerName(customerName);
			}
			orderListBaseConditionInfo.setCreateTime("");
			orderListBaseConditionInfo.setPageIndex(1);
			orderListBaseConditionInfo.setPageSize(10);
			orderListBaseConditionInfo.setOrderSource(lastOrderSource);
			orderListBaseConditionInfo.setProductType(lastOrderClassify);
			orderListBaseConditionInfo.setPaymentStatus(lastOrderPayStatus);
			orderListBaseConditionInfo.setStatus(lastOrderStatus);
			orderListBaseConditionInfo.setIsBusiness(1);
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
						orderListBaseConditionInfo.setFilterByTimeFlag(1);
						orderListBaseConditionInfo.setStartDate(startDate);
						orderListBaseConditionInfo.setEndDate(endDate);
						orderListBaseConditionInfo.setStartTimeList(startDateList);
						orderListBaseConditionInfo.setEndTimeList(endDateList);
					}
				}
			if(isCondition){
				if(userRole==Constant.USER_ROLE_BUSINESS){
					//将筛选条件写入到本地本件中
					saveConditionToSharePre(orderListBaseConditionInfo);
				}
				Intent data=new Intent();
				data.putExtra("baseCondition",orderListBaseConditionInfo);
				setResult(1,data);
				finish();
			}
			break;
		case R.id.order_search_new_reset_btn:
			reset();
			break;
		case R.id.order_search_new_responsible_person_text:
			intent = new Intent(this, ChoosePersonActivity.class);
			intent.putExtra("personRole", "Doctor");
			intent.putExtra("checkModel", "Multi");
			//如果当前账户没有查看本店订单的权限 只需要列出当前账号下的下级账号列表
			if(userinfoApplication.getAccountInfo().getAuthAllTheBranchOrderRead()==0 && userRole==Constant.USER_ROLE_BUSINESS)
				intent.putExtra("getSubAccount",true);
			intent.putExtra("selectPersonIDs",responsiblePersonIDs);
			startActivityForResult(intent, 10);
			break;
		case R.id.order_search_new_customer_text:
			intent = new Intent(this, ChoosePersonActivity.class);
			intent.putExtra("personRole", "Customer");
			intent.putExtra("checkModel", "Multi");
			intent.putExtra("messageType", "OrderFilter");
			JSONArray customerJsonArray=new JSONArray();
			customerJsonArray.put(customerID);
			intent.putExtra("selectPersonIDs",customerJsonArray.toString());
			startActivityForResult(intent,11);
			break;
		case R.id.order_search_new_order_start_date_text:
			showStartDateDialog();
			break;
		case R.id.order_search_new_order_end_date_text:
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
			if((data.getStringExtra("personName")==null || data.getStringExtra("personName").equals("")) && userRole==Constant.USER_ROLE_BUSINESS){
				setPersonCondition(new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString(),((UserInfoApplication)getApplication()).getAccountInfo().getAccountName());
			}
			else
				setPersonCondition(data.getStringExtra("personId"),data.getStringExtra("personName"));
			break;
		case 11:
			setCustomerCondition(data.getIntExtra("personId",0),data.getStringExtra("personName"));
			break;
		default:
			break;
		}
		
	}
	protected void reset(){
		orderSearchNewOrderSourceSpinner.setSelection(0);
		orderSearchNewOrderClassifySpinner.setSelection(0);
		orderSearchNewOrderStatusSpinner.setSelection(0);
		orderSearchNewOrderPayStatusSpinner.setSelection(0);	
		if(userRole==Constant.USER_ROLE_BUSINESS){
			orderSearchNewCustomerText.setText("");
			customerID=0;
			responsiblePersonIDs=new JSONArray().put(((UserInfoApplication)getApplication()).getAccountInfo().getAccountId()).toString();
			responsiblePersonName=((UserInfoApplication)getApplication()).getAccountInfo().getAccountName();
			orderSearchNewResponsiblePersonText.setText(responsiblePersonName);
		}
		else{
			orderSearchNewResponsiblePersonText.setText("");
			responsiblePersonIDs="";
		}
		orderSearchNewStartDateText.setText("");
		strOrderStartDate=new StringBuffer();
		orderSearchNewEndDateText.setText("");
		strOrderEndDate=new StringBuffer();
	}
	protected void setPersonCondition(String personID,String personName){
			responsiblePersonIDs=personID;
			responsiblePersonName=personName;
			orderSearchNewResponsiblePersonText.setText(responsiblePersonName);
	}
	protected void setCustomerCondition(int personID,String personName){
			customerID=personID;
			customerName=personName;
			orderSearchNewCustomerText.setText(customerName);
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
							
							orderSearchNewStartDateText.setText(strOrderStartDate.toString());
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
							orderSearchNewEndDateText.setText(strOrderEndDate.toString());
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
	private void saveConditionToSharePre(OrderListBaseConditionInfo currentCondition) {
		// TODO Auto-generated method stub
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(),userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.OrderFlag);
		String value = currentCondition.getStringValue();
		sharePreUtil.putAdvancedFilter(key,value);
	}
	private OrderListBaseConditionInfo getConditionFromSharePre(){
		OrderListBaseConditionInfo currentCondition = new OrderListBaseConditionInfo();
		SharedPreferenceUtil sharePreUtil = SharedPreferenceUtil.getSharePreferenceInstance(getApplicationContext());
		String key = sharePreUtil.getAdvancedConditionKey(userinfoApplication.getAccountInfo().getAccountId(),userinfoApplication.getAccountInfo().getBranchId(), SharedPreferenceUtil.AdvancedFilterFlag.OrderFlag);
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
