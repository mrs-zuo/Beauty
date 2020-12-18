package cn.com.antika.bean;

import java.io.Serializable;

public class ThirdPartPay implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String  netTradeNo;//第三方支付编号
	private double  payAmount;//第三方支付金额
	private String  payTime;//第三方支付时间
	private String  payProductName;//第三方支付商品名称
	private String  payBankName;//第三方支付银行名称
	private String  payTradeID;//第三方交易单号
	private String  payQRCodeUrl;//第三方交易的二维码地址
	private String  resultCode;//第三方支付和我们系统交互的结果   SUCCESS/FAIL/USERPAYING
	private String  tradeState;//第三方支付支付结果的状态   SUCCESS—支付成功 REFUND—转入退款,NOTPAY—未支付,CLOSED—已关闭,REVOKED—已撤销（刷卡支付）,USERPAYING--用户支付中,PAYERROR--支付失败(其他原因，如银行返回失败)
	private String  changeTypeName;//第三方交易类型 消费或者是储值卡充值
	private int     netTradeVendor;//第三方支付类型   1：微信  2：支付宝
	public String getNetTradeNo() {
		return netTradeNo;
	}
	public void setNetTradeNo(String netTradeNo) {
		this.netTradeNo = netTradeNo;
	}
	public double getPayAmount() {
		return payAmount;
	}
	public void setPayAmount(double payAmount) {
		this.payAmount = payAmount;
	}
	public String getPayTime() {
		return payTime;
	}
	public void setPayTime(String payTime) {
		this.payTime = payTime;
	}
	public String getPayProductName() {
		return payProductName;
	}
	public void setPayProductName(String payProductName) {
		this.payProductName = payProductName;
	}
	public String getPayBankName() {
		return payBankName;
	}
	public void setPayBankName(String payBankName) {
		this.payBankName = payBankName;
	}
	public String getPayTradeID() {
		return payTradeID;
	}
	public void setPayTradeID(String payTradeID) {
		this.payTradeID = payTradeID;
	}
	public String getPayQRCodeUrl() {
		return payQRCodeUrl;
	}
	public void setPayQRCodeUrl(String payQRCodeUrl) {
		this.payQRCodeUrl = payQRCodeUrl;
	}
	public String getResultCode() {
		return resultCode;
	}
	public void setResultCode(String resultCode) {
		this.resultCode = resultCode;
	}
	public String getTradeState() {
		return tradeState;
	}
	public void setTradeState(String tradeState) {
		this.tradeState = tradeState;
	}
	public String getChangeTypeName() {
		return changeTypeName;
	}
	public void setChangeTypeName(String changeTypeName) {
		this.changeTypeName = changeTypeName;
	}
	public int getNetTradeVendor() {
		return netTradeVendor;
	}
	public void setNetTradeVendor(int netTradeVendor) {
		this.netTradeVendor = netTradeVendor;
	}
}
