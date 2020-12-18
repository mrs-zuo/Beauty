package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CardDiscountInfo implements Serializable{
	private static final long serialVersionUID = 1L;
	private int    cardID;
	private String userCardNo;
	private String cardName;
	private String discount;

	public CardDiscountInfo() {
		cardName = "";
		discount = "1.0";
	}

	public static ArrayList<CardDiscountInfo> parseListByJson(String src) {
		ArrayList<CardDiscountInfo> list = new ArrayList<CardDiscountInfo>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CardDiscountInfo item;
			for (int i = 0; i < count; i++) {
				item = new CardDiscountInfo();
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

	public boolean parseByJson(JSONObject jsSrc) {
		try {

			if (jsSrc.has("CardID")) {
				setCardID(jsSrc.getInt("CardID"));
			}
			if (jsSrc.has("UserCardNo")) {
				setUserCardNo(jsSrc.getString("UserCardNo"));
			}
			if (jsSrc.has("CardName")) {
				setCardName(jsSrc.getString("CardName"));
			}
			if (jsSrc.has("Discount")) {
				setDiscount(jsSrc.getString("Discount"));
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

	public void setCardID(int cardID) {
		this.cardID = cardID;

	}

	public int getCardID() {
		return cardID;
	}

	public void setDiscount(String discount) {
		this.discount = discount;
	}

	public String getDiscount() {
		return discount;
	}
}
