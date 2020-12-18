package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;


public class RechargeDetail implements Serializable {
	private static final long serialVersionUID = 1L;
	private String rechargeDate;//充值日期
	private String rechargeOperator;//充值操作人
	private String rechargeAmont;//充值金额
	private String rechargeModel;//充值方式
	private String rechargeBalance;//e卡余额
	private List<BenefitPerson> rechargeProfit;//充值业绩参与及比例
	private String rechargeRemark;//充值备注
	public String getRechargeDate() {
		return rechargeDate;
	}
	public void setRechargeDate(String rechargeDate) {
		this.rechargeDate = rechargeDate;
	}
	public String getRechargeOperator() {
		return rechargeOperator;
	}
	public void setRechargeOperator(String rechargeOperator) {
		this.rechargeOperator = rechargeOperator;
	}
	public String getRechargeAmont() {
		return rechargeAmont;
	}
	public void setRechargeAmont(String rechargeAmont) {
		this.rechargeAmont = rechargeAmont;
	}
	public String getRechargeModel() {
		return rechargeModel;
	}
	public void setRechargeModel(String rechargeModel) {
		this.rechargeModel = rechargeModel;
	}
	public String getRechargeBalance() {
		return rechargeBalance;
	}
	public void setRechargeBalance(String rechargeBalance) {
		this.rechargeBalance = rechargeBalance;
	}
	public String getRechargeRemark() {
		return rechargeRemark;
	}
	public void setRechargeRemark(String rechargeRemark) {
		this.rechargeRemark = rechargeRemark;
	}
	public List<BenefitPerson> getRechargeProfit() {
		return rechargeProfit;
	}
	public void setRechargeProfit(List<BenefitPerson> rechargeProfit) {
		this.rechargeProfit = rechargeProfit;
	}
}
