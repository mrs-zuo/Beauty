package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.SearchView.OnQueryTextListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.AccountListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.AccountInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

@SuppressLint("NewApi")
public class AccountListActivity extends BaseActivity implements OnClickListener, OnItemClickListener, OnQueryTextListener, IConnectTask {
	private static final String CATEGORY_NAME = "account";
	private static final String GET_ACCOUNT_LIST = "getAccountListForCustomer";	
	private NewRefreshListView  accountListView;
	private List<AccountInformation> accountInformationList = new ArrayList<AccountInformation>();
	private int      branchID;
	private AccountListAdapter accountListAdapter;
	private String flag;
    int fromSource=0;
    private SearchView searchView;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_account_list);
		Intent intent = getIntent();
		flag = intent.getStringExtra("flag");// 0：取公司所有的服务人员列表；1：取总店的；2：取分店的
		branchID = intent.getIntExtra("branchID",0);
		fromSource=intent.getIntExtra("FROM_SOURCE", 0);
		searchView=(SearchView) findViewById(R.id.search_account);
		int id =searchView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
		TextView searchText = (TextView)searchView.findViewById(id);
		searchText.setTextSize(14);
		searchView.setOnQueryTextListener(this);
		if(fromSource==0){
			findViewById(R.id.head_rl).setVisibility(View.GONE);
			searchView.setVisibility(View.GONE);
		}else{
			findViewById(R.id.head_rl).setVisibility(View.VISIBLE);
			findViewById(R.id.btn_main_back).setOnClickListener(this);
			findViewById(R.id.btn_main_home).setOnClickListener(this);
			searchView.setVisibility(View.VISIBLE);
		}
		initView();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	protected void initView() {
		accountListView = (NewRefreshListView) findViewById(R.id.account_listview);
		accountListView.setOnItemClickListener(this);
		//设置listView下拉刷新调用的接口
		accountListView.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				AccountListActivity.super.asyncRefrshView(AccountListActivity.this);
			}

		});
		super.asyncRefrshView(this);
	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		return super.onKeyDown(keyCode, event);
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		Intent destIntent;
		if(fromSource==0){
			destIntent = new Intent(this, AccountDetailActivity.class);
			destIntent.putExtra("AccountID",accountListAdapter.getAccountList().get(position - 1).getAccountID());
			startActivity(destIntent);
		}else{
			destIntent = new Intent();
			destIntent.putExtra("AccountID",Integer.parseInt(accountListAdapter.getAccountList().get(position - 1).getAccountID()));
			destIntent.putExtra("AccountName",accountListAdapter.getAccountList().get(position - 1).getAccountName());
			setResult(RESULT_OK,destIntent);
			finish();
		}
	}

	@Override
	public boolean onQueryTextChange(String newText) {
		newText = newText.toLowerCase();
		List<AccountInformation> newAccountList = searchCustomer(newText);
		updateLayout(newAccountList);
		return false;
	}

	private List<AccountInformation> searchCustomer(String name) {
		List<AccountInformation> newCustomerList = new ArrayList<AccountInformation>();
		for (AccountInformation accountInformation :accountInformationList) {
			if (accountInformation.getPinYin().contains(name) || accountInformation.getPinYinFirst().contains(name) || accountInformation.getAccountName().contains(name)) {
				newCustomerList.add(accountInformation);
			}
		}
		return newCustomerList;
	}

	@Override
	public boolean onQueryTextSubmit(String arg0) {
		return false;
	}

	private void updateLayout(List<AccountInformation> newAccountList) {
		if (null != newAccountList && newAccountList.size() != 0) {
			accountListAdapter=new AccountListAdapter(AccountListActivity.this,newAccountList,fromSource);
			accountListView.setAdapter(accountListAdapter);
			accountListAdapter.notifyDataSetChanged();
		} else {
			accountListAdapter=new AccountListAdapter(this,accountInformationList,fromSource);
			accountListView.setAdapter(accountListAdapter);
			accountListAdapter.notifyDataSetChanged();
		}
	}
	@Override
	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerID", mCustomerID);
			para.put("CompanyID", mCompanyID);
			para.put("Flag", flag);
			para.put("BranchID", branchID);
			para.put("ImageWidth",100);
			para.put("ImageHeight",100);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_ACCOUNT_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_ACCOUNT_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				accountInformationList = (List<AccountInformation>) response.mData;
				accountListAdapter = new AccountListAdapter(this,accountInformationList,fromSource);
				accountListView.setAdapter(accountListAdapter);				
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
		accountListView.onRefreshComplete();
	}

	@Override
	public void parseData(WebApiResponse response) {
		if(response.getHttpCode() == 200 && response.getCode() == WebApiResponse.GET_WEB_DATA_TRUE){
			ArrayList<AccountInformation> accounts = AccountInformation.parseListByJson(response.getStringData());
			response.mData = accounts;
		}
	}
}
