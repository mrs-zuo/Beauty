package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.SearchView.OnQueryTextListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CommodityListAdapter;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CommodityInformation;
import com.glamourpromise.beauty.customer.bean.ECardInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

@SuppressLint("NewApi")
public class CommodityListActivity extends BaseActivity implements OnClickListener, OnQueryTextListener, IConnectTask{
	private static final String CATEGORY_NAME = "Commodity";
	private static final String GET_COMMODITY_LIST_BY_CATEGORY = "getCommodityListByCategoryID";
	private static final String GET_COMMODITY_LIST_BY_COMPANY = "getCommodityListByCompanyID";
	private static final String ECARD_CATEGORY = "ECard";
	private static final String GET_ECARD_INFO = "getEcardInfo";
	private static final int GET_ECARD_INFO_FLAG = 1;
	private static final int GET_COMMODITY_LIST_FLAG = 2;
	private int taskFlag;	
	private ListView commodityListView;
	private ECardInformation ecardInformation = new ECardInformation();
	private List<CommodityInformation> commodityList = new ArrayList<CommodityInformation>();
	private String categoryID;
	private UserInfoApplication userInfo;
	// 搜索按钮盒搜索框
	private SearchView searchCommodityView;
	private CommodityListAdapter commodityListAdapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_commodity_list);
		super.setTitle(getIntent().getStringExtra("CategoryName"));
		Intent intent = getIntent();
		categoryID = intent.getStringExtra("CategoryID");
		commodityListView = (ListView) findViewById(R.id.commodity_listview);
		commodityListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				// TODO Auto-generated method stub
				Intent destIntent = new Intent(CommodityListActivity.this, CommodityDetailActivity.class);
				destIntent.putExtra("CommodityCode", String.valueOf(commodityList.get(arg2).getCode()));
				destIntent.putExtra("DiscountPrice", String.valueOf(commodityList.get(arg2).getDiscountPrice()));
				startActivity(destIntent);
			}
		});

		userInfo = (UserInfoApplication)getApplication();
		searchCommodityView = (SearchView) findViewById(R.id.search_commodity);
		int id =searchCommodityView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
		TextView searchText = (TextView)searchCommodityView.findViewById(id);
		searchText.setTextSize(14);
		searchCommodityView.setOnQueryTextListener(this);
		super.showProgressDialog();
		taskFlag = GET_COMMODITY_LIST_FLAG;
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onNewIntent(Intent intent) {
		// TODO Auto-generated method stub
		super.onNewIntent(intent);
	}
	@Override
	public boolean onQueryTextSubmit(String query) {
		// TODO Auto-generated method stub
		return false;
	}

	@SuppressLint("DefaultLocale")
	@Override
	public boolean onQueryTextChange(String newText) {
		// TODO Auto-generated method stub
		newText = newText.toLowerCase();
		List<CommodityInformation> newCommodityList = searchCommodity(newText);
		updateLayout(newCommodityList);
		return false;
	}

	private List<CommodityInformation> searchCommodity(String searchKeyWord) {
		List<CommodityInformation> newCommodityList = new ArrayList<CommodityInformation>();
		for (CommodityInformation commodityInfo :commodityList) {
			if (commodityInfo.getSearchField().contains(searchKeyWord)) {
				newCommodityList.add(commodityInfo);
			}
		}
		return newCommodityList;
	}
	private void updateLayout(final List<CommodityInformation> newCommodityList) {
		commodityListAdapter = new CommodityListAdapter(this,newCommodityList);
		commodityListView.setAdapter(commodityListAdapter);
		commodityListAdapter.notifyDataSetChanged();
		commodityListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				// TODO Auto-generated method stub
				Intent destIntent = new Intent(CommodityListActivity.this, CommodityDetailActivity.class);
				destIntent.putExtra("CommodityCode", String.valueOf(newCommodityList.get(arg2).getCode()));
				destIntent.putExtra("DiscountPrice", String.valueOf(newCommodityList.get(arg2).getDiscountPrice()));
				startActivity(destIntent);
			}
		});
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag == GET_ECARD_INFO_FLAG){
			catoryName = ECARD_CATEGORY;
			methodName = GET_ECARD_INFO;
			
		}else{
			catoryName = CATEGORY_NAME;
			if (categoryID.equals("0")) {
				methodName = GET_COMMODITY_LIST_BY_COMPANY;
			}else{
				methodName = GET_COMMODITY_LIST_BY_CATEGORY;
			}
			try {
				para.put("CategoryID", categoryID);
				para.put("ImageWidth", String.valueOf(180));
				para.put("ImageHeight", String.valueOf(180));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if((taskFlag != GET_ECARD_INFO_FLAG) || (taskFlag == GET_ECARD_INFO_FLAG && response.getCode() != WebApiResponse.GET_WEB_DATA_TRUE)){
			super.dismissProgressDialog();
		}
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == GET_ECARD_INFO_FLAG){
					userInfo.getLoginInformation().setDisCount(ecardInformation.getDisCount());
					taskFlag = GET_COMMODITY_LIST_FLAG;
				}else{
					super.dismissProgressDialog();
					commodityList = (List<CommodityInformation>) response.mData;
					commodityListAdapter=new CommodityListAdapter(CommodityListActivity.this, commodityList);
					commodityListView.setAdapter(commodityListAdapter);
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
		
		super.dismissProgressDialog();
	}

	@Override
	public void parseData(WebApiResponse response) {
		if(taskFlag == GET_COMMODITY_LIST_FLAG){
			ArrayList<CommodityInformation> commodityList = CommodityInformation.parseListByJson(response.getStringData());
			response.mData = commodityList;
		}
	}
}
