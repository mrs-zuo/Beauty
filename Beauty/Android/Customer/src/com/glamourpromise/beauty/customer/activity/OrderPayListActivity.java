package com.glamourpromise.beauty.customer.activity;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.OrderPayListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderPayListInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class OrderPayListActivity extends BaseActivity implements IConnectTask {
	private static final String CATEGORY_NAME = "Payment";
	private static final String GET_ORDER_LIST = "UnPaidListByCustomerID";
	private List<OrderPayListInfo> orderList;
	private ListView orderListView;
	private Button  orderPay;
	private OrderPayListAdapter orderPayListAdapter;
	private ListItemClick listItemClick;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_order_pay_list);
		super.setTitle(getString(R.string.title_order_pay_list));
		initActivity();
	}
	@Override
	protected void onResume() {
		super.onResume();
		getOrderList();
	}
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
	}
	private void getOrderList() {
		super.showProgressDialog();
		orderList.clear();
		super.asyncRefrshView(this);
	}
	private void initActivity() {
		orderListView = (ListView) findViewById(R.id.order_pay_listview);
		orderPay = (Button) findViewById(R.id.pay_confirm);
		listItemClick = new ListItemClick() {
			@Override
			public void itemOnClick(int currentSelectCount) {
				
			}
		};
		orderPay.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				List<Boolean> state = orderPayListAdapter.getSelectedFlag();
				List<OrderPayListInfo> orderPayList = new ArrayList<OrderPayListInfo>();
				for (int i = 0; i < orderList.size(); i++) {
					if (state.get(i)) {
						orderPayList.add(orderList.get(i));
					}
				}
				int partOrderCount = 0;
				if (orderPayList.size() > 1) {
					for (OrderPayListInfo orderInfo : orderPayList) {
						if (orderInfo.getPaymentStatus() == 2) {
							partOrderCount++;
						}
					}
				}
				//检测去支付的订单是否包含不同门店和不同卡的
				boolean hasDifferentOrder=false;
				if (orderPayList.size() > 1) {
					for(int i=0;i<orderPayList.size();i++){
						OrderPayListInfo o1=orderPayList.get(i);
						for(int j=0;j<orderPayList.size();j++){
							OrderPayListInfo o2=orderPayList.get(j);
							if(o1.getBranchID()!=o2.getBranchID() || o1.getCardID()!=o2.getCardID()){
								hasDifferentOrder=true;
								break;
							}
						}
					}
				}
				//检测去支付的订单是否包含不同门店和不同卡的
				boolean hasCardNullOrder=false;
			    for(int i=0;i<orderPayList.size();i++){
						OrderPayListInfo o1=orderPayList.get(i);
						if(o1.getCardID()==0){
							hasCardNullOrder=true;
							break;
						}
					}
				if (orderPayList.size() < 1)
					DialogUtil.createShortDialog(OrderPayListActivity.this,"订单不能为空");
				else if (partOrderCount > 0 && partOrderCount < orderPayList.size()) {
					DialogUtil.createShortDialog(OrderPayListActivity.this,"部分支付的订单不能和其他订单一起支付!");
				} else if (partOrderCount > 1 && partOrderCount == orderPayList.size()) {
					DialogUtil.createShortDialog(OrderPayListActivity.this,"部分支付的订单只能选择一张!");
				}
				else if(hasDifferentOrder){
					DialogUtil.createShortDialog(OrderPayListActivity.this,"请选择同一门店同一种卡订单支付!");
				}
				else if(hasCardNullOrder){
					DialogUtil.createShortDialog(OrderPayListActivity.this,"未使用e账户购买的订单,不能进行支付!");
				}
				else {
					Intent destIntent = new Intent(OrderPayListActivity.this,AddPaymentActivity.class);
					Bundle mBundle = new Bundle();
					mBundle.putSerializable("OrderPayList",(Serializable) orderPayList);
					destIntent.putExtras(mBundle);
					startActivity(destIntent);
				}

			}
		});
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		orderList = new ArrayList<OrderPayListInfo>();
	}

	public interface ListItemClick {
		void itemOnClick(int currentSelectCount);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerID", mCustomerID);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_ORDER_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_ORDER_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				@SuppressWarnings("unchecked")
				ArrayList<OrderPayListInfo> tmp = (ArrayList<OrderPayListInfo>) response.mData;
				orderList.clear();
				orderList.addAll(tmp);
				orderPayListAdapter = new OrderPayListAdapter(OrderPayListActivity.this, orderList, listItemClick);
				orderListView.setAdapter(orderPayListAdapter);
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
	public void parseData(WebApiResponse response) {
		ArrayList<OrderPayListInfo> tmp = OrderPayListInfo.parseListByJson(response.getStringData());
		response.mData = tmp;
	}
}
