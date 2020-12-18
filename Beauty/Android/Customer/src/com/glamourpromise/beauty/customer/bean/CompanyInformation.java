package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CompanyInformation implements Serializable{
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
	private List<String> imageURL;
	private String iamgeCount;

	public CompanyInformation() {
		this.imageURL = new ArrayList<String>();
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
		Longitude = "-1";
		Latitude  ="-1";
		accountCount = "0";
		iamgeCount = "0";
	}
	
	public boolean parseByJson(String src){
		JSONObject json = null;
		try {
			json = new JSONObject(src);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return parse(json);
	}
	
	public boolean parseByJson(JSONObject src){
		return parse(src);
	}

	private boolean parse(JSONObject src) {
		try {
			JSONObject json = src;
			if(json.has("Name")){
				setName(json.getString("Name"));
			}
			if(json.has("Summary")){
				setSummary(json.getString("Summary"));
			}
			if(json.has("Contact")){
				setContact(json.getString("Contact"));
			}
			if(json.has("Phone")){
				setPhone(json.getString("Phone"));
			}
			if(json.has("BusinessHours") && !json.isNull("BusinessHours")){
				setBusinessHours(json.getString("BusinessHours"));
			}
			if(json.has("Fax")){
				setFax(json.getString("Fax"));
			}
			if(json.has("Address") && !json.isNull("Address")){
				setAddress(json.getString("Address"));
			}
			if(json.has("Zip") && !json.isNull("Zip")){
				setZip(json.getString("Zip"));
			}
			if(json.has("Web")){
				setWeb(json.getString("Web"));
			}
			if(json.has("Remark")){
				setRemark(json.getString("Remark"));
			}
			if(json.has("Longitude")){
				setLongitude(json.getString("Longitude"));
			}
			if(json.has("Latitude")){
				setLatitude(json.getString("Latitude"));
			}
			if(json.has("AccountCount")){
				setAccountCount(json.getString("AccountCount"));
			}
			if(json.has("Abbreviation")){
				setAbbreviation(json.getString("Abbreviation"));
			}
			if(json.has("ImageCount")){
				setIamgeCount(json.getString("ImageCount"));
			}
			if(!getIamgeCount().equals("0")){
				ArrayList<String> url = new ArrayList<String>();
				JSONArray jarrUrl = json.getJSONArray("ImageURL");
				int count = jarrUrl.length();
				for(int i = 0; i < count; i++){
					url.add(jarrUrl.getString(i));
				}
				setImageURL(url);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public static ArrayList<CompanyInformation> parseListByJson(String src){
		ArrayList<CompanyInformation> list = new ArrayList<CompanyInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			CompanyInformation item;
			for(int i = 0; i < count; i++){
				item = new CompanyInformation();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public void setAbbreviation(String abbreviation) {
		this.abbreviation = abbreviation;
	}

	public String getAbbreviation() {
		return this.abbreviation;
	}
	
	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return this.name;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public String getSummary() {
		return this.summary;
	}

	public void setContact(String contact) {
		this.contact = contact;
	}

	public String getContact() {
		return this.contact;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getPhone() {
		return this.phone;
	}

	public void setFax(String fax) {
		this.fax = fax;
	}

	public String getFax() {
		return this.fax;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getAddress() {
		return this.address;
	}
	
	public void setZip(String zip) {
		this.zip = zip;
	}

	public String getZip() {
		return this.zip;
	}
	
	public void setWeb(String web) {
		this.web = web;
	}

	public String getWeb() {
		return this.web;
	}
	public void setBusinessHours(String businessHours) {
		if(!businessHours.equals("null"))
			this.businessHours = businessHours;
	}

	public String getbBusinessHours() {
		return this.businessHours;
	}
	
	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getRemark() {
		return this.remark;
	}
	
	public void setLongitude(String Longitude) {
		this.Longitude = Longitude;
	}

	public String getLongitude() {
		return this.Longitude;
	}
	
	public void setLatitude(String Latitude) {
		this.Latitude = Latitude;
	}

	public String getLatitude() {
		return this.Latitude;
	}
	
	public void setAccountCount(String accountCount) {
		this.accountCount = accountCount;
	}

	public String getAccountCount() {
		return this.accountCount;
	}
	public void setImageURL(List<String> imageURL) {
		this.imageURL = imageURL;
	}

	public List<String> getImageURL() {
		return this.imageURL;
	}
	public void setIamgeCount(String iamgeCount) {
		this.iamgeCount = iamgeCount;
	}

	public String getIamgeCount() {
		return this.iamgeCount;
	}
	
}
