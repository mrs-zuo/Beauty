package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ProductInformation {

	private String productName;
	private String quantity;
	private String subTotalPrice;
	private String subTotalSalePrice;
	private String responsiblePersonName;
	private String responsiblePersonID;
	private String orderSerinalNumber;//订单编号
	private String orderExpirationtime;
	private String paymentRemark;
	private JSONArray paymentInfoJsonArray;
	private int paymentStatus;

	public ProductInformation() {
		productName = "";
		orderSerinalNumber = "";
		orderExpirationtime = "2099-12-31";
		paymentRemark = "";
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getQuantity() {
		return quantity;
	}

	public void setQuantity(String quantity) {
		this.quantity = quantity;
	}

	public String getSubTotalPrice() {
		return subTotalPrice;
	}

	public void setSubTotalPrice(String subTotalPrice) {
		this.subTotalPrice = subTotalPrice;
	}

	public String getSubTotalSalePrice() {
		return subTotalSalePrice;
	}

	public void setSubTotalSalePrice(String subTotalSalePrice) {
		this.subTotalSalePrice = subTotalSalePrice;
	}
	
	public String getResponsiblePersonName(){
		return responsiblePersonName;
	}
	public void setResponsiblePersonName(String responsiblePersonName){
		this.responsiblePersonName = responsiblePersonName;
	}

	public String getOrderSerinalNumber() {
		return orderSerinalNumber;
	}

	public void setOrderSerinalNumber(String orderSerinalNumber) {
		this.orderSerinalNumber = orderSerinalNumber;
	}

	public String getOrderExpirationtime() {
		return orderExpirationtime;
	}

	public void setOrderExpirationtime(String orderExpirationtime) {		
		String time[] = orderExpirationtime.split("T");
		this.orderExpirationtime = time[0];
	}

	public String getPaymentRemark() {
		return paymentRemark;
	}

	public void setPaymentRemark(String paymentRemark) {
		if(!paymentRemark.equals("anyType{}"))
			this.paymentRemark = paymentRemark;
	}

	public String getResponsiblePersonID() {
		return responsiblePersonID;
	}

	public void setResponsiblePersonID(String responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}

	public int getPaymentStatus() {
		return paymentStatus;
	}

	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
	}

	public ArrayList<BalanceInfo> getPaymentInfo() {
		ArrayList<BalanceInfo> paymentInfoList = new ArrayList<BalanceInfo>();
		BalanceInfo paymentInfo;
		for (int i = 0; i < paymentInfoJsonArray.length(); i++) {
			JSONObject orderPaymentDetailJson;
			try {
				orderPaymentDetailJson = paymentInfoJsonArray.getJSONObject(i);
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
		this.paymentInfoJsonArray = paymentInfoJsonArray;
	}	
}
