package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;
import android.os.Parcelable.Creator;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class OrderPayListInfo  implements Serializable, Parcelable{
	private static final long serialVersionUID = 1L;
	private int    OrderID;
	private String OrderCreatorID;
	private String OrderTime;
	private String ResponsiblePersonName;
	private String ProductName;
	private int    ProductType;
	private String Quantity;
	private String TotalPrice;
	private String TotalSalePrice;
	private String Status;
	private int    paymentStatus;// 订单的支付状态 0:未支付 1:部分付 2:已支付
	private String paymentRemark;
	private String orderSerialNumber;
	private String orderExpirationtime;
	private String unPayAmount = "0";
	private String paymentInfoJsonArray;
	private String branchName = "";
	private String createTime;
	private int    OrderObjectID;
	private String TGListJsonArray;
	private int    branchID;
	private int    cardID;
	private String cardName;
	public OrderPayListInfo() {
		OrderID = 0;
		Quantity = "0";
		TotalPrice = "0";
		TotalSalePrice = "0";
		paymentRemark = "";
		createTime = "";
		orderExpirationtime = "2099-12-31";
	}

	public OrderPayListInfo(Parcel source) {
		OrderID = source.readInt();
		OrderCreatorID = source.readString();
		OrderTime = source.readString();
		ResponsiblePersonName = source.readString();
		ProductName = source.readString();
		ProductType = source.readInt();
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
		OrderObjectID = source.readInt();
		branchID=source.readInt();
		cardID=source.readInt();
		TGListJsonArray = source.readString();
		cardName=source.readString();
	}

	public static ArrayList<OrderPayListInfo> parseListByJson(String src) {
		ArrayList<OrderPayListInfo> list = new ArrayList<OrderPayListInfo>();
		try {
			 
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			OrderPayListInfo item;
			for (int i = 0; i < count; i++) {
				item = new OrderPayListInfo();
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

	public boolean parseByJson(JSONObject src) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("OrderID")) {
				setOrderID(jsSrc.getInt("OrderID"));
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
			if (jsSrc.has("ResponsiblePersonName")) {
				setResponsiblePersonName(jsSrc.getString("ResponsiblePersonName"));
			}
			if (jsSrc.has("Quantity")) {
				setQuantity(jsSrc.getString("Quantity"));
			}
			if (jsSrc.has("ProductName")) {
				setProductName(jsSrc.getString("ProductName"));
			}
			if (jsSrc.has("ProductType")) {
				setProductType(jsSrc.getInt("ProductType"));
			}
			if (jsSrc.has("CardID")) {
				setCardID(jsSrc.getInt("CardID"));
			}
			if (jsSrc.has("CardName")) {
				setCardName(jsSrc.getString("CardName"));
			}
			if (jsSrc.has("BranchName")) {
				setBranchName(jsSrc.getString("BranchName"));
			}
			if (jsSrc.has("BranchID")) {
				setBranchID(jsSrc.getInt("BranchID"));
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

			if (jsSrc.has("PaymentRemark"))
				setPaymentRemark(jsSrc.getString("PaymentRemark"));

			if(jsSrc.has("OrderObjectID")){
				setOrderObjectID(jsSrc.getInt("OrderObjectID"));
			}
			if (jsSrc.has("OrderNumber"))
				setOrderSerialNumber(jsSrc.getString("OrderNumber"));
			if (jsSrc.has("UnPaidPrice"))
				setUnPayAmount(jsSrc.getString("UnPaidPrice"));

			if (jsSrc.has("PaymentList")) {
				JSONArray orderPaymentArray = jsSrc.getJSONArray("PaymentList");
				setPaymentInfoJsonArray(orderPaymentArray);

			}
			if (jsSrc.has("TGList")) {
				JSONArray TGListArray = jsSrc.getJSONArray("TGList");
				setTGListJsonArray(TGListArray);
			}
			
			

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setOrderID(int OrderID) {
		this.OrderID = OrderID;
	}

	public int getOrderID() {
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

	public void setProductType(int productType) {
		this.ProductType = productType;
	}

	public int getProductType() {
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

	public void setOrderObjectID(int orderObjectID) {
		this.OrderObjectID = orderObjectID;
	}

	public int getOrderObjectID() {
		return OrderObjectID;
	}
	public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public int getCardID() {
		return cardID;
	}
	public void setCardID(int cardID) {
		this.cardID = cardID;
	}
	
	public String getCardName() {
		return cardName;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

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

	public void setPaymentInfoJsonArray(JSONArray paymentInfoJsonArray) {
		this.paymentInfoJsonArray = paymentInfoJsonArray.toString();
	}

	public void setTGListJsonArray(JSONArray TGListJsonArray) {
		this.TGListJsonArray = TGListJsonArray.toString();
	}

	public ArrayList<TGListInfo> getTGList() {
		ArrayList<TGListInfo> TGList = new ArrayList<TGListInfo>();
		TGListInfo tgListInfo = null;
		JSONArray tgListJson = null;
		try {
			tgListJson = new JSONArray(TGListJsonArray);
		} catch (JSONException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
			return TGList;
		}
		
		for (int i = 0; i < tgListJson.length(); i++) {
			JSONObject tgListDetailJson;
			try {

				tgListDetailJson = tgListJson.getJSONObject(i);
				tgListInfo = new TGListInfo();
				if (tgListDetailJson.has("ServicePICName"))
					tgListInfo.setServicePICName(tgListDetailJson
							.getString("ServicePICName"));
				if (tgListDetailJson.has("Status"))
					tgListInfo.setStatus(tgListDetailJson.getInt("Status"));
				if (tgListDetailJson.has("StartTime"))
					tgListInfo.setStartTime(tgListDetailJson
							.getString("StartTime"));
				TGList.add(tgListInfo);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
		return TGList;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeInt(OrderID);
		dest.writeString(OrderCreatorID);
		dest.writeString(OrderTime);
		dest.writeString(ResponsiblePersonName);
		dest.writeString(ProductName);
		dest.writeInt(ProductType);
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
		dest.writeInt(OrderObjectID);
		dest.writeInt(branchID);
		dest.writeInt(cardID);
		dest.writeString(TGListJsonArray);
		dest.writeString(cardName);
	}
	// 实例化静态内部对象CREATOR实现接口Parcelable.Creator
	public static final Parcelable.Creator<OrderPayListInfo> CREATOR = new Creator<OrderPayListInfo>() {

		@Override
		public OrderPayListInfo[] newArray(int size) {
			return new OrderPayListInfo[size];
		}

		// 将Parcel对象反序列化为ParcelableDate
		@Override
		public OrderPayListInfo createFromParcel(Parcel source) {
			return new OrderPayListInfo(source);
		}
	};
}
