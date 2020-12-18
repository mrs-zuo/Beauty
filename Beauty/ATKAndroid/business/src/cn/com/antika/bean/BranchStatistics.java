package cn.com.antika.bean;

import java.io.Serializable;

public class BranchStatistics implements Serializable{
	/**
	 *商家数据统计
	 */
	private static final long serialVersionUID = 1L;
	private int    objectCount;//服务次数  或者 操作业绩
    private String objectName;//中文月份
    private double sumOrigPrice;//消费金额
    private double totalAmount;//总业绩  销售加充值业绩
    private double consumeAmount;//销售业绩
    private double rechargeAmount;//充值业绩
    private String dateSort;//
    private int    objectId;
	public int getObjectCount() {
		return objectCount;
	}
	public void setObjectCount(int objectCount) {
		this.objectCount = objectCount;
	}
	public String getObjectName() {
		return objectName;
	}
	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}
	public double getSumOrigPrice() {
		return sumOrigPrice;
	}
	public void setSumOrigPrice(double sumOrigPrice) {
		this.sumOrigPrice = sumOrigPrice;
	}
	public double getTotalAmount() {
		return totalAmount;
	}
	public void setTotalAmount(double totalAmount) {
		this.totalAmount = totalAmount;
	}
	public double getConsumeAmount() {
		return consumeAmount;
	}
	public void setConsumeAmount(double consumeAmount) {
		this.consumeAmount = consumeAmount;
	}
	public double getRechargeAmount() {
		return rechargeAmount;
	}
	public void setRechargeAmount(double rechargeAmount) {
		this.rechargeAmount = rechargeAmount;
	}
	public String getDateSort() {
		return dateSort;
	}
	public void setDateSort(String dateSort) {
		this.dateSort = dateSort;
	}
	public int getObjectId() {
		return objectId;
	}
	public void setObjectId(int objectId) {
		this.objectId = objectId;
	}
}	
