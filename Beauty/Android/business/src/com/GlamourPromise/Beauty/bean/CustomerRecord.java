package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

import android.os.Parcel;
import android.os.Parcelable;

/*
 * customer的记录类
 * */
public class CustomerRecord implements Serializable {
	private String recordId;
	private String recordTime;
	private String problem;
	private String suggestion;
	private String customerID;
	private String customerName;
	private String creatorID;
	private String responsiblePersonName;
	private String IsVisible;
	private String label = "";
	private StringBuilder tmp;

	public CustomerRecord() {
		IsVisible = "true";
	}

	public String getRecordTime() {
		return recordTime;
	}

	public void setRecordTime(String recordTime) {
		this.recordTime = recordTime;
	}

	public String getProblem() {
		return problem;
	}

	public void setProblem(String problem) {
		this.problem = problem;
	}

	public String getSuggestion() {
		return suggestion;
	}

	public void setSuggestion(String suggestion) {
		this.suggestion = suggestion;
	}

	public String getRecordId() {
		return recordId;
	}

	public void setRecordId(String recordId) {
		this.recordId = recordId;
	}

	public String getCustomerID() {
		return customerID;
	}

	public String getCustomerName() {
		return customerName;
	}

	public String getCreatorID() {
		return creatorID;
	}

	public void setCustomerID(String customerID) {
		this.customerID = customerID;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public void setCreatorID(String creatorID) {
		this.creatorID = creatorID;
	}

	public String getIsVisible() {
		return IsVisible;
	}

	public void setIsVisible(String isVisible) {
		IsVisible = isVisible;
	}

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		tmp = new StringBuilder();
		String[] arrTmp = label.split("\\|");
		
		for(int i = 0; i < arrTmp.length; i++){
			if(!arrTmp[i].equals(""))
				tmp.append(arrTmp[i]);
			if(!arrTmp[i].equals("") && i < arrTmp.length-1)
				tmp.append("、");
		}
		this.label = tmp.toString();
	}
}
