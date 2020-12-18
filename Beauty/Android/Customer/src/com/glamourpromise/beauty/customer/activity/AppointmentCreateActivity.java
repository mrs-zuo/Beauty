package com.glamourpromise.beauty.customer.activity;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.AppointmentListAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AppointmentInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateTimePickDialogUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class AppointmentCreateActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String TASK_NAME = "Task";
	private static final String ADD_SCHEDULE = "AddSchedule";
	private static final int ADD_TASK_FLAG = 1;	
	ArrayList<AppointmentInfo> appointmentInfoList;
	AppointmentListAdapter appointmentListAdapter;
	private TextView appointmentCreateAppointmentDateText,appointmentCreateChooseBranchText,appointmentServiceText,designatedResponsiblePersonText;
	private Button appointmentCreateBtn;
	ImageButton appointmentCreateBackBtn;
	private EditText appointmentRemark;
	RelativeLayout designatedResponsiblePersonRelativelayout;
	private int executorID;
	private String executorNames;
	private String serviceName;
	private String serviceCode;
	private int serviceID,objectID;
	boolean isOldOrder=false;
	private int taskFlag;
	String branchID="0";
	String branchName="";
	private UserInfoApplication userInfo;
	ImageView deleteResponsiblePerson;
	private  int  taskSourceType;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_appointment_create);
		super.setTitle(getString(R.string.appointment_create));
		userInfo = (UserInfoApplication)this.getApplication();
		initView();
	}

	private void initView(){
		appointmentCreateChooseBranchText=(TextView) findViewById(R.id.appointment_create_choose_branch_text);
		appointmentCreateAppointmentDateText=(TextView) findViewById(R.id.appointment_create_appointment_date_text);
		appointmentCreateAppointmentDateText.setOnClickListener(this);
		deleteResponsiblePerson=(ImageView) findViewById(R.id.delete_responsible_person);
		deleteResponsiblePerson.setOnClickListener(this);
		designatedResponsiblePersonText=(TextView) findViewById(R.id.designated_responsible_person_text);
		designatedResponsiblePersonText.setOnClickListener(this);
		appointmentServiceText=(TextView) findViewById(R.id.appointment_service_text);
		appointmentServiceText.setOnClickListener(this);
		appointmentCreateBackBtn=(ImageButton) findViewById(R.id.btn_main_back);
		appointmentCreateBackBtn.setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		appointmentCreateBtn=(Button)findViewById(R.id.order_search_new_make_sure_btn);
		appointmentCreateBtn.setOnClickListener(this);
		appointmentRemark=(EditText) findViewById(R.id.appointment_remark);
		designatedResponsiblePersonRelativelayout=(RelativeLayout) findViewById(R.id.designated_responsible_person_relativelayout);		
		Intent it=getIntent();
		branchID=it.getStringExtra("branchID");
		branchName=it.getStringExtra("branchName");
		setServiceInfo(it.getIntExtra("serviceID", 0),it.getStringExtra("serviceName"),it.getStringExtra("serviceCode"),it.getIntExtra("objectID", 0));
		appointmentCreateChooseBranchText.setText(branchName);
		isOldOrder=it.getBooleanExtra("isOldOrder", false);
		taskSourceType=it.getIntExtra("taskSourceType",1);
	}
	
	private String dataTime(){
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");//设置日期格式
		// new Date()为获取当前系统时间
    	String dataTime=df.format(new Date());
	  return dataTime;
    }
	
	@Override
	public void onClick(View v) {
		super.onClick(v);
		Intent intent=null;
		switch (v.getId()) {
		case R.id.delete_responsible_person:
			setBenefitPersonInfo(0,"到店指定");
			break;
        case R.id.appointment_create_appointment_date_text:
        	DateTimePickDialogUtil dateTimePicKDialog = new DateTimePickDialogUtil(AppointmentCreateActivity.this,dataTime());  
        	dateTimePicKDialog.dateTimePicKDialog(appointmentCreateAppointmentDateText);  
        	setBenefitPersonInfo(0,"到店指定");
			break;
        case R.id.order_search_new_make_sure_btn:
          taskFlag = ADD_TASK_FLAG;
       	  final String remark=appointmentRemark.getText().toString();
       	  String dateText=appointmentCreateAppointmentDateText.getText().toString();
       	  String serviceText=appointmentServiceText.getText().toString();
       	  if(TextUtils.isEmpty(dateText)){
       		  DialogUtil.createShortDialog(AppointmentCreateActivity.this,getString(R.string.appointment_toast_datetext));
       		  return;
       	  }
       	  if(TextUtils.isEmpty(serviceText)){
       		  DialogUtil.createShortDialog(AppointmentCreateActivity.this,getString(R.string.appointment_toast_servicetext));
       		  return;
       	  }
       	  if(!compareDateForAppointment(dateText)){
       		DialogUtil.createShortDialog(AppointmentCreateActivity.this,"预约时间小于当前时间");
       		return;
       	  }
         	taskFlag = ADD_TASK_FLAG;
         	asyncRefrshView(this);
        	break;
        case R.id.designated_responsible_person_text:
			Intent it = new Intent(this, AccountListActivity.class);
			it.putExtra("flag", "2");
			it.putExtra("branchID",Integer.parseInt(branchID));
			it.putExtra("FROM_SOURCE", 1);
			startActivityForResult(it,200);
	        break;
		default:
			break;
		}
	}
	
	public boolean  compareDateForAppointment(String sourceDateStr){
		Date nowDate=new Date();
		SimpleDateFormat simpleDateFormate=new SimpleDateFormat("yyyy-MM-ddHH:mm");
		SimpleDateFormat simpleDateFormate2=new SimpleDateFormat("yyyy/MM/ddHH:mm");
		Date  sourceDate=null;
		try {
			sourceDate=simpleDateFormate.parse(sourceDateStr);
		} catch (ParseException e) {
			try {
				sourceDate=simpleDateFormate2.parse(sourceDateStr);
			} catch (ParseException e1) {
			}
		}
		Date nowDateFormate=null;
		try {
			nowDateFormate=simpleDateFormate.parse(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(nowDate));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return sourceDate.after(nowDateFormate);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	private void setBenefitPersonInfo(int id, String name){
		
		executorID = id;
		executorNames = name;
		if(executorID!=0){
			deleteResponsiblePerson.setVisibility(View.VISIBLE);
		}else{
			designatedResponsiblePersonText.setText(getString(R.string.appointment_to_the_branch_designat_text));
			deleteResponsiblePerson.setVisibility(View.GONE);
		}
		designatedResponsiblePersonText.setText(executorNames);
	}
	protected void setServiceInfo(int serID,String serName,String serCode,int orderObjectID){
		this.serviceID=serID;
		this.serviceName=serName;
		this.serviceCode=serCode;
		this.objectID=orderObjectID;
		appointmentServiceText.setText(serviceName);
    }
	
	@Override
	public WebApiRequest getRequest() {
		final String remark=appointmentRemark.getText().toString();
		JSONObject para = new JSONObject();
		String methodName = "";
		String catoryName="";
		if(taskFlag == ADD_TASK_FLAG){
			methodName=ADD_SCHEDULE;
			catoryName=TASK_NAME;
			try {
				if(executorID!=0){
					para.put("ExecutorID", executorID);
	    		}
				para.put("TaskOwnerID", Integer.parseInt(userInfo.getLoginInformation().getCustomerID()));
				para.put("BranchID", Integer.parseInt(branchID));
				para.put("TaskType", 1);
		    	if(remark!=null && !(("").equals(remark)))
		    		para.put("Remark", remark);
		    	else
		    		para.put("Remark", "");
		    	para.put("TaskScdlStartTime", appointmentCreateAppointmentDateText.getText().toString());
		    	para.put("ReservedServiceCode", Long.parseLong(serviceCode));
		    	if(isOldOrder){
		    		para.put("ReservedOrderID", serviceID);
		    		para.put("ReservedOrderServiceID", objectID);
		    		para.put("ReservedOrderType", 1);
		    	}else{
		    		para.put("ReservedOrderType", 2);
		    		para.put("ReservedServiceCode", Long.parseLong(serviceCode));
		    	}
		    	para.put("TaskSourceType",taskSourceType);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == ADD_TASK_FLAG){
					DialogUtil.createShortDialog(this,"预约成功！");
					Intent it=new Intent(this,NavigationNew.class);
					it.putExtra("NavigationType",1);
					startActivity(it);
					finish();
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			}
		}
		
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}
	 @Override
		protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		  if (resultCode == RESULT_OK) {
				if (requestCode == 200) {
					setBenefitPersonInfo(data.getIntExtra("AccountID",0), data.getStringExtra("AccountName"));
				}
		   }
		}
	
}
