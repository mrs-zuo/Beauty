package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Bundle;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.RecommendBouthServiceListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
public class BoughtServiceListActivity extends BaseActivity implements IConnectTask{
	private static final String  CATEGORY_NAME="Service";
	private static final String  GET_BOUGHT_LIST="GetBoughtServiceList";
	private ListView            boughtServiceListView;
	private List<ServiceInformation> boughtServiceInfoList;
	private int       branchID;
	private String    branchName;
	private RecommendBouthServiceListAdapter recommendBouthServiceListAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_bought_service_list);
		initView();
	}
	private void initView(){
		boughtServiceListView=(ListView) findViewById(R.id.bought_service_listview);
		branchID=getIntent().getIntExtra("BranchID",0);
		branchName=getIntent().getStringExtra("BranchName");
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para=new JSONObject();
		try {
			if (mApp.getScreenWidth() == 720) {
				para.put("ImageWidth", String.valueOf(80));
				para.put("ImageHeight", String.valueOf(80));
			} else if (mApp.getScreenWidth() == 480) {
				para.put("ImageWidth", String.valueOf(66));
				para.put("ImageHeight", String.valueOf(66));
			} else if (mApp.getScreenWidth() == 1080) {
				para.put("ImageWidth", String.valueOf(150));
				para.put("ImageHeight", String.valueOf(150));
			} else if (mApp.getScreenWidth() == 1536) {
				para.put("ImageWidth", String.valueOf(183));
				para.put("ImageHeight", String.valueOf(183));
			} else {
				para.put("ImageWidth", String.valueOf(80));
				para.put("ImageHeight", String.valueOf(80));
			}
			para.put("BranchID",branchID);
		} catch (JSONException e) {
		
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_BOUGHT_LIST,para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_BOUGHT_LIST,para.toString(),header);
		return request;
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				boughtServiceInfoList = (ArrayList<ServiceInformation>)response.mData;
				recommendBouthServiceListAdapter =new RecommendBouthServiceListAdapter(this,boughtServiceInfoList,String.valueOf(branchID),branchName,4);
				boughtServiceListView.setAdapter(recommendBouthServiceListAdapter);
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
		ArrayList<ServiceInformation> services = ServiceInformation.parseListByJsonNoNode(response.getStringData());
		response.mData = services;
	}	
}
