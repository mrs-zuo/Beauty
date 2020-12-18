package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class BenefitPerson implements Serializable{
	private int  accountID;
	private String accountName;//业绩参与人的名字
	private String profitPct;//业绩参与人的提成比例
	public int getAccountID() {
		return accountID;
	}
	public void setAccountID(int accountID) {
		this.accountID = accountID;
	}
	public String getAccountName() {
		return accountName;
	}
	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}
	public String getProfitPct() {
		return profitPct;
	}
	public void setProfitPct(String profitPct) {
		this.profitPct = profitPct;
	}
}
