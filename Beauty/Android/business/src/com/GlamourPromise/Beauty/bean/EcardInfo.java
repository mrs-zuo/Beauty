package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;

public class EcardInfo implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private String    userEcardCode;//卡Code
	private String    userRealCardNo;//实体卡号
	private String    userEcardNo;//客户卡号
	private int       userEcardID;//客户卡ID
	private int    	  userEcardType;//1： 储值卡    2：积分卡   3：现金劵卡
	private String    userEcardTypeName;//客户卡类型名称
	private String    userEcardName;//客户卡名称
	private String    userEcardBalance;//客户卡余额
	private String    userEcardCreateDate;//客户卡建卡日期
	private String    userEcardExpirationDate;//客户卡过期日期
	private List<DiscountDetail> discountDetailList;//客户卡所对应的卡的折扣分类
	private String    userEcardDiscount;
	private boolean isDefault;//是否是默认卡
	private String  userEcardDescription;//客户卡描述
	private String     userEcardNameAndDiscount;
	private String    userEcardPresentRate;
	private String    userEcardRate;
	private boolean isSelect;
	
	public EcardInfo()
    {
		//默认未选中
		isSelect=false;
    }
	
	public boolean isSelect() {
		return isSelect;
	}
	public void setSelect(boolean isSelect) {
		this.isSelect = isSelect;
	}
	public String getUserEcardPresentRate() {
		return userEcardPresentRate;
	}
	public void setUserEcardPresentRate(String userEcardPresentRate) {
		this.userEcardPresentRate = userEcardPresentRate;
	}
	public String getUserEcardRate() {
		return userEcardRate;
	}
	public void setUserEcardRate(String userEcardRate) {
		this.userEcardRate = userEcardRate;
	}
	public String getUserEcardNameAndDiscount() {
		return userEcardNameAndDiscount;
	}
	public void setUserEcardNameAndDiscount(String userEcardNameAndDiscount) {
		this.userEcardNameAndDiscount = userEcardNameAndDiscount;
	}
	public String getUserEcardDiscount() {
		return userEcardDiscount;
	}
	public void setUserEcardDiscount(String userEcardDiscount) {
		this.userEcardDiscount = userEcardDiscount;
	}
	public String getUserEcardNo() {
		return userEcardNo;
	}
	public void setUserEcardNo(String userEcardNo) {
		this.userEcardNo = userEcardNo;
	}
	public int getUserEcardID() {
		return userEcardID;
	}
	public void setUserEcardID(int userEcardID) {
		this.userEcardID = userEcardID;
	}
	public int getUserEcardType() {
		return userEcardType;
	}
	public void setUserEcardType(int userEcardType) {
		this.userEcardType = userEcardType;
	}
	public String getUserEcardName() {
		return userEcardName;
	}
	public void setUserEcardName(String userEcardName) {
		this.userEcardName = userEcardName;
	}
	public String getUserEcardBalance() {
		return userEcardBalance;
	}
	public void setUserEcardBalance(String userEcardBalance) {
		this.userEcardBalance = userEcardBalance;
	}
	public String getUserEcardExpirationDate() {
		return userEcardExpirationDate;
	}
	public void setUserEcardExpirationDate(String userEcardExpirationDate) {
		this.userEcardExpirationDate = userEcardExpirationDate;
	}
	public List<DiscountDetail> getDiscountDetailList() {
		return discountDetailList;
	}
	public void setDiscountDetailList(List<DiscountDetail> discountDetailList) {
		this.discountDetailList = discountDetailList;
	}
	public boolean isDefault() {
		return isDefault;
	}
	public void setDefault(boolean isDefault) {
		this.isDefault = isDefault;
	}
	public String getUserEcardDescription() {
		return userEcardDescription;
	}
	public void setUserEcardDescription(String userEcardDescription) {
		this.userEcardDescription = userEcardDescription;
	}
	public String getUserEcardCreateDate() {
		return userEcardCreateDate;
	}
	public void setUserEcardCreateDate(String userEcardCreateDate) {
		this.userEcardCreateDate = userEcardCreateDate;
	}
	public String getUserEcardTypeName() {
		return userEcardTypeName;
	}
	public void setUserEcardTypeName(String userEcardTypeName) {
		this.userEcardTypeName = userEcardTypeName;
	}
	public String getUserEcardCode() {
		return userEcardCode;
	}
	public void setUserEcardCode(String userEcardCode) {
		this.userEcardCode = userEcardCode;
	}

	public String getUserRealCardNo() {
		return userRealCardNo;
	}

	public void setUserRealCardNo(String userRealCardNo) {
		this.userRealCardNo = userRealCardNo;
	}
}
