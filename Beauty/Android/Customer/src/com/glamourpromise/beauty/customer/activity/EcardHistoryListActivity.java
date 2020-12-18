package com.glamourpromise.beauty.customer.activity;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EcardHistoryListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CardBalanceHistoryInfo;
import com.glamourpromise.beauty.customer.bean.CustomerCardInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class EcardHistoryListActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String CATEGORY_NAME = "Ecard";
	private static final String GET_BALANCE_LIST = "GetBalanceListByCustomerID";
	private List<CustomerCardInfo> cardList = new ArrayList<CustomerCardInfo>();
	private List<CardBalanceHistoryInfo> balanceList = new ArrayList<CardBalanceHistoryInfo>();
	private ListView ecardHistoryListView;
	private CardBalanceHistoryInfo cardBalanceHistoryInfo = new CardBalanceHistoryInfo();
	private int cardListCount = 0;
	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_history_list);
		super.setTitle(getString(R.string.ecard_account_trading_detail));
		ecardHistoryListView = (ListView) findViewById(R.id.ecard_history_listview);
		cardList = (List<CustomerCardInfo>) getIntent().getExtras().getSerializable("CardList");
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		try {
			para.put("CustomerID", mCustomerID);
		} catch (JSONException e) {
			
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(CATEGORY_NAME, GET_BALANCE_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,GET_BALANCE_LIST, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				List<CardBalanceHistoryInfo> tempList = new ArrayList<CardBalanceHistoryInfo>();
				tempList = cardBalanceHistoryInfo.parseListByJsonWithSettingCardType(response.getStringData(),cardList.get(cardListCount).getCardTypeID());
				for (int i = 0; i < tempList.size(); i++) {
						balanceList.add(tempList.get(i));
				}
				EcardHistoryListAdapter listAdapter = new EcardHistoryListAdapter(this, balanceList);
				ecardHistoryListView.setAdapter(listAdapter);
				ecardHistoryListView.setOnItemClickListener(new OnItemClickListener() {

							@Override
							public void onItemClick(AdapterView<?> parent,View view, int position, long id) {
								Intent intent = new Intent();
								intent.putExtra("BalanceID",balanceList.get(position).getBalanceID());
								intent.putExtra("CardType",balanceList.get(position).getCardType());
								intent.putExtra("ChangeType",balanceList.get(position).getChangeType());
								intent.setClass(EcardHistoryListActivity.this,EcardAccountDetailActivity.class);
								startActivity(intent);
							}

						});
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
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

		super.dismissProgressDialog();
	}
	@Override
	public void parseData(WebApiResponse response) {
		
	}
	
}
