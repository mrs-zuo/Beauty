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
import cn.com.antika.bean.TreatmentGroup;
import cn.com.antika.bean.WebDataObject;
import cn.com.antika.constant.Constant;
import cn.GlmourPromise.Beauty.interfaces.IGetBackendServerDataTask;

public class GetUnpaidOrderListTaskImpl implements IGetBackendServerDataTask {
	private static final String METHOD_NAME = "UnPaidListByCustomerID";
	private static final String METHOD_PARENT_NAME = "Payment";
	private OrderListBaseConditionInfo mOrderBaseParam;
	private Handler mHandler;
	private UserInfoApplication userinfoApplication;
	private  int                mBranchID;
	public GetUnpaidOrderListTaskImpl(Handler handler, OrderListBaseConditionInfo orderBaseParam,UserInfoApplication userinfoApplication,int branchID){
		this.mHandler = handler;
		this.mOrderBaseParam = orderBaseParam;
		this.userinfoApplication=userinfoApplication;
		this.mBranchID=branchID;
	}
	@Override
	public String getmethodName() {
		return METHOD_NAME;
	}

	@Override
	public String getmethodParentName() {
		return METHOD_PARENT_NAME;
	}

	@Override
	public Object getParamObject() {
		JSONObject param = new JSONObject();
		try {
			//基本条件
			param.put("CustomerID",mOrderBaseParam.getCustomerID());
			param.put("BranchID",mBranchID);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return param;
	}

	@Override
	public void handleResult(WebDataObject resultObject) {
		Message msg = mHandler.obtainMessage();
		msg.what = resultObject.code;
		if(resultObject.code == Constant.GET_WEB_DATA_TRUE){
			JSONArray resultJsonObject = (JSONArray) resultObject.result;
			msg.obj = handleSoapObjectResult(resultJsonObject);
			
		}else if(resultObject.code == Constant.GET_WEB_DATA_EXCEPTION || resultObject.code == Constant.GET_WEB_DATA_FALSE){
			msg.obj = resultObject.result;
		}
		else if(resultObject.code == Constant.LOGIN_ERROR || resultObject.code == Constant.APP_VERSION_ERROR){
			msg.what=resultObject.code;
		}
		msg.sendToTarget();
	}
	private ArrayList<OrderInfo> handleSoapObjectResult(JSONArray contentJsonObject){
		ArrayList<OrderInfo> orderList = new ArrayList<OrderInfo>();
		int OrderListCount = contentJsonObject.length();
		JSONArray tgArray =null;
		if(OrderListCount > 0){
			JSONObject orderJsonObject;
			OrderInfo orderItem;
			for(int i = 0; i < OrderListCount; i++){
				try {
					orderJsonObject = contentJsonObject.getJSONObject(i);
					orderItem = new OrderInfo();
					
					if (orderJsonObject.has("OrderID"))
						orderItem.setOrderID(orderJsonObject.getInt("OrderID"));
					if (orderJsonObject.has("ProductType"))
						orderItem.setProductType(orderJsonObject.getInt("ProductType"));
					if (orderJsonObject.has("TotalSalePrice"))
						orderItem.setTotalPrice(orderJsonObject.getString("TotalSalePrice"));
					if (orderJsonObject.has("UnPaidPrice"))
						orderItem.setUnpaidPrice(orderJsonObject.getString("UnPaidPrice"));
					if (orderJsonObject.has("PaymentStatus"))
						orderItem.setPaymentStatus(orderJsonObject.getInt("PaymentStatus"));
					if (orderJsonObject.has("OrderTime"))
						orderItem.setOrderTime(orderJsonObject.getString("OrderTime"));
					if (orderJsonObject.has("ResponsiblePersonName"))
						orderItem.setResponsiblePersonName(orderJsonObject.getString("ResponsiblePersonName"));
					if (orderJsonObject.has("ProductName"))
						orderItem.setProductName(orderJsonObject.getString("ProductName"));
					if (orderJsonObject.has("Quantity"))
						orderItem.setQuantity(orderJsonObject.getInt("Quantity"));
					if (orderJsonObject.has("OrderObjectID"))
						orderItem.setOrderObejctID(orderJsonObject.getInt("OrderObjectID"));
					if(orderJsonObject.has("TGList") && !orderJsonObject.isNull("TGList")){
						try {
							JSONObject tgObj=(JSONObject)contentJsonObject.get(i);
							tgArray=tgObj.getJSONArray("TGList");
						}catch(JSONException e){
							
						}
						if (tgArray!=null) {
							ArrayList<TreatmentGroup> treatmentGroupList=new ArrayList<TreatmentGroup>();
							for(int j = 0; j < tgArray.length(); j++){
								TreatmentGroup treatmentGroup = new TreatmentGroup();
								JSONObject treatmentGroupJson = null;
								try {
									treatmentGroupJson = (JSONObject) tgArray.get(j);
								} catch (JSONException e) {
								}
								if(treatmentGroupJson.has("Status")){
									treatmentGroup.setStatus(treatmentGroupJson.getInt("Status"));
								}
								if(treatmentGroupJson.has("ServicePICName")){
									treatmentGroup.setServicePicName(treatmentGroupJson.getString("ServicePICName"));
								}
								if(treatmentGroupJson.has("StartTime")){
									treatmentGroup.setStartTime(treatmentGroupJson.getString("StartTime"));
								}
								treatmentGroupList.add(treatmentGroup);
                                
							}
							orderItem.setTreatmentGroupList(treatmentGroupList);
						}
					}
					orderList.add(orderItem);
				 } catch (JSONException e) {
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
