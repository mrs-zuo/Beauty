package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.ksoap2.serialization.PropertyInfo;
import org.ksoap2.serialization.SoapObject;

public class BranchInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String id;
	private String abbreviation;
	private String name;
	private String summary;
	private String contact;
	private String phone;
	private String fax;
	private String address;
	private String zip;
	private String web;
	private String businessHours;
	private String remark;
	private String Longitude;
	private String Latitude;
	private String accountCount;
	private String imageURLs;
	private String iamgeCount;
	
	public BranchInfo(){
		abbreviation = "";
		name = "";
		summary = "";
		contact = "";
		phone = "";
		fax = "";
		address = "";
		zip = "";
		web = "";
		businessHours = "";
		remark = "";
		Longitude = "0.0";
		Latitude  ="0.0";
		accountCount = "0";
	}
	
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getAbbreviation() {
		return abbreviation;
	}
	public void setAbbreviation(String abbreviation) {
		this.abbreviation = abbreviation;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getSummary() {
		return summary;
	}
	public void setSummary(String summary) {
		this.summary = summary;
	}
	public String getContact() {
		return contact;
	}
	public void setContact(String contact) {
		this.contact = contact;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getFax() {
		return fax;
	}
	public void setFax(String fax) {
		this.fax = fax;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public String getZip() {
		return zip;
	}
	public void setZip(String zip) {
		this.zip = zip;
	}
	public String getWeb() {
		return web;
	}
	public void setWeb(String web) {
		this.web = web;
	}
	public String getBusinessHours() {
		return businessHours;
	}
	public void setBusinessHours(String businessHours) {
		this.businessHours = businessHours;
	}
	public String getRemark() {
		return remark;
	}
	public void setRemark(String remark) {
		this.remark = remark;
	}
	public String getLongitude() {
		return Longitude;
	}
	public void setLongitude(String longitude) {
		Longitude = longitude;
	}
	public String getLatitude() {
		return Latitude;
	}
	public void setLatitude(String latitude) {
		Latitude = latitude;
	}
	public String getAccountCount() {
		return accountCount;
	}
	public void setAccountCount(String accountCount) {
		this.accountCount = accountCount;
	}
	public String getImageURLs() {
		return imageURLs;
	}

	public void setImageURLs(String imageURLs) {
		this.imageURLs = imageURLs;
	}

	public String getIamgeCount() {
		return iamgeCount;
	}
	public void setIamgeCount(String iamgeCount) {
		this.iamgeCount = iamgeCount;
	}
	
	public void setListInfoByJsonObject(JSONObject contentJsonObject){
		try {
			if(contentJsonObject.has("BranchID") && !contentJsonObject.isNull("BranchID")){
					id = contentJsonObject.getString("BranchID");
			}
			if(contentJsonObject.has("BranchName") && !contentJsonObject.isNull("BranchName")){
				name = contentJsonObject.getString("BranchName");
			}
			if(contentJsonObject.has("Address") && !contentJsonObject.isNull("Address")){
					address = contentJsonObject.getString("Address");
			}
		} catch (JSONException e) {
		}
	}
	
	public void setDetailInfoByJsonObject(JSONObject jsonObject){
			try {
				if(jsonObject.has("AccountCount") && !jsonObject.isNull("AccountCount")){
					accountCount =jsonObject.getString("AccountCount");
				}
				if(jsonObject.has("Abbreviation") && !jsonObject.isNull("Abbreviation")){
					abbreviation = jsonObject.getString("Abbreviation");
				}
				if(jsonObject.has("Name") && !jsonObject.isNull("Name")){
					name = jsonObject.getString("Name");
				}
				if(jsonObject.has("Address") && !jsonObject.isNull("Address")){
					address = jsonObject.getString("Address");
				}
				if(jsonObject.has("BusinessHours") && !jsonObject.isNull("BusinessHours")){
					businessHours = jsonObject.getString("BusinessHours");
				}
				if(jsonObject.has("Contact") && !jsonObject.isNull("Contact")){
					contact = jsonObject.getString("Contact");
				}
				if(jsonObject.has("Fax") && !jsonObject.isNull("Fax")){
					fax = jsonObject.getString("Fax");
				}
				if(jsonObject.has("Phone") && !jsonObject.isNull("Phone")){
					phone = jsonObject.getString("Phone");
				}
				if(jsonObject.has("Summary") && !jsonObject.isNull("Summary")){
					summary = jsonObject.getString("Summary");
				}
			    if(jsonObject.has("Web") && !jsonObject.isNull("Web")){
					web = jsonObject.getString("Web");
			    }
				if(jsonObject.has("Zip") && !jsonObject.isNull("Zip")){
					zip = jsonObject.getString("Zip");
				}
				if(jsonObject.has("Remark") && !jsonObject.isNull("Remark")){
					remark =jsonObject.getString("Remark");
				}
				if(jsonObject.has("Latitude") && !jsonObject.isNull("Latitude")){
					Latitude = jsonObject.getString("Latitude");
				}
				if(jsonObject.has("Longitude") && !jsonObject.isNull("Longitude")){
					Longitude = jsonObject.getString("Longitude");
				}
				if(jsonObject.has("ImageCount") && !jsonObject.isNull("ImageCount")){
					iamgeCount = jsonObject.getString("ImageCount");
				}
				
			   if(jsonObject.has("ImageURL") && !jsonObject.isNull("ImageURL")){
				   JSONArray branchImageJson = jsonObject.getJSONArray("ImageURL");
				   StringBuffer imageStr=new StringBuffer();
					for (int j = 0; j < branchImageJson.length(); j++) {
						imageStr.append(branchImageJson.get(j) + ",");
					}
				    imageURLs=imageStr.toString();
				}
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}
	
}
