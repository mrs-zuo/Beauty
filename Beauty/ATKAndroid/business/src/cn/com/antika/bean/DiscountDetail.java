package cn.com.antika.bean;

import java.io.Serializable;

/*
 * 折扣的详细 
 * */
public class DiscountDetail implements Serializable {
	private int    discountDetailID;//
	private String discountDetailName;// 折扣名称
	private String discountRate;// 折扣率
	
	public int getDiscountDetailID() {
		return discountDetailID;
	}

	public void setDiscountDetailID(int discountDetailID) {
		this.discountDetailID = discountDetailID;
	}

	public String getDiscountDetailName() {
		return discountDetailName;
	}

	public void setDiscountDetailName(String discountDetailName) {
		this.discountDetailName = discountDetailName;
	}

	public String getDiscountRate() {
		return discountRate;
	}

	public void setDiscountRate(String discountRate) {
		this.discountRate = discountRate;
	}
}
