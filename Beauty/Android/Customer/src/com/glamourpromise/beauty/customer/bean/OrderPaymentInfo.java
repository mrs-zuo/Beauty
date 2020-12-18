package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class OrderPaymentInfo {
	private String createTime = "";
	private String operator = "";
	private String totalAmount = "";
	private String cashAmount = "";
	private String ecardAmount = "";
	private String bankCardAmount = "";
	private String otherAmount = "";
	private String remark = "";
	private String paymentID;
	private int orderNumber;
	private String paymentCode = "";
	private int status;
	private PaymentDetailInfo paymentDetail = new PaymentDetailInfo();
	private List<PaymentDetailInfo> paymentList = new ArrayList<PaymentDetailInfo>();
	// public String getCreateTime() {
	// return createTime;
	// }
	//
	// public String getPaymentCode() {
	// return paymentCode;
	// }
	//
	// public void setPaymentCode(String paymentCode) {
	// this.paymentCode = paymentCode;
	// }
	//
	// public void setCreateTime(String createTime) {
	// String[] createTimeArr = createTime.split("T");
	// StringBuffer tmp = new StringBuffer();
	// tmp.append(createTimeArr[0]);
	// tmp.append(" ");
	// tmp.append(createTimeArr[1]);
	// this.createTime = tmp.toString();
	// }
	// public String getOperator() {
	// return operator;
	// }
	// public void setOperator(String operator) {
	// this.operator = operator;
	// }
	// public String getTotalAmount() {
	// return totalAmount;
	// }
	// public void setTotalAmount(String totalAmount) {
	// this.totalAmount = totalAmount;
	// }
	// public String getCashAmount() {
	// return cashAmount;
	// }
	// public void setCashAmount(String cashAmount) {
	// this.cashAmount = cashAmount;
	// }
	// public String getEcardAmount() {
	// return ecardAmount;
	// }
	// public void setEcardAmount(String ecardAmount) {
	// this.ecardAmount = ecardAmount;
	// }
	// public String getBankCardAmount() {
	// return bankCardAmount;
	// }
	// public void setBankCardAmount(String bankCardAmount) {
	// this.bankCardAmount = bankCardAmount;
	// }
	// public String getRemark() {
	// return remark;
	// }
	// public void setRemark(String remark) {
	// this.remark = remark;
	// }
	// public String getPaymentID() {
	// return paymentID;
	// }
	// public void setPaymentID(String paymentID) {
	// this.paymentID = paymentID;
	// }
	//
	// public int getOrderNumber() {
	// return orderNumber;
	// }
	// public void setOrderNumber(int orderNumber) {
	// this.orderNumber = orderNumber;
	// }
	//
	// public String getOtherAmount() {
	// return otherAmount;
	// }
	// public void setOtherAmount(String otherAmount) {
	// this.otherAmount = otherAmount;
	// }
	private String totalPrice;
	private String paymentTime;
	private String salesIDs;
	private String salesName;
	private String branchName;

	public static ArrayList<OrderPaymentInfo> parseListByJson(String src) {
		ArrayList<OrderPaymentInfo> list = new ArrayList<OrderPaymentInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			OrderPaymentInfo item;
			for (int i = 0; i < count; i++) {
				item = new OrderPaymentInfo();
				item.setInfoByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public void setInfoByJson(JSONObject contentJson) {

		try {
			if (contentJson.has("Status"))
				setStatus(contentJson.getInt("Status"));
			if (contentJson.has("CreateTime"))
				setCreateTime(contentJson.getString("CreateTime"));
			if (contentJson.has("Operator"))
				setOperator(contentJson.getString("Operator"));
			if (contentJson.has("TotalPrice"))
				setTotalPrice(contentJson.getString("TotalPrice"));
			if (contentJson.has("PaymentID"))
				setPaymentID(contentJson.getString("PaymentID"));
			if (contentJson.has("OrderNumber"))
				setOrderNumer(contentJson.getInt("OrderNumber"));
			if (contentJson.has("PaymentTime"))
				setPaymentTime(contentJson.getString("PaymentTime"));
			if (contentJson.has("PaymentCode"))
				setPaymentCode(contentJson.getString("PaymentCode"));
			if (contentJson.has("SaleIDs"))
				setSaleIDs(contentJson.getString("SaleIDs"));
			if (contentJson.has("SalesName"))
				setSalesName(contentJson.getString("SalesName"));
			if (contentJson.has("Remark"))
				setRemark(contentJson.getString("Remark"));
			if (contentJson.has("BranchName"))
				setBranchName(contentJson.getString("BranchName"));
			if (contentJson.has("PaymentDetailList"))
				setPaymentDetailList(contentJson.getString("PaymentDetailList"));

			// orig
			// if(contentJson.has("PaymentCode")){
			// setPaymentCode(contentJson.getString("PaymentCode"));
			// }
			// if (contentJson.has("PaymentTime")) {
			// createTime = contentJson.getString("PaymentTime");
			// }
			// if (contentJson.has("Operator")) {
			// operator = contentJson.getString("Operator");
			// }
			// if (contentJson.has("TotalPrice")) {
			// totalAmount =
			// NumberFormatUtil.StringFormatToStringWithoutSingle(contentJson.getString("TotalPrice"));
			// }
			// if (contentJson.has("Cash")) {
			// cashAmount =
			// NumberFormatUtil.StringFormatToStringWithoutSingle(contentJson.getString("Cash"));
			// }
			// if (contentJson.has("Ecard")) {
			// ecardAmount =
			// NumberFormatUtil.StringFormatToStringWithoutSingle(contentJson.getString("Ecard"));
			// }
			// if (contentJson.has("BankCard")) {
			// bankCardAmount =
			// NumberFormatUtil.StringFormatToStringWithoutSingle(contentJson.getString("BankCard"));
			// }
			// if (contentJson.has("Others")) {
			// otherAmount =
			// NumberFormatUtil.StringFormatToStringWithoutSingle(contentJson.getString("Others"));
			// }
			// if (contentJson.has("Remark")) {
			// remark = contentJson.getString("Remark");
			// }
			// if (contentJson.has("PaymentID")) {
			// paymentID = contentJson.getString("PaymentID");
			// }
			// if (contentJson.has("OrderNumber")) {
			// orderNumber = contentJson.getInt("OrderNumber");
			// }
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	public void setStatus(int status) {
		this.status = status;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public void setTotalPrice(String totalPrice) {
		this.totalPrice = totalPrice;
	}

	public void setPaymentID(String paymentID) {
		this.paymentID = paymentID;
	}

	public void setOrderNumer(int orderNumber) {
		this.orderNumber = orderNumber;
	}

	public void setPaymentTime(String paymentTime) {
		this.paymentTime = paymentTime;
	}

	public void setPaymentCode(String paymentCode) {
		this.paymentCode = paymentCode;
	}

	public void setSaleIDs(String salesIDs) {
		this.salesIDs = salesIDs;
	}

	public void setSalesName(String salesName) {
		this.salesName = salesName;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	public void setPaymentDetailList(String src) {
		paymentList = PaymentDetailInfo.parsePaymentDetailListByJson(src);
	}

	public int getStatus() {
		return status;
	}

	public String getCreateTime() {
		return createTime;
	}

	public String getOperator() {
		return operator;
	}

	public String getTotalPrice() {
		return totalPrice;
	}

	public String getPaymentID() {
		return paymentID;
	}

	public int getOrderNumer() {
		return orderNumber;
	}

	public String getPaymentTime() {
		return paymentTime;
	}

	public String getPaymentCode() {
		return paymentCode;
	}

	public String getSaleIDs() {
		return salesIDs;
	}

	public String getSalesName() {
		return salesName;
	}

	public String getRemark() {
		return remark;
	}

	public String getBranchName() {
		return branchName;
	}

	public List<PaymentDetailInfo> getPaymentDetailList() {
		return paymentList;
	}

}
