package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow.LayoutParams;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.OrderServiceFinishedDetailAdapter;
import com.glamourpromise.beauty.customer.adapter.ScdlListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.BalanceInfo;
import com.glamourpromise.beauty.customer.bean.CourseInformation;
import com.glamourpromise.beauty.customer.bean.CourseInformation.Group;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.OrderDetailInformation;
import com.glamourpromise.beauty.customer.bean.TGListInfo;
import com.glamourpromise.beauty.customer.bean.TreatmentInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class ServcieOrderDetailActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Order";
	private static final String GET_ORDER_DETAIL = "GetOrderDetail";
	private static final String GET_ORDER_TREAT_GROUP = "GetTreatGroupByOrderObjectID";
	private static final String CATEGORY_NAME_OF_TASK = "Task";
	private static final String GET_SCHEDULELIST = "GetScheduleList";
	private LayoutInflater layoutInflater;
	private OrderBaseInfo orderInformation;
	private List<BalanceInfo> paymentList;// 支付信息
	private OrderDetailInformation orderDetail = new OrderDetailInformation();
	private int taskFlag;
	private static final int GET_ORDER_DETAIL_FLAG = 1;
	private static final int GET_SCHEDULELIST_FLAG = 2;
	private static final int GET_TREAT_GROUP_FLAG = 3;
	// 收发画面功能
	private LinearLayout.LayoutParams orderParams;
	private LinearLayout.LayoutParams priceParams;
	private LinearLayout.LayoutParams contentParams;
	private LinearLayout.LayoutParams scdlParams;
	private boolean serviceOrderFlag = false;
	private boolean servicePriceFlag = false;
	private boolean contentFlag = false;
	private boolean serviceScdlFlag = false;
	private TableLayout serviceOrderBtn;
	private TableLayout servicePriceBtn;
	private TableLayout serviceFinishBtn;
	private TableLayout serviceScdlBtn;
	private LinearLayout serviceOrderView;
	private LinearLayout servicePriceView;
	private LinearLayout contentView;
	private LinearLayout serviceScdlView;

	// 活动画面箭头
	private ImageView serviceOrderArrow;
	private ImageView servicePriceArrow;
	private ImageView serviceFinishArrow;
	private ImageView serviceScdlArrow;

	// 交付记录
	private NoScrollListView noScrollListView;
	private NoScrollListView unFinishListView;
	private List<TGListInfo> finishedTGList = new ArrayList<TGListInfo>();
	private TGListInfo tgListInfo = new TGListInfo();
	private OrderServiceFinishedDetailAdapter listAdapter;

	// 预约
	private TableLayout scdlTableLayout;
	// 预约
	private NoScrollListView scdlListView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_servcie_order_detail);
		super.setTitle(getString(R.string.title_service_order_detail));
		super.showProgressDialog();
		orderInformation = (OrderBaseInfo) getIntent().getSerializableExtra("OrderItem");
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		//mainLayout = (LinearLayout) findViewById(R.id.course_layout);
		layoutInflater = LayoutInflater.from(getApplicationContext());
		setLayoutParams();
		// 刷新页面数据
		invaildAvtivity();
	}

	private void setLayoutParams() {
		serviceOrderBtn = (TableLayout) findViewById(R.id.service_order_time_tablelayout);
		servicePriceBtn = (TableLayout) findViewById(R.id.service_detail_tablelayout);
		serviceFinishBtn = (TableLayout) findViewById(R.id.service_finish_table_layout);
		serviceScdlBtn = (TableLayout) findViewById(R.id.service_order_detail_scdl_tablelayout);
		serviceOrderView = (LinearLayout) findViewById(R.id.service_order_changeable_layout);
		servicePriceView = (LinearLayout) findViewById(R.id.service_price_detail_changeable_layout);
		contentView = (LinearLayout) findViewById(R.id.show_content_layout);
		serviceScdlView = (LinearLayout) findViewById(R.id.activity_service_order_detail_scdl_list_changeable_layout);
		serviceOrderArrow = (ImageView) findViewById(R.id.order_changeable_layout_image_view);
		servicePriceArrow = (ImageView) findViewById(R.id.price_changeable_layout_image_view);
		serviceFinishArrow = (ImageView) findViewById(R.id.finish_list_changeable_layout_image_view);
		serviceScdlArrow = (ImageView) findViewById(R.id.activity_service_order_detail_changeable_layout_arrow);

		contentParams = (LinearLayout.LayoutParams) contentView.getLayoutParams();
		contentParams.height = 0;
		contentView.setLayoutParams(contentParams);

		orderParams = (LinearLayout.LayoutParams) serviceOrderView.getLayoutParams();
		orderParams.height = 0;
		serviceOrderView.setLayoutParams(orderParams);

		priceParams = (LinearLayout.LayoutParams) servicePriceView.getLayoutParams();
		priceParams.height = 0;
		servicePriceView.setLayoutParams(priceParams);

		scdlParams = (LinearLayout.LayoutParams) serviceScdlView.getLayoutParams();
		scdlParams.height = 0;
		serviceScdlView.setLayoutParams(scdlParams);
		serviceOrderBtn.setOnClickListener(this);
		servicePriceBtn.setOnClickListener(this);
		serviceFinishBtn.setOnClickListener(this);
		serviceScdlBtn.setOnClickListener(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	/**
	 * 支付页面返回处理
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		// 从支付页面返回
		if (requestCode == OrderPayActivity.SERVICE_ORDER_PAY_REQUEST_CODE) {
			switch (resultCode) {
			case RESULT_OK:
				orderInformation.setPaymentStatus(2);
				setOrderPayStatus(orderInformation.getOrderStatus(),
						orderInformation.getPaymentStatus());
				break;

			default:
				break;
			}
		}
	}

	/**
	 * 重新刷新页面
	 */
	private void invaildAvtivity() {
		// 调用网络获取数据
		taskFlag = GET_ORDER_DETAIL_FLAG;
		super.asyncRefrshView(this);
	}

	/**
	 * 设置订单基本信息 即UI界面的第一个块
	 */
	private void setOrderBasicInfo() {
		((TextView) findViewById(R.id.servcie_order_branch))
				.setText(orderDetail.getBranchName());
		// 美丽顾问
		((TextView) findViewById(R.id.responsible_personname))
				.setText(orderDetail.getResponsiblePersonName());
		// //下单时间
		setOrderTime();
		// 订单有效期
		setOrderExpirationtime();
		// 订单编号
		setSerialNumber();
	}

	/**
	 * 设置订单的服务的信息
	 */
	private void setServiceDetail() {

		TextView serviceName = (TextView) findViewById(R.id.service_name);
		TextView quantity = (TextView) findViewById(R.id.service_quantity);
		TextView totalOrigPrice = (TextView) findViewById(R.id.total_orig_price_content);
		TextView totalMemeberPrice = (TextView) findViewById(R.id.total_member_sale_price_content);
		TextView totalSalePrice = (TextView) findViewById(R.id.total_sale_price_content);
		LinearLayout totalSalePriceLayout = (LinearLayout) findViewById(R.id.activity_service_order_detail_total_sale_price_layout);
		serviceName.setText(orderDetail.getProductName());
		quantity.setText(orderDetail.getQuantity());
		totalOrigPrice.setText(NumberFormatUtil.StringFormatToString(this,
				orderDetail.getTotalOrigPrice()));

		if (orderDetail.getTotalCalcPrice().equals(
				orderDetail.getTotalSalePrice())) {
			totalSalePriceLayout.setVisibility(View.GONE);
		} else {
			totalSalePriceLayout.setVisibility(View.VISIBLE);
			totalSalePrice.setText(NumberFormatUtil.StringFormatToString(this,
					orderDetail.getTotalSalePrice()));
		}
		totalMemeberPrice.setText(NumberFormatUtil.StringFormatToString(this,
				orderDetail.getTotalCalcPrice()));
	}

	private void setFinishedAmount() {
		((TextView) findViewById(R.id.service_finish_status_title))
				.setText(StatusUtil.OrderDetailTextStringUtil(this,
						orderDetail.getProductType(),
						orderDetail.getFinishedCount(),
						orderDetail.getTotalCount()));
		((TextView) findViewById(R.id.service_finish_status_content))
				.setText(StatusUtil.ProductRemainCalcTextUtil(this,
						orderDetail.getProductType(),
						orderDetail.getSurplusCount(),
						orderDetail.getTotalCount()));
	}

	private void setSerialNumber() {
		if (orderDetail.getOrderNumber().equals(""))
			((RelativeLayout) findViewById(R.id.layout_order_serial_number)).setVisibility(View.GONE);
		else
			((TextView) findViewById(R.id.servcie_order_serial_number)).setText(orderDetail.getOrderNumber());
	}

	private void setOrderExpirationtime() {
		// 当前时间小于等于有效期

		SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd",Locale.getDefault());
		String currentTime = sDateFormat.format(new java.util.Date());
		((TextView) findViewById(R.id.responsible_expirationtime)).setText(DateUtil.getFormateDateByString(orderDetail.getExpirationTime()));// 当前时间小于等于有效期
		if (orderDetail.getStatus() == 1
				&& currentTime.compareTo(orderDetail.getExpirationTime()) > 0) {
			((ImageView) findViewById(R.id.expirationtime_overdue_prompt))
					.setVisibility(View.VISIBLE);
		} else
			((ImageView) findViewById(R.id.expirationtime_overdue_prompt))
					.setVisibility(View.GONE);
	}

	/**
	 * 设置订单状态
	 */
	private void setOrderStatus() {
		TextView serviceStatus = (TextView) findViewById(R.id.service_order_status);
		RelativeLayout payDetailBtn = (RelativeLayout) findViewById(R.id.order_pay_detail_relativelayout);
		LinearLayout paymentDetailLayout = (LinearLayout) findViewById(R.id.order_payment_detail_changeable_layout);
		Button orderAppointmentBt=(Button) findViewById(R.id.order_appointment_bt);
		orderAppointmentBt.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent it =new Intent(ServcieOrderDetailActivity.this,AppointmentCreateActivity.class);
				it.putExtra("branchID", String.valueOf(orderDetail.getBranchID()));
				it.putExtra("branchName", orderDetail.getBranchName());
				Bundle bu = new Bundle();
				bu.putInt("serviceID", orderDetail.getOrderID());
				bu.putString("serviceName", orderDetail.getProductName());
				bu.putString("serviceCode", "0");
				bu.putInt("objectID", orderDetail.getOrderObjectID());
				bu.putBoolean("isOldOrder", true);
				it.putExtra("taskSourceType",3);
				it.putExtras(bu);
				startActivity(it);
			}
		});
		if(orderDetail.getStatus()==1){
			if(orderDetail.getTotalCount()==0){
				orderAppointmentBt.setVisibility(View.VISIBLE);
			}else if(orderDetail.getSurplusCount()>0){
				orderAppointmentBt.setVisibility(View.VISIBLE);
			}
		}else{
			orderAppointmentBt.setVisibility(View.GONE);
		}
		
		serviceStatus.setText(StatusUtil.OrderAndPaymentStatusTextUtil(this,
				orderDetail.getStatus(), orderDetail.getPaymentStatus()));
		if (orderDetail.getPaymentStatus() == 1
				|| orderDetail.getPaymentStatus() == 5) {
			paymentDetailLayout.setVisibility(View.GONE);
		} else {
			paymentDetailLayout.setVisibility(View.VISIBLE);
			payDetailBtn.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					Intent destIntent = new Intent(
							ServcieOrderDetailActivity.this,
							OrderPaymentDetail.class);
					destIntent.putExtra("OrderID",
							orderInformation.getOrderID());
					destIntent.putExtra("OrderPrice",
							orderInformation.getTotalSalePrice());
					startActivity(destIntent);
				}
			});
		}

	}

	private void setOrderTime() {
		TextView orderTime = (TextView) findViewById(R.id.servcie_order_time);
		orderTime.setText(orderDetail.getOrderTime());
	}

	/**
	 * 设置支付详情
	 */
	private void setPaymentDetail() {
		if (paymentList == null || paymentList.size() == 0) {
			((RelativeLayout) findViewById(R.id.order_pay_detail_relativelayout))
					.setVisibility(View.GONE);
			return;
		}

		// 显示支付信息
		final View promptView = layoutInflater.inflate(
				R.xml.payment_mode_amount_prompt, null);
		ImageView paymentModeCrashView;

		if (!orderInformation.getPaymentRemark().equals("")) {
			TextView paymentRemarkView;
			paymentRemarkView = (TextView) promptView
					.findViewById(R.id.payment_remark);
			paymentRemarkView.setVisibility(View.VISIBLE);
			paymentRemarkView.setText(new StringBuilder("支付备注：").append(
					orderInformation.getPaymentRemark()).toString());
		}

		for (int i = 0; i < paymentList.size(); i++) {
			// 现金
			if (paymentList.get(i).getPaymentMode().equals("0")) {
				paymentModeCrashView = (ImageView) findViewById(R.id.order_detail_paymentmode_crash);
				paymentModeCrashView.setVisibility(View.VISIBLE);
			}
			// ECard
			else if (paymentList.get(i).getPaymentMode().equals("1")) {
				paymentModeCrashView = (ImageView) findViewById(R.id.order_detail_paymentmode_e_card);
				paymentModeCrashView.setVisibility(View.VISIBLE);
			}

			else if (paymentList.get(i).getPaymentMode().equals("2")) {
				paymentModeCrashView = (ImageView) findViewById(R.id.order_detail_paymentmode_bank_card);
				paymentModeCrashView.setVisibility(View.VISIBLE);
			} else if (paymentList.get(i).getPaymentMode().equals("3")) {
				paymentModeCrashView = (ImageView) findViewById(R.id.order_detail_paymentmode_other);
				paymentModeCrashView.setVisibility(View.VISIBLE);
			}

		}
	}

	/**
	 * 设置支付状态
	 * 
	 * @param orderStatus
	 * @param payStatus
	 */
	private void setOrderPayStatus(String orderStatus, int payStatus) {
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String methodName = "";
		String categoryName = "";
		JSONObject para = new JSONObject();
		if (taskFlag == GET_ORDER_DETAIL_FLAG) {
			categoryName = CATEGORY_NAME;
			methodName = GET_ORDER_DETAIL;
			try {
				para.put("OrderObjectID",
						Integer.parseInt(orderInformation.getOrderObjectID()));
				para.put("ProductType",
						Integer.parseInt(orderInformation.getProductType()));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (taskFlag == GET_SCHEDULELIST_FLAG) {
			categoryName = CATEGORY_NAME_OF_TASK;
			methodName = GET_SCHEDULELIST;
			try {

				JSONArray statusJArr = new JSONArray();
				statusJArr.put(1);
				statusJArr.put(2);
				para.put("Status", statusJArr);
				para.put("PageIndex", 1);
				para.put("PageSize", 999999);
				para.put("TaskType", 1);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		else if (taskFlag == GET_TREAT_GROUP_FLAG) {
			categoryName = CATEGORY_NAME;
			methodName = GET_ORDER_TREAT_GROUP;
			try {
				para.put("OrderObjectID",
						Integer.parseInt(orderInformation.getOrderObjectID()));
				para.put("ProductType",
						Integer.parseInt(orderInformation.getProductType()));
				para.put("Status", -1);

			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName,
				para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_ORDER_DETAIL_FLAG) {
					handleGetDetail(response.getStringData());
				} else if (taskFlag == GET_SCHEDULELIST_FLAG) {
					taskFlag = GET_TREAT_GROUP_FLAG;
					super.asyncRefrshView(this);
				} else if (taskFlag == GET_TREAT_GROUP_FLAG) {
					finishedTGList = tgListInfo.parseListByJson(response.getStringData());
					initListView();
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
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	private void handleGetDetail(String data) {
		orderDetail.parseByJson(data);
		setOrderBasicInfo();
		setServiceDetail();
		setOrderStatus();
		setFinishedAmount();
		TextView finishCountText = (TextView) findViewById(R.id.activity_service_order_detail_finished_count_text_content);
		LinearLayout pastCountLayout = (LinearLayout) findViewById(R.id.activity_service_order_detail_past_count_linear_layout);

		serviceScdlBtn = (TableLayout) findViewById(R.id.service_order_detail_scdl_tablelayout);
		scdlListView = (NoScrollListView) findViewById(R.id.activity_service_order_detail_scdl_list_view);
		// 判断预约
		if (orderDetail.getScdlCount() > 0) {
			serviceScdlBtn.setVisibility(View.VISIBLE);
			ScdlListAdapter scdlAdapter = new ScdlListAdapter(this,
					orderDetail.getScdlList());
			scdlListView.setAdapter(scdlAdapter);
			scdlListView.setOnItemClickListener(new OnItemClickListener() {

				@Override
				public void onItemClick(AdapterView<?> parent, View view,
						int position, long id) {
					// TODO Auto-generated method stub
					Intent destIntent=new Intent(ServcieOrderDetailActivity.this,AppointmentDetailActivity.class);
					destIntent.putExtra("taskID",orderDetail.getScdlList().get(position).getTaskID());
					startActivity(destIntent);
				}
				
			});
		} else
			serviceScdlBtn.setVisibility(View.GONE);

		if (orderDetail.getPastCount() != 0) {
			pastCountLayout.setVisibility(View.VISIBLE);
			finishCountText.setText("过去已完成" + orderDetail.getPastCount() + "次");
		} else
			pastCountLayout.setVisibility(View.GONE);

		unFinishListView = (NoScrollListView) findViewById(R.id.unfinish_list_view);
		listAdapter = new OrderServiceFinishedDetailAdapter(this,
				orderDetail.getGroupList(), orderDetail.getOrderID(),
				orderDetail.getBranchName(), 0);
		unFinishListView.setAdapter(listAdapter);
		taskFlag = GET_SCHEDULELIST_FLAG;
		super.asyncRefrshView(this);

	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub

	}

	// 交付记录列表
	private void initListView() {
		LinearLayout concealListView = (LinearLayout) findViewById(R.id.order_annual_changeable_layout);
		noScrollListView = (NoScrollListView) findViewById(R.id.order_annual_list_view);
		// 控制显示
		if (finishedTGList.size() == 0 && orderDetail.getPastCount() == 0) {
			serviceFinishBtn.setVisibility(View.GONE);
			concealListView.setVisibility(View.GONE);
		} else {
			serviceFinishBtn.setVisibility(View.VISIBLE);
			concealListView.setVisibility(View.VISIBLE);
			listAdapter = new OrderServiceFinishedDetailAdapter(this,finishedTGList, orderDetail.getOrderID(),orderDetail.getBranchName(), 0);
			noScrollListView.setAdapter(listAdapter);
		}
		super.dismissProgressDialog();
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.service_order_time_tablelayout:
			if (serviceOrderFlag == false) {
				serviceOrderFlag = !serviceOrderFlag;
				serviceOrderArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				orderParams.height = LayoutParams.WRAP_CONTENT;
				serviceOrderView.setLayoutParams(orderParams);
			} else {
				serviceOrderFlag = !serviceOrderFlag;
				serviceOrderArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				orderParams.height = 0;
				serviceOrderView.setLayoutParams(orderParams);
			}
			break;
		case R.id.service_detail_tablelayout:
			if (servicePriceFlag == false) {
				servicePriceFlag = !servicePriceFlag;
				servicePriceArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				priceParams.height = LayoutParams.WRAP_CONTENT;
				servicePriceView.setLayoutParams(priceParams);
			} else {
				servicePriceFlag = !servicePriceFlag;
				servicePriceArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				priceParams.height = 0;
				servicePriceView.setLayoutParams(priceParams);
			}
			break;
		case R.id.service_finish_table_layout:
			if (contentFlag == false) {
				contentFlag = !contentFlag;
				serviceFinishArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				contentParams.height = LayoutParams.WRAP_CONTENT;
				contentView.setLayoutParams(contentParams);
			} else {
				contentFlag = !contentFlag;
				serviceFinishArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				contentParams.height = 0;
				contentView.setLayoutParams(contentParams);
			}
			break;
		case R.id.service_order_detail_scdl_tablelayout:
			if (serviceScdlFlag == false) {
				serviceScdlFlag = !serviceScdlFlag;
				serviceScdlArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				scdlParams.height = LayoutParams.WRAP_CONTENT;
				serviceScdlView.setLayoutParams(scdlParams);
			} else {
				serviceScdlFlag = !serviceScdlFlag;
				serviceScdlArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				scdlParams.height = 0;
				serviceScdlView.setLayoutParams(scdlParams);
			}
			break;
		default:
			break;
		}
	}

}
