package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.RelativeLayout;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.PromotionListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.PromotionInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView;
import com.glamourpromise.beauty.customer.custom.view.NewRefreshListView.OnRefreshListener;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class BranchPromotionActivity extends BaseActivity implements OnClickListener, OnItemClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Promotion";
	private static final String GET_PROMOTION_LIST = "GetPromotionList";
	private ArrayList<PromotionInformation> promotionList;
	private NewRefreshListView promotionListview;
	private PromotionListAdapter promotionListAdapter;
    int fromSource=0;
    RelativeLayout headLayout;
    int branchID=0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_branch_promotion);
		headLayout=(RelativeLayout)findViewById(R.id.head_layout);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		Intent it=getIntent();
		fromSource=it.getIntExtra("FROM_SOURCE", 0);
		branchID=it.getIntExtra("BranchID", 0);
        if(fromSource==0){
        	headLayout.setVisibility(View.VISIBLE);
        }else{
        	headLayout.setVisibility(View.GONE);
        }
		initView();
	}

	private void initView() {
		promotionListview = (NewRefreshListView) findViewById(R.id.promotion_listview);
		promotionListview.setOnItemClickListener(this);
		// 设置listView下拉刷新调用的接口
		promotionListview.setonRefreshListener(new OnRefreshListener() {
			@Override
			public void onRefresh() {
				BranchPromotionActivity.super.asyncRefrshView(BranchPromotionActivity.this);
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
	public WebApiRequest getRequest() {
		JSONObject para=new JSONObject();
		String categoryName = "";
		String methodName = "";
		categoryName = CATEGORY_NAME;
		methodName = GET_PROMOTION_LIST;
			try {
				para.put("ImageWidth",300);
				para.put("ImageHeight",224);
				para.put("BranchID", branchID);
			} catch (JSONException e) {
				e.printStackTrace();
			}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				promotionList = PromotionInformation.parseListByJson(response.getStringData());
				promotionListAdapter = new PromotionListAdapter(this,promotionList);
				promotionListview.setAdapter(promotionListAdapter);
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				//当登陆异常时，则退出到登陆页
				mApp.AppExitToLoginActivity(this);
				Editor editor=mApp.getSharedPreferences().edit();
				editor.putBoolean("autoLogin",false);
				editor.commit();
				break;
			case WebApiResponse.GET_DATA_NULL:
				break;
			case WebApiResponse.PARSING_ERROR:
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
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

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		Intent destIntent = new Intent();
		destIntent.setClass(this, PromotionDetailActivity.class);
		destIntent.putExtra("PromotionCode", promotionList.get(position -1).getPromotionCode());
		startActivity(destIntent);
	}
}
