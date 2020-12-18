package cn.com.antika.bean;

import org.json.JSONException;
import org.json.JSONObject;
public class AccountDetailInfo {
	private String accountID;
	private String accountCode;
	private String accountName;
	private String department;
	private String title;
	private String introduction;
	private String expert;
	private String mobile;
	private String headImageURL;
	private String branchName;
	public AccountDetailInfo(){
		accountID = "0";
		accountName = "";
		department = "";
		title = "";
		introduction = "";
		expert = "";
		mobile = "";
		headImageURL = "";
		branchName = "";
	}
	public String getAccountID() {
		return accountID;
	}

	public void setAccountID(String accountID) {
		this.accountID = accountID;
	}

	public String getAccountCode() {
		return accountCode;
	}

	public void setAccountCode(String accountCode) {
		this.accountCode = accountCode;
	}

	public String getAccountName() {
		return accountName;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getIntroduction() {
		return introduction;
	}

	public void setIntroduction(String introduction) {
		this.introduction = introduction;
	}

	public String getExpert() {
		return expert;
	}

	public void setExpert(String expert) {
		this.expert = expert;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getHeadImageURL() {
		return headImageURL;
	}

	public void setHeadImageURL(String headImageURL) {
		this.headImageURL = headImageURL;
	}

	public String getBranchName() {
		return branchName;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}
	
	public void setInfoByJsonObject(JSONObject jsonObject){
			try {
				if (jsonObject.has("AccountName")) 
					accountName = jsonObject.getString("AccountName");
				if (jsonObject.has("Name")) 
					accountName = jsonObject.getString("Name");
				if(jsonObject.has("AccountID")) 
					accountID = jsonObject.getString("AccountID");
				if (jsonObject.has("Code")) 
					accountCode = jsonObject.getString("Code");
				if (jsonObject.has("Department")) 
					department = jsonObject.getString("Department");
				if (jsonObject.has("Title")) 
					title = jsonObject.getString("Title");
				if (jsonObject.has("Introduction")) 
					introduction = jsonObject.getString("Introduction");
				if (jsonObject.has("Expert")) 
					expert = jsonObject.getString("Expert");
				if (jsonObject.has("Mobile")) 
					mobile = jsonObject.getString("Mobile");
				if (jsonObject.has("HeadImageURL")) 
					headImageURL = jsonObject.getString("HeadImageURL");
				if (jsonObject.has("BranchName")) 
					branchName = jsonObject.getString("BranchName");
			} catch (JSONException e) {
			}
	}
			
}
