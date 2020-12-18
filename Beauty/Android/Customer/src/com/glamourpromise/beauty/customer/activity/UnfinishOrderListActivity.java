package com.glamourpromise.beauty.customer.activity;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.UnFinishOrderListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
public class UnfinishOrderListActivity extends BaseActivity implements IConnectTask,OnItemClickListener{
	private static final String  CATEGORY_NAME="Order";
	private static final String  GET_RECOMMEND_LIST="GetUnfinishOrder";
	private ListView             unFinishOrderListView;
	private List<OrderBaseInfo> serviceOrderInfoList;
	private int       branchID;
	private UnFinishOrderListAdapter unFinishOrderListAdapter;
	private String   branchName;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_unfinish_order_list);
		initView();
	}
	private void initView(){
		unFinishOrderListView=(ListView) findViewById(R.id.unfinish_order_listview);
		unFinishOrderListView.setOnItemClickListener(this);
		branchID=getIntent().getIntExtra("BranchID",0);
		branchName=getIntent().getStringExtra("BranchName");
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para=new JSONObject();
		try {
			para.put("BranchID",branchID);
			para.put("ProductType",0);
		} catch (JSONException e) {
		
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_RECOMMEND_LIST,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_RECOMMEND_LIST,para.toString(),header);
		return request;
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				serviceOrderInfoList = (ArrayList<OrderBaseInfo>)response.mData;
				unFinishOrderListAdapter =new UnFinishOrderListAdapter(this,serviceOrderInfoList,String.valueOf(branchID),branchName);
				unFinishOrderListView.setAdapter(unFinishOrderListAdapter);
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

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		ArrayList<OrderBaseInfo> orderInfos = OrderBaseInfo.oldOrderByJson(response.getStringData());
		response.mData = orderInfos;
	}
	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		// TODO Auto-generated method stub
		Intent destIntent=new Intent(this,ServcieOrderDetailActivity.class);
		Bundle mBundle = new Bundle();
		mBundle.putSerializable("OrderItem",(Serializable) serviceOrderInfoList.get(arg2));
		destIntent.putExtras(mBundle);
		startActivity(destIntent);
	}	
}
