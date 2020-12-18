package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CategoryListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CategoryInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.task.CategoryListHttpTask;
import com.glamourpromise.beauty.customer.task.CategoryListHttpTask.ResponseListener;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class CommodityCategoryListActivity extends BaseActivity implements OnClickListener, OnItemClickListener {
	private ListView categoryListView;
	private String parentCategoryName;
	private List<CategoryInformation> categoryInformationList = new ArrayList<CategoryInformation>();
	private Stack<List<CategoryInformation>> categoryInformationListStack = new Stack<List<CategoryInformation>>();
	private CategoryListHttpTask httpTask;
	private String mNextCategoryID;
	private String mCategoryName ;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_commodity_category_list);
		super.setTitle(getString(R.string.title_category_list));
		categoryListView = (ListView) findViewById(R.id.category_listview);
		categoryListView.setOnItemClickListener(this);
		parentCategoryName = getString(R.string.all_commodity);
		initView();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		categoryInformationListStack.clear();
		parentCategoryName = getString(R.string.all_commodity);
		((CategoryListAdapter)categoryListView.getAdapter()).clearList();
		initView();
	}

	protected void initView() {
		super.showProgressDialog();
		categoryInformationList = new ArrayList<CategoryInformation>();
		httpTask = new CategoryListHttpTask(mApp,1,new ResponseListener() {
			
			@Override
			public void onHandleResponse(WebApiResponse response) {
				// TODO Auto-generated method stub
				CommodityCategoryListActivity.super.dismissProgressDialog();
				if(response.getHttpCode() == 200){
					switch (response.getCode()) {
					case WebApiResponse.GET_WEB_DATA_TRUE:
						if(httpTask.getTaskFlag() == CategoryListHttpTask.BY_CATEGORYID_TASK){
							categoryInformationList = handleCategoryTask(response.getStringData(), mNextCategoryID, mCategoryName);
							updateLayout(categoryInformationList);
						}else if(httpTask.getTaskFlag() == CategoryListHttpTask.BY_COMPANYID_TASK){
							categoryInformationList = handleCompanyTask(response.getStringData());
							categoryListView.setAdapter(new CategoryListAdapter(CommodityCategoryListActivity.this,categoryInformationList));
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
		});
		httpTask.setTaskFlag(CategoryListHttpTask.BY_COMPANYID_TASK);
		super.asyncRefrshView(httpTask);
	}
	
	private ArrayList<CategoryInformation> handleCompanyTask(String data){
		ArrayList<CategoryInformation> categoryInformationList = new ArrayList<CategoryInformation>();
		try {
			JSONArray categoryList =new JSONObject(data).getJSONArray("CategoryList");
			String totalCount = "1";
			JSONObject item;
			int count = categoryList.length();
			CategoryInformation categoryInfo = new CategoryInformation();
			categoryInfo.setCategoryID("0");
			categoryInfo.setParentCategoryID(0);
			categoryInfo.setParentCategoryName("全部商品");
			categoryInfo.setTotalCommodityCount(totalCount);
			categoryInfo.setNextCategoryCount(String.valueOf(count));
			categoryInformationList.add(categoryInfo);
			parentCategoryName = "全部商品";
			for (int i = 0; i < count; i++) {
				item = categoryList.getJSONObject(i);
				categoryInfo = new CategoryInformation();
				categoryInfo.setTotalCommodityCount(totalCount);
				categoryInfo.setParentCategoryName(parentCategoryName);
				categoryInfo.setCommodityCount("1");
				categoryInfo.setCategoryID(item.getString("CategoryID"));
				categoryInfo.setCategoryName(item.getString("CategoryName"));
				categoryInfo.setNextCategoryCount(item.getString("NextCategoryCount"));
				categoryInformationList.add(categoryInfo);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return categoryInformationList;
	}
	
	private ArrayList<CategoryInformation> handleCategoryTask(String data, String nextCategoryID, String categoryName ){
		ArrayList<CategoryInformation> categoryInformationList = new ArrayList<CategoryInformation>();
		try {
			JSONArray categoryList = new JSONObject(data).getJSONArray("CategoryList");
			String totalCount = "1";
			JSONObject item;
			int count = categoryList.length();
			categoryInformationList = new ArrayList<CategoryInformation>();
			CategoryInformation categoryInfo = new CategoryInformation();
			categoryInfo.setCategoryID(nextCategoryID);
			categoryInfo.setParentCategoryID(Integer.valueOf(nextCategoryID));
			categoryInfo.setCategoryName(categoryName);
			categoryInfo.setParentCategoryName(categoryName);
			categoryInfo.setTotalCommodityCount(totalCount);
			categoryInfo.setNextCategoryCount(String.valueOf(count));
			categoryInformationList.add(categoryInfo);
			for (int i = 0; i < count; i++) {
				item = categoryList.getJSONObject(i);
				categoryInfo = new CategoryInformation();
				categoryInfo.setTotalCommodityCount(totalCount);
				categoryInfo.setParentCategoryName(categoryName);
				categoryInfo.setParentCategoryID(Integer.valueOf(nextCategoryID));
				categoryInfo.setCommodityCount("1");
				categoryInfo.setCategoryID(item.getString("CategoryID"));
				categoryInfo.setCategoryName(item.getString("CategoryName"));
				categoryInfo.setNextCategoryCount(item.getString("NextCategoryCount"));
				categoryInformationList.add(categoryInfo);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return categoryInformationList;
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		if (position == 0) {
			Intent destIntent = new Intent(this, CommodityListActivity.class);
			destIntent.putExtra("CategoryID", String.valueOf(categoryInformationList.get(position).getParentCategoryID()));
			destIntent.putExtra("CategoryName", categoryInformationList.get(position).getParentCategoryName());
			startActivity(destIntent);
		}
		else {
			if (Integer.parseInt(categoryInformationList.get(position).getNextCategoryCount()) != 0) {
				categoryInformationListStack.push(categoryInformationList);
				parentCategoryName = categoryInformationList.get(position).getCategoryName();
				getNextCategoryList(categoryInformationList.get(position).getCategoryID(), categoryInformationList.get(position).getCategoryName());
			} else {
				if (Integer.parseInt(categoryInformationList.get(position).getCommodityCount()) != 0) {
					Intent destIntent = new Intent(this,CommodityListActivity.class);
					destIntent.putExtra("CategoryID",String.valueOf(categoryInformationList.get(position).getCategoryID()));
					destIntent.putExtra("CategoryName", categoryInformationList.get(position).getCategoryName());
					startActivity(destIntent);
				}
			}
		}
	}

	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_BACK) {
			if (categoryInformationListStack.size() >= 1) {
				categoryInformationList = categoryInformationListStack.pop();
				updateLayout(categoryInformationList);
				return true;
			} 
		}
		return super.onKeyDown(keyCode, event);
	}

	private void getNextCategoryList(String nextCategoryID, String parentCategoryName) {
		mNextCategoryID = nextCategoryID;
		mCategoryName = parentCategoryName;
		httpTask.setNextCategoryID(nextCategoryID);
		httpTask.setTaskFlag(CategoryListHttpTask.BY_CATEGORYID_TASK);
		super.showProgressDialog();
		super.asyncRefrshView(httpTask);
	}

	private void updateLayout(List<CategoryInformation> newCategoryList) {
		categoryListView.setAdapter(new CategoryListAdapter(this, newCategoryList));
	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.btn_main_back:
			if (!categoryInformationListStack.isEmpty()) {
				categoryInformationList = categoryInformationListStack.pop();
				updateLayout(categoryInformationList);
			}
			break;
		default:
			break;
		}
	}
}
