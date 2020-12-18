package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;

import com.baidu.location.BDLocation;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.BranchListAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.Branch;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.LocationService;

public class BranchListActivity extends BaseActivity implements OnItemClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Company";
	private static final String GET_BRANCH_LIST = "GetBranchList";
	private boolean isRefresh;
	private NewRefreshListView branchListView;
	private ArrayList<Branch> mBranchList;
	private OnRefreshListener refreshListWithWebService;
	private BranchListAdapter branchListAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_branch_list);
		branchListView = (NewRefreshListView) findViewById(R.id.branch_listview);
		branchListView.setOnItemClickListener(this);
		refreshListWithWebService = new OnRefreshListener() {

			@Override
			public void onRefresh() {
				// TODO Auto-generated method stub
				getBranchListByByWebService();

			}

		};
		branchListView.setonRefreshListener(refreshListWithWebService);
		isRefresh = false;
		getBranchListByByWebService();
	}
	
	

	@Override
	protected void onResume() {
		super.onResume();
		
	}
	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		getBranchListByByWebService();
	}

	protected void getBranchListByByWebService() {
		if(!isRefresh){
			isRefresh = true;
			super.asyncRefrshView(this);
		}
		
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		Intent destIntent = new Intent(this, BranchActivity.class);
		destIntent.putExtra("flag","2");// 2:分店的信息
		destIntent.putExtra("strCompanyID", super.mCompanyID);
		destIntent.putExtra("BranchID",Integer.parseInt(mBranchList.get(position - 1).getID()));
		startActivity(destIntent);
	}

	@Override
	public WebApiRequest getRequest() {
		JSONObject jsonParam=new JSONObject();
		LocationManager locationManager=(LocationManager)getSystemService(Context.LOCATION_SERVICE);
			if(locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)){
			LocationService locationService=new LocationService();
			BDLocation location=locationService.getBaiDuLocation(this);
			if(location!=null && location.getLocType()==161 && location.getLatitude()>0 && location.getLongitude()>0){
				try {
					jsonParam.put("Longitude",location.getLongitude());
					jsonParam.put("Latitude",location.getLatitude());
				} catch (JSONException e) {
				}
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_BRANCH_LIST,jsonParam.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_BRANCH_LIST,jsonParam.toString(),header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		isRefresh = false;
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				mBranchList = (ArrayList<Branch>) response.mData;
				branchListAdapter = new BranchListAdapter(getApplicationContext(), mBranchList);
				branchListView.setAdapter(branchListAdapter);
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
		branchListView.onRefreshComplete();
	}
	@Override
	public void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		(((UserInfoApplication)getApplication()).mLocationClient).stop();
	}
	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<Branch> branches = Branch.parseListByJson(response.getStringData());
		response.mData = branches;
	}
}
