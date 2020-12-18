package com.glamourpromise.beauty.customer.activity;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.FavoriteListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.FavoriteInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class FavoriteListActivity extends BaseActivity implements OnClickListener,IConnectTask,OnItemClickListener{
	private static final String CATEGROY_NAME="Customer";
	private static final String GET_FAVORITE_LIST = "GetFavorteList";
	private List<FavoriteInfo> favoriteList;
	private ListView           favoriteListView;
	private FavoriteListAdapter favoriteListAdapter;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_my_favorite);
		super.setTitle(getString(R.string.my_favorite_title_text));
		initView();
	}
	
	private void initView(){
		favoriteListView=(ListView)findViewById(R.id.my_favorite_listview);
		favoriteListView.setOnItemClickListener(this);
		super.showProgressDialog();
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
	protected void onRestart() {
		super.onRestart();
		super.asyncRefrshView(this);
	}	
	@Override
	public WebApiRequest getRequest() {
		JSONObject jsonPara=new JSONObject();
		try {
			jsonPara.put("ImageWidth", String.valueOf(180));
			jsonPara.put("ImageHeight", String.valueOf(180));
			jsonPara.put("ProductType",-1);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGROY_NAME,GET_FAVORITE_LIST,jsonPara.toString());
		WebApiRequest request = new WebApiRequest(CATEGROY_NAME,GET_FAVORITE_LIST,jsonPara.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				favoriteList = FavoriteInfo.parseFavoriteListByJson(response.getStringData());
				favoriteListAdapter = new FavoriteListAdapter(this,favoriteList);
				favoriteListView.setAdapter(favoriteListAdapter);
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
	public void onItemClick(AdapterView<?> parent, View view, int position,long id) {
		int productType=favoriteList.get(position).getProductType();
		Intent destIntent=null;
		if(productType==0){
			destIntent=new Intent(this,ServiceDetailActivity.class);
			destIntent.putExtra("serviceCode",String.valueOf(favoriteList.get(position).getProductCode()));
		}
		else if(productType==1){
			destIntent=new Intent(this,CommodityDetailActivity.class);
			destIntent.putExtra("CommodityCode",String.valueOf(favoriteList.get(position).getProductCode()));
		}
		startActivity(destIntent);
	}
}
