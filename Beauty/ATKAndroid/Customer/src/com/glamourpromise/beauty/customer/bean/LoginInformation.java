package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;

import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class LoginInformation implements Serializable{
	private static final long serialVersionUID = 123L;
	private String customerID;
	private String customerName;
	private String companyName;
	private String companyCode;
	private String companyID;
	private String companyAbbreviation;
	private String branchID;
	private String branchCount;
	private String headImageURL;
	private String promotionCount;
	private String companyScale;
	private String disCount;
	private String currencySymbols;
	private String mGUID="";
	
	public LoginInformation(){
		branchID = "0";
		companyScale = "0";//0:小型店、1:大型店
		disCount = "1.00";
		currencySymbols = "¥";
	}
	
	
	public void setCustomerID(String customerID){
		this.customerID = customerID;
	}
	
	public String getCustomerID(){
		return customerID;
	}
	
	public void setCustomerName(String customerName){
		this.customerName = customerName;
	}
	
	public String getCustomerName(){
		return customerName;
	}
	
	public void setCompanyName(String companyName){
		this.companyName = companyName;
	}
	
	public String getCompanyName(){
		return companyName;
	}
	
	public void setCompanyCode(String companyCode){
		this.companyCode = companyCode;
	}
	
	public String getCompanyCode(){
		return companyCode;
	}
	
	public void setCompanyID(String companyID){
		this.companyID = companyID;
	}
	
	public String getCompanyID(){
		return companyID;
	}
	
	public void setCompanyAbbreviation(String companyAbbreviation){
		this.companyAbbreviation = companyAbbreviation;
	}
	
	public String getCompanyAbbreviation(){
		return companyAbbreviation;
	}
	
	public void setBranchID(String branchID){
		this.branchID = branchID;
	}
	
	public String getBranchID(){
		return branchID;
	}
	
	public void setBranchCount(String branchCount){
		this.branchCount = branchCount;
	}
	
	public String getBranchCount(){
		return branchCount;
	}
	
	public void setHeadImageURL(String headImageURL){
		this.headImageURL = headImageURL;
	}
	
	public String getHeadImageURL(){
		return headImageURL;
	}
	
	public void setPromotionCount(String promotionCount){
		this.promotionCount = promotionCount;
	}
	
	public String getPromotionCount(){
		return promotionCount;
	}
	
	public void setCompanyScale(String companyScale){
		if(companyScale.contains("|1|"))
			this.companyScale = "1";
	}
	
	public String getCompanyScale(){
		return companyScale;
	}
	
	public void setDisCount(String disCount){
		this.disCount = disCount;
	}
	
	public String getDisCount(){
		return NumberFormatUtil.StringFormatToStringWithoutSingle(disCount);
	}

	public String getCurrencySymbols() {
		return currencySymbols;
	}

	public void setCurrencySymbols(String currencySymbols) {
		this.currencySymbols = currencySymbols;
	}


	public String getGUID() {
		return mGUID;
	}


	public void setGUID(String gUID) {
		mGUID = gUID;
	}

	public boolean ParseJson(JSONObject jsonReslut){
		try {
			if(jsonReslut.has("CustomerID")){
				setCustomerID(jsonReslut.getString("CustomerID"));
			}
			if (jsonReslut.has("CustomerName")) {
				setCustomerName(jsonReslut.getString("CustomerName"));
			}
			if (jsonReslut.has("CompanyName")) {
				setCompanyName(jsonReslut.getString("CompanyName"));
			}
			if (jsonReslut.has("CompanyCode")) {
				setCompanyCode(jsonReslut.getString("CompanyCode"));
			}
			if (jsonReslut.has("CompanyID")) {
				setCompanyID(jsonReslut.getString("CompanyID"));
			}

			if (jsonReslut.has("CompanyAbbreviation")) {
				setCompanyAbbreviation(jsonReslut.getString("CompanyAbbreviation"));
			}
			if (jsonReslut.has("BranchID")) {
				setBranchID(jsonReslut.getString("BranchID"));
			}
			if (jsonReslut.has("BranchCount")) {
				setBranchCount(jsonReslut.getString("BranchCount"));
			}
			if (jsonReslut.has("HeadImageURL")) {
				setHeadImageURL(jsonReslut.getString("HeadImageURL"));;
			}
			if (jsonReslut.has("PromotionCount")) {
				setPromotionCount(jsonReslut.getString("PromotionCount"));;
			}
			if (jsonReslut.has("Advanced")) {
				setCompanyScale(jsonReslut.getString("Advanced"));;
			}
			if (jsonReslut.has("Discount")) {
				setDisCount(jsonReslut.getString("Discount"));;
			}

			if (jsonReslut.has("CurrencySymbol")) {
				setCurrencySymbols(jsonReslut.getString("CurrencySymbol"));;
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
}
