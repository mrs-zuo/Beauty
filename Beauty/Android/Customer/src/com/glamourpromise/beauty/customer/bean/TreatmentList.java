package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TreatmentList {

	private int subServiceID;
	private String subServiceName;
	private int executorID;
	private String executorName = "";
	private int treatmentID;
	private String startTime;
	private int status;

	public TreatmentList() {

	}

	public static ArrayList<TreatmentList> parseListByJson(String src) {
		ArrayList<TreatmentList> list = new ArrayList<TreatmentList>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TreatmentList item;
			for (int i = 0; i < count; i++) {
				item = new TreatmentList();
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
			if (jsSrc.has("SubServiceID"))
				setSubServiceID(jsSrc.getInt("SubServiceID"));
			if (jsSrc.has("SubServiceName"))
				setSubServiceName(jsSrc.getString("SubServiceName"));
			if (jsSrc.has("ExecutorID"))
				setExecutorID(jsSrc.getInt("ExecutorID"));
			if (jsSrc.has("ExecutorName"))
				setExecutorName(jsSrc.getString("ExecutorName"));
			if (jsSrc.has("TreatmentID"))
				setTreatmentID(jsSrc.getInt("TreatmentID"));
			if (jsSrc.has("StartTime"))
				setStartTime(jsSrc.getString("StartTime"));
			if (jsSrc.has("Status"))
				setStatus(jsSrc.getInt("Status"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setSubServiceID(int subServiceID) {
		this.subServiceID = subServiceID;
	}

	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}

	public void setExecutorID(int executorID) {
		this.executorID = executorID;
	}

	public void setExecutorName(String executorName) {
		this.executorName = executorName;
	}

	public void setTreatmentID(int treatmentID) {
		this.treatmentID = treatmentID;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public int getSubServiceID() {
		return subServiceID;
	}

	public String getSubServiceName() {
		return subServiceName;
	}

	public int getExecutorID() {
		return executorID;
	}

	public String getExecutorName() {
		return executorName;
	}

	public int getTreatmentID() {
		return treatmentID;
	}

	public String getStartTime() {
		return startTime;
	}

	public int getStatus() {
		return status;
	}
}
