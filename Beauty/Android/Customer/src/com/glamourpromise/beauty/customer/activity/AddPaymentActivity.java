package com.glamourpromise.beauty.customer.activity;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.OrderPayListInfo;
import com.glamourpromise.beauty.customer.bean.OrderPayment;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.util.AmountConvertToCapital;
import com.glamourpromise.beauty.customer.util.DateUtil;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class AddPaymentActivity extends BaseActivity implements OnClickListener, IConnectTask {
	private static final String PAYMENT_CATEGORY = "Payment";
	private static final String GET_PAYMENT = "GetPaymentInfo";
	private static final String ADD_PAYMENT = "AddPayment";
	private List<OrderPayListInfo> orderList;
	private OrderPayment   op;
	private int taskFlag=1;
	private TextView cardNameText;
	private TextView rateTxt;
	private TextView presentRateTxt;
	private TextView balance;
	private TextView expirationtime;
	private Button paymentButton;
	private static int  GET_PAYMENT_FLAG=1;
	private static int  ADD_PAYMENT_FLAG=2;
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_order_pay_adding);
		super.setTitle(getString(R.string.title_order_pay));
		super.showProgressDialog();
		initAcitivity();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	private void initAcitivity() {
		orderList = (List<OrderPayListInfo>) getIntent().getSerializableExtra("OrderPayList");
		taskFlag = GET_PAYMENT_FLAG;
		super.asyncRefrshView(this);
		
	}

	private void initValue() {
		TextView orderQuantity = (TextView) findViewById(R.id.order_quantity);
		TextView orderTotalPrice = (TextView) findViewById(R.id.order_totalprice);
		TextView orderPaymentPrice = (TextView) findViewById(R.id.order_pay_payment_price);
		TextView orderPaymentPriceCapital = (TextView) findViewById(R.id.order_pay_payment_price_capital);
		paymentButton = (Button)findViewById(R.id.ensure_payment_btn);
		cardNameText = (TextView) findViewById(R.id.order_pay_card_name);
		rateTxt = (TextView) findViewById(R.id.order_payment_bonus);
		presentRateTxt = (TextView) findViewById(R.id.order_payment_ticket);
		balance = (TextView) findViewById(R.id.balance);
		expirationtime = (TextView) findViewById(R.id.ecard_expirationtime);
		orderQuantity.setText(String.valueOf(orderList.size()));
		orderTotalPrice.setText(NumberFormatUtil.StringFormatToString(this,op.getTotalOrigPrice()));
		orderPaymentPrice.setText(NumberFormatUtil.StringFormatToString(this,op.getUnPaidPrice()));
		orderPaymentPriceCapital.setText(AmountConvertToCapital.parse(op.getUnPaidPrice()));
		cardNameText.setText(op.getCardName());
		expirationtime.setText(DateUtil.getFormateDateByString(op.getExpirationDate()));
		balance.setText(NumberFormatUtil.StringFormatToString(this,op.getBalance()));
		if(Double.valueOf(op.getGivePointAmount())==0 && Double.valueOf(op.getGiveCouponAmount())==0)
			findViewById(R.id.activity_order_pay_adding_payment_ticket_and_bonus_layout).setVisibility(View.GONE);
		else{
			findViewById(R.id.activity_order_pay_adding_payment_ticket_and_bonus_layout).setVisibility(View.VISIBLE);
			if(Double.valueOf(op.getGivePointAmount())!=0 && Double.valueOf(op.getGiveCouponAmount())!=0){
				rateTxt.setText(NumberFormatUtil.FloatFormatToStringWithoutSingle(Double.valueOf(op.getGivePointAmount())));
				presentRateTxt.setText(NumberFormatUtil.StringFormatToString(this,op.getGiveCouponAmount()));
			}
			else if(Double.valueOf(op.getGivePointAmount())==0 && Double.valueOf(op.getGiveCouponAmount())!=0){
				findViewById(R.id.activity_order_pay_adding_paymtent_bonus_layout).setVisibility(View.GONE);
				findViewById(R.id.activity_order_pay_adding_paymtent_bonus_divider).setVisibility(View.GONE);
				presentRateTxt.setText(NumberFormatUtil.StringFormatToString(this,op.getGiveCouponAmount()));
			}
			else if(Double.valueOf(op.getGiveCouponAmount())==0 && Double.valueOf(op.getGivePointAmount())!=0){
				findViewById(R.id.activity_order_pay_adding_paymtent_bonus_divider).setVisibility(View.GONE);
				findViewById(R.id.activity_order_pay_adding_paymtent_ticket_layout).setVisibility(View.GONE);
				rateTxt.setText(NumberFormatUtil.StringFormatToString(this,op.getGivePointAmount()));
			}
		}
		paymentButton.setOnClickListener(this);
	}
	@Override
	public void onClick(View view) {
		super.onClick(view);
		switch (view.getId()) {
		case R.id.ensure_payment_btn:
			taskFlag=ADD_PAYMENT_FLAG;
			super.asyncRefrshView(this);
			break;
		}
	}
	@Override
	public WebApiRequest getRequest() {
		String categoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if (taskFlag == GET_PAYMENT_FLAG) {
			categoryName = PAYMENT_CATEGORY;
			methodName =GET_PAYMENT;
			try {
				JSONArray orderJsonArray=new JSONArray();
				for(OrderPayListInfo oi:orderList){
					JSONObject orderJson=new JSONObject();
					orderJson.put("OrderID",oi.getOrderID());
					orderJson.put("ProductType",oi.getProductType());
					orderJson.put("OrderObjectID",oi.getOrderObjectID());
					orderJsonArray.put(orderJson);
				}
				para.put("OrderList",orderJsonArray);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
			}
		}
		else if (taskFlag == ADD_PAYMENT_FLAG) {
			categoryName = PAYMENT_CATEGORY;
			methodName = ADD_PAYMENT;
			try {
				para.put("OrderCount",orderList.size());
				para.put("TotalPrice",op.getUnPaidPrice());
				JSONObject paymentDetailJson=new JSONObject();
				paymentDetailJson.put("UserCardNo",op.getUserCardNo());
				para.put("PaymentDetail",paymentDetailJson);
				JSONArray orderJsonArray=new JSONArray();
				for(OrderPayListInfo oi:orderList){
					orderJsonArray.put(oi.getOrderID());
				}
				para.put("OrderIDList",orderJsonArray);
			} catch (JSONException e) {
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(categoryName, methodName,para.toString(), header);
		return request;
	}

	@Override
	public void parseData(WebApiResponse response) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if (taskFlag == GET_PAYMENT_FLAG) {
					op=OrderPayment.parseByJson(response.getStringData());
					initValue();
				} else if (taskFlag == ADD_PAYMENT_FLAG){
					DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
					LeftMenuPresenter.getInstace(mApp).addUnpaymentOrderCount(-orderList.size());
					finishActivity();
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
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				break;
			}
		}
	}
	private void finishActivity() {
		setResult(RESULT_OK, null);
		this.finish();
	}

}
