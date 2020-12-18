package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class CardBalanceHistoryInfo {

	private String amount;
	private String absAmount;
	private int paymentID;// 消费的ID
	private int changeType;
	private int actionType;
	private String actionModeName;
	private int actionMode;
	private int balanceID;
	private String createTime;
	private String balance;
	private int cardType;
	private String changeTypeName;

	public CardBalanceHistoryInfo() {
		amount = "";
		balance = "";
		createTime = "";
		actionModeName = "";
		cardType = 1;
	}

	public static ArrayList<CardBalanceHistoryInfo> parseListByJson(String src) {
		ArrayList<CardBalanceHistoryInfo> list = new ArrayList<CardBalanceHistoryInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CardBalanceHistoryInfo item;
			for (int i = 0; i < count; i++) {
				item = new CardBalanceHistoryInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public static ArrayList<CardBalanceHistoryInfo> parseListByJsonWithSettingCardType(
			String src, int cardType) {
		ArrayList<CardBalanceHistoryInfo> list = new ArrayList<CardBalanceHistoryInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CardBalanceHistoryInfo item;
			for (int i = 0; i < count; i++) {
				item = new CardBalanceHistoryInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				item.setCardType(cardType);
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
			if (jsSrc.has("BalanceID"))
				setBalanceID(jsSrc.getInt("BalanceID"));
			if (jsSrc.has("ActionMode"))
				setActionMode(jsSrc.getInt("ActionMode"));
			if (jsSrc.has("CreateTime"))
				setCreateTime(jsSrc.getString("CreateTime"));
			if (jsSrc.has("Amount"))
				setAmount(jsSrc.getString("Amount"));
			if (jsSrc.has("Balance"))
				setBalance(jsSrc.getString("Balance"));
			if (jsSrc.has("ActionModeName"))
				setActionModeName(jsSrc.getString("ActionModeName"));
			if (jsSrc.has("ActionType"))
				setActionType(jsSrc.getInt("ActionType"));
			if (jsSrc.has("ChangeType"))
				setChangeType(jsSrc.getInt("ChangeType"));
			if (jsSrc.has("PaymentID"))
				setPaymentID(jsSrc.getInt("PaymentID"));
			if (jsSrc.has("ChangeTypeName"))
				setChangeTypeName(jsSrc.getString("ChangeTypeName"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setChangeTypeName(String changeTypeName) {
		this.changeTypeName = changeTypeName;
	}

	public String getChangeTypeName() {
		return changeTypeName;
	}

	public void setPaymentID(int paymentID) {
		this.paymentID = paymentID;
	}

	public void setChangeType(int changeType) {
		this.changeType = changeType;
	}

	public void setActionType(int actionType) {
		this.actionType = actionType;
	}

	public void setBalance(String balance) {
		this.balance = balance;
	}

	public void setActionModeName(String actionModeName) {
		this.actionModeName = actionModeName;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setActionMode(int actionMode) {
		this.actionMode = actionMode;
	}

	public void setBalanceID(int balanceID) {
		this.balanceID = balanceID;
	}

	public int getPaymentID() {
		return paymentID;
	}

	public int getChangeType() {
		return changeType;
	}

	public int getActionType() {
		return actionType;
	}

	public String getActionModeName() {
		return actionModeName;
	}

	public String getBalance() {
		return balance;
	}

	public String getAmount() {
		return amount;
	}

	public String getCreateTime() {
		return createTime;
	}

	public int getActionMode() {
		return actionMode;
	}

	public int getBalanceID() {
		return balanceID;
	}

	public String getAbsAmount() {
		return absAmount;
	}

	public void setCardType(int cardType) {
		this.cardType = cardType;
	}

	public int getCardType() {
		return cardType;
	}

	public boolean isAmountPositive() {
		float absAmountFloat = Math.abs(Float.parseFloat(this.amount));
		absAmount = String.valueOf(absAmountFloat);
		return absAmountFloat == Float.parseFloat(amount);
	}
}
