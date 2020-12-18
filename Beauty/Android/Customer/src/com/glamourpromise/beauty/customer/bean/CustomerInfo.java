package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CustomerInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int customerID;
	private String customerName;
	private int companyID;
	private String companyName;
	private String companyAbbreviation;
	private int branchID;
	private int branchCount;
	private String headImageUrl;
	private int promotionCount;
	private String companyCode;
	private float disCount;
	private int   companyScale;
	private int    gender;//顾客性别
	private String loginMobile;//会员登录手机号
	private List<AccountInformation> accountInformationList;//该顾客的专属顾问
	public CustomerInfo() {
	}

	public int getCustomerID() {
		return customerID;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}

	public String getCustomerName() {
		return customerName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public int getCompanyID() {
		return companyID;
	}

	public void setCompanyID(int companyID) {
		this.companyID = companyID;
	}

	public String getCompanyName() {
		return companyName;
	}

	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}

	public String getCompanyAbbreviation() {
		return companyAbbreviation;
	}

	public void setCompanyAbbreviation(String companyAbbreviation) {
		this.companyAbbreviation = companyAbbreviation;
	}

	public int getBranchID() {
		return branchID;
	}

	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}

	public int getBranchCount() {
		return branchCount;
	}

	public void setBranchCount(int branchCount) {
		this.branchCount = branchCount;
	}

	public String getHeadImageUrl() {
		return headImageUrl;
	}

	public void setHeadImageUrl(String headImageUrl) {
		this.headImageUrl = headImageUrl;
	}

	public int getPromotionCount() {
		return promotionCount;
	}

	public void setPromotionCount(int promotionCount) {
		this.promotionCount = promotionCount;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public float getDisCount() {
		return disCount;
	}

	public void setDisCount(float disCount) {
		this.disCount = disCount;
	}

	public int getCompanyScale() {
		return companyScale;
	}

	public void setCompanyScale(int companyScale) {
		this.companyScale = companyScale;
	}

	public int getGender() {
		return gender;
	}

	public void setGender(int gender) {
		this.gender = gender;
	}

	public String getLoginMobile() {
		return loginMobile;
	}

	public void setLoginMobile(String loginMobile) {
		this.loginMobile = loginMobile;
	}

	public List<AccountInformation> getAccountInformationList() {
		return accountInformationList;
	}

	public void setAccountInformationList(
			List<AccountInformation> accountInformationList) {
		this.accountInformationList = accountInformationList;
	}
	public static CustomerInfo parseCustomerInfoByJson(String jsonString){
		CustomerInfo customer=null;
		try {
			JSONObject jsSrc=new JSONObject(jsonString);
			customer=new CustomerInfo();
			if (jsSrc.has("CustomerID")) {
				customer.setCustomerID(jsSrc.getInt("CustomerID"));
			}
			if (jsSrc.has("CustomerName")) {
				customer.setCustomerName(jsSrc.getString("CustomerName"));
			}
			if (jsSrc.has("LoginMobile")) {
				customer.setLoginMobile(jsSrc.getString("LoginMobile"));
			}
			if (jsSrc.has("HeadImageURL") && !jsSrc.isNull("HeadImageURL")) {
				customer.setHeadImageUrl(jsSrc.getString("HeadImageURL"));
			}
			if (jsSrc.has("Gender")) {
				customer.setGender(jsSrc.getInt("Gender"));
			}
			if(jsSrc.has("BranchList") && !jsSrc.isNull("BranchList")){
				JSONArray accountJsonArray=jsSrc.getJSONArray("BranchList");
				List<AccountInformation> accountList=new ArrayList<AccountInformation>();
				for(int i=0;i<accountJsonArray.length();i++){
					AccountInformation accountInfo=new AccountInformation();
					JSONObject accountJson=accountJsonArray.getJSONObject(i);
					Branch branch=new Branch();
					if(accountJson.has("BranchID")){
						branch.setID(accountJson.getString("BranchID"));
					}
					if(accountJson.has("BranchName")){
						branch.setName(accountJson.getString("BranchName"));
						accountInfo.setBranch(branch);
					}
					if(accountJson.has("ResponsiblePersonID"))
						accountInfo.setAccountID(accountJson.getString("ResponsiblePersonID"));
					if(accountJson.has("ResponsiblePersonName"))
						accountInfo.setAccountName(accountJson.getString("ResponsiblePersonName"));
					accountList.add(accountInfo);
				}
				customer.setAccountInformationList(accountList);
			}

		} catch (JSONException e) {
			e.printStackTrace();
		}
		return customer;
	}
}
