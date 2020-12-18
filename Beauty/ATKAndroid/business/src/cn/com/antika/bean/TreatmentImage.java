package cn.com.antika.bean;

import java.io.Serializable;
public class TreatmentImage implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private  int  treatmentImageID;
	private  String  origianlImageURL;
	private  String  treatmentImageURL;
	public   TreatmentImage(){
		
	}
	public int getTreatmentImageID() {
		return treatmentImageID;
	}
	public String getTreatmentImageURL() {
		return treatmentImageURL;
	}
	public void setTreatmentImageID(int treatmentImageID) {
		this.treatmentImageID = treatmentImageID;
	}
	public void setTreatmentImageURL(String treatmentImageURL) {
		this.treatmentImageURL = treatmentImageURL;
	}
	public String getOrigianlImageURL() {
		return origianlImageURL;
	}
	public void setOrigianlImageURL(String origianlImageURL) {
		this.origianlImageURL = origianlImageURL;
	}
}
