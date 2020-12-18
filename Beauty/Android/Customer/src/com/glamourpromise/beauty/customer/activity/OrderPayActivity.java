package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.Spinner;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CardDiscountInfo;
import com.glamourpromise.beauty.customer.bean.CustomerCardInfo;
import com.glamourpromise.beauty.customer.bean.OrderPayListInfo;
import com.glamourpromise.beauty.customer.bean.PaymentInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.AmountConvertToCapital;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;
import com.glamourpromise.beauty.customer.util.StringMultiplyUtil;

public class OrderPayActivity extends BaseActivity implements OnClickListener,
		IConnectTask {
	public static final int SERVICE_ORDER_PAY_REQUEST_CODE = 1;
	public static final int COMMODITY_ORDER_PAY_REQUEST_CODE = 2;
	private static final String GET_CARD_INFO = "GetCardInfo";
	private static final String ECARD_CATEGORY = "ECard";
	private static final String GET_CUSTOMERCARD_LIST = "getCustomerCardList";
	private static final String GET_DISCOUNT_LIST = "GetCardDiscountList";
	private static final String PAYMENT_CATEGORY = "Payment";
	private static final String GET_PAYMENT_INFO = "GetPaymentInfo";
	private static final int GET_PAYMENTINFO_FLAG = 1;
	private static final int GET_DISCOUNT_FLAG = 2;
	private static final int GET_CARDLIST_FLAG = 3;
	private int taskFlag;
	private float totalPrice = 0;
	private float totalSalePrice = 0;
	private List<OrderPayListInfo> orderList;
	private List<CustomerCardInfo> cardList = new ArrayList<CustomerCardInfo>();
	private List<CardDiscountInfo> discountCardList = new ArrayList<CardDiscountInfo>();
	private ImageView payConfirm;
	private Spinner cardSpinner;
	private TextView memberDiscount;
	TextView orderTotalPrice;
	private ArrayAdapter<String> arrAdapter;
	private List<String> cardInfoList = new ArrayList<String>();
	private TextView orderTotalSalePrice;
	private TextView orderCapitalPrice;
	private Intent intent;
	private Bundle mBundle;
	private String productCode = "";
	private CustomerCardInfo customerCardInfo = new CustomerCardInfo();
	private PaymentInfo paymentInfo = new PaymentInfo();
	private CardDiscountInfo cardDiscountInfo = new CardDiscountInfo();

	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_order_pay);
		super.setTitle(getString(R.string.title_order_pay));
		orderList = (List<OrderPayListInfo>) getIntent().getSerializableExtra("OrderPayList");
		super.showProgressDialog();
		intent = new Intent();
		intent.setClass(this, AddPaymentActivity.class);
		mBundle = new Bundle();
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		TextView orderCount = (TextView) findViewById(R.id.order_quantity);
		orderCount.setText(String.valueOf(orderList.size()));
		orderTotalPrice = (TextView) findViewById(R.id.order_totalprice);
		orderTotalSalePrice = (TextView) findViewById(R.id.order_total_sale_price);
		orderCapitalPrice = (TextView) findViewById(R.id.order_price_capitalization);
		cardSpinner = (Spinner) findViewById(R.id.order_pay_customer_card_spinner);
		memberDiscount = (TextView) findViewById(R.id.memeber_payment_discount);
		orderTotalPrice.setText(NumberFormatUtil.currencyFormat(this,totalPrice));
		orderTotalSalePrice.setText(NumberFormatUtil.currencyFormat(this,totalSalePrice));
		orderCapitalPrice.setText(AmountConvertToCapital.parse(String.valueOf(totalSalePrice)));

		payConfirm = (ImageView) findViewById(R.id.order_confirm);
		payConfirm.setEnabled(false);
		
		taskFlag = GET_PAYMENTINFO_FLAG;
		super.asyncRefrshView(this);
		arrAdapter = new ArrayAdapter<String>(this, R.xml.select_dialog_text,cardInfoList);
		arrAdapter.setDropDownViewResource(android.R.layout.select_dialog_singlechoice);
		cardSpinner.setAdapter(arrAdapter);
		cardSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int position, long id) {
			}
			@Override
			public void onNothingSelected(AdapterView<?> parent) {
			}
		});

	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	private void finishActivity() {
		setResult(RESULT_OK, null);
		this.finish();
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if (taskFlag == GET_PAYMENTINFO_FLAG) {
			catoryName = PAYMENT_CATEGORY;
			methodName = GET_PAYMENT_INFO;
			JSONObject orderJsonObject;
			JSONArray orderJsonList = new JSONArray();

			try {
				para.put("CustomerID", mCustomerID);
				for (int i = 0; i < orderList.size(); i++) {
					orderJsonObject = new JSONObject();
					orderJsonObject.put("OrderID", orderList.get(i).getOrderID());
					orderJsonObject.put("OrderObjectID", orderList.get(i).getOrderObjectID());
					orderJsonObject.put("ProductType", orderList.get(i).getProductType());
					orderJsonList.put(orderJsonObject);
				}
				para.put("OrderList", orderJsonList);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else if (taskFlag == GET_DISCOUNT_FLAG) {
			catoryName = ECARD_CATEGORY;
			methodName = GET_DISCOUNT_LIST;
			try {
				para.put("CustomerID", Integer.parseInt(mCustomerID));
				para.put("ProductCode", productCode);
				para.put("ProductType", orderList.get(0).getProductType());
			} catch (JSONException e) {
				e.printStackTrace();
			}
		} else {
			catoryName = ECARD_CATEGORY;
			methodName = GET_CUSTOMERCARD_LIST;
			try {
				para.put("CustomerID", mCustomerID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(
				catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName,
				para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
					if (taskFlag == GET_PAYMENTINFO_FLAG) {
						boolean discountFlag = false;

						int tempTaskFlag = GET_PAYMENTINFO_FLAG;
						paymentInfo.parseByJson(response.getStringData());
						productCode = paymentInfo.getProductCode();
						orderTotalPrice.setText(NumberFormatUtil
								.StringFormatToString(this,
										paymentInfo.getTotalSalePrice()));
						orderTotalSalePrice.setText(NumberFormatUtil
								.StringFormatToString(this,
										paymentInfo.getUnPaidPrice()));
						orderCapitalPrice.setText(AmountConvertToCapital
								.parse(String.valueOf(paymentInfo
										.getUnPaidPrice())));
						memberDiscount.setText(NumberFormatUtil
								.StringFormatToString(this,
										paymentInfo.getUnPaidPrice()));

						
						// 部分或多笔订单付销毁Activity跳下一页
						if (orderList.get(0).getPaymentStatus() == 2
								|| orderList.size() > 1) {
							List<OrderPayListInfo> orderPayList = new ArrayList<OrderPayListInfo>();
							for (int i = 0; i < orderList.size(); i++)
								orderPayList.add(orderList.get(i));

							discountFlag = false;
							putPaymentData(discountFlag);

							tempTaskFlag = GET_CARDLIST_FLAG;
							OrderPayActivity.this.finish();
						}

						else {
							tempTaskFlag = GET_DISCOUNT_FLAG;
						}
						taskFlag = tempTaskFlag;
						OrderPayActivity.super
								.asyncRefrshView(OrderPayActivity.this);
					}

					// 卡有折扣
					else if (taskFlag == GET_DISCOUNT_FLAG) {
						int tempTaskFlag = GET_DISCOUNT_FLAG;
						boolean discountFlag = true;
						discountCardList.clear();
						discountCardList = cardDiscountInfo
								.parseListByJson(response.getStringData());
						cardSpinner.setEnabled(true);

						if (discountCardList.size() == 0) {
							tempTaskFlag = GET_CARDLIST_FLAG;
							discountFlag = false;
							OrderPayActivity.super
									.asyncRefrshView(OrderPayActivity.this);
							putPaymentData(discountFlag);
							OrderPayActivity.this.finish();
						}
						// 卡有折扣且为单笔订单
						else {
							discountFlag = true;
							for (int i = 0; i < discountCardList.size(); i++) {
								cardInfoList.add(i, discountCardList.get(i)
										.getCardName());
								if (discountCardList.get(i).getUserCardNo()
										.equals(paymentInfo.getUserCardNo())) {
									arrAdapter.notifyDataSetChanged();
									cardSpinner.setSelection(i);
								}
							}
							arrAdapter.notifyDataSetChanged();

							String discountPrice = StringMultiplyUtil
									.FloatFormatStringMuiltiplyUtil(
											paymentInfo.getUnPaidPrice(),
											discountCardList
													.get(cardSpinner
															.getSelectedItemPosition())
													.getDiscount());

							orderTotalSalePrice.setText(NumberFormatUtil
									.StringFormatToString(this, discountPrice));
							orderCapitalPrice.setText(AmountConvertToCapital
									.parse(String.valueOf(discountPrice)));
							memberDiscount.setText(NumberFormatUtil
									.StringFormatToString(this, discountPrice));
							
						}
						taskFlag = tempTaskFlag;
					}
					
					else {
						cardList.clear();
						cardList = customerCardInfo.parseListByJson(response.getStringData());
						for (int i = 0; i < cardList.size(); i++) {
							cardInfoList.add(i, cardList.get(i).getCardName());
							if (cardList.get(i).getUserCardNo()
									.equals(paymentInfo.getUserCardNo())) {
								arrAdapter.notifyDataSetChanged();
								cardSpinner.setSelection(i);
								cardSpinner.setEnabled(false);
							}
						}
						arrAdapter.notifyDataSetChanged();
						payConfirm.setEnabled(true);
						super.dismissProgressDialog();

					}
					payConfirm.setOnClickListener(new OnClickListener() {

						@Override
						public void onClick(View view) {
							putPaymentData(true);
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
				DialogUtil.createShortDialog(getApplicationContext(),
						Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}

	}

	private void putPaymentData(boolean discountFlag) {
		List<OrderPayListInfo> orderPayList = new ArrayList<OrderPayListInfo>();
		String chosenUserCardNo = "";
		
		for (int i = 0; i < orderList.size(); i++)
			orderPayList.add(orderList.get(i));

		mBundle.putSerializable("OrderPayList", (Serializable) orderPayList);
		intent.putExtra("DiscountFlag", discountFlag);
		mBundle.putSerializable("PaymentInfo", (Serializable) paymentInfo);

		if (discountFlag) {
			mBundle.putSerializable("CardDiscountInfo",(Serializable) discountCardList);
			chosenUserCardNo = discountCardList.get(cardSpinner.getSelectedItemPosition()).getUserCardNo();
		} else
			chosenUserCardNo = paymentInfo.getUserCardNo();
		super.dismissProgressDialog();
		intent.putExtra("ChosenUserCardNo", chosenUserCardNo);
		intent.putExtras(mBundle);
		startActivity(intent);
	}

	@Override
	public void parseData(WebApiResponse response) {

	}

}
