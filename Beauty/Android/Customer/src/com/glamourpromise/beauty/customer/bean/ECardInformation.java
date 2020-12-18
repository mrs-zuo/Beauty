package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ECardInformation implements Serializable {
	private static final long serialVersionUID = 1L;
	private String balance;
	private String levelName;
	private String mLevelID;
	private String discount;
	private boolean IsShowECardHis;
	private String mExpirationDate = "2099-12-31";
	private int    cardID;
	private String cardName;
	private String cardTypeName;
	private String userCardNo;
	private List<DiscountInfo> discountInfo = new ArrayList<DiscountInfo>();
	private String realCardNo;
	private String cardDescription;
	private int cardType;
	
	public ECardInformation() {
		cardType = 1;
		discount = "1.0";
		balance = "0.0";
		IsShowECardHis = true;
		cardTypeName = "";
		realCardNo = "";
		cardDescription = "";
	}

	public static ArrayList<ECardInformation> parseListByJson(String src) {
		ArrayList<ECardInformation> list = new ArrayList<ECardInformation>();
		try {

			JSONObject jarrList = new JSONObject(src);
			int count = jarrList.length();
			ECardInformation item;
			for (int i = 0; i < count; i++) {
				item = new ECardInformation();
				item.parseByJson(jarrList);
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
	public static ArrayList<ECardInformation> parseCardDiscountByJson(String src) {
		ArrayList<ECardInformation> list = new ArrayList<ECardInformation>();
		try {
			JSONArray ecardJsonArray=new JSONArray(src);
			for(int i=0;i<ecardJsonArray.length();i++){
				JSONObject ecardJson=ecardJsonArray.getJSONObject(i);
				ECardInformation ecardInfo=new ECardInformation();
				if(ecardJson.has("CardID"))
					ecardInfo.setCardID(ecardJson.getInt("CardID"));
				if(ecardJson.has("UserCardNo"))
					ecardInfo.setUserCardNo(ecardJson.getString("UserCardNo"));
				if(ecardJson.has("CardName"))
					ecardInfo.setCardName(ecardJson.getString("CardName"));
				if(ecardJson.has("Discount"))
					ecardInfo.setDisCount(ecardJson.getString("Discount"));
				list.add(ecardInfo);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	public boolean parseByJson(JSONObject data) {
		try {
			JSONObject jsSrc = data;
			if (jsSrc.has("Balance")) {
				setBalance(jsSrc.getString("Balance"));
			}
			if (jsSrc.has("Discount")) {
				setDisCount(jsSrc.getString("Discount"));
			}
			if (jsSrc.has("LevelName")) {
				setLevelName(jsSrc.getString("LevelName"));
			}
			if (jsSrc.has("LevelID")) {
				setLevelID(jsSrc.getString("LevelID"));
			}
			if (jsSrc.has("IsShowECardHis")) {
				setIsShowECardHis(jsSrc.getBoolean("IsShowECardHis"));
			}
			if (jsSrc.has("ExpirationDate")) {
				setExpirationDate(jsSrc.getString("ExpirationDate"));
			}
			if (jsSrc.has("CardName")) {
				setCardName(jsSrc.getString("CardName"));
			}
			if (jsSrc.has("CardTypeName")) {
				setCardTypeName(jsSrc.getString("CardTypeName"));
			}
			if (jsSrc.has("CardExpiredDate")) {
				setExpirationDate(jsSrc.getString("CardExpiredDate"));
			}
			if (jsSrc.has("DiscountList")) {
				DiscountInfo discount = new DiscountInfo();
				discountInfo = discount.parseListByJson(jsSrc.getString("DiscountList"));
			}
			if (jsSrc.has("RealCardNo")) {
				setRealCardNo(jsSrc.getString("RealCardNo"));
			}

			if (jsSrc.has("UserCardNo")) {
				setUserCardNo(jsSrc.getString("UserCardNo"));
			}
			if (jsSrc.has("CardDescription")) {
				setCardDescription(jsSrc.getString("CardDescription"));
			}
			if(jsSrc.has("CardType")){
				setCardType(jsSrc.getInt("CardType"));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setBalance(String balance) {
		this.balance = balance;
	}

	public String getBalance() {
		return balance;
	}

	public void setLevelName(String levelName) {
		this.levelName = levelName;
	}

	public String getLevelName() {
		return levelName;
	}

	public String getLevelID() {
		return mLevelID;
	}

	public void setLevelID(String levelID) {
		mLevelID = levelID;
	}

	public void setDisCount(String discount) {
		this.discount = discount;
	}

	public String getDisCount() {
		return discount;
	}

	public boolean getIsShowECardHis() {
		return IsShowECardHis;
	}

	public void setIsShowECardHis(boolean isShowECardHis) {
		IsShowECardHis = isShowECardHis;
	}

	public String getExpirationDate() {
		return mExpirationDate;
	}

	public void setExpirationDate(String expirationDate) {
		if (expirationDate.equals("")) {
			return;
		}
		String[] tmp = expirationDate.split(" ");
		StringBuffer sb = new StringBuffer(tmp[0]);
		this.mExpirationDate = sb.toString();
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	public String getCardName() {
		return cardName;
	}

	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}

	public List<DiscountInfo> getDiscountList() {
		return discountInfo;
	}

	public void setUserCardNo(String userCardNo) {
		this.userCardNo = userCardNo;
	}

	public String getUserCardNo() {
		return userCardNo;
	}

	public void setRealCardNo(String realCardNo) {
		this.realCardNo = realCardNo;
	}

	public String getRealCardNo() {
		return realCardNo;
	}

	public void setCardDescription(String cardDescrip) {
		this.cardDescription = cardDescrip;
	}

	public String getCardDescription() {
		return cardDescription;
	}
	
	public void setCardType(int cardType){
		this.cardType = cardType;
	}
	
	public int getCardType(){
		return cardType;
	}
	public int getCardID() {
		return cardID;
	}

	public void setCardID(int cardID) {
		this.cardID = cardID;
	}

	/**
	 * 判断时间是否有效
	 * 
	 * @return
	 */
	public boolean isExpiration() {
		SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd",
				Locale.getDefault());
		String currentTime = sDateFormat.format(new java.util.Date());
		int result = mExpirationDate.compareTo(currentTime);
		if (result >= 0) {
			return true;
		}
		return false;
	}

}
