package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;

public class ContactInformation implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String contactID;
	private String time;
	private String scheduleID;
	private String isComplete;
	private String remark;

	public ContactInformation() {
		remark = "";
	}

	public void setContactID(String contactID) {
		this.contactID = contactID;
	}

	public String getContactID() {
		return this.contactID;
	}
	
	public void setTime(String time) {
		this.time = time;
	}

	public String getTime() {
		return this.time;
	}
	
	public void setScheduleID(String scheduleID) {
		this.scheduleID = scheduleID;
	}

	public String getScheduleID() {
		return this.scheduleID;
	}

	public void setIsComplete(String isComplete) {
		this.isComplete = isComplete;
	}

	public String getIsComplete() {
		return this.isComplete;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getRemark() {
		return this.remark;
	}
}
