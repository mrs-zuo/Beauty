package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CategoryInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.ServiceCategoryView;
import com.glamourpromise.beauty.customer.custom.view.ServiceCategoryView.OnListViewItemClickListener;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.task.CategoryListHttpTask;
import com.glamourpromise.beauty.customer.task.CategoryListHttpTask.ResponseListener;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class ServiceCategoryListActivity extends BaseActivity implements OnClickListener{
	private List<CategoryInformation> categoryInformationList = new ArrayList<CategoryInformation>();
	private String parentCategoryName;
	private ServiceCategoryView serviceCategoryView;
	private CategoryListHttpTask httpTask;
	private String mNextCategoryID;
	private String mCategoryName ;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_service_category_list);
		super.setTitle("服务");
		initActivity();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	
	private void initActivity(){
		serviceCategoryView = new ServiceCategoryView(this);
		serviceCategoryView.setOnListViewItemClickListener(new OnListViewItemClickListener() {
			
			@Override
			public void TurnToServiceActivity(String categoryID, String categoryName) {
				// TODO Auto-generated method stub
				Intent destIntent = new Intent(ServiceCategoryListActivity.this, ServiceListActivity.class);
				destIntent.putExtra("CategoryID",categoryID);
				destIntent.putExtra("CategoryName",categoryName);
				startActivity(destIntent);
			}
			
			@Override
			public void TurnToNextCategory(String nextCategoryID, String categoryName) {
				// TODO Auto-generated method stub
				getNextCategoryListByWebService(nextCategoryID, categoryName);
			}
			
			@Override
			public void BackButtonStatus(int backButtonStatus) {
				// TODO Auto-generated method stub
				
			}
		});
		httpTask = new CategoryListHttpTask(mApp,0,new ResponseListener() {
			@Override
			public void onHandleResponse(WebApiResponse response) {
				// TODO Auto-generated method stub
				ServiceCategoryListActivity.super.dismissProgressDialog();
				if(response.getHttpCode() == 200){
					switch (response.getCode()) {
					case WebApiResponse.GET_WEB_DATA_TRUE:
						if(httpTask.getTaskFlag() == CategoryListHttpTask.BY_CATEGORYID_TASK){
							categoryInformationList = handleCategoryTask(response.getStringData(), mNextCategoryID, mCategoryName);
						}else if(httpTask.getTaskFlag() == CategoryListHttpTask.BY_COMPANYID_TASK){
							categoryInformationList = handleCompanyTask(response.getStringData());
						}
						serviceCategoryView.categoryNotify(categoryInformationList);
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
		getCategoryListByWebService();
	}
	
	private ArrayList<CategoryInformation> handleCompanyTask(String data){
		ArrayList<CategoryInformation> categoryInformationList = new ArrayList<CategoryInformation>();
		try {
			String totalCount = "1";
			JSONArray categoryList = new JSONObject(data).getJSONArray("CategoryList");
			JSONObject item;
			
			int count = categoryList.length();
			
			CategoryInformation categoryInfo = new CategoryInformation();
			categoryInfo.setCategoryID("0");
			categoryInfo.setParentCategoryID(0);
			categoryInfo.setParentCategoryName("全部服务");
			categoryInfo.setTotalCommodityCount(totalCount);
			categoryInfo.setNextCategoryCount(String.valueOf(count));
			categoryInformationList.add(categoryInfo);
			
			parentCategoryName = "全部服务";
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
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
	}
	private void getCategoryListByWebService(){
		httpTask.setTaskFlag(CategoryListHttpTask.BY_COMPANYID_TASK);
		super.asyncRefrshView(httpTask);
	}
	
	public void getNextCategoryListByWebService(String nextCategoryID, String categoryName){
		super.showProgressDialog();
		mNextCategoryID = nextCategoryID;
		mCategoryName = categoryName;
		httpTask.setTaskFlag(CategoryListHttpTask.BY_CATEGORYID_TASK);
		httpTask.setNextCategoryID(nextCategoryID);
		super.asyncRefrshView(httpTask);
	}
}
