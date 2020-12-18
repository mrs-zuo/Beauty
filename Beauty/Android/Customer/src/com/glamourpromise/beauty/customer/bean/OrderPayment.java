package com.glamourpromise.beauty.customer.bean;

import org.json.JSONException;
import org.json.JSONObject;

public class OrderPayment {
	private String totalOrigPrice;//支付合计
	private String totalCalcPrice;//支付B价格
	private String totalSalePrice;//支付C价格
	private String unPaidPrice;//未支付价格
	private int    cardID;//支付卡ID
	private String expirationDate;//支付卡过期日期
	private String cardName;//支付卡名称
	private String userCardNo;//支付卡NO
	private String balance;//支付卡余额
	private String givePointAmount;//赠送积分
	private String giveCouponAmount;//赠送现金券
	public static OrderPayment parseByJson(String jsonString){
		OrderPayment op=new OrderPayment();
		try {
			JSONObject jsSrc = new JSONObject(jsonString);
			if (jsSrc.has("TotalOrigPrice")) {
				op.setTotalOrigPrice(jsSrc.getString("TotalOrigPrice"));
			}
			if (jsSrc.has("TotalCalcPrice")) {
				op.setTotalCalcPrice(jsSrc.getString("TotalCalcPrice"));
			}
			if (jsSrc.has("TotalSalePrice")) {
				op.setTotalSalePrice(jsSrc.getString("TotalSalePrice"));
			}
			if (jsSrc.has("UnPaidPrice")) {
				op.setUnPaidPrice(jsSrc.getString("UnPaidPrice"));
			}
			if (jsSrc.has("ExpirationDate")) {
				op.setExpirationDate(jsSrc.getString("ExpirationDate"));
			}
			if (jsSrc.has("CardID")) {
				op.setCardID(jsSrc.getInt("CardID"));
			}
			if (jsSrc.has("CardName")) {
				op.setCardName(jsSrc.getString("CardName"));
			}
			if (jsSrc.has("UserCardNo")) {
				op.setUserCardNo(jsSrc.getString("UserCardNo"));
			}
			if (jsSrc.has("Balance")) {
				op.setBalance(jsSrc.getString("Balance"));
			}
			if (jsSrc.has("GivePointAmount")) {
				op.setGivePointAmount(jsSrc.getString("GivePointAmount"));
			}
			if (jsSrc.has("GiveCouponAmount")) {
				op.setGiveCouponAmount(jsSrc.getString("GiveCouponAmount"));
			}
		} catch (JSONException e) {
			
		}
		return op;
	}
	public String getTotalOrigPrice() {
		return totalOrigPrice;
	}
	public void setTotalOrigPrice(String totalOrigPrice) {
		this.totalOrigPrice = totalOrigPrice;
	}
	public String getTotalCalcPrice() {
		return totalCalcPrice;
	}
	public void setTotalCalcPrice(String totalCalcPrice) {
		this.totalCalcPrice = totalCalcPrice;
	}
	public String getTotalSalePrice() {
		return totalSalePrice;
	}
	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}
	public String getUnPaidPrice() {
		return unPaidPrice;
	}
	public void setUnPaidPrice(String unPaidPrice) {
		this.unPaidPrice = unPaidPrice;
	}
	public int getCardID() {
		return cardID;
	}
	public void setCardID(int cardID) {
		this.cardID = cardID;
	}
	public String getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}
	public String getCardName() {
		return cardName;
	}
	public void setCardName(String cardName) {
		this.cardName = cardName;
	}
	public String getUserCardNo() {
		return userCardNo;
	}
	public void setUserCardNo(String userCardNo) {
		this.userCardNo = userCardNo;
	}
	public String getBalance() {
		return balance;
	}
	public void setBalance(String balance) {
		this.balance = balance;
	}
	public String getGivePointAmount() {
		return givePointAmount;
	}
	public void setGivePointAmount(String givePointAmount) {
		this.givePointAmount = givePointAmount;
	}
	public String getGiveCouponAmount() {
		return giveCouponAmount;
	}
	public void setGiveCouponAmount(String giveCouponAmount) {
		this.giveCouponAmount = giveCouponAmount;
	}
}
