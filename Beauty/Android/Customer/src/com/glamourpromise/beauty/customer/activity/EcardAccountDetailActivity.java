package com.glamourpromise.beauty.customer.activity;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EcardBalanceInfoListAdapter;
import com.glamourpromise.beauty.customer.adapter.EcardBalanceOrderListAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.BalanceDetailInfo;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class EcardAccountDetailActivity extends BaseActivity implements
		IConnectTask {
	private static final String CATEGORY_NAME = "Ecard";
	private static final String GET_BALANCE_Detail = "GetBalanceDetailInfo";
	private static final int GET_BALANCE_DETAIL_FLAG = 1;
	private BalanceDetailInfo balanceDetail = new BalanceDetailInfo();
	private TextView ecardBalanceID;
	private TextView tradingTime;
	private TextView branchName;
	private TextView tradingType;
	private TextView operator;
	private TextView changeTypeAmountTitle;
	private TextView changeTypeAmount;
	private NoScrollListView balanceInfoListView;
	private NoScrollListView orderListView;
	private EcardBalanceInfoListAdapter listAdapter;
	private EcardBalanceOrderListAdapter orderListAdapter;
	private int taskFlag;
	private LayoutInflater layoutInflater;
	RelativeLayout titleLayout;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_account_detail);
		super.setTitle(getString(R.string.ecard_account_balance_detail_title));
		super.showProgressDialog();
		initView();
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);

	}

	private void initView() {
		ecardBalanceID = (TextView) findViewById(R.id.ecard_balance_id_content);
		tradingTime = (TextView) findViewById(R.id.ecard_balance_create_time_content);
		branchName = (TextView) findViewById(R.id.ecard_trading_branch_name_content);
		tradingType = (TextView) findViewById(R.id.ecard_trading_type_content);
		operator = (TextView) findViewById(R.id.ecard_account_operator_content);
		changeTypeAmountTitle = (TextView) findViewById(R.id.ecard_change_type_amount_title);
		changeTypeAmount = (TextView) findViewById(R.id.ecard_card_type_amount_content);
		balanceInfoListView = (NoScrollListView) findViewById(R.id.balance_info_list_view);
		orderListView = (NoScrollListView) findViewById(R.id.order_list_info_list_view);
	}

	private void initValue() {
		ecardBalanceID.setText("" + balanceDetail.getBalanceNumber());
		tradingTime.setText(balanceDetail.getCreateTime());
		branchName.setText(balanceDetail.getBranchName());
		tradingType.setText(balanceDetail.getChangeTypeName());
		operator.setText(balanceDetail.getOperator());
		changeTypeAmountTitle.setText(balanceDetail.getChangeTypeName()+ this.getResources().getString(R.string.ecard_change_type_amount_title));
		changeTypeAmount.setText(NumberFormatUtil.StringFormatToString(this,String.valueOf(Math.abs(Float.parseFloat(balanceDetail.getAmount())))));
		listAdapter = new EcardBalanceInfoListAdapter(this,balanceDetail.getBalanceInfoList());
		balanceInfoListView.setAdapter(listAdapter);
		balanceInfoListView.setEnabled(false);
		orderListAdapter = new EcardBalanceOrderListAdapter(this,balanceDetail.getOrderList());
		orderListView.setAdapter(orderListAdapter);
		orderListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				OrderBaseInfo orderDetail = new OrderBaseInfo();
				orderDetail.setProductType(balanceDetail.getOrderList().get(position).getProductType());
				orderDetail.setOrderObjectID(balanceDetail.getOrderList().get(position).getOrderObjectID());
				orderDetail.setOrderID(balanceDetail.getOrderList().get(position).getOrderID());
				Intent destIntent = new Intent();
				Bundle bundle = new Bundle();
				bundle.putSerializable("OrderItem", orderDetail);
				destIntent.putExtras(bundle);
				if (balanceDetail.getOrderList().get(position).getProductType().equals("0"))
					destIntent.setClass(EcardAccountDetailActivity.this,ServcieOrderDetailActivity.class);
				else
					destIntent.setClass(EcardAccountDetailActivity.this,CommodityOrderDetailActivity.class);
				startActivity(destIntent);
			}

		});
	}

	@Override
	protected void onResume() {
		super.onResume();
		taskFlag = GET_BALANCE_DETAIL_FLAG;
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String category = "";
		String destination = "";
		JSONObject para = new JSONObject();
		if (taskFlag == GET_BALANCE_DETAIL_FLAG) {
			category = CATEGORY_NAME;
			destination = GET_BALANCE_Detail;
			try {
				para.put("ID", getIntent().getIntExtra("BalanceID", 0));
				para.put("CardType", getIntent().getIntExtra("CardType", 1));
				para.put("ChangeType", getIntent().getIntExtra("ChangeType", 0));
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(category, destination, para.toString());
		WebApiRequest request = new WebApiRequest(category, destination,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				balanceDetail.parseByJson(response.getStringData());
				initValue();
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
