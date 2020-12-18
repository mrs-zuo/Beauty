package com.glamourpromise.beauty.customer.bean;

import org.json.JSONException;
import org.json.JSONObject;

public class LeftMenuBean {
	private String mNewMessageCount;
	private String mCartCount;
	private String mPromotionCount;
	private String mRemindCount;
	private String mUnpaidOrderCount;
	private String mUnconfirmedOrderCount;
	
	public LeftMenuBean(){
		init();
	}
	
	public void parseByJson(String data){
		try {
			JSONObject jsSrc = new JSONObject(data);
			if(jsSrc.has("NewMessageCount")){
				setNewMessageCount(jsSrc.getString("NewMessageCount"));
			}
			if (jsSrc.has("CartCount")) {
				setCartCount(jsSrc.getString("CartCount"));
			}
			if (jsSrc.has("PromotionCount")) {
				setPromotionCount(jsSrc.getString("PromotionCount"));
			}
			if (jsSrc.has("RemindCount")) {
				setRemindCount(jsSrc.getString("RemindCount"));
			}
			if (jsSrc.has("UnpaidOrderCount")) {
				setUnpaidOrderCount(jsSrc.getString("UnpaidOrderCount"));
			}
			if (jsSrc.has("UnconfirmedOrderCount")) {
				setUnconfirmedOrderCount(jsSrc.getString("UnconfirmedOrderCount"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void init(){
		mNewMessageCount = "0";
		mCartCount = "0";
		mPromotionCount = "0";
		mRemindCount = "0";
		mUnpaidOrderCount = "0";
		mUnconfirmedOrderCount = "0";
	}
	
	public String getNewMessageCount() {
		return mNewMessageCount;
	}
	public void setNewMessageCount(String newMessageCount) {
		if(!newMessageCount.equals("null"))
			mNewMessageCount = newMessageCount;
	}
	public String getCartCount() {
		return mCartCount;
	}
	public void setCartCount(String cartCount) {
		if(!cartCount.equals("null"))
			mCartCount = cartCount;
	}
	public String getPromotionCount() {
		return mPromotionCount;
	}
	public void setPromotionCount(String promotionCount) {
		if(!promotionCount.equals("null"))
			mPromotionCount = promotionCount;
	}
	public String getRemindCount() {
		return mRemindCount;
	}
	public void setRemindCount(String remindCount) {
		if(!remindCount.equals("null"))
			mRemindCount = remindCount;
	}
	public String getUnpaidOrderCount() {
		return mUnpaidOrderCount;
	}
	public void setUnpaidOrderCount(String unpaidOrderCount) {
		if(!unpaidOrderCount.equals("null"))
			mUnpaidOrderCount = unpaidOrderCount;
	}
	public String getUnconfirmedOrderCount() {
		return mUnconfirmedOrderCount;
	}
	public void setUnconfirmedOrderCount(String unconfirmedOrderCount) {
		if(!unconfirmedOrderCount.equals("null"))
			mUnconfirmedOrderCount = unconfirmedOrderCount;
	}
	
	

}
