package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.AppointmentListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AppointmentInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class AppointmentStatusModleActivity extends BaseActivity implements OnClickListener,OnItemClickListener , IConnectTask {
	private static final String CATEGORY_NAME = "Task";
	private static final String GET_PROMOTION_LIST = "GetScheduleList";
	ArrayList<AppointmentInfo> appointmentInfoList;
	private NewRefreshListView promotionListview;
	AppointmentListAdapter appointmentListAdapter;
	int status;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Intent it=getIntent();
		status=it.getIntExtra("Status", 0);
		appointmentInfoList=new ArrayList<AppointmentInfo>();
		setContentView(R.layout.activity_appointment_viewpager_item);
		initView();
	}

	private void initView(){
		promotionListview = (NewRefreshListView) findViewById(R.id.appointment_listview);
		promotionListview.setOnItemClickListener(this);
		//设置listView下拉刷新调用的接口
		promotionListview.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				AppointmentStatusModleActivity.super.asyncRefrshView(AppointmentStatusModleActivity.this);
			}

		});
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
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		Intent destIntent = new Intent(this, AppointmentDetailActivity.class);
		Bundle bu=new Bundle();
		bu.putLong("taskID", appointmentInfoList.get(position - 1).getTaskID());
		destIntent.putExtras(bu);
		startActivity(destIntent);
	}	
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		JSONArray statusArray=new JSONArray();
    	statusArray.put(status);
		try {
			para.put("TaskType", 1);
			para.put("Status", statusArray);
			para.put("PageIndex", 1);
			para.put("PageSize", 999999);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_PROMOTION_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_PROMOTION_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				int appointmentListSize=AppointmentInfo.parseListByJson(response.getStringData()).size();
				if(appointmentListSize>0){
					appointmentInfoList=AppointmentInfo.parseListByJson(response.getStringData());
				}
				appointmentListAdapter = new AppointmentListAdapter(this, appointmentInfoList);
				promotionListview.setAdapter(appointmentListAdapter);
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
	public void parseData(WebApiResponse response) {
		
	}
}
