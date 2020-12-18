package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.OrderServiceFinishedDetailAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.BalanceInfo;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.OrderDetailInformation;
import com.glamourpromise.beauty.customer.bean.TGListInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StatusUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class CommodityOrderDetailActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Order";
	private static final String GET_ORDER_DETAIL = "GetOrderDetail";
	private static final String DELETE_ORDER = "DeleteOrder";
	private static final String GET_ORDER_TREAT_GROUP = "GetTreatGroupByOrderObjectID";

	private static final int GET_DETAIL_TASK_FLAG = 1;
	private static final int DELETE_TASK_FLAG = 2;
	private static final int GET_TREAT_GROUP_FLAG = 3;

	private int taskFlag;

	private OrderBaseInfo orderInformation;
	private TextView orderTimeView;
	private TextView orderStatus;
	private LayoutInflater layoutInflater;

	private List<BalanceInfo> paymentList = new ArrayList<BalanceInfo>();// 支付信息
	private OrderDetailInformation orderDetail = new OrderDetailInformation();

	// 交付记录
	private NoScrollListView noScrollListView;
	private NoScrollListView unFinishListView;
	private List<TGListInfo> finishedTGList = new ArrayList<TGListInfo>();// 已交付商品列表
	private TGListInfo tgListInfo = new TGListInfo();
	private OrderServiceFinishedDetailAdapter listAdapter;

	// 收发画面功能
	private LinearLayout.LayoutParams orderParams;
	private LinearLayout.LayoutParams priceParams;
	private LinearLayout.LayoutParams contentParams;
	private boolean commodityOrderFlag = false;
	private boolean commodityPriceFlag = false;
	private boolean contentFlag = false;
	private TableLayout commodityOrderBtn;
	private TableLayout commodityPriceBtn;
	private TableLayout commodityFinishBtn;
	private LinearLayout commodityOrderView;
	private LinearLayout commodityPriceView;
	private LinearLayout contentView;
	private ImageView commodityFinishArrow;
	// 活动画面箭头
	private ImageView commodityOrderArrow;
	private ImageView commodityPriceArrow;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_commodity_order_detail);
		super.setTitle(getString(R.string.title_commodity_order_detail));
		super.showProgressDialog();
		
		orderInformation = (OrderBaseInfo) getIntent().getSerializableExtra("OrderItem");

		layoutInflater = LayoutInflater.from(this);
		orderTimeView = (TextView) findViewById(R.id.commodity_order_time);
		orderStatus = (TextView) findViewById(R.id.commodity_order_status);
		
		// 设定收发画面
		setLayoutParams();
		
		getData();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	private void setLayoutParams() {
		commodityOrderBtn = (TableLayout) findViewById(R.id.commodity_order_time_tablelayout);
		commodityPriceBtn = (TableLayout) findViewById(R.id.commodity_detail_tablelayout);
		commodityFinishBtn = (TableLayout) findViewById(R.id.commodity_finish_table_layout);
		commodityOrderView = (LinearLayout) findViewById(R.id.commodity_order_changeable_layout);
		commodityPriceView = (LinearLayout) findViewById(R.id.commodity_price_detail_changeable_layout);
		contentView = (LinearLayout) findViewById(R.id.show_content_layout);
		commodityOrderArrow = (ImageView) findViewById(R.id.order_changeable_layout_image_view);
		commodityPriceArrow = (ImageView) findViewById(R.id.price_changeable_layout_image_view);
		commodityFinishArrow = (ImageView) findViewById(R.id.finish_list_changeable_layout_image_view);
		orderParams = (LinearLayout.LayoutParams) commodityOrderView.getLayoutParams();
		orderParams.height = 0;
		commodityOrderView.setLayoutParams(orderParams);

		priceParams = (LinearLayout.LayoutParams) commodityPriceView.getLayoutParams();
		priceParams.height = 0;
		commodityPriceView.setLayoutParams(priceParams);

		contentParams = (LinearLayout.LayoutParams) contentView.getLayoutParams();
		contentParams.height = 0;
		contentView.setLayoutParams(contentParams);

		commodityOrderBtn.setOnClickListener(this);
		commodityPriceBtn.setOnClickListener(this);
		commodityFinishBtn.setOnClickListener(this);

	}

	protected void initView() {
		orderStatus.setText(StatusUtil.OrderAndPaymentStatusTextUtil(this,orderDetail.getStatus(), orderDetail.getPaymentStatus()));
		setOrderPayStatus(String.valueOf(orderDetail.getStatus()),orderDetail.getPaymentStatus());
	}

	// 交付记录列表
	private void initListView() {
		LinearLayout concealListView = (LinearLayout) findViewById(R.id.order_annual_changeable_layout);
		noScrollListView = (NoScrollListView) findViewById(R.id.commodity_order_annual_list_view);
		// 控制显示
		if (finishedTGList.size() == 0) {
			commodityFinishBtn.setVisibility(View.GONE);
			concealListView.setVisibility(View.GONE);
		} else {
			commodityFinishBtn.setVisibility(View.VISIBLE);
			concealListView.setVisibility(View.VISIBLE);
			listAdapter = new OrderServiceFinishedDetailAdapter(this,
					finishedTGList, orderDetail.getOrderID(),
					orderDetail.getBranchName(), 1);
			noScrollListView.setAdapter(listAdapter);
		}
		
		super.dismissProgressDialog();

	}

	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == OrderPayActivity.COMMODITY_ORDER_PAY_REQUEST_CODE) {
			switch (resultCode) { // resultCode为回传的标记
			case RESULT_OK:
				// 如果支付成功，则结束该activity
				orderDetail.setPaymentStatus(3);
				setOrderPayStatus(String.valueOf(orderDetail.getStatus()),orderDetail.getPaymentStatus());
				break;
			default:
				break;
			}
		}
	}

	private void getData() {
		submitTask(GET_DETAIL_TASK_FLAG);
	}

	private void submitTask(int flag) {
		// TODO Auto-generated method stub
		taskFlag = flag;
		super.asyncRefrshView(this);
	}

	private void setPaymentStatus() {
		// 显示支付信息

		if (paymentList.size() > 0) {
			final View promptView = layoutInflater.inflate(R.xml.payment_mode_amount_prompt, null);
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

		if (paymentList.size() == 0) {
			((RelativeLayout) findViewById(R.id.order_pay_detail_relativelayout))
					.setVisibility(View.GONE);
			;

		}
	}


	private void setOrderPayStatus(String orderStatus, int payStatus) {
		RelativeLayout payDetailBtn = (RelativeLayout) findViewById(R.id.order_pay_detail_relativelayout);
		LinearLayout paymentDetailLayout = (LinearLayout) findViewById(R.id.order_payment_detail_changeable_layout);
		if (payStatus == 1 || payStatus == 5) {
			paymentDetailLayout.setVisibility(View.GONE);
		} else {
			paymentDetailLayout.setVisibility(View.VISIBLE);
			payDetailBtn.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					// TODO Auto-generated method stub
					Intent destIntent = new Intent(
							CommodityOrderDetailActivity.this,
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

	private void createCommodityTableLayout() {
		TextView commodityNameView = (TextView) findViewById(R.id.commodity_name);
		commodityNameView.setText(orderDetail.getProductName());
		TextView commodityCountView = (TextView) findViewById(R.id.commodity_quantity);
		commodityCountView.setText("" + orderDetail.getTotalCount());

		TextView totalOrigPrice = (TextView) findViewById(R.id.total_orig_price_content);
		TextView totalMemberPrice = (TextView) findViewById(R.id.total_member_sale_price_content);
		TextView totalSalePrice = (TextView) findViewById(R.id.total_sale_price_content);
		LinearLayout totalSaleLayout = (LinearLayout) findViewById(R.id.activity_commodity_order_detail_total_sale_price_layout);

		totalOrigPrice.setText(NumberFormatUtil.StringFormatToString(this,orderDetail.getTotalOrigPrice()));
		if (orderDetail.getTotalCalcPrice().equals(orderDetail.getTotalSalePrice())) {
			totalSaleLayout.setVisibility(View.GONE);
		} else {
			totalSaleLayout.setVisibility(View.VISIBLE);
			totalSalePrice.setText(NumberFormatUtil.StringFormatToString(this,orderDetail.getTotalSalePrice()));
		}
		totalMemberPrice.setText(NumberFormatUtil.StringFormatToString(this,orderDetail.getTotalCalcPrice()));
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		String methodName = "";
		if (taskFlag == GET_DETAIL_TASK_FLAG) {
			methodName = GET_ORDER_DETAIL;
			try {
				para.put("OrderObjectID",Integer.parseInt(orderInformation.getOrderObjectID()));
				para.put("ProductType",Integer.parseInt(orderInformation.getProductType()));
				
			} catch (JSONException e) {
				
				e.printStackTrace();
			}
		} else if (taskFlag == DELETE_TASK_FLAG) {
			methodName = DELETE_ORDER;
			try {
				para.put("OrderID", orderInformation.getOrderID());
				para.put("UpdaterID", mCustomerID);
				para.put("IsBussiness", 0);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (taskFlag == GET_TREAT_GROUP_FLAG) {
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
				CATEGORY_NAME, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, methodName,
				para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_DETAIL_TASK_FLAG)
					handleGetDetail(response);
				else if (taskFlag == DELETE_TASK_FLAG) {
					handleDeleteTask(response.getMessage());
				} else if (taskFlag == GET_TREAT_GROUP_FLAG) {
					finishedTGList = tgListInfo.parseListByJson(response
							.getStringData());
					initListView();
				}
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),
						response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),
						Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}

	}

	private void handleDeleteTask(String msg) {
		// TODO Auto-generated method stub
		DialogUtil.createShortDialog(this, msg);
		setOrderPayStatus(orderInformation.getOrderStatus(),orderInformation.getPaymentStatus());
	}

	private void handleGetDetail(WebApiResponse response) {

		orderDetail.parseByJson(response.getStringData());
		orderTimeView.setText(orderDetail.getOrderTime());
		((TextView) findViewById(R.id.commodity_order_branch)).setText(orderDetail.getBranchName());

		if (orderDetail.getOrderNumber().equals("")
				|| orderDetail.getOrderNumber().equals("anyType{}"))
			((RelativeLayout) findViewById(R.id.layout_order_serial_number))
					.setVisibility(View.GONE);
		else
			((TextView) findViewById(R.id.commodity_order_serial_number))
					.setText(orderDetail.getOrderNumber());
		((TextView) findViewById(R.id.responsible_personname))
				.setText(orderDetail.getResponsiblePersonName());
		createCommodityTableLayout();
		initView();

		((TextView) findViewById(R.id.commodity_finish_status_title))
				.setText(StatusUtil.OrderDetailTextStringUtil(this,
						orderDetail.getProductType(),
						orderDetail.getFinishedCount(),
						orderDetail.getTotalCount()));
		((TextView) findViewById(R.id.commodity_finish_status_content))
				.setText(StatusUtil.ProductRemainCalcTextUtil(this,
						orderDetail.getProductType(),
						orderDetail.getSurplusCount(),
						orderDetail.getTotalCount()));

		unFinishListView = (NoScrollListView) findViewById(R.id.unfinish_list_view);
		listAdapter = new OrderServiceFinishedDetailAdapter(this,
				orderDetail.getGroupList(), orderDetail.getOrderID(),
				orderDetail.getBranchName(), 1);
		unFinishListView.setAdapter(listAdapter);

		taskFlag = GET_TREAT_GROUP_FLAG;
		super.asyncRefrshView(this);

	}

	@Override
	public void parseData(WebApiResponse response) {

	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.commodity_order_time_tablelayout:
			if (commodityOrderFlag == false) {
				commodityOrderFlag = !commodityOrderFlag;
				commodityOrderArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				orderParams.height = LayoutParams.WRAP_CONTENT;
				commodityOrderView.setLayoutParams(orderParams);
			} else {
				commodityOrderFlag = !commodityOrderFlag;
				commodityOrderArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				orderParams.height = 0;
				commodityOrderView.setLayoutParams(orderParams);
			}
			break;
		case R.id.commodity_detail_tablelayout:
			if (commodityPriceFlag == false) {
				commodityPriceFlag = !commodityPriceFlag;
				commodityPriceArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				priceParams.height = LayoutParams.WRAP_CONTENT;
				commodityPriceView.setLayoutParams(priceParams);
			} else {
				commodityPriceFlag = !commodityPriceFlag;
				commodityPriceArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				priceParams.height = 0;
				commodityPriceView.setLayoutParams(priceParams);
			}
			break;
		case R.id.commodity_finish_table_layout:
			if (contentFlag == false) {
				contentFlag = !contentFlag;
				commodityFinishArrow
						.setBackgroundResource(R.drawable.report_main_up_icon);
				contentParams.height = LayoutParams.WRAP_CONTENT;
				contentView.setLayoutParams(contentParams);
			} else {
				contentFlag = !contentFlag;
				commodityFinishArrow
						.setBackgroundResource(R.drawable.report_main_down_icon);
				contentParams.height = 0;
				contentView.setLayoutParams(contentParams);
			}
			break;
		default:
			break;
		}
	}

}
