package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.GetScheduleDetail;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;

public class ScheduleDetailActivity extends BaseActivity implements OnClickListener, IConnectTask {
	public final static String CATEGORY_NAME = "Task";
	public final static String GET_SCHEDULE_DETAIL = "GetScheduleDetail";
	private GetScheduleDetail scheduleDetail = new GetScheduleDetail();

	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_schedule_detail);
		super.setTitle(getString(R.string.schedule_detail_title));
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub

	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("LongID", getIntent().getStringExtra("TaskID"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				CATEGORY_NAME, GET_SCHEDULE_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,
				GET_SCHEDULE_DETAIL, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				scheduleDetail.parseByJson(response.getStringData());
				initAllCell(scheduleDetail);
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.btn_main_home:
			
			break;
		case R.id.btn_main_back:
			finish();
			break;
		default:
			break;
		}
		;
	}

	private void initAllCell(GetScheduleDetail schedule) {
		TextView longID = (TextView) findViewById(R.id.activity_schedule_detail_long_id_content);
		TextView status = (TextView) findViewById(R.id.activity_schedule_detail_status_content);
		TextView branchName = (TextView) findViewById(R.id.activity_schedule_detail_branch_name_content);
		TextView toBranchTime = (TextView) findViewById(R.id.activity_schedule_detail_to_branch_time_content);
		TextView scheduleDetail = (TextView) findViewById(R.id.activity_schedule_detail_content_detail_content);
		TextView asignResponsiblePersonStatus = (TextView) findViewById(R.id.activity_schedule_detail_asignment_responsible_person_for_sure_content);
		TextView asignResponsiblePersonName = (TextView) findViewById(R.id.activity_schedule_asignment_responsible_person_name_content);
		LinearLayout asignmentDetailLayout = (LinearLayout) findViewById(R.id.activity_schedule_detail_asignment_concealable_linear_layout);

		TableLayout remarkLayout = (TableLayout) findViewById(R.id.activity_schedule_detail_remark_layout);
		TextView remarkContent = (TextView) findViewById(R.id.activity_schedule_detail_remark);
		if (schedule.getRemark().equals(""))
			remarkLayout.setVisibility(View.GONE);
		else {
			remarkLayout.setVisibility(View.VISIBLE);
			remarkContent.setText(schedule.getRemark());
		}

		longID.setText(schedule.getTaskID());
		status.setText(StatusUtil.TaskStatusUtil(this, schedule.getTaskStatus()));
		branchName.setText(schedule.getBranchName());
		toBranchTime.setText(schedule.getTaskScdlStartTime());
		scheduleDetail.setText(schedule.getProductName());

		if (schedule.getAccountName().equals(""))
			asignmentDetailLayout.setVisibility(View.GONE);
		else {
			asignmentDetailLayout.setVisibility(View.VISIBLE);
			asignResponsiblePersonStatus.setText("指定");
			asignResponsiblePersonName.setText(schedule.getAccountName());
		}

		initOrderDetail();
	}

	private void initOrderDetail() {
		RelativeLayout toOrderDetailBtn = (RelativeLayout) findViewById(R.id.activity_schedule_detail_to_order_detail_btn);
		TextView orderNumber = (TextView) findViewById(R.id.activity_schedule_detail_order_number_content);
		TextView productName = (TextView) findViewById(R.id.activity_schedule_detail_order_product_name);
		TextView paymentAmount = (TextView) findViewById(R.id.activity_schedule_detail_order_payment_amount);

		orderNumber.setText(scheduleDetail.getOrderNumber());
		productName.setText(scheduleDetail.getProductName());
		paymentAmount.setText(NumberFormatUtil.StringFormatToString(this,
				scheduleDetail.getTotalSalePrice()));

		toOrderDetailBtn.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent destIntent = new Intent();
				Bundle bundle = new Bundle();
				destIntent.setClass(ScheduleDetailActivity.this,
						ServcieOrderDetailActivity.class);
				OrderBaseInfo orderItem = new OrderBaseInfo();
				orderItem.setOrderID(String.valueOf(scheduleDetail.getOrderID()));
				orderItem.setTotalSalePrice(scheduleDetail.getTotalSalePrice());
				orderItem.setOrderObjectID(String.valueOf(scheduleDetail
						.getOrderObjectID()));
				orderItem.setProductType("0");
				bundle.putSerializable("OrderItem", orderItem);
				destIntent.putExtras(bundle);
				startActivity(destIntent);
			}

		});
	}
}
