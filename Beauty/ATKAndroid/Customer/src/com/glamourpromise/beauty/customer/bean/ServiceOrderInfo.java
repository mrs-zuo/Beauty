package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class ServiceOrderInfo implements Serializable{
	OrderBaseInfo mBaseInfo;
	ArrayList<TGDetail> tgList;
	
	public ServiceOrderInfo(){
		
	}
	
	public static ArrayList<ServiceOrderInfo> parseListByJson(String src){
		ArrayList<ServiceOrderInfo> list = new ArrayList<ServiceOrderInfo>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			ServiceOrderInfo item;
			for(int i = 0; i < count; i++){
				item = new ServiceOrderInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
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
			OrderBaseInfo orderBaseInfo = new OrderBaseInfo();
			orderBaseInfo.parseByJson(jsSrc);
			setBaseInfo(orderBaseInfo);
			ArrayList<TGDetail> tgList = new ArrayList<TGDetail>();
			if (jsSrc.has("GroupList")) {
				tgList = TGDetail.parseListByJson(jsSrc.getString("GroupList"));
			}
			setTgList(tgList);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public OrderBaseInfo getBaseInfo() {
		return mBaseInfo;
	}

	public void setBaseInfo(OrderBaseInfo baseInfo) {
		mBaseInfo = baseInfo;
	}

	public ArrayList<TGDetail> getTgList() {
		return tgList;
	}

	public void setTgList(ArrayList<TGDetail> tgList) {
		this.tgList = tgList;
	}
	
	
}
