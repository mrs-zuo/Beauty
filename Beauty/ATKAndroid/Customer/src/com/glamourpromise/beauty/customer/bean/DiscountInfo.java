package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

/*
 * 折扣信息
 */
public class DiscountInfo implements Serializable{
	private static final long serialVersionUID = 1L;
	private int ID;
	private String name;
	private String discount;
	
	public static ArrayList<DiscountInfo> parseListByJson(String src){
		ArrayList<DiscountInfo> list = new ArrayList<DiscountInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			DiscountInfo item;
			for(int i = 0; i < count; i++){
				item = new DiscountInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	
	public boolean parseByJson(String src){
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
			if(jsSrc.has("DiscountName")){
				setName(jsSrc.getString("DiscountName"));
			}
			if(jsSrc.has("Discount")){
				setDiscount(NumberFormatUtil.StringFormatToStringWithoutSingle(jsSrc.getString("Discount")));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public int getID() {
		return ID;
	}
	public void setID(int iD) {
		ID = iD;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDiscount() {
		return discount;
	}
	public void setDiscount(String discount) {
		this.discount = NumberFormatUtil.StringFormatToStringWithoutSingle(discount);
	}
}
