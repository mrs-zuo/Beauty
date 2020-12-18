package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class AccountInformation implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String accountID;
	private String accountName;
	private String accountCode;
	private String department;
	private String title;
	private String expert;
	private String headImageURL;
	private String pinYin;
	private String pinYinFirst;
	private int    flyMessageAuthority;//飞语权限
	private Branch branch;//该服务顾客所属门店信息
	public AccountInformation()
	{
		accountName = "";
		accountCode = "";
		department = "";
		title = "";
		expert = "";
		headImageURL = "";
		pinYin = "";
		pinYinFirst = "";
		flyMessageAuthority = 1;
	}
	
	public static ArrayList<AccountInformation> parseListByJson(String src){
		ArrayList<AccountInformation> list = new ArrayList<AccountInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			AccountInformation item;
			for(int i = 0; i < count; i++){
				item = new AccountInformation();
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
			if(jsSrc.has("AccountID")){
				setAccountID(jsSrc.getString("AccountID"));
			}
			if (jsSrc.has("AccountName")) {
				setAccountName(jsSrc.getString("AccountName"));
			}
			if (jsSrc.has("Department")) {
				setDepartment(jsSrc.getString("Department"));
			}
			if(jsSrc.has("Title")){
				setTitle(jsSrc.getString("Title"));
			}
			if (jsSrc.has("PinYin")) {
				setPinYin(jsSrc.getString("PinYin"));
			}
			if (jsSrc.has("PinYinFirst")) {
				setPinYinFirst(jsSrc.getString("PinYinFirst"));
			}
			if(jsSrc.has("HeadImageURL")){
				setHeadImageURL(jsSrc.getString("HeadImageURL"));
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public String getAccountID() {
		return accountID;
	}
	public void setAccountID(String AccountID) {
		this.accountID = AccountID;
	}
	
	public String getAccountName() {
		return accountName;
	}
	public void setAccountName(String AccountName) {
		this.accountName = AccountName;
	}
	
	public String getAccountCode() {
		return accountCode;
	}
	public void setAccountCode(String AccountCode) {
		this.accountCode = AccountCode;
	}
	
	public String getDepartment() {
		return department;
	}
	public void setDepartment(String Department) {
		this.department = Department;
	}
	
	public String getTitle() {
		return title;
	}
	public void setTitle(String Title) {
		this.title = Title;
	}
	
	public String getExpert() {
		return expert;
	}
	public void setExpert(String Expert) {
		this.expert = Expert;
	}
	
	public String getHeadImageURL() {
		return headImageURL;
	}
	public void setHeadImageURL(String HeadImageURL) {
		if(HeadImageURL.equals("null"))
			this.headImageURL = "";
		else
			this.headImageURL = HeadImageURL;
	}
	
	public String getPinYin() {
		return pinYin;
	}
	public void setPinYin(String PinYin) {
		this.pinYin = PinYin;
	}
	
	public String getPinYinFirst() {
		return pinYinFirst;
	}
	public void setPinYinFirst(String PinYinFirst) {
		this.pinYinFirst = PinYinFirst;
	}

	public int getFlyMessageAuthority() {
		return flyMessageAuthority;
	}

	public void setFlyMessageAuthority(boolean flyMessageAuthority) {
		if(flyMessageAuthority){
			this.flyMessageAuthority = 1;
		}else{
			this.flyMessageAuthority = 0;
		}
	}

	public Branch getBranch() {
		return branch;
	}

	public void setBranch(Branch branch) {
		this.branch = branch;
	}
}
