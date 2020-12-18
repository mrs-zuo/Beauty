package com.glamourpromise.beauty.customer.repository;

import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;
import com.glamourpromise.beauty.customer.bean.OrderBaseInfo;
import com.glamourpromise.beauty.customer.bean.ServiceOrderInfo;
import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.net.WebApiHttpHead;
import com.glamourpromise.beauty.customer.net.WebApiRequest;
import com.glamourpromise.beauty.customer.net.WebApiResponse;

public class OrderRepository extends BaseRepository{
	private static final String ORDER_CATEGORY_NAME = "Order";
	private static final String GET_ORDER_LIST = "GetOrderList";
	
	public interface OrderListCallback{
		public void onOrderListLoaded(ArrayList<OrderBaseInfo> serviceOrders);
		public void onLoadedError(String message);
		public void onHttpError(int httpCode, int httpMessage);
	}
	
	public interface ServiceOrderDetailCallback{
		public void onServiceOrderDetailLoaded(ServiceOrderInfo serviceOrderDetail);
	}
	
	private OrderListCallback mListCallback;
	private String mCustomerID;
	private UserInfoApplication mApp;
	
	public OrderRepository(String customerID, UserInfoApplication app){
		mCustomerID = customerID;
		mApp = app;
	}
	
	public void getOrderList(int producType, int orderStatus, int orderPayStatus, OrderListCallback orderListCallback){
		mListCallback = orderListCallback;
		WebApiRequest request = getWebApiRequest(producType, orderStatus, orderPayStatus);
		WebApiResponse response = (WebApiResponse) super.get(ORDER_CATEGORY_NAME, request.getParameters(), request.getHeader(), mApp.getHttpClient());
		if (response.getHttpCode() == 200) {
			String message = "";
			switch (response.getCode()) {
			case WebApiResponse.GET_WEB_DATA_TRUE:
				OrderBaseInfo orderBase = new OrderBaseInfo();
				ArrayList<OrderBaseInfo> orderList = orderBase.parseListByJson(response.getStringData());
				mListCallback.onOrderListLoaded(orderList);
				return;
			case WebApiResponse.GET_WEB_DATA_EXCEPTION:
			case WebApiResponse.GET_WEB_DATA_FALSE:
				message = response.getMessage();
				break;
			case WebApiResponse.GET_DATA_NULL:
			case WebApiResponse.PARSING_ERROR:
				message = Constant.NET_ERR_PROMPT;
				break;
			default:
				message = Constant.NET_ERR_PROMPT;
				break;
			}
			mListCallback.onLoadedError(message);
		} else{
			int httpErrorMessage = 0;
			 if (response.getHttpCode() == 401) {
					httpErrorMessage = Integer.valueOf(response.getHttpErrorMessage());
			 }
			mListCallback.onHttpError(response.getHttpCode(), httpErrorMessage);
		}
		
	}
	
	private WebApiRequest getWebApiRequest(int producType, int orderStatus, int orderPayStatus){
		JSONObject para = new JSONObject();
		try {
			para.put("BranchID", 0);
			para.put("CustomerID", mCustomerID);
			para.put("ProductType", producType);
			para.put("Status", orderStatus);
			para.put("PaymentStatus", orderPayStatus);
			para.put("PageSize", 20000);
			para.put("PageIndex", 1);
		} catch (JSONException e) {
		}
		WebApiHttpHead header = mApp.createNeededCheckingWebConnectHead(ORDER_CATEGORY_NAME, GET_ORDER_LIST, para.toString());
		WebApiRequest request = new WebApiRequest(ORDER_CATEGORY_NAME, GET_ORDER_LIST, para.toString(), header);
		return request;
	}
}
