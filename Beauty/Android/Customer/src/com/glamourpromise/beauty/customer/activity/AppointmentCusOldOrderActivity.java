package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.AppointmentCompleteOrderListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

import android.view.View.OnClickListener;

public class AppointmentCusOldOrderActivity extends BaseActivity implements OnClickListener,OnItemClickListener , IConnectTask {
	private static final String ORDER_NAME = "Order";
	private static final String GET_EXECUTING_ORDER_LIST = "GetExecutingOrderList";
	List<OrderBaseInfo> customerOldOrderList;
	AppointmentCompleteOrderListAdapter appointmentCompleteOrderListAdapter;
	Button appointmentDetailOrderMakeSure;
	private NewRefreshListView promotionListview;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.appointment_complete_order_list);
		initView();
	}
	
	private void initView(){
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		appointmentDetailOrderMakeSure=(Button) findViewById(R.id.appointment_detail_order_make_sure);
		appointmentDetailOrderMakeSure.setOnClickListener(this);
		promotionListview = (NewRefreshListView) findViewById(R.id.old_order_listview);
		promotionListview.setOnItemClickListener(this);
		//设置listView下拉刷新调用的接口
		promotionListview.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				AppointmentCusOldOrderActivity.super.asyncRefrshView(AppointmentCusOldOrderActivity.this);
			}

		});
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		return super.onKeyDown(keyCode, event);
	}
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		OrderBaseInfo orderBaseInfo = customerOldOrderList.get(position-1);
		Bundle bundle = new Bundle();
		bundle.putSerializable("orderBaseInfo",orderBaseInfo);
		bundle.putInt("isOldOrder", 1);//老单
		Intent destIntent = new Intent();
		destIntent.putExtras(bundle);
		setResult(RESULT_OK,destIntent);
		AppointmentCusOldOrderActivity.this.finish();
	}
	
	
	@Override
	public void onClick(View v) {
		super.onClick(v);
		Intent intent;
		switch (v.getId()) {
        case R.id.appointment_detail_order_make_sure:
        	intent = new Intent(this, ServiceListActivity.class);
        	intent.putExtra("CategoryID", 0);
        	intent.putExtra("CategoryName", "全部服务");
        	intent.putExtra("FROM_SOURCE", 1);
			startActivityForResult(intent,10);
			break;
		default:
			break;
		}
	}
	 @Override
		protected void onActivityResult(int requestCode, int resultCode, Intent data) {
			// 选择员工成功返回
		  if (resultCode == RESULT_OK) {
				if(requestCode == 10){
					Intent it=getIntent();
					Bundle bu=new Bundle();
					bu.putInt("serviceID", data.getIntExtra("serviceID",0));
					bu.putInt("OrderObjectID", data.getIntExtra("OrderObjectID",0));
					bu.putLong("serviceCode", data.getLongExtra("serviceCode",0));
					bu.putString("serviceName", data.getStringExtra("serviceName"));
					bu.putInt("isOldOrder", 2);//新单
					it.putExtras(bu);
					setResult(RESULT_OK, it);
					AppointmentCusOldOrderActivity.this.finish();
				}
		    }
		}

	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerID",mCustomerID);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(ORDER_NAME, GET_EXECUTING_ORDER_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(ORDER_NAME, GET_EXECUTING_ORDER_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				customerOldOrderList=new ArrayList<OrderBaseInfo>();
				customerOldOrderList=OrderBaseInfo.oldOrderByJson(response.getStringData());
				if(customerOldOrderList.size()>0){
					appointmentCompleteOrderListAdapter = new AppointmentCompleteOrderListAdapter(AppointmentCusOldOrderActivity.this, customerOldOrderList);
					promotionListview.setAdapter(appointmentCompleteOrderListAdapter);
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
		promotionListview.onRefreshComplete();
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		
	}
}
