package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class BalanceCardInfo {

	private String cardPaidAmount;
	private String absCardPaidAmount;
	private String userCardNo;
	private String balance;
	private String amount;
	private String cardName;
	private int    cardType;
	private String actionModeName;
	private String absAmount;
	private int actionMode;

	public BalanceCardInfo() {

	}

	public static ArrayList<BalanceCardInfo> parseListByJson(String src) {
		ArrayList<BalanceCardInfo> list = new ArrayList<BalanceCardInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("OrderList");
			int count = jarrList.length();
			BalanceCardInfo item;
			for (int i = 0; i < count; i++) {
				item = new BalanceCardInfo();
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
			if (jsSrc.has("ActionMode"))
				setActionMode(jsSrc.getInt("ActionMode"));
			if (jsSrc.has("ActionModeName"))
				setActionModeName(jsSrc.getString("ActionModeName"));
			if (jsSrc.has("CardType"))
				setCardType(jsSrc.getInt("CardType"));
			if (jsSrc.has("CardName"))
				setCardName(jsSrc.getString("CardName"));
			if (jsSrc.has("Amount"))
				setAmount(jsSrc.getString("Amount"));
			if (jsSrc.has("Balance"))
				setBalance(jsSrc.getString("Balance"));
			if (jsSrc.has("UserCardNo"))
				setUserCardNo(jsSrc.getString("UserCardNo"));
			if (jsSrc.has("CardPaidAmount"))
				setCardPaidAmount(jsSrc.getString("CardPaidAmount"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setActionMode(int actionMode) {
		this.actionMode = actionMode;
	}

	public void setActionModeName(String actionModeName) {
		this.actionModeName = actionModeName;
	}

	public void setCardType(int cardType) {
		this.cardType = cardType;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}

	public void setBalance(String balance) {
		this.balance = balance;
	}

	public void setUserCardNo(String userCardNo) {
		this.userCardNo = userCardNo;
	}

	public void setCardPaidAmount(String cardPaidAmount) {
		this.cardPaidAmount = cardPaidAmount;
	}

	public int getActionMode() {
		return actionMode;
	}

	public String getActionModeName() {
		return actionModeName;
	}

	public int getCardType() {
		return cardType;
	}

	public String getCardName() {
		return cardName;
	}

	public String getAmount() {
		return amount;
	}

	public String getAbsAmount() {
		float absAmount = Math.abs(Float.parseFloat(amount));
		this.absAmount = String.valueOf(absAmount);
		return this.absAmount;
	}

	public String getBalance() {
		return balance;
	}

	public String getUserCardNo() {
		return userCardNo;
	}

	public String getCardPaidAmount() {
		return cardPaidAmount;
	}

	public String getAbsCardPaidAmount() {
		absCardPaidAmount = String.valueOf(Math.abs(Float
				.parseFloat(this.cardPaidAmount)));
		return absCardPaidAmount;
	}

	public boolean isPositive() {
		float absAmount = Math.abs(Float.parseFloat(amount));
		return absAmount == Float.parseFloat(amount);
	}
}
