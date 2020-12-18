package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ExecutingOrderListInfo {
	private String productType;
	private String orderID;
	private String accountID;
	private String accountName;
	private String orderTime;
	private String executingCount;
	private String finishedCount;
	private String totalCount;
	private String productName;
	private List<TGListInfo> tgListInfoList = new ArrayList<TGListInfo>();
	private TGListInfo tgListInfo = new TGListInfo();
	private String orderObjectID;

	public ExecutingOrderListInfo() {

	}

	public static ArrayList<ExecutingOrderListInfo> parseListByJson(String src) {
		ArrayList<ExecutingOrderListInfo> list = new ArrayList<ExecutingOrderListInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			ExecutingOrderListInfo item;
			for (int i = 0; i < count; i++) {
				item = new ExecutingOrderListInfo();
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
			if (jsSrc.has("TotalCount"))
				setTotalCount(jsSrc.getString("TotalCount"));
			if (jsSrc.has("FinishedCount"))
				setFinishedCount(jsSrc.getString("FinishedCount"));
			if (jsSrc.has("ExecutingCount"))
				setExecutingCount(jsSrc.getString("ExecutingCount"));
			if (jsSrc.has("OrderTime"))
				setOrderTime(jsSrc.getString("OrderTime"));
			if (jsSrc.has("AccountName"))
				setAccountName(jsSrc.getString("AccountName"));
			if (jsSrc.has("AccountID"))
				setAccountID(jsSrc.getString("AccountID"));
			if (jsSrc.has("OrderID"))
				setOrderID(jsSrc.getString("OrderID"));
			if (jsSrc.has("OrderObjectID"))
				setOrderObjectID(jsSrc.getString("OrderObjectID"));
			if (jsSrc.has("ProductType"))
				setProductType(jsSrc.getString("ProductType"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setOrderObjectID(String orderObjectID) {
		this.orderObjectID = orderObjectID;
	}

	public String getOrderObjectID() {
		return orderObjectID;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}

	public void setOrderID(String orderID) {
		this.orderID = orderID;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public void setOrderTime(String orderTime) {
		this.orderTime = orderTime;
	}

	public void setExecutingCount(String executingCount) {
		this.executingCount = executingCount;
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

	public String getProductType() {
		return productType;
	}

	public String getOrderID() {
		return orderID;
	}

	public String getAccountID() {
		return accountID;
	}

	public String getAccountName() {
		return accountName;
	}

	public String getOrderTime() {
		return orderTime;
	}

	public String getExecutingCount() {
		return executingCount;
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
	public void setTGListInfoList(List<TGListInfo> tgListInfoList) {
		this.tgListInfoList = tgListInfoList;
	}

	public List<TGListInfo> getTGListInfoList() {
		return tgListInfoList;
	}

	public void setTGListInfo(TGListInfo tgListInfo) {
		this.tgListInfo = tgListInfo;
	}

	public TGListInfo getTGListInfo() {
		return tgListInfo;
	}
}
