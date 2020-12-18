package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;
/*
 * 订单退款
 * */
public class RefundInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private double            refundAmount;
	private double            givePointAmount;
	private double            giveCashCouponAmount;
	private double            Rate;
	private int               ProductType;
	private List<PaymentRecordDetail> PaymentRecordDetailList;
	private List<EcardInfo>   ecardInfoList;
	public double getRefundAmount() {
		return refundAmount;
	}
	public void setRefundAmount(double refundAmount) {
		this.refundAmount = refundAmount;
	}
	public List<PaymentRecordDetail> getPaymentRecordDetailList() {
		return PaymentRecordDetailList;
	}
	public void setPaymentRecordDetailList(
			List<PaymentRecordDetail> paymentRecordDetailList) {
		PaymentRecordDetailList = paymentRecordDetailList;
	}
	public List<EcardInfo> getEcardInfoList() {
		return ecardInfoList;
	}
	public void setEcardInfoList(List<EcardInfo> ecardInfoList) {
		this.ecardInfoList = ecardInfoList;
	}
	public double getGivePointAmount() {
		return givePointAmount;
	}
	public void setGivePointAmount(double givePointAmount) {
		this.givePointAmount = givePointAmount;
	}
	public double getGiveCashCouponAmount() {
		return giveCashCouponAmount;
	}
	public void setGiveCashCouponAmount(double giveCashCouponAmount) {
		this.giveCashCouponAmount = giveCashCouponAmount;
	}
	public double getRate() {
		return Rate;
	}
	public void setRate(double rate) {
		Rate = rate;
	}
	public int getProductType() {
		return ProductType;
	}
	public void setProductType(int productType) {
		ProductType = productType;
	}
}
