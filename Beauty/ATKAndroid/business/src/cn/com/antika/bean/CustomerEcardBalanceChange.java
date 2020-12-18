/**
 * CustomerEcardBalanceChange.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年3月25日 下午2:37:26
 * @version V1.0
 */
package cn.com.antika.bean;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 *CustomerEcardBalanceChange
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年3月25日 下午2:37:26
 */
public class CustomerEcardBalanceChange implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private String customerName;//顾客姓名
	private BigDecimal customerEcardBalanceChangeBalance;//余额
	private BigDecimal customerEcardBalanceChangeRecharge;//充值
	private BigDecimal customerEcardBalanceChangeOut;//支出
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public BigDecimal getCustomerEcardBalanceChangeBalance() {
		return customerEcardBalanceChangeBalance;
	}
	public void setCustomerEcardBalanceChangeBalance(
			BigDecimal customerEcardBalanceChangeBalance) {
		this.customerEcardBalanceChangeBalance = customerEcardBalanceChangeBalance;
	}
	public BigDecimal getCustomerEcardBalanceChangeRecharge() {
		return customerEcardBalanceChangeRecharge;
	}
	public void setCustomerEcardBalanceChangeRecharge(
			BigDecimal customerEcardBalanceChangeRecharge) {
		this.customerEcardBalanceChangeRecharge = customerEcardBalanceChangeRecharge;
	}
	public BigDecimal getCustomerEcardBalanceChangeOut() {
		return customerEcardBalanceChangeOut;
	}
	public void setCustomerEcardBalanceChangeOut(
			BigDecimal customerEcardBalanceChangeOut) {
		this.customerEcardBalanceChangeOut = customerEcardBalanceChangeOut;
	}
	
}
