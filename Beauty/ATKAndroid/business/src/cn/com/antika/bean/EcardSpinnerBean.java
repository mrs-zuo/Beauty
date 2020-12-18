/**
 * EcardSpinnerBean.java
 * cn.com.antika.bean
 * tim.zhang@bizapper.com
 * 2015年7月13日 上午10:54:09
 * @version V1.0
 */
package cn.com.antika.bean;

import java.util.ArrayList;

import android.widget.EditText;
import android.widget.Spinner;

/**
 *EcardSpinnerBean
 *TODO
 * @author tim.zhang@bizapper.com
 * 2015年7月13日 上午10:54:09
 */
public class EcardSpinnerBean {
	private Spinner  ecardSpinner;
	private String[] cardNameArray;
	private EditText prepareOrderProductPromotionPriceText;
	private EditText prepareOrderProductTotalSalePriceText;
	
	private ArrayList<String> cardDiscount;
	private ArrayList<String> cardId;
	
	public EditText getPrepareOrderProductTotalSalePriceText() {
		return prepareOrderProductTotalSalePriceText;
	}
	public void setPrepareOrderProductTotalSalePriceText(
			EditText prepareOrderProductTotalSalePriceText) {
		this.prepareOrderProductTotalSalePriceText = prepareOrderProductTotalSalePriceText;
	}
	public ArrayList<String> getCardId() {
		return cardId;
	}
	public void setCardId(ArrayList<String> cardId) {
		this.cardId = cardId;
	}
	public ArrayList<String> getCardDiscount() {
		return cardDiscount;
	}
	public void setCardDiscount(ArrayList<String> cardDiscount) {
		this.cardDiscount = cardDiscount;
	}
	public EditText getPrepareOrderProductPromotionPriceText() {
		return prepareOrderProductPromotionPriceText;
	}
	public void setPrepareOrderProductPromotionPriceText(
			EditText prepareOrderProductPromotionPriceText) {
		this.prepareOrderProductPromotionPriceText = prepareOrderProductPromotionPriceText;
	}
	public Spinner getEcardSpinner() {
		return ecardSpinner;
	}
	public void setEcardSpinner(Spinner ecardSpinner) {
		this.ecardSpinner = ecardSpinner;
	}
	public String[] getCardNameArray() {
		return cardNameArray;
	}
	public void setCardNameArray(String[] cardNameArray) {
		this.cardNameArray = cardNameArray;
	}
}
