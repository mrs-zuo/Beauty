package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class PaymentRecord implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int paymentID;//支付ID
	private String paymentRecordTitle;//支付记录标题   比如:支付1笔订单
	private String paymentRecordTime;//支付记录时间
	private boolean    paymentRecordHasRemark;//支付是否有备注
	private String paymentRecordAmount;//支付金额
	private String paymentRecordModel;//支付方式
	public int getPaymentID() {
		return paymentID;
	}
	public void setPaymentID(int paymentID) {
		this.paymentID = paymentID;
	}
	public String getPaymentRecordTitle() {
		return paymentRecordTitle;
	}
	public void setPaymentRecordTitle(String paymentRecordTitle) {
		this.paymentRecordTitle = paymentRecordTitle;
	}
	public String getPaymentRecordTime() {
		return paymentRecordTime;
	}
	public void setPaymentRecordTime(String paymentRecordTime) {
		this.paymentRecordTime = paymentRecordTime;
	}
	public boolean isPaymentRecordHasRemark() {
		return paymentRecordHasRemark;
	}
	public void setPaymentRecordHasRemark(boolean paymentRecordHasRemark) {
		this.paymentRecordHasRemark = paymentRecordHasRemark;
	}
	public String getPaymentRecordAmount() {
		return paymentRecordAmount;
	}
	public void setPaymentRecordAmount(String paymentRecordAmount) {
		this.paymentRecordAmount = paymentRecordAmount;
	}
	public String getPaymentRecordModel() {
		return paymentRecordModel;
	}
	public void setPaymentRecordModel(String paymentRecordModel) {
		this.paymentRecordModel = paymentRecordModel;
	}
}
