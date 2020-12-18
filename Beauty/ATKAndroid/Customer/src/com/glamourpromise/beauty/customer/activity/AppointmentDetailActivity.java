package com.glamourpromise.beauty.customer.activity;
import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AppointmentDetailInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateTimePickDialogUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class AppointmentDetailActivity extends BaseActivity implements OnClickListener,OnItemClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Task";
	private static final String GET_PROMOTION_DETAIL = "GetScheduleDetail";
	private static final String GET_PROMOTION_CANCEL = "CancelSchedule";
	private static final String GET_PROMOTION_EDIT = "EditTask";
	private static final int GET_PROMOTION_DETAIL_FLAG = 1;
	private static final int GET_PROMOTION_CANCEL_FLAG = 2;
	private static final int GET_PROMOTION_EDIT_FLAG = 3;
	private int taskFlag;
	private Button appointmentDetailCancel,appointmentDetailConfirm,appointmentDetailEdit;
	private TextView appointmentDetailNum,appointmentDetailBranchText,appointmentDetailDateText,appointmentDetailServiceText,designatedResponsiblePersonText;
	private TextView appointmentDetailAppointmentStatusText,appointmentDetailOrderNumText,appointmentDetailOrderProductNameText,appointmentDetailOrderPriceText;
	private EditText appointmentRemark;
	private RelativeLayout appointmentDetailOrderRelativelayout;
	TableLayout orderTablelayout;
	ImageButton appointmentDetailOrderIcon;
	long taskID;
	private AppointmentDetailInfo appointmentDetailInfo;
	TableLayout appointmentRemarkTableLayout;
	private int executorID;
	private String executorNames;
	ImageView deleteResponsiblePerson;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_appointment_detail);
		super.setTitle(getString(R.string.appointment_detail_title));
		Intent it=getIntent();
		taskID=it.getLongExtra("taskID", 0);
		initView();
	}

	private void initView(){
		appointmentDetailNum=(TextView) findViewById(R.id.appointment_detail_num);
		appointmentDetailBranchText=(TextView) findViewById(R.id.appointment_detail_branch_text);
		appointmentDetailDateText=(TextView) findViewById(R.id.appointment_detail_date_text);
		appointmentDetailDateText.setOnClickListener(this);
		deleteResponsiblePerson=(ImageView) findViewById(R.id.delete_responsible_person);
		deleteResponsiblePerson.setOnClickListener(this);
		appointmentDetailServiceText=(TextView) findViewById(R.id.appointment_detail_service_text);
		appointmentRemark=(EditText) findViewById(R.id.appointment_remark);
		appointmentRemarkTableLayout = (TableLayout) findViewById(R.id.appointment_remark_tablelayout);
		appointmentDetailCancel=(Button) findViewById(R.id.appointment_detail_cancel);
		appointmentDetailCancel.setOnClickListener(this);
		appointmentDetailConfirm=(Button) findViewById(R.id.appointment_detail_confirm);
		appointmentDetailConfirm.setOnClickListener(this);
		appointmentDetailEdit=(Button) findViewById(R.id.appointment_detail_edit);
		appointmentDetailEdit.setOnClickListener(this);
		appointmentDetailAppointmentStatusText=(TextView) findViewById(R.id.appointment_detail_status_text);
		appointmentDetailOrderNumText=(TextView) findViewById(R.id.appointment_detail_order_num_text);
		appointmentDetailOrderProductNameText=(TextView) findViewById(R.id.appointment_detail_order_product_name_text);
		appointmentDetailOrderPriceText=(TextView) findViewById(R.id.appointment_detail_order_price_text);
		designatedResponsiblePersonText=(TextView) findViewById(R.id.designated_responsible_person_text);
		designatedResponsiblePersonText.setOnClickListener(this);
		designatedResponsiblePersonText.setEnabled(false);
		orderTablelayout=(TableLayout) findViewById(R.id.order_tablelayout);
		appointmentDetailOrderIcon=(ImageButton) findViewById(R.id.appointment_detail_order_icon);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		appointmentDetailOrderRelativelayout= (RelativeLayout) findViewById(R.id.appointment_detail_order_relativelayout);
		appointmentDetailOrderRelativelayout.setOnClickListener(this);
		taskFlag = GET_PROMOTION_DETAIL_FLAG;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	private void initData(){
		//填充数据
				if(appointmentDetailInfo!=null){
					if(appointmentDetailInfo.getOrderBaseInfo().getOrderObjectIDInt()>0)
						orderTablelayout.setVisibility(View.VISIBLE);
					else
						orderTablelayout.setVisibility(View.GONE);
					if(appointmentDetailInfo.getOrderNumber()!=null && !(("").equals(appointmentDetailInfo.getOrderNumber()))){
						appointmentDetailOrderNumText.setText(appointmentDetailInfo.getOrderNumber());
						appointmentDetailOrderIcon.setVisibility(View.VISIBLE);
					}else
						appointmentDetailOrderIcon.setVisibility(View.GONE);
					appointmentDetailOrderProductNameText.setText(appointmentDetailInfo.getOrderBaseInfo().getProductName());
					appointmentDetailOrderPriceText.setText(NumberFormatUtil.StringFormatToString(this,appointmentDetailInfo.getOrderBaseInfo().getTotalSalePrice()));
					appointmentDetailAppointmentStatusText.setText(getTaskStatus(appointmentDetailInfo.getTaskStatus()));
					appointmentDetailNum.setText(String.valueOf(appointmentDetailInfo.getTaskID()));
					appointmentDetailBranchText.setText(appointmentDetailInfo.getOrderBaseInfo().getBranchName());
					appointmentDetailDateText.setText(appointmentDetailInfo.getTaskScdlStartTime());
					appointmentDetailServiceText.setText(appointmentDetailInfo.getOrderBaseInfo().getProductName());
					if(appointmentDetailInfo.getOrderBaseInfo().getResponsiblePersonName()!=null && !(("").equals(appointmentDetailInfo.getOrderBaseInfo().getResponsiblePersonName()))){
						designatedResponsiblePersonText.setText(appointmentDetailInfo.getOrderBaseInfo().getResponsiblePersonName());
					}else{
						designatedResponsiblePersonText.setText(getString(R.string.appointment_to_the_branch_designat_text));
					}
					if(appointmentDetailInfo.getRemark()==null || ("").equals(appointmentDetailInfo.getRemark())){
						appointmentRemark.setHint("");
					}else{
						appointmentRemark.setText(appointmentDetailInfo.getRemark());
					}
					
					appointmentRemark.setEnabled(false);
					appointmentDetailDateText.setEnabled(false);
					appointmentRemark.setTextColor(Color.BLACK);
					appointmentDetailDateText.setTextColor(Color.BLACK);
					//预约状态控制权限
					if(appointmentDetailInfo.getTaskStatus()==1){
					    appointmentDetailEdit.setVisibility(View.VISIBLE);
					    appointmentDetailCancel.setVisibility(View.VISIBLE);
					}else if(appointmentDetailInfo.getTaskStatus()==2){
						appointmentDetailEdit.setVisibility(View.GONE);
						appointmentDetailCancel.setVisibility(View.VISIBLE);
					}else{
						appointmentDetailEdit.setVisibility(View.GONE);
						appointmentDetailCancel.setVisibility(View.GONE);
					}
				}
	}
	private String dataTime(){
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");//设置日期格式
		System.out.println();// new Date()为获取当前系统时间
    	String dataTime=df.format(new Date());
	  return dataTime;
    }
	@Override
	public void onClick(View view) {
		super.onClick(view);
		switch (view.getId()) {
		case R.id.delete_responsible_person:
			setBenefitPersonInfo(0,"到店指定");
			break;
		case R.id.designated_responsible_person_text:
			Intent it = new Intent(this, AccountListActivity.class);
			it.putExtra("flag", "2");
			it.putExtra("branchID",appointmentDetailInfo.getBranchID());
			it.putExtra("FROM_SOURCE", 1);
			startActivityForResult(it,200);
	        break;
		case R.id.appointment_detail_order_relativelayout:
			Intent destIntent = null;
			destIntent = new Intent(this,ServcieOrderDetailActivity.class);
			Bundle mBundle = new Bundle();
			mBundle.putSerializable("OrderItem",(Serializable) appointmentDetailInfo.getOrderBaseInfo());
			destIntent.putExtras(mBundle);
			startActivity(destIntent);
			break;
		case R.id.appointment_detail_cancel:
			appointmentCancel();
			break;
        case R.id.appointment_detail_edit:
        	appointmentDetailDateText.setEnabled(true);
			appointmentDetailDateText.setTextColor(Color.GRAY);
			appointmentRemarkTableLayout.setVisibility(View.VISIBLE);
			appointmentRemark.setEnabled(true);
			appointmentRemark.setTextColor(Color.GRAY);
			if(appointmentDetailInfo.getRemark()==null || ("").equals(appointmentDetailInfo.getRemark())){
			   appointmentRemark.setHint(R.string.please_input_customer_appointment_remark);;
			}
			appointmentDetailConfirm.setVisibility(View.VISIBLE);
			appointmentDetailEdit.setVisibility(View.GONE);
			appointmentDetailCancel.setVisibility(View.GONE);
			if(appointmentDetailInfo.getAccountID()!=0){
				deleteResponsiblePerson.setVisibility(View.VISIBLE);
			}
			designatedResponsiblePersonText.setTextColor(Color.GRAY);
			designatedResponsiblePersonText.setEnabled(true);
			break;
		case R.id.appointment_detail_confirm:
			appointmentConfirm();
			break;
		case R.id.appointment_detail_date_text:
			DateTimePickDialogUtil dateTimePicKDialog = new DateTimePickDialogUtil(AppointmentDetailActivity.this,dataTime());  
        	dateTimePicKDialog.dateTimePicKDialog(appointmentDetailDateText);  
        	setBenefitPersonInfo(0,"到店指定");
			break;
		default:
			break;
		}
	}
	
	private void appointmentCancel() {
		AlertDialog paymentDialog = new AlertDialog.Builder(this)
				.setTitle("是否取消预约？")
				.setPositiveButton(this.getString(R.string.confirm),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface arg0, int arg1) {
									taskFlag = GET_PROMOTION_CANCEL_FLAG;
									asyncRefrshView(AppointmentDetailActivity.this);
							}
						})
				.setNegativeButton(this.getString(R.string.cancel), null)
				.show();
		paymentDialog.setCancelable(false);
	}
	
	private void appointmentConfirm() {
		AlertDialog paymentDialog = new AlertDialog.Builder(this)
				.setTitle("是否确认编辑？")
				.setPositiveButton(this.getString(R.string.confirm),
						new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface arg0, int arg1) {
								if(!compareDateForAppointment(appointmentDetailDateText.getText().toString())){
						       		DialogUtil.createShortDialog(AppointmentDetailActivity.this,"预约时间小于当前时间");
						       		return;
						       	  }else{
						       		  taskFlag = GET_PROMOTION_EDIT_FLAG;
						       		  asyncRefrshView(AppointmentDetailActivity.this);
						       	  }
							}
						})
				.setNegativeButton(this.getString(R.string.cancel), null)
				.show();
		paymentDialog.setCancelable(false);
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
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		String methodName = "";
		if(taskFlag == GET_PROMOTION_DETAIL_FLAG){
			methodName=GET_PROMOTION_DETAIL;
			try {
				para.put("LongID",taskID);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			
		}else if(taskFlag == GET_PROMOTION_CANCEL_FLAG){
			methodName=GET_PROMOTION_CANCEL;
			try {
				para.put("LongID",appointmentDetailInfo.getTaskID());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}else if(taskFlag == GET_PROMOTION_EDIT_FLAG){
			methodName=GET_PROMOTION_EDIT;
			try {
				para.put("ExecutorID",appointmentDetailInfo.getAccountID());
				para.put("TaskScdlStartTime",appointmentDetailDateText.getText().toString());
				para.put("Remark",appointmentRemark.getText().toString());
				para.put("ID",appointmentDetailInfo.getTaskID());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == GET_PROMOTION_DETAIL_FLAG){
					appointmentDetailInfo=AppointmentDetailInfo.parseListByJson(response.getStringData());
					initData();
				}else if(taskFlag == GET_PROMOTION_CANCEL_FLAG){
					Intent it=new Intent(this,NavigationNew.class);
					Bundle bu=new Bundle();
					bu.putInt("FROM_SOURCE", 1);
					it.putExtras(bu);
					startActivity(it);
					this.finish();
				}else if(taskFlag == GET_PROMOTION_EDIT_FLAG){
					appointmentRemark.setEnabled(false);
					appointmentDetailDateText.setEnabled(false);
					appointmentRemark.setTextColor(Color.BLACK);
					appointmentDetailDateText.setTextColor(Color.BLACK);
					appointmentDetailConfirm.setVisibility(View.GONE);
					designatedResponsiblePersonText.setTextColor(Color.BLACK);
					designatedResponsiblePersonText.setEnabled(false);
					appointmentDetailCancel.setVisibility(View.VISIBLE);
					appointmentDetailEdit.setVisibility(View.VISIBLE);
					deleteResponsiblePerson.setVisibility(View.GONE);
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
				break;
			}
		}
	}
	public String getTaskStatus(int taskStatus) {
		String taskStatusString = "未知状态";
		switch (taskStatus) {
		case 1:
			taskStatusString = "待确认";
			break;
		case 2:
			taskStatusString = "已确认";
			break;
		case 3:
			taskStatusString = "已执行";
			break;
		case 4:
			taskStatusString = "已取消";
			break;
		}
		return taskStatusString;
	}
	@Override
	public void parseData(WebApiResponse response) {
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		
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
		appointmentDetailInfo.setAccountID(id);
		designatedResponsiblePersonText.setText(executorNames);
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
