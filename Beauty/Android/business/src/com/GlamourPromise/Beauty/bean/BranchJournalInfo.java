package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;
/*
 * 门店财务总汇
 * */
public class BranchJournalInfo implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private double  incomeAmount;
	private double  salesAll;
	private String  salesAllRatio;
	private double  salesService;
	private String  salesServiceRatio;
	private double  salesCommodity;
	private String  salesCommodityRatio;
	private double  salesEcard;
	private String  salesEcardRatio;
	private double  incomeOthers;
	private String  incomeOthersRatio;
	private double  outAmount;
	private double  balanceAmount;
	private List<BranchJournalOut> outList;
	public double getIncomeAmount() {
		return incomeAmount;
	}
	public void setIncomeAmount(double incomeAmount) {
		this.incomeAmount = incomeAmount;
	}
	public double getSalesAll() {
		return salesAll;
	}
	public void setSalesAll(double salesAll) {
		this.salesAll = salesAll;
	}
	public double getSalesService() {
		return salesService;
	}
	public void setSalesService(double salesService) {
		this.salesService = salesService;
	}
	public double getSalesCommodity() {
		return salesCommodity;
	}
	public void setSalesCommodity(double salesCommodity) {
		this.salesCommodity = salesCommodity;
	}
	public double getSalesEcard() {
		return salesEcard;
	}
	public void setSalesEcard(double salesEcard) {
		this.salesEcard = salesEcard;
	}
	public double getIncomeOthers() {
		return incomeOthers;
	}
	public void setIncomeOthers(double incomeOthers) {
		this.incomeOthers = incomeOthers;
	}
	public double getOutAmount() {
		return outAmount;
	}
	public void setOutAmount(double outAmount) {
		this.outAmount = outAmount;
	}
	public List<BranchJournalOut> getOutList() {
		return outList;
	}
	public void setOutList(List<BranchJournalOut> outList) {
		this.outList = outList;
	}
	public String getSalesAllRatio() {
		return salesAllRatio;
	}
	public void setSalesAllRatio(String salesAllRatio) {
		this.salesAllRatio = salesAllRatio;
	}
	public String getSalesServiceRatio() {
		return salesServiceRatio;
	}
	public void setSalesServiceRatio(String salesServiceRatio) {
		this.salesServiceRatio = salesServiceRatio;
	}
	public String getSalesCommodityRatio() {
		return salesCommodityRatio;
	}
	public void setSalesCommodityRatio(String salesCommodityRatio) {
		this.salesCommodityRatio = salesCommodityRatio;
	}
	public String getSalesEcardRatio() {
		return salesEcardRatio;
	}
	public void setSalesEcardRatio(String salesEcardRatio) {
		this.salesEcardRatio = salesEcardRatio;
	}
	public String getIncomeOthersRatio() {
		return incomeOthersRatio;
	}
	public void setIncomeOthersRatio(String incomeOthersRatio) {
		this.incomeOthersRatio = incomeOthersRatio;
	}
	public double getBalanceAmount() {
		return balanceAmount;
	}
	public void setBalanceAmount(double balanceAmount) {
		this.balanceAmount = balanceAmount;
	}	
	
}
