package com.glamourpromise.beauty.customer.activity;

import org.json.JSONException;
import org.json.JSONObject;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.adapter.EcardDiscountInfoAdapter;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.ECardInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.view.NoScrollListView;

public class EcardDetailActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String ECARD_CATEGORY = "ECard";
	private static final String UPDATE_DEFAULT_CARD = "UpdateCustomerDefaultCard";
	private static final int UPDATE_DEFAULT_CARD_FLAG = 1;
	private int taskFlag;
	private ECardInformation ecardInformation = new ECardInformation();
	private TextView balanceView;
	private TextView cardNameView;
	private TextView realCardNumberView;
	private TextView ecardNumberView;
	private TextView tvExpirationTime;
	private TextView cardTypeContent;
	private TextView accountDiscription;
	private ImageView ivExpirationTimeOverdue;
	private NoScrollListView cardDiscountList;
	private EcardDiscountInfoAdapter discountAdapter;
	private View descriptionDivider;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_detail);
		super.setTitle(getString(R.string.title_ecard_detail));
		initView();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@SuppressLint("CutPasteId")
	protected void initView() {
		balanceView = (TextView) findViewById(R.id.customer_ecard_balance);
		cardNameView = (TextView) findViewById(R.id.ecard_detail_layout_card_name);
		ecardNumberView = (TextView) findViewById(R.id.ecard_number);
		realCardNumberView = (TextView) findViewById(R.id.real_card_number);
		tvExpirationTime = (TextView) findViewById(R.id.responsible_expirationtime);
		ivExpirationTimeOverdue = (ImageView) findViewById(R.id.expirationtime_overdue_prompt);
		cardTypeContent = (TextView) findViewById(R.id.ecard_card_type_content);
		accountDiscription = (TextView) findViewById(R.id.ecard_account_description_content);
		cardDiscountList = (NoScrollListView) findViewById(R.id.card_discount_list);
		descriptionDivider = (View) findViewById(R.id.card_account_description_divider);
		TableLayout balanceHistoryBtn = (TableLayout) findViewById(R.id.layout_balance_history);
		balanceHistoryBtn.setOnClickListener(this);
		initValue();
	}

	private void initValue() {
		Intent intent = getIntent();
		ecardInformation = (ECardInformation) intent.getExtras().getSerializable("EcardInformation");
		if(intent.getBooleanExtra("isDefault",false))
			findViewById(R.id.customer_ecard_is_default).setVisibility(View.VISIBLE);
		else
			findViewById(R.id.customer_ecard_is_default).setVisibility(View.GONE);
		cardNameView.setText(ecardInformation.getCardName());
		ecardNumberView.setText("No." + ecardInformation.getUserCardNo());
		if (!ecardInformation.getRealCardNo().equals(""))
			realCardNumberView.setText("实体卡号："+ ecardInformation.getRealCardNo());
		if(ecardInformation.getCardType()!=2)
			balanceView.setText(NumberFormatUtil.StringFormatToString(this,ecardInformation.getBalance()));
		else
			balanceView.setText(NumberFormatUtil.FloatFormatToStringWithoutSingle(Float.valueOf(ecardInformation.getBalance())));
		
		tvExpirationTime.setText(ecardInformation.getExpirationDate());
			
		if (ecardInformation.isExpiration())
			ivExpirationTimeOverdue.setVisibility(View.GONE);
		else
			ivExpirationTimeOverdue.setVisibility(View.VISIBLE);
		cardTypeContent.setText(ecardInformation.getCardTypeName());
		if (ecardInformation.getCardDescription().length() > 0) {
			descriptionDivider.setVisibility(View.VISIBLE);
			accountDiscription.setText(ecardInformation.getCardDescription());
		} else {
			descriptionDivider.setVisibility(View.GONE);
			accountDiscription.setVisibility(View.GONE);
		}

		discountAdapter = new EcardDiscountInfoAdapter(this,
				ecardInformation.getDiscountList());
		cardDiscountList.setAdapter(discountAdapter);
	}
	@Override
	public void onClick(View view) {
		super.onClick(view);
		Intent destIntent;
		switch (view.getId()) {
		case R.id.layout_balance_history:
			destIntent = new Intent(this, EcardBalanceHistoryActivity.class);
			destIntent.putExtra("UserCardNo", ecardInformation.getUserCardNo());
			destIntent.putExtra("CardType", ecardInformation.getCardType());
			destIntent.putExtra("CardName", ecardInformation.getCardName());
			startActivity(destIntent);
			break;
		}
	}

	/*
	 * qrType:二维码类型: 0:顾客 、1:商品、2:服务 sizeType:二维码大小: 0:小图、1：大图
	 */

	@Override
	public WebApiRequest getRequest() {
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if (taskFlag == UPDATE_DEFAULT_CARD_FLAG) {
			catoryName = ECARD_CATEGORY;
			methodName = UPDATE_DEFAULT_CARD;
			try {
				para.put("CustomerID", mCustomerID);
				para.put("UserCardNo", ecardInformation.getUserCardNo());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
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
}
