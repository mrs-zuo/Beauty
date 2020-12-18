package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.BranchSelectAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.Branch;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class BranchSelectActivity extends BaseActivity implements IConnectTask{
	private ArrayList<Branch> mBranchList;
	private static final String CATEGORY_NAME = "Customer";
	private static final String GET_BRANCH_LIST = "GetCustomerBranch";
	private ListView            branchListView;
	private BranchSelectAdapter branchSelectAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_branch_select);
		super.setTitle(getString(R.string.branch_select_title_text));
		initView();
	}
	protected void  initView(){
		branchListView=(ListView)findViewById(R.id.branch_select_list);
		branchListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
				// TODO Auto-generated method stub
				Intent appointmentRelatedIntent=new Intent();
				appointmentRelatedIntent.setClass(BranchSelectActivity.this,CustomerAppointmentRelatedActivity.class);
				appointmentRelatedIntent.putExtra("BranchID",Integer.parseInt(mBranchList.get(position).getID()));
				appointmentRelatedIntent.putExtra("BranchName",mBranchList.get(position).getName());
				startActivity(appointmentRelatedIntent);
				BranchSelectActivity.this.finish();
			}});
	}
	@Override
	public WebApiRequest getRequest() {
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME,GET_BRANCH_LIST,"");
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_BRANCH_LIST, "", header);
		return request;
	}
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		super.asyncRefrshView(this);
	}
	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				mBranchList = (ArrayList<Branch>) response.mData;
				if(mBranchList!=null && mBranchList.size()>0 && mBranchList.size()==1){
					Intent appointmentRelatedIntent=new Intent();
					appointmentRelatedIntent.setClass(BranchSelectActivity.this,CustomerAppointmentRelatedActivity.class);
					appointmentRelatedIntent.putExtra("BranchID",Integer.parseInt(mBranchList.get(0).getID()));
					appointmentRelatedIntent.putExtra("BranchName",mBranchList.get(0).getName());
					startActivity(appointmentRelatedIntent);
					this.finish();
				}
				else{
					branchSelectAdapter =new BranchSelectAdapter(getApplicationContext(),mBranchList);
					branchListView.setAdapter(branchSelectAdapter);
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
	}

	@Override
	public void parseData(WebApiResponse response) {
		ArrayList<Branch> branches = Branch.parseListByJson(response.getStringData());
		response.mData = branches;
	}
}
