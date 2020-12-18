package com.glamourpromise.beauty.customer.activity;

import java.io.Serializable;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TextView;
import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.BalanceInfo;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.PaymentDetailInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardRechargeDetailActivity extends BaseActivity implements OnClickListener, IConnectTask{
	private static final String ECARD_CATEGORY_NAME = "Ecard";
	private static final String PAYMENT_CATEGORY_NAME = "Payment";
	private static final String GET_BALANCE_DETAIL = "getBalanceDetail";
	private static final String GET_PAYMENT_DETAIL = "getPaymentDetail";
	
	private static final int GET_BALANCE_DETAIL_FLAG = 1;
	private static final int GET_PAYMENT_DETAIL_FLAG = 2;
	
	private int taskFlag;
	
	private LayoutInflater layoutInflater;
	private TableLayout  ecardHistoryOrderListView;
	private List<OrderBaseInfo> orderInfoList;
	private static String title = "";
	private static String timeTitle = "";
	private static String amounTitle="";
	private static String wayTitle="";
	private BalanceInfo balanceDetailInfo;
	private String rechargeMode="";//0:现金、1:银行卡、2:赠送、3:转入、4:消费、5:转出、6:退款
	private String balance="";
	private String paymentID="";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_ecard_recharge_detail);
		rechargeMode = getIntent().getStringExtra("Mode");
		balance = getIntent().getStringExtra("Balance");
		paymentID = getIntent().getStringExtra("PaymentID");
		findViewById(R.id.btn_main_home).setOnClickListener(this);
		findViewById(R.id.btn_main_back).setOnClickListener(this);
		init();
	}
	
	private void init(){
		ecardHistoryOrderListView=(TableLayout) findViewById(R.id.order_list);
		RelativeLayout rLway = (RelativeLayout) findViewById(R.id.recharge_way_layout);
		TextView tvWayTitle = (TextView) findViewById(R.id.recharge_way_title);
		TextView tvPayTimeTitle = (TextView) findViewById(R.id.payment_time_title);
		TextView tvAmountTitle = (TextView) findViewById(R.id.recharge_amount_title);
		if(rechargeMode.equals("0") || rechargeMode.equals("1") || rechargeMode.equals("3") || rechargeMode.equals("2")){
			title = "充值详情";
			timeTitle = "充值日期";
			amounTitle="充值金额";
			wayTitle="充值方式";
			tvWayTitle.setText(wayTitle);
		}else if(rechargeMode.equals("2")){
			
		}else if(rechargeMode.equals("5")){
			title = "转出详情";
			timeTitle = "转出日期";
			amounTitle="转出金额";
			rLway.setVisibility(View.GONE);
			((View) findViewById(R.id.recharge_way_layout_above_line)).setVisibility(View.GONE);
		}else if(rechargeMode.equals("6")){
			title = "退款详情";
			timeTitle = "退款日期";
			amounTitle="退款金额";
			rLway.setVisibility(View.GONE);
			((View) findViewById(R.id.recharge_way_layout_above_line)).setVisibility(View.GONE);
		}else if(rechargeMode.equals("4")){
			title = "e卡支付详情";
			timeTitle = "支付日期";
			amounTitle="支付总金额";
			rLway.setVisibility(View.GONE);
			((View) findViewById(R.id.recharge_way_layout_above_line)).setVisibility(View.GONE);
		}
		tvPayTimeTitle.setText(timeTitle);
		tvAmountTitle.setText(amounTitle);
		super.setTitle(title);
		((TextView)findViewById(R.id.balance)).setText(NumberFormatUtil.StringFormatToString(EcardRechargeDetailActivity.this, balance));
		getData();
	}
	
	private void showDataOnView(){
		if(balanceDetailInfo == null){
			return;
		}
		((TextView)findViewById(R.id.payment_time)).setText(balanceDetailInfo.getCreateTime());
		((TextView)findViewById(R.id.operator)).setText(balanceDetailInfo.getOperator());
		((TextView)findViewById(R.id.recharge_amount)).setText(NumberFormatUtil.StringFormatToString(EcardRechargeDetailActivity.this, balanceDetailInfo.getPaymentAmount()));
		((TextView)findViewById(R.id.recharge_way)).setText(balanceDetailInfo.getPaymentMode());
		if(balanceDetailInfo.getRemark().equals(" ")){
			((LinearLayout) findViewById(R.id.remark_card_layout)).setVisibility(View.GONE);
		}else{
			((TextView)findViewById(R.id.remark_content)).setText(balanceDetailInfo.getRemark());
		}
		
	}
	
	private void getData(){
		super.showProgressDialog();
		if(rechargeMode.equals("4")){
			taskFlag = GET_PAYMENT_DETAIL_FLAG;
		}else{
			taskFlag = GET_BALANCE_DETAIL_FLAG;
		}
		asyncRefrshView(this);
	}

	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		String catoryName = "";
		String methodName = "";
		JSONObject para = new JSONObject();
		if(taskFlag == GET_BALANCE_DETAIL_FLAG){
			catoryName = ECARD_CATEGORY_NAME;
			methodName = GET_BALANCE_DETAIL;
			try {
				para.put("ID",paymentID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else if(taskFlag == GET_PAYMENT_DETAIL_FLAG){
			catoryName = PAYMENT_CATEGORY_NAME;
			methodName = GET_PAYMENT_DETAIL;
			
			try {
				para.put("PaymentID",paymentID);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(catoryName, methodName, para.toString());
		WebApiRequest request = new WebApiRequest(catoryName, methodName, para.toString(), header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		if(response.getHttpCode() == 200){
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag == GET_BALANCE_DETAIL_FLAG){
					balanceDetailInfo = new BalanceInfo();
					balanceDetailInfo.parseByJson(response.getStringData());
					showDataOnView();
				}else if(taskFlag == GET_PAYMENT_DETAIL_FLAG){
					handlePaymentResult(response.getStringData());
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
				DialogUtil.createShortDialog(getApplicationContext(), Constant.NET_ERR_PROMPT);
				break;
			default:
				break;
			}
		}
		
		super.dismissProgressDialog();
	}

	private void handlePaymentResult(String data) {
		// TODO Auto-generated method stub
		PaymentDetailInfo paymentInfo = new PaymentDetailInfo();
		paymentInfo.parseByJson(data);
		((TextView)findViewById(R.id.payment_time)).setText(paymentInfo.getCreateTime());
		((TextView)findViewById(R.id.operator)).setText(paymentInfo.getOperator());
		((TextView)findViewById(R.id.recharge_amount)).setText(NumberFormatUtil.StringFormatToString(EcardRechargeDetailActivity.this, paymentInfo.getTotalPrice()));
		
		((RelativeLayout) findViewById(R.id.payment_code_layout)).setVisibility(View.VISIBLE);
		((View) findViewById(R.id.payment_code_layout_under_line)).setVisibility(View.VISIBLE);
		((TextView)findViewById(R.id.payment_code)).setText(paymentInfo.getPaymentCode());
		
		if(paymentInfo.getRemark().equals(" ")){
			((LinearLayout) findViewById(R.id.remark_card_layout)).setVisibility(View.GONE);
		}else{
			((TextView)findViewById(R.id.remark_content)).setText(paymentInfo.getRemark());
		}
		orderInfoList = paymentInfo.getOrderList();
		if(orderInfoList == null || orderInfoList.size() < 1)
			return;
		layoutInflater = LayoutInflater.from(EcardRechargeDetailActivity.this);
		TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
		lp.setMargins(0, 25, 0, 0);
		for(int i = 0; i < orderInfoList.size(); i++){
			LinearLayout LLOrderItem = (LinearLayout) layoutInflater.inflate(R.xml.ecard_payment_order_item, null);
			((TextView)LLOrderItem.findViewById(R.id.order_number)).setText(orderInfoList.get(i).getOrderSerialNumber());
			((TextView)LLOrderItem.findViewById(R.id.product_name)).setText(orderInfoList.get(i).getProductName());
			((TextView)LLOrderItem.findViewById(R.id.order_amount)).setText(NumberFormatUtil.StringFormatToString(EcardRechargeDetailActivity.this, orderInfoList.get(i).getTotalPrice()));
			final int position = i;
			LLOrderItem.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View arg0) {
					Intent destIntent = null;
					if (orderInfoList.get(position).getProductType().equals("1")) {
						destIntent = new Intent(EcardRechargeDetailActivity.this, CommodityOrderDetailActivity.class);

					} else if (orderInfoList.get(position).getProductType().equals("0")) {
						destIntent = new Intent(EcardRechargeDetailActivity.this, ServcieOrderDetailActivity.class);
					}
					
					if(destIntent == null)
						return;

					Bundle mBundle = new Bundle();
					mBundle.putSerializable("OrderItem", (Serializable) orderInfoList.get(position));
					destIntent.putExtras(mBundle);
					startActivity(destIntent);
				}
			});
			
			ecardHistoryOrderListView.addView(LLOrderItem, lp);
		}
	}

	@Override
	public void parseData(WebApiResponse response) {
		
	}
	
}
