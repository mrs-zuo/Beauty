package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PaymentDetailInfo {
	private String mPaymentCode = "";
	private String createTime;
	private String operator;
	private String totalPrice;
	private String cashAmount;
	private String ecardAmount;
	private String bankCardAmount;
	private String remark = " ";
	private String others;

	private ArrayList<OrderBaseInfo> orderList = new ArrayList<OrderBaseInfo>();
	private int cardType;
	private String cardName;
	private String cardPaidAmount;
	private String paymentAmount;
	private int paymentMode;
	private int paymentDetailID;

	public String getPaymentCode() {
		return mPaymentCode;
	}

	public void setPaymentCode(String paymentCode) {
		mPaymentCode = paymentCode;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public String getTotalPrice() {
		return totalPrice;
	}

	public void setTotalPrice(String totalPrice) {
		this.totalPrice = totalPrice;
	}

	public String getCashAmount() {
		return cashAmount;
	}

	public void setCashAmount(String cashAmount) {
		this.cashAmount = cashAmount;
	}

	public String getEcardAmount() {
		return ecardAmount;
	}

	public void setEcardAmount(String ecardAmount) {
		this.ecardAmount = ecardAmount;
	}

	public String getBankCardAmount() {
		return bankCardAmount;
	}

	public void setBankCardAmount(String bankCardAmount) {
		this.bankCardAmount = bankCardAmount;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getOthers() {
		return others;
	}

	public void setOthers(String others) {
		this.others = others;
	}

	public ArrayList<OrderBaseInfo> getOrderList() {
		return orderList;
	}

	public void setOrderList(ArrayList<OrderBaseInfo> orderList) {
		this.orderList = orderList;
	}

	public static ArrayList<PaymentDetailInfo> parseListByJson(String src) {
		ArrayList<PaymentDetailInfo> list = new ArrayList<PaymentDetailInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("OrderList");
			int count = jarrList.length();
			PaymentDetailInfo item;
			for (int i = 0; i < count; i++) {
				item = new PaymentDetailInfo();
				item.setInfoByJson(jarrList.getJSONObject(i));
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
		return setInfoByJson(jsSrc);
	}

	public boolean setInfoByJson(JSONObject contentJson) {

		try {
			if (contentJson.has("PaymentDetailID"))
				setPaymentDetailID(contentJson.getInt("PaymentDetailID"));
			if (contentJson.has("PaymenMode"))
				setPaymentMode(contentJson.getInt("PaymentMode"));
			if (contentJson.has("PaymentAmount"))
				setPaymentAmount(contentJson.getString("PaymentAmount"));
			if (contentJson.has("CardPaidAmount"))
				setCardPaidAmount(contentJson.getString("CardPaidAmount"));
			if (contentJson.has("CardName"))
				setCardName(contentJson.getString("CardName"));
			if (contentJson.has("CardType"))
				setCardType(contentJson.getInt("CardType"));
			if (contentJson.has("PaymentCode")) {
				setPaymentCode(contentJson.getString("PaymentCode"));
			}
			if (contentJson.has("PaymentTime")) {
				createTime = contentJson.getString("PaymentTime");
			}
			if (contentJson.has("Operator")) {
				operator = contentJson.getString("Operator");
			}
			if (contentJson.has("TotalPrice")) {
				totalPrice = contentJson.getString("TotalPrice");
			}
			if (contentJson.has("Cash")) {
				cashAmount = contentJson.getString("Cash");
			}
			if (contentJson.has("Ecard")) {
				ecardAmount = contentJson.getString("Ecard");
			}
			if (contentJson.has("BankCard")) {
				bankCardAmount = contentJson.getString("BankCard");
			}
			if (contentJson.has("Remark")) {
				remark = contentJson.getString("Remark");
			}
			if (contentJson.has("Others")) {
				others = contentJson.getString("Others");
			}
			if (contentJson.has("OrderList")) {
				JSONArray jAOrderInfo = contentJson.getJSONArray("OrderList");
				JSONObject tmp;
				OrderBaseInfo orderInfo;
				for (int i = 0; i < jAOrderInfo.length(); i++) {
					orderInfo = new OrderBaseInfo();
					tmp = jAOrderInfo.getJSONObject(i);
					orderInfo
							.setOrderSerialNumber(tmp.getString("OrderNumber"));
					orderInfo.setProductName(tmp.getString("ProductName"));
					orderInfo.setTotalPrice(tmp.getString("OrderPrice"));
					orderInfo.setOrderID(tmp.getString("ID"));
					orderInfo.setProductType(tmp.getString("ProductType"));
					orderList.add(orderInfo);
				}
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return true;
	}

	public void setCardType(int cardType) {
		this.cardType = cardType;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public void setCardPaidAmount(String cardPaidAmount) {
		this.cardPaidAmount = cardPaidAmount;
	}

	public void setPaymentAmount(String paymentAmount) {
		this.paymentAmount = paymentAmount;
	}

	public void setPaymentMode(int paymentMode) {
		this.paymentMode = paymentMode;
	}

	public void setPaymentDetailID(int paymentDetailID) {
		this.paymentDetailID = paymentDetailID;
	}

	public int getCardType() {
		return cardType;
	}

	public String getCardName() {
		return cardName;
	}

	public String getCardPaidAmount() {
		return cardPaidAmount;
	}

	public String getPaymentAmount() {
		return paymentAmount;
	}

	public int getPaymentMode() {
		return paymentMode;
	}

	public int getPaymentDetailID() {
		return paymentDetailID;
	}

	public static ArrayList<PaymentDetailInfo> parsePaymentDetailListByJson(
			String src) {
		ArrayList<PaymentDetailInfo> list = new ArrayList<PaymentDetailInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PaymentDetailInfo item;
			for (int i = 0; i < count; i++) {
				item = new PaymentDetailInfo();
				item.setInfoByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
}
