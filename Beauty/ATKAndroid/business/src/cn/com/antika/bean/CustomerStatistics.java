package cn.com.antika.bean;

import java.io.Serializable;

public class CustomerStatistics implements Serializable{
	/**
	 * 顾客统计
	 */
	private static final long serialVersionUID = 1L;
	private int    objectCount;//服务次数或者商品个数
    private String objectName;//抽取名
    private double consumeAmount;//消费金额
    private double rechargeAmount;//充值金额
    private double totalAmount;//总金额
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
	public double getTotalAmount() {
		return totalAmount;
	}
	public void setTotalAmount(double totalAmount) {
		this.totalAmount = totalAmount;
	}
}	
