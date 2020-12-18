package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class UnconfirmInformation {
	private String orderID;
	private String treatmentID;
	private String productType;
	private String time;
	private String accountName;
	private String quantity;
	private String productName;
	private String remark="";
	private String lastFlag;
	
	public UnconfirmInformation(){
		accountName = "";
		
	}
	
	public static ArrayList<UnconfirmInformation> parseListByJson(String src){
		ArrayList<UnconfirmInformation> list = new ArrayList<UnconfirmInformation>();
		try {
//			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			UnconfirmInformation item;
			for(int i = 0; i < count; i++){
				item = new UnconfirmInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	
	public boolean parseByJson(String src){
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
			if(jsSrc.has("OrderID")){
				setOrderID(jsSrc.getString("OrderID"));
			}
			if (jsSrc.has("TreatmentID")) {
				setTreatmentID(jsSrc.getString("TreatmentID"));
			}
			if (jsSrc.has("ProductType")) {
				setProductType(jsSrc.getString("ProductType"));
			}
			if (jsSrc.has("Time")) {
				setTime(jsSrc.getString("Time"));
			}
			if (jsSrc.has("AccountName")) {
				setAccountName(jsSrc.getString("AccountName"));
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
			if (jsSrc.has("ProductName")) {
				setProductName(jsSrc.getString("ProductName"));
			}
			if (jsSrc.has("Remark")) {
				setRemark(jsSrc.getString("Remark"));
			}
			if (jsSrc.has("IsLastFlag")) {
				setLastFlag(jsSrc.getString("IsLastFlag"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public String getOrderID() {
		return orderID;
	}

	public void setOrderID(String orderID) {
		this.orderID = orderID;
	}

	public String getTreatmentID() {
		return treatmentID;
	}

	public void setTreatmentID(String treatmentID) {
		this.treatmentID = treatmentID;
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public String getAccountName() {
		return accountName;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getQuantity() {
		return quantity;
	}

	public void setQuantity(String quantity) {
		if(quantity.equals("null")){
			this.quantity = "0";
		}else
			this.quantity = quantity;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		if(!remark.equals("null"))
			this.remark = remark;
	}

	public String getLastFlag() {
		return lastFlag;
	}

	public void setLastFlag(String lastFlag) {
		this.lastFlag = lastFlag;
	}
	
}
