package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;

public class PaymentRecordDetail implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String paymentRecordDetailCode;//交易编号
	private String paymentRecordDetailDate;//交易日期
	private String  paymentRecordDetailBranchName;//支付门店
	private String paymentRecordDetailOperator;//操作人
	private String paymentRecordDetailAmount;//交易总金额
	private String paymentRecordDetailTypeName;//交易类型
	private String paymentRecordDetailRemark;//备注
	private List<OrderInfo> paymentRecordOrderList;//订单
	private int    orderNumber;
	private List<SalesConsultantRate>   consultantList;//销售顾问业绩
	private List<BenefitPerson>       profitList;//业绩参与者
	private List<PaymentDetailIssues> pdiList;
	private List<OrderInfo>           paymentOrderList;//交易的订单列表
	private String paymentRecordDetailType;
	
 	public String getPaymentRecordDetailDate() {
		return paymentRecordDetailDate;
	}
	public void setPaymentRecordDetailDate(String paymentRecordDetailDate) {
		this.paymentRecordDetailDate = paymentRecordDetailDate;
	}
	public String getPaymentRecordDetailOperator() {
		return paymentRecordDetailOperator;
	}
	public void setPaymentRecordDetailOperator(String paymentRecordDetailOperator) {
		this.paymentRecordDetailOperator = paymentRecordDetailOperator;
	}
	public String getPaymentRecordDetailAmount() {
		return paymentRecordDetailAmount;
	}
	public void setPaymentRecordDetailAmount(String paymentRecordDetailAmount) {
		this.paymentRecordDetailAmount = paymentRecordDetailAmount;
	}
	public String getPaymentRecordDetailRemark() {
		return paymentRecordDetailRemark;
	}
	public void setPaymentRecordDetailRemark(String paymentRecordDetailRemark) {
		this.paymentRecordDetailRemark = paymentRecordDetailRemark;
	}
	public List<OrderInfo> getPaymentRecordOrderList() {
		return paymentRecordOrderList;
	}
	public void setPaymentRecordOrderList(List<OrderInfo> paymentRecordOrderList) {
		this.paymentRecordOrderList = paymentRecordOrderList;
	}
	public int getOrderNumber() {
		return orderNumber;
	}
	public void setOrderNumber(int orderNumber) {
		this.orderNumber = orderNumber;
	}
	public String getPaymentRecordDetailBranchName() {
		return paymentRecordDetailBranchName;
	}
	public void setPaymentRecordDetailBranchName(
			String paymentRecordDetailBranchName) {
		this.paymentRecordDetailBranchName = paymentRecordDetailBranchName;
	}
	public String getPaymentRecordDetailCode() {
		return paymentRecordDetailCode;
	}
	public void setPaymentRecordDetailCode(String paymentRecordDetailCode) {
		this.paymentRecordDetailCode = paymentRecordDetailCode;
	}
	public List<SalesConsultantRate> getConsultantList() {
		return consultantList;
	}
	public void setConsultantList(List<SalesConsultantRate> consultantList) {
		this.consultantList = consultantList;
	}
	public List<BenefitPerson> getProfitList() {
		return profitList;
	}
	public void setProfitList(List<BenefitPerson> profitList) {
		this.profitList = profitList;
	}
	public List<PaymentDetailIssues> getPdiList() {
		return pdiList;
	}
	public void setPdiList(List<PaymentDetailIssues> pdiList) {
		this.pdiList = pdiList;
	}
	public List<OrderInfo> getPaymentOrderList() {
		return paymentOrderList;
	}
	public void setPaymentOrderList(List<OrderInfo> paymentOrderList) {
		this.paymentOrderList = paymentOrderList;
	}
	public String getPaymentRecordDetailTypeName() {
		return paymentRecordDetailTypeName;
	}
	public void setPaymentRecordDetailTypeName(String paymentRecordDetailTypeName) {
		this.paymentRecordDetailTypeName = paymentRecordDetailTypeName;
	}
	public String getPaymentRecordDetailType() {
		return paymentRecordDetailType;
	}
	public void setPaymentRecordDetailType(String paymentRecordDetailType) {
		this.paymentRecordDetailType = paymentRecordDetailType;
	}
}
