package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 
 * 服务评价
 * */
public class TreatmentReview implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int    satisfaction;
	private String comment;
	private String tmExectorName;
	private String subServiceName;
	private int    treatmentID;
	
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
	public int getTreatmentID() {
		return treatmentID;
	}
	public void setTreatmentID(int treatmentID) {
		this.treatmentID = treatmentID;
	}
	public int getSatisfaction() {
		return satisfaction;
	}
	public String getComment() {
		return comment;
	}
	public void setSatisfaction(int satisfaction) {
		this.satisfaction = satisfaction;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
}
