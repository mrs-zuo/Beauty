package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
/*
 * 
 * 子服务
 */
public class SubServiceInformation implements Serializable {
	private int subServiceID;//子服务的ID
	private String subServiceName;//子服务名称
	private int    subServiceSpendTime;//子服务服务时间
	public int getSubServiceID() {
		return subServiceID;
	}
	public void setSubServiceID(int subServiceID) {
		this.subServiceID = subServiceID;
	}
	public String getSubServiceName() {
		return subServiceName;
	}
	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}
	public int getSubServiceSpendTime() {
		return subServiceSpendTime;
	}
	public void setSubServiceSpendTime(int subServiceSpendTime) {
		this.subServiceSpendTime = subServiceSpendTime;
	}
}
