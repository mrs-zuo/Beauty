package cn.com.antika.bean;

import java.io.Serializable;

public class AllEcardHistroy implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int  balanceID;
	private String  changeTypeName;
	private String createTime;
	private int  changeType;
	private int  targetAccount;
	public int getBalanceID() {
		return balanceID;
	}
	public void setBalanceID(int balanceID) {
		this.balanceID = balanceID;
	}
	public String getChangeTypeName() {
		return changeTypeName;
	}
	public void setChangeTypeName(String changeTypeName) {
		this.changeTypeName = changeTypeName;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public int getChangeType() {
		return changeType;
	}
	public void setChangeType(int changeType) {
		this.changeType = changeType;
	}
	public int getTargetAccount() {
		return targetAccount;
	}
	public void setTargetAccount(int targetAccount) {
		this.targetAccount = targetAccount;
	}
}
