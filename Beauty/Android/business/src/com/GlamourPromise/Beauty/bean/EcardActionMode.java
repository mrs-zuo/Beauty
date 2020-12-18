/**
 * EcardActionMode.java
 * com.GlamourPromise.Beauty.bean
 * tim.zhang@bizapper.com
 * 2015年7月2日 下午2:14:15
 * @version V1.0
 */
package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;
import java.util.List;

/**
 *EcardActionMode
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月2日 下午2:14:15
 */
public class EcardActionMode implements Serializable{
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	private int    ecardActionMode;
	private String ecardActionModeName;
	private List<BalanceCard> balanceCardList;//账户交易一次性动作发关联到的账户信息
	public int getEcardActionMode() {
		return ecardActionMode;
	}
	public void setEcardActionMode(int ecardActionMode) {
		this.ecardActionMode = ecardActionMode;
	}
	public String getEcardActionModeName() {
		return ecardActionModeName;
	}
	public void setEcardActionModeName(String ecardActionModeName) {
		this.ecardActionModeName = ecardActionModeName;
	}
	public List<BalanceCard> getBalanceCardList() {
		return balanceCardList;
	}
	public void setBalanceCardList(List<BalanceCard> balanceCardList) {
		this.balanceCardList = balanceCardList;
	}
}
