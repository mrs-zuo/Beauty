package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View.OnClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.RemindListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.RemindInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class RemindListActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Task";
	private static final String GET_NOTICE_LIST = "GetScheduleList";
	private List<RemindInformation> RemindList = new ArrayList<RemindInformation>();
	private ListView remindListView;
	private RemindListAdapter remindListAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_remind_list);
		super.setTitle("提醒");
		remindListView = (ListView) findViewById(R.id.remind_listview);
		LayoutInflater.from(this);
		remindListAdapter = new RemindListAdapter(RemindListActivity.this, RemindList);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("TaskType",1);
			para.put("Status",new JSONArray().put(2));
			para.put("PageIndex",1);
			para.put("PageSize",999999);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_NOTICE_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_NOTICE_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<RemindInformation> reminds = (ArrayList<RemindInformation>) response.mData;
				RemindList.clear();
				RemindList.addAll(reminds);
				remindListView.setAdapter(remindListAdapter);
				remindListAdapter.notifyDataSetChanged();
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
		ArrayList<RemindInformation> reminds = RemindInformation.parseListByJson(response.getStringData());
		response.mData = reminds;
	}
}
