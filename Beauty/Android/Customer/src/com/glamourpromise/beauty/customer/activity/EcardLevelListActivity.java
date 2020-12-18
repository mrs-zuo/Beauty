package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.ListView;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EcardDiscountInfoAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.DiscountInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class EcardLevelListActivity extends BaseActivity implements OnClickListener, IConnectTask{
	private static final String CATEGORY_NAME = "Level";
	private static final String GET_DISCOUNT_LIST = "getDiscountListForWebService";
	private ListView ecardLevelListView;
	private String mLevelName="";
	private EcardDiscountInfoAdapter ecardLevelAdapter;
	private ArrayList<DiscountInfo> ecardLevelList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_ecard_level_list);
		mLevelName = getIntent().getStringExtra("LevelName");
		getIntent().getStringExtra("LevelID");
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		((TextView)findViewById(R.id.level_content_text)).setText(mLevelName);
		ecardLevelList = new ArrayList<DiscountInfo>();
		ecardLevelAdapter = new EcardDiscountInfoAdapter(this, ecardLevelList);
		ecardLevelListView = (ListView) findViewById(R.id.ecard_level_listview);
		ecardLevelListView.setAdapter(ecardLevelAdapter);
		
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		switch (v.getId()) {
		case R.id.btn_main_home:
			break;
		case R.id.btn_main_back:
			this.finish();
			break;
		default:
			break;
		}
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("LevelID",0);
			para.put("CustomerID",mCustomerID);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_DISCOUNT_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME, GET_DISCOUNT_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				ArrayList<DiscountInfo> tmp = (ArrayList<DiscountInfo>) response.mData;
				ecardLevelList.clear();
				ecardLevelList.addAll(tmp);
				ecardLevelAdapter.notifyDataSetChanged();
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
		ArrayList<DiscountInfo> tmp = DiscountInfo.parseListByJson(response.getStringData());
		response.mData = tmp;
	}
}