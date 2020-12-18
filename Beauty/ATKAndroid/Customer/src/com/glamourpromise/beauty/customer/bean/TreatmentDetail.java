package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TreatmentDetail {

	private int status;
	private String ID;
	private String startTime;
	private String finishTime;
	private String remark;

	public TreatmentDetail() {

	}

	public static ArrayList<TreatmentDetail> parseListByJson(String src) {
		ArrayList<TreatmentDetail> list = new ArrayList<TreatmentDetail>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TreatmentDetail item;
			for (int i = 0; i < count; i++) {
				item = new TreatmentDetail();
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
			if (jsSrc.has("ID"))
				setID(jsSrc.getString("ID"));
			if (jsSrc.has("Status"))
				setStatus(jsSrc.getInt("Status"));
			if (jsSrc.has("StartTime"))
				setStartTime(jsSrc.getString("StartTime"));
			if (jsSrc.has("FinishTime"))
				setFinishTime(jsSrc.getString("FinishTime"));
			if (jsSrc.has("Remark"))
				setRemark(jsSrc.getString("Remark"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setID(String ID) {
		this.ID = ID;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public void setFinishTime(String finishTime) {
		this.finishTime = finishTime;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getID() {
		return ID;
	}

	public int getStatus() {
		return status;
	}

	public String getStartTime() {
		return startTime;
	}

	public String getFinishTime() {
		return finishTime;
	}

	public String getRemark() {
		return remark;
	}
}
