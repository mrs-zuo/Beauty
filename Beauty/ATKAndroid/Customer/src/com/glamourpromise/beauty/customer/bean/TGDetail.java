package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TGDetail {

	private String groupNo;
	private String remark;
	private String tgEndTime;
	private String tgStartTime;
	private int    tgStatus;

	public TGDetail() {

	}

	public static ArrayList<TGDetail> parseListByJson(String src) {
		ArrayList<TGDetail> list = new ArrayList<TGDetail>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TGDetail item;
			for (int i = 0; i < count; i++) {
				item = new TGDetail();
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
			if (jsSrc.has("GroupNo"))
				setGroupNo(jsSrc.getString("GroupNo"));
			if (jsSrc.has("Remark"))
				setRemark(jsSrc.getString("Remark"));
			if (jsSrc.has("TGEndTime"))
				setTGEndTime(jsSrc.getString("TGEndTime"));
			if (jsSrc.has("TGStartTime"))
				setTGStartTime(jsSrc.getString("TGStartTime"));
			if (jsSrc.has("TGStatus"))
				setTGStatus(jsSrc.getInt("TGStatus"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setGroupNo(String groupNo) {
		this.groupNo = groupNo;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public void setTGEndTime(String tgEndTime) {
		this.tgEndTime = tgEndTime;
	}

	public void setTGStartTime(String tgStartTime) {
		this.tgStartTime = tgStartTime;
	}

	public void setTGStatus(int tgStatus) {
		this.tgStatus = tgStatus;
	}

	public String getGroupNo() {
		return groupNo;
	}

	public String getRemark() {
		return remark;
	}

	public String getTGEndTime() {
		return tgEndTime;
	}

	public String getTGStartTime() {
		return tgStartTime;
	}

	public int getTGStatus() {
		return tgStatus;
	}

}
