package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class TGListInfo {

	private String servicePICName = "";
	private int status = 0;
	private String startTime = "";
	private boolean designated;
	private String servicePicID;
	private String groupNo;
	private int quantity;
	private List<TreatmentList> treatmentList = new ArrayList<TreatmentList>();

	public TGListInfo() {

	}

	public static ArrayList<TGListInfo> parseListByJson(String src) {
		ArrayList<TGListInfo> list = new ArrayList<TGListInfo>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			TGListInfo item;
			for (int i = 0; i < count; i++) {
				item = new TGListInfo();
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
			if (jsSrc.has("ServicePicID"))
				setServicePicID(jsSrc.getString("ServicePicID"));
			if (jsSrc.has("ServicePicName"))
				setServicePICName(jsSrc.getString("ServicePicName"));
			if (jsSrc.has("IsDesignated"))
				setDesignated(jsSrc.getBoolean("IsDesignated"));
			if (jsSrc.has("Status"))
				setStatus(jsSrc.getInt("Status"));
			if (jsSrc.has("Quantity"))
				setQuantitiy(jsSrc.getInt("Quantity"));
			if (jsSrc.has("StartTime"))
				setStartTime(jsSrc.getString("StartTime"));
			if (jsSrc.has("TreatmentList"))
				setTreatmentList(jsSrc.getString("TreatmentList"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setTreatmentList(String src) {
		TreatmentList treatmentInfo = new TreatmentList();
		this.treatmentList = treatmentInfo.parseListByJson(src);
	}

	public List<TreatmentList> getTreatmentList() {
		return treatmentList;
	}

	public void setQuantitiy(int quantity) {
		this.quantity = quantity;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setDesignated(boolean designated) {
		this.designated = designated;
	}

	public void setServicePicID(String servicePicID) {
		this.servicePicID = servicePicID;
	}

	public void setGroupNo(String groupNo) {
		this.groupNo = groupNo;
	}

	public boolean getDesignated() {
		return designated;
	}

	public String getServicePicID() {
		return servicePicID;
	}

	public String getGroupNo() {
		return groupNo;
	}

	public String getServicePICName() {
		return servicePICName;
	}

	public void setServicePICName(String servicePICName) {
		this.servicePICName = servicePICName;
	}

	public int getStatus() {
		return status;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public String getStartTime() {
		return startTime;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

}
