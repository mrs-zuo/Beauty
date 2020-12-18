package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

//一个手机号可能是不同公司的客户，因此可能有多个user信息
public class UserInformation implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String userID;
	private String companyName;
	private String companyID;
	
	public UserInformation(){
		
	}
	
	public static ArrayList<UserInformation> parseListByJson(String src){
		ArrayList<UserInformation> list = new ArrayList<UserInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			UserInformation item;
			for(int i = 0; i < count; i++){
				item = new UserInformation();
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
			if(jsSrc.has("UserID")){
				setUserID(jsSrc.getString("UserID"));
			}
			if (jsSrc.has("Name")) {
				setCompanyName(jsSrc.getString("Name"));
			}
			if (jsSrc.has("CompanyID")) {
				setCompanyID(jsSrc.getString("CompanyID"));
			}
			
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public void setUserID(String userID){
		this.userID = userID;
	}
	public String getUserID(){
		return userID;
	}
	
	public void setCompanyName(String companyName){
		this.companyName = companyName;
	}
	
	public String getCompanyName(){
		return companyName;
	}
	
	public void setCompanyID(String companyID){
		this.companyID = companyID;
	}
	
	public String getCompanyID(){
		return companyID;
	}
}
