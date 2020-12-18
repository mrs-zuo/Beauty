package cn.com.antika.bean;

import java.io.Serializable;

public class EcardHistroy implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int  balanceID;
	private int  actionMode;//
	private String amount;//充值或者支出金额
	private String balance;//该账户充值或者支出后的金额
	private String actionModeName;//充值或者支出的具体动作名称
	private String createTime;//充值或者支出的时间
	private int    actionType;//0.账户进钱   1.账户出钱
	private int    changeType;
	public int getBalanceID() {
		return balanceID;
	}
	public void setBalanceID(int balanceID) {
		this.balanceID = balanceID;
	}
	public int getActionMode() {
		return actionMode;
	}
	public void setActionMode(int actionMode) {
		this.actionMode = actionMode;
	}
	public String getAmount() {
		return amount;
	}
	public void setAmount(String amount) {
		this.amount = amount;
	}
	public String getBalance() {
		return balance;
	}
	public void setBalance(String balance) {
		this.balance = balance;
	}
	public String getActionModeName() {
		return actionModeName;
	}
	public void setActionModeName(String actionModeName) {
		this.actionModeName = actionModeName;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public int getActionType() {
		return actionType;
	}
	public void setActionType(int actionType) {
		this.actionType = actionType;
	}
	public int getChangeType() {
		return changeType;
	}
	public void setChangeType(int changeType) {
		this.changeType = changeType;
	}
}
