package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Parcel;
import android.os.Parcelable;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EvaluateServiceListTMInfo implements Serializable{
	/**
	 * 
	 */
	private String tmExectorName;
	private String subServiceName;
	private int    satisfaction;
	private String    comment;
	private int    treatmentID;
	
	
	public int getTreatmentID() {
		return treatmentID;
	}
	public void setTreatmentID(int treatmentID) {
		this.treatmentID = treatmentID;
	}
	public String getTmExectorName() {
		return tmExectorName;
	}
	public void setTmExectorName(String tmExectorName) {
		this.tmExectorName = tmExectorName;
	}
	public String getSubServiceName() {
		return subServiceName;
	}
	public void setSubServiceName(String subServiceName) {
		this.subServiceName = subServiceName;
	}
	public int getSatisfaction() {
		return satisfaction;
	}
	public void setSatisfaction(int satisfaction) {
		this.satisfaction = satisfaction;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	
}
