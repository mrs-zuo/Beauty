package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class UnfinishTGListInfo {
	private int productType;
	private int orderID;
	private String accountID;
	private String accountName;
	private String finishedCount;
	private String totalCount;
	private String productName;
	private TGListInfo tgListInfo = new TGListInfo();
	private int orderObjectID;
	private boolean isDesignated;
	private int customerID;
	private String customerName;
	private int status;
	private String groupNo;
	private String headImageURL;
	private int paymentStatus;
	private String tgStartTime;

	public UnfinishTGListInfo() {

	}

	public static ArrayList<UnfinishTGListInfo> parseListByJson(String src) {
		ArrayList<UnfinishTGListInfo> list = new ArrayList<UnfinishTGListInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			UnfinishTGListInfo item;
			for (int i = 0; i < count; i++) {
				item = new UnfinishTGListInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
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
			if (jsSrc.has("ProductName"))
				setProductName(jsSrc.getString("ProductName"));
			if (jsSrc.has("TGStartTime"))
				setTGStartTime(jsSrc.getString("TGStartTime"));
			if (jsSrc.has("AccountName"))
				setAccountName(jsSrc.getString("AccountName"));
			if (jsSrc.has("AccountID"))
				setAccountID(jsSrc.getString("AccountID"));
			if (jsSrc.has("PaymentStatus"))
				setPaymentStatus(jsSrc.getInt("PaymentStatus"));
			if (jsSrc.has("TotalCount"))
				setTotalCount(jsSrc.getString("TotalCount"));
			if (jsSrc.has("FinishedCount"))
				setFinishedCount(jsSrc.getString("FinishedCount"));
			if (jsSrc.has("GroupNo"))
				setGroupNo(jsSrc.getString("GroupNo"));
			if (jsSrc.has("OrderID"))
				setOrderID(jsSrc.getInt("OrderID"));
			if (jsSrc.has("OrderObjectID"))
				setOrderObjectID(jsSrc.getInt("OrderObjectID"));
			if (jsSrc.has("ProductType"))
				setProductType(jsSrc.getInt("ProductType"));
			if (jsSrc.has("HeadImageURL"))
				setHeadImageURL(jsSrc.getString("HeadImageURL"));
			if (jsSrc.has("Status"))
				setStatus(jsSrc.getInt("Status"));
			if (jsSrc.has("CustomerName"))
				setCustomerName(jsSrc.getString("CustomerName"));
			if (jsSrc.has("CustomerID"))
				setCustomerID(jsSrc.getInt("CustomerID"));
			if (jsSrc.has("IsDesignated"))
				setIsDesignated(jsSrc.getBoolean("IsDesignated"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setIsDesignated(boolean isDesignated) {
		this.isDesignated = isDesignated;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public void setGroupNo(String groupNo) {
		this.groupNo = groupNo;
	}

	public void setHeadImageURL(String headImageURL) {
		this.headImageURL = headImageURL;
	}

	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
	}

	public void setTGStartTime(String tgStartTime) {
		this.tgStartTime = tgStartTime;
	}

	public boolean getIsDesignated() {
		return isDesignated;
	}

	public int getCustomerID() {
		return customerID;
	}

	public String getCustomerName() {
		return customerName;
	}

	public int getStatus() {
		return status;
	}

	public String getGroupNo() {
		return groupNo;
	}

	public String getHeadImageURL() {
		return headImageURL;
	}

	public int getPaymentStatus() {
		return paymentStatus;
	}

	public String getTGStartTime() {
		return tgStartTime;
	}

	public void setOrderObjectID(int orderObjectID) {
		this.orderObjectID = orderObjectID;
	}

	public int getOrderObjectID() {
		return orderObjectID;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	public void setOrderID(int orderID) {
		this.orderID = orderID;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public void setFinishedCount(String finishedCount) {
		this.finishedCount = finishedCount;
	}

	public void setTotalCount(String totalCount) {
		this.totalCount = totalCount;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public int getProductType() {
		return productType;
	}

	public int getOrderID() {
		return orderID;
	}

	public String getAccountID() {
		return accountID;
	}

	public String getAccountName() {
		return accountName;
	}

	public String getFinishedCount() {
		return finishedCount;
	}

	public String getTotalCount() {
		return totalCount;
	}

	public String getProductName() {
		return productName;
	}

	// 扩充object

	public void setTGListInfo(TGListInfo tgListInfo) {
		this.tgListInfo = tgListInfo;
	}

	public TGListInfo getTGListInfo() {
		return tgListInfo;
	}

}
