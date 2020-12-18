package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ListView;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EcardHistoryOrderListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class EcardHistoryOrderListActivity extends BaseActivity implements OnClickListener, IConnectTask{
	private static final String CATEGORY_NAME = "order";
	private static final String GET_ORDER_LIST = "getOrderListByPaymentID";
	
	private ListView  ecardHistoryOrderListView;
	private Thread requestWebServiceThread;
	private ProgressDialog progressDialog;
	private List<OrderBaseInfo> orderInfoList=new ArrayList<OrderBaseInfo>();
	private EcardHistoryOrderListAdapter orderListAdapter;	
	private String mPaymentID;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_history_order_list);
		super.setTitle("消费记录详情");
		Intent intent=getIntent();
		initView(intent.getStringExtra("paymentId"));
	}
	protected void initView(String paymentId){
		ecardHistoryOrderListView=(ListView) findViewById(R.id.ecard_history_order_list_view);
		mPaymentID = paymentId;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	@SuppressLint("HandlerLeak")
	private Handler mHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			
			if (progressDialog != null) {
				progressDialog.dismiss();
				progressDialog = null;
			}
			if (requestWebServiceThread != null) {
				requestWebServiceThread.interrupt();
				requestWebServiceThread = null;
			}
			if (msg.what == -2) {
				DialogUtil.createShortDialog(EcardHistoryOrderListActivity.this, EcardHistoryOrderListActivity.this.getString(R.string.get_webservice_data_null));
			} else if (msg.what == -1) {
				DialogUtil.createShortDialog(EcardHistoryOrderListActivity.this, EcardHistoryOrderListActivity.this.getString(R.string.get_webservice_data_error));
			} else if (msg.what == 1) {
				orderListAdapter = new EcardHistoryOrderListAdapter(EcardHistoryOrderListActivity.this, orderInfoList, false);
				ecardHistoryOrderListView.setAdapter(orderListAdapter);
			}
		}
	};
	
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
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("PaymentID", mPaymentID);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_ORDER_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_ORDER_LIST, para.toString(), header);
		return request;
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
//				orderInfoList = OrderBaseInfo.parseListByJson(response.getStringData());
				orderInfoList = (List<OrderBaseInfo>) response.mData;
				orderListAdapter = new EcardHistoryOrderListAdapter(EcardHistoryOrderListActivity.this, orderInfoList, false);
				ecardHistoryOrderListView.setAdapter(orderListAdapter);
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
		
		super.dismissProgressDialog();
	}
	@Override
	public void parseData(WebApiResponse response) {
		OrderBaseInfo orderBase = new OrderBaseInfo();
		ArrayList<OrderBaseInfo> orderInfoList = orderBase.parseListByJson(response.getStringData());
		response.mData = orderInfoList;
	}
}
