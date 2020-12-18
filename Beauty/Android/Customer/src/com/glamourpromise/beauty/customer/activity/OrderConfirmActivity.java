package com.glamourpromise.beauty.customer.activity;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TableLayout;
import android.widget.TextView;

import com.glamourpromise.beauty.customer.R;
import com.glamourpromise.beauty.customer.base.BaseActivity;
import com.glamourpromise.beauty.customer.bean.CartInformation;
import com.glamourpromise.beauty.customer.bean.ECardInformation;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.IConnectTask;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;
import com.glamourpromise.beauty.customer.presenter.LeftMenuPresenter;
import com.glamourpromise.beauty.customer.util.CreateLayoutInTableLayout;
import com.glamourpromise.beauty.customer.util.DialogUtil;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class OrderConfirmActivity extends BaseActivity implements
		OnClickListener, IConnectTask {
	private static final String GET_PRODUCT_CATEGORY_NAME = "Commodity";
	private static final String GET_PRODUCT = "getProductInfoList";
	private static final String ORDER_CATEGORY_NAME = "Order";
	private static final String ADD_ORDER = "AddNewOrder";
	private static final String GET_CARD_CATEGORY_NAME="ECard";
	private static final String GET_CARD="GetCardDiscountList";
	private List<CartInformation> selectCartList;
	private LinearLayout commodityLayout;
	private Button      orderConfirmBtn;
	private double      totalPrice = 0;
	private double      totalSalePrice = 0;
	private JSONArray  mJArrCart;
	private int     taskFlag=1;
	private JSONObject currentProductJson;
	private int        currentIndex;
	@SuppressWarnings("unchecked")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		super.baseSetContentView(R.layout.activity_order_confirm);
		super.setTitle(getString(R.string.title_order_confirm));
		selectCartList = new ArrayList<CartInformation>();
		selectCartList = (List<CartInformation>) getIntent().getSerializableExtra("selectCartList");
		commodityLayout = (LinearLayout) findViewById(R.id.commodity_linearlayout);
		orderConfirmBtn = (Button)findViewById(R.id.order_confirm_btn);
		orderConfirmBtn.setOnClickListener(this);
		new CreateLayoutInTableLayout();
		initView();
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@SuppressLint("SimpleDateFormat")
	private void initView() {
		taskFlag=1;
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	protected void refreshView(){
		for (int i = 0; i < selectCartList.size(); i++) {
			createCommodityRow(i);
		}
		if (selectCartList.size() > 1) {
			createTotalPriceRow();
		} else {
			TableLayout totalPriceLayout = (TableLayout) findViewById(R.id.total_price_layout);
			totalPriceLayout.setVisibility(View.GONE);
		}
	}
	private void createCommodityRow(final int i) {
		LayoutInflater mLayoutInflater = getLayoutInflater();
		TableLayout tableLayout = (TableLayout) mLayoutInflater.inflate(R.xml.order_confirm_item, null);
		TableLayout.LayoutParams lp = new TableLayout.LayoutParams();
		lp.setMargins(0,getResources().getDimensionPixelSize(R.dimen.margin_top), 0, 0);
		tableLayout.setLayoutParams(lp);
		// 商品名
		TextView commodityNameView = (TextView) tableLayout.findViewById(R.id.commodity_name_text);
		commodityNameView.setText(selectCartList.get(i).getProductName());
		//
		final TextView commodityAmountView = (TextView) tableLayout.findViewById(R.id.amount_content_text);
		commodityAmountView.setText(String.valueOf(selectCartList.get(i).getQuantity()));
		final TextView commodityUnitPriceView = (TextView) tableLayout.findViewById(R.id.unit_content_text);
		final TextView commodityPromotionPriceView = (TextView) tableLayout.findViewById(R.id.order_confirm_item_member_discount_payment);
		// 等级打折
		calculation(i, commodityUnitPriceView, commodityPromotionPriceView);
		// Branch Name
		TextView branchName = (TextView) tableLayout.findViewById(R.id.order_confirm_item_branch_name_content);
		branchName.setText(selectCartList.get(i).getBranchName());
		List<String> cardNameList=new ArrayList<String>();
		final List<ECardInformation> ecardList=selectCartList.get(i).getEcardList();
		if(ecardList!=null && ecardList.size()>0){
			for(ECardInformation ecard:ecardList){
				cardNameList.add(ecard.getCardName()+"("+NumberFormatUtil.FloatFormatToStringWithoutSingle(Double.valueOf(ecard.getDisCount()))+")");
			}
		}
		 
		ArrayAdapter<String> arrAdapter = new ArrayAdapter<String>(this, R.xml.select_dialog_text,cardNameList);
		arrAdapter.setDropDownViewResource(android.R.layout.select_dialog_singlechoice);
		Spinner cardSpinner=(Spinner)tableLayout.findViewById(R.id.order_confirm_item_spinner);
		cardSpinner.setAdapter(arrAdapter);
		cardSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> parent,View view, int position, long id) {
				double totalPrice=Double.valueOf(String.valueOf(selectCartList.get(i).getTotalPrice()));
				if(selectCartList.get(i).getMarketingPolicy().equals("1")){
					int    quantity=selectCartList.get(i).getQuantity();
					double promotionPrice=(totalPrice*Double.valueOf(ecardList.get(position).getDisCount()))/quantity;
					commodityPromotionPriceView.setText(NumberFormatUtil.currencyFormat(OrderConfirmActivity.this,promotionPrice*quantity));
					selectCartList.get(i).setPromotionPrice(promotionPrice);
				}
				selectCartList.get(i).setCardID(ecardList.get(position).getCardID());
				totalSalePrice=0;
				for (int i = 0; i < selectCartList.size(); i++){
						totalSalePrice += selectCartList.get(i).getPromotionPrice()*selectCartList.get(i).getQuantity();
				}
				if (selectCartList.size() > 1)
					createTotalPriceRow();
			}

			@Override
			public void onNothingSelected(AdapterView<?> parent) {
				// TODO Auto-generated method stub
			}
		});
		boolean hasCardBuy=false;
		for(int j=0;j<ecardList.size();j++){
			if(ecardList.get(j).getCardID()==selectCartList.get(i).getCardID()){
				cardSpinner.setSelection(j);
				hasCardBuy=true;
				break;
			}
		}
		if(!hasCardBuy){
			selectCartList.get(i).setCardID(0);
			selectCartList.get(i).setPromotionPrice(Double.valueOf(String.valueOf(selectCartList.get(i).getTotalPrice()))/selectCartList.get(i).getQuantity());
			commodityPromotionPriceView.setText(NumberFormatUtil.currencyFormat(OrderConfirmActivity.this,selectCartList.get(i).getPromotionPrice()*selectCartList.get(i).getQuantity()));
		}
		commodityLayout.addView(tableLayout);
	}

	private void calculation(int position, TextView commodityUnitPriceView,TextView commodityPromotionPriceView) {
		// 最下面的section 归零
		totalPrice = 0;
		totalSalePrice = 0;
		// 每个section价格
		double unitPrice = selectCartList.get(position).getUnity()* selectCartList.get(position).getQuantity();
		double promotionPrice = selectCartList.get(position).getPromotionPrice()* selectCartList.get(position).getQuantity();
		for (int i = 0; i < selectCartList.size(); i++)
			totalPrice += selectCartList.get(i).getCommoditySectionPrice();
		commodityUnitPriceView.setText(NumberFormatUtil.currencyFormat(this,unitPrice));
		commodityPromotionPriceView.setText(NumberFormatUtil.currencyFormat(this,promotionPrice));
		for (int i = 0; i < selectCartList.size(); i++){
				totalSalePrice += selectCartList.get(i).getPromotionPrice()*selectCartList.get(i).getQuantity();
		}
		if (selectCartList.size() > 1)
			createTotalPriceRow();
	}
	private void createTotalPriceRow() {
		TextView totalPriceView = (TextView) findViewById(R.id.total_price_content_text);
		totalPriceView.setText(NumberFormatUtil.currencyFormat(this, totalPrice));
		TextView totalSalePriceView = (TextView) findViewById(R.id.sale_price_content_text);
		totalSalePriceView.setText(NumberFormatUtil.currencyFormat(this,totalSalePrice));
	}
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.order_confirm_btn:
			addOrder();
			break;
		default:
			break;
		}
	}

	private void goToOrderClassifyActivity() {
		// 多笔订单到待付款页面
		if (selectCartList.size() > 1) {
			Intent destIntent = null;
			destIntent = new Intent(this, OrderPayListActivity.class);
			startActivity(destIntent);
			this.finish();
		}
		// 之后跳转到支付页面
		else {
			Intent destIntent = null;
			destIntent = new Intent(this, OrderPayListActivity.class);
			startActivity(destIntent);
			this.finish();
		}
	}
	
	private void addOrder() {
		taskFlag=2;
		double totalPrice;
		DecimalFormat decimalFormat = new DecimalFormat("0.00");
		int quantity;
		mJArrCart = new JSONArray();
		JSONObject item;
		try {
			for (CartInformation cartInfo : selectCartList) {
				item = new JSONObject();
				item.put("CartID",cartInfo.getCartID());
				item.put("CardID",cartInfo.getCardID());
				item.put("ProductID",cartInfo.getProductID());
				item.put("ProductCode",cartInfo.getProductCode());
				item.put("TotalSalePrice", -1);
				item.put("ProductType",cartInfo.getProductType());
				quantity = Integer.valueOf(cartInfo.getQuantity());
				totalPrice = 0;
				// 原价
				totalPrice = quantity * Double.valueOf(cartInfo.getUnity());
				item.put("TotalOrigPrice",decimalFormat.format( totalPrice));
				totalPrice = quantity * Double.valueOf(cartInfo.getPromotionPrice());
				item.put("TotalCalcPrice",decimalFormat.format(totalPrice));
				item.put("BranchID",cartInfo.getBranchID());
				mJArrCart.put(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return;
		}
		super.showProgressDialog();
		super.asyncRefrshView(this);
	}
	private void getCardDiscountList(int currentIndex,int branchID,String productCode,int productType){
		taskFlag=3;
		this.currentIndex=currentIndex;
		currentProductJson=new JSONObject();
		try {
			currentProductJson.put("BranchID",branchID);
			currentProductJson.put("ProductCode",productCode);
			currentProductJson.put("ProductType",productType);
		} catch (JSONException e) {
		}
		super.asyncRefrshView(this);
	}
	@Override
	public WebApiRequest getRequest() {
		// TODO Auto-generated method stub
		JSONObject para = new JSONObject();
		String categroyName="";
		String methodName="";
		if(taskFlag==1){
			categroyName=GET_PRODUCT_CATEGORY_NAME;
			methodName=GET_PRODUCT;
			try {
				JSONArray cartIDJsonArray=new JSONArray();
				for(CartInformation cartInfo:selectCartList){
					cartIDJsonArray.put(cartInfo.getCartID());
				}
				para.put("CartIDList",cartIDJsonArray);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if(taskFlag==2){
			categroyName=ORDER_CATEGORY_NAME;
			methodName=ADD_ORDER;
			try {
				para.put("CustomerID",mCustomerID);
				para.put("OrderList",mJArrCart);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if(taskFlag==3){
			categroyName=GET_CARD_CATEGORY_NAME;
			methodName=GET_CARD;
			try {
				para.put("BranchID",currentProductJson.getInt("BranchID"));
				para.put("ProductCode",currentProductJson.getString("ProductCode"));
				para.put("ProductType",currentProductJson.getInt("ProductType"));
			} catch (JSONException e) {
				
			}
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(categroyName,methodName,para.toString());
		WebApiRequest request = new WebApiRequest(categroyName,methodName,para.toString(),header);
		return request;
	}

	@Override
	public void onHandleResponse(WebApiResponse response) {
		// TODO Auto-generated method stub
		super.dismissProgressDialog();
		if (response.getHttpCode() == 200) {
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				if(taskFlag==1){
					try {
						CartInformation.refershCartList(selectCartList,new JSONArray(response.getStringData()));
					} catch (JSONException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					CartInformation cart=selectCartList.get(0);
					getCardDiscountList(0,cart.getBranchID(),cart.getProductCode(),cart.getProductType());
				}
				else if(taskFlag==2){
					DialogUtil.createShortDialog(this, response.getMessage());
					LeftMenuPresenter.getInstace(mApp).addCartCount(-selectCartList.size());
					goToOrderClassifyActivity();
				}
				else if(taskFlag==3){
					List<ECardInformation> ecardInformationList=ECardInformation.parseCardDiscountByJson(response.getStringData());
					selectCartList.get(currentIndex).setEcardList(ecardInformationList);
					if(currentIndex==selectCartList.size()-1)
						refreshView();
					else{
						int index=currentIndex+1;
						CartInformation cart=selectCartList.get(index);
						getCardDiscountList(index,cart.getBranchID(),cart.getProductCode(),cart.getProductType());
					}
						
				}
				break;
			case 3:
				DialogUtil.createShortDialog(this,response.getMessage());
				break;
			case -2:
				break;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
				break;
			case WebApiResponse.GET_WEB_DATA_FALSE:
				DialogUtil.createShortDialog(getApplicationContext(),response.getMessage());
				finish();
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
