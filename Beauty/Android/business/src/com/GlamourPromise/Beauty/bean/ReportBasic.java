package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class ReportBasic implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private  double  salesServiceTotal;//服务销售额
	private  double  SalesServiceTotalCash;//服务销售-现金
	private  double  salesServiceTotalBankcard;//服务销售-银行卡
	private  double  salesServiceTotalWeiXin;//服务销售-微信收入
	private  double  salesServiceTotalAli;//服务销售-支付宝收入
	private  double  salesServiceTotalEcard;//服务销售-e卡
	private  double  salesServiceTotalLoan;//服务销售-消费贷款
	private  double  salesServiceTotalFromThird;//服务销售-第三方付款
	private  double  salesServiceRevenuePoint;//积分抵扣
	private  double  salesServiceRevenueCoupon;//券抵扣
	private  double  salesServiceTotalOther;//服务销售-其他
	private  double  salesProductTotal;//商品销售额
	private  double  SalesProductTotalCash;//商品销售-现金
	private  double  salesProductTotalBankcard;//商品销售-银行卡
	private  double  salesProductTotalWeiXin;//商品销售-微信收入
	private  double  salesProductTotalAli;//商品销售-支付宝收入
	private  double  salesProductTotalEcard;//商品销售-e卡
	private  double  salesProductRevenuePoint;//商品销售-积分抵扣
	private  double  salesProductRevenueCoupon;//商品销售-券抵扣
	private  double  salesProductTotalOther;//商品销售-其他
	private  double  salesProductTotalLoan;//商品销售-消费贷款
	private  double  salesProductTotalFromThird;//商品销售-第三方付款
	private  double  cashAndBankcardIncome;//现金和银行卡总收入
	private  double  cashIncome;//现金总收入
	private  double  bankcardIncome;//银行卡总收入
	private  double  weiXinIncome;//微信总收入
	private  double  aliIncome;//支付宝总收入
	private  double  loanIncome;//消费贷款总收入
	private  double  fromThirdIncome;//第三方付款总收入
	private  double  ecardSalesAllIncome;//储值卡总销售
	private  double  ecardSalesCashIncome;//储值卡销售-现金
	private  double  ecardSalesBankCardIncome;//储值卡销售-银行卡
	private  double  ecardSalesWebChatIncome;//储值卡销售-微信
	private  double  ecardSalesAliIncome;//储值卡销售-支付宝
	private  double  ecardBalance;//e卡余额
	private  double  ecardSales;//e卡销售
	private  double  ecardConsume;//e卡消耗
	private  double  serviceOverAll;//服务总业绩
	private  double  serviceOverAllDesigned;//指定业绩
	private  double  serviceOverAllNotDesigned;//非指定业绩
	private  int     serviceTreatmentTimesAll;//服务总次数
	private  int     serviceTreatmentTimesDesigned;//指定次数
	private  int     serviceTreatmentTimesNotDesigned;//非指定次数
	private  int     serviceCustomerAll;//服务总客数
	private  int     serviceCustomerFemale;//服务女性客数
	private  int     serviceCustomerMale;//服务男性客数
	private  int     newAddCustomer;//新增顾客
	private  int     newAddEffectCustomer;//新增有效顾客(开卡并且消费)
	private  int     oldEffectCustomer;//再次消费老顾客
	public double getSalesServiceTotal() {
		return salesServiceTotal;
	}
	public double getSalesProductTotal() {
		return salesProductTotal;
	}
	public void setSalesServiceTotal(double salesServiceTotal) {
		this.salesServiceTotal = salesServiceTotal;
	}
	public void setSalesProductTotal(double salesProductTotal) {
		this.salesProductTotal = salesProductTotal;
	}
	public int getNewAddCustomer() {
		return newAddCustomer;
	}
	public void setNewAddCustomer(int newAddCustomer) {
		this.newAddCustomer = newAddCustomer;
	}
	public int getNewAddEffectCustomer() {
		return newAddEffectCustomer;
	}
	public void setNewAddEffectCustomer(int newAddEffectCustomer) {
		this.newAddEffectCustomer = newAddEffectCustomer;
	}
	public int getOldEffectCustomer() {
		return oldEffectCustomer;
	}
	public void setOldEffectCustomer(int oldEffectCustomer) {
		this.oldEffectCustomer = oldEffectCustomer;
	}
	public double getCashAndBankcardIncome() {
		return cashAndBankcardIncome;
	}
	public void setCashAndBankcardIncome(double cashAndBankcardIncome) {
		this.cashAndBankcardIncome = cashAndBankcardIncome;
	}
	public double getCashIncome() {
		return cashIncome;
	}
	public void setCashIncome(double cashIncome) {
		this.cashIncome = cashIncome;
	}
	public double getBankcardIncome() {
		return bankcardIncome;
	}
	public void setBankcardIncome(double bankcardIncome) {
		this.bankcardIncome = bankcardIncome;
	}
	public double getEcardBalance() {
		return ecardBalance;
	}
	public void setEcardBalance(double ecardBalance) {
		this.ecardBalance = ecardBalance;
	}
	public double getEcardSales() {
		return ecardSales;
	}
	public void setEcardSales(double ecardSales) {
		this.ecardSales = ecardSales;
	}
	public double getEcardConsume() {
		return ecardConsume;
	}
	public void setEcardConsume(double ecardConsume) {
		this.ecardConsume = ecardConsume;
	}
	public double getServiceOverAll() {
		return serviceOverAll;
	}
	public void setServiceOverAll(double serviceOverAll) {
		this.serviceOverAll = serviceOverAll;
	}
	public double getServiceOverAllDesigned() {
		return serviceOverAllDesigned;
	}
	public void setServiceOverAllDesigned(double serviceOverAllDesigned) {
		this.serviceOverAllDesigned = serviceOverAllDesigned;
	}
	public double getServiceOverAllNotDesigned() {
		return serviceOverAllNotDesigned;
	}
	public void setServiceOverAllNotDesigned(double serviceOverAllNotDesigned) {
		this.serviceOverAllNotDesigned = serviceOverAllNotDesigned;
	}
	public int getServiceTreatmentTimesAll() {
		return serviceTreatmentTimesAll;
	}
	public void setServiceTreatmentTimesAll(int serviceTreatmentTimesAll) {
		this.serviceTreatmentTimesAll = serviceTreatmentTimesAll;
	}
	public int getServiceTreatmentTimesDesigned() {
		return serviceTreatmentTimesDesigned;
	}
	public void setServiceTreatmentTimesDesigned(int serviceTreatmentTimesDesigned) {
		this.serviceTreatmentTimesDesigned = serviceTreatmentTimesDesigned;
	}
	public int getServiceTreatmentTimesNotDesigned() {
		return serviceTreatmentTimesNotDesigned;
	}
	public void setServiceTreatmentTimesNotDesigned(int serviceTreatmentTimesNotDesigned) {
		this.serviceTreatmentTimesNotDesigned = serviceTreatmentTimesNotDesigned;
	}
	public int getServiceCustomerAll() {
		return serviceCustomerAll;
	}
	public void setServiceCustomerAll(int serviceCustomerAll) {
		this.serviceCustomerAll = serviceCustomerAll;
	}
	public int getServiceCustomerFemale() {
		return serviceCustomerFemale;
	}
	public void setServiceCustomerFemale(int serviceCustomerFemale) {
		this.serviceCustomerFemale = serviceCustomerFemale;
	}
	public int getServiceCustomerMale() {
		return serviceCustomerMale;
	}
	public void setServiceCustomerMale(int serviceCustomerMale) {
		this.serviceCustomerMale = serviceCustomerMale;
	}
	public double getSalesServiceTotalCash() {
		return SalesServiceTotalCash;
	}
	public void setSalesServiceTotalCash(double salesServiceTotalCash) {
		SalesServiceTotalCash = salesServiceTotalCash;
	}
	public double getSalesServiceTotalBankcard() {
		return salesServiceTotalBankcard;
	}
	public void setSalesServiceTotalBankcard(double salesServiceTotalBankcard) {
		this.salesServiceTotalBankcard = salesServiceTotalBankcard;
	}
	public double getSalesServiceTotalEcard() {
		return salesServiceTotalEcard;
	}
	public void setSalesServiceTotalEcard(double salesServiceTotalEcard) {
		this.salesServiceTotalEcard = salesServiceTotalEcard;
	}
	public double getSalesServiceTotalOther() {
		return salesServiceTotalOther;
	}
	public void setSalesServiceTotalOther(double salesServiceTotalOther) {
		this.salesServiceTotalOther = salesServiceTotalOther;
	}
	public double getSalesProductTotalCash() {
		return SalesProductTotalCash;
	}
	public void setSalesProductTotalCash(double salesProductTotalCash) {
		SalesProductTotalCash = salesProductTotalCash;
	}
	public double getSalesProductTotalBankcard() {
		return salesProductTotalBankcard;
	}
	public void setSalesProductTotalBankcard(double salesProductTotalBankcard) {
		this.salesProductTotalBankcard = salesProductTotalBankcard;
	}
	public double getSalesProductTotalEcard() {
		return salesProductTotalEcard;
	}
	public void setSalesProductTotalEcard(double salesProductTotalEcard) {
		this.salesProductTotalEcard = salesProductTotalEcard;
	}
	public double getSalesProductTotalOther() {
		return salesProductTotalOther;
	}
	public void setSalesProductTotalOther(double salesProductTotalOther) {
		this.salesProductTotalOther = salesProductTotalOther;
	}
	public double getSalesServiceRevenuePoint() {
		return salesServiceRevenuePoint;
	}
	public void setSalesServiceRevenuePoint(double salesServiceRevenuePoint) {
		this.salesServiceRevenuePoint = salesServiceRevenuePoint;
	}
	public double getSalesServiceRevenueCoupon() {
		return salesServiceRevenueCoupon;
	}
	public void setSalesServiceRevenueCoupon(double salesServiceRevenueCoupon) {
		this.salesServiceRevenueCoupon = salesServiceRevenueCoupon;
	}
	public double getSalesProductRevenuePoint() {
		return salesProductRevenuePoint;
	}
	public void setSalesProductRevenuePoint(double salesProductRevenuePoint) {
		this.salesProductRevenuePoint = salesProductRevenuePoint;
	}
	public double getSalesProductRevenueCoupon() {
		return salesProductRevenueCoupon;
	}
	public void setSalesProductRevenueCoupon(double salesProductRevenueCoupon) {
		this.salesProductRevenueCoupon = salesProductRevenueCoupon;
	}
	public double getSalesServiceTotalWeiXin() {
		return salesServiceTotalWeiXin;
	}
	public void setSalesServiceTotalWeiXin(double salesServiceTotalWeiXin) {
		this.salesServiceTotalWeiXin = salesServiceTotalWeiXin;
	}
	public double getSalesProductTotalWeiXin() {
		return salesProductTotalWeiXin;
	}
	public void setSalesProductTotalWeiXin(double salesProductTotalWeiXin) {
		this.salesProductTotalWeiXin = salesProductTotalWeiXin;
	}
	public double getWeiXinIncome() {
		return weiXinIncome;
	}
	public void setWeiXinIncome(double weiXinIncome) {
		this.weiXinIncome = weiXinIncome;
	}
	public double getEcardSalesAllIncome() {
		return ecardSalesAllIncome;
	}
	public void setEcardSalesAllIncome(double ecardSalesAllIncome) {
		this.ecardSalesAllIncome = ecardSalesAllIncome;
	}
	public double getEcardSalesCashIncome() {
		return ecardSalesCashIncome;
	}
	public void setEcardSalesCashIncome(double ecardSalesCashIncome) {
		this.ecardSalesCashIncome = ecardSalesCashIncome;
	}
	public double getEcardSalesBankCardIncome() {
		return ecardSalesBankCardIncome;
	}
	public void setEcardSalesBankCardIncome(double ecardSalesBankCardIncome) {
		this.ecardSalesBankCardIncome = ecardSalesBankCardIncome;
	}
	public double getEcardSalesWebChatIncome() {
		return ecardSalesWebChatIncome;
	}
	public void setEcardSalesWebChatIncome(double ecardSalesWebChatIncome) {
		this.ecardSalesWebChatIncome = ecardSalesWebChatIncome;
	}
	public double getSalesServiceTotalAli() {
		return salesServiceTotalAli;
	}
	public void setSalesServiceTotalAli(double salesServiceTotalAli) {
		this.salesServiceTotalAli = salesServiceTotalAli;
	}
	public double getSalesProductTotalAli() {
		return salesProductTotalAli;
	}
	public void setSalesProductTotalAli(double salesProductTotalAli) {
		this.salesProductTotalAli = salesProductTotalAli;
	}
	public double getEcardSalesAliIncome() {
		return ecardSalesAliIncome;
	}
	public void setEcardSalesAliIncome(double ecardSalesAliIncome) {
		this.ecardSalesAliIncome = ecardSalesAliIncome;
	}
	public double getAliIncome() {
		return aliIncome;
	}
	public void setAliIncome(double aliIncome) {
		this.aliIncome = aliIncome;
	}
	public double getSalesServiceTotalLoan() {
		return salesServiceTotalLoan;
	}
	public void setSalesServiceTotalLoan(double salesServiceTotalLoan) {
		this.salesServiceTotalLoan = salesServiceTotalLoan;
	}
	public double getSalesServiceTotalFromThird() {
		return salesServiceTotalFromThird;
	}
	public void setSalesServiceTotalFromThird(double salesServiceTotalFromThird) {
		this.salesServiceTotalFromThird = salesServiceTotalFromThird;
	}
	public double getSalesProductTotalLoan() {
		return salesProductTotalLoan;
	}
	public void setSalesProductTotalLoan(double salesProductTotalLoan) {
		this.salesProductTotalLoan = salesProductTotalLoan;
	}
	public double getSalesProductTotalFromThird() {
		return salesProductTotalFromThird;
	}
	public void setSalesProductTotalFromThird(double salesProductTotalFromThird) {
		this.salesProductTotalFromThird = salesProductTotalFromThird;
	}
	public double getLoanIncome() {
		return loanIncome;
	}
	public void setLoanIncome(double loanIncome) {
		this.loanIncome = loanIncome;
	}
	public double getFromThirdIncome() {
		return fromThirdIncome;
	}
	public void setFromThirdIncome(double fromThirdIncome) {
		this.fromThirdIncome = fromThirdIncome;
	}
}
