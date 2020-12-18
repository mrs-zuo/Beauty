/**
 * BalanceCard.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年7月2日 下午2:17:55
 * @version V1.0
 */
package cn.com.antika.bean;

import java.io.Serializable;

/**
 *BalanceCard
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月2日 下午2:17:55
 */
public class BalanceCard implements Serializable{
	private int    actionMode;
	private String actionModeName;
	private int    cardType;
	private String cardName;
	private String amount;//实际抵的支付金额
	private String balance;
	private String cardPaidAmount;//卡里支付了多少
	public int getActionMode() {
		return actionMode;
	}
	public void setActionMode(int actionMode) {
		this.actionMode = actionMode;
	}
	public String getActionModeName() {
		return actionModeName;
	}
	public void setActionModeName(String actionModeName) {
		this.actionModeName = actionModeName;
	}
	public int getCardType() {
		return cardType;
	}
	public void setCardType(int cardType) {
		this.cardType = cardType;
	}
	public String getCardName() {
		return cardName;
	}
	public void setCardName(String cardName) {
		this.cardName = cardName;
	}
	public String getAmount() {
		return amount;
	}
	public void setAmount(String amount) {
		this.amount = amount;
	}
	public String getBalance() {
		return balance;
	}
	public void setBalance(String balance) {
		this.balance = balance;
	}
	public String getCardPaidAmount() {
		return cardPaidAmount;
	}
	public void setCardPaidAmount(String cardPaidAmount) {
		this.cardPaidAmount = cardPaidAmount;
	}
}
