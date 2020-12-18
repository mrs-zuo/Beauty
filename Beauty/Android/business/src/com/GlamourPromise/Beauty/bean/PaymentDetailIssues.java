/**
 * PaymentDetailIssues.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年7月23日 下午6:01:03
 * @version V1.0
 */
package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

/**
 *PaymentDetailIssues
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月23日 下午6:01:03
 */
public class PaymentDetailIssues implements Serializable{
	private  int paymentMode;//支付类型
	private  String paymentAmount;//支付额
	private  String cardPaidAmount;//实际卡支付的金额
	private  String cardName;//支付卡的名称
	private  int    cardType;
	private  String UserCardNo;//支付卡的卡号
		
	public int getPaymentMode() {
		return paymentMode;
	}
	public void setPaymentMode(int paymentMode) {
		this.paymentMode = paymentMode;
	}
	public String getPaymentAmount() {
		return paymentAmount;
	}
	public void setPaymentAmount(String paymentAmount) {
		this.paymentAmount = paymentAmount;
	}
	public String getCardPaidAmount() {
		return cardPaidAmount;
	}
	public void setCardPaidAmount(String cardPaidAmount) {
		this.cardPaidAmount = cardPaidAmount;
	}
	public String getCardName() {
		return cardName;
	}
	public void setCardName(String cardName) {
		this.cardName = cardName;
	}
	public int getCardType() {
		return cardType;
	}
	public void setCardType(int cardType) {
		this.cardType = cardType;
	}
	public String getUserCardNo() {
		return UserCardNo;
	}
	public void setUserCardNo(String userCardNo) {
		UserCardNo = userCardNo;
	}	
}
