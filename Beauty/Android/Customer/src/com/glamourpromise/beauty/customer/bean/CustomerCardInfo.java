package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CustomerCardInfo implements Serializable{
	private static final long serialVersionUID = 1L;
	private String userCardNo;
	private String cardName;
	private String balance;
	private boolean isDefault;
	private int cardTypeID;
	private String presentRate;
	private String rate;
	private String discount;

	public CustomerCardInfo() {
		rate = "1.0";
		balance = "0.0";
		discount = "1.0";
	}

	public static ArrayList<CustomerCardInfo> parseListByJson(String src) {
		ArrayList<CustomerCardInfo> list = new ArrayList<CustomerCardInfo>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CustomerCardInfo item;
			for (int i = 0; i < count; i++) {
				item = new CustomerCardInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//默认添加福利包到卡集合当中
		CustomerCardInfo customerBenefitsCard=new CustomerCardInfo();
		customerBenefitsCard.setUserCardNo("");
		customerBenefitsCard.setCardName("福利包");
		customerBenefitsCard.setCardTypeID(4);
		list.add(customerBenefitsCard);
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

	public boolean parseByJson(JSONObject jsSrc) {
		try {
			if (jsSrc.has("UserCardNo")) {
				setUserCardNo(jsSrc.getString("UserCardNo"));
			}
			if (jsSrc.has("CardName")) {
				setCardName(jsSrc.getString("CardName"));
			}
			if (jsSrc.has("Balance")) {
				setBalance(jsSrc.getString("Balance"));
			}
			if (jsSrc.has("IsDefault")) {
				setIsDefault(jsSrc.getBoolean("IsDefault"));
			}
			if (jsSrc.has("CardTypeID")) {
				setCardTypeID(jsSrc.getInt("CardTypeID"));
			}
			if (jsSrc.has("Rate")) {
				setRate(jsSrc.getString("Rate"));
			}
			if (jsSrc.has("PresentRate")) {
				setPresentRate(jsSrc.getString("PresentRate"));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setUserCardNo(String userCardNo) {
		this.userCardNo = userCardNo;
	}

	public String getUserCardNo() {
		return userCardNo;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public String getCardName() {
		return cardName;
	}

	public void setBalance(String balance) {
		this.balance = balance;
	}

	public String getBalance() {
		return balance;
	}

	public void setIsDefault(boolean isDefault) {
		this.isDefault = isDefault;
	}

	public boolean getIsDefault() {
		return isDefault;
	}

	public void setCardTypeID(int cardTypeID) {
		this.cardTypeID = cardTypeID;
	}

	public int getCardTypeID() {
		return cardTypeID;
	}

	public void setRate(String rate) {
		this.rate = rate;
	}

	public String getRate() {
		return rate;
	}

	public void setPresentRate(String presentRate) {
		this.presentRate = presentRate;
	}

	public String getPresentRate() {
		return presentRate;
	}
	
	public void setDiscount(String discount){
		this.discount = discount;
	}
	
	public String getDiscount(){
		return discount;
	}

}
