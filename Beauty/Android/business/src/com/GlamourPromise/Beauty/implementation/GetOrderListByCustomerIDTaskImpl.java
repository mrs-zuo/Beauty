package com.GlamourPromise.Beauty.implementation;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import com.GlamourPromise.Beauty.application.UserInfoApplication;
import com.GlamourPromise.Beauty.bean.OrderInfo;
import com.GlamourPromise.Beauty.bean.OrderListBaseConditionInfo;
import com.GlamourPromise.Beauty.bean.WebDataObject;
import com.GlamourPromise.Beauty.constant.Constant;
import com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetOrderListByCustomerIDTaskImpl implements IGetBackendServerDataTask{
	private static final String METHOD_NAME = "getOrderList";
	private static final String METHOD_PARENT_NAME = "order";
	private OrderListBaseConditionInfo mOrderBaseParam;
	private String mCustomerName;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public GetOrderListByCustomerIDTaskImpl(Handler handler, String customerName, OrderListBaseConditionInfo orderBaseParam,UserInfoApplication userinfoApplication){
		mHandler = handler;
		mCustomerName = customerName;
		mOrderBaseParam = orderBaseParam;
		this.userinfoApplication=userinfoApplication;
	}
	
	@Override
	public String getmethodName() {
		// TODO Auto-generated method stub
		return METHOD_NAME;
	}

	@Override
	public String getmethodParentName() {
		// TODO Auto-generated method stub
		return METHOD_PARENT_NAME;
	}

	@Override
	public Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject param = new JSONObject();
		try {
			//基本条件
			param.put("CustomerID",mOrderBaseParam.getCustomerID());
			param.put("BranchID",mOrderBaseParam.getBranchID());
			param.put("ProductType",mOrderBaseParam.getProductType());
			param.put("Status",mOrderBaseParam.getStatus());
			param.put("PaymentStatus", mOrderBaseParam.getPaymentStatus());
			param.put("IsBusiness",mOrderBaseParam.getIsBusiness());
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return param;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			JSONObject resultJsonObject = (JSONObject) resultObject.result;
			msg.obj = handleSoapObjectResult(resultJsonObject);
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		else if(resultObject.code == Constant.LOGIN_ERROR || resultObject.code == Constant.APP_VERSION_ERROR){
			msg.what=resultObject.code;
		}
		msg.sendToTarget();
	}
	private ArrayList<OrderInfo> handleSoapObjectResult(JSONObject contentJsonObject){
		ArrayList<OrderInfo> orderList = new ArrayList<OrderInfo>();
		JSONArray orderListArray = null;
		try {
			orderListArray = contentJsonObject.getJSONArray("OrderList");
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return orderList;
		}
		int OrderListCount = orderListArray.length();
		
		if(OrderListCount > 0){
			JSONObject orderJsonObject;
			OrderInfo orderItem;
			String tmp;
			for(int i = 0; i < OrderListCount; i++){
				try {
					orderJsonObject = orderListArray.getJSONObject(i);
					orderItem = new OrderInfo();
					orderItem.setCustomerName(mCustomerName);
					if(orderJsonObject.has("CreateTime"))
						orderItem.setCreateTime(orderJsonObject.getString("CreateTime"));
					if (orderJsonObject.has("OrderID"))
						orderItem.setOrderID(orderJsonObject.getInt("OrderID"));
					if (orderJsonObject.has("OrderObjectID"))
						orderItem.setOrderObejctID(orderJsonObject.getInt("OrderObjectID"));
					// 订单的美丽顾问
					if (orderJsonObject.has("ResponsiblePersonName"))
						orderItem.setResponsiblePersonName(orderJsonObject.getString("ResponsiblePersonName"));
					if (orderJsonObject.has("ProductType"))
						orderItem.setProductType(orderJsonObject.getInt("ProductType"));
					if (orderJsonObject.has("Quantity"))
						orderItem.setQuantity(orderJsonObject.getInt("Quantity"));
					if (orderJsonObject.has("TotalOrigPrice"))
						orderItem.setTotalPrice(orderJsonObject.getString("TotalOrigPrice"));
					if (orderJsonObject.has("TotalSalePrice"))
						orderItem.setTotalSalePrice(orderJsonObject.getString("TotalSalePrice"));
					if (orderJsonObject.has("OrderTime"))
						orderItem.setOrderTime(orderJsonObject.getString("OrderTime"));
					if (orderJsonObject.has("ProductName"))
						orderItem.setProductName(orderJsonObject.getString("ProductName"));
					if (orderJsonObject.has("Status"))
						orderItem.setStatus(orderJsonObject.getInt("Status"));
					if (orderJsonObject.has("PaymentStatus"))
						orderItem.setPaymentStatus(orderJsonObject.getInt("PaymentStatus"));
					if (orderJsonObject.has("OrderSource"))
						orderItem.setOrderSource(orderJsonObject.getString("OrderSource"));
					if(orderJsonObject.has("IsThisBranch")){
						tmp = orderJsonObject.getString("IsThisBranch");
						if(tmp.equals("true")){
							orderItem.setIsThisBranch(1);
						}else{
							orderItem.setIsThisBranch(0);
						}
					}
						
					orderList.add(orderItem);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		return orderList;
		
	}

	/* (non-Javadoc)
	 * @return
	 * @see com.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask#getApplication()
	 */
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
