package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
/*
 * 门店累计统计储值卡信息
 * */
public class ReportTotalEcard implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String ecardName;//储值卡名称
	private double ecardTotalBalance;//储值卡卡总余额
	private int    ecardTotalPublish;//储值卡总发行张数
	private int    ecardHasBalanceNumber;//储值卡有余额的数量
	public String getEcardName() {
		return ecardName;
	}
	public void setEcardName(String ecardName) {
		this.ecardName = ecardName;
	}
	public double getEcardTotalBalance() {
		return ecardTotalBalance;
	}
	public void setEcardTotalBalance(double ecardTotalBalance) {
		this.ecardTotalBalance = ecardTotalBalance;
	}
	public int getEcardTotalPublish() {
		return ecardTotalPublish;
	}
	public void setEcardTotalPublish(int ecardTotalPublish) {
		this.ecardTotalPublish = ecardTotalPublish;
	}
	public int getEcardHasBalanceNumber() {
		return ecardHasBalanceNumber;
	}
	public void setEcardHasBalanceNumber(int ecardHasBalanceNumber) {
		this.ecardHasBalanceNumber = ecardHasBalanceNumber;
	}
}
