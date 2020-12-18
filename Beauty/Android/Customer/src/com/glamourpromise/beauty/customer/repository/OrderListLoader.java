package com.glamourpromise.beauty.customer.repository;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;

public class OrderListLoader extends BaseLoader {
	private static final String ORDER_CATEGORY_NAME = "Order";
	private static final String GET_ORDER_LIST = "GetOrderList";
	
	private String mCustomerID;
	private int mProductType;
	private int mOrderStatus;
	private int mOrderPayStatus;
	private UserInfoApplication mApp;
	
	

	public OrderListLoader(Context context, String customerID, int productType, int orderStatus, int orderPayStatus, UserInfoApplication app) {
		super(context, app.getHttpClient());
		mCustomerID = customerID;
		mProductType = productType;
		mOrderStatus = orderStatus;
		mOrderPayStatus = orderPayStatus;
		mApp = app;
	}

	public WebApiRequest getRequest() {
		JSONObject para = new JSONObject();
		try {
			para.put("BranchID", 0);
			para.put("CustomerID", mCustomerID);
			para.put("ProductType", mProductType);
			para.put("Status", mOrderStatus);
			para.put("PaymentStatus", mOrderPayStatus);
			para.put("PageSize", 20000);
			para.put("PageIndex", 1);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(ORDER_CATEGORY_NAME, GET_ORDER_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(ORDER_CATEGORY_NAME, GET_ORDER_LIST, para.toString(), header);
		return request;
	}

	@Override
	protected Object parseData(String resultString) {
		OrderBaseInfo orderBase = new OrderBaseInfo();
		ArrayList<OrderBaseInfo> orders = orderBase.parseListByJson(resultString);
		return orders;
	}
}
