package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class SalesConsultantRate implements Serializable {
	private int SalesConsultantID;;;
	private String SalesConsultantName;// 销售顾问的名字
	private String commissionRate;// 销售顾问的提成比例
	
	public int getSalesConsultantID() {
		return SalesConsultantID;
	}
	public void setSalesConsultantID(int salesConsultantID) {
		SalesConsultantID = salesConsultantID;
	}
	public String getSalesConsultantName() {
		return SalesConsultantName;
	}
	public void setSalesConsultantName(String salesConsultantName) {
		SalesConsultantName = salesConsultantName;
	}
	public String getCommissionRate() {
		return commissionRate;
	}
	public void setCommissionRate(String commissionRate) {
		this.commissionRate = commissionRate;
	}

}
