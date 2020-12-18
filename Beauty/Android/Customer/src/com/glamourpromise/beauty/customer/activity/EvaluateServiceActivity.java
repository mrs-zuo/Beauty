package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ImageButton;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EvaluateServiceListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.EvaluateServiceInfo;
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
public class EvaluateServiceActivity extends BaseActivity implements OnClickListener,OnItemClickListener, IConnectTask {
	private static final String REVIEW_NAME = "Review";
	private static final String GET_REVIEW_LIST = "GetUnReviewList";
	private List<EvaluateServiceInfo> evaluateServiceInfoList;
	private EvaluateServiceListAdapter evaluateServiceListAdapter;
	private NewRefreshListView evaluateServiceListView;	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.evaluate_service_list);
		super.setTitle(getString(R.string.evaluate_service_menu));
		evaluateServiceInfoList=new ArrayList<EvaluateServiceInfo>();
		initView();
	}
	
	private void initView(){
		evaluateServiceListView = (NewRefreshListView) findViewById(R.id.evaluate_service_listview);
        evaluateServiceListView.setOnItemClickListener(EvaluateServiceActivity.this);
		//设置listView下拉刷新调用的接口
		evaluateServiceListView.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				EvaluateServiceActivity.super.asyncRefrshView(EvaluateServiceActivity.this);
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
	protected void onRestart() {
		super.onRestart();
		super.asyncRefrshView(this);
	}
	
	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		Intent it = new Intent(this, ServcieOrderDetailActivity.class);
		Bundle bu=new Bundle();
		OrderBaseInfo orderItem=new OrderBaseInfo();
		orderItem.setOrderObjectID(String.valueOf(evaluateServiceInfoList.get(position - 1).getOrderObejctID()));
		orderItem.setProductType(String.valueOf(0));
		bu.putSerializable("OrderItem",orderItem);
		it.putExtras(bu);
		startActivityForResult(it,200);
	}
	
	@Override
	public WebApiRequest getRequest() {
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(REVIEW_NAME, GET_REVIEW_LIST, "");
		WebApiRequest request = new WebApiRequest(REVIEW_NAME, GET_REVIEW_LIST, "", header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				evaluateServiceInfoList = EvaluateServiceInfo.parseListByJson(response.getStringData());
				evaluateServiceListAdapter = new EvaluateServiceListAdapter(EvaluateServiceActivity.this, evaluateServiceInfoList);
				evaluateServiceListView.setAdapter(evaluateServiceListAdapter);
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
		evaluateServiceListView.onRefreshComplete();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
	  if (resultCode == RESULT_OK) {
			if (requestCode == 200) {
				super.asyncRefrshView(this);
			}
		}
	}
}
