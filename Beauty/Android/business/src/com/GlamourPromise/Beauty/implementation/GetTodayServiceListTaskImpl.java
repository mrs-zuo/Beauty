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

public class GetTodayServiceListTaskImpl implements IGetBackendServerDataTask{
	private static final String METHOD_NAME = "GetMyTodayDoTGList";
	private static final String METHOD_PARENT_NAME = "order";
	private OrderListBaseConditionInfo mOrderBaseParam;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public GetTodayServiceListTaskImpl(Handler handler, OrderListBaseConditionInfo orderBaseParam,UserInfoApplication userinfoApplication){
		mHandler = handler;
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
			param.put("ProductType", mOrderBaseParam.getProductType());
			param.put("Status", mOrderBaseParam.getStatus());
			param.put("TGStartTime",mOrderBaseParam.getCreateTime());
			param.put("PageIndex", mOrderBaseParam.getPageIndex());
			param.put("PageSize", mOrderBaseParam.getPageSize());
			param.put("ServicePIC",mOrderBaseParam.getAccountID());
			param.put("CustomerID",mOrderBaseParam.getCustomerID());
			param.put("FilterByTimeFlag",mOrderBaseParam.getFilterByTimeFlag());
			if(mOrderBaseParam.getFilterByTimeFlag()==1){
				param.put("StartTime",mOrderBaseParam.getStartDate());
				param.put("EndTime", mOrderBaseParam.getEndDate());
			}
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
			JSONObject resultJsonObject = (JSONObject)resultObject.result;
			msg.obj = handleSoapObjectResult(resultJsonObject);
			try {
				msg.arg1 = resultJsonObject.getInt("RecordCount");
				msg.arg2 = resultJsonObject.getInt("PageCount");
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		else if(resultObject.code == Constant.LOGIN_ERROR || resultObject.code == Constant.APP_VERSION_ERROR){
			msg.what=resultObject.code;
		}
		msg.sendToTarget();
	}
	private ArrayList<OrderInfo> handleSoapObjectResult(JSONObject contentJsonObject){
		ArrayList<OrderInfo> todayServiceList = new ArrayList<OrderInfo>();
		JSONArray  todayServiceArray = null;
		try {
			todayServiceArray = contentJsonObject.getJSONArray("TGList");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return todayServiceList;
		}
		int OrderListCount = todayServiceArray.length();
		if(OrderListCount > 0){
			for (int i = 0; i < todayServiceArray.length(); i++) {
			OrderInfo  todayServiceOrder=new OrderInfo();
			JSONObject todayServiceOrderJson = null;
			String     customerName="";
			String     productName="";
			int        productType=-1;
			int        totalCount=0;
			int        finishedCount=0;
			int        paymentStatus=0;
			String     tgGroupNO="";
			String     tgStartTime="";
			int        orderID=0;
			int        orderObjectID=0;
			int        tgStatus=0;
			try {
				todayServiceOrderJson = todayServiceArray.getJSONObject(i);
				if (todayServiceOrderJson.has("CustomerName") && !todayServiceOrderJson.isNull("CustomerName"))
					customerName=todayServiceOrderJson.getString("CustomerName");
				if (todayServiceOrderJson.has("ProductName") && !todayServiceOrderJson.isNull("ProductName"))
					productName=todayServiceOrderJson.getString("ProductName");
				if (todayServiceOrderJson.has("ProductType") && !todayServiceOrderJson.isNull("ProductType"))
					productType=todayServiceOrderJson.getInt("ProductType");
				if (todayServiceOrderJson.has("TotalCount") && !todayServiceOrderJson.isNull("TotalCount"))
					totalCount=todayServiceOrderJson.getInt("TotalCount");
				if (todayServiceOrderJson.has("FinishedCount") && !todayServiceOrderJson.isNull("FinishedCount"))
					finishedCount=todayServiceOrderJson.getInt("FinishedCount");
				if (todayServiceOrderJson.has("PaymentStatus") && !todayServiceOrderJson.isNull("PaymentStatus"))
					paymentStatus=todayServiceOrderJson.getInt("PaymentStatus");
				if (todayServiceOrderJson.has("Status") && !todayServiceOrderJson.isNull("Status"))
					tgStatus=todayServiceOrderJson.getInt("Status");
				if (todayServiceOrderJson.has("GroupNo") && !todayServiceOrderJson.isNull("GroupNo"))
					tgGroupNO=todayServiceOrderJson.getString("GroupNo");
				if (todayServiceOrderJson.has("TGStartTime") && !todayServiceOrderJson.isNull("TGStartTime"))
					tgStartTime=todayServiceOrderJson.getString("TGStartTime");
				if (todayServiceOrderJson.has("OrderID") && !todayServiceOrderJson.isNull("OrderID"))
					orderID=todayServiceOrderJson.getInt("OrderID");
				if (todayServiceOrderJson.has("OrderObjectID") && !todayServiceOrderJson.isNull("OrderObjectID"))
					orderObjectID=todayServiceOrderJson.getInt("OrderObjectID");
			} catch (JSONException e) {
			}
			todayServiceOrder.setCustomerName(customerName);
			todayServiceOrder.setProductName(productName);
			todayServiceOrder.setProductType(productType);
			todayServiceOrder.setTotalCount(totalCount);
			todayServiceOrder.setCompleteCount(finishedCount);
			todayServiceOrder.setPaymentStatus(paymentStatus);
			todayServiceOrder.setUnfinshTgStatus(tgStatus);
			todayServiceOrder.setTgGroupNo(tgGroupNO);
			todayServiceOrder.setOrderTime(tgStartTime);
			todayServiceOrder.setOrderID(orderID);
			todayServiceOrder.setOrderObejctID(orderObjectID);
			todayServiceList.add(todayServiceOrder);
			}
		}
		return todayServiceList;
	}
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
