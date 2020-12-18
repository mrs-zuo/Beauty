package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.NoticeListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.NoticeInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
public class NoticeListActivity extends BaseActivity implements
		OnClickListener, OnItemClickListener,IConnectTask {
	private static final String CATEGORY_NAME = "Notice";
	private static final String GET_NOTICE_LIST = "getNoticeList";	
	private NewRefreshListView NoticeListView;
	private List<NoticeInformation> NoticeList;
	private OnRefreshListener refreshListWithWebService;
	private NoticeListAdapter noticeAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_notice_list);
		NoticeListView = (NewRefreshListView) findViewById(R.id.notice_listview);
		NoticeListView.setOnItemClickListener(this);
		NoticeList = new ArrayList<NoticeInformation>();
		refreshListWithWebService = new OnRefreshListener() {
			@Override
			public void onRefresh() {
				// TODO Auto-generated method stub
				NoticeList.clear();
				getNoticeListByWebService();
			}

		};
		NoticeListView.setonRefreshListener(refreshListWithWebService);
		getNoticeListByWebService();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		super.asyncRefrshView(this);
	}

	protected void getNoticeListByWebService() {
		super.asyncRefrshView(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.btn_main_back:
			finish();
			break;
		}
	}

	@Override
	public void onItemClick(AdapterView<?> arg0, View arg1, int position,long arg3) {
		// TODO Auto-generated method stub
		Intent destIntent = new Intent(this,NoticeDetailActivity.class);
		destIntent.putExtra("NoticeTitle",NoticeList.get(position - 1).getNoticeTitle());
		destIntent.putExtra("NoticeTime",NoticeList.get(position - 1).getNoticeStartTime() + "~" + NoticeList.get(position - 1).getNoticeEndTime());
		destIntent.putExtra("NoticeContent",NoticeList.get(position - 1).getNoticeContent());
		startActivity(destIntent);
	}

	@Override
	public WebApiRequest getRequest() {
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_NOTICE_LIST, "");
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_NOTICE_LIST, "", header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				NoticeList = (List<NoticeInformation>) response.mData;
				noticeAdapter = new NoticeListAdapter(NoticeListActivity.this,NoticeList);
				NoticeListView.setAdapter(noticeAdapter);
				noticeAdapter.notifyDataSetChanged();
				NoticeListView.onRefreshComplete();
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			case WebApiResponse.GET_DATA_NULL:
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
		ArrayList<NoticeInformation> NoticeList = NoticeInformation.parseListByJson(response.getStringData());
		response.mData = NoticeList;
	}
}
