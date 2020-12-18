package cn.com.antika.implementation;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Handler;
import android.os.Message;
import cn.com.antika.application.UserInfoApplication;
import cn.com.antika.bean.OrderInfo;
import cn.com.antika.bean.OrderListBaseConditionInfo;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetOrderListTaskImpl implements IGetBackendServerDataTask {
	private static final String METHOD_NAME = "getOrderList";
	private static final String METHOD_PARENT_NAME = "order";
	private OrderListBaseConditionInfo mOrderBaseParam;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	public GetOrderListTaskImpl(Handler handler, OrderListBaseConditionInfo orderBaseParam,UserInfoApplication userinfoApplication){
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
			param.put("BranchID",mOrderBaseParam.getBranchID());
			param.put("OrderSource",mOrderBaseParam.getOrderSource());
			param.put("ProductType", mOrderBaseParam.getProductType());
			param.put("Status", mOrderBaseParam.getStatus());
			param.put("PaymentStatus", mOrderBaseParam.getPaymentStatus());
			param.put("CreateTime", mOrderBaseParam.getCreateTime());
			param.put("PageIndex", mOrderBaseParam.getPageIndex());
			param.put("PageSize", mOrderBaseParam.getPageSize());
			if(mOrderBaseParam.getResponsiblePersonID()!=null && !(("").equals(mOrderBaseParam.getResponsiblePersonID())))
				param.put("ResponsiblePersonIDs",new JSONArray(mOrderBaseParam.getResponsiblePersonID()));
			param.put("CustomerID",mOrderBaseParam.getCustomerID());
			param.put("IsShowAll",mOrderBaseParam.getIsAllTheBranch());
			param.put("FilterByTimeFlag",mOrderBaseParam.getFilterByTimeFlag());
			if(mOrderBaseParam.getFilterByTimeFlag()==1){
				param.put("StartTime",mOrderBaseParam.getStartDate());
				param.put("EndTime", mOrderBaseParam.getEndDate());
			}
			param.put("SerchField",mOrderBaseParam.getSearchWord());
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
			for(int i = 0; i < OrderListCount; i++){
				try {
					orderJsonObject = orderListArray.getJSONObject(i);
					orderItem = new OrderInfo();
					if(orderJsonObject.has("CreateTime"))
						orderItem.setCreateTime(orderJsonObject.getString("CreateTime"));
					if (orderJsonObject.has("OrderID"))
						orderItem.setOrderID(orderJsonObject.getInt("OrderID"));
					if (orderJsonObject.has("OrderObjectID"))
						orderItem.setOrderObejctID(orderJsonObject.getInt("OrderObjectID"));
					if (orderJsonObject.has("CustomerName"))
						orderItem.setCustomerName(orderJsonObject.getString("CustomerName"));
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
					if(orderJsonObject.has("IsThisBranch"))
						orderItem.setIsThisBranch(orderJsonObject.getInt("IsThisBranch"));
					orderList.add(orderItem);
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		return orderList;
		
	}
	@Override
	public UserInfoApplication getApplication() {
		// TODO Auto-generated method stub
		return userinfoApplication;
	}
}
