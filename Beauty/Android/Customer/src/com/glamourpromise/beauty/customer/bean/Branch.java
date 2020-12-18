package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Branch{
	private String mID;
	private String mName;
	private String mAddress;
	private String distance;
	public String getID() {
		return mID;
	}
	public void setID(String iD) {
		mID = iD;
	}
	public String getName() {
		return mName;
	}
	public void setName(String name) {
		mName = name;
	}
	public String getAddress() {
		return mAddress;
	}
	public void setAddress(String address) {
		mAddress = address;
	}
	public String getDistance() {
		return distance;
	}
	public void setDistance(String distance) {
		this.distance = distance;
	}
	public boolean parseByJson(String src){
		try {
			JSONObject json = new JSONObject(src);
			setAddress(json.getString("Address"));
			setID(json.getString("ID"));
			setName(json.getString("Name"));
			setDistance(json.getString("Distance"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public boolean parseByJson(JSONObject src){
		try {
			JSONObject json = src;
			setAddress(json.getString("Address"));
			setID(json.getString("BranchID"));
			setName(json.getString("BranchName"));
			setDistance(json.getString("Distance"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public static ArrayList<Branch> parseListByJson(String src){
		ArrayList<Branch> branchList = new ArrayList<Branch>();
		try {
			JSONArray jarrBranch = new JSONArray(src);
			int count = jarrBranch.length();
			Branch item;
			for(int i = 0; i < count; i++){
				item = new Branch();
				item.parseByJson(jarrBranch.getJSONObject(i));
				branchList.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return branchList;
	}
}
