package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.ServiceListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ServiceInformation;
import com.glamourpromise.beauty.customer.presenter.ServicePresenter;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.view.IServiceListView;
@SuppressLint({ "DefaultLocale", "NewApi" })
public class ServiceListActivity extends BaseActivity implements OnClickListener, OnQueryTextListener, IServiceListView{
	private String categoryID;
	private List<ServiceInformation> serviceList;
	private String categroyName;
	private ListView serviceListView;
	//服务搜索框和点击按钮
	private SearchView searchServiceView;
	private ServiceListAdapter serviceListAdapter;
	private ServicePresenter mPresenter;
	int fromSource;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_service_list);
		categoryID = getIntent().getStringExtra("CategoryID");
		categroyName=getIntent().getStringExtra("CategoryName");
		super.setTitle(categroyName);
		fromSource=getIntent().getIntExtra("FROM_SOURCE",0);
		initActivity();
	}
	
	private void initActivity(){
		serviceListView = (ListView) findViewById(R.id.service_listview);
		serviceListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				ServiceInformation service = serviceList.get(position);
				if(fromSource==1){
					Intent it=getIntent();
					Bundle bu = new Bundle();
					bu.putInt("serviceID", service.getID());
					bu.putString("serviceName", service.getName());
					bu.putInt("OrderObjectID", 0);
					bu.putString("serviceCode", service.getCode());
					it.putExtras(bu);
					setResult(RESULT_OK, it);
					finish();
				}else{
					Intent destIntent = new Intent(ServiceListActivity.this, ServiceDetailActivity.class);
					destIntent.putExtra("serviceCode", service.getCode());
					destIntent.putExtra("CategoryID",categoryID);
					destIntent.putExtra("CategoryName",categroyName.toString());
					destIntent.putExtra("PromotionPrice",service.getDiscountPrice());
					startActivity(destIntent);
				}
			}
		});
		searchServiceView = (SearchView) findViewById(R.id.search_service);
		if(searchServiceView == null) {
			   return;
		}  
		int id =searchServiceView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
		TextView searchText = (TextView)searchServiceView.findViewById(id);
		searchText.setTextSize(14);
		searchServiceView.setOnQueryTextListener(this);
		super.showProgressDialog();
		mPresenter = ServicePresenter.getInsance(mApp);
		mPresenter.setView(this);
		mPresenter.loadServiceList(categoryID);
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		mPresenter.setView(null);
	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
	}

	@Override
	public boolean onQueryTextSubmit(String query) {
		return false;
	}

	@Override
	public boolean onQueryTextChange(String newText) {
		List<ServiceInformation> newServiceList = searchService(newText);
		updateLayout(newServiceList);
		return false;
	}

	private List<ServiceInformation> searchService(String searchKeyWord) {
		List<ServiceInformation> newServiceList = new ArrayList<ServiceInformation>();
		if(searchKeyWord!=null && !(("").equals(searchKeyWord))){
			for (ServiceInformation service :serviceList) {
				if(service.getSearchField()!=null && !(("").equals(service.getSearchField()))){
					if (service.getSearchField().contains(searchKeyWord.toLowerCase())) {
						newServiceList.add(service);
					}
				}
			}
		}else{
			newServiceList.addAll(serviceList);
		}
		return newServiceList;
	}
	private void updateLayout(final List<ServiceInformation> newServiceList) {
		serviceListAdapter = new ServiceListAdapter(this,newServiceList);
		serviceListView.setAdapter(serviceListAdapter);
		serviceListAdapter.notifyDataSetChanged();
		serviceListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				// TODO Auto-generated method stub
				Intent destIntent = new Intent(ServiceListActivity.this, ServiceDetailActivity.class);
				destIntent.putExtra("serviceCode", newServiceList.get(arg2).getCode());
				destIntent.putExtra("PromotionPrice",newServiceList.get(arg2).getDiscountPrice());
				startActivity(destIntent);
			}
		});
	}
	
	@Override
	public void renderView(ArrayList<ServiceInformation> serviceList) {
		super.dismissProgressDialog();
		this.serviceList = serviceList;
		serviceListAdapter=new ServiceListAdapter(ServiceListActivity.this, serviceList);
		serviceListView.setAdapter(serviceListAdapter);
	}

	@Override
	public void renderError(String message) {
		super.dismissProgressDialog();
		DialogUtil.createShortDialog(getApplicationContext(),message);
	}
}
