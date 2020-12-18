package com.glamourpromise.beauty.customer.activity;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.CardBalanceHistoryListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CardBalanceHistoryInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;

public class EcardBalanceHistoryActivity extends BaseActivity implements
		IConnectTask {
	private static final String CATEGORY_NAME = "Ecard";
	private static final String GET_BALANCE_HISTORY = "GetCardBalanceByUserCardNo";
	private static final int GET_BALANCE_HISTORY_FLAG = 1;
	private List<CardBalanceHistoryInfo> balanceHistoryList = new ArrayList<CardBalanceHistoryInfo>();
	private CardBalanceHistoryInfo balanceHistory = new CardBalanceHistoryInfo();
	private ListView historyListView;
	private CardBalanceHistoryListAdapter listAdapter;
	private int taskFlag;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_balance_history_list);
		super.setTitle(getString(R.string.ecard_balance_detail_title));
		initView();
		super.showProgressDialog();
		taskFlag = GET_BALANCE_HISTORY_FLAG;
		super.asyncRefrshView(this);
	}

	private void initView() {
		historyListView = (ListView) findViewById(R.id.ecard_history_listview);
	}

	@Override
	protected void onResume() {
		super.onResume();
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		if (taskFlag == GET_BALANCE_HISTORY_FLAG) {
			try {
				para.put("CustomerID", mCustomerID);
				para.put("UserCardNo",getIntent().getExtras().getString("UserCardNo"));
				para.put("CardType",getIntent().getExtras().getInt("CardType", 0));
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				CATEGORY_NAME, GET_BALANCE_HISTORY, para.toString());
		WebApiRequest request = new WebApiRequest(CATEGORY_NAME,
				GET_BALANCE_HISTORY, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_BALANCE_HISTORY_FLAG) {
					balanceHistoryList = balanceHistory.parseListByJson(response.getStringData());
					for(CardBalanceHistoryInfo cbhi:balanceHistoryList)
						cbhi.setCardType(getIntent().getExtras().getInt("CardType", 0));
					initListView(balanceHistoryList);
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
				DialogUtil.createShortDialog(getApplicationContext(),Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
	}

	@Override
	public void parseData(WebApiResponse response) {
	}

	private void initListView(List<CardBalanceHistoryInfo> history) {
		listAdapter = new CardBalanceHistoryListAdapter(
				EcardBalanceHistoryActivity.this, history);
		historyListView.setAdapter(listAdapter);

		historyListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				Intent intent = new Intent();
				intent.setClass(EcardBalanceHistoryActivity.this,
						EcardAccountDetailActivity.class);
				intent.putExtra("BalanceID", balanceHistoryList.get(position)
						.getBalanceID());
				intent.putExtra("ChangeType", balanceHistoryList.get(position)
						.getChangeType());
				intent.putExtra("CardType",
						getIntent().getExtras().getInt("CardType"));
				startActivity(intent);
			}

		});
	}

}
