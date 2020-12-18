package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.OrderPaymentDetailAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.OrderPaymentInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class OrderPaymentDetail extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "payment";
	private static final String GET_PAYMENT_DETAIL = "GetPaymentDetailByOrderID";
	private NoScrollListView orderPaymentListView;
	private UserInfoApplication userInfo;
	private ArrayList<OrderPaymentInfo> orderPaymentDetailList;
	private OrderPaymentDetailAdapter orderPaymentAdapter;
	private String mOrderID;
	private String mOrderPrice;
	private List<OrderBaseInfo> orderInfoList;
	private LayoutInflater layoutInflater;
	private TableLayout  ecardHistoryOrderListView;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_order_payment_detail);
		super.setTitle(getString(R.string.order_payment_detail_title));
		mOrderID = getIntent().getStringExtra("OrderID");
		mOrderPrice = getIntent().getStringExtra("OrderPrice");
		userInfo = (UserInfoApplication) getApplication();
		orderPaymentListView = (NoScrollListView) findViewById(R.id.payment_listview);
		orderPaymentDetailList = new ArrayList<OrderPaymentInfo>();
		orderPaymentAdapter = new OrderPaymentDetailAdapter(this,orderPaymentDetailList, mOrderPrice, userInfo.getLoginInformation().getCurrencySymbols());
		orderPaymentListView.setAdapter(orderPaymentAdapter);
		ecardHistoryOrderListView=(TableLayout) findViewById(R.id.order_list);
		getData();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	private void getData() {
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("OrderID", mOrderID);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				CATEGORY_NAME, GET_PAYMENT_DETAIL, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,
				GET_PAYMENT_DETAIL, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<OrderPaymentInfo> paymentList =OrderPaymentInfo.parseListByJson(response.getStringData());
				try {
					JSONArray paymentOrderList =new JSONArray(response.getStringData()).getJSONObject(0).getJSONArray("PaymentOrderList");
					int count = paymentOrderList.length();
					orderInfoList=new ArrayList<OrderBaseInfo>();
					for (int i = 0; i <count; i++) {
						JSONObject orderJson=paymentOrderList.getJSONObject(i);
						OrderBaseInfo order=new OrderBaseInfo();
						order.setOrderID(orderJson.getString("OrderID"));
						order.setOrderObjectID(orderJson.getString("OrderObjectID"));
						order.setProductType(orderJson.getString("ProductType"));
						order.setOrderSerialNumber(orderJson.getString("OrderNumber"));
						order.setProductName(orderJson.getString("ProductName"));
						order.setTotalPrice(orderJson.getString("TotalSalePrice"));
						orderInfoList.add(order);
					}
				} catch (JSONException e) {
					 e.printStackTrace();
				}
				orderPaymentDetailList.clear();
				orderPaymentDetailList.addAll(paymentList);
				orderPaymentAdapter.notifyDataSetChanged();
				setPaymentOrderList();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
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
	private void setPaymentOrderList() {
		if(orderInfoList == null || orderInfoList.size() < 1)
			return;
		layoutInflater = LayoutInflater.from(this);
		ecardHistoryOrderListView.setVisibility(View.VISIBLE);
		TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
		lp.setMargins(0, 25, 0, 0);
		for(int i = 0; i < orderInfoList.size(); i++){
			LinearLayout LLOrderItem = (LinearLayout) layoutInflater.inflate(R.xml.ecard_payment_order_item, null);
			((TextView)LLOrderItem.findViewById(R.id.order_number)).setText(orderInfoList.get(i).getOrderSerialNumber());
			((TextView)LLOrderItem.findViewById(R.id.product_name)).setText(orderInfoList.get(i).getProductName());
			((TextView)LLOrderItem.findViewById(R.id.order_amount)).setText(NumberFormatUtil.StringFormatToString(OrderPaymentDetail.this, orderInfoList.get(i).getTotalPrice()));
			final int position = i;
			LLOrderItem.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent destIntent = null;
					if (orderInfoList.get(position).getProductType().equals("1")) {
						destIntent = new Intent(OrderPaymentDetail.this, CommodityOrderDetailActivity.class);

					} else if (orderInfoList.get(position).getProductType().equals("0")) {
						destIntent = new Intent(OrderPaymentDetail.this, ServcieOrderDetailActivity.class);
					}
					
					if(destIntent == null)
						return;

					Bundle mBundle = new Bundle();
					mBundle.putSerializable("OrderItem", (Serializable) orderInfoList.get(position));
					destIntent.putExtras(mBundle);
					startActivity(destIntent);
				}
			});
			ecardHistoryOrderListView.addView(LLOrderItem, lp);
		}
	}

	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<OrderPaymentInfo> paymentList = OrderPaymentInfo.parseListByJson(response.getStringData());
		response.mData = paymentList;
	}
}
