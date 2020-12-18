package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;
import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class OrderBaseInfo implements Serializable, Parcelable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String OrderID;
	private String OrderCreatorID;
	private String OrderTime;
	private String ResponsiblePersonName;
	private String ProductName;
	private String ProductType;
	private String Quantity;
	private String TotalPrice;
	private String TotalSalePrice;
	private String Status;
	private int paymentStatus;// 订单的支付状态 0:未支付 1:部分付 2:已支付
	private String paymentRemark;
	private String orderSerialNumber;
	private String orderExpirationtime;
	private String unPayAmount = "0";
	private String paymentInfoJsonArray;
	private String branchName = "";
	private String createTime;
	private String OrderObjectID;
	private int orderObjectIDInt;
	private int productTypeInt;
	private String orderNumber;

	private int totalCount;
	private int finishedCount;
	private int executingCount;
	private int ResponsiblePersonID;
	
	
	//
	// private ArrayList<CourseInformation> mArrLiCourse;

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getFinishedCount() {
		return finishedCount;
	}

	public void setFinishedCount(int finishedCount) {
		this.finishedCount = finishedCount;
	}

	public int getExecutingCount() {
		return executingCount;
	}

	public void setExecutingCount(int executingCount) {
		this.executingCount = executingCount;
	}

	public int getResponsiblePersonID() {
		return ResponsiblePersonID;
	}

	public void setResponsiblePersonID(int responsiblePersonID) {
		ResponsiblePersonID = responsiblePersonID;
	}

	public OrderBaseInfo() {
		OrderID = "0";
		Quantity = "0";
		TotalPrice = "0";
		TotalSalePrice = "0";
		paymentRemark = "";
		createTime = "";
		orderExpirationtime = "2099-12-31";
	}

	public OrderBaseInfo(Parcel source) {
		OrderID = source.readString();
		OrderCreatorID = source.readString();
		OrderTime = source.readString();

		ResponsiblePersonName = source.readString();
		ProductName = source.readString();
		ProductType = source.readString();
		Quantity = source.readString();
		TotalPrice = source.readString();
		TotalSalePrice = source.readString();
		Status = source.readString();
		paymentStatus = source.readInt();
		paymentRemark = source.readString();
		orderSerialNumber = source.readString();
		orderExpirationtime = source.readString();
		unPayAmount = source.readString();
		paymentInfoJsonArray = source.readString();
		branchName = source.readString();
		createTime = source.readString();
		OrderObjectID = source.readString();

		// source.readList(mArrLiCourse, null);;

	}

	public ArrayList<OrderBaseInfo> parseListByJson(String src) {
		ArrayList<OrderBaseInfo> list = new ArrayList<OrderBaseInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("OrderList");
			int count = jarrList.length();
			OrderBaseInfo item;
			for (int i = 0; i < count; i++) {
				item = new OrderBaseInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public boolean parseByJson(String src) {
		JSONObject jsSrc = null;
		try {
			jsSrc = new JSONObject(src);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return parseByJson(jsSrc);
	}

	public static ArrayList<OrderBaseInfo> oldOrderByJson(String stringJson){
		ArrayList<OrderBaseInfo> dispenseCustomerOldOrderList = null;
		if(dispenseCustomerOldOrderList!=null && dispenseCustomerOldOrderList.size()>0)
			dispenseCustomerOldOrderList.clear();
		else
			dispenseCustomerOldOrderList = new ArrayList<OrderBaseInfo>();
		JSONArray unFinishTGArray=null;
		try {
			unFinishTGArray = new JSONArray(stringJson);
		} catch (JSONException e) {
		}
		if (unFinishTGArray != null) {
			for (int i = 0; i < unFinishTGArray.length(); i++) {
				OrderBaseInfo  unfinishOrder=new OrderBaseInfo();
				JSONObject unfinishOrderJson = null;
				String     productName="";
				int        productType=-1;
				int        totalCount=0;
				int        finishedCount=0;
				int        executingCount=0;
				String     tgGroupNO="";
				String     orderTime="";
				String     accountName="";
				int        accountID=0;
				int        orderID=0;
				int        orderObjectID=0;
				try {
					unfinishOrderJson = unFinishTGArray.getJSONObject(i);
					if (unfinishOrderJson.has("ProductName") && !unfinishOrderJson.isNull("ProductName"))
						productName=unfinishOrderJson.getString("ProductName");
					if (unfinishOrderJson.has("ProductType") && !unfinishOrderJson.isNull("ProductType"))
						productType=unfinishOrderJson.getInt("ProductType");
					if (unfinishOrderJson.has("TotalCount") && !unfinishOrderJson.isNull("TotalCount"))
						totalCount=unfinishOrderJson.getInt("TotalCount");
					if (unfinishOrderJson.has("FinishedCount") && !unfinishOrderJson.isNull("FinishedCount"))
						finishedCount=unfinishOrderJson.getInt("FinishedCount");
					if(unfinishOrderJson.has("ExecutingCount") && !unfinishOrderJson.isNull("ExecutingCount"))
						executingCount=unfinishOrderJson.getInt("ExecutingCount");
					if (unfinishOrderJson.has("GroupNo") && !unfinishOrderJson.isNull("GroupNo"))
						tgGroupNO=unfinishOrderJson.getString("GroupNo");
					if (unfinishOrderJson.has("OrderTime") && !unfinishOrderJson.isNull("OrderTime"))
						orderTime=unfinishOrderJson.getString("OrderTime");
					if (unfinishOrderJson.has("AccountName") && !unfinishOrderJson.isNull("AccountName"))
						accountName=unfinishOrderJson.getString("AccountName");
					if (unfinishOrderJson.has("ResponsiblePersonName") && !unfinishOrderJson.isNull("ResponsiblePersonName")) {
						accountName=unfinishOrderJson.getString("ResponsiblePersonName");
					}
					if (unfinishOrderJson.has("AccountID") && !unfinishOrderJson.isNull("AccountID"))
						accountID=unfinishOrderJson.getInt("AccountID");
					if (unfinishOrderJson.has("OrderID") && !unfinishOrderJson.isNull("OrderID"))
						orderID=unfinishOrderJson.getInt("OrderID");
					if (unfinishOrderJson.has("OrderObjectID") && !unfinishOrderJson.isNull("OrderObjectID"))
						orderObjectID=unfinishOrderJson.getInt("OrderObjectID");
					if(unfinishOrderJson.has("TGFinishedCount"))
						finishedCount=unfinishOrderJson.getInt("TGFinishedCount");
					if(unfinishOrderJson.has("TGTotalCount"))
						totalCount=unfinishOrderJson.getInt("TGTotalCount");
				} catch (JSONException e) {
				}
				if(productType==0){
					if(totalCount!=0){
						if((totalCount-finishedCount-executingCount)>0){
							unfinishOrder.setProductName(productName);
							unfinishOrder.setProductType(String.valueOf(productType));
							unfinishOrder.setTotalCount(totalCount);
							unfinishOrder.setFinishedCount(finishedCount);
							unfinishOrder.setExecutingCount(executingCount);
//							unfinishOrder.setTgGroupNo(tgGroupNO);
							unfinishOrder.setOrderTime(orderTime);
							unfinishOrder.setResponsiblePersonName(accountName);
							unfinishOrder.setResponsiblePersonID(accountID);
							unfinishOrder.setOrderID(String.valueOf(orderID));
							unfinishOrder.setOrderObjectID(String.valueOf(orderObjectID));
							dispenseCustomerOldOrderList.add(unfinishOrder);
						}
					}else{
						unfinishOrder.setProductName(productName);
						unfinishOrder.setProductType(String.valueOf(productType));
						unfinishOrder.setTotalCount(totalCount);
						unfinishOrder.setFinishedCount(finishedCount);
						unfinishOrder.setExecutingCount(executingCount);
//						unfinishOrder.setTgGroupNo(tgGroupNO);
						unfinishOrder.setOrderTime(orderTime);
						unfinishOrder.setResponsiblePersonName(accountName);
						unfinishOrder.setResponsiblePersonID(accountID);
						unfinishOrder.setOrderID(String.valueOf(orderID));
						unfinishOrder.setOrderObjectID(String.valueOf(orderObjectID));
						dispenseCustomerOldOrderList.add(unfinishOrder);
					}
				}
			}
		}
		return dispenseCustomerOldOrderList;
	}
	
	public boolean parseByJson(JSONObject src) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("OrderID")) {
				setOrderID(jsSrc.getString("OrderID"));
			}
			if (jsSrc.has("CreatorID")) {
				setOrderCreatorID(jsSrc.getString("CreatorID"));
			}
			if (jsSrc.has("BranchName")) {
				setBranchName(jsSrc.getString("BranchName"));
			}
			if (jsSrc.has("OrderTime")) {
				setOrderTime(jsSrc.getString("OrderTime"));
			}
			if (jsSrc.has("ResponsiblePersonName") && !jsSrc.isNull("ResponsiblePersonName")) {
				setResponsiblePersonName(jsSrc.getString("ResponsiblePersonName"));
			}
			if (jsSrc.has("Quantity")) {
				setQuantity(jsSrc.getString("Quantity"));
			}
			if (jsSrc.has("ProductName")) {
				setProductName(jsSrc.getString("ProductName"));
			}
			if (jsSrc.has("ProductType")) {
				setProductType(jsSrc.getString("ProductType"));
			}
			if (jsSrc.has("Status")) {
				setStatus(jsSrc.getString("Status"));
			}
			if (jsSrc.has("PaymentStatus")) {
				setPaymentStatus(jsSrc.getInt("PaymentStatus"));
			}
			if (jsSrc.has("TotalOrigPrice")) {
				setTotalPrice(jsSrc.getString("TotalOrigPrice"));
			}
			if (jsSrc.has("TotalSalePrice")) {
				setTotalSalePrice(jsSrc.getString("TotalSalePrice"));
			}
			if (jsSrc.has("UnPaidPrice")) {
				setUnPayAmount(jsSrc.getString("UnPaidPrice"));
			}
			if (jsSrc.has("ExpirationTime"))
				setOrderExpirationtime(jsSrc.getString("ExpirationTime"));

			if (jsSrc.has("OrderNumber"))
				setOrderNumber(jsSrc.getString("OrderNumber"));
			if (jsSrc.has("PaymentRemark"))
				setPaymentRemark(jsSrc.getString("PaymentRemark"));

			if (jsSrc.has("OrderObjectID")) {
				setOrderObjectID(jsSrc.getString("OrderObjectID"));
			}
			if(jsSrc.has("TGFinishedCount"))
				setFinishedCount(jsSrc.getInt("TGFinishedCount"));
			if(jsSrc.has("TGTotalCount"))
				setTotalCount(jsSrc.getInt("TGTotalCount"));
			if (jsSrc.has("UnPaidPrice"))
				setUnPayAmount(jsSrc.getString("UnPaidPrice"));
			
			if (jsSrc.has("PaymentList")) {
				JSONArray orderPaymentArray = jsSrc.getJSONArray("PaymentList");
				setPaymentInfoJsonArray(orderPaymentArray);

			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setOrderObjectIDInt(int orderObjectIDInt) {
		this.orderObjectIDInt = orderObjectIDInt;
	}

	public void setProductTypeInt(int productTypeInt) {
		this.productTypeInt = productTypeInt;
	}

	public int getOrderObjectIDInt() {
		return orderObjectIDInt;
	}

	public int getProductTypeInt() {
		return productTypeInt;
	}

	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}

	public String getOrderNumber() {
		return orderNumber;
	}

	public void setOrderID(String OrderID) {
		this.OrderID = OrderID;
	}

	public String getOrderID() {
		return OrderID;
	}

	public String getOrderCreatorID() {
		return OrderCreatorID;
	}

	public void setOrderCreatorID(String orderCreatorID) {
		OrderCreatorID = orderCreatorID;
	}

	public void setOrderTime(String OrderTime) {
		this.OrderTime = OrderTime;
	}

	public String getOrderTime() {
		return OrderTime;
	}

	public void setResponsiblePersonName(String ResponsiblePersonName) {
		this.ResponsiblePersonName = ResponsiblePersonName;
	}

	public String getResponsiblePersonName() {
		return ResponsiblePersonName;
	}

	public void setProductType(String productType) {
		this.ProductType = productType;
	}

	public String getProductType() {
		return ProductType;
	}

	public void setQuantity(String quantity) {
		this.Quantity = quantity;
	}

	public String getQuantity() {
		return Quantity;
	}

	public void setOrderStatus(String Status) {
		this.Status = Status;
	}

	public String getOrderStatus() {
		return Status;
	}

	public void setTotalPrice(String TotalPrice) {
		this.TotalPrice = NumberFormatUtil
				.StringFormatToStringWithoutSingle(TotalPrice);
	}

	public String getTotalPrice() {
		return TotalPrice;
	}

	public void setTotalSalePrice(String TotalSalePrice) {
		this.TotalSalePrice = NumberFormatUtil
				.StringFormatToStringWithoutSingle(TotalSalePrice);
		;
	}

	public String getTotalSalePrice() {
		return TotalSalePrice;
	}

	public void setProductName(String ProductName) {
		this.ProductName = ProductName;
	}

	public String getProductName() {
		return ProductName;
	}

	public int getPaymentStatus() {
		return paymentStatus;
	}

	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
	}

	public String getStatus() {
		return Status;
	}

	public void setStatus(String status) {
		Status = status;
	}

	public String getPaymentRemark() {
		return paymentRemark;
	}

	public void setPaymentRemark(String paymentRemark) {
		this.paymentRemark = paymentRemark;
	}

	public String getOrderSerialNumber() {
		return orderSerialNumber;
	}

	public void setOrderSerialNumber(String orderSerialNumber) {
		this.orderSerialNumber = orderSerialNumber;
	}

	public String getOrderExpirationtime() {
		return orderExpirationtime;
	}

	public void setOrderExpirationtime(String orderExpirationtime) {
		if (orderExpirationtime.equals("")
				&& orderExpirationtime.equals("null")) {
			return;
		}
		String time = "";
		try {
			time = orderExpirationtime.substring(0, 10);
		} catch (Exception e) {

		}
		this.orderExpirationtime = time;
	}

	public String getBranchName() {
		return branchName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public String getUnPayAmount() {
		return unPayAmount;
	}

	public void setUnPayAmount(String unPayAmount) {
		this.unPayAmount = NumberFormatUtil
				.StringFormatToStringWithoutSingle(unPayAmount);
	}

	public void setOrderObjectID(String orderObjectID) {
		this.OrderObjectID = orderObjectID;
	}

	public String getOrderObjectID() {
		return OrderObjectID;
	}

	// public ArrayList<CourseInformation> getArrLiCourse() {
	// return mArrLiCourse;
	// }
	//
	// public void setArrLiCourse(ArrayList<CourseInformation> arrLiCourse) {
	// mArrLiCourse = arrLiCourse;
	// }

	public ArrayList<BalanceInfo> getPaymentInfo() {
		ArrayList<BalanceInfo> paymentInfoList = new ArrayList<BalanceInfo>();
		BalanceInfo paymentInfo;
		JSONArray paymentJson = null;
		try {
			paymentJson = new JSONArray(paymentInfoJsonArray);
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return paymentInfoList;
		}

		for (int i = 0; i < paymentJson.length(); i++) {
			JSONObject orderPaymentDetailJson;
			try {

				orderPaymentDetailJson = paymentJson.getJSONObject(i);
				paymentInfo = new BalanceInfo();
				if (orderPaymentDetailJson.has("PaymentMode"))
					paymentInfo.setPaymentMode(orderPaymentDetailJson
							.getString("PaymentMode"));
				if (orderPaymentDetailJson.has("PaymentAmount"))
					paymentInfo.setPaymentAmount(orderPaymentDetailJson
							.getString("PaymentAmount"));
				paymentInfoList.add(paymentInfo);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		return paymentInfoList;
	}

	// public JSONArray getPaymentInfoJsonArray() {
	// return paymentInfoJsonArray;
	// }

	public void setPaymentInfoJsonArray(JSONArray paymentInfoJsonArray) {
		this.paymentInfoJsonArray = paymentInfoJsonArray.toString();
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeString(OrderID);
		dest.writeString(OrderCreatorID);
		dest.writeString(OrderTime);
		dest.writeString(ResponsiblePersonName);
		dest.writeString(ProductName);
		dest.writeString(ProductType);
		dest.writeString(Quantity);
		dest.writeString(TotalPrice);
		dest.writeString(TotalSalePrice);
		dest.writeString(Status);
		dest.writeInt(paymentStatus);
		dest.writeString(paymentRemark);
		dest.writeString(orderSerialNumber);
		dest.writeString(orderExpirationtime);
		dest.writeString(unPayAmount);
		dest.writeString(paymentInfoJsonArray);
		dest.writeString(branchName);
		dest.writeString(createTime);
		dest.writeString(OrderObjectID);

		// dest.writeTypedList(mArrLiCourse);
	}

	// 实例化静态内部对象CREATOR实现接口Parcelable.Creator
	public static final Parcelable.Creator<OrderBaseInfo> CREATOR = new Creator<OrderBaseInfo>() {

		@Override
		public OrderBaseInfo[] newArray(int size) {
			return new OrderBaseInfo[size];
		}

		// 将Parcel对象反序列化为ParcelableDate
		@Override
		public OrderBaseInfo createFromParcel(Parcel source) {
			return new OrderBaseInfo(source);
		}
	};
}
