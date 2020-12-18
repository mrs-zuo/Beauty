package cn.com.antika.bean;

import java.io.Serializable;

public class ReportListBean implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  String  objectName;
	private  int     objectID;
	private  String  salesAmount;
	private  String  rechargeAmount;
	public String getObjectName() {
		return objectName;
	}
	public int getObjectID() {
		return objectID;
	}
	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}
	public void setObjectID(int objectID) {
		this.objectID = objectID;
	}
	public String getSalesAmount() {
		return salesAmount;
	}
	public String getRechargeAmount() {
		return rechargeAmount;
	}
	public void setSalesAmount(String salesAmount) {
		this.salesAmount = salesAmount;
	}
	public void setRechargeAmount(String rechargeAmount) {
		this.rechargeAmount = rechargeAmount;
	}
}
